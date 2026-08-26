/*
 * herdr-passthough — conditional key dispatch for herdr type="shell" keybinds.
 *
 * usage:
 *   herdr-passthough if-proc <regex> <key> [fallback-cmd...]
 *
 *   if-proc <regex> <key> [fallback...]
 *       If the focused pane's foreground process matches <regex>, forward
 *       <key> into that pane (pane.send_keys over herdr's socket). Otherwise
 *       execvp(3) the remaining arguments directly — no shell involved, so
 *       write the full command line yourself:
 *
 *         herdr-passthough if-proc '^nvim$' ctrl+h \
 *           herdr pane focus --direction left
 *
 *       A builtin fallback is the three-token form
 *
 *         herdr-passthough if-proc '^nvim$' ctrl+h \
 *           builtin current-pane left
 *
 *       (the action is one of up/down/left/right/close). Instead of running
 *       the `herdr` CLI it talks to herdr's socket directly — pane.focus_
 *       direction or pane.close — so the miss path costs one socket round
 *       trip, like the match path, instead of a fork/exec + binary load.
 *
 *       With no fallback arguments, a miss does nothing.
 *
 * The pane comes from $HERDR_ACTIVE_PANE_ID, which herdr exports to every
 * type="shell" keybind command. HERDR_IF_FG_DEBUG=1 logs every process name
 * seen during matching.
 *
 * Why C: a shell dispatcher paid fork/exec + shell startup + loading the
 * herdr binary twice (~50ms+) to do two ~0.3ms socket round trips. The match
 * path here is one fork/exec plus raw socket writes; only the fallback pays
 * for whatever command it runs. A `builtin current-pane <dir|close>` fallback
 * skips even that: it reuses the open socket to call pane.focus_direction /
 * pane.close directly, so the miss path is just one more ~0.3ms round trip.
 *
 * Env overrides: HERDR_SOCKET_PATH (API socket), HERDR_SESSION (named
 * session), XDG_CONFIG_HOME/HOME (default config dir).
 *
 * Exit codes: 0 dispatched (or nothing to do), 1 socket/exec failure,
 * 2 usage error.
 *
 * Build:  cc -O2 -Wall -Wextra -o herdr-passthough herdr-passthough.c
 */

#include <errno.h>
#include <regex.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/time.h>
#include <sys/un.h>
#include <unistd.h>

#define PROG "herdr-passthough"
#define REQ_ID "passthough"
#define PATH_BUF 1024
#define REQ_BUF 640
#define PANE_Q_BUF 256
#define KEY_Q_BUF 128
#define REPLY_TIMEOUT_MS 400

/* Method names mirror src/api/schema/panes.rs. Macros so they splice into
 * adjacent string literals below. */
#define METHOD_PROCESS_INFO "pane.process_info"
#define METHOD_SEND_KEYS "pane.send_keys"
#define METHOD_FOCUS_DIRECTION "pane.focus_direction"
#define METHOD_CLOSE "pane.close"

/* ------------------------------------------------------------------ */
/* diagnostics                                                         */
/* ------------------------------------------------------------------ */

static void warn(const char *fmt, ...) {
    va_list ap;
    fprintf(stderr, PROG ": ");
    va_start(ap, fmt);
    vfprintf(stderr, fmt, ap);
    va_end(ap);
    fputc('\n', stderr);
}

static void die_usage(const char *msg) {
    if (msg)
        warn("%s", msg);
    fprintf(stderr,
            "usage: " PROG " if-proc <regex> <key> [fallback-cmd...]\n");
    exit(2);
}

/* ------------------------------------------------------------------ */
/* json output: render request lines into fixed buffers                */
/* ------------------------------------------------------------------ */

/* Render s as a quoted JSON string literal. Returns 0 on truncation. */
static int json_quote(char *out, size_t cap, const char *s) {
    size_t n = 0;
    if (cap < 3)
        return 0;
    out[n++] = '"';
    for (; *s; s++) {
        char piece[8];
        size_t plen;
        unsigned char c = (unsigned char)*s;

        if (c == '"' || c == '\\') {
            piece[0] = '\\';
            piece[1] = (char)c;
            plen = 2;
        } else if (c < 0x20) {
            plen = (size_t)snprintf(piece, sizeof piece, "\\u%04x", c);
        } else {
            piece[0] = (char)c;
            plen = 1;
        }
        if (n + plen + 2 > cap) /* keep room for the closing '"' and NUL */
            return 0;
        memcpy(out + n, piece, plen);
        n += plen;
    }
    out[n++] = '"';
    out[n] = '\0';
    return 1;
}

static int make_process_info_req(const char *pane, char *out, size_t cap) {
    char pane_q[PANE_Q_BUF];
    if (!json_quote(pane_q, sizeof pane_q, pane))
        return -1;
    /* An empty pane id means "no HERDR_ACTIVE_PANE_ID" (e.g. manual
     * invocation). Omit pane_id entirely so herdr uses its active focused
     * pane, rather than sending "" which it rejects as pane_not_found. */
    if (*pane)
        return snprintf(out, cap,
                        "{\"id\":\"" REQ_ID "\",\"method\":\"" METHOD_PROCESS_INFO "\","
                        "\"params\":{\"pane_id\":%s}}\n",
                        pane_q) >= (int)cap ? -1 : 0;
    return snprintf(out, cap,
                    "{\"id\":\"" REQ_ID "\",\"method\":\"" METHOD_PROCESS_INFO "\","
                    "\"params\":{}}\n") >= (int)cap ? -1 : 0;
}

static int make_send_keys_req(const char *pane, const char *key, char *out, size_t cap) {
    char pane_q[PANE_Q_BUF], key_q[KEY_Q_BUF];
    if (!json_quote(pane_q, sizeof pane_q, pane) ||
        !json_quote(key_q, sizeof key_q, key))
        return -1;
    if (snprintf(out, cap,
                 "{\"id\":\"" REQ_ID "\",\"method\":\"" METHOD_SEND_KEYS "\","
                 "\"params\":{\"pane_id\":%s,\"keys\":[%s]}}\n",
                 pane_q, key_q) >= (int)cap)
        return -1;
    return 0;
}

/*
 * Move herdr focus in <direction> (one of up/down/left/right), starting from
 * <pane>. Mirrors `herdr pane focus --direction <dir>`. An empty pane omits
 * pane_id so the server uses the active focused pane.
 */
static int make_focus_direction_req(const char *pane, const char *direction,
                                    char *out, size_t cap) {
    char pane_q[PANE_Q_BUF], dir_q[64];
    if (!json_quote(pane_q, sizeof pane_q, pane) ||
        !json_quote(dir_q, sizeof dir_q, direction))
        return -1;
    if (*pane)
        return snprintf(out, cap,
                        "{\"id\":\"" REQ_ID "\",\"method\":\"" METHOD_FOCUS_DIRECTION "\","
                        "\"params\":{\"direction\":%s,\"pane_id\":%s}}\n",
                        dir_q, pane_q) >= (int)cap ? -1 : 0;
    return snprintf(out, cap,
                    "{\"id\":\"" REQ_ID "\",\"method\":\"" METHOD_FOCUS_DIRECTION "\","
                    "\"params\":{\"direction\":%s}}\n",
                    dir_q) >= (int)cap ? -1 : 0;
}

/* Close <pane> (the current pane). Mirrors `herdr pane close`. An empty pane
 * omits pane_id so the server closes the active focused pane. */
static int make_close_req(const char *pane, char *out, size_t cap) {
    char pane_q[PANE_Q_BUF];
    if (!json_quote(pane_q, sizeof pane_q, pane))
        return -1;
    if (*pane)
        return snprintf(out, cap,
                        "{\"id\":\"" REQ_ID "\",\"method\":\"" METHOD_CLOSE "\","
                        "\"params\":{\"pane_id\":%s}}\n",
                        pane_q) >= (int)cap ? -1 : 0;
    return snprintf(out, cap,
                    "{\"id\":\"" REQ_ID "\",\"method\":\"" METHOD_CLOSE "\","
                    "\"params\":{}}\n") >= (int)cap ? -1 : 0;
}

/* ------------------------------------------------------------------ */
/* wire: one newline-delimited JSON request per connection             */
/* ------------------------------------------------------------------ */

/* Resolve herdr's API socket the same way the CLI does. Returns 0 on truncation. */
static int socket_path_for(char *out, size_t cap) {
    const char *override_path = getenv("HERDR_SOCKET_PATH");
    if (override_path && *override_path)
        return snprintf(out, cap, "%s", override_path) < (int)cap;

    const char *config = getenv("XDG_CONFIG_HOME");
    if (!config || !*config) {
        static char fallback[PATH_BUF];
        const char *home = getenv("HOME");
        if (!home || !*home)
            return 0;
        if (snprintf(fallback, sizeof fallback, "%s/.config", home) >= (int)sizeof fallback)
            return 0;
        config = fallback;
    }

    const char *session = getenv("HERDR_SESSION");
    if (session && *session && strcmp(session, "default") != 0)
        return snprintf(out, cap, "%s/herdr/sessions/%s/herdr.sock", config, session) < (int)cap;

    return snprintf(out, cap, "%s/herdr/herdr.sock", config) < (int)cap;
}

static int connect_herdr(void) {
    char path[PATH_BUF];
    struct sockaddr_un addr;
    struct timeval tv = { .tv_sec = 0, .tv_usec = REPLY_TIMEOUT_MS * 1000 };
    int fd;

    if (!socket_path_for(path, sizeof path) || strlen(path) >= sizeof addr.sun_path)
        return -1;

    fd = socket(AF_UNIX, SOCK_STREAM, 0);
    if (fd < 0)
        return -1;

    memset(&addr, 0, sizeof addr);
    addr.sun_family = AF_UNIX;
    memcpy(addr.sun_path, path, strlen(path) + 1);

    if (connect(fd, (struct sockaddr *)&addr, sizeof addr) != 0) {
        close(fd);
        return -1;
    }

    setsockopt(fd, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof tv);
    setsockopt(fd, SOL_SOCKET, SO_SNDTIMEO, &tv, sizeof tv);
    return fd;
}

static int write_all(int fd, const char *data, size_t len) {
    size_t sent = 0;
    while (sent < len) {
        ssize_t w = write(fd, data + sent, len - sent);
        if (w < 0) {
            if (errno == EINTR)
                continue;
            return -1;
        }
        sent += (size_t)w;
    }
    return 0;
}

/* Read the reply up to its terminating newline. Returns a malloc'd line or NULL. */
static char *read_json_line(int fd) {
    size_t cap = 4096, len = 0;
    char *buf = malloc(cap);
    if (!buf)
        return NULL;

    for (;;) {
        ssize_t r;
        if (len + 1 >= cap) {
            char *grown = realloc(buf, cap *= 2);
            if (!grown) {
                free(buf);
                return NULL;
            }
            buf = grown;
        }
        r = read(fd, buf + len, cap - len - 1);
        if (r < 0 && errno == EINTR)
            continue;
        if (r <= 0)
            break;
        len += (size_t)r;
        buf[len] = '\0';
        if (memchr(buf, '\n', len))
            break;
    }

    if (len == 0) {
        free(buf);
        return NULL;
    }
    buf[len] = '\0';
    return buf;
}

/* Send one request and return its malloc'd reply line, or NULL after warning. */
static char *herdr_request(const char *req) {
    int fd = connect_herdr();
    if (fd < 0) {
        warn("cannot reach herdr socket");
        return NULL;
    }

    char *reply = NULL;
    if (write_all(fd, req, strlen(req)) == 0)
        reply = read_json_line(fd);
    close(fd);

    if (!reply) {
        warn("no reply from herdr");
        return NULL;
    }
    if (strstr(reply, "\"error\"") != NULL) {
        warn("request rejected: %.400s", reply);
        free(reply);
        return NULL;
    }
    return reply;
}

/* ------------------------------------------------------------------ */
/* json input: find foreground_processes[].name and match the regex    */
/* ------------------------------------------------------------------ */

/* Skip whitespace plus the separators that appear between tokens. */
static void json_skip(const char **pp) {
    while (**pp == ' ' || **pp == '\t' || **pp == ',' || **pp == ':')
        (*pp)++;
}

/*
 * Parse the quoted string at *pp (which must sit on the opening quote),
 * advance *pp past the closing quote, and report the raw content span.
 * Returns 0 on malformed input.
 */
static int json_span_string(const char **pp, const char **begin, size_t *len) {
    const char *p = *pp;
    if (*p != '"')
        return 0;
    *begin = ++p;
    while (*p && *p != '"') {
        if (*p == '\\' && p[1])
            p++;
        p++;
    }
    if (*p != '"')
        return 0;
    *len = (size_t)(p - *begin);
    *pp = p + 1;
    return 1;
}

/* Skip any single JSON value: string, number, literal, array, or object. */
static int json_skip_value(const char **pp) {
    const char *p = *pp;
    if (*p == '"')
        return json_span_string(pp, &(const char *){0}, &(size_t){0});

    if (*p == '[' || *p == '{') {
        int depth = 0;
        do {
            if (*p == '"') {
                const char *s;
                size_t n;
                if (!json_span_string(&p, &s, &n))
                    return 0;
                continue;
            }
            if (*p == '[' || *p == '{')
                depth++;
            else if (*p == ']' || *p == '}')
                depth--;
            p++;
        } while (*p && depth > 0);
        if (depth != 0)
            return 0;
        *pp = p;
        return 1;
    }

    while (**pp && **pp != ',' && **pp != '}' && **pp != ']')
        (*pp)++;
    return 1;
}

static void ascii_lower(char *s) {
    for (; *s; s++)
        if (*s >= 'A' && *s <= 'Z')
            *s = (char)(*s + 'a' - 'A');
}

static int span_matches(const char *val, size_t len, const regex_t *re, int debug) {
    char name[128];
    if (len >= sizeof name)
        return 0;
    memcpy(name, val, len);
    name[len] = '\0';
    ascii_lower(name);
    if (debug)
        fprintf(stderr, PROG ": fg process '%s'\n", name);
    return regexec(re, name, 0, NULL, 0) == 0;
}

/*
 * Run `re` against every lower-cased name in
 * result.process_info.foreground_processes[]. Returns 1 on the first match.
 * Malformed input counts as "no match".
 */
static int fg_has_process(const char *reply, const regex_t *re, int debug) {
    const char *p = strstr(reply, "\"foreground_processes\"");
    if (!p || (p = strchr(p, '[')) == NULL)
        return 0;

    p++; /* step over '[' */
    json_skip(&p);
    while (*p == '{') {
        p++; /* step over '{' */
        for (;;) {
            const char *key, *val;
            size_t key_len, val_len;

            json_skip(&p);
            if (*p == '}') { /* end of this process object */
                p++;
                break;
            }
            if (*p != '"')
                return 0;

            if (!json_span_string(&p, &key, &key_len))
                return 0;
            json_skip(&p);

            if (*p == '"') {
                if (!json_span_string(&p, &val, &val_len))
                    return 0;
                if (key_len == 4 && strncmp(key, "name", 4) == 0 &&
                    span_matches(val, val_len, re, debug))
                    return 1;
            } else if (!json_skip_value(&p)) {
                return 0;
            }
        }
        json_skip(&p);
    }
    return 0;
}

/* ------------------------------------------------------------------ */
/* subcommand: if-proc                                                 */
/* ------------------------------------------------------------------ */

typedef struct {
    const char *regex; /* foreground-process matcher      */
    const char *key;   /* chord forwarded on match        */
    char **fallback;   /* argv for execvp on miss, may be empty */
} IfProcArgs;

/* argv layout: if-proc <regex> <key> [fallback...] */
static void parse_if_proc_args(IfProcArgs *args, int argc, char **argv) {
    if (argc < 3)
        die_usage("need <regex> and <key>");
    args->regex = argv[1];
    args->key = argv[2];
    args->fallback = argv + 3;
}

/* Replace this process with the fallback command line. Never returns. */
static void run_fallback(char **fallback) {
    execvp(fallback[0], fallback);
    warn("cannot execute '%s': %s", fallback[0], strerror(errno));
    exit(127);
}

/*
 * A builtin fallback is the three-token form
 *
 *     builtin current-pane <up|down|left|right|close>
 *
 * which maps onto herdr's own API (pane.focus_direction / pane.close).
 * Instead of fork/exec-ing the `herdr` CLI, we dispatch the request down the
 * socket we already hold open — the miss path then costs one ~0.3ms round
 * trip, exactly like the match path, instead of a ~50ms+ fork/exec + binary
 * load. This is the herdr-nvim-nav trick: do the work in the one process herdr
 * already started for us.
 *
 * Returns:
 *   0  fallback is NOT the builtin form — caller should execvp it
 *   1  builtin form handled successfully
 *   2  builtin form recognized but the socket request failed
 */
static int run_builtin_fallback(char **fallback, const char *pane) {
    if (!fallback[0] || !fallback[1] || !fallback[2] || fallback[3])
        return 0; /* not the exact builtin form */
    if (strcmp(fallback[0], "builtin") != 0 ||
        strcmp(fallback[1], "current-pane") != 0)
        return 0;

    const char *action = fallback[2];
    char req[REQ_BUF];

    int built = 0;
    if (strcmp(action, "up") == 0 || strcmp(action, "down") == 0 ||
        strcmp(action, "left") == 0 || strcmp(action, "right") == 0) {
        built = make_focus_direction_req(pane, action, req, sizeof req) == 0;
    } else if (strcmp(action, "close") == 0) {
        built = make_close_req(pane, req, sizeof req) == 0;
    } else {
        warn("unknown builtin action '%s'", action);
        return 2;
    }
    if (!built) {
        warn("pane id too long");
        return 2;
    }

    char *reply = herdr_request(req);
    if (!reply)
        return 2;
    free(reply);
    return 1;
}

static int run_if_proc(int argc, char **argv) {
    IfProcArgs args;
    parse_if_proc_args(&args, argc, argv);

    regex_t re;
    if (regcomp(&re, args.regex, REG_EXTENDED | REG_NOSUB) != 0)
        die_usage("invalid regex");

    int debug = getenv("HERDR_IF_FG_DEBUG") != NULL;
    const char *pane = getenv("HERDR_ACTIVE_PANE_ID");
    if (!pane)
        pane = "";

    /* Ask which process owns the pane. */
    char req[REQ_BUF];
    if (make_process_info_req(pane, req, sizeof req) != 0)
        die_usage("pane id too long");

    char *reply = herdr_request(req);
    int matched = reply != NULL && fg_has_process(reply, &re, debug);
    free(reply);
    regfree(&re);

    if (matched) {
        if (make_send_keys_req(pane, args.key, req, sizeof req) != 0)
            die_usage("pane id too long");

        char *unused_reply = herdr_request(req);
        if (!unused_reply)
            return 1;
        free(unused_reply);
        return 0;
    }

    if (args.fallback[0] == NULL)
        return 0; /* no fallback configured: a miss does nothing */

    /* A builtin fallback dispatches straight to herdr's API in this process
     * — no fork/exec of the CLI. Anything else falls through to execvp. */
    int builtin = run_builtin_fallback(args.fallback, pane);
    if (builtin == 1)
        return 0;
    if (builtin == 2)
        return 1;

    run_fallback(args.fallback);
    return 127; /* unreachable */
}

/* ------------------------------------------------------------------ */
/* main                                                                */
/* ------------------------------------------------------------------ */

int main(int argc, char **argv) {
    if (argc < 2)
        die_usage(NULL);

    if (strcmp(argv[1], "if-proc") == 0)
        return run_if_proc(argc - 1, argv + 1);

    warn("unknown subcommand '%s'", argv[1]);
    die_usage(NULL);
    return 2;
}

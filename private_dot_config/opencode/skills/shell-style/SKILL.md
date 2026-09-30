---
name: shell-style
description: >-
  House style for bash scripts: `set -euo pipefail`, a header + usage block,
  `HERE`/`REPO` path resolution, the helper set (`need`, `die`, `title`,
  `runcmd`, `runeval`), one verb-named function per step, and a `main` that
  reads like an outline. Use when writing or reviewing setup, bootstrap,
  install, provisioning, or any multi-step shell script.
---

# Shell Script Style

Apply this style when writing or reviewing a shell script. The goal: a reader
opens `main()` and understands the whole workflow, while every side effect is
visible in the log and safe to re-run.

## Skeleton

```bash
#!/usr/bin/env bash
# One line: what this script does.
#
# Why anything non-obvious is the way it is (pinned version, mirror, caveat).
#
# Usage:
#   script.sh --target HOST [--port 22]
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO="$(cd "$HERE/.." && pwd)"

PORT="${PORT:-22}"     # env-overridable default
TARGET="${TARGET:-}"   # required; validated in resolve()

# -- helpers ---------------------------------------------------------------

need() { command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"; }
die()  { echo "error: $*" >&2; exit 1; }

runcmd() {             # argv form: no shell parsing, no injection
    echo "Running: $*"
    "$@"
}

runeval() {            # shell form: pipes, redirections, exports, globs
    echo "Running: $*"
    eval "$*"
}

title() {              # step banner: prints the *calling* function's name
    echo "=========================="
    echo "${FUNCNAME[1]}"
    echo "=========================="
}

# -- steps -----------------------------------------------------------------

check_env() {
    title
    runcmd need git
    runcmd need curl
}

ensure_thing() {
    title
    [[ -e "$THING" ]] && return 0        # probe the final artifact, then skip
    runcmd mkdir -p "$(dirname "$THING")"
    runcmd curl -fL --retry 3 -o "$THING.part" "$URL"
    runcmd mv "$THING.part" "$THING"     # atomic publish
}

# -- main ------------------------------------------------------------------

main() {
    check_env
    ensure_thing
}

main "$@"
```

## Rules

1. **Header first, strict mode second.** A comment block says what the script
   does and how to run it; then `set -euo pipefail`. Never work around strict
   mode with scattered `|| true`.
2. **Constants at the top, env-overridable.** `PORT="${PORT:-22}"`. Annotate
   magic values (URL, pinned version, mirror) with why they are what they are.
3. **Resolve paths from `BASH_SOURCE`** (`HERE`, then `REPO`/`TOP`). Never
   assume the caller's `$PWD`; the script must work from anywhere.
4. **Helper set:** `need` (dependency pre-check), `die` (single error exit),
   `title` (step banner), `runcmd`/`runeval` (side-effect runners).
5. **`title` opens every step.** It prints `${FUNCNAME[1]}`, so the banner is
   the step's own name — never repeat the name in the call site.
6. **Wrap every side effect in `runcmd`.** Downloads, `mkdir`, `mv`, `cp`,
   `chmod`, builds, `ssh`, package installs. Side effects must be visible and
   run under strict mode.
7. **`runeval` only when you need shell syntax:** pipes, redirection, `export`,
   globs, `$(...)`, here-docs, `&&`/`||` chains. For everything else prefer
   `runcmd` — it passes argv directly and cannot be re-split by the shell.
8. **Do not wrap pure logic.** Conditionals, assignments, `[[ ]]`,
   `command -v`, arithmetic, and `case` are not side effects.
9. **One verb-named function per step.** `main()` is a bare outline of step
   calls:

   ```bash
   main() {
       parse_args "$@"
       resolve
       check_env
       ensure_thing
   }
   main "$@"
   ```
10. **Idempotency, probe-then-skip.** Probe the *final artifact* and
    short-circuit with a message, rather than tracking "did I run before".
    Download to `"$X.part"` then `mv` (no half files that look complete).
    Never clobber existing data (per-file no-clobber; add an explicit
    `--force` if overwrite is a real need).
11. **`pipefail` gotcha.** Avoid `cmd | head`; when `head` exits early the
    upstream gets `SIGPIPE` and the pipeline aborts the script. Use
    `cmd | sed -n '1,5p'`, `cmd | awk 'NR<=5'`, or `find ... -print -quit`.
12. **Quote every `"$VAR"`.** `die` messages should be actionable: name the
    missing thing and how to supply it.
13. **Secrets never hardcoded or committed.** Read them from an env var or a
    file outside version control; document the override. Never accept a
    password as an argv argument (it leaks to `ps` and shell history) — use an
    env var or a hidden prompt.
14. **stdout vs stderr.** If a step's stdout is captured with `$(...)`, send
    its log line to stderr (`echo ... >&2`) so it does not pollute the captured
    value. Otherwise stdout is fine.
15. **End with a handoff.** Print the next copy-pasteable command (or the
    resulting path/config) so the run is self-explanatory.

## `runcmd` vs `runeval`

| Need | Use | Example |
| --- | --- | --- |
| Run a program with fixed args | `runcmd` | `runcmd git add -N .` |
| `mkdir`, `mv`, `cp`, `chmod` | `runcmd` | `runcmd chmod 700 "$DIR"` |
| Pipe / redirect | `runeval` | `runeval 'tool dump >"$OUT"'` |
| `export` / `source` / glob / `$(...)` | `runeval` | `runeval 'export PATH="$HOME/bin:$PATH"'` |
| `cd` + run (inside a step) | subshell | `( cd "$TOP" && runcmd make )` |

## Argument parsing

Use a `while [ "$#" -gt 0 ]; do case "$1" in ... esac; done` loop with a
`usage()` heredoc for `-h/--help`; validate required values in a `resolve`
step before any side effects. Every option should also be settable via a
same-named environment variable, so the script works both interactively and in
CI.

## Review checklist

- Side effect not wrapped in `runcmd`/`runeval` → flag it.
- `runcmd` used with pipes, redirections, or `&&` → must be `runeval`.
- Pure test/assignment wrapped in `runcmd` → unwrap it.
- Step reruns unconditionally → make it probe-then-skip.
- `cmd | head` under `pipefail` → replace with `sed`/`awk`.
- Password or token in argv or committed → move to env var or file.
- Hard-coded `$PWD` assumption → resolve from `BASH_SOURCE`.

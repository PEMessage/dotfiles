// OpenCode V2 plugin.
//
// Mirrors the current agent session status into the tmux window bar through the
// `tmux-pane-status` helper, so workmux can render a per-pane indicator.
//
// Migrated from the V1 `@opencode-ai/plugin` implementation:
//   - the returned `event` hook is now `ctx.event.subscribe()`, aborted on unload
//   - `$` (the V1 Bun shell helper) is replaced by `node:child_process`
//   - event payloads live on `event.data` instead of `event.properties`
//   - `question.asked` / `question.replied` became `form.created` / `form.replied`
//
// A V2 plugin only needs a stable `id` and a `setup(ctx)` function. Local plugins
// discovered under `~/.config/opencode/plugins/` do not need a config entry.
//
// Note: like the V1 version, this relies on the process environment (notably
// `TMUX_PANE`) to pick the target pane. With V2's shared background service that
// environment belongs to the service, not necessarily to the pane running the
// session. Run `opencode --standalone` when panes must be attributed correctly.

import { spawn } from "node:child_process";

/**
 * Run `tmux-pane-status` quietly. Equivalent to the V1 `$\`${args}\`.quiet()`:
 * the arguments are passed in order, and output or a missing binary is ignored.
 */
function runTmuxPaneStatus(args: readonly string[]): Promise<void> {
  return new Promise((resolve) => {
    const child = spawn("tmux-pane-status", args, { stdio: "ignore" });
    child.once("error", () => resolve());
    child.once("close", () => resolve());
  });
}

export default {
  id: "tmux.status",

  async setup(ctx: any) {
    // OpenCode can emit repeated `session.status busy` events for a single turn,
    // and can even emit a stale trailing `busy` after `idle` at the end. Track
    // per-session status so workmux only sees real transitions.
    const lastStatusBySession = new Map<string, string>();
    const acceptBusyBySession = new Map<string, boolean>();

    async function setStatus(sessionID: string | undefined, status: string) {
      if (!sessionID) {
        return;
      }

      const previous = lastStatusBySession.get(sessionID);
      // Ignore the final stale `busy` OpenCode sometimes emits after a session
      // is already done. The next user message re-arms `working` for the turn.
      if (status === "working" && acceptBusyBySession.get(sessionID) === false) {
        return;
      }
      if (previous === status) {
        return;
      }

      lastStatusBySession.set(sessionID, status);
      acceptBusyBySession.set(sessionID, status !== "done");

      const args: string[] = [];
      if (status !== "working") {
        args.push("--auto-clear");
      }
      args.push(status);
      await runTmuxPaneStatus(args);
    }

    const controller = new AbortController();

    void (async () => {
      try {
        for await (const event of ctx.event.subscribe({ signal: controller.signal })) {
          const data = event.data ?? {};

          switch (event.type) {
            case "message.updated":
              if (data.info?.role === "user") {
                acceptBusyBySession.set(data.sessionID, true);
              }
              break;
            case "session.status":
              if (data.status?.type === "busy") {
                await setStatus(data.sessionID, "working");
              } else if (data.status?.type === "idle") {
                await setStatus(data.sessionID, "done");
              }
              break;
            case "permission.asked":
            case "form.created":
              await setStatus(data.sessionID ?? data.form?.sessionID, "waiting");
              break;
            case "permission.replied":
            case "form.replied":
              await setStatus(data.sessionID, "working");
              break;
            case "session.idle":
              await setStatus(data.sessionID, "done");
              break;
          }
        }
      } catch (error) {
        if (!controller.signal.aborted) {
          console.error("tmux-status: event stream failed", error);
        }
      }
    })();

    return () => controller.abort();
  },
};

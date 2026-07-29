#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.10"
# ///

import asyncio
import json
import os
import re
import sys
import argparse
from pathlib import Path
from typing import Optional


# ── LSP framing helpers ────────────────────────────────────────────────

CONTENT_LENGTH_RE = re.compile(rb"Content-Length:\s*(\d+)")


async def _read_exactly(reader: asyncio.StreamReader, n: int) -> bytes:
    data = b""
    while len(data) < n:
        chunk = await reader.read(n - len(data))
        if not chunk:
            raise EOFError(f"Stream closed while reading {n} bytes (got {len(data)})")
        data += chunk
    return data


async def lsp_read(reader: asyncio.StreamReader) -> dict:
    """Read one LSP message (Content-Length header + JSON body)."""
    headers = {}
    while True:
        line = await reader.readline()
        if line in (b"\r\n", b"\n"):
            break
        m = CONTENT_LENGTH_RE.match(line)
        if m:
            headers["Content-Length"] = int(m.group(1))
        elif b":" in line:
            key, _, value = line.decode("ascii").partition(":")
            headers[key.strip()] = value.strip()

    content_length = headers.get("Content-Length", 0)
    if content_length == 0:
        return {}
    body = await _read_exactly(reader, content_length)
    return json.loads(body)


def lsp_write(writer: asyncio.StreamWriter, message: dict) -> None:
    """Write one LSP message (Content-Length header + JSON body)."""
    body = json.dumps(message)
    header = f"Content-Length: {len(body)}\r\n\r\n".encode("ascii")
    writer.write(header + body.encode("utf-8"))


async def lsp_request(
    writer: asyncio.StreamWriter,
    reader: asyncio.StreamReader,
    method: str,
    params: dict,
    msg_id: int,
    timeout: float = 60.0,
) -> dict:
    """Send a JSON-RPC request and wait for the matching response."""
    req = {"jsonrpc": "2.0", "id": msg_id, "method": method, "params": params}
    lsp_write(writer, req)
    await writer.drain()

    while True:
        msg = await asyncio.wait_for(lsp_read(reader), timeout=timeout)
        if msg.get("id") == msg_id:
            return msg


async def lsp_notify(
    writer: asyncio.StreamWriter,
    method: str,
    params: dict,
) -> None:
    """Send a JSON-RPC notification (no response expected)."""
    notif = {"jsonrpc": "2.0", "method": method, "params": params}
    lsp_write(writer, notif)
    await writer.drain()


# ── Server discovery ───────────────────────────────────────────────────

def find_intellij_server() -> Optional[str]:
    """Find the intellij-server binary via Mason, env var, or PATH."""
    mason_base = os.path.expanduser("~/.local/share/nvim/mason/packages/kotlin-lsp")
    if not os.path.isdir(mason_base):
        mason_base = os.path.expanduser(
            "~/AppData/Local/nvim-data/mason/packages/kotlin-lsp"
        )

    search_dirs = []
    if os.path.isdir(mason_base):
        search_dirs.append(mason_base)
        for entry in sorted(os.listdir(mason_base)):
            if entry.startswith("kotlin-server-"):
                versioned = os.path.join(mason_base, entry)
                if os.path.isdir(versioned):
                    search_dirs.append(versioned)

    if os.environ.get("KOTLIN_LSP_DIR"):
        search_dirs.append(os.environ["KOTLIN_LSP_DIR"])

    for base in search_dirs:
        bin_dir = os.path.join(base, "bin")
        for name in ("intellij-server", "intellij-server.exe"):
            path = os.path.join(bin_dir, name)
            if os.path.isfile(path):
                return path

    import shutil
    for name in ("intellij-server", "intellij-server.exe"):
        path = shutil.which(name)
        if path:
            return path

    return None


# ── Background stderr drainer ──────────────────────────────────────────

async def _drain_stderr(stderr: Optional[asyncio.StreamReader]) -> None:
    if stderr is None:
        return
    while True:
        line = await stderr.readline()
        if not line:
            break
        # Uncomment next line to see server logs on stderr:
        # print(f"[server] {line.decode().rstrip()}", file=sys.stderr)
        _ = line  # suppress unused warning


# ── Main export routine ────────────────────────────────────────────────

async def _wait_progress_done(
    writer: asyncio.StreamWriter,
    reader: asyncio.StreamReader,
    settle_s: float = 3.0,
    max_wait_s: float = 300.0,
) -> None:
    """
    Read LSP messages until no $/progress activity settles for settle_s seconds.

    Responds to window/workDoneProgress/create server requests so the server
    can send $/progress notifications. Displays live progress bars or spinners
    à la Neovim's LSP progress display.
    """
    _SPINNER = "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"

    tokens: dict[str, None] = {}
    _progress_info: dict[str, dict] = {}
    last_progress_at = asyncio.get_event_loop().time()
    spin_idx = 0

    def _fmt_line(info: dict) -> str:
        """Format one progress line: spinner + bar-or-text."""
        spin = _SPINNER[spin_idx % len(_SPINNER)]
        title = info.get("title", "")
        message = info.get("message", "")
        pct = info.get("percentage", -1)

        label = message or title
        if pct > 0:
            w = 20
            filled = int(w * pct / 100)
            bar = "[" + "=" * filled + "-" * (w - filled) + f"] {pct:>3}%"
            return f"  {spin} {bar}  {label}"
        else:
            return f"  {spin} {label}"

    def _render():
        nonlocal spin_idx
        spin_idx += 1
        lines = [_fmt_line(info) for tok in tokens
                 if (info := _progress_info.get(tok))]
        if lines:
            print("\033[K" + "\n".join(lines), flush=True)
            print(f"\033[{len(lines)}A", end="", flush=True)

    while True:
        try:
            msg = await asyncio.wait_for(lsp_read(reader), timeout=min(settle_s, 2.0))
        except asyncio.TimeoutError:
            msg = None

        now = asyncio.get_event_loop().time()
        idle = now - last_progress_at

        if msg is None:
            if not tokens and idle >= settle_s:
                print("\033[K", end="", flush=True)
                return
            continue

        method = msg.get("method", "")

        if method == "window/workDoneProgress/create":
            req_id = msg.get("id")
            lsp_write(writer, {"jsonrpc": "2.0", "id": req_id, "result": None})
            await writer.drain()
            continue

        if method == "$/progress":
            params = msg.get("params", {})
            token_str = str(params.get("token", ""))
            value = params.get("value", {})
            kind = value.get("kind")

            if kind == "begin":
                tokens[token_str] = None
                _progress_info[token_str] = {
                    "title": value.get("title", ""),
                    "message": value.get("message", ""),
                    "percentage": 0,
                }
                last_progress_at = now
                _render()

            elif kind == "report":
                if token_str in _progress_info:
                    info = _progress_info[token_str]
                    if "percentage" in value:
                        info["percentage"] = value["percentage"]
                    if "message" in value:
                        info["message"] = value["message"]
                    last_progress_at = now
                    _render()

            elif kind == "end":
                tokens.pop(token_str, None)
                _progress_info.pop(token_str, None)
                last_progress_at = now
                _render()

            continue

        if method in ("window/showMessage", "window/logMessage"):
            params = msg.get("params", {})
            mtype = {1: "ERR", 2: "WRN", 3: "INFO", 4: "LOG"}.get(
                params.get("type", 4), "MSG")
            print(f"  [{mtype}] {params.get('message', '')}", flush=True)
            continue

        if now - last_progress_at > max_wait_s:
            print("\n  reached maximum wait, continuing anyway", flush=True)
            return


async def export_workspace(
    project_dir: str,
    server_path: Optional[str] = None,
    system_path: Optional[str] = None,
) -> None:
    if server_path is None:
        server_path = find_intellij_server()

    if not server_path:
        print("Error: Could not find intellij-server binary.", file=sys.stderr)
        print("  Install: :MasonInstall kotlin-lsp", file=sys.stderr)
        print("  Or set KOTLIN_LSP_DIR env var", file=sys.stderr)
        print("  Or pass --server-path", file=sys.stderr)
        sys.exit(1)

    if not os.path.isfile(server_path):
        print(f"Error: 'intellij-server' not found at {server_path}", file=sys.stderr)
        sys.exit(1)

    project_dir = os.path.abspath(project_dir)
    root_uri = Path(project_dir).as_uri()

    print(f"server  : {server_path}")
    print(f"project : {project_dir}")
    if system_path:
        print(f"system  : {system_path}")
    print()

    cmd = [server_path, "--stdio"]
    if system_path:
        cmd.append(f"--system-path={system_path}")
    proc = await asyncio.create_subprocess_exec(
        *cmd,
        stdin=asyncio.subprocess.PIPE,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.PIPE,
    )

    stderr_task = asyncio.create_task(_drain_stderr(proc.stderr))
    assert proc.stdout is not None and proc.stdin is not None
    reader, writer = proc.stdout, proc.stdin

    try:
        # 1 ── Initialize
        print("[1/4] initialize …", flush=True)
        init_resp = await lsp_request(writer, reader, "initialize", {
            "processId": os.getpid(),
            "rootUri": root_uri,
            "workspaceFolders": [{"uri": root_uri, "name": os.path.basename(project_dir)}],
            "capabilities": {
                "window": {
                    "workDoneProgress": True,
                },
            },
            "initializationOptions": {},
        }, msg_id=1, timeout=60.0)

        if "error" in init_resp:
            print(f"  error: {json.dumps(init_resp['error'], indent=2)}", file=sys.stderr)
            sys.exit(1)

        info = init_resp.get("result", {}).get("serverInfo", {})
        print(f"  connected → {info.get('name', 'kotlin-lsp')} {info.get('version', '')}")
        print()

        # 2 ── Send initialized + wait for Gradle import to finish
        print("[2/4] waiting for Gradle import …", flush=True)
        await lsp_notify(writer, "initialized", {})

        await _wait_progress_done(writer, reader, settle_s=3.0, max_wait_s=300.0)
        print("  import finished.")
        print()

        # 3 ── Execute exportWorkspace
        print("[3/4] workspace/executeCommand exportWorkspace …", flush=True)
        export_resp = await lsp_request(writer, reader, "workspace/executeCommand", {
            "command": "exportWorkspace",
            "arguments": [project_dir],
        }, msg_id=2, timeout=300.0)

        if "error" in export_resp:
            print(f"  error: {json.dumps(export_resp['error'], indent=2)}", file=sys.stderr)
            sys.exit(1)

        result = export_resp.get("result")
        if result and result.get("status") == "OK":
            print(f"  OK", flush=True)
        else:
            print(f"  result: {json.dumps(result, indent=2)}")

        ws_file = os.path.join(project_dir, "workspace.json")
        if os.path.isfile(ws_file):
            print(f"  file  : {ws_file}  ({os.path.getsize(ws_file):,} bytes)")
        print()

        # 4 ── Shutdown
        print("[4/4] shutdown + exit …", flush=True)
        await lsp_request(writer, reader, "shutdown", {}, msg_id=3, timeout=10.0)
        await lsp_notify(writer, "exit", {})
        print("  done.")

    finally:
        try:
            proc.terminate()
            await asyncio.wait_for(proc.wait(), timeout=5.0)
        except (asyncio.TimeoutError, ProcessLookupError):
            proc.kill()
            await proc.wait()
        stderr_task.cancel()
        try:
            await stderr_task
        except asyncio.CancelledError:
            pass


# ── CLI ────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(
        description="Export Kotlin workspace structure to workspace.json via LSP"
    )
    parser.add_argument(
        "project_dir", nargs="?", default=".",
        help="Kotlin project directory (default: .)",
    )
    parser.add_argument(
        "--server-path",
        help="Path to intellij-server binary (auto-detected)",
    )
    parser.add_argument(
        "--system-path",
        default=None,
        help="System data dir for kotlin-lsp",
    )
    args = parser.parse_args()
    asyncio.run(export_workspace(
        args.project_dir,
        server_path=args.server_path,
        system_path=args.system_path,
    ))


if __name__ == "__main__":
    main()

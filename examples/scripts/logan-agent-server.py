#!/usr/bin/env python3
"""Minimal HTTP remote agent wrapper around Logan headless.

Author: Yuval Avidani (YUV.AI) - https://yuv.ai

  python3 examples/scripts/logan-agent-server.py --port 8787

  curl -s localhost:8787/v1/run -H 'content-type: application/json' -d '{
    "prompt": "Summarize this repo",
    "cwd": "/path/to/repo",
    "model": "tier-default",
    "max_turns": 20
  }'

Security: binds 127.0.0.1 only. Put auth in front before any remote exposure.
Optional: LOGAN_AGENT_TOKEN required as Bearer token when set.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import tempfile
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import urlparse


def run_logan(body: dict) -> dict:
    prompt = body.get("prompt") or ""
    if not prompt.strip():
        return {"ok": False, "error": "prompt required"}

    model = body.get("model") or os.environ.get("MODEL", "tier-default")
    cwd = body.get("cwd") or os.getcwd()
    max_turns = int(body.get("max_turns") or 40)
    always = body.get("always_approve", True)
    logan = os.environ.get("LOGAN_BIN", "logan")

    cmd = [
        logan,
        "-p",
        prompt,
        "--cwd",
        cwd,
        "-m",
        str(model),
        "--output-format",
        "json",
        "--max-turns",
        str(max_turns),
    ]
    if always:
        cmd.append("--always-approve")

    try:
        proc = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=int(body.get("timeout_secs") or 600),
        )
    except subprocess.TimeoutExpired:
        return {"ok": False, "error": "timeout", "model": model, "cwd": cwd}
    except FileNotFoundError:
        return {"ok": False, "error": f"logan binary not found: {logan}"}

    usage = None
    text = proc.stdout
    try:
        data = json.loads(proc.stdout)
        if isinstance(data, dict):
            usage = data.get("usage")
            text = (
                data.get("result")
                or data.get("text")
                or data.get("data")
                or proc.stdout
            )
    except json.JSONDecodeError:
        pass

    # best-effort ledger
    stats = Path(os.environ.get("LOGAN_HOME", Path.home() / ".logan")) / "stats"
    stats.mkdir(parents=True, exist_ok=True)
    rec = {
        "model": model,
        "cwd": cwd,
        "exit_code": proc.returncode,
        "usage": usage,
        "stderr_tail": (proc.stderr or "")[-2000:],
    }
    with (stats / "usage.jsonl").open("a", encoding="utf-8") as f:
        f.write(json.dumps(rec) + "\n")

    return {
        "ok": proc.returncode == 0,
        "exit_code": proc.returncode,
        "model": model,
        "cwd": cwd,
        "text": text,
        "usage": usage,
        "stderr": (proc.stderr or "")[-4000:],
    }


class Handler(BaseHTTPRequestHandler):
    server_version = "LoganAgent/0.1"

    def _auth_ok(self) -> bool:
        token = os.environ.get("LOGAN_AGENT_TOKEN")
        if not token:
            return True
        auth = self.headers.get("Authorization", "")
        return auth == f"Bearer {token}"

    def _json(self, code: int, payload: dict) -> None:
        raw = json.dumps(payload).encode("utf-8")
        self.send_response(code)
        self.send_header("content-type", "application/json")
        self.send_header("content-length", str(len(raw)))
        self.end_headers()
        self.wfile.write(raw)

    def do_GET(self) -> None:  # noqa: N802
        path = urlparse(self.path).path
        if path in ("/health", "/v1/health"):
            self._json(200, {"ok": True, "service": "logan-agent"})
            return
        self._json(404, {"ok": False, "error": "not found"})

    def do_POST(self) -> None:  # noqa: N802
        if not self._auth_ok():
            self._json(401, {"ok": False, "error": "unauthorized"})
            return
        path = urlparse(self.path).path
        if path not in ("/v1/run", "/run"):
            self._json(404, {"ok": False, "error": "not found"})
            return
        n = int(self.headers.get("content-length") or 0)
        try:
            body = json.loads(self.rfile.read(n).decode("utf-8") or "{}")
        except json.JSONDecodeError:
            self._json(400, {"ok": False, "error": "invalid json"})
            return
        result = run_logan(body)
        self._json(200 if result.get("ok") else 500, result)

    def log_message(self, fmt: str, *args) -> None:
        # quieter default
        sys_stderr = __import__("sys").stderr
        sys_stderr.write("%s - %s\n" % (self.address_string(), fmt % args))


def main() -> None:
    ap = argparse.ArgumentParser(description="Logan remote agent HTTP wrapper")
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--port", type=int, default=8787)
    args = ap.parse_args()
    httpd = ThreadingHTTPServer((args.host, args.port), Handler)
    print(f"logan-agent listening on http://{args.host}:{args.port}", flush=True)
    print("POST /v1/run  GET /health", flush=True)
    if os.environ.get("LOGAN_AGENT_TOKEN"):
        print("auth: Bearer LOGAN_AGENT_TOKEN required", flush=True)
    httpd.serve_forever()


if __name__ == "__main__":
    main()

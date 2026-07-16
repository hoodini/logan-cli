# LLM install prompt - paste this into any coding agent

**Author:** Yuval Avidani (YUV.AI) · https://yuv.ai

Copy everything below the line into Claude / Cursor / Grok / Codex / etc.

---

## Task

Install and start **Logan CLI** (fork of xAI Grok Build by Yuval Avidani / YUV.AI) on this machine so the user can run `logan` with the same xAI/Grok auth, auto-loaded skills + MCPs, and Logan slash commands (`/stats`, `/goal`, `/context`).

### Do all of this without asking questions

1. If repo is not present:
   ```bash
   git clone https://github.com/hoodini/logan-cli.git
   cd logan-cli
   ```
2. Prerequisites if missing: `rustup` (Rust 1.92+), `protoc` (or use `bin/protoc` in repo), ensure `PATH` has `~/.cargo/bin` and `~/.local/bin`.
3. Run:
   ```bash
   bash scripts/install-logan.sh
   ```
4. Auth (pick first that works):
   - If user already uses Grok Build / xAI: `logan login` (OIDC, same as grok.com).
   - Else if `XAI_API_KEY` exists in env or a secrets file: export it.
   - Else: print that they must run `logan login` once in a browser-capable terminal.
5. Smoke test:
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   logan --version
   logan -p "Reply with exactly: logan-ok" --always-approve 2>&1 | tail -20
   ```
6. Confirm:
   - Binary is BOTH `~/.local/bin/logan` AND `~/.logan/bin/logan` (same binary - avoids stale leader).
   - `~/.logan/config.toml` has memory + `[compat.claude]` / `[compat.cursor]` skills/mcps.
   - Skills under `~/.grok/skills`, `~/.claude/skills`, `~/.agents/skills` are visible (sync or auto-discover).
   - MCP auto-loads from `~/.logan/config.toml` `[mcp_servers.*]`, project `.mcp.json`, `~/.cursor/mcp.json`, Claude mcp config when compat is on.
7. Tell the user:
   ```text
   logan                 # open TUI
   /stats /context /goal # after first turn
   ```

### Do not

- Do not leave them on official `grok` from xai-org without installing Logan.
- Do not only copy to `~/.local/bin` - also overwrite `~/.logan/bin/logan`.
- Do not require them to hand-edit TOML if the install script can seed it.

### Success criteria

`which logan` → `~/.local/bin/logan`, version mentions Logan / Yuval Avidani, headless prompt returns text, TUI has `/stats`.

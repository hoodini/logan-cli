# START HERE - Logan in 60 seconds

**Yuval Avidani (YUV.AI)** · https://github.com/hoodini/logan-cli

## You already built from this repo

```bash
bash scripts/install-logan.sh
export PATH="$HOME/.local/bin:$PATH"
logan login          # same xAI OIDC as Grok Build / this chat
logan                # open TUI
```

Inside the TUI after any turn:

| Command | What |
| --- | --- |
| `/stats` | colorful API in / out / cache / $ by model |
| `/context` | window bar + categories |
| `/context deep` | **actual** system prompt + message texts for those tokens |
| `/goal …` | autonomous goal loop |
| `/mcp` | MCP servers |
| `/skills` | discovered skills |

Status bar shows:

```text
m <model> · s <search> · mcp N    |    24K/200K 12% · in … out … c …
```

## Auth = Grok / xAI

Logan uses the **same** xAI auth stack as Grok Build:

- `logan login` → browser → `~/.logan/auth.json`
- or `export XAI_API_KEY=…`

If you already ran `grok login`, copy auth once:

```bash
mkdir -p ~/.logan
cp ~/.grok/auth.json ~/.logan/auth.json   # only if logan auth is empty
```

## Skills + MCP (automatic)

Already auto-loaded (no manual step):

| Source | Skills | MCP |
| --- | --- | --- |
| `~/.logan/skills`, project `.logan/skills` | yes | - |
| `~/.grok/skills`, project `.grok/skills` | yes | - |
| `~/.claude/skills`, `~/.cursor/skills`, `~/.agents/skills` | yes (compat on) | - |
| `~/.logan/config.toml` `[mcp_servers.*]` | - | yes |
| project `.mcp.json` | - | yes |
| `~/.cursor/mcp.json` | - | yes (compat) |
| Claude MCP config | - | yes (compat) |

`install-logan.sh` also **copies missing** skills from grok/claude/agents into `~/.logan/skills`.

## Headless smoke test

```bash
logan -p "Reply with exactly: logan-ok" --always-approve
```

## LLM agents installing for you

Paste **[docs/LLM_INSTALL_PROMPT.md](LLM_INSTALL_PROMPT.md)** into any coding agent.

## Full docs

- [SETUP.md](SETUP.md) · [FEATURES.md](FEATURES.md) · [WEB_SEARCH.md](WEB_SEARCH.md) · [UX_VISION.md](UX_VISION.md)

# START HERE - Logan in 60 seconds

**Yuval Avidani (YUV.AI)** · https://github.com/hoodini/logan-cli

**Core idea:** Logan shows **what you spend** - live on the bar, as a colorful
ledger, and as the **real text** inside the context window.

Full token guide: **[TOKEN_VISIBILITY.md](TOKEN_VISIBILITY.md)**

## Install + open

```bash
bash scripts/install-logan.sh
export PATH="$HOME/.local/bin:$PATH"
logan login          # same xAI OIDC as Grok Build / this chat
logan                # open TUI
```

## After any turn - visibility recipe

| Command | What you learn |
| --- | --- |
| *(status bar)* | Window fill % · last sample **in / out / cache** · model · search · mcp |
| **`/stats`** | Colorful API bill: IN · OUT · CACHE · REASON · $ · by model |
| **`/context`** | Composition bar - system vs messages vs tools vs free |
| **`/context deep`** | **Actual** system prompt + user/assistant/tool texts for those tokens |
| `/goal …` | Autonomous goal loop |
| `/mcp` · `/skills` | Connected servers and discovered skills |

Status bar:

```text
m <model> · s <search> · mcp N    24K/200K 12% · in 2.4K out 180 c 1.2K
```

Never guess where tokens went - `/stats` for the bill, `/context deep` for the text.

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

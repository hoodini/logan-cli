<p align="center">
  <img src="docs/assets/banner.jpg" alt="Logan CLI by Yuval Avidani (YUV.AI)" width="100%"/>
</p>

<h1 align="center">Logan <code>logan</code></h1>

<p align="center">
  <strong>Terminal AI coding agent</strong> by
  <a href="https://yuv.ai">Yuval Avidani</a> (YUV.AI) - AI Builder &amp; Speaker
  <br/>
  Fork of <a href="https://github.com/xai-org/grok-build">xAI Grok Build</a> (Apache-2.0)
  with multi-LLM presets, Hermes-style learning, and ship-ready docs.
</p>

<p align="center">
  <a href="https://github.com/hoodini/logan-cli"><img alt="GitHub" src="https://img.shields.io/badge/github-hoodini%2Flogan--cli-ff4d9a?style=flat-square"/></a>
  <a href="docs/SETUP.md"><img alt="Setup" src="https://img.shields.io/badge/setup-5%20min-b2f2bb?style=flat-square"/></a>
  <a href="docs/COMPARISON.md"><img alt="vs Grok Build" src="https://img.shields.io/badge/vs-Grok%20Build%20OSS-a5d8ff?style=flat-square"/></a>
  <a href="LICENSE"><img alt="License" src="https://img.shields.io/badge/license-Apache%202.0-ffd60a?style=flat-square"/></a>
</p>

<p align="center">
  <img src="docs/assets/screenshot-tui.jpg" alt="Logan TUI mock" width="90%"/>
</p>

```sh
logan --version
# Logan TUI by Yuval Avidani (YUV.AI) - https://yuv.ai
```

| | |
| --- | --- |
| Web | [yuv.ai](https://yuv.ai) |
| Linktree | [linktr.ee/yuvai](https://linktr.ee/yuvai) |
| X | [@yuvalav](https://x.com/yuvalav) |
| Instagram | [@yuval_770](https://instagram.com/yuval_770) |
| Facebook | [@yuval.avidani](https://facebook.com/yuval.avidani) |
| GitHub | [@hoodini](https://github.com/hoodini) |
| TikTok | [@yuval.ai](https://tiktok.com/@yuval.ai) |

---

## Why Logan (vs Grok Build open source)?

<p align="center">
  <img src="docs/assets/comparison.svg" alt="Grok Build vs Logan" width="95%"/>
</p>

Full matrix: **[docs/COMPARISON.md](docs/COMPARISON.md)**

| Logan adds | Detail |
| --- | --- |
| **`logan` product identity** | Binary, `~/.logan`, YUV.AI credit |
| **Multi-provider presets** | Anthropic, OpenAI, Gemini, OpenRouter, Ollama, LM Studio, LiteLLM, Bedrock-via-proxy |
| **Self-improve + learn-user skills** | Hermes-style lessons + personal preferences |
| **Auto reflection hooks** | `Stop` / `SessionEnd` → MEMORY.md |
| **Architecture + Excalidraw diagrams** | Prompt lifecycle, memory, system prompt, providers |
| **Excalidraw MCP wiring** | Ready TOML for diagram tools |
| **Setup guide for humans + LLMs** | [docs/SETUP.md](docs/SETUP.md) |

Upstream harness (tools, sessions, MCP engine, compaction, experimental memory)
is preserved under Apache-2.0 - see [NOTICE](NOTICE).

---

## Quick start (5 minutes)

```bash
# 1) Build
git clone https://github.com/hoodini/logan-cli.git && cd logan-cli
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh   # if needed
source "$HOME/.cargo/env"
cargo build -p xai-grok-pager-bin --release
cp target/release/logan ~/.local/bin/logan
export PATH="$HOME/.local/bin:$PATH"

# 2) LLM preset (example: Anthropic)
mkdir -p ~/.logan
cat examples/config/providers.toml >> ~/.logan/config.toml
# set default in config: [models] default = "claude-sonnet"
export ANTHROPIC_API_KEY="sk-ant-..."

# 3) Memory + learning
# ensure [memory] enabled = true in config
cp examples/config/USER_PREFERENCES.template.md ~/.logan/memory/MEMORY.md

# 4) Auto-reflect hooks
mkdir -p ~/.logan/hooks/bin
cp examples/hooks/auto-reflect.json ~/.logan/hooks/
cp examples/hooks/bin/auto-reflect.py ~/.logan/hooks/bin/
chmod +x ~/.logan/hooks/bin/auto-reflect.py

# 5) Optional Excalidraw MCP (needs Node/npx)
cat examples/config/mcp-excalidraw.toml >> ~/.logan/config.toml

# 6) Run
logan --version
logan -p "Say logan-ok" -m claude-sonnet
logan   # interactive TUI
```

**Human + agent install playbook:** [docs/SETUP.md](docs/SETUP.md)

---

## Docs map

| Doc | Contents |
| --- | --- |
| [docs/SETUP.md](docs/SETUP.md) | Install, LLM keys, memory, hooks, MCP, LLM-agent checklist |
| [docs/COMPARISON.md](docs/COMPARISON.md) | Grok Build OSS vs Logan |
| [docs/architecture/ARCHITECTURE.md](docs/architecture/ARCHITECTURE.md) | Prompt lifecycle, memory, system prompt, providers |
| [examples/config/providers.toml](examples/config/providers.toml) | Copy-paste model blocks |
| [examples/config/mcp-excalidraw.toml](examples/config/mcp-excalidraw.toml) | Excalidraw MCP |
| [examples/hooks/](examples/hooks/) | Auto-reflect hooks |

### Excalidraw diagrams

Open on [excalidraw.com](https://excalidraw.com) (drag-and-drop):

- [01-prompt-lifecycle.excalidraw](docs/architecture/01-prompt-lifecycle.excalidraw)
- [02-memory-sessions-context.excalidraw](docs/architecture/02-memory-sessions-context.excalidraw)
- [03-system-prompt-composition.excalidraw](docs/architecture/03-system-prompt-composition.excalidraw)
- [04-providers-self-improve.excalidraw](docs/architecture/04-providers-self-improve.excalidraw)

---

## How a prompt is processed

```text
You type a prompt
  -> logan CLI
  -> Session actor (slash / skills)
  -> ChatState (history + memory inject + tools)
  -> Sampler (chat_completions | responses | messages)
  -> Tool loop (edit, shell, MCP, skills)
  -> Stream to TUI + session logs
  -> Stop hook: auto-reflect stub -> MEMORY.md
```

### Memory

| Kind | Where |
| --- | --- |
| Short-term | Session conversation + `~/.logan/sessions/...` |
| Long-term | `~/.logan/memory/MEMORY.md` + hybrid index |
| Learning | `/flush`, skills, autoDream, **auto-reflect hooks** |

### System prompt

Layered (no fixed size): base template → tools → skills → AGENTS.md → memory
context → preferences / lessons. See architecture doc.

### Multi-provider LLMs

| Provider | Path |
| --- | --- |
| Anthropic | `api_backend = "messages"` |
| OpenAI | `chat_completions` / `responses` |
| Gemini | OpenAI-compat URL |
| OpenRouter | `openrouter.ai/api/v1` |
| Ollama / LM Studio | localhost OpenAI-compat |
| Bedrock | via **LiteLLM** proxy |

```bash
logan models
/model claude-sonnet
```

### Self-improve

```text
/skill self-improve
/skill learn-user
/flush
```

Plus automatic `Stop` / `SessionEnd` hooks writing reflection stubs.

---

## Screenshots and assets

| Asset | Path |
| --- | --- |
| Hero banner | [docs/assets/banner.jpg](docs/assets/banner.jpg) |
| TUI visual | [docs/assets/screenshot-tui.jpg](docs/assets/screenshot-tui.jpg) |
| Comparison graphic | [docs/assets/comparison.svg](docs/assets/comparison.svg) |
| Terminal SVG mock | [docs/assets/screenshot-tui.svg](docs/assets/screenshot-tui.svg) |

---

## Build notes

```sh
cargo build -p xai-grok-pager-bin --release   # -> target/release/logan
cargo check -p xai-grok-pager-bin
```

Config home: **`~/.logan`** (`LOGAN_HOME`).

---

## Status

| Surface | State |
| --- | --- |
| Binary / brand | Logan · YUV.AI |
| Multi-LLM presets | Shipped |
| Self-improve skills + auto-reflect hooks | Shipped |
| Excalidraw MCP example | Shipped |
| Architecture docs + banner | Shipped |
| Native Bedrock SigV4 | Use LiteLLM |
| Internal crates | Still `xai-grok-*` |

---

## License

Logan product work by **Yuval Avidani (YUV.AI)**.  
Upstream Grok Build remains Apache-2.0 - [LICENSE](LICENSE) · [NOTICE](NOTICE) · [AUTHORS](AUTHORS.md).

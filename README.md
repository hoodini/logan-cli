# Logan (`logan`)

**Logan** is a terminal AI coding agent by
**[Yuval Avidani](https://yuv.ai)** (YUV.AI) - AI Builder & Speaker.

Forked from [xAI Grok Build](https://github.com/xai-org/grok-build) (Apache-2.0).

```sh
logan --version
# logan 0.1.x  ·  Logan TUI by Yuval Avidani (YUV.AI) - https://yuv.ai
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
| Repo | [github.com/hoodini/logan-cli](https://github.com/hoodini/logan-cli) |

> **Attribution:** Based on Grok Build by SpaceXAI / xAI. See [NOTICE](NOTICE)
> and [LICENSE](LICENSE). Logan product work by Yuval Avidani (YUV.AI).

---

## Architecture (read this)

Deep dive: **[docs/architecture/ARCHITECTURE.md](docs/architecture/ARCHITECTURE.md)**

| Diagram (open in [excalidraw.com](https://excalidraw.com)) | Topic |
| --- | --- |
| [01-prompt-lifecycle.excalidraw](docs/architecture/01-prompt-lifecycle.excalidraw) | User prompt → session → LLM → tools → UI |
| [02-memory-sessions-context.excalidraw](docs/architecture/02-memory-sessions-context.excalidraw) | Short-term vs long-term memory, sessions, compaction |
| [03-system-prompt-composition.excalidraw](docs/architecture/03-system-prompt-composition.excalidraw) | How the system prompt is layered |
| [04-providers-self-improve.excalidraw](docs/architecture/04-providers-self-improve.excalidraw) | Multi-provider LLMs + Hermes-style learning |

---

## How a prompt is processed

```text
You type a prompt (TUI / headless / ACP)
  -> logan CLI parse
  -> Session actor (slash commands, skills rewrite)
  -> ChatState builds request
       - system prompt layers
       - tool schemas
       - short-term history
       - optional <memory-context> from long-term memory
  -> Sampler HTTP (chat_completions | responses | messages)
  -> Tool loop (edit, shell, MCP, skills) until done
  -> Stream tokens to TUI + write session logs
```

Key crates: `xai-grok-pager-bin` → `xai-grok-shell` → `xai-chat-state` →
`xai-grok-sampler` → `xai-grok-tools` / MCP.

---

## Memory: short-term, long-term, sessions

### Short-term (this session)

- In-memory conversation held by **ChatStateActor**
- On disk: `~/.logan/sessions/<cwd>/<session-id>/`
  - `updates.jsonl` - resume stream
  - `chat_history.jsonl` - model-facing history
- Tool results pruned around **~50%** of the context window
- Auto-compact around **~85%** (summarize + continue)

### Long-term (across sessions)

Opt-in memory engine (`xai-grok-memory`):

```toml
# ~/.logan/config.toml
[memory]
enabled = true

[memory.session]
save_on_end = true

[memory.dream]
enabled = true
```

```bash
logan --experimental-memory
# or
export GROK_MEMORY=1
```

| Store | Path |
| --- | --- |
| Global prefs / lessons | `~/.logan/memory/MEMORY.md` |
| Project memory | `~/.logan/memory/<project>/MEMORY.md` |
| Session logs | `.../sessions/*.md` |
| Hybrid search index | `index.sqlite` (FTS + optional vectors) |

Commands: `/remember`, `/flush`, `/memory on|off`  
Tools: `memory_search`, `memory_get`  
Background: **autoDream** consolidates session logs into evergreen MEMORY.md.

### Sessions

| Action | Command |
| --- | --- |
| Continue last | `logan -c` / `--continue` |
| Resume id | `logan --resume <id>` |
| List | `logan sessions` |

---

## System prompt: length and construction

There is **no fixed system-prompt token count**. Size grows with tools, skills,
and project rules. Layers:

1. Base template (identity, safety, tool rules) - product label **Logan**
2. API tool schemas (often the largest cost)
3. Skills catalog (budgeted descriptions)
4. Project rules (`AGENTS.md`, `Claude.md`, `.logan/rules/`)
5. Memory section + first-turn `<memory-context>` when memory is on
6. Role / persona / custom overrides
7. Self-improve lessons + user **Preferences** from MEMORY.md

After compaction a shorter compact system prompt is used.

Template source: `crates/codegen/xai-grok-agent/templates/prompt.md`  
Assembler: `crates/codegen/xai-grok-agent` (`PromptContext`, `AgentBuilder`)

---

## Skills, MCP connectors, plugins

| Extension | Purpose |
| --- | --- |
| **Skills** | Markdown playbooks the agent can load mid-task |
| **MCP** | Connectors (GitHub, DBs, design tools, …) |
| **Plugins** | Bundles of skills + MCP + hooks |
| **Hooks** | Lifecycle automation on turns/tools |

Bundled Logan skills for learning:

- **`self-improve`** - Hermes-style reflection: what worked / failed → lessons
- **`learn-user`** - extract and store your preferences (style, risk, habits)

```text
/skill self-improve
/skill learn-user
```

---

## Multi-provider LLMs

Logan speaks three backends:

| `api_backend` | Use for |
| --- | --- |
| `chat_completions` | OpenAI, OpenRouter, Ollama, LM Studio, LiteLLM, Gemini OpenAI-compat |
| `responses` | OpenAI Responses / xAI-style |
| `messages` | Anthropic Messages API |

**Copy-paste presets:** [examples/config/providers.toml](examples/config/providers.toml)

| Provider | How |
| --- | --- |
| **Anthropic** | `api_backend = "messages"` + `ANTHROPIC_API_KEY` |
| **OpenAI** | `chat_completions` or `responses` + `OPENAI_API_KEY` |
| **Gemini** | OpenAI-compat base URL + `GEMINI_API_KEY` |
| **OpenRouter** | `https://openrouter.ai/api/v1` + `OPENROUTER_API_KEY` |
| **AWS Bedrock** | Via **LiteLLM** proxy (native SigV4 not built-in yet) |
| **Ollama** | `http://localhost:11434/v1` |
| **LM Studio** | `http://localhost:1234/v1` |
| **LiteLLM** | Point `base_url` at your proxy |

```bash
# merge presets into ~/.logan/config.toml, then:
export ANTHROPIC_API_KEY=...
export OPENAI_API_KEY=...
export OPENROUTER_API_KEY=...
logan models
logan -m claude-sonnet -p "hello"
# TUI:
/model openrouter-auto
```

Full guide: user-guide custom models under
`crates/codegen/xai-grok-pager/docs/user-guide/11-custom-models.md`.

---

## Self-improve (learn what works - and learn you)

Logan does not retrain weights. It learns like strong agent harnesses (Hermes-style):

1. **Observe** session outcomes and your corrections  
2. **Reflect** with `/flush` + skill `self-improve`  
3. **Store** durable lessons in `~/.logan/memory/MEMORY.md`  
4. **Retrieve** on later turns via hybrid memory search  
5. **Personalize** with skill `learn-user` → `## Preferences`

Seed your profile:

```bash
mkdir -p ~/.logan/memory
cp examples/config/USER_PREFERENCES.template.md ~/.logan/memory/MEMORY.md
# edit Preferences for how you like to work
```

Enable memory (required for durable learning):

```toml
[memory]
enabled = true
[memory.dream]
enabled = true
```

---

## Install / build

### Prerequisites

- Rust 1.92+ (see `rust-toolchain.toml`)
- `protoc` on PATH
- Optional: `dotslash` for repo `bin/protoc`

```sh
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
cd logan-cli
cargo build -p xai-grok-pager-bin --release
cp target/release/logan ~/.local/bin/logan
logan --version
```

Config home: **`~/.logan`** (`LOGAN_HOME` override).

---

## Status of this fork

| Surface | State |
| --- | --- |
| Product name / binary | **Logan** / `logan` |
| Config home | `~/.logan` |
| Architecture docs + diagrams | Shipped |
| Multi-provider presets | Shipped (`examples/config/providers.toml`) |
| Self-improve + learn-user skills | Shipped |
| Memory / dream / sessions | Upstream capability, documented for Logan |
| Native Bedrock SigV4 | Not yet (use LiteLLM) |
| Internal crate names | Still `xai-grok-*` |
| Default auth CDN | Still xAI-shaped until rewired |

---

## License

Fork changes by **Yuval Avidani (YUV.AI)**.  
Upstream Grok Build remains Apache-2.0 - see [LICENSE](LICENSE) and [NOTICE](NOTICE).

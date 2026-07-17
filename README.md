<p align="center">
  <img src="docs/assets/banner.jpg" alt="LOGAN coding agent CLI by Yuval Avidani (YUV.AI)" width="100%"/>
</p>

# Logan

**A coding agent in your terminal** - with **token visibility**, and an **opt-in library** of modes + creative skills (HyperFrames, scrub landings, yuvai-thinking).

By [Yuval Avidani (YUV.AI)](https://yuv.ai) · inspired by Wolverine · fork of [xAI Grok Build](https://github.com/xai-org/grok-build) (Apache-2.0)

> **Default is empty and clean.** Skills and modes are **off** until you add them. You compose Logan: add packs, remove packs, toggle `/think` / `/caveman` yourself.

---

## Install (one command)

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/hoodini/logan-cli/main/scripts/install-logan.sh | bash
```

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/hoodini/logan-cli/main/scripts/install-logan.ps1 | iex
```

That single command gets Logan, puts it on your PATH, seeds skills + modes, sets up `~/.logan`, and starts the app.

<p align="center">
  <img src="docs/assets/infographic-one-command-install.jpg" alt="Logan one-command install: paste, login, code" width="100%"/>
</p>

### Login

```bash
logan login                 # browser - xAI user account (same idea as Grok Build)
logan login --from-grok     # reuse ~/.grok/auth.json if you already use Grok Build
# or: export XAI_API_KEY="your-key"
logan
```

**Which credential wins?** Per-model `api_key`/`env_key` (Claude, OpenAI, Ollama, ...) always wins for that model. Grok session / import is for **default xAI** models. See [docs/SETUP.md](docs/SETUP.md#auth-vs-which-llm-you-use).

---

## First 5 minutes

| You type | What you get |
| --- | --- |
| `hi` | Chat |
| `/stats` | Tokens: input / output / cache / $ |
| `/context deep` | Real system prompt + messages |
| `/goal Fix the bug` | Long multi-step work |
| `/skills catalog` | See optional skills (not installed yet) |
| `/skills add pack modes` | Install caveman / think / ponytail / whoami |
| `/skills add pack creative` | Install HyperFrames + scrub + reels |
| `/think full` | Deep explain - only after `yuvai-thinking` is installed |
| `/caveman full` | Terse talk - only after `caveman` is installed |
| `/site mouse clip.mp4` | Scrub landing - after creative pack |
| `/reel clip.mp4` | Captioned reel - after creative pack |
| `/whoami grill` | Optional identity interview |
| `/improve` | Optional self-heal dashboard |

Bottom bar after each reply:

```text
m grok-4.5 · 24K/200K 12% · in 2.4K out 180 c 1.2K
```

<p align="center">
  <img src="docs/assets/infographic-token-visibility.jpg" alt="Logan token visibility: live bar, /stats, /context deep" width="100%"/>
</p>

---

## Opt-in skills (empty by default)

Install puts skills in a **catalog**, not into your active set:

```text
~/.logan/catalog/skills/   # library (available)
~/.logan/skills/           # active (starts empty - you add)
```

```text
/skills catalog
/skills add pack modes       # thinking + caveman + ponytail + whoami + improve
/skills add pack creative    # HyperFrames + scrub landings + reels
/skills add yuvai-thinking   # one skill
/skills remove caveman       # your agent, your choice
```

### Thinking is not prebaked

| Step | Command |
| --- | --- |
| 1. Install skill | `/skills add yuvai-thinking` |
| 2. Turn mode on | `/think full` |
| 3. Turn off | `/think off` or `/skills remove yuvai-thinking` |

Without that, Logan is a normal coding agent - no forced teach-every-crumb style.

### Creative pack (after you opt in)

| Intent | Command |
| --- | --- |
| Mouse-scrub landing | `/site mouse video.mp4` |
| Scroll-scrub parallax | `/site parallax video.mp4` |
| Apple sticky scroll | `/site scroll video.mp4` |
| Captioned reel | `/reel video.mp4` |
| Stack map | `/creative` |

Full map: **[docs/CREATIVE.md](docs/CREATIVE.md)** · modes: **[docs/MODES.md](docs/MODES.md)** · catalog: **[skills/README.md](skills/README.md)**

Also: [hoodini/ai-agents-skills](https://github.com/hoodini/ai-agents-skills) · [HyperFrames](https://github.com/heygen-com/hyperframes)

---

## Modes (also off by default)

| Mode | Command | Needs skill |
| --- | --- | --- |
| Think | `/think off\|lite\|full\|ultra` | `yuvai-thinking` |
| Caveman | `/caveman off\|lite\|full\|ultra` | `caveman` |
| Ponytail | `/ponytail off\|lite\|full\|ultra` | `ponytail` |
| Status | `/modes` | - |

**`/think` and `/caveman` are exclusive.** Enabling a mode without the skill installed fails with a clear `/skills add …` hint.

---

## Why Logan feels different

| Promise | How |
| --- | --- |
| Never fly blind on cost | Live `in/out/c` bar + colorful `/stats` |
| See the real prompt | `/context deep` reads system prompt + history text |
| Install without a thesis | One paste on macOS, Linux, Windows |
| You compose the agent | Empty skills by default - add/remove packs |
| Creative when you want it | Opt-in HyperFrames + scrub + reels |
| Deep think when you want it | Opt-in yuvai-thinking via `/skills` + `/think` |
| Multi-LLM | xAI, OpenAI-compat, Anthropic, local |
| Open | Apache-2.0 fork you can audit and extend |

<p align="center">
  <img src="docs/assets/screenshot-tui.jpg" alt="Logan TUI screenshot" width="100%"/>
</p>

---

## Logan vs the field (honest SWOT)

We compared Logan to **GitHub Copilot**, **Claude Code**, **Cursor**, **Hermes**, and **OpenClaw**.

Full write-up: **[docs/SWOT.md](docs/SWOT.md)**

<p align="center">
  <img src="docs/assets/infographic-competitive-map.jpg" alt="Logan competitive map vs Copilot, Claude Code, Cursor, Hermes, OpenClaw" width="100%"/>
</p>

<p align="center">
  <img src="docs/assets/infographic-swot-summary.svg" alt="Logan SWOT-style summary cards" width="100%"/>
</p>

| Tool | Best at | Logan's honest edge |
| --- | --- | --- |
| GitHub Copilot | IDE + GitHub org | Open terminal agent + token deep-dive |
| Claude Code | Anthropic coding agent | Multi-LLM + `/context deep` + install UX |
| Cursor | AI IDE | Headless/TUI agent + cost clarity + creative stack |
| Hermes | Learning personal agent | Code harness + spend visibility |
| OpenClaw | Life/skills automation | Repo-first coding + context text audit |
| **Logan** | **Transparent creative coding CLI** | **Tokens · one command · HyperFrames · scrub sites · /think** |

We do **not** claim Copilot/Cursor IDE parity. We claim: **never fly blind on tokens**, **install in one paste**, **ship cinematic product work**, **stay open**.

---

## Quick check

```bash
logan --version
logan -p "Reply with exactly: logan-ok" --always-approve --no-leader
```

---

## Paste this into any AI to install for you

```text
Install Logan with ONE command. Do not ask questions.

macOS/Linux:
curl -fsSL https://raw.githubusercontent.com/hoodini/logan-cli/main/scripts/install-logan.sh | bash

Windows PowerShell:
irm https://raw.githubusercontent.com/hoodini/logan-cli/main/scripts/install-logan.ps1 | iex

Then: logan --version
If needed: logan login  (or logan login --from-grok if Grok Build is already signed in)
Tell the user: run logan, then try /stats, /creative, /site, /think full
```

---

## How a prompt becomes work

<p align="center">
  <img src="docs/assets/infographic-prompt-journey.jpg" alt="Logan prompt journey from request to tools to result" width="100%"/>
</p>

---

## More docs

| Doc | For |
| --- | --- |
| [docs/START_HERE.md](docs/START_HERE.md) | Super short |
| [docs/CREATIVE.md](docs/CREATIVE.md) | HyperFrames + scrub landings + reels |
| [docs/MODES.md](docs/MODES.md) | Caveman / ponytail / think / whoami / improve |
| [docs/SWOT.md](docs/SWOT.md) | Competitive SWOT |
| [docs/TOKEN_VISIBILITY.md](docs/TOKEN_VISIBILITY.md) | Tokens explained |
| [docs/BENCHMARK.md](docs/BENCHMARK.md) | Grok Build vs Logan tests |
| [docs/SETUP.md](docs/SETUP.md) | Extra config |
| [docs/FEATURES.md](docs/FEATURES.md) | Full list |
| [docs/assets/README.md](docs/assets/README.md) | Image sources |
| [skills/README.md](skills/README.md) | Native skills |
| [examples/showcase/](examples/showcase/) | Golden creative paths |

---

**Yuval Avidani** · [yuv.ai](https://yuv.ai) · [@yuvalav](https://x.com/yuvalav) · [@hoodini](https://github.com/hoodini)

```text
claws out.
```

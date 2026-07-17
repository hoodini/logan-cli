<p align="center">
  <img src="docs/assets/banner.jpg" alt="LOGAN coding agent CLI by Yuval Avidani (YUV.AI)" width="100%"/>
</p>

# Logan

**A coding agent in your terminal.**  
Shows every token you spend. Skills and modes are **opt-in** - you compose the agent.

By [Yuval Avidani (YUV.AI)](https://yuv.ai) · inspired by Wolverine · fork of [xAI Grok Build](https://github.com/xai-org/grok-build) (Apache-2.0)

> **Default is empty and clean.**  
> Active skills start empty. Modes start off. No forced HyperFrames, no forced yuvai-thinking, no forced caveman.  
> You add what you want - and remove it anytime.

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

That puts `logan` on your PATH, creates `~/.logan`, refreshes the **skill catalog** (library only), and starts the app.  
**It does not auto-enable skills or modes.**

<p align="center">
  <img src="docs/assets/infographic-one-command-install.jpg" alt="Logan one-command install" width="100%"/>
</p>

### Login

```bash
logan login                 # browser - xAI user account
logan login --from-grok     # reuse ~/.grok/auth.json if Grok Build is already signed in
# or: export XAI_API_KEY="your-key"
logan
```

**Which credential wins?** Per-model `api_key` / `env_key` always wins for that model.  
Session / Grok import is for default xAI models. See [docs/SETUP.md](docs/SETUP.md#auth-vs-which-llm-you-use).

---

## First 5 minutes

| You type | What you get |
| --- | --- |
| `hi` | Chat (plain coding agent) |
| `/stats` | Tokens: input / output / cache / $ |
| `/context deep` | Real system prompt + messages |
| `/goal Fix the bug` | Long multi-step work |
| `/skills catalog` | Optional library (not installed yet) |
| `/skills list` | What **you** installed (starts empty) |
| `/skills add pack modes` | Opt-in: caveman, think, ponytail, whoami, self-improve |
| `/skills add pack creative` | Opt-in: HyperFrames, scrub landings, reels |
| `/skills remove <name>` | Drop a skill you no longer want |
| `/update` | Pull latest from GitHub main (background) - then restart |
| `/update check` | Check release channel without installing |
| `/update status` | Tail last update log |

Bottom bar after each reply:

```text
m grok-4.5 · 24K/200K 12% · in 2.4K out 180 c 1.2K
```

<p align="center">
  <img src="docs/assets/infographic-token-visibility.jpg" alt="Logan token visibility" width="100%"/>
</p>

---

## You compose the agent (empty by default)

| Path | Role |
| --- | --- |
| `~/.logan/skills/` | **Active** skills - starts **empty** |
| `~/.logan/catalog/skills/` | **Library** from install - available, not forced |
| `~/.logan/modes.toml` | Modes - all **off** until you enable them |

```text
/skills catalog
/skills add pack modes
/skills add pack creative
/skills add yuvai-thinking
/skills remove video-edit
```

Bare `/skills` opens the skills modal. With args, it manages the catalog.

### Thinking is not prebaked

| Step | Command |
| --- | --- |
| 1. Install skill | `/skills add yuvai-thinking` |
| 2. Turn mode on | `/think full` |
| 3. Turn off | `/think off` |
| 4. Uninstall | `/skills remove yuvai-thinking` |

Without that, Logan does **not** run the "every crumb" teach style.

### Creative pack (only after you opt in)

```text
/skills add pack creative
```

| Intent | Command | Skill |
| --- | --- | --- |
| Mouse-scrub landing | `/site mouse video.mp4` | `cinematic-scrub-landing` |
| Scroll-scrub parallax | `/site parallax video.mp4` | `parallax-landing-page` |
| Apple sticky scroll | `/site scroll video.mp4` | `video-to-landing-page` |
| Captioned reel | `/reel video.mp4` | `video-edit` |
| Stack map | `/creative` | shows installed vs catalog |

If a skill is missing, Logan tells you how to add it - it does not invent the stack silently.

Full map: **[docs/CREATIVE.md](docs/CREATIVE.md)** · modes: **[docs/MODES.md](docs/MODES.md)** · catalog: **[skills/README.md](skills/README.md)**

Also: [hoodini/ai-agents-skills](https://github.com/hoodini/ai-agents-skills) · [HyperFrames](https://github.com/heygen-com/hyperframes)

### Modes (off until you enable)

| Mode | Command | Needs skill first |
| --- | --- | --- |
| Think | `/think off\|lite\|full\|ultra` | `yuvai-thinking` |
| Caveman | `/caveman off\|lite\|full\|ultra` | `caveman` |
| Ponytail | `/ponytail off\|lite\|full\|ultra` | `ponytail` |
| Status | `/modes` | - |

**`/think` and `/caveman` are exclusive** (deep explain vs terse talk).  
Enabling a mode without the skill installed fails with a clear `/skills add …` hint.

### Optional power-user install flags

```bash
LOGAN_SEED_SKILLS=1 …              # install entire catalog into active skills (not default)
LOGAN_SYNC_SIBLING_SKILLS=1 …      # also copy from ~/.claude / ~/.grok skills
```

---

## Why Logan feels different

| Promise | How |
| --- | --- |
| Never fly blind on cost | Live `in/out/c` bar + colorful `/stats` |
| See the real prompt | `/context deep` |
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
  <img src="docs/assets/infographic-competitive-map.jpg" alt="Logan competitive map" width="100%"/>
</p>

<p align="center">
  <img src="docs/assets/infographic-swot-summary.svg" alt="Logan SWOT-style summary cards" width="100%"/>
</p>

| Tool | Best at | Logan's honest edge |
| --- | --- | --- |
| GitHub Copilot | IDE + GitHub org | Open terminal agent + token deep-dive |
| Claude Code | Anthropic coding agent | Multi-LLM + `/context deep` + install UX |
| Cursor | AI IDE | Headless/TUI + cost clarity + opt-in creative pack |
| Hermes | Learning personal agent | Code harness + spend visibility |
| OpenClaw | Life/skills automation | Repo-first coding + context text audit |
| **Logan** | **Transparent coding CLI you compose** | **Tokens · empty-by-default skills · opt-in packs** |

We do **not** claim Copilot/Cursor IDE parity.  
We claim: **never fly blind on tokens**, **install in one paste**, **you own the skill set**, **stay open**.

---

## Update Logan

**Inside the TUI (every time):**

```text
/update              # GitHub main via install script (background)
/update status       # watch log
/update check        # release channel only
/update release      # published releases (logan update)
```

When the log shows `finished exit=0`, quit and start again:

```bash
logan --version
logan
```

**Outside the TUI:**

```bash
logan update                 # release channel
# or rebuild from source install:
curl -fsSL https://raw.githubusercontent.com/hoodini/logan-cli/main/scripts/install-logan.sh | LOGAN_INSTALL_NO_START=1 bash
```

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

Important defaults:
- Active skills start EMPTY. Catalog is available but not enabled.
- Do NOT claim thinking/creative modes are pre-enabled.
- User opts in: /skills catalog · /skills add pack modes · /skills add pack creative
- Then optional: /think full · /caveman full · /site · /reel
Tell the user to start with /stats and /skills catalog.
```

---

## How a prompt becomes work

<p align="center">
  <img src="docs/assets/infographic-prompt-journey.jpg" alt="Logan prompt journey" width="100%"/>
</p>

---

## More docs

| Doc | For |
| --- | --- |
| [docs/START_HERE.md](docs/START_HERE.md) | Super short |
| [docs/MODES.md](docs/MODES.md) | Modes + empty-by-default skills |
| [docs/CREATIVE.md](docs/CREATIVE.md) | Opt-in HyperFrames / scrub / reels |
| [skills/README.md](skills/README.md) | Catalog of optional skills |
| [docs/SWOT.md](docs/SWOT.md) | Competitive SWOT |
| [docs/TOKEN_VISIBILITY.md](docs/TOKEN_VISIBILITY.md) | Tokens explained |
| [docs/SETUP.md](docs/SETUP.md) | Extra config |
| [docs/FEATURES.md](docs/FEATURES.md) | Full list |
| [examples/showcase/](examples/showcase/) | Golden creative paths (after opt-in) |

---

**Yuval Avidani** · [yuv.ai](https://yuv.ai) · [@yuvalav](https://x.com/yuvalav) · [@hoodini](https://github.com/hoodini)

```text
claws out.
```

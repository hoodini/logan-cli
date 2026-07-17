<p align="center">
  <img src="docs/assets/banner.jpg" alt="LOGAN - by Yuval Avidani (YUV.AI)" width="100%"/>
</p>

# Logan

**A coding agent in your terminal.**  
Talk to it, it edits code, runs commands, and **shows you every token you spend**.

By [Yuval Avidani (YUV.AI)](https://yuv.ai) · inspired by Wolverine · fork of [xAI Grok Build](https://github.com/xai-org/grok-build)

---

## Install in 3 steps

### 1. Get the code

```bash
git clone https://github.com/hoodini/logan-cli.git
cd logan-cli
```

### 2. Install (one command)

You need **Rust** once. If you do not have it:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
```

Then:

```bash
bash scripts/install-logan.sh
export PATH="$HOME/.local/bin:$PATH"
```

### 3. Log in and open

```bash
logan login      # browser login (same as Grok / xAI)
logan            # open the app
```

Or use an API key:

```bash
export XAI_API_KEY="your-key"
logan
```

**Done.** Type a question. Press Enter.

---

## First 5 minutes (what to type)

| You type | What happens |
| --- | --- |
| `hi` | Normal chat |
| `/stats` | **How many tokens** you used (input / output / cache / $) |
| `/context` | **How full** your context window is |
| `/context deep` | **The actual text** in that window (system prompt + messages) |
| `/goal Fix the login bug` | Long task mode (plan + work) |
| `Ctrl+C` then `q` | Leave |

Look at the **bottom status bar** after each reply:

```text
m grok-4.5 · 24K/200K 12% · in 2.4K out 180 c 1.2K
             │              └─ last reply: input / output / cache
             └─ how full the memory window is
```

You always see **what you spent** and **what is filling the window**.

---

## Paste this into any AI to install for you

Copy the block below into Claude, Cursor, Grok, Codex, etc.

```text
Install Logan CLI for me.

1. git clone https://github.com/hoodini/logan-cli.git && cd logan-cli
2. Install Rust if needed: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
3. Run: bash scripts/install-logan.sh
4. Put ~/.local/bin on PATH
5. Run: logan --version
6. Run: logan -p "Reply with exactly: logan-ok" --always-approve
7. Tell me how to open it: logan login && logan

Do not ask questions. Just do it.
```

Longer agent playbook (optional): [docs/LLM_INSTALL_PROMPT.md](docs/LLM_INSTALL_PROMPT.md)

---

## Why Logan (vs plain Grok Build)

| | Grok Build | Logan |
| --- | --- | --- |
| App name | `grok` | **`logan`** |
| See token spend live | Basic | **Yes - bar + `/stats` colors** |
| See real prompt text | Hard | **`/context deep`** |
| Install | Manual | **One script** |
| Skills from Claude/Cursor | Limited | **Auto-load** |
| Made for | xAI product | **Builders who want clarity** |

Measured check on this machine: [docs/BENCHMARK.md](docs/BENCHMARK.md)

---

## Quick checks (does it work?)

```bash
logan --version
# expect: logan 0.1.x ...

logan -p "Reply with exactly: logan-ok" --always-approve
# expect: logan-ok
```

Then open the app:

```bash
logan
```

After one message:

1. Type `/stats` - you should see **IN / OUT / CACHE** in color  
2. Type `/context deep` - you should see **real system prompt text**

---

## More help (only if you need it)

| Doc | For |
| --- | --- |
| [docs/START_HERE.md](docs/START_HERE.md) | Super short checklist |
| [docs/TOKEN_VISIBILITY.md](docs/TOKEN_VISIBILITY.md) | Tokens explained simply |
| [docs/BENCHMARK.md](docs/BENCHMARK.md) | Grok Build vs Logan tests |
| [docs/SETUP.md](docs/SETUP.md) | Extra setup (API keys, providers) |
| [docs/FEATURES.md](docs/FEATURES.md) | Full feature list |
| [docs/WEB_SEARCH.md](docs/WEB_SEARCH.md) | Web search setup |
| [docs/COMPARISON.md](docs/COMPARISON.md) | Detailed comparison |

---

## Who made this

**Yuval Avidani** · [yuv.ai](https://yuv.ai) · [@yuvalav](https://x.com/yuvalav) · [@hoodini](https://github.com/hoodini)

Based on [xAI Grok Build](https://github.com/xai-org/grok-build) (Apache-2.0).

```text
claws out.
```

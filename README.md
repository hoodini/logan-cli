<p align="center">
  <img src="docs/assets/banner.jpg" alt="LOGAN - by Yuval Avidani (YUV.AI)" width="100%"/>
</p>

# Logan

**A coding agent in your terminal.**  
It edits code, runs commands, and **shows every token you spend**.

By [Yuval Avidani (YUV.AI)](https://yuv.ai) · inspired by Wolverine · fork of [xAI Grok Build](https://github.com/xai-org/grok-build)

---

## Install (one command)

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/hoodini/logan-cli/main/scripts/install-logan.sh | bash
```

That single command will:

1. Get Logan (download a release **or** clone + build automatically)  
2. Install `logan` on your PATH  
3. Set up `~/.logan` config  
4. **Start Logan** when you run it in a normal terminal  

### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/hoodini/logan-cli/main/scripts/install-logan.ps1 | iex
```

### Already have the repo?

```bash
cd logan-cli
bash scripts/install-logan.sh
```

---

## First login

```bash
logan login          # browser once
# or:
export XAI_API_KEY="your-key"
```

Then:

```bash
logan
```

---

## First 5 minutes

| You type | What you get |
| --- | --- |
| `hi` | Chat |
| `/stats` | Tokens: input / output / cache / $ |
| `/context` | How full the window is |
| `/context deep` | Real system prompt + messages |
| `/goal Fix the bug` | Long multi-step work |

Bottom bar after each reply:

```text
m grok-4.5 · 24K/200K 12% · in 2.4K out 180 c 1.2K
```

---

## Paste this into any AI to install for you

```text
Install Logan with ONE command. Do not ask questions.

macOS/Linux:
curl -fsSL https://raw.githubusercontent.com/hoodini/logan-cli/main/scripts/install-logan.sh | bash

Windows PowerShell:
irm https://raw.githubusercontent.com/hoodini/logan-cli/main/scripts/install-logan.ps1 | iex

Then run: logan --version
If needed: logan login
Tell the user to run: logan
After a chat turn they can use /stats and /context deep.
```

---

## Quick check

```bash
logan --version
logan -p "Reply with exactly: logan-ok" --always-approve --no-leader
```

---

## Why Logan vs Grok Build

| | Grok Build | Logan |
| --- | --- | --- |
| Install | Manual | **One command** |
| Token spend | Basic | **Live bar + `/stats` + `/context deep`** |
| Name | `grok` | **`logan`** |

Details: [docs/BENCHMARK.md](docs/BENCHMARK.md)

---

## More docs

| Doc | For |
| --- | --- |
| [docs/START_HERE.md](docs/START_HERE.md) | Super short |
| [docs/TOKEN_VISIBILITY.md](docs/TOKEN_VISIBILITY.md) | Tokens explained |
| [docs/BENCHMARK.md](docs/BENCHMARK.md) | Grok vs Logan tests |
| [docs/SETUP.md](docs/SETUP.md) | Extra config |
| [docs/FEATURES.md](docs/FEATURES.md) | Full list |

---

**Yuval Avidani** · [yuv.ai](https://yuv.ai) · [@yuvalav](https://x.com/yuvalav) · [@hoodini](https://github.com/hoodini)

```text
claws out.
```

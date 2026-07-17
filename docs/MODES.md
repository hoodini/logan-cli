# Logan modes: caveman, ponytail, whoami, improve

**Author:** Yuval Avidani (YUV.AI)

## Why these modes exist

Two viral agent skills showed up hard in 2026:

| Skill | Hype | Real idea |
| --- | --- | --- |
| **[Caveman](https://github.com/JuliusBrussee/caveman)** | "65% fewer tokens" | Talk less. Keep code/errors exact. Biggest win on **prose**, not tool-heavy coding turns. Independent tests saw smaller savings on full agent loops - still useful for less chatter. |
| **[Ponytail](https://github.com/DietrichGebert/ponytail)** | "lazy senior / YAGNI" | Write less **code**. Stdlib/native first. Shortest working diff. Saves tokens by not over-building. |

Logan ships both as **native toggleable modes** - not a forced personality.

## Quick commands

| Command | Purpose |
| --- | --- |
| `/caveman off\|lite\|full\|ultra` | Terse talk mode |
| `/ponytail off\|lite\|full\|ultra` | Minimal code / YAGNI |
| `/modes` | Show both |
| `/whoami` | Show identity profile |
| `/whoami grill` | Interview for socials + stack + taste |
| `/whoami update <fact>` | Append a fact |
| `/improve` | Self-heal dashboard |
| `/improve why` | Explain last decision path |
| `/heal` · `/reflections` | Aliases for improve |

## How enable/disable works

1. Slash command writes `~/.logan/modes.toml`
2. Mirrors sticky instructions to `~/.logan/rules/logan-modes.md`
3. Global rules load every session - so the mode **sticks** until you turn it off

You choose. Default seed is **both off**.

## Whoami + memory

| File | Role |
| --- | --- |
| `~/.logan/memory/PROFILE.md` | Identity, links, stack |
| `~/.logan/memory/MEMORY.md` | Preferences + lessons |
| `~/.logan/memory/IMPROVEMENTS.md` | Structured improve journal |
| `~/.logan/memory/reflections.log` | Hook firehose |

First time: `/whoami grill`. Ongoing: `/whoami update …` or `/remember …`.

## Self-improve visibility

Logan should not learn in the dark:

- Hooks append reflection stubs (Stop / SessionEnd)
- `/improve` shows logs + journal
- `/improve why` forces a clear decision postmortem
- Agent should append IMPROVEMENTS.md after non-trivial fixes

## HyperFrames default

For video / motion / captions work, Logan prefers **HyperFrames**  
(https://github.com/heygen-com/hyperframes). Skill: `hyperframes-master` plus workflow skills already under `~/.logan/skills/`.

## Install

Native skills ship in the repo under `skills/` and are seeded by `install-logan.sh`.

```bash
# after install / rebuild
logan
/caveman full
/ponytail lite
/whoami grill
/improve
```

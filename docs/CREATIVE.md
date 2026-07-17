# Logan creative stack (HyperFrames + YUV.AI)

**Author:** Yuval Avidani (YUV.AI)

Logan is not only a coding agent - it ships a **native creative OS** for cinematic video and 3D-feeling web landings.

## Why this exists

Most agents write generic React. Logan is tuned for:

- **HyperFrames** - HTML compositions → MP4 ([heygen-com/hyperframes](https://github.com/heygen-com/hyperframes))
- **Scroll / mouse video scrub landings** - Apple / Copilot-style product sites
- **Captioned reels** - Hebrew + English, transcript review before render
- **yuvai-thinking** - every crumb explained when you want to *learn*, not just ship

Skills also live in [hoodini/ai-agents-skills](https://github.com/hoodini/ai-agents-skills). Install seeds them into `~/.logan/skills/`.

## Slash shortcuts

| Command | What it does |
| --- | --- |
| `/creative` | Map of the whole stack |
| `/site mouse video.mp4` | **cinematic-scrub-landing** - cursor scrubs hero video |
| `/site parallax video.mp4` | **parallax-landing-page** - scroll scrubs frames (one viewport) |
| `/site scroll video.mp4` | **video-to-landing-page** - sticky Apple-style scroll hero |
| `/reel video.mp4` | **video-edit** - captioned HyperFrames 16:9 + 9:16 |
| `/think full` | **yuvai-thinking** - deep teach mode (exclusive with `/caveman`) |

## Skills (seeded)

| Skill | Role |
| --- | --- |
| `hyperframes-master` | Default video engine + workflow router |
| `cinematic-scrub-landing` | Mouse-scrub golden template landings |
| `parallax-landing-page` | Scroll-scrub single-hero landings |
| `video-to-landing-page` | Sticky scroll-frame landings |
| `video-edit` | Captioned showcase pipeline |
| `yuv-pilot` | Brand multi-output orchestrator |
| `yuvai-thinking` | Learning / teaching cascade |

Plus the HyperFrames companions usually synced from agent homes (`hyperframes`, `hyperframes-core`, …).

## Project save paths

| Output | Default folder |
| --- | --- |
| Landings | `~/Documents/yuv-projects/landings/<slug>/` |
| Videos | `~/Documents/yuv-projects/videos/<slug>/` |

## Modes that pair well

| Goal | Modes |
| --- | --- |
| Ship a landing fast | `/ponytail lite` · caveman off |
| Understand every step | `/think full` (turns caveman off) |
| Save talk tokens | `/caveman full` (turns think off) |

## One-liner mental model

```text
video ──► /reel     → captioned HyperFrames MP4
video ──► /site     → stunning scrub / parallax landing
topic ──► /think    → full understanding (yuvai-thinking)
brand ──► yuv-pilot → deck + site + reel composition
```

See also: [MODES.md](MODES.md) · [FEATURES.md](FEATURES.md)

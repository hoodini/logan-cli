---
name: self-improve
description: >
  Visibility into Logan self-healing and self-improving. Show what was analyzed,
  what improved, how, and why. Journal durable lessons. Trigger: /improve,
  /heal, /reflections, "what did you learn", "why did you decide that".
---

# Self-improve / self-heal visibility

Logan should not only learn quietly - **you must be able to see and steer it**.

## User commands

| Command | What you get |
| --- | --- |
| `/improve` | Full improve dashboard: modes, recent reflections, lessons, open questions |
| `/improve why` | Explain last non-trivial decision path (tools + rationale) |
| `/improve log` | Tail of `reflections.log` + `IMPROVEMENTS.md` |
| `/heal` | Alias focused on failures: what broke, fix applied, prevention |
| `/reflections` | Alias for improve log |
| `/flush` | Rich session summary → memory (existing) |
| `/memory on` | Enable memory this session |

## Files (operators)

| Path | Role |
| --- | --- |
| `~/.logan/memory/reflections.log` | One-line firehose of hook events |
| `~/.logan/memory/IMPROVEMENTS.md` | Structured improve journal |
| `~/.logan/memory/MEMORY.md` | Preferences + Lessons + Auto reflections |
| `~/.logan/memory/PROFILE.md` | Whoami identity |

## When you improve something mid-session

After a non-trivial fix or process win, **append** to IMPROVEMENTS.md:

```markdown
### YYYY-MM-DD · short title
- **Trigger:** what user said / what failed
- **Analyzed:** files, symptoms, hypotheses
- **Decision:** what we chose and **why**
- **Changed:** files / commands
- **Improved how:** measurable or qualitative
- **Lesson for next time:** durable rule
- **User steered:** (if they corrected you)
```

## Self-heal loop

1. Detect failure (test red, tool error, user "that's wrong")
2. Root-cause (not symptom patch) - pair with ponytail ladder
3. Fix + verify
4. Journal the lesson
5. If user preference involved → update PROFILE / Preferences

## Answering "why did you decide that?"

Be explicit:

1. Goal / constraint observed
2. Options considered (even if one line each)
3. Evidence (file, error, prior memory)
4. Choice + risk
5. What would change the decision

If caveman is on, still answer **why** clearly when asked - auto-clarity applies.

## Never

- Fake improvements that did not happen
- Hide failures
- Write secrets/API keys into MEMORY/IMPROVEMENTS

# Logan features: what you already have vs what we are adding

**Author:** Yuval Avidani (YUV.AI) · https://yuv.ai

This is the honest map for builders who want a **real** coding-agent CLI:
token visibility, auto-routing, goals, observability, and remote-agent use.

---

## Already in the harness (use today)

| Need | Logan / Grok Build today | How |
| --- | --- | --- |
| **Autonomous goals** | **Yes - `/goal`** | `/goal Migrate auth` · `/goal status` · pause/resume/clear. Enable if hidden: `GROK_GOAL=1` or remote/local goal flags. Planner + strategist + `update_goal` tool exist. |
| **Context token breakdown** | **Yes - `/context`** | System prompt / messages / reasoning / free + tool defs, skills, MCP cost estimates |
| **Session stats** | **Yes - `/session-info`** | Model, turns, context usage |
| **Billing/credits UI** | **Yes - `/usage`** | Product credit/billing path (provider-specific) |
| **Usage on API responses** | **Yes (wire)** | Sampler records `prompt_tokens`, `completion_tokens`, `reasoning_tokens`, `cached_prompt_tokens` / Anthropic `cache_read_input_tokens` |
| **Telemetry metrics** | **Yes** | `input` / `output` / `reasoning` / `cache_read` token counters + OTEL export path |
| **Headless “agent calls CLI”** | **Yes - not impossible** | `logan -p "…" --output-format json` · streaming-json · `agent stdio` (ACP) |
| **Multi-provider LLMs** | **Yes** | `[model.*]` + `examples/config/providers.toml` |
| **LiteLLM** | **Yes as OpenAI-compat** | Point `base_url` at LiteLLM proxy |
| **Langfuse-class tracing** | **Partial** | OTEL exporter exists; wire OTLP endpoint to Langfuse/OTEL backends |
| **Memory / self-improve** | **Yes (Logan)** | Memory + dream + skills + auto-reflect hooks |
| **Smart auto model routing** | **`--route auto` shipped** | Heuristic classifier → `tier-*` before sample; skill still available |
| **`/stats`** | **Shipped** | Session ledger: input/output/cache/reasoning/cost by model |

---

## Remote agent: is it possible?

**Yes.** Logan is already designed as a non-interactive agent host:

```bash
# Fire-and-forget coding task, JSON out (includes usage when provider returns it)
logan -p "Summarize this repo in 5 bullets" \
  --output-format json \
  --always-approve \
  -m claude-sonnet

# Structured output for another agent
logan -p "Extract todos as JSON" \
  --json-schema '{"type":"object","properties":{"todos":{"type":"array","items":{"type":"string"}}}}' \
  --always-approve

# Long-lived protocol for IDEs / agents
logan agent stdio
```

Wrap with HTTP when you want multi-tenant remote:

- Script: `examples/scripts/logan-agent-server.py`
- Guide: [REMOTE_AGENT.md](REMOTE_AGENT.md)

Safety: sandbox, `--allow`/`--deny`, `--tools`, network isolation, auth on the HTTP wrapper. Do **not** expose bare YOLO Logan to the public internet without auth.

---

## Token visibility & stats (roadmap productized)

### What you can see now

| Surface | Shows |
| --- | --- |
| `/context` | Context composition estimate |
| `/session-info` | Session-level usage |
| Headless JSON | `usage` object when provider sends it |
| OTEL metrics | `input` / `output` / `reasoning` / `cache_read` |

### What Logan should feel like for devs (target)

```text
/stats                  # session + day rollup
/stats --by-model       # per provider/model
/stats --export jsonl   # ~/.logan/stats/usage.jsonl

Breakdown per turn:
  input_tokens
  output_tokens
  cache_read_tokens
  cache_write_tokens   # when provider supports it
  reasoning_tokens
  estimated_cost_usd   # optional price table
```

Local ledger design lives in `examples/config/observability.toml` and
`examples/scripts/usage-rollup.py` (aggregates headless JSON / jsonl).

---

## Smart auto-routing (token saver)

**Goal:** cheap model for triage / search / small edits; premium only when needed.

```text
classify task size/risk
   |
   +-- trivial (docs typo, short Q)     -> model.fast   (e.g. gemini-flash, haiku, ollama)
   +-- standard implement              -> model.default
   +-- hard (arch, multi-file, debug)  -> model.premium
   +-- verification / review           -> model.review (optional second pass)
```

Today: configure named tiers in config and switch with `-m` / `/model`, or let
the **auto-route skill** recommend a switch mid-session.

Tomorrow (harness): pre-turn classifier that sets model before sampler call,
with override flags:

```bash
logan -p "…" --route auto
logan -p "…" --route premium
```

Config sketch: [examples/config/auto-routing.toml](../examples/config/auto-routing.toml)

---

## LiteLLM + Langfuse (best-in-class logging)

### LiteLLM (gateway)

One proxy for Bedrock, Azure, Vertex, rate limits, budgets:

```toml
[model.litellm]
model = "claude-sonnet-4"
base_url = "http://localhost:4000/v1"
env_key = "LITELLM_API_KEY"
```

LiteLLM already logs requests; point Langfuse at LiteLLM **or** at Logan OTEL.

### Langfuse (traces)

Logan can emit OpenTelemetry. Point OTLP HTTP at Langfuse’s OTEL endpoint
(or collector → Langfuse):

```toml
# See examples/config/observability.toml
[telemetry]
# enable external OTEL when your build exposes it
```

Env pattern (typical Langfuse OTEL):

```bash
export OTEL_EXPORTER_OTLP_ENDPOINT="https://cloud.langfuse.com/api/public/otel"
export OTEL_EXPORTER_OTLP_HEADERS="Authorization=Basic <langfuse_b64>"
```

Exact keys depend on Langfuse project settings - keep secrets out of git.

---

## `/goal` (Claude Code-class)

You **already have** it:

```text
/goal Ship token stats dashboard
/goal status
/goal pause
/goal resume
/goal clear
```

If the slash command is missing, enable goal mode (`GROK_GOAL=1` or config
feature flag) so the `update_goal` tool is in the toolset.

---

## Per-skill / per-subagent models

| Mechanism | Status |
| --- | --- |
| Skill frontmatter `model:` / `effort:` | **Supported** |
| Agent/subagent frontmatter `model: inherit\|id` | **Supported** |
| Web search / summary / image models in config | **Supported** |
| Goal planner/strategist models | **Supported** (flags) |
| Example agents + assignment TOML | **Shipped** - see [MODEL_ROUTING.md](MODEL_ROUTING.md) |

## Automations / schedules

| Mechanism | Status |
| --- | --- |
| `/loop`, `scheduler_create/list/delete`, `monitor` | **Supported** in-session |
| OS cron / launchd / Task Scheduler + headless | **Documented** - [AUTOMATIONS.md](AUTOMATIONS.md) |
| Wake sleeping computer | **OS power**, not Logan-core |

## Prompt journey with real token picture

Concrete walkthrough: [PROMPT_JOURNEY_WALKTHROUGH.md](PROMPT_JOURNEY_WALKTHROUGH.md)

## Priority build order (product)

1. **Local usage jsonl + `/stats` UX** - devs feel control immediately  
2. **Auto-route tiers + native `--route auto`** - real token savings  
3. **Langfuse OTEL recipe** - team observability  
4. **HTTP remote agent** hardened (auth, sandbox, quotas)  
5. **Cost tables** per model in config  
6. **UI for models-per-role** map  

---

## Related

- [REMOTE_AGENT.md](REMOTE_AGENT.md)
- [SETUP.md](SETUP.md)
- [architecture/ARCHITECTURE.md](architecture/ARCHITECTURE.md)
- [examples/config/auto-routing.toml](../examples/config/auto-routing.toml)
- [examples/config/observability.toml](../examples/config/observability.toml)

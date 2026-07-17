# Start here

## Install (one command)

**macOS / Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/hoodini/logan-cli/main/scripts/install-logan.sh | bash
```

**Windows (PowerShell)**

```powershell
irm https://raw.githubusercontent.com/hoodini/logan-cli/main/scripts/install-logan.ps1 | iex
```

## Login + open

```bash
# Browser account login (xAI user - same idea as Grok Build)
logan login

# Already signed into Grok Build on this machine? Reuse that session:
logan login --from-grok

# Or API key (CI / automation)
# export XAI_API_KEY="xai-..."

logan
```

If you only use custom models (Claude/OpenAI/Ollama) with `api_key`/`env_key` in
config, you do **not** need a Grok session - those keys win for that model.

## After you chat once

| Type | See |
| --- | --- |
| `/stats` | Token bill |
| `/context deep` | Real prompt text |

## AI paste

See [LLM_INSTALL_PROMPT.md](LLM_INSTALL_PROMPT.md)

# Start here (simple)

## Install

```bash
git clone https://github.com/hoodini/logan-cli.git
cd logan-cli
bash scripts/install-logan.sh
export PATH="$HOME/.local/bin:$PATH"
```

## Log in

```bash
logan login
```

(or `export XAI_API_KEY=...`)

## Open

```bash
logan
```

## After you chat once

| Type this | You see |
| --- | --- |
| `/stats` | Tokens: input, output, cache, cost |
| `/context` | How full the window is |
| `/context deep` | The real text inside the window |
| `/goal Fix X` | Long multi-step task |

Status bar (bottom) always shows last spend: `in … out … c …`

## Test without the UI

```bash
logan -p "Reply with exactly: logan-ok" --always-approve
```

## More

- Tokens: [TOKEN_VISIBILITY.md](TOKEN_VISIBILITY.md)  
- Grok vs Logan tests: [BENCHMARK.md](BENCHMARK.md)  
- Ask an AI to install: [LLM_INSTALL_PROMPT.md](LLM_INSTALL_PROMPT.md)  

# Paste this into any AI helper

Copy **everything** in the box. Paste into Claude / Cursor / Grok / Codex / ChatGPT.

```text
Install Logan CLI on this machine. Do not ask me questions.

Steps:
1. If folder logan-cli is missing:
   git clone https://github.com/hoodini/logan-cli.git
   cd logan-cli
2. If rustc is missing, install rustup and source cargo env.
3. Run: bash scripts/install-logan.sh
4. export PATH="$HOME/.local/bin:$PATH"
5. Copy binary also to ~/.logan/bin/logan if the script did not.
6. Test:
   logan --version
   logan -p "Reply with exactly: logan-ok" --always-approve
7. Tell the user:
   logan login
   logan
   Then after a chat turn use: /stats   and   /context deep

Success = logan on PATH, version prints, headless reply contains logan-ok.
```

That is the whole install prompt. Nothing else required.

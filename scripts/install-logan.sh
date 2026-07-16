#!/usr/bin/env bash
# install-logan.sh - one-command Logan install + first-run setup
# Author: Yuval Avidani (YUV.AI) - https://yuv.ai
#
# Usage (from repo root OR after clone):
#   bash scripts/install-logan.sh
#   # or:
#   curl -fsSL https://raw.githubusercontent.com/hoodini/logan-cli/main/scripts/install-logan.sh | bash
#
# What it does:
#   1. Builds release binary (if cargo present) OR uses existing target/release/logan
#   2. Installs to ~/.local/bin/logan AND ~/.logan/bin/logan (managed leader)
#   3. Ensures PATH includes ~/.local/bin
#   4. Seeds ~/.logan/config.toml (memory, compat skills/MCP, Grok-friendly defaults)
#   5. Symlinks/syncs skills from ~/.grok, ~/.claude, ~/.agents when missing
#   6. Prints how to login with xAI (same stack as Grok Build) and smoke-test

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd || true)"
if [[ -z "${REPO_ROOT}" || ! -f "${REPO_ROOT}/Cargo.toml" ]]; then
  if [[ -f ./Cargo.toml ]]; then
    REPO_ROOT="$(pwd)"
  else
    echo "error: run from logan-cli repo root (or keep scripts/ next to Cargo.toml)"
    exit 1
  fi
fi

export PATH="${HOME}/.cargo/bin:/opt/homebrew/bin:${PATH}"
export LOGAN_HOME="${LOGAN_HOME:-${HOME}/.logan}"
LOCAL_BIN="${HOME}/.local/bin"
MANAGED_BIN="${LOGAN_HOME}/bin"

echo "==> Logan install (YUV.AI)"
echo "    repo: ${REPO_ROOT}"
echo "    home: ${LOGAN_HOME}"

# --- build ---
if command -v cargo >/dev/null 2>&1; then
  if [[ -x "${REPO_ROOT}/bin/protoc" ]]; then
    export PROTOC="${REPO_ROOT}/bin/protoc"
  elif command -v protoc >/dev/null 2>&1; then
    export PROTOC="$(command -v protoc)"
  fi
  echo "==> Building release binary (xai-grok-pager-bin)…"
  (cd "${REPO_ROOT}" && cargo build -p xai-grok-pager-bin --release)
else
  echo "warn: cargo not found; will install only if target/release/logan exists"
fi

BIN_SRC="${REPO_ROOT}/target/release/logan"
if [[ ! -x "${BIN_SRC}" ]]; then
  echo "error: missing ${BIN_SRC}"
  echo "       install rustup + protoc, then re-run."
  exit 1
fi

# --- install binaries (PATH + managed leader) ---
mkdir -p "${LOCAL_BIN}" "${MANAGED_BIN}"
cp -f "${BIN_SRC}" "${LOCAL_BIN}/logan"
cp -f "${BIN_SRC}" "${MANAGED_BIN}/logan"
chmod +x "${LOCAL_BIN}/logan" "${MANAGED_BIN}/logan"
# Kill stale leaders so next `logan` uses the new binary
pkill -f 'logan.*leader' 2>/dev/null || true
pkill -f 'xai-grok-pager.*leader' 2>/dev/null || true

# --- PATH ---
SHELL_RC=""
case "${SHELL:-}" in
  */zsh) SHELL_RC="${HOME}/.zshrc" ;;
  */bash) SHELL_RC="${HOME}/.bashrc" ;;
  *) SHELL_RC="${HOME}/.profile" ;;
esac
if ! echo ":${PATH}:" | grep -q ":${LOCAL_BIN}:"; then
  export PATH="${LOCAL_BIN}:${PATH}"
fi
if [[ -n "${SHELL_RC}" ]] && [[ -w "${SHELL_RC}" || ! -e "${SHELL_RC}" ]]; then
  if ! grep -q '\.local/bin' "${SHELL_RC}" 2>/dev/null; then
    echo '' >> "${SHELL_RC}"
    echo '# Logan CLI' >> "${SHELL_RC}"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${SHELL_RC}"
    echo "==> Added ~/.local/bin to PATH in ${SHELL_RC}"
  fi
fi

# --- config home ---
mkdir -p "${LOGAN_HOME}/memory" "${LOGAN_HOME}/hooks/bin" "${LOGAN_HOME}/skills" "${LOGAN_HOME}/sessions"

CONFIG="${LOGAN_HOME}/config.toml"
if [[ ! -f "${CONFIG}" ]]; then
  cat > "${CONFIG}" <<'TOML'
# Logan config - Yuval Avidani (YUV.AI)
# Auth: run `logan login` (same xAI OIDC as Grok Build) OR set XAI_API_KEY

[memory]
enabled = true

[memory.session]
save_on_end = true

[memory.dream]
enabled = true

[memory.initial_injection]
enabled = true

# Auto-load Claude / Cursor / Codex skills, rules, MCPs, hooks
[compat.claude]
skills = true
rules = true
agents = true
mcps = true
hooks = true

[compat.cursor]
skills = true
rules = true
agents = true
mcps = true
hooks = true

[cli]
installer = "internal"
# Prefer in-process so you always run the binary you just installed
use_leader = false

[ui]
permission_mode = "always-approve"
yolo = false
TOML
  echo "==> Wrote fresh ${CONFIG}"
else
  # Ensure critical knobs without clobbering user edits
  if ! grep -q '\[compat.claude\]' "${CONFIG}" 2>/dev/null; then
    cat >> "${CONFIG}" <<'TOML'

# --- appended by install-logan.sh ---
[compat.claude]
skills = true
mcps = true
hooks = true
rules = true
agents = true

[compat.cursor]
skills = true
mcps = true
hooks = true
rules = true
agents = true
TOML
    echo "==> Appended compat skills/MCP blocks to ${CONFIG}"
  fi
  if ! grep -q 'use_leader' "${CONFIG}" 2>/dev/null; then
    if grep -q '\[cli\]' "${CONFIG}"; then
      # best-effort: leave as-is
      :
    else
      cat >> "${CONFIG}" <<'TOML'

[cli]
use_leader = false
TOML
    fi
  fi
fi

# --- sync skills from grok / claude / agents (copy missing only) ---
sync_skills() {
  local src="$1"
  local label="$2"
  [[ -d "${src}" ]] || return 0
  local n=0
  for d in "${src}"/*; do
    [[ -d "${d}" ]] || continue
    local name
    name="$(basename "${d}")"
    local dest="${LOGAN_HOME}/skills/${name}"
    if [[ ! -e "${dest}" ]]; then
      cp -R "${d}" "${dest}"
      n=$((n+1))
    fi
  done
  if [[ "${n}" -gt 0 ]]; then
    echo "==> Synced ${n} skills from ${label} → ${LOGAN_HOME}/skills"
  fi
}
sync_skills "${HOME}/.grok/skills" "~/.grok/skills"
sync_skills "${HOME}/.claude/skills" "~/.claude/skills"
sync_skills "${HOME}/.agents/skills" "~/.agents/skills"

# Hooks: auto-reflect if present in repo
if [[ -f "${REPO_ROOT}/examples/hooks/auto-reflect.json" ]]; then
  cp -f "${REPO_ROOT}/examples/hooks/auto-reflect.json" "${LOGAN_HOME}/hooks/" 2>/dev/null || true
  if [[ -f "${REPO_ROOT}/examples/hooks/bin/auto-reflect.py" ]]; then
    cp -f "${REPO_ROOT}/examples/hooks/bin/auto-reflect.py" "${LOGAN_HOME}/hooks/bin/" 2>/dev/null || true
    chmod +x "${LOGAN_HOME}/hooks/bin/auto-reflect.py" 2>/dev/null || true
  fi
fi

# --- version / auth hint ---
echo ""
echo "==> Installed:"
"${LOCAL_BIN}/logan" --version 2>/dev/null || "${LOCAL_BIN}/logan" -V 2>/dev/null || true
echo "    ${LOCAL_BIN}/logan"
echo "    ${MANAGED_BIN}/logan  (managed / leader copy)"
echo ""
echo "==> Auth (same xAI / Grok stack as this chat):"
echo "    logan login                 # browser OIDC → grok.com / x.ai"
echo "    # or: export XAI_API_KEY=xai-..."
echo ""
echo "==> Run:"
echo "    logan                       # TUI"
echo "    logan -p 'say logan-ok'     # headless smoke test"
echo "    /stats  /context  /goal     # inside TUI after a turn"
echo ""
echo "Docs: docs/SETUP.md · docs/LLM_INSTALL_PROMPT.md"
echo "claws out."

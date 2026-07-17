#!/usr/bin/env bash
# Guards for native modes / whoami / improve skills.
# Author: Yuval Avidani (YUV.AI)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
FAIL=0
pass() { printf 'PASS  %s\n' "$*"; }
fail() { printf 'FAIL  %s\n' "$*"; FAIL=$((FAIL + 1)); }

for s in caveman ponytail whoami self-improve hyperframes-master; do
  if [[ -f "${ROOT}/skills/${s}/SKILL.md" ]]; then
    pass "skill ${s}"
  else
    fail "missing skill ${s}"
  fi
done

if rg -q "logan_modes::CavemanCommand" "${ROOT}/crates/codegen/xai-grok-pager/src/slash/commands/mod.rs"; then
  pass "caveman command registered"
else
  fail "caveman not registered"
fi
if rg -q "WhoamiCommand" "${ROOT}/crates/codegen/xai-grok-pager/src/slash/commands/mod.rs"; then
  pass "whoami registered"
else
  fail "whoami not registered"
fi
if rg -q "ImproveCommand" "${ROOT}/crates/codegen/xai-grok-pager/src/slash/commands/mod.rs"; then
  pass "improve registered"
else
  fail "improve not registered"
fi
if [[ -f "${ROOT}/docs/MODES.md" ]]; then
  pass "docs/MODES.md"
else
  fail "missing MODES.md"
fi
if rg -q 'skills/\$\{name\}' "${ROOT}/scripts/install-logan.sh" || rg -q 'REPO_ROOT}/skills' "${ROOT}/scripts/install-logan.sh"; then
  pass "install seeds skills/"
else
  fail "install does not seed skills/"
fi

if [[ "${FAIL}" -ne 0 ]]; then
  echo "FAILED: ${FAIL}"
  exit 1
fi
echo "ALL PASS"
exit 0

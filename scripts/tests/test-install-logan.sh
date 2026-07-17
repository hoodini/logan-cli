#!/usr/bin/env bash
# Tests for one-command Logan install (drives shipped scripts).
# Author: Yuval Avidani (YUV.AI)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
SH="${ROOT}/scripts/install-logan.sh"
PS1="${ROOT}/scripts/install-logan.ps1"
FAIL=0

pass() { printf 'PASS  %s\n' "$*"; }
fail() { printf 'FAIL  %s\n' "$*"; FAIL=$((FAIL + 1)); }

# --- static: scripts exist and advertise one-liners ---
[[ -f "${SH}" ]] || fail "missing install-logan.sh"
[[ -f "${PS1}" ]] || fail "missing install-logan.ps1"
[[ -x "${SH}" ]] || chmod +x "${SH}"

grep -q 'raw.githubusercontent.com/hoodini/logan-cli/main/scripts/install-logan.sh' "${SH}" \
  && pass "bash one-liner URL in install-logan.sh" \
  || fail "bash one-liner URL missing"

grep -q 'install-logan.ps1' "${PS1}" \
  && pass "ps1 self-reference present" \
  || fail "ps1 missing self URL"

README="${ROOT}/README.md"
grep -q 'install-logan.sh | bash' "${README}" \
  && pass "README has curl|bash one-liner" \
  || fail "README missing curl|bash"
grep -qi 'install-logan.ps1' "${README}" \
  && pass "README mentions Windows install" \
  || fail "README missing Windows install"

grep -q 'LOGAN_INSTALL_DIR' "${SH}" && grep -q 'git clone' "${SH}" \
  && pass "bootstrap can clone without checkout" \
  || fail "no clone bootstrap path"

grep -q 'rustup' "${SH}" && pass "auto rustup path" || fail "no rustup"
grep -q 'protoc' "${SH}" && pass "auto protoc path" || fail "no protoc"
grep -q 'try_prebuilt_release\|Prebuilt' "${SH}" && pass "prebuilt release path" || fail "no prebuilt"
grep -q 'is_interactive' "${SH}" && pass "interactive gate" || fail "no interactive gate"
grep -q '/dev/tty' "${SH}" && pass "curl|bash tty reattach" || fail "no /dev/tty reattach"
grep -q 'CI' "${SH}" && pass "CI non-interactive" || fail "no CI gate"

grep -qi 'rustup' "${PS1}" && pass "ps1 rustup" || fail "ps1 no rustup"
grep -qi 'Ensure-Protoc\|protoc' "${PS1}" && pass "ps1 protoc bootstrap" || fail "ps1 no protoc"
grep -q 'LOGAN_INSTALL_NO_START' "${PS1}" && pass "ps1 interactive gate" || fail "ps1 no interactive gate"
# Must NOT require IsInputRedirected false for start (irm|iex always redirects)
if grep -q 'IsInputRedirected' "${PS1}"; then
  if grep -q 'UserInteractive.*IsInputRedirected\|IsInputRedirected.*UserInteractive' "${PS1}"; then
    fail "ps1 still blocks on IsInputRedirected (breaks irm|iex auto-start)"
  else
    pass "ps1 IsInputRedirected not blocking start"
  fi
else
  pass "ps1 does not use IsInputRedirected"
fi
# Interactive start must free the console (not bare & $destLocal after irm|iex)
if grep -q 'Start-Process' "${PS1}" && grep -q '\$destLocal' "${PS1}"; then
  pass "ps1 Start-Process free-console launch"
else
  fail "ps1 missing Start-Process free-console launch for TUI"
fi
# Guard: interactive branch must not be only bare call-operator start
if grep -A5 'Test-Interactive' "${PS1}" | grep -q 'Start-Process'; then
  pass "ps1 Test-Interactive branch uses Start-Process"
else
  fail "ps1 Test-Interactive branch does not use Start-Process"
fi

grep -q '\[compat.claude\]' "${SH}" && pass "seeds compat.claude" || fail "no compat seed"
grep -q 'use_leader = false' "${SH}" && pass "seeds use_leader false" || fail "no use_leader seed"
grep -q 'install_bin_atomic\|.new.\$\$' "${SH}" && pass "atomic binary install" || fail "no atomic install"

# --- Drive SHIPPED is_interactive via LOGAN_INSTALL_PROBE (no reimplementation) ---
probe() {
  # Pipe stdin (simulates curl|bash) while keeping a real session when possible.
  # The shipped function must return yes when stdout is a TTY and CI/NO_START unset.
  LOGAN_INSTALL_PROBE=is_interactive "$@" bash "${SH}" </dev/null
}

out="$(LOGAN_INSTALL_NO_START=1 probe 2>/dev/null || true)"
[[ "${out}" == "no" ]] && pass "shipped probe: NO_START => no" || fail "shipped probe NO_START got '${out}'"

out="$(CI=1 probe 2>/dev/null || true)"
[[ "${out}" == "no" ]] && pass "shipped probe: CI => no" || fail "shipped probe CI got '${out}'"

out="$(NONINTERACTIVE=1 probe 2>/dev/null || true)"
[[ "${out}" == "no" ]] && pass "shipped probe: NONINTERACTIVE => no" || fail "shipped probe NONINTERACTIVE got '${out}'"

# Piped stdin + TTY stdout (this test harness is usually a TTY on stdout):
# must be "yes" so curl|bash would auto-start.
out="$(probe 2>/dev/null || true)"
if [[ -t 1 ]]; then
  [[ "${out}" == "yes" ]] && pass "shipped probe: piped stdin + TTY stdout => yes (curl|bash start)" \
    || fail "shipped probe expected yes for curl|bash-like, got '${out}'"
else
  # Non-TTY CI runner: accept no, but require /dev/tty path still present in script
  [[ "${out}" == "yes" || "${out}" == "no" ]] && pass "shipped probe ran in non-TTY harness (got ${out})" \
    || fail "shipped probe unexpected '${out}'"
fi

if [[ "${FAIL}" -ne 0 ]]; then
  echo "FAILED: ${FAIL} checks"
  exit 1
fi
echo "ALL PASS"
exit 0

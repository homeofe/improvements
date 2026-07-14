#!/usr/bin/env bash
# verify-hooks.test.sh - Plain-shell tests for local hook coverage.
#
# The repo does not use bats, so this is a self-contained runner (no framework
# dependency). It exercises scripts/install-hooks.sh and scripts/verify-hooks.sh
# against throwaway git repositories under a temp directory it cleans up.
#
# Cases (issue #8, AC#5):
#   1. fresh install         - installer places both hooks; verify reports INSTALLED
#   2. upgrade over old hook  - installer overwrites a drifted hook; verify passes
#   3. duplicate invocation   - installer is idempotent (stable checksum, no extra backup)
#   4. missing-hook detection - a required-but-absent hook is UNKNOWN and fails
#   5. declared exception     - an exempt hook is EXEMPT and does not fail
#
# Run:  bash tests/verify-hooks.test.sh
# Exit: 0 if all assertions pass, 1 otherwise.

set -u

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$TEST_DIR/.." && pwd)"
INSTALL="$REPO_ROOT/scripts/install-hooks.sh"
VERIFY="$REPO_ROOT/scripts/verify-hooks.sh"
CANON_HOOKS="$REPO_ROOT/scripts/hooks"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

PASS=0
FAIL=0

ok()   { PASS=$((PASS + 1)); echo "  ok   - $1"; }
bad()  { FAIL=$((FAIL + 1)); echo "  FAIL - $1"; }

assert_exit() { # expected actual msg
    if [ "$1" = "$2" ]; then ok "$3 (exit $2)"; else bad "$3 (expected exit $1, got $2)"; fi
}
assert_contains() { # haystack needle msg
    case "$1" in
        *"$2"*) ok "$3" ;;
        *)      bad "$3 (missing: $2)"; printf '        --- output ---\n%s\n        --------------\n' "$1" ;;
    esac
}
assert_eq() { # expected actual msg
    if [ "$1" = "$2" ]; then ok "$3"; else bad "$3 (expected '$1', got '$2')"; fi
}

# Init a throwaway git repo and echo its path.
new_repo() {
    local d="$WORK/$1"
    mkdir -p "$d"
    git -C "$d" init -q
    echo "$d"
}

# Write the fixture coverage registry used by every case.
REGISTRY="$WORK/hook-coverage.md"
cat > "$REGISTRY" <<'EOF'
# Fixture coverage registry

<!-- BEGIN hook-coverage-registry -->
| repo | type | required_hooks | exempt_hooks | reason |
|------|------|----------------|--------------|--------|
| test/full | product-platform | pre-commit,pre-push | - | - |
| test/exempt-push | product-platform | pre-commit,pre-push | pre-push | ci-only enforcement |
<!-- END hook-coverage-registry -->
EOF

# Run verify, capturing stdout+stderr and the exit code (set -e safe).
run_verify() { # args...  -> sets RV_OUT, RV_RC
    RV_OUT="$(bash "$VERIFY" "$@" 2>&1)"; RV_RC=$?
}

echo "verify-hooks.test.sh"
echo "REPO_ROOT=$REPO_ROOT"

# --- Sanity: the pieces under test exist ------------------------------------
[ -f "$INSTALL" ] && ok "install-hooks.sh present" || bad "install-hooks.sh missing"
[ -f "$VERIFY" ]  && ok "verify-hooks.sh present"  || bad "verify-hooks.sh missing"
[ -f "$CANON_HOOKS/pre-commit" ] && [ -f "$CANON_HOOKS/pre-push" ] \
    && ok "canonical hooks present" || bad "canonical hooks missing"

# --- Case 1: fresh install ---------------------------------------------------
echo "[case 1] fresh install"
R1="$(new_repo case1)"
bash "$INSTALL" "$R1" >/dev/null
run_verify "$R1" --repo test/full --registry "$REGISTRY"
assert_exit 0 "$RV_RC" "fresh install verifies clean"
assert_contains "$RV_OUT" "INSTALLED  pre-commit" "pre-commit reported INSTALLED"
assert_contains "$RV_OUT" "INSTALLED  pre-push" "pre-push reported INSTALLED"

# --- Case 2: upgrade over an older/modified hook -----------------------------
echo "[case 2] upgrade over an older hook"
R2="$(new_repo case2)"
mkdir -p "$R2/.git/hooks"
# Pre-seed an OLD AAHP pre-push that differs from canonical (marker present so
# the installer upgrades in place rather than backing it up).
cat > "$R2/.git/hooks/pre-push" <<'OLD'
#!/usr/bin/env bash
# AAHP pre-push hook - OLD stale version for the upgrade test.
echo "stale"
OLD
run_verify "$R2" --repo test/full --registry "$REGISTRY"
assert_exit 1 "$RV_RC" "drifted hook fails before upgrade"
assert_contains "$RV_OUT" "DRIFTED    pre-push" "stale pre-push reported DRIFTED"
# Upgrade.
bash "$INSTALL" "$R2" >/dev/null
run_verify "$R2" --repo test/full --registry "$REGISTRY"
assert_exit 0 "$RV_RC" "upgrade brings the hook back to INSTALLED"
assert_contains "$RV_OUT" "INSTALLED  pre-push" "upgraded pre-push reported INSTALLED"

# --- Case 3: duplicate invocation (idempotency) ------------------------------
echo "[case 3] duplicate invocation is idempotent"
R3="$(new_repo case3)"
bash "$INSTALL" "$R3" >/dev/null
sum1="$(cat "$R3/.git/hooks/pre-commit" | tr -d '\r' | sha256sum | awk '{print $1}')"
bash "$INSTALL" "$R3" >/dev/null
sum2="$(cat "$R3/.git/hooks/pre-commit" | tr -d '\r' | sha256sum | awk '{print $1}')"
assert_eq "$sum1" "$sum2" "pre-commit checksum stable across two installs"
backups="$(find "$R3/.git/hooks" -name '*.pre-aahp.bak' | wc -l | tr -d ' ')"
assert_eq "0" "$backups" "no backup files created on a clean re-install"
run_verify "$R3" --repo test/full --registry "$REGISTRY"
assert_exit 0 "$RV_RC" "repo still verifies clean after duplicate install"

# --- Case 4: missing-hook detection ------------------------------------------
echo "[case 4] missing-hook detection"
R4="$(new_repo case4)"
bash "$INSTALL" "$R4" >/dev/null
rm -f "$R4/.git/hooks/pre-push"
run_verify "$R4" --repo test/full --registry "$REGISTRY"
assert_exit 1 "$RV_RC" "missing required hook fails"
assert_contains "$RV_OUT" "UNKNOWN    pre-push" "absent pre-push reported UNKNOWN"
assert_contains "$RV_OUT" "INSTALLED  pre-commit" "present pre-commit still INSTALLED"

# --- Case 5: declared exception ----------------------------------------------
echo "[case 5] declared exception"
R5="$(new_repo case5)"
bash "$INSTALL" "$R5" >/dev/null
rm -f "$R5/.git/hooks/pre-push"   # exempt repo may legitimately omit pre-push
run_verify "$R5" --repo test/exempt-push --registry "$REGISTRY"
assert_exit 0 "$RV_RC" "exempt hook does not fail even when absent"
assert_contains "$RV_OUT" "EXEMPT     pre-push" "pre-push reported EXEMPT"
assert_contains "$RV_OUT" "INSTALLED  pre-commit" "pre-commit still INSTALLED under exemption"

# --- Summary -----------------------------------------------------------------
echo ""
echo "========================================="
echo "  verify-hooks tests: $PASS passed, $FAIL failed"
echo "========================================="
[ "$FAIL" -eq 0 ]

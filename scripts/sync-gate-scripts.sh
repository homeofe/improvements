#!/usr/bin/env bash
# sync-gate-scripts.sh - Propagate the canonical AAHP gate scripts into a
# consumer repo checkout, preserving that repo's per-repo config.
#
# WHY THIS EXISTS
#   The four gate scripts under scripts/ are vendored (copied) into every
#   consumer repo. Over time they DRIFT: a fix landed in the canonical repo
#   (homeofe/improvements) never reaches the copies, so each consumer runs a
#   slightly different gate. The ONLY gate-deciding function, aahp_checksum, is
#   byte-identical everywhere and must stay that way; the rest should track the
#   canonical source. This tool makes that propagation mechanical instead of
#   manual, WITHOUT clobbering the one line that is legitimately per-repo.
#
# WHAT IT SYNCS
#   scripts/_aahp-lib.sh
#   scripts/lint-handoff.sh
#   scripts/aahp-manifest.sh
#   scripts/verify-handoff.sh
#
# WHAT IT PRESERVES (the important part)
#   The consumer's own AAHP_HANDOFF_FILES=(...) line in scripts/_aahp-lib.sh.
#   That array names which handoff files a repo tracks and differs per repo
#   (some track LOG-ARCHIVE.md / LOG-ARCHIVE.index.json / pii-allowlist.json,
#   some do not). This tool reads the consumer's existing line and substitutes
#   it into the canonical copy, so a sync never changes a repo's tracked-file
#   set. Everything else in the four scripts becomes byte-identical to canonical.
#
# PROPERTIES
#   - Idempotent: a second run against an already-synced repo changes nothing.
#   - Portable: pure bash + coreutils/awk. No node, python, or other runtime dep.
#   - Non-destructive to git: it only edits the working tree; committing/PRing
#     is the caller's job (see .github/workflows/gate-sync.yml).
#
# Usage:
#   scripts/sync-gate-scripts.sh <path-to-consumer-repo-checkout>
#
# Exit codes:
#   0 = success (whether or not anything changed; see the printed summary)
#   1 = usage error / consumer layout not recognised

set -euo pipefail

# --- Locate the canonical scripts (this script's own directory) --------------
CANON_DIR="$(cd "$(dirname "$0")" && pwd)"

GATE_SCRIPTS=(_aahp-lib.sh lint-handoff.sh aahp-manifest.sh verify-handoff.sh)
LIB_SCRIPT="_aahp-lib.sh"
CONFIG_KEY="AAHP_HANDOFF_FILES="

# --- Args --------------------------------------------------------------------
if [ $# -ne 1 ] || [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    sed -n '2,49p' "$0" | sed 's/^# \{0,1\}//'
    [ $# -eq 1 ] && exit 0 || exit 1
fi

CONSUMER_ROOT="$1"
CONSUMER_SCRIPTS="$CONSUMER_ROOT/scripts"

if [ ! -d "$CONSUMER_ROOT" ]; then
    echo "Error: consumer repo path not found: $CONSUMER_ROOT" >&2
    exit 1
fi
if [ ! -d "$CONSUMER_SCRIPTS" ]; then
    echo "Error: consumer has no scripts/ directory: $CONSUMER_SCRIPTS" >&2
    exit 1
fi

# Guard against pointing the tool at the canonical repo itself.
if [ "$(cd "$CONSUMER_SCRIPTS" && pwd)" = "$CANON_DIR" ]; then
    echo "Error: refusing to sync the canonical repo onto itself." >&2
    exit 1
fi

# Sanity: every canonical gate script must be present.
for s in "${GATE_SCRIPTS[@]}"; do
    if [ ! -f "$CANON_DIR/$s" ]; then
        echo "Error: canonical script missing: $CANON_DIR/$s" >&2
        exit 1
    fi
done

echo "========================================="
echo "  AAHP gate-script sync"
echo "========================================="
echo "  Canonical: $CANON_DIR"
echo "  Consumer:  $CONSUMER_SCRIPTS"
echo ""

# --- Read the consumer's per-repo config line (before we overwrite anything) -
CONSUMER_CONFIG_LINE=""
if [ -f "$CONSUMER_SCRIPTS/$LIB_SCRIPT" ]; then
    # First matching line only; strip a trailing CR so a CRLF working tree does
    # not inject a lone carriage return into the (LF) canonical body.
    CONSUMER_CONFIG_LINE="$(grep -m1 "^$CONFIG_KEY" "$CONSUMER_SCRIPTS/$LIB_SCRIPT" 2>/dev/null | tr -d '\r' || true)"
fi

if [ -n "$CONSUMER_CONFIG_LINE" ]; then
    echo "  Preserving consumer $CONFIG_KEY line:"
    echo "    $CONSUMER_CONFIG_LINE"
else
    DEFAULT_LINE="$(grep -m1 "^$CONFIG_KEY" "$CANON_DIR/$LIB_SCRIPT" | tr -d '\r' || true)"
    echo "  No consumer $CONFIG_KEY line found; using canonical default:"
    echo "    $DEFAULT_LINE"
fi
echo ""

# --- Build desired content for each script, then apply only if it differs ----
TMPDIR_SYNC="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_SYNC"' EXIT

CHANGED_LIST=()
UNCHANGED_LIST=()

build_desired() {
    # $1 = script name -> writes desired content to $2
    local name="$1" out="$2"
    if [ "$name" = "$LIB_SCRIPT" ] && [ -n "$CONSUMER_CONFIG_LINE" ]; then
        # Substitute the consumer's config line into the canonical lib. Pass the
        # replacement via the environment so awk performs NO backslash-escape
        # processing on it (ENVIRON values are taken verbatim). Only the first
        # matching line is replaced.
        AAHP_REPL_LINE="$CONSUMER_CONFIG_LINE" awk '
            index($0, "'"$CONFIG_KEY"'") == 1 && !done {
                print ENVIRON["AAHP_REPL_LINE"]; done = 1; next
            }
            { print }
        ' "$CANON_DIR/$name" > "$out"
    else
        cat "$CANON_DIR/$name" > "$out"
    fi
}

for name in "${GATE_SCRIPTS[@]}"; do
    desired="$TMPDIR_SYNC/$name"
    build_desired "$name" "$desired"
    target="$CONSUMER_SCRIPTS/$name"

    if [ -f "$target" ] && cmp -s "$desired" "$target"; then
        UNCHANGED_LIST+=("$name")
        echo "  unchanged  scripts/$name"
    else
        # Show a short diff summary when the target already existed.
        if [ -f "$target" ]; then
            echo "  UPDATED    scripts/$name"
            if command -v diff >/dev/null 2>&1; then
                diff -u "$target" "$desired" 2>/dev/null \
                    | sed 's/^/      /' | head -40 || true
            fi
        else
            echo "  ADDED      scripts/$name"
        fi
        cp "$desired" "$target"
        chmod +x "$target" 2>/dev/null || true
        CHANGED_LIST+=("$name")
    fi
done

echo ""
echo "-----------------------------------------"
if [ ${#CHANGED_LIST[@]} -eq 0 ]; then
    echo "  RESULT: no changes (consumer already in sync)."
else
    echo "  RESULT: ${#CHANGED_LIST[@]} script(s) changed: ${CHANGED_LIST[*]}"
    echo "  AAHP_HANDOFF_FILES was preserved from the consumer (per-repo config)."
fi
echo "-----------------------------------------"

exit 0

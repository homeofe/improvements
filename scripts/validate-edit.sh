#!/usr/bin/env bash
# validate-edit.sh - PostToolUse hook for Claude Code
#
# Validates every file edited by Claude for:
#   1. Em dashes (U+2014) - banned by CONVENTIONS.md
#   2. Common secret patterns - banned by safety rules
#
# Claude Code passes tool call details as JSON on stdin.
# Exit codes:
#   0 = ok, no violations
#   2 = violations found (reported to user, does NOT block the edit)
#
# To test manually:
#   echo '{"tool_name":"Edit","tool_input":{"file_path":"path/to/file.md"}}' | bash scripts/validate-edit.sh

set -euo pipefail

# --------------------------------------------------------------------------
# Read file path from stdin JSON
# --------------------------------------------------------------------------
INPUT=$(cat 2>/dev/null || true)

# Try Python first (most reliable, cross-platform)
FILE=""
if command -v python3 &>/dev/null; then
  FILE=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    # tool_input.file_path for Edit/Write
    print(d.get('tool_input', {}).get('file_path', ''))
except Exception:
    pass
" 2>/dev/null || true)
elif command -v python &>/dev/null; then
  FILE=$(printf '%s' "$INPUT" | python -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('file_path', ''))
except Exception:
    pass
" 2>/dev/null || true)
elif command -v jq &>/dev/null; then
  FILE=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)
fi

# Nothing to validate
if [ -z "$FILE" ] || [ ! -f "$FILE" ]; then
  exit 0
fi

# Skip binary files, generated files, and node_modules
case "$FILE" in
  *.png|*.jpg|*.jpeg|*.gif|*.ico|*.woff|*.woff2|*.ttf|*.eot|*.mp4|*.zip|*.tar|*.gz)
    exit 0 ;;
  */node_modules/*|*/dist/*|*/.git/*)
    exit 0 ;;
esac

VIOLATIONS=0

# --------------------------------------------------------------------------
# Check 1: Em dash (Unicode U+2014)
# --------------------------------------------------------------------------
# Use grep with -P (Perl regex) for Unicode support; fallback to plain grep
EM_DASH_HITS=""
if grep -Pn "\x{2014}" "$FILE" 2>/dev/null; then
  EM_DASH_HITS="found"
elif grep -n $'\xe2\x80\x94' "$FILE" 2>/dev/null; then
  EM_DASH_HITS="found"
fi

if [ -n "$EM_DASH_HITS" ]; then
  printf "\n[validate] WARNING: Em dash found in %s\n" "$FILE"
  printf "           Use a hyphen (-) or double-hyphen (--) instead.\n"
  printf "           See .ai/handoff/CONVENTIONS.md for formatting rules.\n"
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# --------------------------------------------------------------------------
# Check 2: Secret patterns
# --------------------------------------------------------------------------
SECRET_FOUND=0
check_secret() {
  local label="$1"
  local pattern="$2"
  if grep -Pni "$pattern" "$FILE" 2>/dev/null | head -3; then
    printf "[validate] WARNING: Possible %s in %s\n" "$label" "$FILE"
    SECRET_FOUND=1
  fi
}

# API keys and tokens
check_secret "OpenAI/Anthropic key"  "sk-[a-zA-Z0-9]{20,}"
check_secret "Anthropic key (new)"   "sk-ant-[a-zA-Z0-9\-_]{20,}"
check_secret "GitHub token"          "gh[ps]_[a-zA-Z0-9]{36}"
check_secret "AWS access key"        "AKIA[A-Z0-9]{16}"
check_secret "AWS secret key"        "aws_secret_access_key\s*=\s*['\"]?[A-Za-z0-9/+=]{40}"
check_secret "generic API key"       "(api[_-]?key|apikey)\s*[=:]\s*['\"][a-zA-Z0-9\-_]{16,}['\"]"
check_secret "password assignment"   "password\s*[=:]\s*['\"][^'\"]{8,}['\"]"
check_secret "bearer token"          "Bearer\s+[a-zA-Z0-9\-_.~+/]+=*"
check_secret "private key header"    "-----BEGIN (RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----"

if [ "$SECRET_FOUND" -eq 1 ]; then
  printf "\n[validate] WARNING: Possible secret(s) detected in %s\n" "$FILE"
  printf "           Remove secrets before committing. Use environment variables instead.\n"
  printf "           See .ai/handoff/.aiignore for secret patterns to watch for.\n"
  VIOLATIONS=$((VIOLATIONS + 1))
fi

# --------------------------------------------------------------------------
# Result
# --------------------------------------------------------------------------
if [ "$VIOLATIONS" -gt 0 ]; then
  printf "\n[validate] %d convention violation(s) in %s. Review before committing.\n" \
    "$VIOLATIONS" "$FILE"
  exit 2
fi

exit 0

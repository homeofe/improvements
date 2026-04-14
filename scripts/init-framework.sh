#!/usr/bin/env bash
# init-framework.sh - Install AI Workflow Improvement Framework into a target project
#
# Usage:
#   ./scripts/init-framework.sh [TARGET_DIR] [PROJECT_NAME]
#
# Examples:
#   ./scripts/init-framework.sh ../my-project "My Project"
#   ./scripts/init-framework.sh .  "This Project"   # install into current dir
#
# What it does:
#   - Copies .claude/ (rules, agents, commands, settings)
#   - Copies .llm/ (routing, providers, prompts, patterns)
#   - Generates CLAUDE.md with project name filled in
#   - Initializes .ai/handoff/ with clean AAHP templates
#   - Runs `aahp init` if the AAHP CLI is available

set -euo pipefail

FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${1:-$(pwd)}"
PROJECT_NAME="${2:-$(basename "$(cd "$TARGET_DIR" && pwd)")}"

# --------------------------------------------------------------------------
# Colors (skip if not a tty)
# --------------------------------------------------------------------------
if [ -t 1 ]; then
  RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; BLUE=''; NC=''
fi

info() { printf "${BLUE}[framework]${NC} %s\n" "$1"; }
ok()   { printf "${GREEN}[ok]${NC}        %s\n" "$1"; }
warn() { printf "${YELLOW}[warn]${NC}      %s\n" "$1"; }
die()  { printf "${RED}[error]${NC}     %s\n" "$1" >&2; exit 1; }

# --------------------------------------------------------------------------
# Validate
# --------------------------------------------------------------------------
[ -d "$TARGET_DIR" ] || die "Target directory does not exist: $TARGET_DIR"
[ "$FRAMEWORK_DIR" != "$(cd "$TARGET_DIR" && pwd)" ] || die "Target cannot be the framework directory itself"

info "Installing AI Workflow Improvement Framework"
info "Source : $FRAMEWORK_DIR"
info "Target : $TARGET_DIR"
info "Project: $PROJECT_NAME"
echo

# --------------------------------------------------------------------------
# Step 1: Copy .claude/ (rules, agents, commands)
# --------------------------------------------------------------------------
info "Copying .claude/ ..."
mkdir -p "$TARGET_DIR/.claude"

for subdir in rules agents commands; do
  src="$FRAMEWORK_DIR/.claude/$subdir"
  if [ -d "$src" ]; then
    cp -r "$src" "$TARGET_DIR/.claude/"
    ok ".claude/$subdir/"
  fi
done

# settings.json - copy only if target does not already have one
settings_src="$FRAMEWORK_DIR/.claude/settings.json"
settings_dst="$TARGET_DIR/.claude/settings.json"
if [ -f "$settings_src" ]; then
  if [ ! -f "$settings_dst" ]; then
    cp "$settings_src" "$settings_dst"
    ok ".claude/settings.json"
  else
    warn ".claude/settings.json already exists - skipping (merge manually if needed)"
  fi
fi

# --------------------------------------------------------------------------
# Step 2: Copy .llm/
# --------------------------------------------------------------------------
info "Copying .llm/ ..."
if [ -d "$FRAMEWORK_DIR/.llm" ]; then
  cp -r "$FRAMEWORK_DIR/.llm" "$TARGET_DIR/.llm"
  ok ".llm/"
else
  warn ".llm/ not found in framework - skipping"
fi

# --------------------------------------------------------------------------
# Step 3: Generate CLAUDE.md
# --------------------------------------------------------------------------
info "Generating CLAUDE.md ..."
claude_dst="$TARGET_DIR/CLAUDE.md"
template="$FRAMEWORK_DIR/scripts/templates/CLAUDE.md.tpl"

if [ -f "$claude_dst" ]; then
  warn "CLAUDE.md already exists - skipping (edit it to match your project)"
elif [ -f "$template" ]; then
  sed "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$template" > "$claude_dst"
  ok "CLAUDE.md (from template)"
else
  # Inline minimal template - no em dashes, no secrets, placeholders filled
  cat > "$claude_dst" << CLAUDEEOF
# $PROJECT_NAME

> AI-assisted development project using the AI Workflow Improvement Framework.

## Quick Start (Every Session)

1. Read \`.ai/handoff/MANIFEST.json\` for project state
2. Check \`quick_context\` field for orientation
3. Consult \`.llm/ROUTING.md\` when choosing which model to use for a task
4. Follow AAHP protocol rules in \`.claude/rules/aahp-protocol.md\`

## Key File Locations

| What | Where |
|------|-------|
| AAHP handoff state | \`.ai/handoff/\` |
| Model routing guide | \`.llm/ROUTING.md\` |
| Provider capabilities | \`.llm/PROVIDERS.md\` |
| Reusable prompts | \`.llm/PROMPTS.md\` |
| Workflow patterns | \`.llm/PATTERNS.md\` |
| Project conventions | \`.ai/handoff/CONVENTIONS.md\` |
| Agent pipeline | \`.ai/handoff/WORKFLOW.md\` |

## Conventions

- English only (code, comments, docs, commits)
- No em dashes (use hyphens instead)
- AAHP protocol compliance for all handoff operations
- Conventional commits: \`feat(scope): description [AAHP-auto]\`
- Always update AAHP state files at end of session (use \`/handoff\`)

## Custom Commands

- \`/handoff\` - Complete AAHP handoff cycle (update state, log, manifest)
- \`/route <task>\` - Get model routing recommendation for a task
- \`/status\` - Display AAHP project health dashboard
- \`/next\` - Pick and start the next ready AAHP task
- \`/review-cycle\` - Run multi-model review on recent changes

## Multi-Model Strategy

When working on this project, consider routing tasks to the best model:
- **Research**: Perplexity (web-grounded), Gemini (large context)
- **Architecture**: Opus, GPT-4 (hard reasoning)
- **Implementation**: Sonnet, Codex (fast coding)
- **Review**: Use a different provider than the implementer
- **Quick tasks**: Haiku, GPT-4-mini, local LLM

See \`.llm/ROUTING.md\` for the full decision matrix.

## AAHP Protocol

This project uses AAHP v3 for structured handoff between AI agents. Key rules:
- Always read \`MANIFEST.json\` before starting work
- Update handoff files atomically (all or nothing)
- Never reuse task IDs
- Mark trust claims with TTL
- See \`.claude/rules/aahp-protocol.md\` for full protocol
CLAUDEEOF
  ok "CLAUDE.md (generated)"
fi

# --------------------------------------------------------------------------
# Step 4: Initialize .ai/handoff/
# --------------------------------------------------------------------------
info "Initializing .ai/handoff/ ..."
mkdir -p "$TARGET_DIR/.ai/handoff"

if command -v aahp &> /dev/null; then
  (cd "$TARGET_DIR" && aahp init)
  ok "aahp init completed"
else
  warn "aahp CLI not found - writing minimal templates"
  TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u)

  # MANIFEST.json
  if [ ! -f "$TARGET_DIR/.ai/handoff/MANIFEST.json" ]; then
    cat > "$TARGET_DIR/.ai/handoff/MANIFEST.json" << MANIFESTEOF
{
  "aahp_version": "3.0",
  "project": "$PROJECT_NAME",
  "last_session": null,
  "files": {},
  "quick_context": "Fresh install. No sessions yet. Begin with T-001: configure project conventions.",
  "token_budget": {
    "manifest_only": 220,
    "manifest_plus_core": 700,
    "full_read": 4000
  },
  "next_task_id": 2,
  "tasks": {
    "T-001": {
      "title": "Configure project-specific conventions",
      "status": "ready",
      "priority": "high",
      "depends_on": [],
      "created": "$TIMESTAMP"
    }
  }
}
MANIFESTEOF
    ok ".ai/handoff/MANIFEST.json"
  fi

  # STATUS.md
  if [ ! -f "$TARGET_DIR/.ai/handoff/STATUS.md" ]; then
    cat > "$TARGET_DIR/.ai/handoff/STATUS.md" << STATUSEOF
# $PROJECT_NAME: Status

<!-- SECTION: overview -->
**Project:** $PROJECT_NAME
**Last Updated:** $TIMESTAMP (install)
**Framework:** AI Workflow Improvement Framework v1

<!-- SECTION: state -->
## Current State

Fresh install. Framework installed via init-framework.sh.
No sessions started yet. Begin with T-001.

<!-- SECTION: trust -->
## Trust Levels

- Framework files: (Verified) - installed from framework source
- Project content (CLAUDE.md, CONVENTIONS.md): (Unknown) - not yet customized
STATUSEOF
    ok ".ai/handoff/STATUS.md"
  fi

  # NEXT_ACTIONS.md
  if [ ! -f "$TARGET_DIR/.ai/handoff/NEXT_ACTIONS.md" ]; then
    cat > "$TARGET_DIR/.ai/handoff/NEXT_ACTIONS.md" << NAEOF
# $PROJECT_NAME: Next Actions

> Priority order. Work top-down.
> Each item should be self-contained.

---

## T-001: Configure project-specific conventions

**Goal:** Customize the framework files to match this project.

**Steps:**
1. Edit \`CLAUDE.md\` - fill in project purpose, repo links, key contacts
2. Edit \`.ai/handoff/CONVENTIONS.md\` - add project-specific coding rules
3. Edit \`.llm/ROUTING.md\` - adjust model preferences if needed
4. Run \`/handoff\` at end of session to commit the state

**Definition of done:**
- [ ] CLAUDE.md reflects this project
- [ ] CONVENTIONS.md has project rules
- [ ] First /handoff committed to git

---

## Recently Completed

| Item | Resolution |
|------|-----------|
| T-000: Framework install | Installed via init-framework.sh on $TIMESTAMP |
NAEOF
    ok ".ai/handoff/NEXT_ACTIONS.md"
  fi

  # LOG.md
  if [ ! -f "$TARGET_DIR/.ai/handoff/LOG.md" ]; then
    cat > "$TARGET_DIR/.ai/handoff/LOG.md" << LOGEOF
# $PROJECT_NAME: Session Log

> Reverse chronological. Max 10 entries. Older entries in LOG-ARCHIVE.md.

---

## Session: install-$TIMESTAMP

> **Agent:** init-framework.sh
> **Session ID:** install-$TIMESTAMP
> **Timestamp:** $TIMESTAMP
> **Commit:** (pre-first-commit)

### Summary
Framework installed into \`$PROJECT_NAME\` via init-framework.sh.

### Files created
- \`.claude/\` (rules, agents, commands, settings)
- \`.llm/\` (routing, providers, prompts, patterns)
- \`.ai/handoff/\` (MANIFEST, STATUS, NEXT_ACTIONS, LOG, CONVENTIONS, WORKFLOW)
- \`CLAUDE.md\`

### Next
Run T-001: customize CLAUDE.md and CONVENTIONS.md for this project.
LOGEOF
    ok ".ai/handoff/LOG.md"
  fi

  # LOG-ARCHIVE.md (empty placeholder)
  if [ ! -f "$TARGET_DIR/.ai/handoff/LOG-ARCHIVE.md" ]; then
    printf "# %s: Log Archive\n\n> Entries moved here when LOG.md exceeds 10 entries.\n\n(empty)\n" \
      "$PROJECT_NAME" > "$TARGET_DIR/.ai/handoff/LOG-ARCHIVE.md"
    ok ".ai/handoff/LOG-ARCHIVE.md"
  fi

  # Copy CONVENTIONS.md, WORKFLOW.md, .aiignore from framework (authoritative templates)
  for f in CONVENTIONS.md WORKFLOW.md .aiignore; do
    src="$FRAMEWORK_DIR/.ai/handoff/$f"
    dst="$TARGET_DIR/.ai/handoff/$f"
    if [ -f "$src" ] && [ ! -f "$dst" ]; then
      cp "$src" "$dst"
      ok ".ai/handoff/$f"
    elif [ ! -f "$src" ]; then
      warn ".ai/handoff/$f not found in framework source - skipping"
    fi
  done

  # DASHBOARD.md and TRUST.md - generate stubs
  if [ ! -f "$TARGET_DIR/.ai/handoff/DASHBOARD.md" ]; then
    cat > "$TARGET_DIR/.ai/handoff/DASHBOARD.md" << DASHEOF
# $PROJECT_NAME: Dashboard

> Auto-updated by agents. Do not edit manually.

## Task Queue

| ID | Title | Status | Priority |
|----|-------|--------|----------|
| T-001 | Configure project-specific conventions | ready | high |

## Pipeline State

Not yet configured.

## Build Health

Not yet configured.
DASHEOF
    ok ".ai/handoff/DASHBOARD.md"
  fi

  if [ ! -f "$TARGET_DIR/.ai/handoff/TRUST.md" ]; then
    cat > "$TARGET_DIR/.ai/handoff/TRUST.md" << TRUSTEOF
# $PROJECT_NAME: Trust Register

> TTL: high-churn properties 1-3 days, stable properties 30 days.
> Expired (Verified) automatically downgrades to (Assumed).

## Verified Claims

| Claim | Verified By | Date | TTL | Expires |
|-------|------------|------|-----|---------|
| Framework files installed correctly | init-framework.sh | $TIMESTAMP | 30d | (recalculate) |

## Assumed Claims

- Project-specific conventions: (Assumed) - not yet customized
- Build system: (Unknown) - not yet configured
TRUSTEOF
    ok ".ai/handoff/TRUST.md"
  fi
fi

# --------------------------------------------------------------------------
# Done
# --------------------------------------------------------------------------
echo
ok "Framework installed successfully."
echo
printf "  Target  : %s\n" "$TARGET_DIR"
printf "  Project : %s\n" "$PROJECT_NAME"
echo
echo "Next steps:"
echo "  1. Edit CLAUDE.md          - describe your project"
echo "  2. Edit .ai/handoff/CONVENTIONS.md - add project-specific rules"
echo "  3. Start Claude Code in the project and run /status"
echo "  4. Run /handoff at end of first session to initialize git state"
echo

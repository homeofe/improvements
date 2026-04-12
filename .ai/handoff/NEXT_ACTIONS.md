# AI Workflow Improvement Framework: Next Actions for Incoming Agent

> Priority order. Work top-down.
> Each item should be self-contained, the agent must be able to start without asking questions.
> Blocked tasks go to the bottom. Completed tasks move to "Recently Completed".

---

## T-004: Add Template Packaging Script

**Goal:** Create a script that copies the framework to any project, adapting placeholders.

**Context:**
- Framework manually integrated into Shield (20 files) and AEGIS (17 files)
- Manual copying works but is error-prone and tedious
- GitHub Issue: #2

**What to do:**
1. Create `scripts/init-framework.sh` (or `.js`)
2. Script should:
   - Copy `.claude/`, `.llm/` directories to target
   - Generate a starter `CLAUDE.md` with project name placeholder filled
   - Initialize `.ai/handoff/` with clean templates
   - Run `aahp init` if AAHP CLI is available
3. Test with a fresh directory

**Definition of done:**
- [ ] Script creates all framework files in target directory
- [ ] Placeholders replaced with project-specific values
- [ ] Works on both Windows and Unix

---

## T-005: Add PostToolUse Hooks for Quality Enforcement

**Goal:** Configure hooks that auto-validate no em dashes and no secrets in edited files.

**Context:**
- `.claude/settings.json` exists but hooks are not yet configured
- CONVENTIONS.md prohibits em dashes and secrets
- GitHub Issue: #3

**What to do:**
1. Create a validation script (bash or node) that checks for em dashes and secret patterns
2. Add PostToolUse hook in `.claude/settings.json` for Edit|Write events
3. Test that the hook blocks commits with violations

**Definition of done:**
- [ ] Hook fires on every Edit/Write
- [ ] Em dashes detected and reported
- [ ] Secret patterns from .aiignore detected
- [ ] Hook does not block valid edits

---

## Recently Completed

| Item | Resolution |
|------|-----------|
| T-003: Test framework in real project | Integrated into Shield + AEGIS, all 5 commands verified (Issue #1 closed) |
| T-002: Create all framework files | 30 files created across 4 layers |
| T-001: Design framework structure | 4-layer architecture designed and implemented |

---

## Reference: Key File Locations

| What | Where |
|------|-------|
| Project instructions | `CLAUDE.md` |
| Model routing | `.llm/ROUTING.md` |
| Provider capabilities | `.llm/PROVIDERS.md` |
| AAHP protocol rules | `.claude/rules/aahp-protocol.md` |
| Custom commands | `.claude/commands/*.md` |
| Custom agents | `.claude/agents/*.md` |
| AAHP handoff state | `.ai/handoff/` |
| Integration guide | `INTEGRATION.md` |

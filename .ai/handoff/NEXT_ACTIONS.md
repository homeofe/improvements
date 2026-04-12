# AI Workflow Improvement Framework: Next Actions for Incoming Agent

> Priority order. Work top-down.
> Each item should be self-contained, the agent must be able to start without asking questions.
> Blocked tasks go to the bottom. Completed tasks move to "Recently Completed".

---

## T-003: Test Framework in a Real Project

**Goal:** Copy the framework to an existing project and validate it works end-to-end.

**Context:**
- Framework structure is complete with all configuration files
- Untested in real-world usage

**What to do:**
1. Choose a target project (e.g., Shield, AEGIS, or another active project)
2. Copy `.claude/`, `.llm/`, and CLAUDE.md to the target project
3. Adapt CLAUDE.md for the target project's specifics
4. Run a full session using the framework: `/status`, `/next`, `/route`, `/handoff`
5. Document what works and what needs adjustment

**Files:**
- `CLAUDE.md`: Root project instructions
- `.claude/commands/*.md`: Custom commands to test
- `.llm/ROUTING.md`: Model routing to validate

**Definition of done:**
- [ ] Framework copied to a real project
- [ ] All 5 custom commands work correctly
- [ ] Model routing produces sensible recommendations
- [ ] Handoff cycle completes without errors
- [ ] STATUS.md updated with findings

---

## T-004: Add Template Packaging Script

**Goal:** Create a script that copies the framework to any project, adapting placeholders.

**Context:**
- Framework files contain project-specific content that needs adaptation
- Manual copying is error-prone

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

## T-005: Add PostToolUse Hooks for Quality

**Goal:** Configure hooks that auto-validate no em dashes and no secrets in edited files.

**Context:**
- `.claude/settings.json` exists but hooks are not yet configured
- CONVENTIONS.md prohibits em dashes and secrets

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
| T-001: Design framework structure | Designed and implemented in initial session |
| T-002: Create all framework files | 28 files created across 4 layers |

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

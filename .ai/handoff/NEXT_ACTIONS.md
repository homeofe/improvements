# AI Workflow Improvement Framework: Next Actions for Incoming Agent

> Priority order. Work top-down.
> Each item should be self-contained, the agent must be able to start without asking questions.
> Blocked tasks go to the bottom. Completed tasks move to "Recently Completed".

---

## No open tasks

All tasks complete. The framework is fully operational and portable.

To add new tasks, follow AAHP protocol: assign T-006+ IDs, update MANIFEST.json.

---

## Recently Completed

| Item | Resolution |
|------|-----------|
| T-005: PostToolUse hooks | validate-edit.sh + settings.json hook wired. Fires on Edit/Write. |
| T-004: Template packaging script | scripts/init-framework.sh - copies framework into any project |
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
| **Install script** | `scripts/init-framework.sh` |
| **Edit validator** | `scripts/validate-edit.sh` |

# AI Workflow Improvement Framework: Build Dashboard

> Single source of truth for framework health and task state.
> Updated by agents at the end of every completed task.

---

## Framework Components

| Name | Files | State | Notes |
|------|-------|-------|-------|
| CLAUDE.md | 1 | (Unknown) | Customize for your project |
| Rules | n | (Verified) | `.claude/rules/` |
| Agents | n | (Verified) | `.claude/agents/` |
| Commands | n | (Verified) | `.claude/commands/` |
| LLM configs | n | (Verified) | `.llm/` |
| AAHP handoff | 8 | (Verified) | This `.ai/handoff/` directory |

**Legend:** (Verified) confirmed - (Assumed) untested - (Unknown) needs check

---

## Validation Status

| Check | Status | Last Verified |
|-------|--------|--------------|
| All files exist | (Verified) | YYYY-MM-DD |
| No em dashes in files | (Unknown) | - |
| No secrets in files | (Unknown) | - |
| Build/test pipeline | (Unknown) | Not yet configured |

---

## Pipeline State

| Field | Value |
|-------|-------|
| Current task | idle |
| Phase | idle |
| Last completed | (none yet) |
| Build | Not yet configured |
| Rate limit | None |

---

## Open Tasks (strategic priority)

| ID | Task | Priority | Blocked by | Ready? |
|----|------|----------|-----------|--------|
| T-001 | Customize the framework for your project | HIGH | - | Ready |

---

## Completed Tasks

| ID | Task | Completed |
|----|------|-----------|
| (none yet) | - | - |

---

## Update Instructions (for agents)

After completing any task:

1. Update the relevant rows above
2. Update validation status if checks were performed
3. Update "Pipeline State"
4. Move completed task out of "Open Tasks"
5. Add newly discovered tasks with correct priority

**Pipeline rules:**
- Blocked task - skip, take next unblocked
- All tasks blocked - notify the project owner
- Notify project owner only on **fully completed tasks**, not phase transitions
- On failures: attempt 1-2 self-fixes before escalating

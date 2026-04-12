# AI Workflow Improvement Framework: Build Dashboard

> Single source of truth for framework health and task state.
> Updated by agents at the end of every completed task.

---

## Framework Components

| Name | Files | State | Notes |
|------|-------|-------|-------|
| CLAUDE.md | 1 | (Verified) | Root project instructions |
| Rules | 4 | (Verified) | aahp-protocol, multi-model, safety, handoff |
| Agents | 5 | (Verified) | researcher, architect, implementer, reviewer, handoff-manager |
| Commands | 5 | (Verified) | handoff, route, status, next, review-cycle |
| LLM configs | 4 | (Verified) | routing, providers, patterns, prompts |
| AAHP handoff | 8 | (Verified) | All populated for this project |
| Settings | 1 | (Verified) | Permission rules configured |

**Legend:** (Verified) confirmed - (Assumed) untested - (Unknown) needs check

---

## Validation Status

| Check | Status | Last Verified |
|-------|--------|--------------|
| All files exist | (Verified) | 2026-04-12 |
| No em dashes in files | (Assumed) | - |
| No secrets in files | (Assumed) | - |
| Commands work in Claude Code | (Unknown) | Not yet tested |
| Agents spawn correctly | (Unknown) | Not yet tested |
| AAHP manifest valid | (Verified) | 2026-04-12 |
| Cross-project portability | (Unknown) | Not yet tested |

---

## Pipeline State

| Field | Value |
|-------|-------|
| Current task | T-003 (not started) |
| Phase | idle |
| Last completed | T-002: Create framework files |
| Rate limit | None |

---

## Open Tasks (strategic priority)

| ID | Task | Priority | Blocked by | Ready? |
|----|------|----------|-----------|--------|
| T-003 | Test framework in real project | HIGH | - | Ready |
| T-004 | Add template packaging script | MEDIUM | - | Ready |
| T-005 | Add PostToolUse hooks for quality | LOW | - | Ready |

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

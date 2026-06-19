# AI Workflow Improvement Framework: Next Actions for Incoming Agent

> Priority order. Work top-down.
> Each item should be self-contained, the agent must be able to start without asking questions.
> Blocked tasks go to the bottom. Completed tasks move to "Recently Completed".

---

## Open Tasks

| ID | Task | Priority | Blocked by | Ready? |
|----|------|----------|-----------|--------|
| T-001 | Customize the framework for your project | HIGH | - | Ready |

**T-001 details:** Update `CLAUDE.md`, the `.llm/` routing configs, and these
`.ai/handoff/` files to describe your real project. Configure your build and
test pipeline, then mark this task done and add your own T-002+ tasks.

---

## Recently Completed

| Item | Resolution |
|------|-----------|
| (none yet) | This is a fresh install |

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

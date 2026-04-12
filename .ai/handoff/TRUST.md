# AI Workflow Improvement Framework: Trust Register

> Tracks verification status of critical system properties.
> Trust has TTL - expired (Verified) auto-downgrades to (Assumed).

---

## Confidence Levels

| Level | Meaning |
|-------|---------|
| **verified** | An agent executed code, ran tests, or observed output to confirm this |
| **assumed** | Derived from docs, config files, or chat, not directly tested |
| **untested** | Status unknown; needs verification |

---

## Framework Structure

| Property | Status | Last Verified | Agent | TTL | Expires | Notes |
|----------|--------|---------------|-------|-----|---------|-------|
| All framework files exist | verified | 2026-04-12 | claude-opus-4.6 | 7d | 2026-04-19 | 28 files created |
| CLAUDE.md loads correctly | untested | - | - | - | - | Needs new session test |
| Custom commands functional | untested | - | - | - | - | /status, /next, /route, /handoff, /review-cycle |
| Custom agents spawn | untested | - | - | - | - | researcher, architect, implementer, reviewer, handoff-manager |
| Settings.json valid | assumed | 2026-04-12 | claude-opus-4.6 | 3d | 2026-04-15 | Permissions configured |

---

## Content Quality

| Property | Status | Last Verified | Agent | TTL | Expires | Notes |
|----------|--------|---------------|-------|-----|---------|-------|
| No em dashes in files | assumed | 2026-04-12 | claude-opus-4.6 | 1d | 2026-04-13 | Needs grep verification |
| No secrets in files | assumed | 2026-04-12 | claude-opus-4.6 | 1d | 2026-04-13 | Needs pattern scan |
| No absolute paths | assumed | 2026-04-12 | claude-opus-4.6 | 1d | 2026-04-13 | Needs grep verification |

---

## AAHP Compliance

| Property | Status | Last Verified | Agent | TTL | Expires | Notes |
|----------|--------|---------------|-------|-----|---------|-------|
| MANIFEST.json valid schema | verified | 2026-04-12 | claude-opus-4.6 | 7d | 2026-04-19 | v3 format |
| Protocol rules documented | verified | 2026-04-12 | claude-opus-4.6 | 30d | 2026-05-12 | In .claude/rules/ |
| Handoff file rules documented | verified | 2026-04-12 | claude-opus-4.6 | 30d | 2026-05-12 | In .claude/rules/ |

---

## Cross-Project Portability

| Property | Status | Last Verified | Agent | TTL | Expires | Notes |
|----------|--------|---------------|-------|-----|---------|-------|
| Framework copies cleanly | untested | - | - | - | - | Needs real test |
| CLAUDE.md adapts to target | untested | - | - | - | - | Needs packaging script |
| LLM configs are generic | assumed | 2026-04-12 | claude-opus-4.6 | 7d | 2026-04-19 | No project-specific references |

---

## Update Rules (for agents)

- Change `untested` to `verified` only after **running actual code/tests**
- Change `assumed` to `verified` after direct confirmation
- Never downgrade `verified` without explaining why in `LOG.md`
- Add new rows when new system properties become critical
- Expired `verified` automatically downgrades to `assumed`
- Re-verify periodically, especially after major changes

## How to Re-Verify

| Property | Verification Method |
|----------|-------------------|
| Files exist | `find .claude/ .llm/ .ai/handoff/ -type f \| wc -l` (expect 28) |
| CLAUDE.md loads | Start a new Claude Code session in this directory |
| Commands work | Run `/status`, `/next`, `/route test`, `/review-cycle` |
| Agents spawn | Run a task that triggers each agent type |
| No em dashes | `grep -rPn '\xe2\x80\x94' .claude/ .llm/ .ai/` |
| No secrets | Check `.ai/handoff/.aiignore` patterns against all files |
| Manifest valid | `aahp lint` or JSON schema validation |

---

*Trust degrades over time. Re-verify periodically, especially after major refactors.*

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
| All framework files exist | verified | 2026-04-12 | claude-opus-4.6 | 7d | 2026-04-19 | 30 files across 4 layers |
| CLAUDE.md loads correctly | verified | 2026-04-12 | claude-opus-4.6 | 7d | 2026-04-19 | Loaded in current session, rules applied |
| Custom commands functional | verified | 2026-04-12 | claude-opus-4.6 | 7d | 2026-04-19 | All 5 tested: /status, /next, /route, /review-cycle, /handoff |
| Custom agents spawn | assumed | 2026-04-12 | claude-opus-4.6 | 3d | 2026-04-15 | Agent definitions valid, not yet triggered via subagent |
| Settings.json valid | verified | 2026-04-12 | claude-opus-4.6 | 7d | 2026-04-19 | Permissions loaded, no errors |

---

## Content Quality

| Property | Status | Last Verified | Agent | TTL | Expires | Notes |
|----------|--------|---------------|-------|-----|---------|-------|
| No em dashes in files | verified | 2026-04-12 | claude-opus-4.6 | 3d | 2026-04-15 | grep -rP confirms zero matches |
| No secrets in files | verified | 2026-04-12 | claude-opus-4.6 | 3d | 2026-04-15 | Only .aiignore patterns (rules, not secrets) |
| No absolute paths | verified | 2026-04-12 | claude-opus-4.6 | 3d | 2026-04-15 | grep confirms zero matches |

---

## AAHP Compliance

| Property | Status | Last Verified | Agent | TTL | Expires | Notes |
|----------|--------|---------------|-------|-----|---------|-------|
| MANIFEST.json valid schema | verified | 2026-04-12 | claude-opus-4.6 | 7d | 2026-04-19 | v3 format with checksums |
| Checksums match files | verified | 2026-04-12 | claude-opus-4.6 | 1d | 2026-04-13 | Regenerated via /handoff |
| Protocol rules documented | verified | 2026-04-12 | claude-opus-4.6 | 30d | 2026-05-12 | In .claude/rules/ |
| Handoff file rules documented | verified | 2026-04-12 | claude-opus-4.6 | 30d | 2026-05-12 | In .claude/rules/ |
| Atomic handoff works | verified | 2026-04-12 | claude-opus-4.6 | 7d | 2026-04-19 | Lock/update/checksum/unlock/commit tested |

---

## Cross-Project Portability

| Property | Status | Last Verified | Agent | TTL | Expires | Notes |
|----------|--------|---------------|-------|-----|---------|-------|
| Framework copies cleanly | verified | 2026-04-12 | claude-opus-4.6 | 7d | 2026-04-19 | Shield (20 files) + AEGIS (17 files) |
| CLAUDE.md adapts to target | verified | 2026-04-12 | claude-opus-4.6 | 7d | 2026-04-19 | Extended existing CLAUDE.md in both projects |
| LLM configs are generic | verified | 2026-04-12 | claude-opus-4.6 | 7d | 2026-04-19 | No project-specific references |
| skills/ works same as commands/ | verified | 2026-04-12 | claude-opus-4.6 | 30d | 2026-05-12 | AEGIS uses skills/, Shield uses commands/ |

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
| Files exist | `find .claude/ .llm/ .ai/handoff/ -type f \| wc -l` (expect 30) |
| CLAUDE.md loads | Start a new Claude Code session in this directory |
| Commands work | Run `/status`, `/next`, `/route test`, `/review-cycle` |
| Agents spawn | Run a task that triggers each agent type |
| No em dashes | `grep -rPn '\xe2\x80\x94' .claude/ .llm/ .ai/` |
| No secrets | Check `.ai/handoff/.aiignore` patterns against all files |
| Manifest valid | `aahp lint` or JSON schema validation |
| Checksums match | `sha256sum .ai/handoff/*.md` and compare to MANIFEST.json |

---

*Trust degrades over time. Re-verify periodically, especially after major refactors.*

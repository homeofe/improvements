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

## Provenance (Draft v0.1, proposed)

The Grounded Reflection Layer adds an orthogonal *provenance* field recording HOW a
claim was checked, separate from the status above: `model_claim`, `self_reviewed`,
`cross_model_reviewed`, `source_verified`, `tool_verified`, `test_verified`,
`runtime_observed`, `human_confirmed`. `cross_model_reviewed` maps to status
`assumed`, never `verified`; only `source_verified` / `tool_verified` /
`test_verified` / `runtime_observed` / `human_confirmed` can support `verified`
(== grounded). TTL and expiry stay governed by the Trust Decay rule in
`.claude/rules/aahp-protocol.md`. See `.ai/GROUNDING.md` for the task-type anchor
matrix and `.claude/rules/grounded-reflection.md` for the rules.

---

## Framework Structure

| Property | Status | Last Verified | Agent | TTL | Expires | Notes |
|----------|--------|---------------|-------|-----|---------|-------|
| All framework files exist | verified | YYYY-MM-DD | your-agent | 7d | YYYY-MM-DD | Handoff files present |
| CLAUDE.md customized | untested | - | - | 7d | - | Customize for your project |

---

## Content Quality

| Property | Status | Last Verified | Agent | TTL | Expires | Notes |
|----------|--------|---------------|-------|-----|---------|-------|
| No em dashes in files | untested | - | - | 3d | - | Run grep to confirm |
| No secrets in files | untested | - | - | 3d | - | Review against .aiignore patterns |

---

## AAHP Compliance

| Property | Status | Last Verified | Agent | TTL | Expires | Notes |
|----------|--------|---------------|-------|-----|---------|-------|
| MANIFEST.json valid schema | verified | YYYY-MM-DD | your-agent | 7d | YYYY-MM-DD | v3 format with checksums |
| Checksums match files | untested | - | - | 1d | - | Regenerate via /handoff |
| Protocol rules documented | verified | YYYY-MM-DD | your-agent | 30d | YYYY-MM-DD | In .claude/rules/ |

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
| Files exist | `find .claude/ .llm/ .ai/handoff/ -type f \| wc -l` |
| CLAUDE.md loads | Start a new Claude Code session in this directory |
| Commands work | Run `/status`, `/next`, `/route test`, `/review-cycle` |
| No em dashes | `grep -rPn '\xe2\x80\x94' .claude/ .llm/ .ai/` |
| No secrets | Check `.ai/handoff/.aiignore` patterns against all files |
| Manifest valid | `aahp lint` or JSON schema validation |
| Checksums match | `sha256sum .ai/handoff/*.md` and compare to MANIFEST.json |

---

*Trust degrades over time. Re-verify periodically, especially after major refactors.*

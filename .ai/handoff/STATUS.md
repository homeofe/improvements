# AI Workflow Improvement Framework: Current State of the Nation

> Last updated: 2026-06-20 by Claude Opus 4.8 (1M context)
> Commit: (pending)
>
> **Rule:** This file is rewritten (not appended) at the end of every session.
> It reflects the *current* reality, not history. History lives in LOG.md.

---

<!-- SECTION: summary -->
## Summary

The AI Workflow Improvement Framework now ships the AAHP verify gate. As the
first propagation target from the AAHP protocol repo, this framework carries
`scripts/verify-handoff.sh` plus the pre-commit and pre-push hooks
(`scripts/install-hooks.sh`) and the `.github/workflows/aahp-verify.yml` CI
check, so every project that installs this framework also gets the gate against
staled handoff state. The seed task T-001 "Customize the framework for your
project" is still ready for consumers. The gate is verify-only: it never
regenerates MANIFEST.json (that stays a separate /handoff step).
<!-- /SECTION: summary -->

---

<!-- SECTION: build_health -->
## Build Health

| Check | Result | Notes |
|-------|--------|-------|
| Framework structure | (Verified) | Handoff files present and well-formed |
| AAHP verify gate | (Verified) | scripts/verify-handoff.sh installed; hooks wired via install-hooks.sh |
| Build/test pipeline | (Unknown) | Not yet configured for your project |
| CLAUDE.md | (Unknown) | Customize for your project |
<!-- /SECTION: build_health -->

---

<!-- SECTION: infrastructure -->
## Infrastructure

| Component | Location | State |
|-----------|----------|-------|
| Framework files | `.claude/`, `.llm/`, `.ai/handoff/` | (Verified) Present |
| Git repository | (your remote here) | (Unknown) Not yet configured |
| Build tooling | (your build system here) | (Unknown) Not yet configured |
<!-- /SECTION: infrastructure -->

---

<!-- SECTION: components -->
## Framework Components

| Component | Files | State | Notes |
|-----------|-------|-------|-------|
| AAHP handoff state | 8 | (Verified) | This `.ai/handoff/` directory |
| AAHP verify gate | 6 | (Verified) | scripts/verify-handoff.sh, _aahp-lib.sh, lint-handoff.sh, hooks/, install-hooks.sh |
| Verify CI workflow | 1 | (Verified) | .github/workflows/aahp-verify.yml (inert until Actions re-enabled) |
| Root CLAUDE.md | 1 | (Unknown) | Customize for your project |

> Add your own components here as you build them.
<!-- /SECTION: components -->

---

<!-- SECTION: what_is_missing -->
## What is Missing

| Gap | Severity | Description |
|-----|----------|-------------|
| Project customization | HIGH | Framework still in fresh-install state (T-001) |
<!-- /SECTION: what_is_missing -->

---

## Recently Resolved

| Item | Resolution |
|------|-----------|
| Add README status badges | 2026-06-21: Added AAHP Verify workflow badge + MIT License badge below the README H1 |
| Install AAHP verify gate | Copied verify-handoff.sh + hooks + CI from AAHP; hooks installed; baseline green |
| Tighten lint secret patterns | Length floor {16,} on sk-/ghp_/gho_/AKIA in scripts/lint-handoff.sh (synced from AAHP); fixes the "sk-to" false positive that had flagged CONVENTIONS.md |
| Line-ending-agnostic checksums | Synced the CRLF/LF fix from AAHP: aahp_checksum (_aahp-lib.sh) + lint-handoff.sh strip CR before hashing, so handoff checksums match on Windows and Linux CI |

---

## Trust Levels

- **(Verified)**: confirmed by running code/tests or direct file creation
- **(Assumed)**: derived from docs/config, not directly tested
- **(Unknown)**: needs verification

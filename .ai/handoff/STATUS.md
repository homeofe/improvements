> Note (2026-07-25, claude-opus-5): Made the fleet-distribution tooling configuration-driven so the framework ships the mechanism and an operator supplies the deployment data. gate-sync.yml now reads its target list at runtime from the Actions variable GATE_SYNC_CONSUMERS (newline, comma, or space separated owner/name; a workflow_dispatch `consumers` input, read via github.event.inputs so it resolves the same way on the push trigger, overrides it for a one-off run) instead of a literal array, registers every target with ::add-mask:: and reports progress by position rather than by name, takes its runner from the optional GATE_SYNC_RUNNER variable (default ubuntu-latest), and commits as the standard github-actions[bot] identity. With no list configured the job warns and exits 0. docs/gate-sync.md and docs/hook-coverage.md were rewritten around roles and placeholders: hook-coverage keeps the registry format, the required-hooks-by-role table, and the exception schema, and verify-hooks.sh gained an AAHP_HOOK_REGISTRY environment fallback (precedence --registry, AAHP_HOOK_REGISTRY, shipped default) so an operator can verify against their own registry. Verified: the workflow YAML parses and the extracted run block is syntax-clean (bash -n); the list parser was exercised standalone over six inputs (newline, comma, and space separators, comment tails, CRLF, a glob character, malformed entries counted and dropped without echoing them, and empty input taking the warn-and-exit-0 path), which caught and fixed two defects in the first cut (the final entry was dropped when the value had no trailing newline, and words after a `#` were counted as entries); tests/verify-hooks.test.sh passes 19 of 19; and verify-hooks.sh was checked against all three registry sources (flag, environment variable, shipped default) plus the exempt-row example.

> Note (2026-07-19, claude-opus-4-8): Aligned the AAHP v3.8.0 conformance PR (#18) with the gemini-code-assist review. Corrected a factually wrong maintainer note: GitHub Actions is ON for homeofe (the AAHP Verify workflow already ran and passed on this PR commit), so the "Actions is OFF org-wide (cost sweep)" statement was removed from the PR body and from the aahp-verify.yml header comment; the "mark AAHP Verify as a REQUIRED status check" follow-up is kept. Rejected three review suggestions that would fork canonical AAHP v3.8.0 template text: the two GROUNDING.md wording edits (the "Draft v0.1 - proposed." status stamp and the "shorthand names points" phrasing are seeded verbatim from @elvatis_com/aahp by migrate-grounding, so any genuine fix belongs upstream in homeofe/AAHP, not per-repo), and the claim that aahp-verify.yml is missing from the PR (it is included). Preserved the MANIFEST tasks (T-001 seed) and next_task_id (integer 2) across the manifest checksum regen; TRUST.md provenance placeholders left as seeded.

> Note (2026-07-18, claude-opus-4-8): Adopted AAHP v3.8.0 CLI conformance. `aahp doctor` now reports no failures. Fixed grounding by adding `.ai/handoff/GROUNDING.md` and regenerating MANIFEST.json via `aahp migrate-grounding` (TRUST.md already carried the Provenance column, so it was left unchanged); fixed manifest-schema so `next_task_id` is the integer 2 (was the string "2"). Repointed `.github/workflows/aahp-verify.yml` from `bash scripts/verify-handoff.sh . --level ci` to the pinned CLI (`npx -y @elvatis_com/aahp@3.8.0 verify . --level ci` plus a `doctor --json` snapshot), preserving the dependabot exemption and fetch-depth 0. The canonical bash gate scripts under scripts/ and the pre-commit/pre-push hooks are kept intentionally: they are this repo's fleet-distribution deliverable (sync-gate-scripts.sh, gate-sync.yml) and back the local hooks, so they are not vendored copies to remove. pinned-dep, changelog-format, and version-sync remain skip (no package.json, no CHANGELOG.md, no versionSites configured).

> Note (2026-07-17, claude-fable-5): Reconciled the gate-sync target list and the hook-coverage registry with each other and with the repositories that actually vendor the gate scripts; recorded the categories of repository that are deliberately left out (an upstream protocol source, and anything under a scope agreement that excludes it from fleet-wide automation).

> Note (2026-07-14, claude-opus-4-8): Follow-up to the v1.0 promotion, made the position paper prose fully consistent with the active status: removed the last three draft/proposal self-references ("in this draft" -> "here"; "an open design question for v1.0; this draft" -> "a deferred design question; this paper"; "The layer proposes" -> "The layer provides"). The v0.1 Version History row is intentionally kept as decision history.

> Note (2026-07-14, claude-opus-4-8): Promoted the Grounded Reflection Layer from Draft v0.1 (proposed) to v1.0 (active, adopted 2026-07-14), finalizing issue #10. Flipped every "Draft v0.1 / proposed / not yet running" status stamp across the 6 layer files (docs/POSITIONPAPER-GROUNDED-REFLECTION.md, .ai/GROUNDING.md, .claude/rules/grounded-reflection.md, .claude/commands/challenge.md, .claude/agents/auditor.md, .llm/PROMPTS-GROUNDED-REFLECTION.md) and the cross-reference stamps in TRUST.md, WORKFLOW.md, aahp-protocol.md, PATTERNS.md, ROUTING.md, README.md, INTEGRATION.md. Decision history is preserved (Version History table keeps the v0.1 row plus a new v1.0 row). Pre-promotion consistency audit passed: one canonical trust vocabulary (verified/assumed/untested), provenance is an orthogonal optional field, TTL points to the single authority in aahp-protocol.md, the auditor is Phase 4.5/on-demand (never Phase 6), INTEGRATION file counts (rules 5, agents 6, commands 6, llm 5) and the README architecture tree match reality on main, and no em dashes, en dashes, smart quotes, or German were present.
> Note (2026-07-14, claude-opus-4-8): Added the local hook-coverage contract for issue #8 (framework side): docs/hook-coverage.md (machine-readable coverage registry aligned with the gate-sync target list plus sync-gate-scripts.sh, required-hook-by-role table, and an exceptions schema and policy), scripts/verify-hooks.sh (read-only checker that classifies each required hook as installed, drifted, exempt, or unknown against the scripts/hooks/ checksums, exits non-zero on drift or a missing required hook, and modifies nothing), tests/verify-hooks.test.sh (plain-shell suite: fresh install, upgrade over a drifted hook, idempotent re-install, missing-hook, declared exception; 19 of 19 assertions pass), and an INTEGRATION.md link plus checklist item. Confirmed scripts/install-hooks.sh is already idempotent (AC#3). Consumer rollout (AC#6) stays a separate reviewed phase and is out of scope here.

> Note (2026-07-14, claude-opus-4-8): Closed GitHub issue #6 (the auto-created [T-001] seed tracking issue) as not planned; this repo is the canonical framework source, not a downstream install, so the seed has no completion here. Removed the github_issue/github_repo linkage from the T-001 manifest node so no future manifest-to-issue bridge can re-open it. The seed task itself stays for consumers via init-framework.sh.

> Note (2026-07-14, claude-opus-4-8): Adopted the AAHP v3.5.0 canonical-script fixes (from homeofe/AAHP): aahp-manifest.sh now accepts --phase documentation and preserves the optional cross_repo_ref field across regeneration; lint-handoff.sh discards the unused reason read field (shellcheck SC2034). Verified locally: --phase documentation works, cross_repo_ref survives regen, shellcheck clean. These reach the fleet on the next gate-script sync.

> Note (2026-07-14, claude-opus-4-8): Made Layer 3 (commit-pointer freshness) tolerant of history-rewriting merges. verify-handoff.sh now downgrades a non-ancestor MANIFEST.last_session.commit from a hard FAIL to a WARN. A squash-merge or rebase-merge orphans the branch-local pointer that aahp-manifest.sh records, which tripped "AAHP Verify" Layer 3 on main even though Layers 1 (checksums) and 2 (content-drift) still passed. Layers 1-2 continue to gate real staleness and the missing-MANIFEST hard-fail is unchanged. Distributed to the gated consumers via sync PRs.

> Note (2026-07-12, claude-opus-4-8): Reconciled the canonical gate scripts into a TRUE superset. BASE is now homeofe/supply-chain-guard main (newest; carries the PII allowlist system + validate-pii-allowlist.py), with the improvements-only path-format-agnostic fix folded in: lint-handoff.sh now invokes validate-pii-allowlist.py via a cwd-RELATIVE path (realpath --relative-to), fixing the Windows/MSYS "can't open file" artifact when an absolute /c/... path is passed to native python. Ported scripts/validate-pii-allowlist.py. Fixed the manifest project-corruption bug (aahp-manifest.sh now preserves an existing MANIFEST.json project field instead of overwriting it with a temp-dir basename). Hardened the sync bot: one consumer failure no longer aborts the fleet, an unparseable AAHP_HANDOFF_FILES line skips that consumer instead of injecting the superset, and a failed manifest regen no longer opens a half-refreshed PR. aahp_checksum stays byte-identical (db987255).

> Note (2026-07-12, claude-opus-4-8): Added the config-aware gate-script sync (scripts/sync-gate-scripts.sh + .github/workflows/gate-sync.yml + docs/gate-sync.md). The canonical scripts/ is now the source of truth for the four gate scripts; the sync preserves each consumer's AAHP_HANDOFF_FILES line and folds the aahp_auto_summary CR-strip robustness fix into _aahp-lib.sh.

# AI Workflow Improvement Framework: Current State of the Nation

> Note (2026-07-12, claude-opus-4-8): aahp-manifest.sh refinements after review - reverted next_task_id to the quoted-string form (improvements 060512b intent; bare integer broke JSON on empty), and fixed the task-preservation node -e blocks to pass the manifest path as argv instead of interpolating it (the MSYS bug class: an absolute MSYS $HANDOFF_DIR silently dropped tasks/next_task_id on Windows during sync-bot regen). Verified: project + tasks + next_task_id preserved across an absolute-path regen.

> Last updated: 2026-07-13 by Claude Opus 4.8 (branch feat/grounded-reflection-layer)
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
regenerates MANIFEST.json (that stays a separate /handoff step). The repository
license was migrated from MIT to the Apache License 2.0 to match the Elvatis
convention. On branch `feat/grounded-reflection-layer` (for issue #10), a Draft
v0.1 Grounded Reflection Layer was added: it extends AAHP with an orthogonal
provenance axis, a `/challenge` command, an on-demand `auditor` agent,
`.ai/GROUNDING.md`, and reflection prompt templates, reconciled onto the existing
verified/assumed/untested register and Trust Decay TTL rather than forking them.
Proposed, not yet merged.
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
| Grounded Reflection Layer | 6 new + 8 edits | (Verified) | Files present, ASCII-clean, vocabulary-consistent (tool-checked). Draft v0.1, proposed (issue #10), not yet merged |

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
| Tighten Grounded Reflection (PR #11) | 2026-07-13: Merged origin/main; addressed the gemini-code-assist review - added a Provenance column to the TRUST.md register tables and made two GROUNDING.md "Min provenance" cells single-token (human_confirmed). Kept challenge.md allowed-tools (matches handoff.md precedent; command loads). On branch; PR #11 open, not yet merged to main |
| Draft Grounded Reflection Layer | 2026-07-13: Added the Draft v0.1 layer on branch feat/grounded-reflection-layer (issue #10): docs/POSITIONPAPER, .ai/GROUNDING.md, grounded-reflection rule, /challenge, auditor agent, reflection prompts; reconciled onto the existing trust register (on branch; PR #11 open, not yet merged to main) |
| Config-aware gate-script sync | 2026-07-12: scripts/sync-gate-scripts.sh copies the 4 canonical gate scripts into a consumer while preserving its AAHP_HANDOFF_FILES line; .github/workflows/gate-sync.yml opens a PR per consumer on canonical change; docs/gate-sync.md documents the model + GATE_SYNC_TOKEN requirement |
| Add community-health files | 2026-06-29: Added SECURITY.md, CODE_OF_CONDUCT.md, CONTRIBUTING.md, and .github issue/PR templates (security, conduct, contributing, issue/PR templates) |
| Add AAHP Swarm spec docs | 2026-06-29: Landed docs/AAHP-SWARM-v0.1.md and docs/AAHP-SWARM-v0.2.md (architecture concept v0.1 and v0.2) |
| Add README status badges | 2026-06-21: Added AAHP Verify workflow badge + MIT License badge below the README H1 |
| Install AAHP verify gate | Copied verify-handoff.sh + hooks + CI from AAHP; hooks installed; baseline green |
| Tighten lint secret patterns | Length floor {16,} on sk-/ghp_/gho_/AKIA in scripts/lint-handoff.sh (synced from AAHP); fixes the "sk-to" false positive that had flagged CONVENTIONS.md |
| Line-ending-agnostic checksums | Synced the CRLF/LF fix from AAHP: aahp_checksum (_aahp-lib.sh) + lint-handoff.sh strip CR before hashing, so handoff checksums match on Windows and Linux CI |

---

## Trust Levels

- **(Verified)**: confirmed by running code/tests or direct file creation
- **(Assumed)**: derived from docs/config, not directly tested
- **(Unknown)**: needs verification

> 2026-06-21 ci(aahp): fix unquoted next_task_id (invalid JSON) + lint-handoff noreply@ PII exclusion.

> 2026-06-30 ci: exempt Dependabot from the aahp-verify handoff gate (keep supply-chain-guard/codeql/build).

> Note (2026-07-19): Re-pinned @elvatis_com/aahp from 3.8.0 to 3.8.1 (picks up the v3.8.1 Windows/MSYS manifest-regen fix so tasks, next_task_id and cross_repo_ref survive regeneration). No runtime behavior change on Linux or CI. Handoff refreshed and MANIFEST regenerated.

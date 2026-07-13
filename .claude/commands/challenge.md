---
description: "Draft v0.1: run an adversarial challenge against a claim, output, or decision and report provenance gaps (read-only, does not gate)"
allowed-tools: "Read, Grep, Glob, Bash(git diff*), Bash(git log*)"
---

Run an adversarial challenge against a target claim, output, decision, or task.

This command is a proposed part of the Grounded Reflection Layer (Draft v0.1). It
reverses the burden of proof: instead of asking "Is this correct?", it asks "What
is the strongest reason this could be wrong?" It is read-only and analytical - it
produces a Challenge Report, updates nothing, and does not gate a commit. The
deterministic gate remains `scripts/verify-handoff.sh`; the terminal handoff step
is Phase 5 in `.ai/handoff/WORKFLOW.md`.

`/challenge <target>` where `<target>` is a claim, a decision, a file, a diff
range, or a task ID.

## Two Axes (reference, not redefinition)

This command reads and reports on the two axes defined in
`.claude/rules/grounded-reflection.md`. It does not introduce new levels.

- Axis A - Status (grounding confidence): `verified`, `assumed`, `untested`.
  These render in STATUS.md as `(Verified)`, `(Assumed)`, `(Unknown)`. The register
  of record is `.ai/handoff/TRUST.md`.
- Axis B - Provenance (how a claim was produced or checked), weakest to strongest:
  `model_claim` < `self_reviewed` < `cross_model_reviewed` < `source_verified` <
  `tool_verified` < `test_verified` < `runtime_observed` < `human_confirmed`.

| Grounding term | Status (register) | STATUS.md tag | Typical provenance |
|---|---|---|---|
| grounded | verified | (Verified) | test_verified / tool_verified / source_verified / runtime_observed / human_confirmed |
| partially_grounded | assumed | (Assumed) | cross_model_reviewed / self_reviewed |
| ungrounded | untested | (Unknown) | model_claim |

## When to Use

Run `/challenge` when the target is any of the following:

- Important, high-confidence, or shown to someone outside the session
- Affects architecture, security, compliance, legal, financial, or governance
- Generated and reviewed by the same model (circular-review risk)
- Depends on current external facts that may have changed
- Marked `verified` or `grounded` but the provenance basis is unclear

## Steps

1. Identify the target. If it is a diff or file, gather read-only context:
   ```
   git diff <range>
   git log --oneline -n 5
   ```
   Otherwise restate the exact claim or decision under challenge.

2. Extract the underlying claims. For each, separate Observation, Inference,
   Assumption, and Recommendation so that hidden assumptions become explicit.

3. Build the strongest counterargument. State the most credible case that the
   target is wrong, incomplete, or unsafe. One serious counterargument is the
   minimum.

4. Assess provenance (Axis B). For each claim, record its current provenance token
   and the provenance token that would be required to support the status the claim
   currently carries. Only `source_verified`, `tool_verified`, `test_verified`,
   `runtime_observed`, or `human_confirmed` can support status `verified` (that is,
   `grounded`). `cross_model_reviewed` maps to status `assumed`, not `verified` -
   consensus is not grounding.

5. Check for circular review and stale trust. Flag any claim where the generator
   and reviewer are the same model. For time-sensitive claims, do NOT recompute
   TTLs here; defer to the Trust Decay rule in `.claude/rules/aahp-protocol.md`
   (section "Trust Decay") and the per-row TTL and Expires columns already in
   `.ai/handoff/TRUST.md`. Report any row whose trust is marked `expired`.

6. Recalibrate confidence against both axes (see Output Format).

7. Recommend next actions and the AAHP state updates that would close each gap.
   Recommending is where this command stops; it does not apply the updates.

## Output Format

```
=== Challenge Report (Draft v0.1) ===

Target: [claim / decision / file / diff range / task ID]
Original claim or decision: [restated verbatim]

Strongest counterargument:
- [the most credible case that this is wrong or unsafe]

Hidden assumptions:
- [assumption relied on but not stated]

Failure modes:
- [how this breaks in practice]

Alternative explanations or solutions:
- [at least one]

Evidence required to close the gap:
- [external anchor(s) that would ground the claim]

Provenance Assessment:
| Claim | Current provenance | Required provenance | Gap |
|---|---|---|---|
| [claim] | model_claim | test_verified | needs passing tests |
| [claim] | cross_model_reviewed | source_verified | consensus is not grounding |

Confidence Recalibration (both axes):
- Axis A status, before -> after: [verified|assumed|untested] -> [verified|assumed|untested]
- Axis B provenance basis: [model_claim ... human_confirmed]
- Numeric confidence, before -> after: [0.NN] -> [0.NN]
- Confidence source: [the evidence, not model judgment alone; see confidence bands in .ai/GROUNDING.md]
- Reason for the change: [why the status or number moved]

Circular review / stale trust:
- [same-model generate+review flags; TRUST.md rows marked expired]

Required next actions:
- [concrete step to obtain each missing anchor]

Recommended handoff action (non-binding):
- [SHIP | NEEDS_CHANGES | BLOCK] - advisory only; the gating verdict is emitted by
  the Reviewer (Phase 4, .claude/agents/reviewer.md, /review-cycle) or the auditor,
  not by /challenge.

AAHP state updates needed (recommendation only):
- STATUS.md: [status tag change, e.g. (Verified) -> (Assumed)]
- TRUST.md: [provenance/confidence/next_verification_step to record]

Advisory verdict (machine-readable, non-binding):
CHALLENGE_ADVISORY: SHIP | NEEDS_CHANGES | BLOCK
```

## Integration with AAHP

- This command extends existing machinery; it never forks it. Cross-model review
  already lives in Phase 4 of `.ai/handoff/WORKFLOW.md`, `.claude/agents/reviewer.md`,
  and `.claude/commands/review-cycle.md`. TTL and expiry live in the Trust Decay
  rule in `.claude/rules/aahp-protocol.md`. The mechanical gate is
  `scripts/verify-handoff.sh`.
- After running, the recommended updates should be folded into the next handoff
  under the "Grounded Reflection" section described in
  `.claude/rules/grounded-reflection.md`. `/challenge` writes nothing itself.
- The output of `/challenge` is itself provenance `model_claim` (a model produced it
  and nothing external checked it). Running `/challenge` on a previous challenge
  report does not add grounding and must not be used to self-certify a prior
  challenge result.

## Exit Criteria

A run is complete when it produces:

- At least one serious counterargument
- Explicit hidden assumptions and failure modes
- A Provenance Assessment using only the Axis B tokens above
- A confidence recalibration that references both axes
- Concrete next actions and recommended (not applied) AAHP state updates

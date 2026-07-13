# AI Workflow Improvement Framework: Grounding Register

> Defines which task types require which external anchors before a claim may be
> recorded as grounded (status `verified`). Proposed reference doc for the
> Grounded Reflection Layer; complements `.ai/handoff/TRUST.md`.
> Draft v0.1 - proposed, not yet wired into the running workflow.

This register EXTENDS existing AAHP machinery; it does not fork or replace it.
It reuses the confidence register in `.ai/handoff/TRUST.md`, the Trust Decay rule
in `.claude/rules/aahp-protocol.md`, the cross-model review in
`.ai/handoff/WORKFLOW.md` (Phase 4) plus `.claude/agents/reviewer.md` and
`.claude/commands/review-cycle.md`, and the deterministic gate
`scripts/verify-handoff.sh`. Where those already define a mechanism, this file
points to them instead of restating it.

Placement note: this file lives at `.ai/GROUNDING.md` (a stable policy/reference
doc, like a rule), NOT in `.ai/handoff/`, so it is not part of the MANIFEST
checksum set. Any PR that touches it must still ship a regenerated STATUS.md and
MANIFEST.json via `/handoff` to satisfy the content-drift gate.

---

## 1. The Two Axes

A claim is described on two orthogonal axes. Keep them in separate fields.

### Axis A - Status (grounding confidence). Reused from TRUST.md, not new.

The only status vocabulary is `verified`, `assumed`, `untested` - the same three
levels the TRUST.md Confidence Levels table already defines. In STATUS.md these
render inline as `(Verified)`, `(Assumed)`, `(Unknown)`; treat register
`untested` and STATUS.md `(Unknown)` as the same level.

Grounding shorthand names points on this SAME axis; it does not add levels:

- `grounded` is status `verified` (at least one external anchor confirms it)
- `partially_grounded` is status `assumed` (cross-model reviewed or weak evidence; no external anchor yet)
- `ungrounded` is status `untested` (model-only; nothing external has checked it)

Two lifecycle markers are applied by the Trust Decay rule in
`.claude/rules/aahp-protocol.md` (they are orthogonal to the three levels and are
not provenance values): `expired` (TTL lapsed; auto-downgrades `verified` to
`assumed`) and `rejected` (claim withdrawn; never reuse).

### Axis B - Provenance (how a claim was produced or checked). New, orthogonal field.

Provenance is recorded as a SEPARATE field (`provenance:`), never mixed into the
status. The only provenance vocabulary, weakest to strongest:

`model_claim` < `self_reviewed` < `cross_model_reviewed` < `source_verified` <
`tool_verified` < `test_verified` < `runtime_observed` < `human_confirmed`

- `model_claim` means a model produced it and nothing has checked it. It
  corresponds to status `untested`.
- `self_reviewed` is never final verification for high-impact work.
- `cross_model_reviewed` is provenance only; it maps to status `assumed`, not
  `verified` (consensus is not grounding).
- Only `source_verified`, `tool_verified`, `test_verified`, `runtime_observed`,
  or `human_confirmed` can support status `verified`.

### Axis crosswalk

| Grounding term | Status (register) | STATUS.md tag | Typical provenance |
|---|---|---|---|
| grounded | verified | (Verified) | test_verified / tool_verified / source_verified / runtime_observed / human_confirmed |
| partially_grounded | assumed | (Assumed) | cross_model_reviewed / self_reviewed |
| ungrounded | untested | (Unknown) | model_claim |

---

## 2. Grounding Anchors

A claim may reach status `verified` (grounded) only with at least one external
anchor - something outside the model's own assertion:

- passing tests
- passing build
- passing type-check
- passing lint or static analysis
- schema validation
- a verified external source
- runtime observation
- a deterministic calculation
- human domain-owner confirmation

With no anchor, a claim stays at status `untested` (provenance `model_claim`) or,
if a different provider reviewed it, at status `assumed` (provenance
`cross_model_reviewed`). Model output on its own is not verification.

---

## 3. Task-Type Grounding Matrix

Which anchor a task needs before its central claim can be recorded as grounded
(status `verified`). "Min provenance for verified" is the weakest provenance on
Axis B that can carry that task to `verified`; anything weaker keeps it at
`assumed` or `untested`.

| Task type | Minimum external anchor | Min provenance for verified | Stays below verified if |
|---|---|---|---|
| Code implementation | Passing tests + build + type-check/lint on the change | test_verified | Only self-reviewed, or no tests were actually run |
| Documentation | Doc checked against the source or config it describes | source_verified | Describes code that was never read; model_claim only |
| Architecture decisions | ADR recording alternatives considered, plus human sign-off | human_confirmed | No alternatives weighed; single-model reasoning only |
| Security-sensitive changes | Security scanner or static-analysis output, cross-provider review, human sign-off | tool_verified + human_confirmed | Same model generated and approved it; model reasoning only |
| Compliance or legal claims | Verified external source and human domain-owner confirmation | human_confirmed | No human_confirmed; source not cited or not current |
| External factual research | Two or more independent verified external sources | source_verified | No current source; model_claim only |
| Strategic/business analysis | Human domain-owner confirmation; assumptions labelled | human_confirmed | Rests on model reasoning alone (holds at assumed until a human confirms) |
| Agent-governance changes | `scripts/verify-handoff.sh` passes, cross-model review, human sign-off | tool_verified + human_confirmed | Gate not run; change self-approved by its author |

Notes:

- Cross-model review (Phase 4 in `.ai/handoff/WORKFLOW.md`, `reviewer.md`,
  `/review-cycle`) raises provenance to `cross_model_reviewed`, which maps to
  status `assumed` - it never reaches `verified` on its own.
- For agent-governance changes the deterministic gate is
  `scripts/verify-handoff.sh`; the auditor reasons on top of it and does not
  restate its checks.

---

## 4. Confidence Bands

Confidence is advisory. The load-bearing fields are `status`, `provenance`, and
`evidence`; a number never substitutes for an anchor. When confidence is
recorded, it must carry a `confidence_source` (see the "Confidence Requires a
Source" principle in `.claude/rules/grounded-reflection.md`).

| Confidence | Typical status | Typical provenance |
|---|---|---|
| 0.20 - 0.40 | untested | model_claim (model output only, no anchor) |
| 0.40 - 0.60 | assumed | self_reviewed (plausible, limited evidence) |
| 0.60 - 0.75 | assumed | cross_model_reviewed (no deterministic anchor yet) |
| 0.75 - 0.90 | verified | source_verified / tool_verified / test_verified |
| 0.90 - 0.98 | verified | multiple independent anchors |
| 0.99+ | verified | deterministic or mathematically certain cases only |

A confidence above 0.75 that lacks a matching anchor is a provenance gap: lower
the number or add the anchor.

---

## 5. Required TRUST Fields

A trust record that participates in the Grounded Reflection Layer should carry
these fields. They extend the existing `.ai/handoff/TRUST.md` register rather
than replacing its table; `status`, `ttl`, and `expires` map directly onto the
Status, TTL, and Expires columns already in TRUST.md.

- `id` - stable identifier; never reused
- `claim` - the assertion in one sentence
- `status` - `verified` / `assumed` / `untested` (Axis A)
- `provenance` - strongest achieved value on Axis B
- `generated_by` - agent or model that produced the claim
- `reviewed_by` - reviewing agent or model (a different provider for high-impact work)
- `verified_by` - the anchor or agent that verified it, or null
- `confidence` - optional numeric estimate (see Section 4)
- `confidence_source` - required whenever `confidence` is present
- `evidence` - pointer to the anchor (test run, source, scan, sign-off)
- `ttl` - time-to-live; maps to the TRUST.md TTL column
- `expires` - expiry date; maps to the TRUST.md Expires column
- `owner` - accountable agent or human
- `remaining_uncertainty` - what is still open
- `next_verification_step` - what the next agent should check first

### Example (illustrative, not a live record)

```
id: trust-2026-07-13-001
claim: "The AAHP handoff state is complete enough for the next implementation agent."
status: assumed          # partially_grounded
provenance: cross_model_reviewed
generated_by: implementer
reviewed_by: reviewer
verified_by: null
confidence: 0.68
confidence_source: "cross-provider review; no deterministic anchor run yet"
evidence: "review-cycle notes"
ttl: 7d
owner: handoff-manager
remaining_uncertainty: "no test or gate run against the claim"
next_verification_step: "run scripts/verify-handoff.sh and record tool_verified"
```

---

## 6. TTL and Expiry

This file defines no TTL tables of its own. Time-to-live and expiry are governed
by a single authority:

- The Trust Decay rule in `.claude/rules/aahp-protocol.md` sets the day tiers
  (high-churn build/test properties get short TTLs; stable properties such as
  architecture and conventions get long TTLs) and the rule that an expired
  `verified` claim auto-downgrades to `assumed`.
- The per-row `TTL` and `Expires` columns in `.ai/handoff/TRUST.md` carry the
  actual values for each tracked property.
- `scripts/verify-handoff.sh` enforces TRUST-TTL expiry as one of its layers.

To refresh an expired claim, re-run its anchor and reset the TTL per the Trust
Decay rule; do not invent a new tier here.

---

## 7. Verdicts

Audit and review decisions use the reviewer vocabulary only: `SHIP`,
`NEEDS_CHANGES`, `BLOCK`. This register does not define its own outcome tokens;
the grounding audit that reads it emits those three verdicts. See
`.claude/agents/reviewer.md` and `/review-cycle`.

---

## Cross-References

- `.ai/handoff/TRUST.md` - the confidence register (verified/assumed/untested) and per-row TTL + Expires columns
- `.claude/rules/aahp-protocol.md` - Trust Decay (sole TTL authority)
- `.claude/rules/grounded-reflection.md` - the operating rules for the two axes and grounding requirement
- `.ai/handoff/WORKFLOW.md` (Phase 4) + `.claude/agents/reviewer.md` + `.claude/commands/review-cycle.md` - cross-model review
- `scripts/verify-handoff.sh` - deterministic gate (checksum, content-drift, commit-pointer, TRUST-TTL)

---

*Grounding degrades over time. Re-verify against a live anchor, especially after major changes.*

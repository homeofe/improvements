# Position Paper: From Agentic Engineering to Grounded Reflection Engineering

**Status:** Draft v0.1  
**Project:** AI Workflow Improvement Framework / AAHP  
**Author:** Emre Kohler / Elvatis  
**Purpose:** Governance extension for multi-model AI workflows - structured handoff, critical self-reflection, provenance tracking, and grounded verification.

---

## Scope of This Draft

This document is a proposal. The Grounded Reflection Layer described here is
defined, not yet running. Everything below states what the layer would do, which
files it proposes to add, and how it would extend existing AAHP machinery. Nothing
here should be read as a description of a system already in operation.

The layer extends AAHP; it does not fork or replace it. Where an existing mechanism
already covers a concern, this paper references it rather than restating it:

- Trust Decay and TTL are defined once, in `.claude/rules/aahp-protocol.md`
  (section "Trust Decay"). That rule is the sole TTL authority. The per-row TTL and
  Expires columns already live in `.ai/handoff/TRUST.md`.
- The confidence register is `.ai/handoff/TRUST.md` (status values verified,
  assumed, untested). It is the sole status register.
- Cross-model review already exists: `.ai/handoff/WORKFLOW.md` Phase 4, the reviewer
  agent in `.claude/agents/reviewer.md`, and the `/review-cycle` command in
  `.claude/commands/review-cycle.md`.
- The deterministic gate is `scripts/verify-handoff.sh` (checksum, content-drift,
  commit-pointer, TRUST-TTL). The proposed auditor reasons on top of that gate; it
  never restates or replaces its mechanical checks.

---

## 1. Executive Summary

Modern LLM-based agent workflows are moving from simple "agentic engineering" toward
iterative loop-based systems: generate, review, revise, verify, hand off. This is
useful, but it may be insufficient. Loops can improve outputs only if their
verification steps are anchored outside the same model-family assumptions.
Otherwise, loops may converge toward plausibility rather than toward truth.

This paper proposes "Grounded Reflection Engineering": a governance layer that would
combine multi-model review, adversarial challenge, explicit provenance, randomized
audits, and external verification anchors. The goal is not to prove that an AI system
is internally honest. The goal is to reduce undetected error, hallucination,
manipulation, and circular self-confirmation by making truth claims inspectable,
contestable, and grounded.

---

## 2. Core Thesis

Current LLMs can produce highly capable outputs, but they may not reliably possess
stable, causal, self-correcting world models. A reliable agent workflow therefore
should not depend on model self-reflection alone. It should externalize reflection
into architecture:

1. role separation
2. cross-provider review
3. adversarial challenge
4. external grounding
5. provenance tracking
6. randomized audits
7. explicit uncertainty calibration

### Motivating hypothesis (labelled, not asserted)

The layer is motivated by a hypothesis, not by an established finding:

> Hypothesis (provenance: `model_claim`; status: `untested`): a model's internal
> path to an answer can diverge from its stated answer, so output-level governance
> alone may not catch every error.

This hypothesis is recorded here at its true confidence level. It carries no external
anchor and no citation in this draft, so it stays at status `untested`. It motivates
the design but is not used as proof of anything. The layer is worth building even if
the hypothesis is only partly true, because external grounding helps regardless of a
model's internal mechanics.

---

## 3. Why Loop Engineering Is Not Enough

If the generator and the verifier share the same blind spots, the loop may reinforce
error instead of correcting it. A loop becomes truth-oriented only when at least one
step is grounded outside the model: deterministic tests, compiler or type-checker
output, formal schema validation, reproducible calculations, external source
verification, human domain review, runtime observation, security scanner output, or
real-world feedback. Without such grounding, a loop may only produce consensus among
models, and consensus is not grounding.

---

## 4. Relationship to AAHP

AAHP operates on the state and behavior layer. This proposal would extend it with a
Grounded Reflection Layer that answers:

- What claims were made?
- Which claims are `verified` (grounded by an external anchor)?
- Which claims are only model claims (provenance `model_claim`, status `untested`)?
- Which claims require external evidence before they can move to `verified`?
- Which outputs were challenged adversarially?
- Which agent or tool provided the provenance?
- How long is that verification valid? (governed by the existing Trust Decay rule)
- What uncertainty remains?

Answering these questions does not require new state machinery. It reuses the status
register in `.ai/handoff/TRUST.md` and adds one orthogonal field, provenance, to
record how each claim was produced or checked.

---

## 5. Three-Layer Governance Model

**Layer 1 - Behavioral Governance (What did the agent do?)**
AAHP handoff files, task graph, session log, status dashboard, next actions,
conventions, and pipeline phases. This layer already exists.

**Layer 2 - Reflective Governance (Has the output been challenged?)**
Cross-model review, adversarial challenge, devil's-advocate review, assumption
extraction, failure-mode analysis, alternative-hypothesis testing, and confidence
calibration. Part of this layer already exists as Phase 4 review
(`.ai/handoff/WORKFLOW.md`), the reviewer agent (`.claude/agents/reviewer.md`), and
`/review-cycle`. The proposal would add the adversarial `/challenge` command and the
auditor agent on top of that existing review step.

**Layer 3 - Grounded Governance (Is the claim anchored outside the model?)**
Tests, static analysis, build checks, type checks, schema validation, verified
citations, human approval, runtime logs, security scanners, and deterministic
calculations. A claim reaches status `verified` only through this layer.

---

## 6. Design Principles

### Principle 1: Provenance Before Plausibility

Every important claim should carry a provenance label. Provenance is a separate axis
from status: it records how a claim was produced or checked, weakest to strongest.

`model_claim` < `self_reviewed` < `cross_model_reviewed` < `source_verified` <
`tool_verified` < `test_verified` < `runtime_observed` < `human_confirmed`

A claim that sounds plausible but has no external anchor stays at status `untested`
with provenance `model_claim`. Provenance is recorded as its own field, never mixed
into the status value.

### Principle 2: No Self-Verification as Final Verification

Self-review is real but limited. It is recorded as provenance `self_reviewed` and is
never final verification for high-impact work.

- Invalid final state: `generated_by: model_a` / `verified_by: model_a` /
  `status: verified`.
- Valid final state: `generated_by: model_a` / `reviewed_by: model_b` /
  `verified_by: <deterministic tool or test>` / `status: verified`.

The existing self-review limits are enforced by the operating rules in the proposed
`.claude/rules/grounded-reflection.md`; this paper does not restate them.

### Principle 3: Separate Generator, Reviewer, and Auditor

The implementer creates; the reviewer critiques (Phase 4); the auditor challenges
provenance and grounding; the handoff-manager updates AAHP state; tools verify where
possible. The implementer, reviewer, and handoff-manager already exist in
`.ai/handoff/WORKFLOW.md`. The auditor is the new proposed role.

### Principle 4: Grounding Is Stronger Than Consensus

`cross_model_reviewed` is provenance only. It maps to status `assumed`, not
`verified`. Agreement between two models increases robustness but is not an external
anchor. Only `source_verified`, `tool_verified`, `test_verified`, `runtime_observed`,
or `human_confirmed` can support status `verified`.

### Principle 5: Randomized Audits Reduce Test Gaming

Periodic, non-deterministic audits of grounding claims reduce the incentive to game a
fixed checklist. The auditor is invoked on demand (see Section 7) and may sample
high-impact claims at random.

### Principle 6: Confidence Requires a Source

Do not record a confidence number without its reason.

- Weak: `confidence: 0.92`.
- Better: `confidence: 0.92` / `confidence_source: "unit tests pass, schema valid,
  reviewed by a different provider"`.

---

## 7. Proposed AAHP Extension

The layer proposes the following new files and one extension, all as Draft v0.1:

- `docs/POSITIONPAPER-GROUNDED-REFLECTION.md` - this paper.
- `.ai/GROUNDING.md` - task-type to anchor matrix, confidence bands, and TRUST field
  guidance. It is a stable policy reference (like a rule), not mutable session state,
  so it lives at `.ai/GROUNDING.md` and is outside the handoff checksum set.
- `.claude/rules/grounded-reflection.md` - the operating rules (two axes, grounding
  requirement, self-verification limits, reflection questions, handoff section).
- `.claude/commands/challenge.md` - the `/challenge` adversarial command.
- `.claude/agents/auditor.md` - the auditor agent.
- `.ai/handoff/TRUST.md` - extended with a provenance field and grounding guidance.
- `.llm/PROMPTS-GROUNDED-REFLECTION.md` - reusable reflection prompt templates.

### Auditor placement

The auditor is an on-demand agent, invoked like `/review-cycle`. For high-impact
tasks it may optionally run as a pre-handoff check labelled "Phase 4.5 (optional,
pre-handoff)", before the terminal Phase 5 Handoff. It is not a "Phase 6": Phase 5
Handoff is the final atomic step where `MANIFEST.json` is regenerated and the branch
is pushed, so an audit after it could not gate the commit.

Its scope is grounding and trust-of-claims only: are STATUS and TRUST assertions
actually grounded, are there provenance gaps, is there circular review, is any trust
expired. It is not code review; code review remains Phase 4 (reviewer +
`/review-cycle`) plus the deterministic `scripts/verify-handoff.sh` gate.

The auditor emits the same verdict vocabulary as the reviewer: `SHIP`,
`NEEDS_CHANGES`, or `BLOCK`. It does not introduce a separate verdict scheme.

---

## 8. Critical Self-Reflection Mechanisms

The layer proposes a small set of reflection mechanisms, surfaced through
`/challenge` and the reflection prompt templates:

- Assumption extraction (which assumptions is this output relying on?).
- Adversarial counter-argument ("What is the strongest argument that this output is
  wrong?").
- Alternative-hypothesis testing.
- Evidence separation (Observation / Inference / Assumption / Recommendation).
- Confidence calibration against the bands in `.ai/GROUNDING.md`.
- Decision journaling.

---

## 9. The Two Axes: Status and Provenance

The layer uses exactly two axes. It adds no new status levels.

### Axis A - Status (grounding confidence), reused from TRUST.md

The only status values are `verified`, `assumed`, and `untested`. In `STATUS.md` they
render inline as `(Verified)`, `(Assumed)`, and `(Unknown)`; register `untested` and
`STATUS.md` `(Unknown)` are the same level. The grounding shorthand terms are named
points on this same axis, not new levels:

- `grounded` == status `verified` (at least one external anchor confirms it)
- `partially_grounded` == status `assumed` (cross-model reviewed or weak evidence; no
  external anchor yet)
- `ungrounded` == status `untested` (model only; nothing has checked it)

Lifecycle markers are applied by the existing Trust Decay rule and are orthogonal to
the three status levels: `expired` (TTL lapsed; auto-downgrades `verified` to
`assumed`) and `rejected` (claim withdrawn; the id is never reused). TTL policy is not
defined here; it lives in `.claude/rules/aahp-protocol.md`.

### Axis B - Provenance (how a claim was produced or checked), new field

Provenance is recorded as a separate field, weakest to strongest:

`model_claim` < `self_reviewed` < `cross_model_reviewed` < `source_verified` <
`tool_verified` < `test_verified` < `runtime_observed` < `human_confirmed`

- `self_reviewed` is never final verification for high-impact work.
- `cross_model_reviewed` is provenance only; it maps to status `assumed`, not
  `verified`.
- Only `source_verified`, `tool_verified`, `test_verified`, `runtime_observed`, or
  `human_confirmed` can support status `verified`.
- The single token for "a model produced it and nothing checked it" is `model_claim`,
  which corresponds to status `untested`.

### Axis-crosswalk table

| Grounding term | Status (register) | STATUS.md tag | Typical provenance |
|---|---|---|---|
| grounded | verified | (Verified) | test_verified / tool_verified / source_verified / runtime_observed / human_confirmed |
| partially_grounded | assumed | (Assumed) | cross_model_reviewed / self_reviewed |
| ungrounded | untested | (Unknown) | model_claim |

---

## 10. Recommended Workflow

A high-impact implementation task would flow as follows. Existing steps are reused;
only the challenge and audit steps are new.

1. The implementer creates the change.
2. Tests, build, and type-checker run (external anchors).
3. A reviewer from a different model or provider reviews (Phase 4; verdict `SHIP`,
   `NEEDS_CHANGES`, or `BLOCK`).
4. `/challenge` runs against assumptions and edge cases.
5. For high-impact work, the auditor optionally runs as Phase 4.5 and checks
   provenance and grounding.
6. `.ai/handoff/TRUST.md` is updated with status and provenance per claim.
7. The AAHP handoff (Phase 5, via `/handoff`) records remaining uncertainty and
   regenerates `MANIFEST.json`.

Research and strategic or business tasks follow the same shape, with human
confirmation (`human_confirmed`) or source verification (`source_verified`) as the
grounding anchor instead of tests.

---

## 11. Success Criteria

The layer would be working if, over time:

- Fewer model-only claims are labelled `verified`.
- Review records distinguish plausibility from proof.
- Assumptions are exposed consistently.
- High-impact tasks carry stronger grounding.
- Stale trust records are detected earlier (via the existing Trust Decay rule).
- Cross-model agreement is no longer confused with truth.

---

## 12. Final Position

The direction is from structured handoff to grounded reflection. Truth has to be
earned through explicit evidence, adversarial pressure, external grounding, and
accountable state transitions. This paper is Draft v0.1: it proposes the vocabulary,
the two axes, and the file set, and it invites review before any of the proposed
files are treated as normative.

---

## Version History

| Version | Date | Notes |
|---|---:|---|
| v0.1 | 2026-07-13 | Initial draft. Two-axis status and provenance model, hedged core thesis, labelled motivating hypothesis, auditor as optional Phase 4.5, proposed file set. |

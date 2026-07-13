# Grounded Reflection Prompt Templates

> Status: Draft v0.1 (proposed). Provider-agnostic reflection prompts for the
> proposed Grounded Reflection Layer. Copy and adapt for any LLM. These templates
> extend, and never replace, existing AAHP machinery - route cross-model review
> through Phase 4 (`.claude/agents/reviewer.md` + `.claude/commands/review-cycle.md`),
> read trust state from `.ai/handoff/TRUST.md`, let Trust Decay / TTL stay owned by
> `.claude/rules/aahp-protocol.md` (section "Trust Decay"), and leave the mechanical
> gate to `scripts/verify-handoff.sh`.

## Canonical vocabulary (use these tokens only)

Every prompt below stays inside one shared vocabulary. Do not invent synonyms.

- Status (grounding confidence): `verified`, `assumed`, `untested`. In STATUS.md
  these render as `(Verified)`, `(Assumed)`, `(Unknown)`. The grounding shorthand
  `grounded` / `partially_grounded` / `ungrounded` are named points on this SAME
  axis, not new levels.
- Provenance (how a claim was produced or checked), weakest to strongest:
  `model_claim` < `self_reviewed` < `cross_model_reviewed` < `source_verified` <
  `tool_verified` < `test_verified` < `runtime_observed` < `human_confirmed`.
- Verdict (audit or review decision): `SHIP`, `NEEDS_CHANGES`, `BLOCK` (same set as
  `.claude/agents/reviewer.md`).

Paste this crosswalk into any prompt that shows a mapping:

| Grounding term | Status (register) | STATUS.md tag | Typical provenance |
|---|---|---|---|
| grounded | verified | (Verified) | test_verified / tool_verified / source_verified / runtime_observed / human_confirmed |
| partially_grounded | assumed | (Assumed) | cross_model_reviewed / self_reviewed |
| ungrounded | untested | (Unknown) | model_claim |

Note: `expired` and `rejected` are lifecycle markers applied by the Trust Decay
rule, not status levels and not provenance values. `unverified` is plain-English
prose, never a status value - the status for "nothing checked it" is `untested`.

## 1. Assumption Extraction

Use to surface what an output silently relies on before trusting it.

```
List every assumption the output below depends on. Do not evaluate the output
yet - only extract assumptions.

For each assumption, return a row:
| Assumption | Status | Load-bearing? | Needs external anchor? | Why |

Rules:
- Status is exactly one of: verified, assumed, untested.
  - verified = an external anchor already confirms it (test/build/type-check/lint,
    schema validation, verified source, runtime observation, human confirmation).
  - assumed = only cross-model reviewed or weak evidence; no external anchor yet.
  - untested = model reasoning only, nothing has checked it.
- Load-bearing? = would the conclusion collapse if this assumption were false?
- Needs external anchor? = yes if it is load-bearing and not yet verified.

End with: the single most dangerous assumption (load-bearing + untested) and the
one external check that would most reduce risk.

Output to review:
[PASTE OUTPUT / DECISION / CLAIM]
```

## 2. Strongest Counterargument

Reverses the burden of proof. Pairs with the proposed `/challenge` command.

```
Do not defend the output below. Argue against it.

Question to answer: what is the strongest reason this output is wrong, incomplete,
or unsafe to rely on?

Return:
1. Strongest counterargument (the best case that this is wrong)
2. Hidden assumptions the output depends on
3. Failure modes (concrete inputs/conditions where it breaks)
4. Evidence gaps (what is claimed but not shown)
5. Alternative explanations or solutions
6. Required external checks (which grounding anchor would settle it: test, build,
   type-check, lint/static analysis, schema validation, verified source, runtime
   observation, deterministic calculation, or human domain-owner confirmation)
7. Confidence recalibration: original confidence -> adjusted confidence + reason

If you cannot produce at least one serious counterargument, say so explicitly and
explain why the output is hard to fault.

Output to challenge:
[PASTE OUTPUT / DECISION / CLAIM]
```

## 3. Provenance Classification

Assigns each claim a provenance token so plausibility is not confused with proof.

```
Classify each claim in the material below by how it was actually produced or
checked. Use ONLY these provenance tokens (weakest to strongest):

model_claim, self_reviewed, cross_model_reviewed, source_verified, tool_verified,
test_verified, runtime_observed, human_confirmed

Do not invent other tokens. If a claim was produced by a model and nothing has
checked it, the provenance is model_claim.

Return a table:
| Claim | Current provenance | Required provenance | Gap | Recommended next action |

Then map provenance to status using this crosswalk:

| Grounding term | Status (register) | STATUS.md tag | Typical provenance |
|---|---|---|---|
| grounded | verified | (Verified) | test_verified / tool_verified / source_verified / runtime_observed / human_confirmed |
| partially_grounded | assumed | (Assumed) | cross_model_reviewed / self_reviewed |
| ungrounded | untested | (Unknown) | model_claim |

Reminders:
- self_reviewed is never final verification for high-impact work.
- cross_model_reviewed maps to status assumed, not verified (consensus is not
  grounding).
- Only source_verified / tool_verified / test_verified / runtime_observed /
  human_confirmed can support status verified.

Material to classify:
[PASTE CLAIMS / OUTPUT / TRUST.md ROWS]
```

## 4. Grounding Gap

Finds the shortest path from a model-only claim to a grounded one.

```
For the claim below, identify what is missing before it can be recorded as
grounded (status verified).

Answer:
1. Current status (verified / assumed / untested) and current provenance token
2. What "grounded" would require here: name at least one concrete external anchor
   (passing tests, passing build, passing type-check, passing lint/static analysis,
   schema validation, verified external source, runtime observation, deterministic
   calculation, or human domain-owner confirmation)
3. The grounding gap: the exact difference between now and grounded
4. Cheapest sufficient check that closes the gap
5. If no external anchor is achievable, state that the claim stays at
   status: assumed / provenance: cross_model_reviewed at best, and must remain
   visibly not-yet-grounded

Do not mark anything verified on model judgment alone.

Claim:
[PASTE CLAIM]
```

## 5. Confidence Calibration

Forces every confidence number to name its source.

```
Recalibrate the confidence attached to the claim below.

Return:
- claim
- status: verified / assumed / untested
- provenance: one token from the canonical set
- confidence: a value in [0, 1]
- confidence_source: the evidence the number rests on (e.g. "unit tests pass,
  schema valid, reviewed by a different provider"). If the only basis is model
  judgment, write confidence_source: model_reasoning_only.

Constraints:
- A confidence number without a confidence_source is invalid - do not emit one.
- High confidence with provenance model_claim is a red flag; lower it or ground it.
- For the numeric bands (which confidence range fits which evidence), follow the
  proposed .ai/GROUNDING.md calibration table rather than guessing here.

Claim:
[PASTE CLAIM + ANY STATED CONFIDENCE]
```

## 6. Circular Review Detection

Checks whether a claim was blessed by the same source that produced it.

```
Inspect the provenance chain for the claim below and decide whether the review was
circular.

A review is circular when the generator and the verifier share the same blind spot,
for example:
- generated_by and verified_by are the same model or model family
- self_reviewed is used as final verification for high-impact work
- cross_model_reviewed is treated as status verified (it maps to assumed only)
- the only evidence is model agreement, with no external anchor

Return:
- generated_by / reviewed_by / verified_by (as recorded)
- Circular? yes / no, with the specific reason
- If yes: what independent step breaks the circle (a different provider via Phase 4
  cross-model review, or an external anchor from tests/build/tools/source/runtime/
  human)
- Resulting honest status and provenance after the circle is accounted for

Cross-model review itself runs through Phase 4 (.claude/agents/reviewer.md +
.claude/commands/review-cycle.md); this prompt only detects the circularity, it does
not replace that review.

Provenance chain:
[PASTE generated_by / reviewed_by / verified_by / status / provenance]
```

## 7. Human Escalation

Decides when a claim must leave the model loop and reach a human owner.

```
Decide whether the item below must be escalated to a human domain owner before it
can be relied on.

Escalate (human_confirmed required) when the item is any of: security-sensitive,
financial, legal, compliance, an architecture decision, public documentation,
external communication, production configuration, or a claim about current external
facts that no available tool or source can settle.

Return:
- Escalate? yes / no
- Category that triggers it (or "none")
- What exactly the human must confirm (a specific, answerable question)
- Interim status until confirmed: assumed or untested (never verified)
- Interim provenance token
- What the workflow may and may not do while waiting on confirmation

Do not record status verified via provenance human_confirmed until a human has
actually confirmed it.

Item:
[PASTE CLAIM / DECISION / CHANGE]
```

## 8. AAHP Grounded Handoff

Produces the "Grounded Reflection" block for a handoff, sorted by grounding.

```
Write the Grounded Reflection section for this session's AAHP handoff. Sort claims
by grounding using the canonical crosswalk (grounded=verified, partially_grounded=
assumed, ungrounded=untested).

Format:

## Grounded Reflection

**Grounded Claims (status: verified)**
- [claim] - provenance: [token] - anchor: [test/build/tool/source/runtime/human]

**Partially Grounded Claims (status: assumed)**
- [claim] - provenance: cross_model_reviewed | self_reviewed - what is still missing

**Ungrounded Claims (status: untested)**
- [claim] - provenance: model_claim - not yet checked by anything external

**Assumptions**
- [load-bearing assumptions the work depends on]

**Counterarguments**
- [strongest reasons the work could be wrong]

**Required External Checks**
- [the anchors the next agent should obtain first]

**Residual Risk**
- [what remains uncertain and its impact]

**TRUST.md Updates**
- [rows to add or change in .ai/handoff/TRUST.md]

Rules:
- Put a claim under Grounded only if it has at least one external anchor.
- cross_model_reviewed stays under Partially Grounded, never Grounded.
- Do NOT restate TTL or expiry tiers here - TRUST.md carries per-row TTL/Expires and
  the Trust Decay rule in .claude/rules/aahp-protocol.md owns decay.

Session work to summarize:
[DESCRIBE WHAT WAS DONE + KEY CLAIMS]
```

## 9. Auditor Invocation

Frames a grounding-and-trust audit and asks for a reviewer.md-style verdict.

```
Act as the grounding auditor for this handoff (see the proposed
.claude/agents/auditor.md). Scope is grounding and trust-of-claims ONLY: are the
STATUS.md / TRUST.md assertions actually grounded, are there provenance gaps, is any
review circular, is any relied-on trust expired? This is NOT code review - that is
Phase 4 (reviewer.md + /review-cycle) and the mechanical gate scripts/verify-handoff.sh.

Read (read-only): .ai/handoff/MANIFEST.json, STATUS.md, NEXT_ACTIONS.md, LOG.md,
DASHBOARD.md, TRUST.md, plus the proposed .ai/GROUNDING.md and
.claude/rules/grounded-reflection.md.

Return:
- Scope and state files reviewed
- Key findings
- Provenance issues (table: claim | recorded provenance | required provenance | gap)
- Expired or weak trust records (defer TTL judgment to the Trust Decay rule)
- Circular review risks
- Required grounding actions
- Confidence assessment

End with exactly one verdict line, using ONLY this set:
- SHIP: claims grounded, provenance present, no expired critical trust
- NEEDS_CHANGES: some claims only partially_grounded, provenance gaps, follow-up needed
- BLOCK: a high-impact claim is ungrounded, circular review found, or it cannot be assessed

Final line format:
AUDIT_VERDICT: SHIP | NEEDS_CHANGES | BLOCK
```

## 10. Decision Journal

Captures a decision with its evidence so it can be re-audited later.

```
Record this decision as a journal entry that a later agent can re-audit.

Format:
- decision: [what was decided]
- date: [ISO-8601]
- decided_by: [model or human]
- options_considered: [alternatives + why rejected]
- evidence: [what supports the decision]
- status: verified / assumed / untested
- provenance: [one canonical token]
- confidence + confidence_source
- assumptions: [what must stay true for this to hold]
- revisit_when: [condition or trust expiry that should trigger re-evaluation;
  let the Trust Decay rule and TRUST.md carry the actual TTL]
- residual_risk: [what could still be wrong]

Keep it honest: if the decision rests on model judgment alone, say status: untested
/ provenance: model_claim rather than overclaiming.

Decision to journal:
[DESCRIBE THE DECISION]
```

## Usage Notes

- These prompts are proposed (Draft v0.1) and provider-agnostic. Adapt the
  [BRACKETED SECTIONS] for your specific use case.
- Keep the vocabulary fixed: status = verified / assumed / untested; the 8 provenance
  tokens listed above; verdicts = SHIP / NEEDS_CHANGES / BLOCK. Do not add synonyms.
- Route cross-model review through Phase 4 (`.claude/agents/reviewer.md` +
  `.claude/commands/review-cycle.md`), and prefer a different provider than the
  implementer per `.llm/ROUTING.md`.
- Trust state lives in `.ai/handoff/TRUST.md`; TTL and decay are owned by the
  "Trust Decay" section of `.claude/rules/aahp-protocol.md`; the mechanical gate is
  `scripts/verify-handoff.sh`. These prompts reason on top of that machinery, they do
  not restate or replace it.
- For Claude Code these can back custom commands (for example the proposed
  `.claude/commands/challenge.md`); for other tools, copy-paste and adapt.

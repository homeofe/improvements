# AI Workflow Improvement Framework: Multi-Model Agent Pipeline

> Based on the [AAHP Protocol](https://github.com/homeofe/AAHP).
> Enhanced with multi-model routing from `.llm/ROUTING.md`.
> Agents read `handoff/DASHBOARD.md` and work autonomously.

---

## Agent Roles (Model-Routed)

| Agent | Primary Model | Fallback | Role | Responsibility |
|-------|--------------|----------|------|---------------|
| Researcher | Perplexity sonar-pro | Gemini + search | Research | OSS research, compliance, doc review |
| Architect | Claude Opus / GPT-4 | Grok reasoning | Design | System design, ADRs, interfaces |
| Implementer | Claude Sonnet / Codex | Gemini Flash | Build | Code, tests, refactoring, commits |
| Reviewer | Different provider | - | Review | Second opinion, security, edge cases |
| Handoff Manager | Haiku | Local LLM | State | MANIFEST.json, checksums, task lifecycle |

> **Key rule**: Reviewer must use a different model family than Implementer.
> See `.llm/ROUTING.md` for the full decision matrix.

---

## The Pipeline

### Phase 1: Research & Context (Researcher Agent)

```
Model:   Perplexity sonar-pro (web-grounded) or Gemini (large context)
Reads:   handoff/NEXT_ACTIONS.md (top unblocked task)
         handoff/STATUS.md (current project state)

Does:    Researches relevant OSS libraries / APIs / compliance
         Checks whether similar solutions already exist
         Clarifies ambiguities in the task

Writes:  handoff/LOG.md - research findings + sources + recommendation

MCP tools (if available):
  - perplexity_run: deep research with citations
  - gemini_run: large document analysis
  - grok_run: real-time knowledge
```

### Phase 2: Architecture Decision (Architect Agent)

```
Model:   Claude Opus or GPT-4 (high reasoning)
Reads:   Research output from LOG.md
         handoff/STATUS.md
         Relevant source files, config, docs

Does:    Decides architecture and interface design
         Chooses branch name
         Defines implementation instructions

Writes:  handoff/LOG.md - ADR (Architecture Decision Record)

ADR format:
  ## [DATE] ADR: [Feature Name]
  **Decision:** ...
  **Rationale:** ...
  **Consequences:** ...
  **Branch:** feat/...
  **Instructions for Implementer:** [numbered steps]
```

### Phase 3: Implementation (Implementer Agent)

```
Model:   Claude Sonnet or Codex (fast coding)
Reads:   ADR from LOG.md
         CONVENTIONS.md (MANDATORY before first commit)

Does:    Creates feature branch: git checkout -b feat/<scope>-<name>
         Writes code + unit tests
         Runs tests and type-check
         Commits and pushes branch

Branch convention:
  feat/<scope>-<short-name>    - new feature
  fix/<scope>-<short-name>     - bug fix
  docs/<scope>-<name>          - documentation only

Commit format:
  feat(scope): description [AAHP-auto]
  fix(scope): description [AAHP-fix]
```

### Phase 4: Cross-Model Review (Reviewer Agent)

```
Model:   DIFFERENT provider than Phase 3
         e.g., if Sonnet implemented -> GPT-4 reviews
         e.g., if Codex implemented -> Opus reviews

All agents review the completed code:
  Architect  - "Does the implementation match the ADR?"
  Reviewer   - "What could be more robust, simpler, or more secure?"
  Researcher - "Were all task items fulfilled? Any compliance concerns?"

Outcome:
  - Minor fixes - Implementer fixes in the same branch
  - Larger issues - New tasks added to NEXT_ACTIONS.md / DASHBOARD.md
  - Everything documented in LOG.md

MCP tools (if available):
  - akido_review_diff: automated diff analysis
  - akido_review_selection: specific code review
```

### Phase 5: Handoff (Handoff Manager Agent)

```
Model:   Haiku or local LLM (simple state management)

Updates:
  DASHBOARD.md:    Build status, test counts, pipeline state
  STATUS.md:       Changed system state (Verified / Assumed / Unknown)
  LOG.md:          Session summary appended
  NEXT_ACTIONS.md: Completed task checked off, new tasks added
  MANIFEST.json:   Checksums, task graph, quick_context regenerated

Git:     Branch pushed, PR-ready
Notify:  Project owner - only on fully completed tasks
         Format: "[Feature] done - Branch: feat/... - Tests: X/X"
```

---

## Autonomy Boundaries

| Allowed | Not allowed |
|---------|------------|
| Write & commit code | Push directly to `main` |
| Write & run tests | Install new dependencies without documenting |
| Push feature branches | Write secrets or PII into source |
| Research & propose OSS libraries | Call external APIs without credentials |
| Make architecture decisions | Perform production deployments |
| Route to different models | Bypass cross-model review for critical code |
| Use MCP tools for research | Send sensitive data to external models |

---

## Task Selection Rules

1. Read `MANIFEST.json` tasks, filter where `status = "ready"`
2. Verify all `depends_on` tasks have `status = "done"`
3. Sort by priority: critical > high > medium > low
4. Take the top eligible task
5. If all tasks are blocked - notify the project owner, pause
6. Never start a task without reading `STATUS.md` first
7. After completing a task - always run handoff (Phase 5)

---

## Error Handling

If an agent fails or is uncertain:
- Mark task as `(Unknown)` in `STATUS.md`
- Document the specific blocker in `LOG.md`
- Notify the project owner
- **Never proceed on assumptions when certainty is missing**

---

## Model Routing Quick Reference

| When you need... | Use this | MCP tool |
|-----------------|---------|----------|
| Web-grounded facts | Perplexity | `perplexity_run` |
| Large file analysis | Gemini Pro | `gemini_run` |
| Hard reasoning | Opus / GPT-4 | native or `chatgpt_run` |
| Fast coding | Sonnet / Codex | native or `codex_run` |
| Real-time knowledge | Grok | `grok_run` |
| Free/private tasks | Local LLM | `local_llm_run` |
| Multi-step automation | OpenClaw | `openclaw_run` |

See `.llm/ROUTING.md` for the full decision matrix.

---

*This document lives in the repo and is continuously refined by the agents themselves.*

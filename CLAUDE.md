# AI Workflow Improvement Framework

> A portable framework for improving daily AI-assisted work using multiple LLM providers and the AAHP handoff protocol.

## Project Overview

- **Purpose**: Design and document best practices for using AI (any LLM) in daily development work
- **Protocol**: Uses [AAHP v3](https://github.com/homeofe/AAHP) for structured multi-agent handoff
- **Scope**: LLM-agnostic - Claude, GPT, Gemini, Grok, Perplexity, local models

## Quick Start (Every Session)

1. Read `.ai/handoff/MANIFEST.json` for project state
2. Check `quick_context` field for orientation
3. Consult `.llm/ROUTING.md` when choosing which model to use for a task
4. Follow AAHP protocol rules in `.claude/rules/aahp-protocol.md`

## Key File Locations

| What | Where |
|------|-------|
| AAHP handoff state | `.ai/handoff/` |
| Model routing guide | `.llm/ROUTING.md` |
| Provider capabilities | `.llm/PROVIDERS.md` |
| Reusable prompts | `.llm/PROMPTS.md` |
| Workflow patterns | `.llm/PATTERNS.md` |
| Project conventions | `.ai/handoff/CONVENTIONS.md` |
| Agent pipeline | `.ai/handoff/WORKFLOW.md` |

## Conventions

- English only (code, comments, docs, commits)
- No em dashes (use hyphens instead)
- AAHP protocol compliance for all handoff operations
- Conventional commits: `feat(scope): description [AAHP-auto]`
- Always update AAHP state files at end of session (use `/handoff`)

## Custom Commands

- `/handoff` - Complete AAHP handoff cycle (update state, log, manifest)
- `/route <task>` - Get model routing recommendation for a task
- `/status` - Display AAHP project health dashboard
- `/next` - Pick and start the next ready AAHP task
- `/review-cycle` - Run multi-model review on recent changes

## Multi-Model Strategy

When working on this project, consider routing tasks to the best model:
- **Research**: Perplexity (web-grounded), Gemini 3.1 Pro (very large context)
- **Architecture**: Opus 4.8, GPT-5.4 (hard reasoning)
- **Implementation**: Sonnet 4.6, Codex (fast coding)
- **Review**: Use a different provider than the implementer
- **Quick tasks**: Haiku 4.5, GPT-5.4 Mini, local LLM

See `.llm/ROUTING.md` for the full decision matrix.

## AAHP Protocol

This project uses AAHP v3 for structured handoff between AI agents. Key rules:
- Always read `MANIFEST.json` before starting work
- Update handoff files atomically (all or nothing)
- Never reuse task IDs
- Mark trust claims with TTL
- See `.claude/rules/aahp-protocol.md` for full protocol

## AAHP Verify Gate

This framework ships the canonical handoff gate, `scripts/verify-handoff.sh`
(`aahp verify`). It runs 4 layers: MANIFEST checksum integrity, the content-drift
gate (any source change outside `.ai/handoff/` must include `STATUS.md` AND a
regenerated `MANIFEST.json`, else hard-fail), commit-pointer freshness, and
TRUST-TTL expiry. Wire it locally once:

```bash
bash scripts/install-hooks.sh .     # installs pre-commit + pre-push hooks
```

- The gate is verify-only; it never regenerates `MANIFEST.json`. Run `/handoff`
  to refresh `STATUS.md` + `MANIFEST.json`, then commit.
- Escape hatch `AAHP_SKIP_VERIFY=1` skips LOCAL verification only and is caught
  by the required CI check (`aahp verify --level ci`). Do NOT use it to bypass
  CI. Never use `git commit/push --no-verify`.
- The CI workflow `.github/workflows/aahp-verify.yml` is committed but inert
  until GitHub Actions is re-enabled org-wide.

## Style Rules

- Never use em dashes (the U+2014 character) in any content: documentation, markdown, README, code comments, GitHub issue titles, or handoff files. Use a plain hyphen (-) instead.
- When reviewing existing files, scan for em dashes and replace them.
- Applies to all .md files, HTML templates, comments, and .ai/handoff files.
- If an AI tool auto-inserts em dashes (e.g. "Title - Subtitle"), fix before committing.

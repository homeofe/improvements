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
- **Research**: Perplexity (web-grounded), Gemini (large context)
- **Architecture**: Opus, GPT-4 (hard reasoning)
- **Implementation**: Sonnet, Codex (fast coding)
- **Review**: Use a different provider than the implementer
- **Quick tasks**: Haiku, GPT-4-mini, local LLM

See `.llm/ROUTING.md` for the full decision matrix.

## AAHP Protocol

This project uses AAHP v3 for structured handoff between AI agents. Key rules:
- Always read `MANIFEST.json` before starting work
- Update handoff files atomically (all or nothing)
- Never reuse task IDs
- Mark trust claims with TTL
- See `.claude/rules/aahp-protocol.md` for full protocol

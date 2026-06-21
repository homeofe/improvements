# AI Workflow Improvement Framework

[![AAHP Verify](https://github.com/homeofe/improvements/actions/workflows/aahp-verify.yml/badge.svg)](https://github.com/homeofe/improvements/actions/workflows/aahp-verify.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

> A portable framework for improving daily AI-assisted development work. LLM-agnostic, built on the [AAHP Protocol](https://github.com/homeofe/AAHP).

---

## What is This?

A ready-to-copy framework that you drop into any project to get:

- **Multi-model routing** - Decision matrix for choosing the right LLM for each task
- **AAHP integration** - Structured handoff between AI agents (98% token reduction vs. raw chat history)
- **Custom agents** - Pre-configured agents for research, architecture, implementation, and review
- **Custom commands** - `/handoff`, `/status`, `/next`, `/route`, `/review-cycle`
- **Cross-model review** - Implement with one provider, review with another
- **Cost-aware escalation** - Start cheap, escalate only when quality demands it

## Who is This For?

Developers who use AI tools daily and want to:
- Work with multiple LLM providers efficiently (Claude, GPT, Gemini, Grok, Perplexity, local models)
- Stop wasting tokens on context duplication across agent sessions
- Enforce quality patterns (cross-model review, safety rules, conventions)
- Have a structured workflow instead of ad-hoc prompting

## Framework Architecture

```
your-project/
  CLAUDE.md                    # Project entry point (loaded every session)
  .claude/
    settings.json              # Permissions and hooks
    rules/
      aahp-protocol.md         # AAHP health check, layered reads, atomic handoff
      multi-model.md            # Model routing decision tree
      safety.md                 # Three Laws + do-no-damage enforcement
      handoff.md                # How to read/write AAHP state files
    agents/
      researcher.md             # Phase 1: Research (Perplexity/Gemini)
      architect.md              # Phase 2: Architecture (Opus/GPT-5.4)
      implementer.md            # Phase 3: Implementation (Sonnet/Codex)
      reviewer.md               # Phase 4: Review (cross-model)
      handoff-manager.md        # Phase 5: State management (Haiku)
    commands/
      handoff.md                # /handoff - End-of-session AAHP cycle
      route.md                  # /route - Model recommendation for a task
      status.md                 # /status - Project health dashboard
      next.md                   # /next - Pick next ready task
      review-cycle.md           # /review-cycle - Multi-model review
  .llm/
    ROUTING.md                  # Task-to-model decision matrix
    PROVIDERS.md                # Provider capabilities comparison
    PATTERNS.md                 # 8 cross-LLM workflow patterns
    PROMPTS.md                  # 8 reusable prompt templates
  .ai/handoff/
    MANIFEST.json               # AAHP v3 index + task graph
    STATUS.md                   # Current project state
    NEXT_ACTIONS.md             # Active tasks (max 5)
    LOG.md                      # Session journal
    DASHBOARD.md                # Build health + pipeline state
    CONVENTIONS.md              # Project coding standards
    WORKFLOW.md                 # Agent pipeline definition
    TRUST.md                    # Verification register with TTL
```

## Quick Start

See **[INTEGRATION.md](INTEGRATION.md)** for the full step-by-step guide.
To understand how this framework is built and why (a build-it-yourself walkthrough), see **[docs/BUILDING-THE-FRAMEWORK.md](docs/BUILDING-THE-FRAMEWORK.md)**.

```bash
# Clone and copy to your project
git clone https://github.com/homeofe/improvements.git /tmp/ai-framework
cp -r /tmp/ai-framework/.claude/ /tmp/ai-framework/.llm/ /tmp/ai-framework/.ai/ your-project/
cp /tmp/ai-framework/CLAUDE.md your-project/
rm -rf /tmp/ai-framework

# Adapt CLAUDE.md for your project, then commit
cd your-project
git add .claude/ .llm/ .ai/ CLAUDE.md
git commit -m "feat(framework): integrate AI workflow framework"
```

## Key Concepts

### Multi-Model Routing

Don't use Opus for everything. The framework includes a routing decision tree:

| Task Type | Recommended Model | Cost Tier |
|-----------|------------------|-----------|
| Web research | Perplexity / Grok | Low |
| Large file analysis | Gemini 3.1 Pro (very large context, 1M+ tokens) | Medium |
| Architecture | Opus / GPT-5.4 | High |
| Code implementation | Sonnet / Codex | Medium |
| Code review | Different provider than implementer | Medium |
| Quick formatting | Haiku / local LLM | Very Low |

### Cross-Model Review

The most important quality pattern: **implement with Model A, review with Model B**. Different model families have different blind spots. Cross-provider review catches issues that same-model review misses.

### AAHP Protocol

The framework uses AAHP v3 for structured handoff between AI agents. Instead of passing full conversation history (expensive, noisy), agents exchange compact state files. This reduces token consumption by 87-98%.

### Cost-Aware Escalation

```
Local LLM (free) -> Haiku ($0.05) -> Sonnet ($0.30) -> Opus ($1.50) -> Multi-model ($3.00+)
```

Start with the cheapest model that can handle the task. Escalate only when the output quality is insufficient.

## Custom Commands

| Command | What It Does |
|---------|-------------|
| `/handoff` | Complete AAHP handoff cycle (update state, log, manifest, commit) |
| `/status` | Display project health dashboard from AAHP state |
| `/next` | Pick and start the next ready task from the task graph |
| `/route <task>` | Get model routing recommendation for a task |
| `/review-cycle` | Run multi-model review on recent changes |

## Custom Agents

| Agent | AAHP Phase | Default Model | Purpose |
|-------|-----------|--------------|---------|
| researcher | Phase 1 | Sonnet | Research, OSS evaluation, context gathering |
| architect | Phase 2 | Opus | System design, ADRs, implementation planning |
| implementer | Phase 3 | Sonnet | Code, tests, documentation |
| reviewer | Phase 4 | Opus | Cross-model code review, security analysis |
| handoff-manager | Phase 5 | Haiku | AAHP state management, checksums |

## LLM-Agnostic Layer

The `.llm/` directory contains provider-neutral documentation that works with any AI tool:

- **ROUTING.md** - The model routing decision matrix
- **PROVIDERS.md** - Capabilities comparison (context windows, tools, cost, best uses)
- **PATTERNS.md** - 8 workflow patterns that work across all LLMs
- **PROMPTS.md** - 8 reusable prompt templates you can copy into any tool

These files are useful even if you don't use Claude Code.

## Related Projects

- [AAHP Protocol](https://github.com/homeofe/AAHP) - The underlying handoff protocol specification
- [akido-mcp](https://github.com/homeofe/akido-mcp) - MCP server with multi-LLM routing tools

---

## License

**Copyright 2026 Emre Kohler (Elvatis)**
Licensed under the [MIT License](LICENSE). Use, copy, modify, and distribute freely,
including for commercial purposes. The only condition is keeping the license notice.

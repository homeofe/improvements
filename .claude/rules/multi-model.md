# Multi-Model Routing Rules

## Decision Tree

When deciding which model to use, follow this routing logic:

### 1. What type of task is it?

| Task Type | Primary Model | Fallback | Cost Tier |
|-----------|--------------|----------|-----------|
| Web research, fact-checking | Perplexity sonar-pro | Gemini with search | Low |
| Deep research with citations | Perplexity sonar-deep-research | Grok (web-grounded) | Medium |
| Architecture, system design | Claude Opus 4.8 / GPT-5.4 | Grok reasoning | High |
| Code implementation | Claude Sonnet 4.6 / Codex | Gemini 3.5 Flash | Medium |
| Code review (security) | Claude Opus 4.8 | GPT-5.4 | High |
| Code review (general) | Different provider than implementer | - | Medium |
| Quick formatting, classification | Haiku 4.5 / GPT-5.4 Mini / local LLM | - | Very Low |
| Large file analysis (>100K tokens) | Gemini 3.1 Pro (1M+ context) | Claude Opus 4.8 (1M) | Medium |
| Creative writing, brainstorming | Claude Opus 4.8 / GPT-5.4 | Grok | Medium |
| Data extraction, parsing | Local LLM / Haiku 4.5 | GPT-5.4 Mini | Very Low |

### 2. Cost-Aware Escalation

Start with the cheapest model that can handle the task. Escalate only when:
- The cheaper model produces incorrect or incomplete results
- The task requires reasoning beyond the model's capability
- Security or safety concerns demand higher accuracy

**Escalation path**: Local LLM -> Haiku 4.5 -> Sonnet 4.6/GPT-5.4 Mini -> Opus 4.8/GPT-5.4 -> Multi-model consensus

### 3. Cross-Model Verification Pattern

For critical decisions, use two different providers:
- Implement with Provider A, review with Provider B
- Never use the same model family for both implementation and review
- Document which models were used in LOG.md

### 4. When to Use akido-mcp Tools

If akido-mcp is available, prefer these MCP tools for routing:
- `gemini_run` - Large context analysis, code generation
- `grok_run` - Real-time knowledge, reasoning
- `chatgpt_run` - General tasks, GPT-5 family
- `perplexity_run` - Web-grounded research with citations
- `local_llm_run` - Free, private, simple tasks
- `openclaw_run` - Complex multi-step tasks with plugin access
- `codex_run` - Coding-specific tasks with file access
- `claude_run` - When calling Claude from a non-Claude context

### 5. Context Window Awareness

| Provider | Max Context | Sweet Spot |
|----------|------------|------------|
| Claude Opus 4.8/Sonnet 4.6 | 1M tokens | <200K (avoid surcharge) |
| GPT-5.4 | Large | Mid-size |
| Gemini 3.1 Pro | Very large (1M+ tokens) | Any size |
| Gemini 3.5 Flash | Very large (1M+ tokens) | Any size |
| Grok 4.x | Large | Mid-size |
| Local LLM | 4-32K typical | <8K |

When a task requires processing large context:
- Prefer Gemini 3 (very large context, no surcharge) for bulk analysis
- Use Claude (1M) only when reasoning quality matters more than cost
- Split large tasks for models with smaller windows

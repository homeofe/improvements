# LLM Provider Capabilities Matrix

> Reference for choosing between providers. Updated as models evolve (current: June 2026).

## Provider Comparison

| Provider | Model | Context | Tools | Code Exec | Web Search | Vision | Cost (Input/Output per 1M) |
|----------|-------|---------|-------|-----------|------------|--------|---------------------------|
| Anthropic | Opus 4.8 | 1M | Yes | Via Bash | No | Yes | $5 / $25 |
| Anthropic | Sonnet 4.6 | 1M | Yes | Via Bash | No | Yes | $3 / $15 |
| Anthropic | Haiku 4.5 | 200K | Yes | Via Bash | No | Yes | $1 / $5 |
| OpenAI | GPT-5.5 | 1M | Yes | Yes | Yes | Yes | $5 / $30 |
| OpenAI | GPT-5.4 | 1M | Yes | Yes | Yes | Yes | $2.50 / $15 |
| OpenAI | GPT-5.4 Mini | 1M | Yes | Yes | Yes | Yes | $0.75 / $4.50 |
| OpenAI | Codex | 1M | Yes | Yes | No | No | coding-optimized GPT-5 |
| Google | Gemini 3.1 Pro | 1M | Yes | Yes | Yes | Yes | $2 / $12 |
| Google | Gemini 3.5 Flash | 1M | Yes | Yes | Yes | Yes | $1.50 / $9 |
| xAI | Grok 4.3 | 1M | Yes | No | Yes | Yes | $1.25 / $2.50 |
| xAI | Grok 4.1 Fast | 2M | Yes | No | Yes | Yes | $0.20 / $0.50 |
| Perplexity | Sonar Pro | 200K | No | No | Built-in | No | ~$3 / $15 |
| Perplexity | Sonar Deep Research | 200K | No | No | Built-in | No | ~$5 / $25 |
| Local | LM Studio / Ollama | 4-256K | Limited | Via shell | No | Some | Free |

*Context windows and prices are approximate and change frequently. Gemini 3.1 Pro and GPT-5.5 apply long-context surcharges above roughly 200K-272K input tokens; Claude 4.x charges a flat rate with no long-context surcharge. Batch APIs are typically 50% cheaper and prompt caching cuts cached-input cost by up to 90%. Verify on the provider pricing pages before relying on exact figures.*

## Capability Deep Dive

### Best for Research
1. **Perplexity** - Built-in web search with citations
2. **Grok** - Real-time knowledge, good reasoning
3. **Gemini** - Can ground with Google Search

### Best for Coding
1. **Claude Sonnet/Opus** - Best code quality, understands complex codebases
2. **Codex** - Optimized for code, fast execution
3. **Gemini 3.1 Pro** - Good code plus 1M context window

### Best for Reasoning
1. **Claude Opus 4.8** - Deep analysis, architecture decisions
2. **GPT-5.5** - Strong logical reasoning (flagship)
3. **Grok 4.3** - Strong reasoning with real-time grounding

### Best for Large Context
1. **Grok 4.1 Fast** - 2M tokens, the largest generally available
2. **Gemini 3.1 Pro / Claude Opus 4.8 / Sonnet 4.6** - 1M tokens (Claude with no long-context surcharge)
3. **Perplexity** - 200K but web-augmented

### Best for Privacy
1. **Local LLM** - Never leaves your machine
2. **Claude** - Strong privacy commitments
3. **Self-hosted** - Full control

### Best for Cost
1. **Local LLM** - Free
2. **GPT-5.4 Nano / Grok 4.1 Fast** - Very cheap
3. **Haiku 4.5 / GPT-5.4 Mini** - Cheap with good quality

## Tool Use Capabilities

| Provider | Function Calling | MCP | Computer Use | File I/O |
|----------|-----------------|-----|-------------|----------|
| Claude | Yes | Yes (native) | Yes | Via tools |
| GPT | Yes | Via adapters | No | Via code exec |
| Gemini | Yes | Via adapters | No | Via CLI |
| Grok | Yes | No | No | No |
| Perplexity | No | No | No | No |
| Local LLM | Some models | No | No | Via shell |

## Choosing by Use Case

### Daily Development
- **Default**: Claude Sonnet 4.6 (balanced)
- **Budget**: Gemini 3.5 Flash or local LLM
- **Quality**: Claude Opus 4.8

### Code Review
- **Security-focused**: Claude Opus 4.8 plus GPT-5.5 cross-check
- **General**: Use a different provider than implementer
- **Automated**: akido-mcp `akido_review_diff`

### Research and Learning
- **Quick facts**: Perplexity sonar-pro
- **Deep analysis**: Perplexity sonar-deep-research
- **Code examples**: Gemini 3.1 Pro (large context for docs)

### Multi-Agent Workflows (AAHP)
- **Researcher**: Perplexity or Gemini (web-grounded)
- **Architect**: Opus 4.8 or GPT-5.5 (reasoning)
- **Implementer**: Sonnet 4.6 or Codex (fast coding)
- **Reviewer**: Different provider than implementer

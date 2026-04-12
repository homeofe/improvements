# Integration Guide: Adding the AI Workflow Framework to Your Project

> Step-by-step guide for integrating this framework into any existing project.
> Works with Claude Code, but the `.llm/` patterns apply to any LLM tool.

---

## Prerequisites

- Git repository (initialized)
- At least one LLM tool available (Claude Code, Cursor, Windsurf, or any MCP-capable editor)
- Optional: [AAHP CLI](https://github.com/homeofe/AAHP) (`npm i -g @elvatis_com/aahp`)

---

## Quick Start (5 minutes)

### Step 1: Clone or Copy the Framework

**Option A: Clone and copy files**
```bash
# Clone the framework repo
git clone https://github.com/homeofe/improvements.git /tmp/ai-framework

# Copy to your project (from your project root)
cp -r /tmp/ai-framework/.claude/ .claude/
cp -r /tmp/ai-framework/.llm/ .llm/
cp -r /tmp/ai-framework/.ai/ .ai/
cp /tmp/ai-framework/CLAUDE.md CLAUDE.md

# Clean up
rm -rf /tmp/ai-framework
```

**Option B: Use the init script (if available)**
```bash
npx @elvatis_com/aahp init
# Then copy .claude/ and .llm/ manually from this repo
```

### Step 2: Adapt CLAUDE.md

Open `CLAUDE.md` and update:
1. Change the project title and description
2. Update the "Project Overview" section with your project's purpose
3. Add your project's dev commands (build, test, lint)
4. Add your project's key file locations
5. Keep the "Conventions" and "Multi-Model Strategy" sections as-is

### Step 3: Adapt AAHP Handoff Files

```bash
# These files need project-specific content:
.ai/handoff/STATUS.md          # Your project's current state
.ai/handoff/NEXT_ACTIONS.md    # Your project's actual tasks
.ai/handoff/CONVENTIONS.md     # Your project's coding standards
.ai/handoff/WORKFLOW.md        # Your project's agent pipeline
.ai/handoff/DASHBOARD.md       # Your project's build health
```

For each file:
- Replace `[PROJECT]` placeholders with your project name
- Update tables with your actual services, components, and tasks
- Keep the structure and section markers intact

### Step 4: Reset AAHP State

```bash
# Clear the log (start fresh)
echo "# $(basename $(pwd)): Session Log" > .ai/handoff/LOG.md

# Clear the archive
echo "" > .ai/handoff/LOG-ARCHIVE.md

# Reset the manifest
# Either use the AAHP CLI:
aahp manifest . --agent "manual" --phase "initialization" \
  --context "Framework integrated. Ready for first session."

# Or start a Claude Code session and run /handoff
```

### Step 5: Commit

```bash
git add .claude/ .llm/ .ai/ CLAUDE.md
git commit -m "feat(framework): integrate AI workflow framework [AAHP-auto]"
```

---

## What Each Layer Does

### `.claude/` - Claude Code Integration

| Directory | Purpose | When to Customize |
|-----------|---------|------------------|
| `rules/` | Loaded every session as behavioral rules | Rarely - these are universal |
| `agents/` | Custom subagents for AAHP pipeline phases | When adding project-specific agents |
| `commands/` | Slash commands (`/handoff`, `/status`, etc.) | When adding project-specific commands |
| `settings.json` | Permissions and hooks | When adding hooks or changing permissions |

**Key files to review:**
- `rules/multi-model.md` - The model routing decision tree
- `rules/aahp-protocol.md` - How agents interact with AAHP state

### `.llm/` - LLM-Agnostic Configuration

These files work with ANY LLM tool, not just Claude Code.

| File | Purpose | When to Customize |
|------|---------|------------------|
| `ROUTING.md` | Which model to use for which task | When you have different providers available |
| `PROVIDERS.md` | Provider capabilities matrix | When providers update models/pricing |
| `PATTERNS.md` | Cross-LLM workflow patterns | Rarely - these are universal patterns |
| `PROMPTS.md` | Reusable prompt templates | When adding project-specific prompts |

**For non-Claude tools:** Copy the prompt templates from `PROMPTS.md` into your tool's configuration. The AAHP session start prompt (template #1) is the most important one.

### `.ai/handoff/` - AAHP Protocol State

This is where agents read and write project state. See the [AAHP Protocol README](https://github.com/homeofe/AAHP) for the full specification.

| File | Purpose | Update Frequency |
|------|---------|-----------------|
| `MANIFEST.json` | Index, checksums, task graph | Every session end |
| `STATUS.md` | Current system state | Every session end |
| `NEXT_ACTIONS.md` | Active tasks (max 5) | When tasks change |
| `LOG.md` | Session journal (last 10) | Every session end |
| `DASHBOARD.md` | Build health + task queue | Every completed task |
| `CONVENTIONS.md` | Project rules | When conventions evolve |
| `WORKFLOW.md` | Agent pipeline definition | When workflow changes |
| `TRUST.md` | Verification register + TTL | When trust state changes |

---

## Customization Guide

### Adding Project-Specific Rules

Create a new file in `.claude/rules/`:

```markdown
# My Project Rule

[Your rule content here - loaded every Claude Code session]
```

### Adding Custom Agents

Create a new file in `.claude/agents/`:

```yaml
---
name: my-agent
description: "When to use this agent"
tools: "Read, Grep, Glob"
model: sonnet
maxTurns: 10
---

[Agent instructions here]
```

### Adding Custom Commands

Create a new file in `.claude/commands/`:

```yaml
---
description: "What this command does"
allowed-tools: "Read, Edit"
argument-hint: <argument>
---

[Command instructions using $ARGUMENTS]
```

Invoke with: `/my-command argument`

### Adding Project-Specific Prompts

Add new templates to `.llm/PROMPTS.md`:

```markdown
## 9. My Custom Prompt

\`\`\`
[Your reusable prompt template here]
[Use [BRACKETED SECTIONS] for variable parts]
\`\`\`
```

### Modifying the Model Routing

Edit `.llm/ROUTING.md` to match your available providers. If you only have Claude:
- Keep the routing table but mark unavailable providers
- Focus on the Claude model tiers (Haiku/Sonnet/Opus)
- Remove MCP tool references you don't have

---

## Using the Framework

### Daily Workflow

1. **Start of session**: Framework loads automatically via `CLAUDE.md`
2. **Check status**: Run `/status` to see project health
3. **Pick a task**: Run `/next` to get the next ready task
4. **Choose a model**: Run `/route <task description>` for recommendations
5. **Do the work**: Follow AAHP conventions
6. **End of session**: Run `/handoff` to update all state files

### Multi-Model Workflow

When working with multiple LLMs (e.g., Claude + GPT + Gemini):

1. Read `.llm/ROUTING.md` to decide which model handles which part
2. Use AAHP handoff files as the communication layer between models
3. Each model reads `MANIFEST.json` -> works -> updates handoff files
4. Never pass full conversation history between models (use AAHP state instead)

### Team Workflow

For teams sharing a project:

1. `.claude/` and `.llm/` are committed to git (team-shared)
2. Use `.claude/settings.local.json` for personal overrides (gitignored)
3. AAHP handoff files track project state across team members
4. Each team member can use different LLM tools with the same `.llm/` configs

---

## Verification Checklist

After integration, verify:

- [ ] `CLAUDE.md` exists at project root
- [ ] `.claude/rules/` has 4 rule files
- [ ] `.claude/agents/` has 5 agent files
- [ ] `.claude/commands/` has 5 command files
- [ ] `.llm/` has 4 configuration files
- [ ] `.ai/handoff/MANIFEST.json` has valid JSON
- [ ] `/status` command works (displays dashboard)
- [ ] `/next` command works (shows next task)
- [ ] No em dashes in any framework file
- [ ] No secrets or absolute paths in committed files
- [ ] `.gitignore` excludes `.claude/settings.local.json`

---

## Troubleshooting

| Problem | Solution |
|---------|---------|
| CLAUDE.md not loading | Ensure it's at project root, not in a subdirectory |
| Commands not found | Check files are in `.claude/commands/` with `.md` extension |
| Agents not spawning | Verify YAML frontmatter is valid (name, tools, model fields) |
| MANIFEST.json invalid | Run `aahp manifest .` or `/handoff` to regenerate |
| Settings not applying | Check precedence: enterprise > CLI > local > project > user global |
| Hooks not firing | Verify `settings.json` hook configuration and script paths |

---

## Removing the Framework

If you decide to remove the framework:

```bash
rm -rf .claude/ .llm/ .ai/ CLAUDE.md
git add -A && git commit -m "chore: remove AI workflow framework"
```

No other project files are affected. The framework is fully self-contained.

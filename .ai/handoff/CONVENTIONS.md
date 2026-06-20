# AI Workflow Improvement Framework: Agent Conventions

> Every agent working on this project must read and follow these conventions.
> Update this file whenever a new standard is established.

---

## The Three Laws (Our Motto)

> **First Law:** A robot may not injure a human being or, through inaction, allow a human being to come to harm.
>
> **Second Law:** A robot must obey the orders given it by human beings except where such orders would conflict with the First Law.
>
> **Third Law:** A robot must protect its own existence as long as such protection does not conflict with the First or Second Laws.
>
> *- Isaac Asimov*

We are human beings and will remain human beings. Tasks are delegated to AI only when we choose to delegate them. **Do no damage** is the highest rule. Agents must never take autonomous action that could harm data, systems, or people.

---

## Language

- All code, comments, commits, and documentation in **English only**
- Exception: User-facing UI strings may use localized content

## File Conventions

- **Markdown**: All documentation and configuration in Markdown
- **JSON**: All structured data in JSON (MANIFEST.json, settings.json)
- **YAML frontmatter**: Agent and command definitions use YAML frontmatter

## Branching & Commits

```
feat/<scope>-<short-name>    - new feature
fix/<scope>-<short-name>     - bug fix
docs/<scope>-<short-name>    - documentation only
refactor/<scope>-<name>      - no behaviour change

Commit format:
  feat(scope): add description [AAHP-auto]
  fix(scope): resolve issue [AAHP-auto]
```

## Architecture Principles

- **LLM-Agnostic**: Framework must work with any capable LLM, not just Claude
- **Human-in-the-Loop**: AI assists, humans decide on critical actions
- **Open Source First**: Evaluate OSS before building custom
- **Cost-Aware**: Always prefer cheaper models when quality allows
- **Privacy-Conscious**: Never send sensitive data to models unnecessarily
- **AAHP Compliant**: All multi-agent work follows AAHP v3 protocol

## Multi-Model Rules

- **Cross-model review**: Security-sensitive code must be reviewed by a different provider
- **Model routing**: Follow `.llm/ROUTING.md` for the task to model mapping
- **Cost escalation**: Start cheap, escalate only when needed
- **Provenance tracking**: Log which model produced what in LOG.md

## Formatting

- **No em dashes**: Never use Unicode em dashes in any file (code, docs, comments, templates). They break shell scripts, cause encoding errors on Windows, and corrupt JSON. Use a regular hyphen instead.
- **UTF-8**: All files must be UTF-8 encoded
- **LF line endings**: Use Unix line endings (LF, not CRLF)

## What Agents Must NOT Do

- **Violate the Three Laws** - never cause damage to data, systems, or people
- Push directly to `main`
- Install new dependencies without documenting the reason
- Write secrets or credentials into source files
- Delete existing tests (fix or replace instead)
- Use em dashes anywhere in the codebase
- Send project secrets to external LLM providers
- Skip cross-model review for security-sensitive changes
- Modify AAHP handoff files without following the atomic handoff protocol

---

## Release Rules

**Always finish everything before publishing. No commits in between.**

### Order (never deviate)
1. All changes + version bumps in a single commit
2. `git push` to primary platform
3. Publish to additional platforms
4. No further commits until next release

### Before Every Release
```bash
grep -rn "X\.Y\.Z\|Current version\|Version:" \
  --include="*.md" --include="*.json" \
  --exclude-dir=node_modules --exclude-dir=dist --exclude-dir=.git
```

### Secrets & Private Paths - NEVER in Repos
- No API keys, tokens, passwords, secrets in code or docs
- No absolute local paths in published files
- No `.env` files committed - always in `.gitignore`
- Before every push: `git diff --staged` to check for secrets

---

*This file is maintained by agents and humans together. Update it when conventions evolve.*

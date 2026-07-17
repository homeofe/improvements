# Local Hook Coverage

> The estate contract for local AAHP git hooks across the framework and its
> consumer repositories: which repositories exist, which local hooks each one
> must install, and where a hook is intentionally exempt.

This document is both human-readable and machine-readable. `scripts/verify-hooks.sh`
parses the registry table below (between the `hook-coverage-registry` markers) to
classify a target repository's hook state as installed, drifted, exempt, or
unknown without modifying anything.

---

## Why this exists

AAHP verification runs in two places:

1. **Locally**, via the `pre-commit` (fast gate) and `pre-push` (full gate) git
   hooks, installed by `scripts/install-hooks.sh` from the canonical hook
   sources in `scripts/hooks/`.
2. **Off machine**, via the required `AAHP Verify` CI check
   (`.github/workflows/aahp-verify.yml`), which cannot be bypassed.

The CI check is the backstop, but the local hooks are the first line of defense:
they catch staled handoff state before a commit or push leaves the machine. This
document turns "which repos have the local hooks, and which are allowed not to"
from tribal knowledge into one verifiable contract.

---

## Required hooks by repository type

Every active consumer is AAHP-gated (it vendors the four gate scripts under
`scripts/` and runs the handoff gate), so every type currently requires the full
local hook set. The type axis exists so requirements can diverge later without
reworking the tooling.

| Repository type   | Description                                             | Required local hooks   |
|-------------------|---------------------------------------------------------|------------------------|
| framework-source  | The canonical framework repo (homeofe/improvements)     | pre-commit, pre-push   |
| aahp-tooling      | AAHP CLIs and services (guard, runner, hub)             | pre-commit, pre-push   |
| product-platform  | Elvatis product applications                            | pre-commit, pre-push   |
| deploy-target     | Build and deploy targets that still run the gate        | pre-commit, pre-push   |

The canonical hook contents live in `scripts/hooks/pre-commit` and
`scripts/hooks/pre-push`. A hook is "installed" only when its content matches
that canonical source byte for byte (checksum comparison, CR-stripped so CRLF
and LF working trees compare equal).

---

## Consumer inventory and coverage registry

The consumer list is derived from the canonical source that already hardcodes it:
the `CONSUMERS=(...)` array in `.github/workflows/gate-sync.yml`. The framework
source repo itself is added because it also installs and runs the same local
hooks. The list was reconciled with the real gated estate on 2026-07-17: every
listed consumer was verified to carry `scripts/_aahp-lib.sh` on its default
branch, giving 22 consumers plus the framework source (23 registry rows).

### Deliberate exclusions

Two gate-related repositories are intentionally NOT consumers and must not be
added to the registry or to the gate-sync `CONSUMERS` array:

- **homeofe/AAHP**: the AAHP spec source. It maintains its own copies of the
  gate scripts and must never be overwritten by the sync.
- **elvatis/secure-smart-factory**: owner-excluded from portfolio-wide syncs;
  including it requires an explicit scope agreement per the ideabase project
  registry.

Registry columns:

- **repo**: `owner/name` as used by the gate-sync workflow.
- **type**: one of the repository types above.
- **required_hooks**: comma-separated hook names, or `none` when a repo requires
  no local hooks.
- **exempt_hooks**: comma-separated hook names that are explicitly exempt for
  this repo, `all` for a whole-repo exemption, or `-` when nothing is exempt.
- **reason**: short justification for the exemption, or `-` when nothing is
  exempt. Must not contain a pipe character.

<!-- BEGIN hook-coverage-registry -->
| repo | type | required_hooks | exempt_hooks | reason |
|------|------|----------------|--------------|--------|
| homeofe/improvements | framework-source | pre-commit,pre-push | - | - |
| homeofe/aahp-cron | aahp-tooling | pre-commit,pre-push | - | - |
| homeofe/aahp-hub | aahp-tooling | pre-commit,pre-push | - | - |
| homeofe/aahp-orchestrator | aahp-tooling | pre-commit,pre-push | - | - |
| homeofe/aahp-runner | aahp-tooling | pre-commit,pre-push | - | - |
| homeofe/aahp-swarm | aahp-tooling | pre-commit,pre-push | - | - |
| homeofe/akido-mcp | aahp-tooling | pre-commit,pre-push | - | - |
| homeofe/supply-chain-guard | aahp-tooling | pre-commit,pre-push | - | - |
| elvatis/AEGIS | product-platform | pre-commit,pre-push | - | - |
| elvatis/ai.elvatis.com | deploy-target | pre-commit,pre-push | - | - |
| elvatis/atlas | product-platform | pre-commit,pre-push | - | - |
| elvatis/conduit-bridge | deploy-target | pre-commit,pre-push | - | - |
| elvatis/conduit-vscode | deploy-target | pre-commit,pre-push | - | - |
| elvatis/elvatis-awareness | product-platform | pre-commit,pre-push | - | - |
| elvatis/elvatis-client-portal | product-platform | pre-commit,pre-push | - | - |
| elvatis/elvatis-defense | product-platform | pre-commit,pre-push | - | - |
| elvatis/elvatis-homepage | deploy-target | pre-commit,pre-push | - | - |
| elvatis/elvatis-intelligence | product-platform | pre-commit,pre-push | - | - |
| elvatis/elvatis-mcp | deploy-target | pre-commit,pre-push | - | - |
| elvatis/elvatis-security-platform | product-platform | pre-commit,pre-push | - | - |
| elvatis/elvatis-sso | product-platform | pre-commit,pre-push | - | - |
| elvatis/elvatis-trust | product-platform | pre-commit,pre-push | - | - |
| elvatis/netos | product-platform | pre-commit,pre-push | - | - |
<!-- END hook-coverage-registry -->

---

## Exceptions

An exception declares that a required hook is intentionally not installed for a
repository, so `scripts/verify-hooks.sh` reports it as `exempt` (which does not
fail the check) rather than `unknown` (which does).

### When an exemption is legitimate

Declare an exemption only when a hook genuinely cannot or should not run locally,
for example:

- A read-only or archived mirror where no local commit workflow exists.
- A repository whose contributors have no local git hook path (for example a
  web-only editing flow), where the required CI check is the sole enforcement.
- A repository that runs the gate exclusively in CI by deliberate policy.

Every exemption must name the specific hook (or `all`) and carry a short reason
in the registry. An exemption is a documented decision, never a silent gap: a
missing hook with no registry exemption is reported as `unknown` and fails.

### Worked example

A hypothetical documentation-only mirror that has no local commit workflow would
be declared like this (illustrative only, not a real consumer):

```
| owner/docs-mirror | product-platform | pre-commit,pre-push | all | read-only mirror, gate runs in CI only |
```

`scripts/verify-hooks.sh --repo owner/docs-mirror <path>` would then report both
hooks as `EXEMPT` and exit zero.

### Active exemptions

**None as of 2026-07-14.** Every listed consumer is AAHP-gated and supports both
local hooks, so no repository currently omits a required hook. This section is
the single place to record an exemption if one becomes necessary; add a row to
the registry above with a non-empty `exempt_hooks` and `reason`.

---

## Verifying a repository

`scripts/verify-hooks.sh` is read-only. It never installs, copies, or edits a
hook; it only reports.

```bash
# Verify the current checkout (repo slug taken from the origin remote):
scripts/verify-hooks.sh .

# Verify an arbitrary checkout, naming the repo explicitly:
scripts/verify-hooks.sh --repo homeofe/supply-chain-guard /path/to/checkout
```

Per-hook states:

| State     | Meaning                                                        | Fails? |
|-----------|----------------------------------------------------------------|--------|
| INSTALLED | Hook present and matches the canonical source.                 | no     |
| DRIFTED   | Hook present but its content differs from canonical.           | yes    |
| EXEMPT    | Hook declared exempt for this repo in the registry.            | no     |
| UNKNOWN   | Required hook is not installed, or the repo has no contract.   | yes    |

The command exits non-zero if any required hook is `DRIFTED` or `UNKNOWN`, and
zero when every required hook is `INSTALLED` or `EXEMPT`.

To install or repair the hooks (idempotent), use the installer:

```bash
scripts/install-hooks.sh /path/to/checkout
```

---

## Rollout

Propagating the local hooks to consumers that are missing or drifting is a
separate, reviewed phase (one pull request per consumer, opened only after that
repo's active-agent worktrees are clean). This document and
`scripts/verify-hooks.sh` are the framework-side contract that rollout is
measured against; the rollout itself does not happen here.

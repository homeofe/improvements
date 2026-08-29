# Local Hook Coverage

> The coverage contract for local AAHP git hooks: which local hooks a repository
> must install, how that requirement is declared, and where a hook is
> intentionally exempt.

This document is both human-readable and machine-readable. `scripts/verify-hooks.sh`
parses a registry table (between the `hook-coverage-registry` markers) to
classify a target repository's hook state as installed, drifted, exempt, or
unknown without modifying anything.

The registry below is the **contract for this repository plus worked examples**.
The set of repositories an operator actually runs the framework across is
deployment configuration, not framework source: keep that registry in your own
configuration and point the checker at it (see
[Pointing the checker at your own registry](#pointing-the-checker-at-your-own-registry)).

---

## Why this exists

AAHP verification runs in two places:

1. **Locally**, via the `pre-commit` (fast gate) and `pre-push` (full gate) git
   hooks, installed by `scripts/install-hooks.sh` from the canonical hook
   sources in `scripts/hooks/`.
2. **Off machine**, via the `AAHP Verify` CI check
   (`.github/workflows/aahp-verify.yml`), which runs on every pull request and
   every push to `main` and has no escape hatch of its own (`AAHP_SKIP_VERIFY`
   is ignored at `--level ci`).

> **Status of the CI check in this repository.** `AAHP Verify` is *intended* to
> be a required status check, but branch protection on `main` currently declares
> no required status checks, so a red run reports and does not block a merge.
> Until that is configured, the off-machine layer is an alarm, not a gate, and
> the local hooks are the only enforcement that actually stops work. An operator
> adopting this framework should mark the check required in branch protection.

The CI check is the backstop, but the local hooks are the first line of defense:
they catch staled handoff state before a commit or push leaves the machine. A
coverage registry turns "which repos have the local hooks, and which are allowed
not to" from tribal knowledge into one verifiable contract.

---

## Required hooks by repository role

A **role** is a coarse label for what a repository is for. It exists so hook
requirements can diverge later (a role could stop requiring a local hook)
without reworking the tooling. The roles below are the framework's suggested
vocabulary; an operator may use their own, because the checker reads the role
only as an opaque label.

| Role              | Description                                              | Required local hooks   |
|-------------------|----------------------------------------------------------|------------------------|
| framework-source  | The canonical framework repository itself                | pre-commit, pre-push   |
| aahp-tooling      | AAHP CLIs and services                                   | pre-commit, pre-push   |
| product-platform  | Application repositories                                 | pre-commit, pre-push   |
| deploy-target     | Build and deploy targets that still run the gate         | pre-commit, pre-push   |

Every AAHP-gated repository (one that vendors the four gate scripts under
`scripts/` and runs the handoff gate) requires the full local hook set, so today
every role carries the same requirement. Assigning roles is therefore a
descriptive exercise, not a security boundary, and a registry may legitimately
use a single role for everything.

The canonical hook contents live in `scripts/hooks/pre-commit` and
`scripts/hooks/pre-push`. A hook is "installed" only when its content matches
that canonical source byte for byte (checksum comparison, CR-stripped so CRLF
and LF working trees compare equal).

---

## Registry format

One row per repository, between the marker comments so the table can be found
in a file that also contains prose.

Registry columns:

- **repo**: `owner/name`, matched against the target's `origin` remote (or the
  `--repo` argument).
- **type**: the role label, from the table above or your own vocabulary.
- **required_hooks**: comma-separated hook names, or `none` when a repo requires
  no local hooks.
- **exempt_hooks**: comma-separated hook names that are explicitly exempt for
  this repo, `all` for a whole-repo exemption, or `-` when nothing is exempt.
- **reason**: short justification for the exemption, or `-` when nothing is
  exempt. Must not contain a pipe character.

A repository with no row is reported as `UNKNOWN`, which fails: coverage is
opt-in by declaration, never by omission.

<!-- BEGIN hook-coverage-registry -->
| repo | type | required_hooks | exempt_hooks | reason |
|------|------|----------------|--------------|--------|
| homeofe/improvements | framework-source | pre-commit,pre-push | - | - |
| acme/example-app | product-platform | pre-commit,pre-push | - | - |
| acme/example-docs-mirror | product-platform | pre-commit,pre-push | all | read-only mirror, gate runs in CI only |
<!-- END hook-coverage-registry -->

The first row is this repository's own contract, so `scripts/verify-hooks.sh .`
works in a fresh checkout. The `acme/*` rows are illustrative placeholders that
show a plain row and an exempted row; they match no real repository and are safe
to delete in a fork.

---

## Pointing the checker at your own registry

Keep your estate registry wherever the rest of your deployment configuration
lives (a private repo, a config management checkout, an operator's working
directory). It is the same Markdown format: the two marker comments around a
table with the five columns above. Then either pass it explicitly:

```bash
scripts/verify-hooks.sh --registry /path/to/private/hook-coverage.md /path/to/checkout
```

or set it once for a shell or CI job:

```bash
export AAHP_HOOK_REGISTRY=/path/to/private/hook-coverage.md
scripts/verify-hooks.sh /path/to/checkout
```

Precedence is `--registry`, then `AAHP_HOOK_REGISTRY`, then the copy in this
repository. Nothing else in the framework reads the registry, so that one
setting redirects the whole contract.

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

The `acme/example-docs-mirror` row above is the exemption shape: a repository
with no local commit workflow, declared `all`-exempt with a reason.

```
| acme/example-docs-mirror | product-platform | pre-commit,pre-push | all | read-only mirror, gate runs in CI only |
```

`scripts/verify-hooks.sh --repo acme/example-docs-mirror <path>` reports both
hooks as `EXEMPT` and exits zero.

---

## Verifying a repository

`scripts/verify-hooks.sh` is read-only. It never installs, copies, or edits a
hook; it only reports.

```bash
# Verify the current checkout (repo slug taken from the origin remote):
scripts/verify-hooks.sh .

# Verify an arbitrary checkout, naming the repo explicitly:
scripts/verify-hooks.sh --repo acme/example-app /path/to/checkout
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

Propagating the local hooks to repositories that are missing or drifting is a
separate, reviewed phase (one pull request per repository, opened only after
that repo's active-agent worktrees are clean). This document and
`scripts/verify-hooks.sh` are the framework-side contract that a rollout is
measured against; the rollout itself does not happen here.

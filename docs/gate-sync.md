# Gate-script sync

The four AAHP gate scripts live here, in the canonical framework repository, and
are **vendored** (copied) into every consumer repo under `scripts/`:

- `scripts/_aahp-lib.sh`
- `scripts/lint-handoff.sh`
- `scripts/aahp-manifest.sh`
- `scripts/verify-handoff.sh`

Because each repo carries its own copy, a fix that lands here does not reach the
copies on its own. Over time the copies **drift** (they have been observed 2 to 4
versions apart across a fleet). This document describes the canonical-source
model that keeps them in step without breaking each repo's legitimate per-repo
configuration.

## The canonical-source model

`scripts/` in this repository is the single source of truth for the four gate
scripts. The propagation is one-directional and automated:

```
canonical framework repo
      |
      |  push to main touches one of the 4 scripts
      v
.github/workflows/gate-sync.yml
      |
      |  for each configured consumer: clone, sync, refresh handoff, open PR
      v
consumer repos  (PR: chore/aahp-gate-sync)  -> a human reviews & merges
```

The workflow **opens PRs and never merges them**. Every consumer change is a
normal pull request that a maintainer reviews.

### What is preserved per repo

Exactly one line is legitimately different between repos: the
`AAHP_HANDOFF_FILES=(...)` array in `_aahp-lib.sh`. It names the handoff files a
repo tracks, and it varies (some repos track `LOG-ARCHIVE.md` /
`LOG-ARCHIVE.index.json` / `pii-allowlist.json`, some do not). A naive
"make identical" sync would overwrite this and break those repos' manifests.

`scripts/sync-gate-scripts.sh` therefore reads the consumer's existing
`AAHP_HANDOFF_FILES=(...)` line and substitutes it back into the canonical copy.
The canonical line in this repo is the superset default, used only for a brand
new install that has no line of its own. `aahp-manifest.sh` indexes only files
that actually exist, so listing a file a repo does not have is harmless.

The gate-deciding function `aahp_checksum` is byte-identical everywhere and is
never changed by a sync.

### Why the sync PR also touches STATUS.md and MANIFEST.json

Consumers are themselves AAHP-gated. Their content-drift gate (Layer 2 of
`verify-handoff.sh`) fails any change that touches source files outside
`.ai/handoff/` unless the same change also updates `STATUS.md` and regenerates
`MANIFEST.json`. So, for gated consumers, the workflow adds a dated note to
`STATUS.md` and reruns `aahp-manifest.sh` before committing. That makes the sync
PR pass the consumer's own gate. Because `AAHP_HANDOFF_FILES` was preserved, the
regenerated manifest indexes exactly the repo's own files.

## Running the sync manually

Against a local checkout of a consumer:

```bash
# from a checkout of this repository
scripts/sync-gate-scripts.sh /path/to/consumer-repo
```

The tool is idempotent (a second run changes nothing), prints a per-file diff
summary, and only edits the working tree. Committing and opening the PR is the
caller's (or the workflow's) job.

## The workflow

`.github/workflows/gate-sync.yml` runs on:

- a push to `main` that touches any of the four gate scripts, and
- `workflow_dispatch` (manual).

## Configuration

The workflow is the mechanism; **which repositories it targets is deployment
configuration and is not part of this source tree**. Three settings drive it,
all read at runtime.

### 1. `GATE_SYNC_CONSUMERS` (Actions variable, required)

The list of repositories that vendor the gate scripts.

- **Where**: `Settings -> Secrets and variables -> Actions -> Variables`, at
  repository or organization scope.
- **Format**: `owner/name` entries separated by newlines, commas, or spaces.
  Blank lines are ignored, and a `#` starts a comment that runs to end of line.

```
# one per line is the readable form
acme/example-app
acme/example-service      # trailing comments are fine
acme/example-tooling
```

An entry that is not of the form `owner/name` is counted and reported as
ignored; the run continues with the valid entries. If the variable is unset or
empty, the job exits successfully after a warning that explains what to set.

**Why a variable and not a secret or a config repo.** The list is not a
credential, so a secret is the wrong container: secrets are write-only, cannot
be reviewed or diffed after the fact, and offer nothing here that a variable
does not. A private configuration repository would work but adds a second
repository, a second token scope, and a checkout step to maintain for what is a
flat list of strings. A variable keeps the data editable and reviewable by
maintainers, applies at organization scope when several workflows need the same
list, and is not published with the source. Log exposure, the one advantage a
secret would have had, is handled explicitly instead: every entry is registered
with `::add-mask::` before first use, so a target name cannot reach the run log
even through git or `gh` error output.

### 2. `GATE_SYNC_TOKEN` (Actions secret, required)

The default `GITHUB_TOKEN` is scoped to this repository only and cannot push
branches or open PRs in the consumer repos. The workflow needs a cross-repo
token supplied as the Actions secret **`GATE_SYNC_TOKEN`**:

- a **classic PAT with the `repo` scope**, owned by a user or bot account that
  has **write access to every configured consumer repo**; or
- a **fine-grained PAT** granting **Contents: read/write** and
  **Pull requests: read/write** on each consumer repo.

Add it under `Settings -> Secrets and variables -> Actions`. Without it the job
exits early with a clear message.

### 3. `GATE_SYNC_RUNNER` (Actions variable, optional)

`runs-on` defaults to GitHub-hosted `ubuntu-latest`, matching
`aahp-verify.yml`. An operator who runs this job on their own infrastructure
sets `GATE_SYNC_RUNNER` to their runner label (a runner group, or one label that
uniquely selects the runner) rather than editing the workflow. The job body is
plain `bash`, `git`, and `gh`, so any Linux runner with those tools works.

## Reading the run log

Targets are masked, so the log reports each consumer by its **position** in
`GATE_SYNC_CONSUMERS` ("consumer 3/12"), not by name. Positions are stable for a
given value of the variable, so an operator maps a reported position back to a
repository by counting entries in the configured list. The final summary is
counts only: consumers, opened or updated, already in sync, skipped.

## Adding or removing a consumer

Edit the `GATE_SYNC_CONSUMERS` variable: append an `owner/name` line to add,
delete the line to remove. No code change and no pull request is needed. A repo
whose `scripts/_aahp-lib.sh` cannot be found after cloning (moved path, or the
token lacks access) is skipped at runtime, so the list stays declarative. Make
sure `GATE_SYNC_TOKEN` has write access to any repo you add.

Two categories of repository are worth leaving out deliberately:

- the **upstream protocol source**, if you track one: it maintains its own
  copies of the gate scripts and must never be overwritten by a downstream sync;
- any repository under a **scope agreement** that excludes it from fleet-wide
  automation.

Record those exclusions wherever you keep the list, not here.

## Forks and outside adopters

A fork inherits the mechanism and nothing else: no consumers, no token, no
runner override, so the workflow no-ops until it is configured. To use it:

1. set `GATE_SYNC_CONSUMERS` to your own repositories,
2. add a `GATE_SYNC_TOKEN` with write access to them, and
3. optionally set `GATE_SYNC_RUNNER`.

For a one-off run without configuring anything, trigger the workflow manually
and pass the list in the `consumers` input, which overrides the variable for
that run. Note that `workflow_dispatch` inputs are recorded in the run metadata,
so prefer the variable when the list should not appear in a run record.

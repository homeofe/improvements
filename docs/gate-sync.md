# Gate-script sync

The four AAHP gate scripts live here, in `homeofe/improvements`, and are
**vendored** (copied) into every consumer repo under `scripts/`:

- `scripts/_aahp-lib.sh`
- `scripts/lint-handoff.sh`
- `scripts/aahp-manifest.sh`
- `scripts/verify-handoff.sh`

Because each repo carries its own copy, a fix that lands here does not reach the
copies on its own. Over time the copies **drift** (they were observed 2 to 4
versions apart across the fleet). This document describes the canonical-source
model that keeps them in step without breaking each repo's legitimate
per-repo configuration.

## The canonical-source model

`homeofe/improvements/scripts/` is the single source of truth for the four gate
scripts. The propagation is one-directional and automated:

```
homeofe/improvements  (canonical)
      |
      |  push to main touches one of the 4 scripts
      v
.github/workflows/gate-sync.yml
      |
      |  for each consumer: clone, sync, refresh handoff, open PR
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
# from a checkout of homeofe/improvements
scripts/sync-gate-scripts.sh /path/to/consumer-repo
```

The tool is idempotent (a second run changes nothing), prints a per-file diff
summary, and only edits the working tree. Committing and opening the PR is the
caller's (or the workflow's) job.

## The workflow

`.github/workflows/gate-sync.yml` runs on:

- a push to `main` that touches any of the four gate scripts, and
- `workflow_dispatch` (manual).

It runs on GitHub-hosted `ubuntu-latest` because `homeofe/improvements` is
public (matching `aahp-verify.yml`). If the repo were private, the org CI-cost
rule would move it to the `[self-hosted, linux, x64, elvatis-ci]` runner.

## Required token secret

The default `GITHUB_TOKEN` is scoped to `homeofe/improvements` only and cannot
push branches or open PRs in the consumer repos. The workflow needs a cross-repo
token supplied as the Actions secret **`GATE_SYNC_TOKEN`**:

- a **classic PAT with the `repo` scope**, owned by a user or bot account that
  has **write access to every consumer repo** in both the `homeofe` and
  `elvatis` orgs; or
- a **fine-grained PAT** granting **Contents: read/write** and
  **Pull requests: read/write** on each consumer repo.

Add it under `Settings -> Secrets and variables -> Actions` in
`homeofe/improvements`. Without it the job fails fast with a clear message.

## Adding or removing a consumer

The consumer list is hardcoded in `.github/workflows/gate-sync.yml` as the
`CONSUMERS=( ... )` bash array. To add a repo, append its `owner/name`; to
remove one, delete its line. A repo whose `scripts/_aahp-lib.sh` cannot be found
after cloning (moved path, or the token lacks access) is skipped at runtime, so
the list stays declarative. Make sure `GATE_SYNC_TOKEN` has write access to any
repo you add.

Current consumers:

- `homeofe/supply-chain-guard`
- `homeofe/aahp-runner`
- `homeofe/aahp-hub`
- `elvatis/elvatis-security-platform`
- `elvatis/atlas`
- `elvatis/elvatis-defense`
- `elvatis/elvatis-awareness`
- `elvatis/elvatis-trust`
- `elvatis/elvatis-client-portal`
- `elvatis/elvatis-intelligence`
- `elvatis/ai.elvatis.com`

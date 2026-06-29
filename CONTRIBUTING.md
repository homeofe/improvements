# Contributing to the AI Workflow Improvement Framework

Thanks for your interest in contributing. This project is a portable,
LLM-agnostic framework you drop into any project to get multi-model routing,
AAHP handoff integration, and a set of ready-to-copy commands and docs. It is
documentation- and template-first: the docs and drop-in assets are the product.

## Getting started

1. Fork the repository and create a feature branch from `main`.
2. Read `README.md`, `INTEGRATION.md`, and the material under `docs/` before
   changing framework behavior or guidance.
3. Keep changes focused and small.

## Repository layout

- `docs/` framework documentation and guidance.
- `scripts/` helper scripts that support adoption and verification.
- `INTEGRATION.md` how to drop the framework into a target project.
- `CLAUDE.md` Claude-specific operating notes.

## Contribution rules

- **Keep guidance model-agnostic.** The framework targets any LLM; avoid tying
  docs or scripts to a single vendor except where a file is explicitly the
  vendor-specific layer.
- **Keep the drop-in assets consistent.** If you change a template or command,
  update the matching documentation in the same change.
- **No em dashes** in code, comments, or documentation. Use a regular hyphen or
  restructure the sentence.

## Pull request process

1. Open a Pull Request against `main` with a clear description.
2. Link any relevant issues and label the area you touched.
3. Update the affected docs or scripts in the same PR.
4. Confirm no secrets are in the commit history.

For major changes (new commands, new docs structure, breaking template
changes), open an issue first to discuss design and scope.

## License

By contributing, you agree that your contributions are licensed under the
[Apache License 2.0](LICENSE).

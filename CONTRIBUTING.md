# Contributing to NeruOS

Thank you for your interest in NeruOS. Contributions of code, design feedback, testing notes, and documentation are welcome.

## Before starting

1. Read docs/VISION.md, docs/ARCHITECTURE.md, and docs/DESIGN-SYSTEM.md.
2. Search existing issues to avoid duplicated work.
3. For large changes, open an issue first and describe the problem and intended outcome.

## Development setup

For the current Qt/QML prototype, see docs/INSTALLATION.md.

## Contribution guidelines

- Keep changes focused and small.
- Do not claim a feature is implemented if it is only a mockup.
- Keep UI decisions consistent with the design tokens.
- Prefer accessible labels, keyboard support, and visible focus states.
- Avoid unnecessary dependencies.
- Do not add privileged scripts or commands without a documented security review.
- Include screenshots or a short recording for UI changes where practical.
- Update documentation when behavior or requirements change.

## Commit messages

Use a short, imperative summary, for example:

- docs: clarify prototype installation
- ui: refine floating dock spacing
- build: add Qt SVG dependency

## Pull requests

A pull request should explain what changed and why, how it was tested, affected files or components, and known limitations or follow-up work.

Do not include secrets, personal data, access tokens, or proprietary assets.

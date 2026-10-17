---
description: Create and verify the C++ Hello World project scaffold.
agent: build-engineer
---

## Purpose
Create the source and project scaffold using [project-scaffold](../skills/project-scaffold/SKILL.md) as the single source of truth.

## Preconditions
- `git rev-parse --is-inside-work-tree` succeeds.
- `git branch --show-current` is not `develop`, `master`, or `main`.

## Actions
- Apply [project-scaffold](../skills/project-scaffold/SKILL.md) exactly, including its idempotency and no-overwrite rules.

## Expected files
- The source files, `tests/` directory, `.gitignore`, and verified `README.md` described by the skill.

## Verification commands
- Perform the checks and platform-specific smoke check in [project-scaffold](../skills/project-scaffold/SKILL.md)'s **Verification** section.

## Error message
Stop at the first failure and report exactly: `FAILED STEP: <command> - <reason>`.

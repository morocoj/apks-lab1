---
description: Initialize Git hygiene for the build-engineer project without changing branches or committing.
agent: build-engineer
---

## Purpose
Check repository and branch preconditions, ensure required ignore entries exist, and report the working-tree state.

## Preconditions
- Confirm `git rev-parse --is-inside-work-tree` succeeds.
- Read the current branch with `git branch --show-current`. If it is `develop`, `master`, or `main`, stop and tell the user: `git switch -c feature/<name>`.

## Actions
- Reuse the required `.gitignore` entries from [project-scaffold](../skills/project-scaffold/SKILL.md); append only missing exact-line entries and preserve existing entries and order.
- Show the current branch and `git status --short`.
- Never commit, push, or create branches.

## Expected files
- `.gitignore`, created if missing or minimally updated with missing entries.

## Verification commands
- `git rev-parse --is-inside-work-tree`
- `git branch --show-current`
- `git status --short`
- Confirm each required ignore entry from [project-scaffold](../skills/project-scaffold/SKILL.md) appears exactly once.

## Error message
Stop at the first failure and report exactly: `FAILED STEP: <command> - <reason>`.

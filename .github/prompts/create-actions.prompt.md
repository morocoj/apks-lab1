---
description: Create and validate the cross-platform GitHub Actions workflow.
agent: build-engineer
---

## Purpose
Create the CI workflow using [github-actions](../skills/github-actions/SKILL.md) as the single source of truth; keep build logic in `ci.sh` and `ci.bat`.

## Preconditions
- `ci.sh` and `ci.bat` both exist.

## Actions
- Apply [github-actions](../skills/github-actions/SKILL.md) exactly, preserving unrelated user changes.
- If `actionlint` is installed, validate with `actionlint .github/workflows/ci.yml`.
- Otherwise parse the YAML with Python and validate the trigger mapping, matrix, and script-only run steps. With PyYAML, read `on` as `data.get("on", data.get(True))` because YAML 1.1 may parse it as boolean `True`.

## Expected files
- `.github/workflows/ci.yml` with the three-OS matrix and script-stage steps specified by the skill.

## Verification commands
- `actionlint .github/workflows/ci.yml` when actionlint is installed.
- Otherwise parse `.github/workflows/ci.yml` with Python/PyYAML and check triggers, the exact OS matrix, and that each run step only calls its script stage.

## Error message
Stop at the first failure and report exactly: `FAILED STEP: <command> - <reason>`.

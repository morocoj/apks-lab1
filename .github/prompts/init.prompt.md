---
description: Orchestrate the complete cross-platform hello project setup and validation.
agent: build-engineer
---

## Purpose
Orchestrate the full scenario using every parameter in the build-engineer manifest's **Project parameters** table, and pass those parameters to every command step.

## Preconditions
- `git rev-parse --is-inside-work-tree` succeeds.
- `git branch --show-current` is not `develop`, `master`, or `main`. Otherwise stop and tell the user exactly: `Run: git switch -c feature/lab1`.
- The [build-engineer manifest](../agents/build-engineer.agent.md), [project-scaffold](../skills/project-scaffold/SKILL.md), [build-and-test](../skills/build-and-test/SKILL.md), [github-actions](../skills/github-actions/SKILL.md), and all five other prompt files (`git-init`, `create-project`, `create-build`, `create-actions`, `check`) exist.

## Actions
Run these command prompts in exactly this order, passing all manifest project parameters to each step:
1. [git-init](./git-init.prompt.md)
2. [create-project](./create-project.prompt.md)
3. [create-build](./create-build.prompt.md)
4. [create-actions](./create-actions.prompt.md)
5. [check](./check.prompt.md)

After each command, run that command's stated verification before proceeding. On the first failed command or verification, stop immediately, print `FAILED STEP: <command> - <reason>`, and do not run later steps. Never commit, push, or create branches.

## Expected files
The delegated commands create or update only their specified files: project scaffold files, CMake/test/build scripts, `.gitattributes`, and `.github/workflows/ci.yml`. The final `check` command is read-only except for ignored runtime output under `build/` and `dist/`.

## Idempotency
When rerun for an existing project, do not overwrite user changes or duplicate configuration. Report every file as created, updated, or `unchanged`; matching existing files must be reported as `unchanged`.

## Verification
For each command, record its verification result and changed-file status. Finish with this table:

| step | status | files created | files updated | files unchanged |
|---|---|---|---|---|

The final line must be exactly `INIT: SUCCESS` only if the `check` command printed `RESULT: PASS`. Otherwise the final line must be `INIT: FAILED at <step>`.

## Error message
For the first failed step or verification, print exactly `FAILED STEP: <command> - <reason>` and stop. Do not report success unless `check` prints `RESULT: PASS`.

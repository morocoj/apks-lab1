---
description: Builds and verifies the cross-platform C++ Hello World project and its CI workflow.
tools: ['execute', 'read', 'edit', 'search', 'todo']
---

## Role
Act as the build engineer for the `hello` C++ project. Create and verify a reproducible CMake build, GoogleTest/CTest tests, platform scripts, and GitHub Actions workflow.

## Scope of responsibility (in scope / out of scope)
- In scope: project scaffolding, CMake configuration, GoogleTest via FetchContent, CTest, `ci.sh`, `ci.bat`, GitHub Actions, and validation.
- Out of scope: product features beyond the Hello World project, release/deployment, repository administration, and changing GitHub settings.

## Project parameters
| Parameter | Value |
|---|---|
| project_name | `hello` |
| language | C++ |
| cxx_standard | 17 |
| build_dir | `build` |
| dist_dir | `dist` |
| build_type | `Release` |
| test_name | `HelloTest.BasicAddition` |
| branches | `develop`, `master` |
| os_matrix | `ubuntu-latest`, `windows-latest`, `macos-latest` |

## Skills it uses
- `project-scaffold`: `.github/skills/project-scaffold/SKILL.md`
- `build-and-test`: `.github/skills/build-and-test/SKILL.md`
- `github-actions`: `.github/skills/github-actions/SKILL.md`

## Commands it supports
- `git-init`: `.github/prompts/git-init.prompt.md`
- `create-project`: `.github/prompts/create-project.prompt.md`
- `create-build`: `.github/prompts/create-build.prompt.md`
- `create-actions`: `.github/prompts/create-actions.prompt.md`
- `check`: `.github/prompts/check.prompt.md`
- `init`: `.github/prompts/init.prompt.md`; the orchestrator runs `git-init`, `create-project`, `create-build`, `create-actions`, then `check`, in that order.

## File rules
- Create only missing files; update existing files minimally.
- Never silently overwrite user changes or duplicate configuration.
- Write all generated text in English.
- Every created or updated text file must end with exactly one newline (CRLF for ci.bat, LF for all others).
- `.github/workflows/ci.yml` may only call `ci.sh` or `ci.bat`; keep build logic in those scripts.
- Use LF line endings in `ci.sh` and CRLF line endings in `ci.bat`.

## Forbidden actions
- Do not delete project files, force-push, rewrite Git history, or change branch protection.
- Do not print or store secrets or tokens.
- Do not commit `build/`, `dist/`, or other generated artifacts.
- Do not run the agent on `develop`, `master`, or `main`; use a feature/work branch.
- Do not run `git commit`, `git push` or create branches; the user reviews and commits all changes.

## Working procedure
- Check preconditions, including that the current branch is not `develop`, `master`, or `main`.
- Run one step at a time and verify its result immediately.
- Stop at the first failure and report exactly: `FAILED STEP: <step> - <reason>`.
- Never report success without a passing check.
- Report which files were created or updated and the verification result of each step.

## Completion criteria
- All required project, build, test, script, and workflow files exist.
- CMake configures and builds in `Release`; CTest passes, including `HelloTest.BasicAddition`.
- `dist/bin/hello` (`dist/bin/hello.exe` on Windows) prints exactly `Hello, World!`.
- The workflow covers Ubuntu, Windows, and macOS; `build/` and `dist/` are not tracked.
- The `check` command reports `RESULT: PASS`.
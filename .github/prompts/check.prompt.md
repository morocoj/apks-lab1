---
description: Run every project, build, workflow, and Git-hygiene check without repairing files.
agent: build-engineer
---

## Purpose
Run read-only validation against the [build-engineer manifest](../agents/build-engineer.agent.md), [project-scaffold](../skills/project-scaffold/SKILL.md), [build-and-test](../skills/build-and-test/SKILL.md), and [github-actions](../skills/github-actions/SKILL.md). Do not create, edit, or delete tracked files. The only permitted filesystem changes are ignored runtime content under `build/` and `dist/` created by the build. Never fix or modify project configuration. This prompt overrides the manifest's fail-fast behavior: perform all ten checks, record PASS or FAIL for each, and summarize only after all checks have run.

## Preconditions
- Run from the repository root in a Git work tree.
- Preserve the starting output of `git status --short` for comparison in check 10.
- Do not stop early when a precondition or check fails; record the failure and continue with every remaining check that can be attempted.

## Actions
Perform these checks in order. Record a PASS or FAIL and concise evidence for each, even when earlier checks fail.

1. **Initial Git status:** record the exact output of `git status --short` as the before snapshot.
2. **Manifest:** confirm `.github/agents/build-engineer.agent.md` exists, has valid YAML frontmatter, and contains sections `Role`, `Scope of responsibility`, `Forbidden actions`, and `Completion criteria`.
3. **Skills:** for each of [project-scaffold](../skills/project-scaffold/SKILL.md), [build-and-test](../skills/build-and-test/SKILL.md), and [github-actions](../skills/github-actions/SKILL.md), confirm `SKILL.md` exists, its frontmatter has `name` and `description`, and it contains `Purpose`, `Inputs`, `Outputs`, `Verification`, and `Failure scenarios and handling` sections.
4. **Commands:** confirm `.github/prompts/git-init.prompt.md`, `create-project.prompt.md`, `create-build.prompt.md`, `create-actions.prompt.md`, `check.prompt.md`, and `init.prompt.md` all exist. Confirm each has frontmatter fields `description` and `agent: build-engineer`, plus an `Error message` section. Confirm `init.prompt.md` references `git-init`, `create-project`, `create-build`, `create-actions`, and `check` in exactly that order.
5. **Project files:** confirm all exist: `src/hello.h`, `src/hello.cpp`, `src/main.cpp`, `tests/test_basic.cpp`, `CMakeLists.txt`, `ci.sh`, `ci.bat`, `.gitignore`, `.gitattributes`, `.github/workflows/ci.yml`, `README.md`, `docs/architecture.md`, `docs/usage.md`, and `docs/ai-log.md`.
6. **Configuration:** compare `.gitignore` with every required entry in [project-scaffold](../skills/project-scaffold/SKILL.md); confirm `ci.sh` uses LF line endings and is executable; confirm `ci.bat` uses CRLF line endings; confirm `.gitattributes` contains both `*.sh text eol=lf` and `*.bat text eol=crlf` rules.
7. **Build and tests:** run `./ci.sh` on Linux/macOS or `ci.bat` on Windows. Mark this check PASS only if the script exits 0, its CTest output reports `HelloTest.BasicAddition` as Passed, `dist/bin/hello` (Windows: `dist/bin/hello.exe`) prints exactly `Hello, World!` followed by a newline, and `dist/` contains only `bin/hello` (Windows: `bin/hello.exe`). Record the output and result for each criterion; do not repair anything.
8. **Workflow:** run `actionlint .github/workflows/ci.yml` if `actionlint` is installed; otherwise parse it with Python/PyYAML, reading triggers as `data.get("on", data.get(True))` because YAML 1.1 may parse `on` as boolean `True`. Confirm the matrix OS list is exactly `ubuntu-latest`, `windows-latest`, `macos-latest`; both `push` and `pull_request` include `develop` and `master`; every `run` step only calls the configured script with one supported stage; and `ci.yml` contains no `cmake` text. Record parser/linter output and each assertion.
9. **Git hygiene:** confirm `git ls-files build/ dist/` lists nothing. Search tracked files with `git grep -n -E 'ghp_|github_pat_|AKIA|BEGIN PRIVATE KEY' -- . ':!.github/prompts/check.prompt.md'`; no matches is PASS, while matches or a command error is FAIL. Report matching paths but never reproduce any matched secret value.
10. **Final Git status:** record `git status --short` as the after snapshot and compare it byte-for-byte with check 1. Any difference is FAIL; do not revert or otherwise change files.

## Expected files
None. Validation must not create, edit, or delete tracked files. Only ignored runtime contents in `build/` and `dist/` may be created by running the build.

## Verification
Print a table with columns `# | check | PASS/FAIL | details`, containing all ten checks in the order above. For every failure, also print one line exactly in this format: `FAILED CHECK: <check> - <reason>`. Continue collecting results after failures and do not perform fixes. End with exactly `RESULT: PASS` only if every check passed. Otherwise end with `RESULT: FAIL - <failed check names>`.

## Error message
Use `FAILED CHECK: <check> - <reason>` for each failed check. Do not stop after a failure, suppress later check results, or claim success unless all ten checks pass; the final line must follow the rule in **Verification**.

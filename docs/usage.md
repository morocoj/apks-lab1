# Usage

## Prerequisites
- VS Code with GitHub Copilot enabled.
- CMake 3.20 or newer.
- A C++17-capable compiler.
- Git.
- Optional: `actionlint` for local GitHub Actions workflow validation.

## Branch workflow
Run these commands in the repository before using the build agent:

```sh
git switch develop
git switch -c feature/lab1
```

The agent does not create branches, commit, or push. Work on a feature branch; do not run it on `develop`, `master`, or `main`.

## Run the full setup
In VS Code, open Copilot Chat, select **Agent** mode, choose `build-engineer`, then run:

```text
/init
```

The orchestrator runs `git-init`, `create-project`, `create-build`, `create-actions`, and `check` in that order, stopping at the first failed step.

## Run one command
With `build-engineer` selected in Copilot Chat, run any command separately:

```text
/git-init
/create-project
/create-build
/create-actions
/check
```

Run the commands in that order when setting up the project manually. `/check` validates the project and does not repair files.

## Build locally
On Linux or macOS, run the full pipeline:

```sh
./ci.sh
```

To run one stage, use `configure`, `build`, `test`, `install`, or `run`:

```sh
./ci.sh <stage>
./ci.sh test
```

On Windows, use the batch script with no argument for all stages or provide one stage:

```bat
ci.bat
ci.bat test
```

The stages configure CMake, build in Release, run CTest, install the executable under `dist/bin/`, and run it. Successful test output includes `HelloTest.BasicAddition` as Passed. The final program output is:

```text
Hello, World!
```

The Windows executable is `dist\bin\hello.exe`; on Linux and macOS it is `dist/bin/hello`.

## CI workflow
GitHub Actions runs on pushes and pull requests targeting `develop` or `master`, with jobs on `ubuntu-latest`, `windows-latest`, and `macos-latest`. Each job invokes the platform script for Configure, Build, Test, Install, and Run, then uploads `dist/` as an OS-specific artifact.

## Broken check demo
Run `/check` on a fully initialized project and confirm it reports `RESULT: PASS`. In `tests/test_basic.cpp`, temporarily change the expected result in `EXPECT_EQ(hello::add(2, 3), 5);` from `5` to `6`, then run:

```text
/check
```

The test should fail and the check should report `RESULT: FAIL`. Restore the expected value to `5`, run `/check` again, and confirm it reports `RESULT: PASS`.

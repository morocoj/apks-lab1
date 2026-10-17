---
description: Create the CMake, GoogleTest, and platform build scripts, then verify the project build.
agent: build-engineer
---

## Purpose
Add and verify the Release build and test workflow using [build-and-test](../skills/build-and-test/SKILL.md) as the single source of truth.

## Preconditions
- `src/hello.h`, `src/hello.cpp`, and `src/main.cpp` exist.
- `cmake --version` succeeds.

## Actions
- Apply [build-and-test](../skills/build-and-test/SKILL.md) exactly, preserving existing user changes and respecting required line endings and executable permission.

## Expected files
- `CMakeLists.txt`, `tests/test_basic.cpp`, `ci.sh`, `ci.bat`, and `.gitattributes` as specified by the skill.

## Verification commands
- Run `./ci.sh` on Linux/macOS or `ci.bat` on Windows.
- Confirm CTest reports `HelloTest.BasicAddition` as Passed and [build-and-test](../skills/build-and-test/SKILL.md)'s remaining verification criteria pass.

## Error message
Stop at the first failure and report exactly: `FAILED STEP: <command> - <reason>`.

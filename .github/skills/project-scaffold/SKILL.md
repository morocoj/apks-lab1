---
name: project-scaffold
description: Use when creating or verifying the C++ Hello World project scaffold for the build-engineer workflow.
---

## Purpose
Create the minimal source tree and project metadata for the cross-platform `hello` C++ project. Keep the interface compatible with the `build-and-test` skill.

## When to use
Use for the `project-scaffold` stage of `/create-project` or `/init`. This fixed scaffold supports `project_name=hello` and C++ only; stop before editing if different values are provided.

## Inputs
- `language`: programming language; defaults to `C++` and must be `C++`.
- `project_name`: project name; defaults to `hello` and must be `hello` for these fixed file contents.

## Steps
1. Create `src/` if missing. Create `src/hello.h` only if missing, with exactly this content:

   ```cpp
   #pragma once

   #include <string>

   namespace hello {

   int add(int a, int b);
   std::string greeting();

   }
   ```

2. Create `src/hello.cpp` only if missing, with exactly this content:

   ```cpp
   #include "hello.h"

   namespace hello {

   int add(int a, int b) {
       return a + b;
   }

   std::string greeting() {
       return "Hello, World!";
   }

   }
   ```

3. Create `src/main.cpp` only if missing, with exactly this content:

   ```cpp
   #include "hello.h"

   #include <iostream>

   int main() {
       std::cout << hello::greeting() << '\n';
       return 0;
   }
   ```

4. Create `tests/` if missing. Do not create test files; the `build-and-test` skill creates them later.

5. Create `.gitignore` if missing. Otherwise append only required entries that are not already present as exact lines. Preserve all existing content and ordering; append missing entries in this order:

   ```gitignore
   build/
   dist/
   cmake-build-*/
   .cache/
   CMakeUserPresets.json
   *.log
   .env
   .DS_Store
   ```

   This list is the single source of truth for required ignore entries; the `git-init` command must reuse it.

6. Verify that `README.md` exists and has sections about running the agent, building/running the project, and project structure. Accept equivalent headings, including `Як запустити агента`, `Як зібрати та запустити проєкт`, and `Структура`. Append only a missing section; never rewrite existing text. Use only the relevant English section below when one is absent:

   ```markdown
   ## Running the agent
   Open the repository in VS Code, select the `build-engineer` agent, and run `/init` on a feature branch.
   ```

   ```markdown
   ## Building and running the project
   Run `./ci.sh` on Linux or macOS, or `ci.bat` on Windows, to build, test, and run the project.
   ```

   ```markdown
   ## Project structure
   The project separates C++ source in `src/`, tests in `tests/`, and build and CI configuration in the repository root and `.github/`.
   ```

## Idempotency
Create only missing files and directories. Leave matching existing source files unchanged; if an existing source file differs from its required content, do not overwrite it and report the difference. For `.gitignore`, append only missing exact-line entries without removing or reordering anything. For `README.md`, preserve all existing text and add only absent sections. Repeated runs must not duplicate entries or sections.

## Outputs
- `src/hello.h`, `src/hello.cpp`, and `src/main.cpp`, created only when missing.
- `tests/`, created only when missing; test files are deferred to `build-and-test`.
- `.gitignore`, created if absent or appended with missing required entries.
- `README.md`, verified and appended only when a required section is absent.

## Verification
- Confirm the source files, `tests/`, `.gitignore`, and `README.md` exist and the README has all required sections.
- On Linux or macOS, ensure `build/` exists, then run:

  ```sh
  c++ -std=c++17 -Isrc src/main.cpp src/hello.cpp -o build/scaffold-check
  ```

- Run `./build/scaffold-check` and confirm standard output is exactly `Hello, World!` followed by a newline.
- On Windows, skip this smoke check; the `build-and-test` skill performs the full build.

## Example input and expected result
Input: `language=C++`, `project_name=hello`.

Expected result: the required source files and `tests/` exist, `.gitignore` contains each required entry once, and `README.md` retains its existing text and includes all three required sections. On Linux/macOS the smoke program compiles and prints `Hello, World!` followed by a newline.

## Failure scenarios and handling
- Compiler not found: stop the smoke-check step, report that the C++ compiler is unavailable, and do not claim verification passed.
- `src/main.cpp` already exists with different content: do not overwrite it; report the path and the difference from the required template.
- Another existing source file differs from its template: do not overwrite it; report the path and difference.
- `README.md` is missing: report the missing file and stop; do not create or replace it.
- For any failure, stop immediately and report `FAILED STEP: <step> - <reason>`.
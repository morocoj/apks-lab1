---
name: build-and-test
description: Use when configuring, building, testing, installing, or running the cross-platform C++ Hello World project.
---

## Purpose
Add the CMake build, GoogleTest/CTest test, and platform build scripts for the `hello` project. Use the `src/hello.h`, `src/hello.cpp`, and `src/main.cpp` created by `project-scaffold` without changing them.

## When to use
Use for the `build-and-test` stage of `/create-build` or `/init`, after `project-scaffold` has created and verified the source files.

## Inputs
- `project_name`: `hello`.
- `cxx_standard`: `17`.
- `build_type`: `Release`.
- `googletest_version`: `1.17.0`.

## Steps
1. Confirm the three scaffold source files exist and match the `project-scaffold` contract. Create `CMakeLists.txt` only if missing, with exactly this content:

   ```cmake
   cmake_minimum_required(VERSION 3.20)

   project(hello LANGUAGES CXX)

   set(CMAKE_CXX_STANDARD 17)
   set(CMAKE_CXX_STANDARD_REQUIRED ON)
   set(CMAKE_CXX_EXTENSIONS OFF)

   add_library(hello_core STATIC src/hello.cpp)
   target_include_directories(hello_core PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/src")

   add_executable(hello src/main.cpp)
   target_link_libraries(hello PRIVATE hello_core)

   install(TARGETS hello RUNTIME DESTINATION bin)

   include(FetchContent)

   set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
   set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)
   set(BUILD_GMOCK OFF CACHE BOOL "" FORCE)

   FetchContent_Declare(
       googletest
       URL https://github.com/google/googletest/archive/refs/tags/v1.17.0.zip
       DOWNLOAD_EXTRACT_TIMESTAMP TRUE
   )
   FetchContent_MakeAvailable(googletest)

   enable_testing()

   add_executable(hello_tests tests/test_basic.cpp)
   target_link_libraries(hello_tests PRIVATE hello_core GTest::gtest_main)

   include(GoogleTest)
   gtest_discover_tests(hello_tests)
   ```

2. Create `tests/` if missing. Create `tests/test_basic.cpp` only if missing, with exactly this content:

   ```cpp
   #include "hello.h"

   #include <gtest/gtest.h>

   TEST(HelloTest, BasicAddition) {
       EXPECT_EQ(hello::add(2, 3), 5);
   }
   ```

3. Create `ci.sh` only if missing, using Bash and LF line endings, with exactly this content. After creating it, run `chmod +x ci.sh` and ensure it is executable:

   ```bash
   #!/usr/bin/env bash
   set -euo pipefail

   script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
   cd "$script_dir"

   do_configure() {
       printf '==> [configure]\n'
       cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
   }

   do_build() {
       printf '==> [build]\n'
       cmake --build build --config Release --parallel
   }

   do_test() {
       printf '==> [test]\n'
       ctest --test-dir build -C Release --output-on-failure
   }

   do_install() {
       printf '==> [install]\n'
       cmake --install build --config Release --prefix dist
   }

   do_run() {
       printf '==> [run]\n'
       if ! dist/bin/hello | cmp - <(printf 'Hello, World!\n'); then
           printf 'Error: dist/bin/hello output did not match "Hello, World!".\n' >&2
           return 1
       fi
       printf 'Hello, World!\n'
   }

   stage="${1:-all}"
   if (($# > 1)); then
       printf 'Error: provide at most one stage argument.\n' >&2
       exit 2
   fi

   case "$stage" in
       configure) do_configure ;;
       build) do_build ;;
       test) do_test ;;
       install) do_install ;;
       run) do_run ;;
       all)
           do_configure
           do_build
           do_test
           do_install
           do_run
           ;;
       *)
           printf 'Error: unknown stage "%s".\n' "$stage" >&2
           exit 2
           ;;
   esac
   ```

4. Create `ci.bat` only if missing, using `cmd.exe` and CRLF line endings, with exactly this content. Keep `--config Release` and `-C Release`; Visual Studio uses a multi-config generator.

   ```bat
   @echo off
   setlocal
   cd /d "%~dp0"
   if errorlevel 1 exit /b 1

   if "%~1"=="" (
       set "stage=all"
   ) else (
       set "stage=%~1"
   )
   if not "%~2"=="" (
       echo Error: provide at most one stage argument. 1>&2
       exit /b 2
   )

   if /I "%stage%"=="configure" goto configure_only
   if /I "%stage%"=="build" goto build_only
   if /I "%stage%"=="test" goto test_only
   if /I "%stage%"=="install" goto install_only
   if /I "%stage%"=="run" goto run_only
   if /I "%stage%"=="all" goto all_stages
   echo Error: unknown stage "%stage%". 1>&2
   exit /b 2

   :all_stages
   call :do_configure
   if errorlevel 1 exit /b 1
   call :do_build
   if errorlevel 1 exit /b 1
   call :do_test
   if errorlevel 1 exit /b 1
   call :do_install
   if errorlevel 1 exit /b 1
   call :do_run
   if errorlevel 1 exit /b 1
   exit /b 0

   :configure_only
   call :do_configure
   exit /b %errorlevel%

   :build_only
   call :do_build
   exit /b %errorlevel%

   :test_only
   call :do_test
   exit /b %errorlevel%

   :install_only
   call :do_install
   exit /b %errorlevel%

   :run_only
   call :do_run
   exit /b %errorlevel%

   :do_configure
   echo ==^> [configure]
   cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
   if errorlevel 1 exit /b 1
   exit /b 0

   :do_build
   echo ==^> [build]
   cmake --build build --config Release --parallel
   if errorlevel 1 exit /b 1
   exit /b 0

   :do_test
   echo ==^> [test]
   ctest --test-dir build -C Release --output-on-failure
   if errorlevel 1 exit /b 1
   exit /b 0

   :do_install
   echo ==^> [install]
   cmake --install build --config Release --prefix dist
   if errorlevel 1 exit /b 1
   exit /b 0

   :do_run
   echo ==^> [run]
   set "run_id=%RANDOM%-%RANDOM%"
   set "actual_file=%TEMP%\hello-output-%run_id%.txt"
   set "expected_file=%TEMP%\hello-expected-%run_id%.txt"
   > "%expected_file%" echo Hello, World!
   if errorlevel 1 exit /b 1
   dist\bin\hello.exe > "%actual_file%"
   if errorlevel 1 goto run_failed
   fc /b "%expected_file%" "%actual_file%" >nul
   if errorlevel 1 goto run_mismatch
   type "%actual_file%"
   if errorlevel 1 goto run_failed
   del /q "%actual_file%" "%expected_file%"
   if errorlevel 1 exit /b 1
   exit /b 0

   :run_mismatch
   echo Error: dist\bin\hello.exe output did not match "Hello, World!". 1>&2
   del /q "%actual_file%" "%expected_file%" >nul 2>&1
   exit /b 1

   :run_failed
   del /q "%actual_file%" "%expected_file%" >nul 2>&1
   exit /b 1
   ```

5. Create `.gitattributes` if missing. Otherwise append only the missing exact lines, preserving existing content and order:

   ```gitattributes
   *.sh text eol=lf
   *.bat text eol=crlf
   ```

## Idempotency
Create only missing files. If an existing generated file matches its template, leave it unchanged. If `CMakeLists.txt`, `tests/test_basic.cpp`, or either script differs in content, do not overwrite it; report the path and difference. Preserve scaffold source files. Append only missing `.gitattributes` lines without removing or reordering existing entries. Ensure `ci.sh` is executable and the scripts use their required line endings. Repeated runs must not duplicate configuration or attribute rules.

## Outputs
- `CMakeLists.txt` configuring the C++17 `hello_core`, `hello`, and GoogleTest-backed `hello_tests` targets.
- `tests/test_basic.cpp` containing `HelloTest.BasicAddition`.
- Executable `ci.sh` with LF endings and `ci.bat` with CRLF endings; each supports `configure`, `build`, `test`, `install`, `run`, and `all` (default).
- `.gitattributes` containing `*.sh text eol=lf` and `*.bat text eol=crlf`.

## Verification
- On Linux or macOS, run `./ci.sh`; on Windows, run `ci.bat`. Each runs configure, build, test, install, and run in that order and stops on the first error.
- Confirm CTest reports `HelloTest.BasicAddition` as Passed and the installed `dist/bin/hello` (`dist\bin\hello.exe` on Windows) prints exactly `Hello, World!` followed by a newline.
- Confirm `dist/` contains only `bin/hello` (or `bin/hello.exe` on Windows), with no GoogleTest files.
- Confirm `git status` does not show `build/` or `dist/` as tracked or unignored changes.
- Confirm `ci.sh` has LF endings and executable permission, and `ci.bat` has CRLF endings.

## Example input and expected result
Input: `project_name=hello`, `cxx_standard=17`, `build_type=Release`, `googletest_version=1.17.0`.

Expected result: CMake builds the scaffold source and `HelloTest.BasicAddition`; the scripts run all five stages in Release; `dist/` contains only the `hello` executable, which prints `Hello, World!` followed by a newline.

## Failure scenarios and handling
- CMake not found: stop and report that CMake is unavailable.
- GoogleTest download fails because the network is unavailable: stop at configure, report the download failure, and do not substitute a different dependency source.
- Test fails: stop, show the CTest output, and do not run install or run stages.
- `ci.sh` is not executable and returns `Permission denied`: run `chmod +x ci.sh`, verify the permission, then retry the same step.
- Wrong line endings: normalize only line endings to LF for `ci.sh` or CRLF for `ci.bat`, preserve file content, and verify again; if normalization cannot be done without changing content, stop and report it.
- An existing generated file differs from its template: do not overwrite it; report the file and difference.
- An unsupported or extra stage argument is supplied: report the invalid argument and exit with status 2.
- Stop at the first failure and report `FAILED STEP: <step> - <reason>`; never claim success without passing verification.
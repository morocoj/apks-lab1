---
name: github-actions
description: Use when creating or verifying the GitHub Actions workflow for the cross-platform hello build.
---

## Purpose
Define the CI matrix and delegate all build, test, install, and run logic to the `ci.sh` and `ci.bat` scripts supplied by `build-and-test`.

## When to use
Use for the `github-actions` stage of `/create-actions` or `/init`, after the build scripts exist.

## Inputs
- `branches`: `develop`, `master`.
- `os_matrix`: `ubuntu-latest`, `windows-latest`, `macos-latest`.

## Steps
1. Confirm `ci.sh` and `ci.bat` exist. If either is missing, stop and report `FAILED STEP: precondition - ci.sh or ci.bat is missing`.
2. Create `.github/workflows/` if missing. Create `.github/workflows/ci.yml` if missing; if it exists, update it minimally and preserve unrelated user changes. The complete workflow content must be:

   ```yaml
   name: CI

   on:
     push:
       branches: [develop, master]
     pull_request:
       branches: [develop, master]

   permissions:
     contents: read

   jobs:
     build-and-test:
       runs-on: ${{ matrix.os }}
       strategy:
         fail-fast: false
         matrix:
           os: [ubuntu-latest, windows-latest, macos-latest]
           include:
             - os: ubuntu-latest
               shell: bash
               script: "bash ./ci.sh"
             - os: windows-latest
               shell: cmd
               script: "ci.bat"
             - os: macos-latest
               shell: bash
               script: "bash ./ci.sh"
       defaults:
         run:
           shell: ${{ matrix.shell }}
       steps:
         - uses: actions/checkout@v5
         - name: Configure
           run: ${{ matrix.script }} configure
         - name: Build
           run: ${{ matrix.script }} build
         - name: Test
           run: ${{ matrix.script }} test
         - name: Install
           run: ${{ matrix.script }} install
         - name: Run
           run: ${{ matrix.script }} run
         - uses: actions/upload-artifact@v4
           with:
             name: hello-${{ matrix.os }}
             path: dist/
             if-no-files-found: error
   ```

3. Keep the workflow declarative: do not add build logic, CMake commands, or secrets. Each run step must call only the corresponding script stage shown above.

## Idempotency
If the workflow already matches the required configuration, leave it unchanged. When updating, change only the workflow portions needed to meet this specification; preserve unrelated user content and do not duplicate triggers, jobs, steps, or matrix entries. Do not create or modify files other than `.github/workflows/ci.yml`.

## Outputs
- `.github/workflows/ci.yml`, triggered by pushes and pull requests targeting `develop` or `master`.
- One `build-and-test` job with exactly the Ubuntu, Windows, and macOS matrix entries, five script-only stages, and one uploaded `dist/` artifact per OS.

## Verification
- Parse the YAML and confirm that the matrix has exactly `ubuntu-latest`, `windows-latest`, and `macos-latest`.
- Confirm both `push` and `pull_request` triggers include `develop` and `master`. With Python/PyYAML, YAML 1.1 may parse the key `on` as boolean `True`; read the trigger mapping as `data.get("on", data.get(True))`.
- Confirm every `run` step only invokes `${{ matrix.script }}` with one of `configure`, `build`, `test`, `install`, or `run`; confirm there are no CMake commands, inline build logic, or secrets.
- Validate that the workflow is accepted by GitHub Actions, not only by a generic YAML parser. In particular, if the platform rejects `${{ matrix.shell }}` in `defaults.run.shell`, report that semantic validation failure; do not claim the workflow passed or silently change the required workflow template.

## Example input and expected result
Input: `branches=develop,master`, `os_matrix=ubuntu-latest,windows-latest,macos-latest`.

Expected result: a workflow for pushes and pull requests to both branches, with one non-fail-fast job on each of the three operating systems. It runs Configure, Build, Test, Install, and Run only through the platform script, then uploads `dist/` as `hello-${{ matrix.os }}` and fails if no artifact files are found.

## Failure scenarios and handling
- `ci.sh` or `ci.bat` is missing: stop before writing the workflow and report `FAILED STEP: precondition - ci.sh or ci.bat is missing`.
- YAML syntax error: report the parser error, stop, and do not claim verification passed.
- GitHub Actions rejects the workflow semantics, including an expression in `defaults.run.shell`: report the exact validation error and stop; do not silently substitute different workflow content.
- Job fails only on Windows: inspect the batch script's CRLF line endings and required multi-config `--config Release` / `-C Release` flags; report the specific failed stage and output.
- Job fails on Linux or macOS with `Permission denied`: confirm the script call is `bash ./ci.sh` and that `ci.sh` exists; if direct execution is used elsewhere, the script must have executable permission.
- Stop at the first failure and report `FAILED STEP: <step> - <reason>`. Never report success without a passing validation.
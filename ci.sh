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

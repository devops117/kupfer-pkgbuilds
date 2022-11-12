#!/bin/bash

FILENAME=".srcinfo_initialised.json"

source "$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")/common.sh"

main() {
    local program=("rm" "-v")
    local verb="Cleaning"
    if [[ "$1" == "-n" ]] || [[ "$1" == "--noop" ]]; then
        program=("-n1" "echo")
        verb="(SIMULATION RUN) Would clean"
    fi
    echo "${verb} orphaned $FILENAME files that don't have an associated PKGBUILD:"
    find . -name "$FILENAME" -print0 | grep -z -v -f <(find_pkgbuild_dirs) | xargs --no-run-if-empty -0 "${program[@]}"
}

main "${@}"

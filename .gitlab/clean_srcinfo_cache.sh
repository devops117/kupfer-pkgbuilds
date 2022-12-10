#!/bin/bash

FILENAMES=(".srcinfo_initialised.json" ".srcinfo_meta.json" ".SRCINFO")

source "$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")/common.sh"

main() {
    local program=("rm" "-v")
    local verb="Cleaning"
    if [[ "$1" == "-n" ]] || [[ "$1" == "--noop" ]]; then
        program=("-n1" "echo")
        verb="(SIMULATION RUN) Would clean"
    fi
    fileargs=()
    for file in "${FILENAMES[@]}"; do
        fileargs+=(-name "$file" -or)
    done
    echo "${verb} orphaned srcinfo cache files that don't have an associated PKGBUILD:"
    find . -maxdepth 3 '(' "${fileargs[@]}" -false ')'  -print0 | grep -z -v -f <(find_pkgbuild_dirs) | xargs --no-run-if-empty -0 "${program[@]}"
}

main "${@}"

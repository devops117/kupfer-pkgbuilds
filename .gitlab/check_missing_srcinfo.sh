#!/bin/bash

source "$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")/common.sh"

FILENAMES=(
    ".SRCINFO"
    ".srcinfo_meta.json"
)

failed="false"
for dir in $(find_pkgbuild_dirs); do
    # find_pkgbuild_dirs already appends the slash
    for filename in "${FILENAMES[@]}"; do
        file="${dir}${filename}"
        if ! git ls-files -- "$file" >/dev/null; then
            echoerr "ERROR: ${file} is missing"
            failed="true"
        fi
    done
done

[[ "$failed" == "false" ]]

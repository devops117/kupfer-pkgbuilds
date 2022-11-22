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
        if ! { [[ -e "$file" ]] && [[ -n "$(git ls-files -- "$file")" ]] ; } then
            echoerr "ERROR: ${file} is missing from git"
            failed="true"
        fi
    done
done

[[ "$failed" == "false" ]]

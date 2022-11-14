#!/bin/bash

source "$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")/common.sh"

modified="false"

for f in $(git ls-files --modified); do
    modified=true
    echoerr "\nNag: file $f has been modified by the CI:" >&2
    git --no-pager diff --color=auto -- "$f"
done
[ "$modified" == "false" ]

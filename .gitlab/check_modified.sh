#!/bin/bash

modified="false"

for f in $(git ls-files --modified); do
    modified=true
    echo -e "\n\033[0;31mNag: file $f has been modified by the CI:\033[0m" >&2
    git diff --color=auto "$f"
done
[ "$modified" == "false" ]

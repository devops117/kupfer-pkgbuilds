#!/bin/bash
set -e
packages=()
for file in $(git diff --cached --name-only --diff-filter=AR | grep ".pkg"); do
    repo="$(dirname "$file")"
    dir=$(mktemp -d)
    tar xf "$file" -C "$dir"
    packages+=("$repo/$(grep pkgname "$dir"/.PKGINFO | cut -d " " -f 3)")
    rm -r "$dir"
done
list=${packages[*]}
join=${list// /, }
echo "Update $join"

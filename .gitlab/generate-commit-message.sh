#!/bin/bash
set -e
declare -A packages
for file in $(git diff --cached --name-only --diff-filter=AR | grep ".pkg"); do
    repo="$(dirname "$file")"
    dir=$(mktemp -d)
    tar xf "$file" -C "$dir"
    pkgname="$(grep pkgname "$dir"/.PKGINFO | cut -d " " -f 3)"
    pkgver="$(grep pkgver "$dir"/.PKGINFO | cut -d " " -f 3)"
    packages["$repo/$pkgname"]="$pkgver"
    rm -r "$dir"
done
pkgbuilds_dir="$(dirname "${BASH_SOURCE[0]}")"
commithash="$(cd "$pkgbuilds_dir" && git rev-parse HEAD)"
committag="$(cd "$pkgbuilds_dir" && ( git describe --tags --abbrev=4 HEAD || (echo "(couldn't retrieve git tag)" | tee /dev/stderr) ) )"
echo "Build for pkgbuilds.git commit $commithash, $committag:"
for pkg in "${!packages[@]}"; do
    echo "- update $pkg to ${packages[$pkg]}"
done

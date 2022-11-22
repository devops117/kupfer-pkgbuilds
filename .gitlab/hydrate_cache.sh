#!/bin/bash

CACHEFILE=".srcinfo_initialised.json"

source "$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")/common.sh"

scriptdir="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")"
pkgbuilds="$(readlink -f "${scriptdir}/..")"
tmpdir="$(mktemp -d)"
archive="$(readlink -f "$1")"
debug="$2"

checksum() {
    sha256sum "$1" | cut -d' ' -f1
}

debug() {
    if [[ "$debug" == "-v" ]]; then
        echo "DEBUG: $*"
    fi
}

for dir in "$tmpdir" "$pkgbuilds"; do
    if ! [ -e "$dir" ]; then
        echoerr "directory '$dir' DOESN'T EXIST!"
        exit 1
    fi
done

if ! { [[ -n "$1" ]] && [[ -e "$archive" ]]; } then
    echoerr "archive '$1' doesn't exist!"
    exit 1
fi

debug "using temp dir '$tmpdir'"

# extract archive
tar -xC "$tmpdir" -f "$archive"

for pkg in $(cd $pkgbuilds && find_pkgbuild_dirs); do
    pkgdir="${pkgbuilds}/${pkg}"
    tmppkg="${tmpdir}/${pkg}"

    cache="${tmppkg}${CACHEFILE}"
    if ! [[ -e "${cache}" ]]; then
        echo "no cache to rehydrate found for $pkg: $cache"
        continue
    fi

    echo "working on cache for $pkg"
    pkgchecksum="$(checksum "${pkgdir}/PKGBUILD")"
    if [[ -e "${pkgdir}/${CACHEFILE}" ]] && grep -q -e "$pkgchecksum" "${pkgdir}/${CACHEFILE}"; then
        echo "cache file already correct for $pkg with checksum $pkgchecksum"
        continue
    fi
    cp -v "$cache" "$pkgdir"
    if grep -q -e "$pkgchecksum" "$cache"; then
        cp -v "${tmppkg}"{.SRCINFO,.srcinfo_meta.json} "${pkgdir}"
    fi
done

rm -rf "$tmpdir"

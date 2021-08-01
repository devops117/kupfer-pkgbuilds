#!/bin/bash

# Copied from https://gitlab.archlinux.org/pacman/pacman-contrib/-/blob/master/src/updpkgsums.sh.in
# and modified to work with the local makepkg script

set -e
(
dir="$(pwd)"
cd $@

newbuildfile=$(mktemp "/tmp/updpkgsums.XXXXXX")

trap "rm -rf '$newbuildfile'" EXIT
sumtypes=(sha256)
newsums=$("$dir/scripts/makepkg.sh" -g) || (echo 'Failed to generate new checksums' && exit 1)
awk -v sumtypes="$sumtypes" -v newsums="$newsums" '
	$0 ~"^[[:blank:]]*(" sumtypes ")sums(_[^=]+)?=", $0 ~ "\\)[[:blank:]]*(#.*)?$" {
		if (!w) {
			print newsums
			w++
		}
		next
	}

	1
	END { if (!w) print newsums }
' PKGBUILD > "$newbuildfile" || (echo 'Failed to write new PKGBUILD' && exit 1)

cat "$newbuildfile" > PKGBUILD

)

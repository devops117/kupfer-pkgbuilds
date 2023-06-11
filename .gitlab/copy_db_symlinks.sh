#!/bin/bash
set -e

copy_symlink() {
    if (($# > 1)) ; then
            echo "Copying $# files"
    fi
    for f in "$@"; do
        if ! [[ -L "$f" ]] ; then
            echo "ERROR: '$f' doesn't exist or is not a link"
            return 1
        fi
        orig="$(readlink -f "$f")"
        rm "$f"
        cp -v "$orig" "$f"
    done
}


if (($# > 0)) ; then
    copy_symlink "$@"
fi

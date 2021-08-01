#!/bin/bash
set -e
repo="$(echo "$@" | cut -d "/" -f 1)"
dir="$(pwd)"

cd $@
pkgs="$($dir/scripts/makepkg.sh --config "$dir/scripts/makepkg.conf" --printsrcinfo | grep "pkgname = " | tr "\n" " " | sed "s/pkgname = //g")"
files="$($dir/scripts/makepkg.sh --config "$dir/scripts/makepkg.conf" --packagelist | sed "s|$(pwd)/||g" | tr "\n" " ")"

pkgrel=$(cat .dev)
sed -i "s/pkgrel=.*/pkgrel=$pkgrel/" PKGBUILD
rm .dev
cd $dir

cd prebuilts/$repo
repo-remove $repo.db.tar.xz $pkgs
rm $files
cd $dir

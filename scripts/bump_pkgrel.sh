#!/bin/bash
set -e
(
cd $@
source PKGBUILD
sed -i "s/pkgrel=$pkgrel/pkgrel=$((pkgrel + 1))/" PKGBUILD
)

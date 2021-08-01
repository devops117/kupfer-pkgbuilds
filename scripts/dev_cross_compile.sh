#!/bin/bash
set -e
(
cd $@
if [ ! -f .dev ]; then
  source PKGBUILD
  echo "$pkgrel" > .dev
fi
)
./scripts/update_sums.sh $@
./scripts/bump_pkgrel.sh $@
./scripts/cross_compile.sh $@
./scripts/add_packages.sh
./scripts/setup.sh

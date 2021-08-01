#!/bin/bash
set -e
for file in $(find ./{device,main} -name ".dev"); do
  pkg="$(echo "$file" | sed "s/\.\///" | sed "s/\/\.dev//")"
  echo "Resetting $pkg"
  ./scripts/dev_reset.sh $pkg
done

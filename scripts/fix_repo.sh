#!/bin/bash

for repo in main device; do
    rm prebuilts/$repo/$repo.db prebuilts/$repo/$repo.files
    cp prebuilts/$repo/$repo.db.tar.xz prebuilts/$repo/$repo.db
    cp prebuilts/$repo/$repo.files.tar.xz prebuilts/$repo/$repo.files
    rm -f prebuilts/$repo/$repo.db.tar.xz.old prebuilts/$repo/$repo.files.tar.xz.old
done

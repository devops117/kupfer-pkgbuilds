#!/bin/bash

build() {
  add_binary e2fsck
  add_binary resize2fs
  add_binary parted

  add_runscript
}

help() {
  cat <<HELPEOF
This hook resizes the root partition to the maximum available space
HELPEOF
}

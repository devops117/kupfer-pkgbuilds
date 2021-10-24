#!/bin/bash

build() {
  add_binary losetup
  add_file /etc/kupfer/deviceinfo

  add_runscript
}

help() {
  cat <<HELPEOF
This hook detects the rootfs image
HELPEOF
}

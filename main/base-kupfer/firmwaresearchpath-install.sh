#!/bin/bash

build() {
  add_runscript
}

help() {
  cat <<HELPEOF
This hook sets up the additional firmware search path at /lib/firmware/kupfer
HELPEOF
}

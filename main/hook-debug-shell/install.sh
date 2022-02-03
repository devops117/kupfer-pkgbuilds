#!/bin/bash

build() {
    add_runscript
    add_binary bash
    add_binary id
    add_binary usb-tethering
    add_binary mount
    add_binary /usr/lib/initcpio/continue_boot /bin/continue_boot
    add_file /etc/kupfer/deviceinfo
}

help() {
    cat <<HELPEOF
This hook spins up a telnet server in the early boot phase to debug stuff
HELPEOF
}

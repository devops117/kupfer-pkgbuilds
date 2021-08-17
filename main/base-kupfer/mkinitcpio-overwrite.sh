#!/bin/bash
source /etc/kupfer/mkinitcpio.conf
source /etc/kupfer/deviceinfo

for file in /etc/kupfer/mkinitcpio.conf.d/*; do
    source "$file"
done
cat >/etc/mkinitcpio.conf <<EOF
MODULES=($deviceinfo_modules_initfs ${MODULES[*]})
BINARIES=(${BINARIES[*]})
FILES=(${FILES[*]})
HOOKS=(${HOOKS[*]})
EOF
rm -f /usr/share/libalpm/hooks/90-mkinitcpio-install.hook

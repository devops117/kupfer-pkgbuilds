#!/bin/bash
BASE="$(cat /etc/kupfer/mkinitcpio.conf)"

if [ -n "$(ls -A /etc/kupfer/firmware-files 2>/dev/null)" ]
then
  FILES="$(cat /etc/kupfer/firmware-files/* | tr "\n" " ")"
  BASE="${BASE/PLACEHOLDER/$FILES}"
else
  BASE="${BASE/ PLACEHOLDER/}"
fi

printf "$BASE" > /etc/mkinitcpio.conf

#!/usr/bin/ash

run_hook() {
  echo -n /usr/lib/firmware/kupfer > /sys/module/firmware_class/parameters/path
}

#!/usr/bin/ash

run_hook() {
  device=$(resolve_device "$root")
  e2fsck -fy "${device}"
  resize2fs "${device}"
}

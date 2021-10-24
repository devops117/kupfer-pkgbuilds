#!/usr/bin/ash

run_hook() {
  if parted -s /dev/loop0 print free | tail -n2 | head -n1 | grep -qi "free space"; then
    echo "Found unallocated space. Resizing..."
    parted -s /dev/loop0 resizepart 2 100%
    partprobe
    e2fsck -fy /dev/loop0p2
    resize2fs /dev/loop0p2
  fi
}

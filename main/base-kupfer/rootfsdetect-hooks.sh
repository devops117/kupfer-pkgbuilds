#!/usr/bin/ash

run_hook() {
  # Some bootloaders mess with those options (e.g. OnePlus 6), therefore we need to overwrite them
  # This is not nice, but there is no other way (at least right now)
  export rwopt=rw
  export init=/sbin/init

  export root="/dev/disk/by-label/kupfer_root"
  eval "$(cat /etc/kupfer/deviceinfo)" || true
  deviceinfo_rootfs_image_sector_size="${deviceinfo_rootfs_image_sector_size:-512}"
  for kupfer_dev in "$deviceinfo_partitions_microsd" "$deviceinfo_partitions_data"; do
    if ! ( [ -n "$kupfer_dev" ] && [ -e "$kupfer_dev" ] ); then
      continue
    fi
    if [ ! -e "$root" ]; then
      losetup -P -b "$deviceinfo_rootfs_image_sector_size" /dev/loop0 "$kupfer_dev"
      partprobe /dev/loop0
    fi
    resolved="$(resolve_device "$root")"
    if [ -n "$resolved" ] ; then
        echo "found root=$root at $resolved"
        export root="$resolved"
        return
    fi
  done
  if [ ! -e "$(resolve_device "$root")" ]; then
    # Still doesn't exist, so we don't have a root partition
    echo "Failed to find root partition"
    unset root
  fi
}

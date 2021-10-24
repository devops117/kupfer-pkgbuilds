#!/usr/bin/ash

run_hook() {
  # Some bootloaders mess with those options (e.g. OnePlus 6), therefore we need to overwrite them
  # This is not nice, but there is no other way (at least right now)
  export rwopt=rw
  export init=/sbin/init

  export root="/dev/disk/by-label/kupfer_root"
  if [ ! -e "$root" ]; then
    eval "$(cat /etc/kupfer/deviceinfo)"
    deviceinfo_rootfs_image_sector_size="${deviceinfo_rootfs_image_sector_size:-512}"
    losetup -P -b "$deviceinfo_rootfs_image_sector_size" /dev/loop0 "$deviceinfo_partitions_data"
    partprobe /dev/loop0
  fi
  if [ ! -e "$(resolve_device "$root")" ]; then
    # Still doesn't exist, so we don't have a root partition
    echo "Failed to find root partition"
    unset root
  fi
}

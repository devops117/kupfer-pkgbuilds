#!/usr/bin/ash

run_hook() {
  # Some bootloaders mess with those options (e.g. OnePlus 6), therefore we need to overwrite them
  # This is not nice, but there is no other way (at least right now)
  export rwopt=rw
  export init=/sbin/init

  if [ -e "/dev/disk/by-label/kupfer" ]; then
    export root="/dev/disk/by-label/kupfer"
  else
    mkdir -p /mnt
    mount "$kupfer_data_partition" /mnt
    for path in /mnt/.stowaways /mnt /mnt/media/0; do
      if [ -f "$path/kupfer.img" ]; then
        loop_device=$(losetup -f)
        losetup -P "$loop_device" "$path/kupfer.img"
        export root="${loop_device}"
        break
      fi
    done
  fi
}

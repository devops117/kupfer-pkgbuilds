#!/bin/bash

set -e

if [ "$(id -u)" -ne "0" ]; then
  echo "This script requires root."
  exit 1
fi

if [ ! -f /etc/kupfer/deviceinfo ]; then
  echo "No deviceinfo found at /etc/kupfer/deviceinfo. This might be intentional"
  exit 1
fi

eval "$(cat /etc/kupfer/deviceinfo)"

dir=$(mktemp -d)

cat /boot/Image.gz "/boot/dtbs/$deviceinfo_dtb.dtb" > $dir/Image.gz-dtb

echo "Generating new boot.img"
mkbootimg \
  --kernel $dir/Image.gz-dtb \
  --ramdisk /boot/initramfs-linux.img \
  --base "$deviceinfo_flash_offset_base" \
  --second_offset "$deviceinfo_flash_offset_second" \
  --kernel_offset "$deviceinfo_flash_offset_kernel" \
  --ramdisk_offset "$deviceinfo_flash_offset_ramdisk" \
  --tags_offset "$deviceinfo_flash_offset_tags" \
  --pagesize "$deviceinfo_flash_pagesize" \
  --cmdline "kupfer rw kupfer_data_partition=$deviceinfo_partitions_data" \
  -o /boot/boot.img

AB_SLOT_SUFFIX=$(grep -o 'androidboot\.slot_suffix=..' /proc/cmdline | cut -d "=" -f2)

BOOT_PART="/dev/disk/by-partlabel/boot${AB_SLOT_SUFFIX}"

if [ -e "$BOOT_PART" ]; then
  echo "Running on the device"

  cmdline=$(unpack_bootimg --boot_img "$(readlink -f "$BOOT_PART")" --out "$dir" | grep -E "^command line args")

  if [[ $cmdline == *"kupfer"* ]]; then
    echo "Running with permanent boot.img"
    echo "Flashing new boot.img"
    dd if=/boot/boot.img of="$(readlink -f "$BOOT_PART")"
  elif [[ "$1" == "-f" ]]; then
    echo "Flashing new boot.img"
    dd if=/boot/boot.img of="$(readlink -f "$BOOT_PART")"
  else
    echo "Running with temporary boot.img"
    echo "Skip flashing new boot.img"
  fi
else
  echo "Not running on the device"
  echo "Skip flashing new boot.img"
fi

rm -rf "$dir"

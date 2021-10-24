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

cat /boot/Image.gz "/boot/dtbs/$deviceinfo_dtb.dtb" >$dir/Image.gz-dtb

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
  --cmdline "kupfer earlymodules=${deviceinfo_modules_initfs// /,} console=tty0" \
  -o /boot/boot.img

qhypstub_offset="508KiB"
qhypstub_size="4KiB"
lk2nd_bootimg_offset="512KiB"

flash_file="/boot/boot.img"
if [[ "$deviceinfo_lk2nd" == "true" ]]; then
  echo "Generating new boot.bin for lk2nd device"
  flash_file="/boot/boot.bin"
  dd if=/dev/zero of=$flash_file bs=$lk2nd_bootimg_offset count=1
  dd of=$flash_file bs=$qhypstub_offset count=1 conv=notrunc if=/boot/lk2nd.img
  dd of=$flash_file bs=$qhypstub_size count=1 conv=notrunc seek=$qhypstub_offset oflag=seek_bytes if=/boot/qhypstub.bin
  dd of=$flash_file conv=notrunc oflag=append if=/boot/boot.img
fi

AB_SLOT_SUFFIX=$(grep -o 'androidboot\.slot_suffix=..' /proc/cmdline | cut -d "=" -f2)
BOOT_PART="/dev/disk/by-partlabel/boot${AB_SLOT_SUFFIX}"

if [ -e "$BOOT_PART" ]; then
  echo "Running on the device"

  BOOT_PART="$(readlink -f "$BOOT_PART")"

  dd if="$BOOT_PART" of=/tmp/boot.bin
  if [[ "$deviceinfo_lk2nd" == "true" ]]; then
    dd if=/tmp/boot.bin of=/tmp/boot.img skip=$lk2nd_bootimg_offset iflag=skip_bytes
  else
    cp /tmp/boot.bin /tmp/boot.img
  fi

  permanent=false
  if [[ "$(file /tmp/boot.img)" != "/tmp/boot.img: data" ]]; then
    cmdline=$(unpack_bootimg --boot_img /tmp/boot.img --out "$dir" | grep -E "^command line args")
    if [[ $cmdline == *"kupfer"* ]]; then
      permanent=true
    fi
  fi

  if [[ $permanent == "true" ]]; then
    echo "Running with permanent boot.img"
    echo "Flashing new boot.img"
    dd if=$flash_file of="$BOOT_PART"
  elif [[ "$1" == "-f" ]]; then
    echo "Flashing new boot.img"
    dd if=$flash_file of="$BOOT_PART"
  else
    echo "Running with temporary boot.img"
    echo "Skip flashing new boot.img"
  fi
else
  echo "Not running on the device"
  echo "Skip flashing new boot.img"
fi

rm -rf "$dir" /tmp/boot.bin /tmp/boot.img

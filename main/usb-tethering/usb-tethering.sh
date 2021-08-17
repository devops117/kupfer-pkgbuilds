#!/bin/bash

# ConfigFS script is taken from postmarketOS
# https://postmarketos.org

set -e

if [ "$(id -u)" -ne "0" ]; then
  echo "This script requires root."
  exit 1
fi

enable_files=0
if [[ "$1" == "--files" ]]; then
  enable_files=1
fi

if [ ! -f /etc/kupfer/deviceinfo ]; then
  echo "No deviceinfo found at /etc/kupfer/deviceinfo. This might be intentional"
  exit 1
fi

eval "$(cat /etc/kupfer/deviceinfo)"

# http://www.linux-usb.org/usb.ids
deviceinfo_usb_idVendor="0x1d6b"  # Linux Foundation
deviceinfo_usb_idProduct="0x0104" # Multifunction Composite Gadget

deviceinfo_manufacturer="kupfer"
deviceinfo_name="Arch Linux ARM"
deviceinfo_usb_serialnumber="kupfer"

deviceinfo_usb_rndis_function="rndis.usb0"
deviceinfo_usb_mass_storage_function="mass_storage.0"

setup_usb_tethering_configfs() {
  CONFIGFS=/sys/kernel/config/usb_gadget/

  if ! [ -e "$CONFIGFS" ]; then
    echo "$CONFIGFS does not exist, skipping configfs usb gadget"
    return
  fi

  # Remove existing gadget to replace it
  rm $CONFIGFS/g1/configs/c.1/$deviceinfo_usb_rndis_function $CONFIGFS/g1/configs/c.1/$deviceinfo_usb_mass_storage_function -rf

  echo "Setting up an USB gadget through configfs"
  # Create an usb gadet configuration
  mkdir -p $CONFIGFS/g1
  echo "$deviceinfo_usb_idVendor" >"$CONFIGFS/g1/idVendor"
  echo "$deviceinfo_usb_idProduct" >"$CONFIGFS/g1/idProduct"

  # Create english (0x409) strings
  mkdir -p $CONFIGFS/g1/strings/0x409

  echo "$deviceinfo_manufacturer" >"$CONFIGFS/g1/strings/0x409/manufacturer"
  echo "$deviceinfo_usb_serialnumber" >"$CONFIGFS/g1/strings/0x409/serialnumber"
  echo "$deviceinfo_name" >"$CONFIGFS/g1/strings/0x409/product"

  enable_microsd=0
  root_mountpoint=""
  if [[ "$enable_files" == "1" ]]; then
    root_mountpoint="$(df / | grep -E -o '^[/a-z0-9]*')"
    if [[ "$deviceinfo_partitions_microsd" != "" ]] && [ -e "$deviceinfo_partitions_microsd" ] && [[ "$root_mountpoint" != "$deviceinfo_partitions_microsd" ]]; then
      echo "Detected SD card that is not the root mountpoint"
      enable_microsd=1
    fi
  fi

  # Create rndis function
  mkdir -p $CONFIGFS/g1/functions/"$deviceinfo_usb_rndis_function"
  # Create mass_storage functions
  if [[ "$enable_files" == "1" ]]; then
    mkdir -p $CONFIGFS/g1/functions/"$deviceinfo_usb_mass_storage_function"
    if [[ "$enable_microsd" == "1" ]]; then
      mkdir -p $CONFIGFS/g1/functions/"$deviceinfo_usb_mass_storage_function/lun.1"
    fi
  fi

  # Create configuration instance for the gadget
  mkdir -p $CONFIGFS/g1/configs/c.1
  mkdir -p $CONFIGFS/g1/configs/c.1/strings/0x409
  echo "rndis" >$CONFIGFS/g1/configs/c.1/strings/0x409/configuration

  # Link the rndis instance to the configuration
  ln -s $CONFIGFS/g1/functions/"$deviceinfo_usb_rndis_function" $CONFIGFS/g1/configs/c.1

  if [[ "$enable_files" == "1" ]]; then
    # Set up mass storage to rootfs
    echo "$root_mountpoint" >$CONFIGFS/g1/functions/"$deviceinfo_usb_mass_storage_function"/lun.0/file
    echo "root" >$CONFIGFS/g1/functions/"$deviceinfo_usb_mass_storage_function"/lun.0/inquiry_string

    # Set up mass storage to the microSD if there is one
    if [[ "$enable_microsd" == "1" ]]; then
      echo "$deviceinfo_partitions_microsd" >$CONFIGFS/g1/functions/"$deviceinfo_usb_mass_storage_function"/lun.1/file
      echo "microSD" >$CONFIGFS/g1/functions/"$deviceinfo_usb_mass_storage_function"/lun.1/inquiry_string
    fi

    # Link the mass_storage instance to the configuration
    ln -s $CONFIGFS/g1/functions/"$deviceinfo_usb_mass_storage_function" $CONFIGFS/g1/configs/c.1
  fi

  # Check if there's an USB Device Controller
  if [ -z "$(ls /sys/class/udc)" ]; then
    echo "No USB Device Controller available"
    return
  fi

  # Link the gadget instance to an USB Device Controller. This activates the gadget.
  # See also: https://github.com/postmarketOS/pmbootstrap/issues/338
  echo "$(ls /sys/class/udc)" >$CONFIGFS/g1/UDC
}

# And we go.
setup_usb_tethering_configfs
ip address add 172.16.42.1/24 dev usb0 || true
ip link set usb0 up

#!/bin/bash
if [ "$(id -u)" -ne "0" ]; then
  echo "This script requires root."
  exit 1
fi

set -ex

if [ ! -d "rootfs" ]; then
  mkdir -p rootfs
  pacstrap -C scripts/pacman.conf -M rootfs base base-devel
  cp scripts/pacman.conf rootfs/etc/pacman.conf
else
  cp scripts/pacman.conf rootfs/etc/pacman.conf
  pacman -Syuu --root rootfs --noconfirm --overwrite=* --needed --arch aarch64 --config scripts/pacman.conf
fi

arch-chroot rootfs /bin/bash -c "yes | pacman -Scc"

# So we can run as root user
sed -i "s/EUID == 0/EUID == -1/g" rootfs/usr/bin/makepkg
# Fix makepkg in alpine
sed -i "s/\/usr\/bin\/bash/\/bin\/bash/g" rootfs/usr/bin/makepkg

# Dirty patch the local makepkg for our purposes
cp rootfs/usr/bin/makepkg scripts/makepkg.sh
# So pacman uses the correct rootfs, arch and config file
sed -i "s|run_pacman |run_pacman --root \"$(pwd)\/rootfs\" --arch aarch64 --config \"$(pwd)\/scripts/pacman.conf\" |g" scripts/makepkg.sh

#!/bin/bash

function check_already_built() {
  repo="$(echo "$1" | cut -d "/" -f 1)"
  dir="$(pwd)"
  cd "$1"
  readarray -t lines <<<$"$("$dir/scripts/makepkg.sh" --config "$dir/scripts/makepkg.conf" --packagelist -f -A --noconfirm)" #" vscode is broken lol
  for line in "${lines[@]}"; do
    file="$(basename "$line")"
    if [ ! -f "$dir/prebuilts/$repo/$file" ]; then
      cd "$dir"
      echo "0"
      return 0
    fi
  done
  cd "$dir"
  echo "1"
}

function add_packages_to_repo() {
  for repo in main device; do
    for file in ./$repo/*/*.pkg* ./$repo/*/*/*.pkg*; do
      if [[ "$file" == *"*.pkg*" ]]; then
        # This happens when there are no packages for the repo
        continue
      fi
      mkdir -p prebuilts/"$repo"
      if [ ! -f "prebuilts/$repo/$(basename "$file")" ]; then
        mv "$file" "prebuilts/$repo/"
        repo-add -R -n -p "prebuilts/$repo/$repo.db.tar.xz" "prebuilts/$repo/$(basename "$file")"
      else
        rm "$file"
      fi
    done
  done
}

function cross_compile_package() {
  (
    dir="$(pwd)"
    cd "$1"
    LANG=C MAKEFLAGS="-j$(nproc --all)" "$dir/scripts/makepkg.sh" --config "$dir/scripts/makepkg.conf" --nobuild -s -f -A --noconfirm
  )

  if [ "$(check_already_built "$1")" == "0" ]; then
    (
      dir="$(pwd)"
      cd "$1"
      QEMU_LD_PREFIX=/usr/aarch64-linux-gnu LANG=C MAKEFLAGS="-j$(nproc --all)" "$dir/scripts/makepkg.sh" --config "$dir/scripts/makepkg.conf" -f -A --noconfirm --noextract --skipinteg --holdver
    )
  fi
}

function host_compile_package() {
  root="$(pwd)/rootfs"
  cleanup() {
    umount -lc "$root"/mnt/pkg
    umount -lc "$root"
  }
  trap cleanup EXIT
  mount -o bind "$root" "$root"
  mkdir -p "$root"/mnt/pkg
  mount -o bind "$1" "$root"/mnt/pkg
  arch-chroot "$root" /bin/bash -c "cd /mnt/pkg && LANG=C MAKEFLAGS=-j$(nproc --all) makepkg --nobuild -s -f -A --noconfirm"

  if [ "$(check_already_built "$1")" == "0" ]; then
    arch-chroot "$root" /bin/bash -c "cd /mnt/pkg && LANG=C MAKEFLAGS=-j$(nproc --all) makepkg -f -A --noconfirm --noextract --skipinteg --holdver"
  fi
}

#!/bin/bash

# Library of reusable functions 公共函数（工具库）

# 从 AUR PKGBUILD 中提取 pkgver
get_aur_pkgver() {
  aur_pkg="$1"

  curl -s "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=$aur_pkg" \
    | grep '^pkgver=' | cut -d= -f2
}

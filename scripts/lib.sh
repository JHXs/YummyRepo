#!/bin/bash

# Library of reusable functions 公共函数（工具库）

# 从 AUR PKGBUILD 中提取 pkgver
# 参数: $1=aur_pkg_name
# 输出: pkgver
get_aur_pkgver() {
  aur_pkg="$1"

  curl -s "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=$aur_pkg" \
    | grep '^pkgver=' | cut -d= -f2
}

# 下载文件并验证完整性
# 参数: $1=url, $2=output_path
# 返回: 0=成功, 1=失败
download_file() {
  local url="$1"
  local output="$2"

  mkdir -p "$(dirname "$output")"

  if ! wget -O "$output" "$url"; then
    echo "Error: Failed to download $url"
    rm -f "$output"
    return 1
  fi

  if [ ! -f "$output" ] || [ ! -s "$output" ]; then
    echo "Error: Downloaded file is empty or missing"
    rm -f "$output"
    return 1
  fi

  return 0
}


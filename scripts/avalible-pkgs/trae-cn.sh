#!/bin/bash

source scripts/lib.sh # 公共函数（工具库）

update_trae-cn() {
  name="trae-cn"
  aur_pkg="trae-cn-desktop-bin"

  pkgver=$(get_aur_pkgver $aur_pkg)

  state_file="state/$name.version"
  old=$(cat "$state_file" 2>/dev/null || echo "")

  if [ "$pkgver" = "$old" ]; then
    echo "$name: no update ($pkgver)"
    return
  fi

  echo "$name: new version detected ($pkgver)"

  prune_local_rpms "$name"

  url="https://lf-cdn.trae.com.cn/obj/trae-com-cn/pkg/app/releases/stable/${pkgver}/linux/Trae%20CN-linux-x64.rpm"

  arch="x86_64"

  if ! download_file "$url" "packages/$name-v$pkgver-$arch.rpm"; then
    return 1
  fi

  echo "更新完成: $name -> $pkgver"
  echo "$pkgver" > "$state_file"
  UPDATED=1
}
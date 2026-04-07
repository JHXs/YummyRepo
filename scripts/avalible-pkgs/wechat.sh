# #!/bin/bash

source scripts/lib.sh # 公共函数（工具库）

update_wechat() {
  name="wechat"
  aur_pkg="wechat-bin"

  pkgver=$(get_aur_pkgver $aur_pkg)

  state_file="state/$name.version"
  old=$(cat "$state_file" 2>/dev/null || echo "")

  if [ "$pkgver" = "$old" ]; then
    echo "$name: no update ($pkgver)"
    return
  fi

  echo "$name: new version detected ($pkgver)"

  prune_local_rpms "$name"

  # https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.rpm
  url="https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.rpm"

  arch="x86_64"

  if ! download_file "$url" "packages/$name-v$pkgver-$arch.rpm"; then
    return 1
  fi

  echo "更新完成: $name -> $pkgver"
  echo "$pkgver" > "$state_file"
  UPDATED=1
}
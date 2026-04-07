# #!/bin/bash
# LinuxQQ 的版本更新检测和下载脚本

source scripts/lib.sh # 公共函数（工具库）

update_linuxqq() {
  name="linuxqq"
  aur_pkg="linuxqq-nt-bwrap"

  pkgver=$(curl -s https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=${aur_pkg} | \
  grep '^_base_pkgver=' | cut -d= -f2)

  state_file="state/$name.version"
  old=$(cat "$state_file" 2>/dev/null || echo "")

  if [ "$pkgver" = "$old" ]; then
    echo "$name: no update ($pkgver)"
    return
  fi

  echo "$name: new version detected ($pkgver)"

  prune_local_rpms "$name"

  # https://dldir1v6.qq.com/qqfile/qq/QQNT/Linux/QQ_3.2.27_260401_x86_64_01.rpm
  # https://dldir1v6.qq.com/qqfile/qq/QQNT/Linux/QQ_3.2.27_260401_amd64_01.deb
  url="https://dldir1v6.qq.com/qqfile/qq/QQNT/Linux/QQ_${pkgver}_x86_64_01.rpm"

  arch="x86_64"

  if ! download_file "$url" "packages/$name-v$pkgver-$arch.rpm"; then
    return 1
  fi

  echo "更新完成: $name -> $pkgver"
  echo "$pkgver" > "$state_file"
  UPDATED=1
}
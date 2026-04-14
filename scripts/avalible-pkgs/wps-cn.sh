#!/bin/bash

# 目前还不行

source scripts/lib.sh # 公共函数（工具库）

update_wps-cn() {
# https://wps-linux-personal.wpscdn.cn/wps/download/ep/Linux2023/25838/wps-office-12.1.2.25838.AK.preread.sw-1-648474.x86_64.rpm?t=1775476611&k=0453247c5b156ea8ea070dc8bc3c44d0
# https://wps-linux-personal.wpscdn.cn/wps/download/ep/Linux2023/25838/wps-office_12.1.2.25838.AK.preread.sw_648473_amd64.deb?t=1775469687&k=ee5f53671551f45a366b2afd03c0a51c

  name="wps-cn"
  aur_pkg="wps-office-cn"

  pkgver=$(get_aur_pkgver $aur_pkg)

  state_file="state/$name.version"
  old=$(cat "$state_file" 2>/dev/null || echo "")

  if [ "$pkgver" = "$old" ]; then
    echo "$name: no update ($pkgver)"
    return
  fi

  echo "$name: new version detected ($pkgver)"

  prune_local_rpms "$name"

  arch=x86_64

  url=$(_get_source_url $arch)

  echo "Downloading $url"

  if ! download_file "$url" "/tmp/$name.rpm"; then
    return 1
  fi

  mv "/tmp/$name.rpm" "packages/$name-$pkgver-$arch.rpm"

  echo "$pkgver" > "$state_file"
  UPDATED=1
}

_get_source_url() {
      local furl="https://wps-linux-personal.wpscdn.cn/wps/download/ep/Linux2023/${pkgver##*.}/wps-office-${pkgver}.AK.preread.sw.Personal-1-663297.${arch}.rpm"
      local uri="${furl#https://wps-linux-personal.wpscdn.cn}"
      local secrityKey='7f8faaaa468174dc1c9cd62e5f218a5b'
      local timestamp10=$(date '+%s')
      local md5hash=$(echo -n "${secrityKey}${uri}${timestamp10}" | md5sum)
      #echo "$md5hash"
      #echo "$md5hash"
      #exit 1
      echo "${furl}?t=${timestamp10}&k=${md5hash%% *}"
  }
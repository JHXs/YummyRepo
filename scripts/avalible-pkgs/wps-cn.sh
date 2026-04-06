#!/bin/bash

update_wps-cn() {
# https://wps-linux-personal.wpscdn.cn/wps/download/ep/Linux2023/25838/wps-office-12.1.2.25838.AK.preread.sw-1-648474.x86_64.rpm?t=1775468936&k=61d025378ce89975a93a108944a5e2a1
# https://wps-linux-personal.wpscdn.cn/wps/download/ep/Linux2023/25838/wps-office_12.1.2.25838.AK.preread.sw_648473_amd64.deb?t=1775469687&k=ee5f53671551f45a366b2afd03c0a51c

  name="wps-cn"
  aur_pkg="wps-office-cn"

  pkgver=$(curl -s "https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=$aur_pkg" \
    | grep '^pkgver=' | cut -d= -f2)

  state_file="state/$name.version"
  old=$(cat "$state_file" 2>/dev/null || echo "")

  if [ "$pkgver" = "$old" ]; then
    echo "$name: no update"
    return
  fi

  arch="amd64"
  furl="https://wps-linux-personal.wpscdn.cn/wps/download/ep/Linux2023/${pkgver##*.}/wps-office_${pkgver}.AK.preread.sw_648473_${arch}.deb"
  uri="${furl#https://wps-linux-personal.wpscdn.cn}"
  secrityKey='7f8faaaa468174dc1c9cd62e5f218a5b'

  timestamp10=$(date '+%s')
  md5hash=$(echo -n "${secrityKey}${uri}${timestamp10}" | md5sum | awk '{print $1}')

  url="${furl}?t=${timestamp10}&k=${md5hash}"

  wget -O "/tmp/$name.deb" "$url"

  alien -r "/tmp/$name.deb"
  mv *.rpm "packages/$name-$pkgver.rpm"

  echo "$pkgver" > "$state_file"
  UPDATED=1
}
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

# 获取 GitHub 最新 release JSON
# 参数: $1=repo (owner/name)
get_github_latest_release_json() {
  local repo="$1"
  curl -s "https://api.github.com/repos/$repo/releases/latest"
}

# 从 release JSON 提取 release id
# 参数: $1=release_json
get_github_release_id() {
  local release_json="$1"
  echo "$release_json" | jq -r '.id // empty'
}

# 从 release JSON 提取 rpm 资产下载链接
# 参数: $1=release_json
get_github_rpm_urls() {
  local release_json="$1"
  echo "$release_json" | jq -r '.assets[] | select(.name | endswith(".rpm") and (contains("x64") or contains("x86_64") or contains("amd64"))) | .browser_download_url'
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

# 删除某软件已有的 RPM 包
# 参数: $1=软件名前缀（例如 wechat、linuxqq、wps-cn）
prune_local_rpms() {
  local prefix="$1"

  if [ -z "$prefix" ]; then
    echo "Warning: prune_local_rpms called with empty prefix"
    return 0
  fi

  find packages -maxdepth 1 -type f -name "${prefix}-*.rpm" -print -delete || true
}


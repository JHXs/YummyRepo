#!/bin/bash
# set -e

mkdir -p packages
mkdir -p state

UPDATED=0

source scripts/lib.sh # 公共函数（工具库）

ENABLED_FILE="scripts/enabled.list"

declare -a enabled_pkgs=()
declare -A enabled_map=()

# 读取启用列表：支持空行、整行注释和行内注释。
while IFS= read -r raw_line || [ -n "$raw_line" ]; do
  pkg="${raw_line%%#*}"
  pkg="$(echo "$pkg" | xargs)"

  if [ -z "$pkg" ]; then
    continue
  fi

  enabled_pkgs+=("$pkg")
  enabled_map["$pkg"]=1
done < "$ENABLED_FILE"

# 注释即下架：不在启用列表的软件会删除本地 RPM 和对应 state。
for script_path in scripts/avalible-pkgs/*.sh; do
  pkg="$(basename "$script_path" .sh)"

  if [ -n "${enabled_map[$pkg]+x}" ]; then
    continue
  fi

  removed_any=0

  if compgen -G "packages/${pkg}-*.rpm" > /dev/null; then
    echo "$pkg: disabled, removing existing RPMs"
    prune_local_rpms "$pkg"
    removed_any=1
  fi

  state_file="state/$pkg.version"
  if [ -f "$state_file" ]; then
    rm -f "$state_file"
    echo "$pkg: disabled, removing state file"
    removed_any=1
  fi

  if [ "$removed_any" -eq 1 ]; then
    UPDATED=1
  fi
done

# 每个软件一个脚本，命名为 软件名.sh，里面定义一个函数 update_软件名 来检查更新和下载。
for pkg in "${enabled_pkgs[@]}"; do
  script="scripts/avalible-pkgs/$pkg.sh"

  if [ -f "$script" ]; then
    source "$script"
    "update_$pkg"
  else
    echo "Warning: $pkg not found"
  fi
done

# 输出是否有更新（给 workflow 用）
if [ -n "${GITHUB_ENV:-}" ]; then
  echo "UPDATED=$UPDATED" >> "$GITHUB_ENV"
fi

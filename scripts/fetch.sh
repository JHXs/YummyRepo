#!/bin/bash
set -e

mkdir -p packages
mkdir -p state

UPDATED=0

source scripts/lib.sh # 公共函数（工具库）

ENABLED_FILE="scripts/enabled.list"
# 每个软件一个脚本，命名为 软件名.sh，里面定义一个函数 update_软件名 来检查更新和下载。
while IFS= read -r raw_line || [ -n "$raw_line" ]; do
  # 支持空行、整行注释和行内注释
  pkg="${raw_line%%#*}"
  pkg="$(echo "$pkg" | xargs)"

  if [ -z "$pkg" ]; then
    continue
  fi

  script="scripts/avalible-pkgs/$pkg.sh"

  if [ -f "$script" ]; then
    source "$script"
    "update_$pkg"
  else
    echo "Warning: $pkg not found"
  fi
done < "$ENABLED_FILE"

# 输出是否有更新（给 workflow 用）
if [ -n "${GITHUB_ENV:-}" ]; then
  echo "UPDATED=$UPDATED" >> "$GITHUB_ENV"
fi
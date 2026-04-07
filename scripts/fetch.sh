#!/bin/bash
set -e

mkdir -p packages
mkdir -p state

UPDATED=0

source scripts/lib.sh # 公共函数（工具库）

ENABLED_FILE="scripts/enabled.list"
# 每个软件一个脚本，命名为 软件名.sh，里面定义一个函数 update_软件名 来检查更新和下载。
for pkg in $(cat "$ENABLED_FILE"); do
  script="scripts/avalible-pkgs/$pkg.sh"

  if [ -f "$script" ]; then
    source "$script"
    "update_$pkg"
  else
    echo "Warning: $pkg not found"
  fi
done

# 输出是否有更新（给 workflow 用）
echo "UPDATED=$UPDATED" >> $GITHUB_ENV
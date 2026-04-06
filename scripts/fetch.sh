#!/bin/bash
set -e

mkdir -p packages
mkdir -p state

STATE_FILE="state/releases.json"

# 初始化 state
if [ ! -f "$STATE_FILE" ]; then
  echo "{}" > "$STATE_FILE"
fi

REPOS=(
  "chen08209/FlClash"
  "xishang0128/sparkle"
  "nashaofu/shell360"
)

UPDATED=0

for repo in "${REPOS[@]}"; do
  echo "Checking $repo..."

  json=$(curl -s https://api.github.com/repos/$repo/releases/latest)

  release_id=$(echo "$json" | jq -r '.id')

  old_id=$(jq -r --arg repo "$repo" '.[$repo] // "null"' "$STATE_FILE")

  if [ "$release_id" = "$old_id" ]; then
    echo "No update for $repo"
    continue
  fi

  echo "New release detected for $repo!"

  # 下载 RPM
  echo "$json" | jq -r '.assets[] | select(.name | endswith(".rpm")) | .browser_download_url' \
  | while read url; do
      echo "Downloading $url"
      wget -nc -P packages "$url"
    done

  # 更新 state
  tmp=$(mktemp)
  jq --arg repo "$repo" --arg id "$release_id" '.[$repo]=$id' "$STATE_FILE" > "$tmp"
  mv "$tmp" "$STATE_FILE"

  UPDATED=1
done

# 输出是否有更新（给 workflow 用）
echo "UPDATED=$UPDATED" >> $GITHUB_ENV
#!/bin/bash
set -e

mkdir -p packages
cd packages

# 你要抓的 GitHub 项目列表
REPOS=(
  "chen08209/FlClash"
  "xishang0128/sparkle"
)

for repo in "${REPOS[@]}"; do
  echo "Fetching $repo ..."

  urls=$(curl -s https://api.github.com/repos/$repo/releases/latest \
    | jq -r '.assets[] | select(.name | endswith(".rpm") and (contains("x86_64") or contains("amd64"))) | .browser_download_url')

  for url in $urls; do
    echo "Downloading $url"
    wget -nc "$url"
  done
done
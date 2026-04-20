#!/bin/bash

source scripts/lib.sh # 公共函数（工具库）

update_rclone-manager() {
  name="rclone-manager"
  repo="Zarestia-Dev/rclone-manager"

  json=$(get_github_latest_release_json "$repo")
  release_id=$(get_github_release_id "$json")

  state_file="state/$name.version"
  old=$(cat "$state_file" 2>/dev/null || echo "")

  if [ -z "$release_id" ]; then
    echo "$name: failed to get latest release id"
    return 1
  fi

  if [ "$release_id" = "$old" ]; then
    echo "$name: no update ($release_id)"
    return
  fi

  mapfile -t urls < <(get_github_rpm_urls "$json")

  if [ "${#urls[@]}" -eq 0 ]; then
    echo "$name: no rpm asset in latest release"
    return
  fi

  echo "$name: new release detected ($release_id)"

  prune_local_rpms "$name"

  for url in "${urls[@]}"; do
    file_name="${url%%\?*}"
    file_name="${file_name##*/}"
    output="packages/${name}-${file_name}"

    if ! download_file "$url" "$output"; then
      return 1
    fi
  done

  echo "$release_id" > "$state_file"
  UPDATED=1
}

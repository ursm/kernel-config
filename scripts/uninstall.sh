#!/bin/sh
set -eu

dest=${DEST:-/etc/kernel/config.d}
manifest="$dest/.kernel-config.manifest"

if [ ! -f "$manifest" ]; then
  echo "No manifest found at $manifest; nothing to uninstall." >&2
  exit 0
fi

while IFS= read -r f; do
  rm -f "$dest/$f"
done < "$manifest"

rm -f "$manifest"


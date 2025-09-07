#!/bin/sh
set -eu

dest=${DEST:-/etc/kernel/config.d}
arch=$(uname -m)
tmp=$(mktemp)
manifest="$dest/.kernel-config.manifest"

mkdir -p "$dest"

# Build the list of files to install for this arch
for f in *.config; do
  case "$f" in
    10-x86.config)
      case "$arch" in x86_64|i?86) printf '%s\n' "$f" ;; esac ;;
    *) printf '%s\n' "$f" ;;
  esac
done | sort -u > "$tmp"

# Remove files previously installed by this project that are no longer present
if [ -f "$manifest" ]; then
  while IFS= read -r f; do
    if ! grep -Fxq "$f" "$tmp"; then
      rm -f "$dest/$f"
    fi
  done < "$manifest"
fi

# Copy current set
while IFS= read -r f; do
  cp "$f" "$dest/"
done < "$tmp"

# Update manifest
cp "$tmp" "$manifest"
rm -f "$tmp"


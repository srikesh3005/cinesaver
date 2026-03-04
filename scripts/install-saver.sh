#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 /path/to/CineSaver.saver"
  exit 1
fi

SOURCE="$1"
TARGET_DIR="$HOME/Library/Screen Savers"
TARGET="$TARGET_DIR/CineSaver.saver"

if [ ! -d "$SOURCE" ]; then
  echo "Error: '$SOURCE' is not a .saver bundle directory"
  exit 1
fi

mkdir -p "$TARGET_DIR"
rm -rf "$TARGET"
cp -R "$SOURCE" "$TARGET"

echo "Installed to: $TARGET"
echo "Open System Settings > Screen Saver and select CineSaver."

#!/usr/bin/env bash
set -euo pipefail

FRAME_DIR="${PHOTOFRAME_DIR:-$HOME/Pictures/frame}"
DELAY="${PHOTOFRAME_DELAY:-20}"

xset s off
xset -dpms
xset s noblank

if command -v unclutter >/dev/null 2>&1; then
  unclutter -idle 0.5 -root &
fi

exec feh \
  --fullscreen \
  --hide-pointer \
  --slideshow-delay "$DELAY" \
  --randomize \
  --auto-rotate \
  --auto-zoom \
  "$FRAME_DIR"

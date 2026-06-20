#!/usr/bin/env bash
# Resize simulator screenshots to App Store Connect slot dimensions.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DATE_TAG="${DATE_TAG:-2026-06-19}"

IPHONE_SIZE="1284x2778"
IPAD_SIZE="2064x2752"

resize_dir() {
  local src_dir="$1" dest_dir="$2" size="$3"
  mkdir -p "$dest_dir"
  shopt -s nullglob
  for src in "$src_dir"/*.png; do
    local name
    name="$(basename "$src")"
    sips -z "${size#*x}" "${size%x*}" "$src" --out "$dest_dir/$name" >/dev/null
  done
}

resize_dir "$ROOT/marketing-screenshots/raw/$DATE_TAG" \
  "$ROOT/marketing-screenshots/asc/$DATE_TAG" "$IPHONE_SIZE"

resize_dir "$ROOT/marketing-screenshots/ipad/raw/$DATE_TAG" \
  "$ROOT/marketing-screenshots/ipad/asc/$DATE_TAG" "$IPAD_SIZE"

echo "ASC-sized screenshots written:"
echo "  iPhone ($IPHONE_SIZE): marketing-screenshots/asc/$DATE_TAG/"
echo "  iPad   ($IPAD_SIZE): marketing-screenshots/ipad/asc/$DATE_TAG/"

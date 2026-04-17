#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  png_to_webp.sh <file-or-directory> [quality]

Examples:
  png_to_webp.sh assets/images/logo.png
  png_to_webp.sh assets/images 80

Notes:
  - Converts .png files to .webp
  - Keeps the original .png files
  - Prefers `cwebp` when available
  - Falls back to ImageMagick `magick` when available
EOF
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage
  exit 1
fi

input_path="$1"
quality="${2:-80}"

if ! [[ "$quality" =~ ^[0-9]+$ ]] || (( quality < 0 || quality > 100 )); then
  echo "Quality must be an integer between 0 and 100." >&2
  exit 1
fi

if [[ ! -e "$input_path" ]]; then
  echo "Path not found: $input_path" >&2
  exit 1
fi

convert_with_cwebp() {
  local src="$1"
  local dest="$2"
  cwebp -quiet -q "$quality" "$src" -o "$dest"
}

convert_with_magick() {
  local src="$1"
  local dest="$2"
  magick "$src" -quality "$quality" "$dest"
}

if command -v cwebp >/dev/null 2>&1; then
  converter="convert_with_cwebp"
elif command -v magick >/dev/null 2>&1; then
  converter="convert_with_magick"
else
  echo "Missing converter. Install either 'cwebp' or ImageMagick 'magick'." >&2
  exit 1
fi

convert_one() {
  local src="$1"
  local dest="${src%.*}.webp"
  "$converter" "$src" "$dest"
  echo "Converted: $src -> $dest"
}

if [[ -f "$input_path" ]]; then
  case "$input_path" in
    *.png|*.PNG) convert_one "$input_path" ;;
    *)
      echo "File must be a .png: $input_path" >&2
      exit 1
      ;;
  esac
else
  while IFS= read -r -d '' file; do
    convert_one "$file"
  done < <(find "$input_path" -type f \( -name '*.png' -o -name '*.PNG' \) -print0)
fi

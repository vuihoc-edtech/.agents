#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  png_to_webp.sh <file-or-directory> [quality] [--force]
  png_to_webp.sh <file-or-directory> [--force] [quality]

Examples:
  png_to_webp.sh assets/images/logo.png
  png_to_webp.sh assets/images 80
  png_to_webp.sh assets/images 80 --force

Notes:
  - Converts .png files to .webp
  - Keeps the original .png files
  - Skips existing .webp files unless --force is passed
  - Prefers `cwebp` when available
  - Falls back to ImageMagick `magick` when available
EOF
}

if [[ $# -lt 1 || $# -gt 3 ]]; then
  usage
  exit 1
fi

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  usage
  exit 0
fi

input_path="$1"
shift

quality="75"
quality_set=false
force=false

for arg in "$@"; do
  case "$arg" in
    --force)
      force=true
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      if [[ "$quality_set" == true ]]; then
        echo "Unexpected argument: $arg" >&2
        usage
        exit 1
      fi
      quality="$arg"
      quality_set=true
      ;;
  esac
done

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

  if [[ -e "$dest" && "$force" != true ]]; then
    echo "Skipped existing: $dest"
    return
  fi

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

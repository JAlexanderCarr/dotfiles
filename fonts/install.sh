#!/usr/bin/env bash
set -euo pipefail

# Generic font install script for all subfolders in fonts/
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
FONTS_BASE_DIR="$SCRIPT_DIR"

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"

if [[ "$OS" == "darwin" ]]; then
    FONT_DEST="$HOME/Library/Fonts"
elif [[ "$OS" == "linux" ]]; then
    FONT_DEST="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DEST"
else
    echo "[ERROR] Unsupported OS for font install: $OS"
    exit 1
fi

found_fonts=0
for fontdir in "$FONTS_BASE_DIR"/*/; do
    # Only process directories
    [[ -d "$fontdir" ]] || continue
    font_family="$(basename "$fontdir")"
    echo "[FONT] Installing font family: $font_family"
    shopt -s nullglob
    for fontfile in "$fontdir"*.otf; do
        fname="$(basename "$fontfile")"
        cp -f "$fontfile" "$FONT_DEST/$fname"
        echo "[FONT INSTALL] $fontfile -> $FONT_DEST/$fname"
        found_fonts=1
    done
    shopt -u nullglob
    echo "[FONT] Done with $font_family"
done

if [[ $found_fonts -eq 0 ]]; then
    echo "[FONT] No .otf font files found in any subfolder."
fi

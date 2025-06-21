#!/usr/bin/env bash
set -euo pipefail

# ----------- CONFIG -----------
# Determine DOTFILES_DIR whether run from root or scripts/
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [[ "${SCRIPT_DIR##*/}" == "scripts" ]]; then
    DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
else
    DOTFILES_DIR="$SCRIPT_DIR"
fi
FILES_DIR="$DOTFILES_DIR/files"
PACKAGES_INSTALL="$DOTFILES_DIR/packages/install.sh"
TIMESTAMP=$(date +"%Y%m%d-%H%M%S")

# ----------- OS & ARCH DETECTION -----------
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

if [[ "$ARCH" == "x86_64" ]]; then
    ARCH_TYPE="x86_64"
elif [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" ]]; then
    ARCH_TYPE="arm64"
else
    echo "[ERROR] Unsupported architecture: $ARCH"
    exit 1
fi

echo "Detected OS: $OS, Architecture: $ARCH_TYPE"

# ----------- BACKUP & INSTALL DOTFILES -----------
backup_and_install() {
    src_file="$1"
    dest_file="$2"

    # Backup if exists
    if [ -f "$dest_file" ] || [ -L "$dest_file" ]; then
        mkdir -p "$DOTFILES_DIR/backups/$TIMESTAMP"
        cp -p "$dest_file" "$DOTFILES_DIR/backups/$TIMESTAMP/$(basename "$dest_file")"
        echo "[BACKUP] $dest_file -> $DOTFILES_DIR/backups/$TIMESTAMP/$(basename "$dest_file")"
    fi
    # Install (overwrite, but don't delete unrelated files)
    cp -f "$src_file" "$dest_file"
    echo "[INSTALL] $src_file -> $dest_file"
}

# Map files/ to destinations (assume dotfiles go to $HOME, configs to $HOME/.config)
for f in "$FILES_DIR"/*; do
    fname="$(basename "$f")"
    # If config file, place in .config, else in $HOME as dotfile
    if [[ "$fname" == *.conf || "$fname" == *config* ]]; then
        mkdir -p "$HOME/.config"
        backup_and_install "$f" "$HOME/.config/$fname"
    else
        backup_and_install "$f" "$HOME/.$fname"
    fi
done

# ----------- PACKAGE INSTALL -----------
echo "[INFO] Installing all package scripts in $DOTFILES_DIR/packages/"
for pkg_script in $(find "$DOTFILES_DIR/packages" -maxdepth 1 -type f -name '*.sh' | sort); do
    if [[ -x "$pkg_script" ]]; then
        echo "[PKG] Installing: $(basename "$pkg_script")"
        if bash "$pkg_script"; then
            echo "[PKG] Success: $(basename "$pkg_script")"
        else
            echo "[PKG] ERROR: $(basename "$pkg_script") failed!"
            exit 2
        fi
    else
        echo "[PKG] Skipped (not found or not executable): $(basename "$pkg_script")"
    fi
done

# ----------- FONT INSTALL -----------
# Call the font install script
bash "$DOTFILES_DIR/fonts/install.sh"

echo "[DONE] Dotfiles, packages, and fonts installed."

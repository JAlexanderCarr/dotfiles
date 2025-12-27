#!/usr/bin/env bash
set -euo pipefail

# ----------- CONFIGURATION -----------

SCRIPTS_DIR="scripts"
FILES_DIR="../files"
FONTS_DIR="../fonts"
PACKAGES_DIR="../packages"

if [ "$(basename "$PWD")" != "$SCRIPTS_DIR" ]; then
    echo "[ERROR] Please run this script from the scripts directory."
    exit 1
fi

# ----------- OS & ARCH DETECTION -----------

OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"
if [[ "$ARCH" == "x86_64" || "$ARCH" == "amd64" ]]; then
    ARCH_TYPE="amd64"
elif [[ "$ARCH" == "arm64" || "$ARCH" == "aarch64" ]]; then
    ARCH_TYPE="arm64"
else
    echo "[ERROR] Unsupported architecture: $ARCH"
    exit 1
fi
echo "Detected OS: $OS, Architecture: $ARCH_TYPE"

# ----------- INSTALLATION -----------

read -p "Install dotfiles (files)? [y/n]: " install_files
read -p "Install packages? [y/n]: " install_packages
read -p "Install fonts? [y/n]: " install_fonts

if [[ "$install_files" =~ ^[Yy]$ ]]; then
    if [ ! -d "$FILES_DIR" ]; then
        echo "[ERROR] Directory $FILES_DIR does not exist. Skipping dotfiles install."
    else
        cd "$FILES_DIR" && bash "install.sh"
    fi
fi

if [[ "$install_packages" =~ ^[Yy]$ ]]; then
    if [ ! -d "$PACKAGES_DIR" ]; then
        echo "[ERROR] Directory $PACKAGES_DIR does not exist. Skipping package install."
    else
        cd "$PACKAGES_DIR" && sudo bash "install.sh"
    fi
fi

if [[ "$install_fonts" =~ ^[Yy]$ ]]; then
    if [ ! -d "$FONTS_DIR" ]; then
        echo "[ERROR] Directory $FONTS_DIR does not exist. Skipping font install."
    else
        cd "$FONTS_DIR" && bash "install.sh"
    fi
fi

echo "[DONE] Installation complete."

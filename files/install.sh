#!/usr/bin/env bash
set -euo pipefail

BACKUPS_DIR="backups/$(date +"%Y%m%d-%H%M%S")"

backup() {
    file="$1"
    if [ -f "$file" ] || [ -L "$file" ]; then
        mkdir -p "$BACKUPS_DIR"
        cp -p "$file" "$BACKUPS_DIR/$(basename "$file")"
        echo "[BACKUP] $file -> $BACKUPS_DIR/$(basename "$file")"
    fi
}

# Map files/ to destinations (assume dotfiles go to $HOME)
for f in ./*; do
    fname="$(basename "$f")"
    if [[ "$fname" == "install.sh" || "$fname" == "backups" ]]; then
        continue
    fi
    backup "$HOME/.$fname"
    cp -f -r "$f" "$HOME/.$fname"
    echo "[INSTALL] $f -> $HOME/.$fname"
done

# Backup and symlink .bash_profile and .zprofile to .profile
for prof in ".bash_profile" ".zprofile"; do
    src="$HOME/$prof"
    target="$HOME/.profile"
    backup "$src"
    ln -sf "$target" "$src"
    echo "[SYMLINK] $src -> $target"
done

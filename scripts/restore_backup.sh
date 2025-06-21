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
BACKUPS_DIR="$DOTFILES_DIR/backups"

# ----------- USAGE -----------
AUTO_YES=0
if [ "$1" == "-y" ]; then
    AUTO_YES=1
    shift
fi
if [ $# -ne 1 ]; then
    echo "Usage: $0 [-y] <backup_timestamp>"
    echo "Example: $0 -y 20250420-002400"
    exit 1
fi
TIMESTAMP="$1"

BACKUP_PATH="$BACKUPS_DIR/$TIMESTAMP"
if [ ! -d "$BACKUP_PATH" ]; then
    echo "[ERROR] Backup folder $BACKUP_PATH does not exist."
    exit 2
fi

# ----------- WARNING -----------
echo "[WARNING] This will OVERWRITE your current dotfiles/configs with files from backup: $BACKUP_PATH!"
echo "[WARNING] There is NO additional backup. Continue at your own risk."
if [ "$AUTO_YES" -eq 0 ]; then
    read -p "Are you sure you want to continue? [Y/N]: " confirm
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 3
    fi
else
    echo "[INFO] Auto-confirm enabled via -y. Proceeding without prompt."
fi

# ----------- RESTORE -----------
for f in "$BACKUP_PATH"/*; do
    fname="$(basename "$f")"
    # Determine restore location: if file exists in $HOME/.config, restore there, else $HOME
    if [ -f "$HOME/.config/$fname" ]; then
        dest="$HOME/.config/$fname"
    else
        dest="$HOME/.$fname"
    fi
    cp -f "$f" "$dest"
    echo "[RESTORE] $f -> $dest"
done

echo "[DONE] Restore complete."

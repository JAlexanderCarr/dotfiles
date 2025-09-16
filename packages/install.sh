#!/usr/bin/env bash
set -eo pipefail

# This script installs all package scripts in the packages directory

# Iterate over scripts using shell globbing (lexicographically sorted by default)
# and explicitly skip this installer script to avoid recursion.
for pkg_script in ./*.sh; do
    # Skip if glob didn't match anything
    [[ "$pkg_script" == "./*.sh" ]] && continue

    # Skip this installer itself
    if [[ "$pkg_script" == "./install.sh" ]]; then
        continue
    fi

    if [[ -f "$pkg_script" && -x "$pkg_script" ]]; then
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

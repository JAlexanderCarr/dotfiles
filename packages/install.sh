#!/usr/bin/env bash
set -euo pipefail

# This script installs all package scripts in the packages directory

for pkg_script in $(find . -maxdepth 1 -type f -name '*.sh' | sort); do
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

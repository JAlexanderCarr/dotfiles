#!/usr/bin/env bash
set -eou pipefail

# Finding and setting machine os
case $OS in
    macos)
        mkdir -p ~/Library/Fonts
        cp FiraMonoNerdFont-Regular.otf ~/Library/Fonts/
        cp FiraMonoNerdFont-Bold.otf ~/Library/Fonts/ ;;
    linux)
        mkdir -p ~/.fonts
        cp FiraMonoNerdFont-Regular.otf ~/.fonts/
        cp FiraMonoNerdFont-Bold.otf ~/.fonts/ ;;
    *) printf "ERROR: Invalid operating system" && exit 1 ;;
esac

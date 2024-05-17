#!/usr/bin/env bash
set -eou pipefail

# Creating a log file
echo "debian-amd64 files"
logfile=$(date +"%d%b%Y_%H:%M_logs.txt")
touch $logfile
exec &> $logfile
set -x

cp -b bashrc $HOME_DIR/.bashrc
# cp -b zshrc $HOME_DIR/.zshrc
# cp -b vimrc $HOME_DIR/.vimrc
cp -b profile $HOME_DIR/.profile
cp -b aliases $HOME_DIR/.aliases
cp -b bash_completion $HOME_DIR/.bash_completion
# cp -b zsh_completion $HOME_DIR/.zsh_completion
# cp -b gitconfig $HOME_DIR/.gitconfig

# Cleaning up
unset logfile
set +x

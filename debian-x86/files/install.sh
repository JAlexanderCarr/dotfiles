#!/usr/bin/env bash
set -eou pipefail

# Creating a log file
echo "debian-x86 files"
logfile=$(date +"%d%b%Y_%H:%M_logs.txt")
touch $logfile
exec &> $logfile
set -x

cp -b bashrc $HOME/.bashrc
cp -b zshrc $HOME/.zshrc
cp -b vimrc $HOME/.vimrc
cp -b profile $HOME/.profile
cp -b aliases $HOME/.aliases
cp -b bash_completion $HOME/.bash_completion
cp -b zsh_completion $HOME/.zsh_completion
cp -b gitconfig $HOME/.gitconfig

# Cleaning up
unset logfile
set +x

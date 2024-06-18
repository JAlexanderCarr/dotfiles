#!/usr/bin/env bash
set -eou pipefail

# Finding and setting machine os
case $(uname) in
    Darwin) export OS=macos ;;
    Linux) export OS=linux ;;
    *) printf "ERROR: Invalid operating system" && exit 1 ;;
esac

# Finding and setting machine architecture
case $(uname -m) in
    aarch64 | arm64) export ARCH=arm64 ;;
    x86_64 | amd64) export ARCH=amd64 ;;
    *) printf "ERROR: Invalid architecture" && exit 1 ;;
esac

#!/usr/bin/env bash
set -euo pipefail

: "${OS:=$(uname -s | tr '[:upper:]' '[:lower:]')}"
: "${ARCH:=$(uname -m)}"

NVM_VERSION="0.39.3"

# Install NVM and Node.js (user can choose version)
if [[ "$OS" == "darwin" ]]; then
    if ! command -v brew >/dev/null; then
        echo "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install curl
elif [[ -f /etc/debian_version ]]; then
    apt-get update -y
    apt-get install -y curl build-essential
elif [[ -f /etc/fedora-release ]]; then
    dnf install -y curl gcc-c++ make
elif [[ -f /etc/centos-release ]] || [[ -f /etc/redhat-release ]] || [[ -f /etc/system-release ]]; then
    yum install -y curl gcc-c++ make
elif [[ -f /etc/arch-release ]]; then
    pacman -Sy --noconfirm curl base-devel
else
    echo "Unsupported OS for Node.js dependencies."
    exit 1
fi
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh | bash

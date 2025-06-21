#!/usr/bin/env bash
set -euo pipefail

# General development tools
# Uses apt-get as an example; update for other OS/package managers as needed

: "${OS:=$(uname -s | tr '[:upper:]' '[:lower:]')}"
: "${ARCH:=$(uname -m)}"

if [[ "$OS" == "darwin" ]]; then
    # macOS
    if ! command -v brew >/dev/null; then
        echo "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install git gnu-tar gnu-sed bash-completion pkg-config
elif [[ -f /etc/debian_version ]]; then
    apt-get update -y
    apt-get install -y build-essential libssl-dev make git g++ curl bash-completion pkg-config
elif [[ -f /etc/fedora-release ]]; then
    dnf install -y @development-tools openssl-devel make git gcc-c++ curl bash-completion pkgconf-pkg-config
elif [[ -f /etc/centos-release ]] || [[ -f /etc/redhat-release ]] || [[ -f /etc/system-release ]]; then
    # yum-based (RHEL/CentOS/Amazon Linux)
    yum groupinstall -y "Development Tools"
    yum install -y openssl-devel make git gcc-c++ curl bash-completion pkgconfig
elif [[ -f /etc/arch-release ]]; then
    pacman -Sy --noconfirm base-devel openssl make git gcc curl bash-completion pkgconf
else
    echo "Unsupported OS for devtools installation."
    exit 1
fi

#!/usr/bin/env bash
set -euo pipefail

: "${OS:=$(uname -s | tr '[:upper:]' '[:lower:]')}"
: "${ARCH:=$(uname -m)}"

GO_VERSION="1.22.2"
GO_OS="$OS"
GO_ARCH="$ARCH"
if [[ "$GO_OS" == "darwin" ]]; then
    GO_OS="darwin"
elif [[ "$GO_OS" == "linux" ]]; then
    GO_OS="linux"
else
    echo "Unsupported OS for Go install: $GO_OS"
    exit 1
fi
if [[ "$GO_ARCH" == "x86_64" ]]; then
    GO_ARCH="amd64"
elif [[ "$GO_ARCH" == "arm64" || "$GO_ARCH" == "aarch64" ]]; then
    GO_ARCH="arm64"
else
    echo "Unsupported architecture for Go install: $GO_ARCH"
    exit 1
fi
if [[ "$OS" == "darwin" ]]; then
    if ! command -v brew >/dev/null; then
        echo "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install go
elif [[ -f /etc/debian_version ]]; then
    apt-get update -y
    apt-get install -y wget tar
    cd /tmp
    wget "https://go.dev/dl/go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz"
    tar -C /usr/local -xzf go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz
    rm -f go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz
elif [[ -f /etc/fedora-release ]]; then
    dnf install -y wget tar
    cd /tmp
    wget "https://go.dev/dl/go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz"
    tar -C /usr/local -xzf go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz
    rm -f go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz
elif [[ -f /etc/centos-release ]] || [[ -f /etc/redhat-release ]] || [[ -f /etc/system-release ]]; then
    yum install -y wget tar
    cd /tmp
    wget "https://go.dev/dl/go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz"
    tar -C /usr/local -xzf go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz
    rm -f go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz
elif [[ -f /etc/arch-release ]]; then
    pacman -Sy --noconfirm wget tar
    cd /tmp
    wget "https://go.dev/dl/go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz"
    tar -C /usr/local -xzf go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz
    rm -f go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz
else
    echo "Unsupported OS for Go installation."
    exit 1
fi

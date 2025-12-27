#!/usr/bin/env bash
set -euo pipefail

: "${OS:=$(uname -s | tr '[:upper:]' '[:lower:]')}"
: "${ARCH:=$(uname -m)}"

GO_VERSION="1.25.3"
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
    @echo "wget and tar are already installed on macOS"
elif [[ -f /etc/debian_version ]]; then
    apt-get update -y
    apt-get install -y wget tar
elif [[ -f /etc/fedora-release ]]; then
    dnf install -y wget tar
elif [[ -f /etc/centos-release ]] || [[ -f /etc/redhat-release ]] || [[ -f /etc/system-release ]]; then
    yum install -y wget tar
elif [[ -f /etc/arch-release ]]; then
    pacman -Sy --noconfirm wget tar
else
    echo "Unsupported OS for Go installation."
    exit 1
fi

rm -rf /usr/local/go*
mkdir -p /tmp/golang

# Download and install
wget --quiet https://go.dev/dl/go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz -P /tmp/golang
tar -C /usr/local -xzf /tmp/golang/go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz 
mv /usr/local/go /usr/local/go${GO_VERSION}
ln -s -f /usr/local/go${GO_VERSION}/bin/go /usr/local/bin/go
ln -s -f /usr/local/go${GO_VERSION} /usr/local/go
rm /tmp/golang/go${GO_VERSION}.${GO_OS}-${GO_ARCH}.tar.gz

# Show the installed and system version
ls -al /usr/local | grep go
ls -al /usr/local/bin/go

# Cleanup
rm -rf /tmp/golang

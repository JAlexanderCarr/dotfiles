#!/usr/bin/env bash
set -euo pipefail

: "${OS:=$(uname -s | tr '[:upper:]' '[:lower:]')}"
: "${ARCH:=$(uname -m)}"
: "${USER:=$(id -un)}"

# Install Docker (latest stable)
if [[ "$OS" == "darwin" ]]; then
    if ! command -v brew >/dev/null; then
        echo "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install --cask docker
    echo "[INFO] Please launch Docker Desktop manually for the first time."
elif [[ -f /etc/debian_version ]]; then
    apt-get update -y
    apt-get install -y ca-certificates curl gnupg lsb-release
    mkdir -m 0755 -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor --yes -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    usermod -aG docker $USER
elif [[ -f /etc/fedora-release ]]; then
    dnf install -y dnf-plugins-core
    dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    dnf install -y docker-ce docker-ce-cli containerd.io
    usermod -aG docker $USER
elif [[ -f /etc/centos-release ]] || [[ -f /etc/redhat-release ]] || [[ -f /etc/system-release ]]; then
    yum install -y yum-utils
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum install -y docker-ce docker-ce-cli containerd.io
    usermod -aG docker $USER
elif [[ -f /etc/arch-release ]]; then
    pacman -Sy --noconfirm docker
    usermod -aG docker $USER
else
    echo "Unsupported OS for Docker installation."
    exit 1
fi

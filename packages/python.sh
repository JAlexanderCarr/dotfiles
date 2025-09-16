#!/usr/bin/env bash
set -euo pipefail

: "${OS:=$(uname -s | tr '[:upper:]' '[:lower:]')}"
: "${ARCH:=$(uname -m)}"

# Example version variable (edit as needed)
PYTHON_VERSION="3.12.2"

# Install Python from source for version control
if [[ "$OS" == "darwin" ]]; then
    # macOS: Prefer Homebrew for Python
    if ! command -v brew >/dev/null; then
        echo "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install python
elif [[ -f /etc/debian_version ]]; then
    apt-get update -y
    apt-get install -y build-essential libssl-dev zlib1g-dev libncurses5-dev libncursesw5-dev libreadline-dev libsqlite3-dev libgdbm-dev libdb5.3-dev libbz2-dev libexpat1-dev liblzma-dev tk-dev wget curl
    cd /tmp
    wget "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz"
    tar -xf Python-$PYTHON_VERSION.tgz
    cd Python-$PYTHON_VERSION
    ./configure --enable-optimizations
    make -j$(nproc)
    make altinstall
    cd ..
    rm -rf Python-$PYTHON_VERSION*
elif [[ -f /etc/fedora-release ]]; then
    dnf install -y gcc openssl-devel bzip2-devel libffi-devel zlib-devel wget make
    cd /tmp
    wget "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz"
    tar -xf Python-$PYTHON_VERSION.tgz
    cd Python-$PYTHON_VERSION
    ./configure --enable-optimizations
    make -j$(nproc)
    make altinstall
    cd ..
    rm -rf Python-$PYTHON_VERSION*
elif [[ -f /etc/centos-release ]] || [[ -f /etc/redhat-release ]] || [[ -f /etc/system-release ]]; then
    yum groupinstall -y "Development Tools"
    yum install -y openssl-devel bzip2-devel libffi-devel zlib-devel wget make
    cd /tmp
    wget "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz"
    tar -xf Python-$PYTHON_VERSION.tgz
    cd Python-$PYTHON_VERSION
    ./configure --enable-optimizations
    make -j$(nproc)
    make altinstall
    cd ..
    rm -rf Python-$PYTHON_VERSION*
elif [[ -f /etc/arch-release ]]; then
    pacman -Sy --noconfirm base-devel openssl zlib wget make
    cd /tmp
    wget "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz"
    tar -xf Python-$PYTHON_VERSION.tgz
    cd Python-$PYTHON_VERSION
    ./configure --enable-optimizations
    make -j$(nproc)
    make altinstall
    cd ..
    rm -rf Python-$PYTHON_VERSION*
else
    echo "Unsupported OS for Python installation."
    exit 1
fi

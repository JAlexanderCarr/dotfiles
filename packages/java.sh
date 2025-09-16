#!/usr/bin/env bash
set -euo pipefail

# FIXME: Fix java install
exit 0

: "${OS:=$(uname -s | tr '[:upper:]' '[:lower:]')}"
: "${ARCH:=$(uname -m)}"

JAVA_VERSION="21.0.2"

# Install OpenJDK from source if possible, else use package manager
if [[ "$OS" == "darwin" ]]; then
    # macOS: Prefer Homebrew for OpenJDK
    if ! command -v brew >/dev/null; then
        echo "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install openjdk
elif [[ -f /etc/debian_version ]]; then
    apt-get update -y
    apt-get install -y wget tar
    cd /tmp
    wget "https://download.java.net/java/GA/jdk${JAVA_VERSION%%.*}/${JAVA_VERSION}/GPL/openjdk-${JAVA_VERSION}_linux-$ARCH.tar.gz"
    tar -xzf openjdk-${JAVA_VERSION}_linux-$ARCH.tar.gz
    mkdir -p /usr/lib/jvm
    mv jdk-${JAVA_VERSION} /usr/lib/jvm/
    update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-${JAVA_VERSION}/bin/java 1
    update-alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk-${JAVA_VERSION}/bin/javac 1
    cd ..
    rm -rf openjdk-${JAVA_VERSION}*
elif [[ -f /etc/fedora-release ]]; then
    dnf install -y wget tar
    cd /tmp
    wget "https://download.java.net/java/GA/jdk${JAVA_VERSION%%.*}/${JAVA_VERSION}/GPL/openjdk-${JAVA_VERSION}_linux-$ARCH.tar.gz"
    tar -xzf openjdk-${JAVA_VERSION}_linux-$ARCH.tar.gz
    mkdir -p /usr/lib/jvm
    mv jdk-${JAVA_VERSION} /usr/lib/jvm/
    alternatives --install /usr/bin/java java /usr/lib/jvm/jdk-${JAVA_VERSION}/bin/java 1
    alternatives --install /usr/bin/javac javac /usr/lib/jvm/jdk-${JAVA_VERSION}/bin/javac 1
    cd ..
    rm -rf openjdk-${JAVA_VERSION}*
elif [[ -f /etc/centos-release ]] || [[ -f /etc/redhat-release ]] || [[ -f /etc/system-release ]]; then
    yum install -y wget tar
    cd /tmp
    wget "https://download.java.net/java/GA/jdk${JAVA_VERSION%%.*}/${JAVA_VERSION}/GPL/openjdk-${JAVA_VERSION}_linux-$ARCH.tar.gz"
    tar -xzf openjdk-${JAVA_VERSION}_linux-$ARCH.tar.gz
    mkdir -p /usr/lib/jvm
    mv jdk-${JAVA_VERSION} /usr/lib/jvm/
    cd ..
    rm -rf openjdk-${JAVA_VERSION}*
elif [[ -f /etc/arch-release ]]; then
    pacman -Sy --noconfirm wget tar
    cd /tmp
    wget "https://download.java.net/java/GA/jdk${JAVA_VERSION%%.*}/${JAVA_VERSION}/GPL/openjdk-${JAVA_VERSION}_linux-$ARCH.tar.gz"
    tar -xzf openjdk-${JAVA_VERSION}_linux-$ARCH.tar.gz
    mkdir -p /usr/lib/jvm
    mv jdk-${JAVA_VERSION} /usr/lib/jvm/
    cd ..
    rm -rf openjdk-${JAVA_VERSION}*
else
    echo "Unsupported OS for Java installation."
    exit 1
fi

#!/usr/bin/env bash
set -euo pipefail

: "${OS:=$(uname -s | tr '[:upper:]' '[:lower:]')}"
: "${ARCH:=$(uname -m)}"

KIND_ARCH="$ARCH"
KUBECTL_ARCH="$ARCH"
if [[ "$KIND_ARCH" == "x86_64" ]]; then
    KIND_ARCH="amd64"
elif [[ "$KIND_ARCH" == "arm64" || "$KIND_ARCH" == "aarch64" ]]; then
    KIND_ARCH="arm64"
else
    echo "Unsupported architecture for kind/kubectl: $KIND_ARCH"
    exit 1
fi

# Install kind
if [[ "$OS" == "darwin" ]]; then
    if ! command -v brew >/dev/null; then
        echo "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    brew install kind kubectl kubectx kubens
else
    # Linux: install from source
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-$KIND_ARCH
    chmod +x ./kind
    mv ./kind /usr/local/bin/kind

    KUBECTL_VERSION="$(curl -L -s https://dl.k8s.io/release/stable.txt)"
    curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/$KUBECTL_ARCH/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    kubectl completion bash | tee /etc/bash_completion.d/kubectl > /dev/null
    rm -f kubectl

    rm -rf /opt/kubectx
    rm -f /usr/local/bin/kubectx
    rm -f /usr/local/bin/kubens
    git clone https://github.com/ahmetb/kubectx /opt/kubectx
    ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
    ln -s /opt/kubectx/kubens /usr/local/bin/kubens
    ln -s /opt/kubectx/completion/kubectx.bash /etc/bash_completion.d/kubectx
    ln -s /opt/kubectx/completion/kubens.bash /etc/bash_completion.d/kubens
fi

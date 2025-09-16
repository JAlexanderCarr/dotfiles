#!/usr/bin/env bash
set -euo pipefail

: "${OS:=$(uname -s | tr '[:upper:]' '[:lower:]')}"
: "${ARCH:=$(uname -m)}"

# Normalize architecture for both kind and kubectl downloads
ARCH_STD="$ARCH"
if [[ "$ARCH_STD" == "x86_64" || "$ARCH_STD" == "amd64" ]]; then
    ARCH_STD="amd64"
elif [[ "$ARCH_STD" == "arm64" || "$ARCH_STD" == "aarch64" ]]; then
    ARCH_STD="arm64"
else
    echo "Unsupported architecture for kind/kubectl: $ARCH_STD"
    exit 1
fi
KIND_ARCH="$ARCH_STD"
KUBECTL_ARCH="$ARCH_STD"

# Ensure any git commands during this installation use HTTPS instead of SSH
# and ignore system/global configs, as requested.
git() {
    GIT_CONFIG_NOSYSTEM=1 \
    GIT_CONFIG_SYSTEM=/dev/null \
    GIT_CONFIG_GLOBAL=/dev/null \
    command git \
      -c url."https://github.com/".insteadof=ssh://github.com/ \
      -c url."https://github.com/".insteadof=ssh://git@github.com/ \
      -c url."https://github.com/".insteadof=git@github.com: \
      -c url."https://github.com/".insteadof=git://github.com/ \
      "$@"
}
export -f git

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
    git clone https://github.com/ahmetb/kubectx.git /opt/kubectx
    ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
    ln -sf /opt/kubectx/kubens /usr/local/bin/kubens
    ln -sf /opt/kubectx/completion/kubectx.bash /etc/bash_completion.d/kubectx
    ln -sf /opt/kubectx/completion/kubens.bash /etc/bash_completion.d/kubens
fi

#!/usr/bin/env bash
set -eou pipefail

# Creating a log file
echo "debian-arm packages"
logfile=$(date +"%d%b%Y_%H:%M_logs.txt")
touch $logfile
exec &> $logfile
set -x

echo "currently testing"

# Setting up package manager
sudo apt-get update -y
sudo apt-get upgrade -y

# General development tools
sudo apt-get install -y build-essential libssl-dev make git g++ curl bash-completion pkg-config

# Python
sudo apt-get install -y python3 python3-pip python3-venv python3-matplotlib

# Java
sudo apt-get install -y default-jre default-jdk

# Node
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# Go
go_version=$(curl https://go.dev/dl/?mode=json | grep -o 'go.*' | head -n 1 | tr -d ',"\r\n' )
wget "https://go.dev/dl/${go_version}.linux-arm64.tar.gz"
tar -C /usr/local -xzf $go_version.linux-arm64.tar.gz
rm -f $go_version.linux-arm64.tar.gz
unset go_version

# Docker
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER

# Kubernetes
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-arm64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
rm -f kubectl
rm -rf /opt/kubectx
rm -f /usr/local/bin/kubectx
rm -f /usr/local/bin/kubens
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
sudo ln -s /opt/kubectx/completion/kubectx.bash /etc/bash_completion.d/kubectx
sudo ln -s /opt/kubectx/completion/kubens.bash /etc/bash_completion.d/kubens

# Cleaning up
unset logfile
set +x

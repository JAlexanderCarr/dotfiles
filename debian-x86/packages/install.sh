#!/usr/bin/env bash
set -eou pipefail

# Creating a log file
echo "debian-x86 packages"
logfile=$(date +"%d%b%Y_%H:%M_logs.txt")
touch $logfile
exec &> $logfile
set -x

echo "currently testing"

# Setting up package manager
# sudo apt-get update -y
# sudo apt-get upgrade -y

# General development tools
# sudo apt-get install -y build-essential libssl-dev make git g++ curl

# Python
# sudo apt-get install -y python3 python3-pip python3-venv python3-matplotlib

# Java
# sudo apt-get install -y default-jre default-jdk

# Node
# wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash

# Go
# go_version=$(curl https://go.dev/VERSION?m=text)
# wget "https://dl.google.com/go/$go_version.linux-amd64.tar.gz"
# tar -C /usr/local -xzf $go_version.linux-amd64.tar.gz
# rm -f $go_version.linux-amd64.tar.gz
# unset go_version

# Docker
# sudo apt-get update -y
# sudo apt-get install -y ca-certificates curl gnupg
# sudo mkdir -m 0755 -p /etc/apt/keyrings
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
# echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list
# sudo apt-get update -y
# sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Kubernetes
# curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
# chmod +x ./kind
# sudo mv ./kind /usr/local/bin/kind
# sudo apt-get update -y
# sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
# echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
# sudo apt-get update -y
# sudo apt-get install -y kubectl
# sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
# sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
# sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens

# Helm
# curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
# chmod 700 get_helm.sh
# ./get_helm.sh
# rm get_helm.sh

# Cleaning up
unset logfile
set +x

#!/bin/bash

echo "debian-x86 packages"
logfile=$(date +"%d%b%Y_%H:%M_logs.txt")
touch $logfile

echo "currently testing" >> $logfile 2>&1

# Setting up package manager
# sudo apt-get update -y >> $logfile 2>&1
# sudo apt-get upgrade -y >> $logfile 2>&1

# General development tools
# sudo apt-get install -y build-essential libssl-dev make git g++ curl >> $logfile 2>&1

# Python
# sudo apt-get install -y python3 python3-pip python3-venv python3-matplotlib >> $logfile 2>&1

# Java
# sudo apt-get install -y default-jre default-jdk >> $logfile 2>&1

# Node
# wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash >> $logfile 2>&1

# Go
# go_version=$(curl https://go.dev/VERSION?m=text)
# wget "https://dl.google.com/go/$go_version.linux-amd64.tar.gz" >> $logfile 2>&1
# tar -C /usr/local -xzf $go_version.linux-amd64.tar.gz >> $logfile 2>&1
# rm -f $go_version.linux-amd64.tar.gz >> $logfile 2>&1
# unset go_version

# Docker
# sudo apt-get update -y >> $logfile 2>&1
# sudo apt-get install -y ca-certificates curl gnupg >> $logfile 2>&1
# sudo mkdir -m 0755 -p /etc/apt/keyrings >> $logfile 2>&1
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg >> $logfile 2>&1
# echo "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | sudo tee /etc/apt/sources.list.d/docker.list >> $logfile 2>&1
# sudo apt-get update -y >> $logfile 2>&1
# sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >> $logfile 2>&1

# Kubernetes
# curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64 >> $logfile 2>&1
# chmod +x ./kind >> $logfile 2>&1
# sudo mv ./kind /usr/local/bin/kind >> $logfile 2>&1
# sudo apt-get update -y >> $logfile 2>&1
# sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg >> $logfile 2>&1
# echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list >> $logfile 2>&1
# sudo apt-get update -y >> $logfile 2>&1
# sudo apt-get install -y kubectl >> $logfile 2>&1
# sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx >> $logfile 2>&1
# sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx >> $logfile 2>&1
# sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens >> $logfile 2>&1

unset logfile

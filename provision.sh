#!/bin/bash

function install_pkgs() {
    apt-get update && \
    apt-get install -y git-core \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    apt-key fingerprint 0EBFCD88

    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"

    apt-get update

    apt-get install -y docker-ce docker-ce-cli containerd.io
}

function install_compose() {
    curl -L "https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose
}

function deploy_vpn() {
    git clone https://github.com/jmarhee/dockvpn.git && \
    cd dockvpn && \
    docker-compose up -d
}

install_pkgs && install_compose && deploy_vpn

#!/bin/bash

function install_pkgs() {
    apt-get update && \
    apt-get install -y git-core curl
}

function install_compose() {
    curl -L "https://github.com/docker/compose/releases/download/1.10.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose
}

function ipv6_prep () {
    sed -i 's/DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4"/DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4 --ipv6 --fixed-cidr-v6=2001:db8:1::\/64"/g' /etc/default/docker && \
    service docker restart && \
    ip -6 route add 2001:db8:1::/64 dev docker0 && \
    sysctl net.ipv6.conf.default.forwarding=1 && \
    sysctl net.ipv6.conf.all.forwarding=1 && \
    sysctl net.ipv6.conf.eth0.accept_ra=2
}

function deploy_vpn() {
    git clone https://github.com/jmarhee/dockvpn.git && \
    cd dockvpn && \
    docker-compose up -d
}

install_pkgs && install_compose && ipv6_prep && deploy_vpn

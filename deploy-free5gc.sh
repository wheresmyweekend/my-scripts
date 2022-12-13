#!/bin/bash

# Author : Halim
# Title: free5gc Deployer
# Automates the deployment of free5gc on a fresh install of Ubuntu Desktop 22.04
# Script starts here:

# Variables
KERNEL_VERSION=$(uname -r)
SUPPORT_PACKAGES="mongodb wget git gcc g++ cmake autoconf libtool pkg-config libmnl-dev libyaml-dev"
NETWORK_INTERFACE="enp0s3" # change where appropriate

# Get password
get_password() {
    if [[ ! ${KERNEL_VERSION} =~ "5.4."* ]]
    then 
            echo "Please use 5.4.* kernel version" >&2
            exit 1
    fi
    read -p "Enter Password: " PASSWORD
}

# Removing other golang versions and installing golang 1.14.4
install_golang() {
    echo ${PASSWORD} | sudo -S rm -rf /usr/local/go
    
    if [[ ! -e go1.14.4.linux-amd64.tar.gz ]]
    then 
        wget https://dl.google.com/go/go1.14.4.linux-amd64.tar.gz
    fi

    echo ${PASSWORD} | sudo -S tar -C /usr/local -zxvf go1.14.4.linux-amd64.tar.gz
    if [[ ${?} -ne 0 ]]
    then 
        echo "Failed to install golang 1.14.4" >&2
        exit 1
    fi

    mkdir -p ~/go/{bin,pkg,src}
    LINES='GOPATH=$HOME/go GOROOT=/usr/local/go PATH=$PATH:$GOPATH/bin:$GOROOT/bin GO111MODULE=auto'
    for LINE in ${LINES}
    do
        grep $LINE ~/.bashrc >> /dev/null
        if [[ ${?} -ne 0 ]]
        then
            echo "export $LINE" >> ~/.bashrc
        fi
    done
    source ~/.bashrc
}

# Installing control-plane, user-plane supporting packages
install_deps() {
    echo ${PASSWORD} | sudo -S sudo apt-get -y update
    echo ${PASSWORD} | sudo -S apt-get -y install ${SUPPORT_PACKAGES}
    echo ${PASSWORD} | sudo -S systemctl start mongodb
}


# Setting the host network settings
set_network() {
    echo ${PASSWORD} | sudo -S sysctl -w net.ipv4.ip_forward=1

    echo ${PASSWORD} | sudo -S iptables -t nat -C POSTROUTING -o ${NETWORK_INTERFACE} -j MASQUERADE >> /dev/null
    if [[ ${?} -ne 0 ]]
    then
        echo ${PASSWORD} | sudo -S iptables -t nat -A POSTROUTING -o ${NETWORK_INTERFACE} -j MASQUERADE
    fi

    echo ${PASSWORD} | sudo -S iptables -C FORWARD -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1400 >> /dev/null
    if [[ ${?} -ne 0 ]]
    then
        echo ${PASSWORD} | sudo -S iptables -A FORWARD -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1400
    fi

    # NOTE: Might need
    # sudo iptables -I FORWARD 1 -j ACCEPT

    echo ${PASSWORD} | sudo -S systemctl stop ufw
}

# cloning free5GC core repo
# TODO: prompt for if shell error, change default shell to bash
build_from_repo() {
    cd ~ 
    if [[ ! -d free5gc ]]
    then
        git clone --recursive -b v3.2.1 -j `nproc` https://github.com/free5gc/free5gc.git
    fi

    if [[ ${?} -ne 0 ]]
    then
        echo "Failed to clone free5gc repo. Exiting." >&2
        exit 1
    fi

    cd free5gc
    if [[ ! -d free5gc ]]
    then
        git clone https://github.com/free5gc/gtp5g.git
    fi

    if [[ ${?} -ne 0 ]]
    then
        echo "Failed to clone gtp5g repo. Exiting." >&2
        exit 1
    fi

    cd gtp5g
    make
    echo ${PASSWORD} | sudo -S make install

    cd ~/free5gc
    make
}

# TODO: Install webconsole



cd ~
get_password
install_golang
install_deps
set_network
build_from_repo

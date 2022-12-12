#!/bin/bash

# Author : Halim
# Title: UERANSIM Deployer
# Automates the deployment of UERANSIM on a fresh install of Ubuntu Desktop 22.04
# Use script by invoking ./ueransim-deploy.sh
# Script starts here:

#TODO: verbose mode

# Check sudo 
check_sudo() {
    if [[ ${UID} -ne 0 ]]
    then 
        echo "Run as sudo or root" >&2
        exit 1
    fi
}

# Install dependencies
install_deps() {
    # List of dependencies
    local DEP_LIST="git make gcc g++ libsctp-dev lksctp-tools iproute2 net-tools"

    # Update and upgrade current package list
    apt-get -y update 
    apt-get -y upgrade 

    # Install required dependencies
    apt-get -y install ${DEP_LIST}

    # Installing cmake
    snap install cmake --classic

}

# Clone Repo
clone_repo() {
    cd ~
    git clone https://github.com/aligungr/UERANSIM
    if [[ ${?} -ne 0 ]]
    then
        echo "Failed to clone repo."
        exit 1
    fi 
}

# Build UERANSIM
build_UERANSIM() {
    cd ~/UERANSIM
    make
    if [[ ${?} -ne 0 ]]
    then
        echo "make failed, cleaning up.."
        cd ~ 
        rm -rf ~/UERANSIM
        echo "Cleanup complete"
    fi    
}

check_sudo
install_deps
clone_repo
build_UERANSIM

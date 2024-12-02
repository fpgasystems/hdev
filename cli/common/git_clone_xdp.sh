#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#inputs
DIR=$1
XDP_BPFTOOL_COMMIT=$2
XDP_LIBBPF_COMMIT=$3

#constants
XDP_BPFTOOL_REPO=$($CLI_PATH/common/get_constant $CLI_PATH XDP_BPFTOOL_REPO)
XDP_LIBBPF_REPO=$($CLI_PATH/common/get_constant $CLI_PATH XDP_LIBBPF_REPO)

#derived
XDP_BPFTOOL_REPO="https://github.com/$XDP_BPFTOOL_REPO.git"
XDP_LIBBPF_REPO="https://github.com/$XDP_LIBBPF_REPO.git"

#print
echo "${bold}Checking out OpenNIC shell:${normal}"
echo ""

#change directory
cd $DIR

#clone shell repository
git clone $XDP_LIBBPF_REPO

#change to repository directory
cd $DIR/open-nic-shell

#checkout the specific commit in the main branch
git checkout $XDP_BPFTOOL_COMMIT > /dev/null 2>&1

#remove the repository (in case we add it later to our own repository)
rm -rf .git

echo ""
echo "${bold}Checking out OpenNIC driver:${normal}"
echo ""

#change back to the original directory
cd $DIR

#clone driver repository
git clone $ONIC_DRIVER_REPO

#change to repository directory
cd $DIR/open-nic-driver

# Checkout the specific commit in the main branch
git checkout $XDP_LIBBPF_COMMIT > /dev/null 2>&1

#remove the repository (in case we add it later to our own repository)
rm -rf .git

echo ""
echo "Checkout commit ID (shell and driver) ${bold}$XDP_BPFTOOL_COMMIT,$XDP_LIBBPF_COMMIT${normal} done!"
echo ""
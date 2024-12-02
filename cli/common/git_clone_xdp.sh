#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#inputs
DIR=$1
XDP_BPFTOOL_COMMIT=$2
XDP_LIBBPF_COMMIT=$3

#constants
RXI_LOGC_REPO="https://github.com/rxi/log.c"
XDP_BPFTOOL_REPO=$($CLI_PATH/common/get_constant $CLI_PATH XDP_BPFTOOL_REPO)
XDP_LIBBPF_REPO=$($CLI_PATH/common/get_constant $CLI_PATH XDP_LIBBPF_REPO)

#derived
XDP_BPFTOOL_REPO="https://github.com/$XDP_BPFTOOL_REPO.git"
XDP_LIBBPF_REPO="https://github.com/$XDP_LIBBPF_REPO.git"

#print
echo "${bold}Checking out bpftool:${normal}"
echo ""

#change directory
cd $DIR

#clone XDP_BPFTOOL_REPO repository
git clone $XDP_BPFTOOL_REPO

#change to repository directory
cd $DIR/bpftool

#checkout the specific commit in the main branch
git checkout $XDP_BPFTOOL_COMMIT > /dev/null 2>&1

#update the submodule
git submodule update --init --recursive > /dev/null 2>&1

#remove the repository (in case we add it later to our own repository)
rm -rf .git

echo ""
echo "${bold}Checking out libbpf:${normal}"
echo ""

#change back to the original directory
cd $DIR

#clone XDP_LIBBPF_REPO repository
git clone $XDP_LIBBPF_REPO

#change to repository directory
cd $DIR/libbpf

# Checkout the specific commit in the main branch
git checkout $XDP_LIBBPF_COMMIT > /dev/null 2>&1

#remove the repository (in case we add it later to our own repository)
rm -rf .git

#clone RXI_LOGC_REPO repository (as of today 02.12.2024, this repo was updated 4 years ago)
cd $DIR
git clone $RXI_LOGC_REPO > /dev/null 2>&1
mv log.c liblog

#move folders
mkdir $DIR/lib
mv $DIR/bpftool $DIR/lib
mv $DIR/libbpf $DIR/lib
mv $DIR/liblog $DIR/lib

echo ""
echo "Checkout commit ID (bpftool and libbpf) ${bold}$XDP_BPFTOOL_COMMIT,$XDP_LIBBPF_COMMIT${normal} done!"
echo ""
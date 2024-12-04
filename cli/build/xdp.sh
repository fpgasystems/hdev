#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev build xdp --commit $commit_name_bpftool $commit_name_libbpf --project $project_name
#example: /opt/hdev/cli/hdev build xdp --commit              687e7f0             20c0a9e --project   hello_world

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_nic=$($CLI_PATH/common/is_nic $CLI_PATH $hostname)
is_network_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
if [ "$is_nic" = "0" ] || [ "$is_network_developer" = "0" ]; then
    exit 1
fi

#inputs
commit_name_bpftool=$2
commit_name_libbpf=$3
project_name=$5

#all inputs must be provided
if [ "$commit_name_bpftool" = "" ] || [ "$commit_name_libbpf" = "" ] || [ "$project_name" = "" ]; then
    exit
fi

#constants
#BITSTREAM_NAME=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_NAME)
#BITSTREAMS_PATH="$CLI_PATH/bitstreams"
#DRIVER_NAME=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_NAME)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
#NUM_JOBS="8"
WORKFLOW="xdp"

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name_bpftool/$project_name"
#SHELL_BUILD_DIR="$DIR/open-nic-shell/script"
#DRIVER_DIR="$DIR/open-nic-driver"

#platform_name to FDEV_NAME
#FDEV_NAME=$(echo "$platform_name" | cut -d'_' -f2)

#define shell
#library_shell="$BITSTREAMS_PATH/$WORKFLOW/$commit_name_bpftool/${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
#project_shell="$DIR/${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"

#compile driver
echo "${bold}eBPF compilation (commit ID: $commit_name_libbpf)${normal}"
echo ""
echo "cd $DIR && make"
echo ""
cd $DIR && make

#author: https://github.com/jmoya82
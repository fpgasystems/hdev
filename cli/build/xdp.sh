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
commit_name_libbpf=$3 #unsed at the moment
project_name=$5
#driver_name=$7

#all inputs must be provided (except driver_name)
if [ "$commit_name_bpftool" = "" ] || [ "$commit_name_libbpf" = "" ] || [ "$project_name" = "" ]; then
    exit
fi

#constants
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="xdp"

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name_bpftool/$project_name"

#compile driver
#if [ ! "$driver_name" = "" ]; then
#    echo "${bold}Driver compilation:${normal}"
#    echo ""
#    echo "cd $DIR/drivers/$driver_name && make"
#    echo ""
#    cd $DIR/drivers/$driver_name && make
#    echo ""
#
#    #copy driver
#    cp -f $DIR/drivers/$driver_name/$driver_name.ko $DIR/$driver_name.ko
#fi

#compile eBPF applications
echo "${bold}eBPF compilation (commit ID: $commit_name_bpftool)${normal}"
echo ""
echo "cd $DIR && make"
echo ""
cd $DIR && make

echo ""
echo "${bold}eBPF compilation is done!${normal}"

#author: https://github.com/jmoya82
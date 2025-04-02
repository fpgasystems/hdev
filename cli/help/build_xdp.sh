#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
is_nic=$3
is_network_developer=$4

XDP_BPFTOOL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH XDP_BPFTOOL_COMMIT)

#get available drivers from templates
#current_directory=$(pwd)
#cd $CLI_PATH
#cd ../templates/xdp/drivers
#drivers=$(ls -l | awk '/^d/ {print $NF}' | tr '\n' ',' | sed 's/,/, /g' | sed 's/, $//' | awk -F', ' '{if (NF > 3) {print $1", "$2", "$3", ..."} else {print $0}}')
#cd $current_directory

if [ "$is_nic" = "1" ] && [ "$is_network_developer" = "1" ]; then
    echo ""
    echo "${bold}$CLI_NAME build xdp [flags] [--help]${normal}"
    echo ""
    echo "eBPF binaries for your Express Data Path (XDP) networking applications."
    echo ""
    echo "FLAGS:"
    echo "   ${bold}-c, --commit${normal}    - GitHub commit ID for bpftool (default: ${bold}$XDP_BPFTOOL_COMMIT${normal})."
    #echo "   ${bold}-d, --driver${normal}    - An XDP driver identifier to be compiled (available: ${bold}$drivers${normal})."
    echo "   ${bold}-p, --project${normal}   - Specifies your xdp project name."
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
    #$CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "1" "1" "1" "0" "yes"
    #echo ""
fi
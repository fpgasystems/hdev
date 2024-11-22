#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1
is_build=$2
is_gpu=$3 
is_gpu_developer=$4

#evaluate integrations
gpu_enabled=$([ "$is_gpu_developer" = "1" ] && [ "$is_gpu" = "1" ] && echo 1 || echo 0)

if [ "$is_build" = "1" ] || [ "$gpu_enabled" = "1" ]; then
    echo ""
    echo "${bold}$CLI_NAME build hip [flags] [--help]${normal}"
    echo ""
    echo "Generates HIP binaries for your projects."
    echo ""
    echo "FLAGS:"
    echo "   ${bold}-p, --project${normal}   - Specifies your HIP project name."
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "0" "0" "0" "1" "yes"
    echo ""
fi
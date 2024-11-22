#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
is_acap=$3
is_asoc=$4
is_build=$5 
is_fpga=$6
is_vivado_developer=$7

ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)

#evaluate integrations
vivado_enabled=$([ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; } && echo 1 || echo 0)

#if [ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_build" = "1" ] || [ "$is_fpga" = "1" ]; }; then
if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "1" ]; then
    echo ""
    echo "${bold}$CLI_NAME build opennic [flags] [--help]${normal}"
    echo ""
    echo "Generates OpenNIC's bitstreams and drivers."
    echo ""
    echo "FLAGS:"
    echo "   ${bold}-c, --commit${normal}    - GitHub commit ID for shell (default: ${bold}$ONIC_SHELL_COMMIT${normal})."
    if [ "$is_build" = "1" ]; then
    echo "       ${bold}--platform${normal}  - Xilinx platform (according to ${bold}$CLI_NAME get platform${normal})."
    fi
    echo "       ${bold}--project${normal}   - Specifies your OpenNIC project name."
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "1" "1" "1" "0" "yes"
    echo ""
fi
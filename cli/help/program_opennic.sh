#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
COLOR_XILINX=$3
COLOR_OFF=$4
ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)

echo ""
echo "${bold}$CLI_NAME program opennic [flags] [--help]${normal}"
echo ""
echo "Programs OpenNIC to a given device."
echo ""
echo "FLAGS:"
echo "   ${bold}-c, --commit${normal}    - GitHub commit ID for shell (default: ${bold}$ONIC_SHELL_COMMIT${normal})."
echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
echo "   ${bold}-p, --project${normal}   - Specifies your OpenNIC project name." 
echo "   ${bold}-r, --remote${normal}    - Local or remote deployment."
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""
#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1
COLOR_XILINX=$2
COLOR_OFF=$3

echo ""
echo "${bold}$CLI_NAME program reset [flags] [--help]${normal}"
echo ""
echo "Performs a 'HOT Reset' on a Vitis device."
echo ""
echo "FLAGS:"
echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""
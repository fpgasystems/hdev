#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1
COLOR_XILINX=$2
COLOR_OFF=$3

echo "" #this one is needed
echo "${bold}$CLI_NAME program revert [flags] [--help]${normal}"
echo ""
echo "Returns a device to its default fabric setup."
echo ""
echo "FLAGS:"
echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
echo "   ${bold}-r, --remote${normal}    - Local or remote deployment."
echo ""
echo "   ${bold}-h, --help${normal}      - Help to revert a device."
echo ""
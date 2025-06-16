#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2

VRT_TAG=$($CLI_PATH/common/get_constant $CLI_PATH VRT_TAG)

echo ""
echo "${bold}$CLI_NAME program vrt [flags] [--help]${normal}"
echo ""
echo "Programs a VRT application to a given device."
echo ""
echo "FLAGS:"
echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
echo "   ${bold}-p, --project${normal}   - Specifies your VRT project name." 
echo "   ${bold}-r, --remote${normal}    - Local or remote deployment."
echo "   ${bold}-t, --tag${normal}       - GitHub tag ID (default: ${bold}$VRT_TAG${normal})."
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command. "
echo ""
#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
VRT_TAG=$($CLI_PATH/common/get_constant $CLI_PATH VRT_TAG)

targets="${bold}sim_all, emu_all,${normal} or ${bold}hw_all.${normal}"

echo ""
echo "${bold}$CLI_NAME validate vrt [flags] [--help]${normal}"
echo ""
echo "Validates V80 RunTime (V80) on the selected device."
echo ""
echo "FLAGS:"
echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
echo "   ${bold}    --tag${normal}       - GitHub tag ID (default: ${bold}$VRT_TAG${normal})."
echo "   ${bold}    --target${normal}    - Sets the build target to $targets"
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""
#exit 1
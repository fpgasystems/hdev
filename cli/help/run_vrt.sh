#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2

#constants
VRT_TAG=$($CLI_PATH/common/get_constant $CLI_PATH VRT_TAG)

#define targers
targets="${bold}sim_all, emu_all,${normal} or ${bold}hw_all.${normal}"

echo ""
echo "${bold}$CLI_NAME run vrt [flags] [--help]${normal}"
echo ""
echo "Runs your V80 RunTime (VRT) application."
echo ""
echo "FLAGS:"
#echo "   ${bold}-c, --config${normal}    - Configuration Index."
#echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
echo "   ${bold}-p, --project${normal}   - Specifies your VRT project name."
echo "   ${bold}    --tag${normal}       - GitHub tag ID (default: ${bold}$VRT_TAG${normal})."
echo "   ${bold}    --target${normal}    - Sets the build target to $targets"
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""
#exit 1
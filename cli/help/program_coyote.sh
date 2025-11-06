#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
COLOR_XILINX=$3
COLOR_OFF=$4
COYOTE_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH COYOTE_COMMIT)

echo ""
echo "${bold}$CLI_NAME program coyote [flags] [--help]${normal}"
echo ""
echo "Programs Coyote shell (dynamic and application layers) to a given device."
echo ""
echo "FLAGS:"
echo "   ${bold}-c, --commit${normal}    - GitHub commit ID (default: ${bold}$COYOTE_COMMIT${normal})."
echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
echo "   ${bold}-p, --project${normal}   - Specifies your Coyote project name." 
echo "   ${bold}-r, --remote${normal}    - Local or remote deployment."
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""
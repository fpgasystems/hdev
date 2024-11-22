#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
AVED_TAG=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TAG)

echo ""
echo "${bold}$CLI_NAME run aved [flags] [--help]${normal}"
echo ""
echo "Runs AVED on a given device."
echo ""
echo "FLAGS:"
echo "   ${bold}-c, --config${normal}    - Configuration index."
echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
echo "   ${bold}-p, --project${normal}   - Specifies your AVED project name."
echo "   ${bold}-t, --tag${normal}       - GitHub tag ID (default: ${bold}$AVED_TAG${normal})."
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""
#exit 1
#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)
ONIC_DRIVER_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_COMMIT)

echo ""
echo "${bold}$CLI_NAME run opennic [flags] [--help]${normal}"
echo ""
echo "Runs OpenNIC on a given device."
echo ""
echo "FLAGS:"
echo "       ${bold}--commit${normal}    - GitHub commit ID for shell (default: ${bold}$ONIC_SHELL_COMMIT${normal})."
echo "       ${bold}--config${normal}    - Configuration index."
echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
echo "   ${bold}-p, --project${normal}   - Specifies your OpenNIC project name."
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""
#exit 1
#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
COYOTE_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH COYOTE_COMMIT)

echo ""
echo "${bold}$CLI_NAME run coyote [flags] [--help]${normal}"
echo ""
echo "Execute a Coyote-based design."
echo ""
echo "FLAGS:"
echo "       ${bold}--commit${normal}    - GitHub commit (default: ${bold}$COYOTE_COMMIT${normal})."
echo "       ${bold}--config${normal}    - Configuration Index."
#echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
echo "   ${bold}-p, --project${normal}   - Specifies your Coyote project name."
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""
#exit 1
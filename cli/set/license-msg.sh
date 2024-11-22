#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"

bold=$(tput bold)
normal=$(tput sgr0)

#early exit
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
if [ "$is_vivado_developer" = "0" ]; then
    exit 1
fi

#print message
echo ""
echo "Please type ${bold}source $CLI_PATH/set/license${normal} to set your favorite Xilinx license servers"
echo ""
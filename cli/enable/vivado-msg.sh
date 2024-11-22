#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
#CLI_PATH="$(dirname "$(dirname "$0")")" # CLI_PATH is declared as an environment variable

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
if [ "$is_build" = "0" ]; then
    exit 1
fi

#print message
echo ""
echo "Please type ${bold}source $CLI_PATH/enable/vivado${normal} to enable your favorite Vivado version"
echo ""
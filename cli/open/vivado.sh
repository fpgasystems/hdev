#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
HDEV_PATH=$(dirname "$CLI_PATH")
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev open vivado --path      $path_value
#example: /opt/hdev/cli/hdev open vivado --path ./my_project.xpr

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
vivado_enabled=$([ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; } && echo 1 || echo 0)
if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "0" ]; then
    exit
fi

#inputs
path_value=$2

#check on symlink
if [ -L "$path_value" ]; then
    path_value=$(readlink -f "$path_value")
fi

#open vivado
echo ""
echo "${bold}hdev open vivado${normal}"
echo ""
echo "vivado $path_value"
vivado $path_value

echo ""

#author: https://github.com/jmoya82
#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil run aved --config $config_index --device $device_index --project $project_name --tag                            $tag_name
#example: /opt/sgrt/cli/sgutil run aved --config             1 --device             1 --project   hello_world --tag amd_v80_gen5x8_23.2_exdes_2_20240408

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)
if [ "$is_build" = "0" ] && [ "$vivado_enabled_asoc" = "0" ]; then
    exit 1
fi

#inputs
config_index=$2
device_index=$4
project_name=$6
tag_name=$8

#all inputs must be provided
if [ "$config_index" = "" ] || [ "$device_index" = "" ] || [ "$project_name" = "" ] || [ "$tag_name" = "" ]; then
    exit
fi

#temporal exit condition
echo "Sorry, we are working on this!"
echo ""
exit

#constants
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="aved"

#define directories (1)
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$tag_name/$project_name"

#author: https://github.com/jmoya82
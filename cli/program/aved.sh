#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
CLI_NAME="sgutil"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil program aved --device $device_index --project $project_name --tag                            $tag_name --version $vivado_version --remote $deploy_option 
#example: /opt/sgrt/cli/sgutil program aved --device             1 --project   hello_world --tag amd_v80_gen5x8_23.2_exdes_2_20240408 --version          2022.2 --remote              0 

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
device_index=$2
project_name=$4
tag_name=$6
vivado_version=$8
deploy_option=${10}
servers_family_list=${11}

#all inputs must be provided
if [ "$device_index" = "" ] || [ "$project_name" = "" ] || [ "$tag_name" = "" ] || [ "$vivado_version" = "" ] || [ "$deploy_option" = "" ]; then
    exit
fi

#constants
AVED_TAG=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TAG)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="aved"

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$tag_name/$project_name"

#get AVED example design name (amd_v80_gen5x8_23.2_exdes_2)
aved_name=$(echo "$tag_name" | sed 's/_[^_]*$//')

#get file_path
pdi_project_name="${aved_name}.$vivado_version.pdi"
file_path="$DIR/$pdi_project_name"

#program image
$CLI_PATH/program/image --device $device_index --path $file_path --remote 0

#programming remote servers (if applies)
programming_string="$CLI_PATH/program/image --device $device_index --path $file_path --remote 0"
$CLI_PATH/program/remote "$CLI_PATH" "$USER" "$deploy_option" "$programming_string" "$servers_family_list"

#author: https://github.com/jmoya82
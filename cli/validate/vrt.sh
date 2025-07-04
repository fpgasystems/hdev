#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
CLI_NAME="hdev"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev validate vrt --device $device_index --tag $tag_name --target $target_name --version $vivado_version
#example: /opt/hdev/cli/hdev validate vrt --device             1 --tag    v1.1.1 --target       hw_all --version          2024.2

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
tag_name=$4
target_name=$6
vivado_version=$8

#all inputs must be provided
if [ "$device_index" = "" ] || [ "$tag_name" = "" ] || [ "$target_name" = "" ] || [ "$vivado_version" = "" ]; then
    exit
fi

#constants
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="vrt"

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#get template name
template_name="00_axilite"

#get device_name
#device_name=$($CLI_PATH/get/get_fpga_device_param $device_index device_name)

#set project name
project_name="validate_vrt.$hostname.$tag_name.$target_name.$vivado_version"

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$tag_name/$project_name"

#remove in the beginning
if [ -d "$DIR" ]; then
    rm -rf "$DIR"
fi

#new
if ! [ -d "$DIR" ]; then
    echo "${bold}$CLI_NAME new $WORKFLOW (tag ID: $tag_name)${normal}"
    echo ""
    $CLI_PATH/new/vrt --tag $tag_name --project $project_name --template $template_name --push 0
fi

#update shell configuration file
sed -i "/^\[workflows\]/!b;n;s/^[0-9]\+: /$device_index: /" "$DIR/sh.cfg"

#author: https://github.com/jmoya82
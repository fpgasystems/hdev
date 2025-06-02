#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev run vrt --project $project_name --tag $tag_name --target $target_name --version $vivado_version
#example: /opt/hdev/cli/hdev run vrt --project   hello_world --tag    v1.0.0 --target       hw_all --version          2024.2

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)
if [ "$is_build" = "0" ] && [ "$vivado_enabled_asoc" = "0" ]; then
    exit 1
fi

#inputs
project_name=$2
tag_name=$4
target_name=$6
vivado_version=$8

#all inputs must be provided
if [ "$project_name" = "" ] || [ "$tag_name" = "" ] || [ "$target_name" = "" ] || [ "$vivado_version" = "" ]; then
    exit
fi

#constants
#BITSTREAM_NAME=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_NAME)
#BITSTREAMS_PATH="$CLI_PATH/bitstreams"
#DRIVER_NAME=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_NAME)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
#NUM_JOBS="8"
WORKFLOW="vrt"

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$tag_name/$project_name"
#SHELL_BUILD_DIR="$DIR/open-nic-shell/script"
#DRIVER_DIR="$DIR/open-nic-driver"

#get template name
VRT_TEMPLATE=$(cat $DIR/VRT_TEMPLATE)

#platform_name to FDEV_NAME
#FDEV_NAME=$(echo "$platform_name" | cut -d'_' -f2)

#define shell
#library_shell="$BITSTREAMS_PATH/$WORKFLOW/$commit_name/${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
#project_shell="$DIR/${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"

#modify Makefile
#sed -i 's|^V80PP_PATH=$(shell realpath ../../submodules/v80-vitis-flow)$|V80PP_PATH=$(shell realpath ../submodules/v80-vitis-flow)|' $DIR/src/Makefile

#read first device index from sh.cfg
device_index=$(awk -F': ' -v w="$WORKFLOW" '$2 == w { print $1; exit }' $DIR/sh.cfg)

#run on device
if [ -d "$DIR/$target_name.$VRT_TEMPLATE.$vivado_version" ]; then
    #get substring (emu_all to emu)
    str="${target_name%%_*}"

    #get upstream port
    upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)

    echo "${bold}Changing directory:${normal}"
    echo ""
    echo "cd $DIR/$target_name.$VRT_TEMPLATE.$vivado_version" # --device $device_index 
    echo ""
    cd $DIR/$target_name.$VRT_TEMPLATE.$vivado_version

    #run
    echo "${bold}Running application:${normal}"
    echo ""
    echo "./$VRT_TEMPLATE $upstream_port ${VRT_TEMPLATE}_$str.vrtbin"
    echo ""
    ./$VRT_TEMPLATE $upstream_port ${VRT_TEMPLATE}_$str.vrtbin
    echo ""
fi

#./00_axilite c4:00.0 00_axilite_emu.vrtbin

#author: https://github.com/jmoya82
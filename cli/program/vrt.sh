#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
CLI_NAME="hdev"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev program vrt --device $device_index --project $project_name --tag                            $tag_name --version $vivado_version --remote $deploy_option 
#example: /opt/hdev/cli/hdev program vrt --device             1 --project   hello_world --tag amd_v80_gen5x8_23.2_exdes_2_20240408 --version          2022.2 --remote              0 

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
AMI_HOME=$($CLI_PATH/common/get_constant $CLI_PATH AMI_HOME)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="vrt"

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$tag_name/$project_name"

#get template name
VRT_TEMPLATE=$(cat $DIR/VRT_TEMPLATE)

#get bdf
upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)

echo "${bold}Creating device directory:${normal}"
echo ""
upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
echo "mkdir -p $AMI_HOME/$upstream_port"
mkdir -p "$AMI_HOME/$upstream_port"
echo ""

#partial programming
echo "${bold}Partial programming:${normal}"
echo ""
echo "$(which v80-smi) partial_program -d $upstream_port -i $DIR/hw_all.$VRT_TEMPLATE.$vivado_version/${VRT_TEMPLATE}_hw.vrtbin"
echo ""
$(which v80-smi) partial_program -d $upstream_port -i $DIR/hw_all.$VRT_TEMPLATE.$vivado_version/${VRT_TEMPLATE}_hw.vrtbin

echo ""

#programming remote servers (if applies)
programming_string="$CLI_PATH/program/vrt --device $device_index --project $project_name --tag $tag_name --version $vivado_version --remote 0"
$CLI_PATH/program/remote "$CLI_PATH" "$USER" "$deploy_option" "$programming_string" "$servers_family_list"

#author: https://github.com/jmoya82
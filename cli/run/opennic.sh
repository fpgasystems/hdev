#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil run opennic --commit $commit_name --config $config_index --device $device_index --project $project_name
#example: /opt/sgrt/cli/sgutil run opennic --commit      8077751 --config             1 --device             1 --project   hello_world

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

#temporal exit condition
if [ "$is_asoc" = "1" ]; then
    echo ""
    echo "Sorry, we are working on this!"
    echo ""
    exit
fi

#inputs
commit_name=$2
config_index=$4
device_index=$6
project_name=$8

#all inputs must be provided
if [ "$commit_name" = "" ] || [ "$config_index" = "" ] || [ "$device_index" = "" ] || [ "$project_name" = "" ]; then
    exit
fi

#constants
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="opennic"

#define directories (1)
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name"

#get FDEV_NAME
platform=$($CLI_PATH/get/get_fpga_device_param $device_index platform)
FDEV_NAME=$(echo "$platform" | cut -d'_' -f2)

#change directory
echo "${bold}Changing directory:${normal}"
echo ""
echo "cd $DIR"
echo ""
cd $DIR

#display configuration
echo "${bold}Device parameters:${normal}"
echo ""
cat $DIR/.device_config
echo ""

#get config name
config_string=$($CLI_PATH/common/get_config_string $config_index)
config_name="host_config_$config_string"

echo "${bold}You are running $config_name:${normal}"
echo ""
cat $DIR/configs/$config_name
echo ""

#run application
echo "${bold}Running your OpenNIC application:${normal}"
echo ""
echo "./onic --config $config_index --device $device_index "
echo ""
./onic --config "$config_index" --device "$device_index"
return_code=$?

echo ""

#exit with return code
exit $return_code

#author: https://github.com/jmoya82
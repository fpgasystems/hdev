#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev run hip --device $device_index --tag $tag_name --project $project_name 
#example: /opt/hdev/cli/hdev run hip --device             1 --tag    2025.6 --project   hello_world

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
IS_GPU_DEVELOPER="1"
is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
gpu_enabled=$([ "$IS_GPU_DEVELOPER" = "1" ] && [ "$is_gpu" = "1" ] && echo 1 || echo 0)
if [ "$is_build" = "1" ] || [ "$hip_enabled" = "0" ]; then
    exit
fi

#inputs
device_index=$2
tag_name=$4
project_name=$6

#all inputs must be provided
if [ "$device_index" = "" ] || [ "$tag_name" = "" ] || [ "$project_name" = "" ]; then
    exit
fi

#constants
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="hip"

#define directories (1)
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$tag_name/$project_name"

#change directory
echo "${bold}Changing directory:${normal}"
echo ""
echo "cd $DIR"
echo ""
cd $DIR

#display configuration
cd $DIR/configs/
config_id=$(ls *.active)
config_id="${config_id%%.*}"

echo "${bold}You are running $config_id:${normal}"
echo ""
cat $DIR/configs/$config_id
echo ""

#get kernel from kn.cfg
kernel_name=$(grep "^${device_index}:" $DIR/kn.cfg | cut -d':' -f2 | xargs)

#run
echo "${bold}Running HIP:${normal}"
echo ""
echo "$DIR/hip $device_index $kernel_name"
echo ""

#the GPU index starts at 0
device_index=$(($device_index-1))
$DIR/hip $device_index $kernel_name

echo ""
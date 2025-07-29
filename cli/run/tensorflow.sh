#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev run tensorflow --commit $TENSORFLOW_COMMIT --config $config_index --project $project_name
#example: /opt/hdev/cli/hdev run tensorflow --commit            b9ba6f2 --config             1 --project   hello_world

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
IS_GPU_DEVELOPER="1"
gpu_enabled=$([ "$IS_GPU_DEVELOPER" = "1" ] && [ "$is_gpu" = "1" ] && echo 1 || echo 0)
if [ "$is_build" = "1" ] || [ "$gpu_enabled" = "0" ]; then
    exit 1
fi

#inputs
TENSORFLOW_COMMIT=$2
config_index=$4
project_name=$6

#all inputs must be provided
if [ "$TENSORFLOW_COMMIT" = "" ] || [ "$config_index" = "" ] || [ "$project_name" = "" ]; then #|| [ "$device_index" = "" ] 
    exit
fi

#constants
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="tensorflow"

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$TENSORFLOW_COMMIT/$project_name"

#change directory
echo "${bold}Changing directory:${normal}"
echo ""
echo "cd $DIR"
echo ""
cd $DIR

#display configuration
echo "${bold}Kernel configuration:${normal}"
#echo ""
#echo "cat $DIR/kn.cfg"
echo ""
cat $DIR/kn.cfg
echo ""
echo ""

#get config name
config_string=$($CLI_PATH/common/get_config_string $config_index)
config_name="host_config_$config_string"

echo "${bold}You are running $config_name:${normal}"
echo ""
cat $DIR/configs/$config_name
echo ""

#run application
echo "${bold}Running your Tensorflow application:${normal}"
echo ""
echo "python3 ./src/main.py 0 float32 $config_string" # --device $device_index 
echo ""
python3 ./src/main.py 0 float32 $config_string
echo ""

#author: https://github.com/jmoya82
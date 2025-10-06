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
IS_HIP_DEVELOPER="1"
hip_enabled=$([ "$IS_HIP_DEVELOPER" = "1" ] && [ "$is_gpu" = "1" ] && echo 1 || echo 0)
if [ "$is_build" = "1" ] || [ "$hip_enabled" = "0" ]; then
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

#get config_string
config_string=$($CLI_PATH/common/get_config_string $config_index)

#display device configuration
echo "${bold}Device configuration:${normal}"
first_kernel=$(tail -n +2 kn.cfg | head -n 1 | cut -d':' -f2 | xargs)
if [ -d "$DIR/$first_kernel.xla" ]; then
    echo ""
    cat $DIR/configs/device_config #this would be .device_config if hdev build tensorflow is implemented
    echo ""
else
    echo ""
    cat $DIR/data/input_$config_string/device_config
    echo ""
fi

#display kernel configuration
echo "${bold}Kernel configuration:${normal}"
#echo ""
#echo "cat $DIR/kn.cfg"
echo ""
tail -n +2 "$DIR/kn.cfg"
echo ""
echo ""

#display host configuration
config_name="host_config_$config_string"
echo "${bold}Host configuration:${normal}"
echo ""
cat $DIR/configs/$config_name
echo ""

#run application
echo "${bold}Running your Tensorflow application:${normal}"
echo ""
echo "python3 ./src/main.py $config_string" # --device $device_index 
echo ""
python3 ./src/main.py $config_string
echo ""

#author: https://github.com/jmoya82
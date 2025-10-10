#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev new hip --tag $tag_name --project $project_name
#example: /opt/hdev/cli/hdev new hip --tag  2025.6.1 --project   hello_world

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
IS_GPU_DEVELOPER="1"
hip_enabled=$([ "$IS_GPU_DEVELOPER" = "1" ] && [ "$is_gpu" = "1" ] && echo 1 || echo 0)
if [ "$is_build" = "0" ] && [ "$hip_enabled" = "0" ]; then
    exit 1
fi

#inputs
tag_name=$2
project_name=$4

#all inputs must be provided
if [ "$tag_name" = "" ] || [ "$project_name" = "" ]; then
    exit
fi

#constants
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="hip"

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$tag_name/$project_name"
APP_BUILD_DIR="$DIR/build_dir"

#create build_dir
if ! [ -d "$APP_BUILD_DIR" ]; then
    mkdir $APP_BUILD_DIR
fi

#change directory
echo "${bold}Changing directory:${normal}"
echo ""
echo "cd $DIR"
echo ""
cd $DIR

#display configuration
echo "${bold}Device parameters:${normal}"
echo ""
cat $DIR/configs/device_config
echo ""

#get config name
cd $DIR/configs
active_file=( host_config_*.active )
if [[ -e ${active_file[0]} ]]; then
    config_name="${active_file[0]%.active}"
fi
cd $DIR

echo "${bold}Host parameters ($config_name):${normal}"
echo ""
cat $DIR/configs/$config_name
echo ""

#get cpp files
cpp_files=$($CLI_PATH/common/get_files $DIR/src/gpu_kernels .cpp)

#copy and compile
echo "${bold}Compiling HIP project:${normal}"
echo ""
sleep 1
echo "hipcc $DIR/src/main.cpp $cpp_files -o $APP_BUILD_DIR/main"
echo ""
hipcc $DIR/src/main.cpp $cpp_files -o $APP_BUILD_DIR/main

echo "HIP compilation ${bold}($config_name)${normal} done!${normal}"
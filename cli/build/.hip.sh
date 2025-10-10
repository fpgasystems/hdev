#!/bin/bash

#early exit
if [ "$is_build" = "0" ] && [ "$hip_enabled" = "0" ]; then
    exit 1
fi

#check on software
gh_check "$CLI_PATH"

#constants
ROCM_PATH=$($CLI_PATH/common/get_constant $CLI_PATH ROCM_PATH)

#verify hip workflow (based on installed software)
test1=$(dkms status | grep amdgpu)
if [ -z "$test1" ] || [ ! -d "$ROCM_PATH/bin/" ]; then
    echo ""
    echo "Sorry, this command is not available on ${bold}$hostname!${normal}"
    echo ""
    exit 1
fi

#check on flags
valid_flags="-p --project -t --tag -h --help"
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#constants
CONFIG_PREFIX="host_config_"

#set defaults
tag_found="0"

#checks on command line
if [ ! "$flags_array" = "" ]; then
    word_check "$CLI_PATH" "-t" "--tag" "${flags_array[@]}"
    tag_found=$word_found
    tag_name=$word_value
    project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "${flags_array[@]}"
    project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
    if [ "$project_found" = "1" ]; then
        config_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "$project_name" "$CONFIG_PREFIX" "yes" "${flags_array[@]}"
    fi
fi

#dialogs
#check on tag
if [ "$tag_found" = "0" ]; then
    tag_found="1"
    tag_name=$(cat $HDEV_PATH/TAG)
fi
project_check_empty "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name"
echo ""
echo "${bold}$CLI_NAME $command $arguments (tag ID: $tag_name)${normal}"
echo ""
project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "${flags_array[@]}"

#define directories
DIR="$MY_PROJECTS_PATH/$arguments/$tag_name/$project_name"

#create or select a configuration
#cd $DIR/configs/
#if [[ $(ls -l | wc -l) = 2 ]]; then
#    #only config_000 exists and we create config_001
#    #we compile create_config (in case there were changes)
#    cd $DIR/src
#    g++ -std=c++17 create_config.cpp -o ../create_config >&/dev/null
#    cd $DIR
#    ./create_config
#    cp -fr $DIR/configs/config_001.hpp $DIR/configs/config_000.hpp
#    config="config_001.hpp"
#elif [[ $(ls -l | wc -l) = 3 ]]; then
#    #config_000 and config_001 exist
#    cp -fr $DIR/configs/config_001.hpp $DIR/configs/config_000.hpp
#    config="config_001.hpp"
#    echo ""
#elif [[ $(ls -l | wc -l) > 4 ]]; then
#    cd $DIR/configs/
#    configs=( "config_"*.hpp )
#    echo ""
#    echo "${bold}Please, choose your configuration:${normal}"
#    echo ""
#    PS3=""
#    select config in "${configs[@]:1}"; do
#        if [[ -z $config ]]; then
#            echo "" >&/dev/null
#        else
#            break
#        fi
#    done
#    # copy selected config as config_000.hpp
#    cp -fr $DIR/configs/$config $DIR/configs/config_000.hpp
#fi

#save config id
cd $DIR/configs/
if [ -e config_*.active ]; then
    rm *.active
fi
config_id="${config%%.*}"
touch $config_id.active

#we force the user to create a configuration
if [ ! -f "$MY_PROJECTS_PATH/$arguments/$tag_name/$project_name/configs/device_config" ]; then
    #get current path
    current_path=$(pwd)
    cd "$MY_PROJECTS_PATH/$arguments/$tag_name/$project_name"
    echo "${bold}Adding device and host configurations with ./config_add:${normal}"
    ./config_add
    cd "$current_path"
fi

#const int N = 2560;
#const int N_THREADS = 128;
#device_config.hpp N_THREADS
#host_config_001.hpp N ==> host_config_000.hpp

#remove first
rm -f $DIR/configs/host_config_*.hpp

#convert to hpp
$CLI_PATH/common/convert_to_hpp device_config
for file in host_config_*; do
    # Skip if no files match
    [[ -e "$file" ]] || continue
    "$CLI_PATH/common/convert_to_hpp" "$file"
done

#select configuration and save as host_config_000.hpp
hpp_files=( host_config_*.hpp )
if (( ${#hpp_files[@]} == 1 )); then
    config="host_config_001.hpp"
    cp -fr $DIR/configs/$config $DIR/configs/host_config_000.hpp
else
    echo "→ One or zero .hpp files"
fi

#run
$CLI_PATH/build/hip --tag $tag_name --project $project_name
echo ""
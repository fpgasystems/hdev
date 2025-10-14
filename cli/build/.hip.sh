#!/bin/bash

#early exit
if [ "$is_build" = "0" ] && [ "$hip_enabled" = "0" ]; then
    exit 1
fi

#check on software
gh_check "$CLI_PATH"

#constants
ROCM_PATH=$($CLI_PATH/common/get_constant $CLI_PATH ROCM_PATH)

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

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
    if [ "$project_found" = "1" ]; then
        config_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "$project_name" "$CONFIG_PREFIX" "yes" "${flags_array[@]}"
    fi
fi

if [ "$project_found" = "0" ]; then
    add_echo="no"
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

#change directory
cd $DIR/configs/

#we force the user to create a configuration
if [ ! -f "$MY_PROJECTS_PATH/$arguments/$tag_name/$project_name/configs/device_config" ]; then
    #get current path
    current_path=$(pwd)
    cd "$MY_PROJECTS_PATH/$arguments/$tag_name/$project_name"
    echo "${bold}Adding device and host configurations with ./config_add:${normal}"
    ./config_add
    cd "$current_path"
fi

#select configuration and save as host_config_000.hpp
hpp_files=( host_config_*.hpp )
if (( ${#hpp_files[@]} == 1 )); then
    config_name="host_config_001"
    #cp -fr $DIR/configs/$config_name $DIR/configs/host_config_000.hpp
else
    rm -f $DIR/configs/host_config_*.active
    config_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "$project_name" "$CONFIG_PREFIX" "$add_echo" "${flags_array[@]}"
    if [ "$project_found" = "1" ] && [ ! -e "$MY_PROJECTS_PATH/$arguments/$tag_name/$project_name/configs/$config_name" ]; then
        echo ""
        echo "$CHECK_ON_CONFIG_ERR_MSG"
        echo ""
        exit
    fi
    #cp -fr $DIR/configs/$config_name $DIR/configs/host_config_000.hpp
fi

#remove first
rm -f $DIR/configs/host_config_*.hpp

#convert to hpp
$CLI_PATH/common/convert_to_hpp device_config
for file in host_config_*; do
    # Skip if no files match
    [[ -e "$file" ]] || continue
    "$CLI_PATH/common/convert_to_hpp" "$file"
done

#save as host_config_000.hpp
cp -fr $DIR/configs/$config_name.hpp $DIR/configs/host_config_000.hpp

#save active configuration
if [ -e config_*.active ]; then
    rm *.active
fi
config_id="${config_name%%.*}"
touch $config_id.active

#run
$CLI_PATH/build/hip --tag $tag_name --project $project_name
echo ""
#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
HDEV_PATH=$(dirname "$CLI_PATH")
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev new hip --tag  $HIP_TAG --project   $new_name --push $push_option
#example: /opt/hdev/cli/hdev new hip --tag  2025.6.1 --project hello_world --push            0

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
IS_HIP_DEVELOPER="1"
hip_enabled=$([ "$IS_HIP_DEVELOPER" = "1" ] && [ "$is_gpu" = "1" ] && echo 1 || echo 0)
if [ "$is_build" = "0" ] && [ "$hip_enabled" = "0" ]; then
    exit 1
fi

#inputs
HIP_TAG=$2
new_name=$4
push_option=$6

#all inputs must be provided
if [ "$HIP_TAG" = "" ] || [ "$new_name" = "" ] || [ "$push_option" = "" ]; then
    exit
fi

echo "HEY I am here"
echo "HIP_TAG: $HIP_TAG"
echo "new_name: $new_name"
echo "push_option: $push_option"

#constants
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="hip"

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$HIP_TAG/$new_name"

#create directories
mkdir -p $DIR

#change directory
cd $MY_PROJECTS_PATH/$WORKFLOW/$HIP_TAG

#create repository
if [ "$push_option" = "1" ]; then 
    gh repo create $new_name --public --clone
    echo ""
else
    mkdir -p $DIR
fi

#save HIP_TAG
echo "$HIP_TAG" > $DIR/HIP_TAG

#add api files
cp $HDEV_PATH/api/config_add $DIR
cp $HDEV_PATH/api/config_delete $DIR

#add template files

#copy template from HDEV_PATH
HDEV_PATH=$(dirname "$CLI_PATH")
cp -rf $HDEV_PATH/templates/$WORKFLOW/* $DIR
#compile src
#cd $DIR/src
#g++ -std=c++17 create_config.cpp -o ../create_config >&/dev/null
#g++ -std=c++17 create_data.cpp -o ../create_data

#push files
if [ "$push_option" = "1" ]; then 
    cd $DIR
    #update README.md 
    if [ -e README.md ]; then
        rm README.md
    fi
    echo "# "$new_name >> README.md
    #add gitignore
    echo ".DS_Store" >> .gitignore
    #add, commit, push
    git add .
    git commit -m "First commit"
    git push --set-upstream origin master
    echo ""
fi

#echo ""
echo "The project ${bold}$DIR${normal} has been created!"
echo ""

#author: https://github.com/jmoya82
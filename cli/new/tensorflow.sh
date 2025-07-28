#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
HDEV_PATH=$(dirname "$CLI_PATH")
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev new tensorflow --commit $TENSORFLOW_COMMIT --project   $new_name --push $push_option
#example: /opt/hdev/cli/hdev new tensorflow --commit            b9ba6f2 --project hello_world --push            0

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
new_name=$4
push_option=$6

#all inputs must be provided
if [ "$TENSORFLOW_COMMIT" = "" ] || [ "$new_name" = "" ] || [ "$push_option" = "" ]; then
    exit
fi

#constants
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="tensorflow"

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$TENSORFLOW_COMMIT/$new_name"

#create directories
mkdir -p $DIR

#change directory
cd $MY_PROJECTS_PATH/$WORKFLOW/$TENSORFLOW_COMMIT

#create repository
if [ "$push_option" = "1" ]; then 
    gh repo create $new_name --public --clone
    echo ""
else
    mkdir -p $DIR
fi

#save TENSORFLOW_COMMIT
echo "$TENSORFLOW_COMMIT" > $DIR/TF_COMMIT

#add template files
cp $HDEV_PATH/templates/$WORKFLOW/config_add.sh $DIR/config_add
cp $HDEV_PATH/templates/$WORKFLOW/config_delete.sh $DIR/config_delete
cp $HDEV_PATH/templates/$WORKFLOW/config_parameters $DIR/config_parameters
cp $HDEV_PATH/templates/$WORKFLOW/data_add.sh $DIR/data_add
cp -r $HDEV_PATH/templates/$WORKFLOW/configs $DIR
cp -r $HDEV_PATH/templates/$WORKFLOW/data $DIR
cp -r $HDEV_PATH/templates/$WORKFLOW/src $DIR
cp $HDEV_PATH/templates/$WORKFLOW/kn.cfg $DIR/kn.cfg
cp $HDEV_PATH/templates/$WORKFLOW/vadd.cfg $DIR/vadd.cfg
cp $HDEV_PATH/templates/$WORKFLOW/vsub.cfg $DIR/vsub.cfg

#compile files
chmod +x $DIR/config_add
chmod +x $DIR/config_delete
chmod +x $DIR/data_add

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

#print message
sleep 2.5
echo "The project ${bold}$DIR${normal} has been created!"
echo ""

#author: https://github.com/jmoya82
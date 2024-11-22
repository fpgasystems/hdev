#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
SGRT_PATH=$(dirname "$CLI_PATH")
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil new aved --tag                            $tag_name --project   $new_name --push $push_option
#example: /opt/sgrt/cli/sgutil new aved --tag amd_v80_gen5x8_23.2_exdes_2_20240408 --project hello_world --push            0

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)
if [ "$is_build" = "0" ] && [ "$vivado_enabled_asoc" = "0" ]; then
    exit 1
fi

#inputs
tag_name=$2
new_name=$4
push_option=$6

#all inputs must be provided
if [ "$tag_name" = "" ] || [ "$new_name" = "" ] || [ "$push_option" = "" ]; then
    exit
fi

#constants
AVED_SMBUS_IP=$($CLI_PATH/common/get_constant $CLI_PATH AVED_SMBUS_IP)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="aved"

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$tag_name/$new_name"

#create directories
mkdir -p $DIR

#change directory
cd $MY_PROJECTS_PATH/$WORKFLOW/$tag_name

#create repository
if [ "$push_option" = "1" ]; then 
    gh repo create $new_name --public --clone
    echo ""
else
    mkdir -p $DIR
fi

#clone repository
$CLI_PATH/common/git_clone_aved $DIR $tag_name

#change to project directory
#cd $DIR

#save tag_name
echo "$tag_name" > $DIR/AVED_TAG

#move files
mv $DIR/AVED/* $DIR/
rm -rf $DIR/AVED

#remove files
rm $DIR/README.md

#get AVED example design name
aved_name=$(echo "$tag_name" | sed 's/_[^_]*$//')

#get SMBus version
smbus_version=$(find "$SGRT_PATH/templates/$WORKFLOW/$AVED_SMBUS_IP/ip" -type d -name 'smbus_v*' -print -quit)
smbus_version=$(basename "$smbus_version")

#copy SMBus IP
cp -r $SGRT_PATH/templates/$WORKFLOW/$AVED_SMBUS_IP/ip/$smbus_version $DIR/hw/$aved_name/src/iprepo/$smbus_version

#add template files
cp $SGRT_PATH/templates/$WORKFLOW/config_add.sh $DIR/config_add
cp $SGRT_PATH/templates/$WORKFLOW/config_delete.sh $DIR/config_delete
cp $SGRT_PATH/templates/$WORKFLOW/config_parameters $DIR/config_parameters
#cp $SGRT_PATH/templates/$WORKFLOW/get_incoming_uuid.c $DIR/sw/AMI/app/cmd_handlers/get_incoming_uuid.c
#adds the flag -n to cmd_cfgmem_program.c (Quit after returning new_uuid)
#cp $SGRT_PATH/templates/$WORKFLOW/cmd_cfgmem_program.c $DIR/sw/AMI/app/cmd_handlers/cmd_cfgmem_program.c

cp -r $SGRT_PATH/templates/$WORKFLOW/configs $DIR
#cp -r $SGRT_PATH/templates/$WORKFLOW/src $DIR

#compile files
chmod +x $DIR/config_add
chmod +x $DIR/config_delete

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
echo "The project ${bold}$DIR${normal} has been created!"
echo ""

#author: https://github.com/jmoya82
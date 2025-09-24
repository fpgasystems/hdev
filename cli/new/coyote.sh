#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
HDEV_PATH=$(dirname "$CLI_PATH")
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev new coyote --commit $commit_name --number $pullrq_id --project   $new_name --name  $device_name --template $template_name --push $push_option
#example: /opt/hdev/cli/hdev new coyote --commit       807775 --number        137 --project hello_world --name xcu280_u55c_0 --template 01_hello_world --push            0

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
vivado_enabled=$([ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; } && echo 1 || echo 0)
if [ "$is_build" = "0" ] && [ "$vivado_enabled" = "0" ]; then
    exit 1
fi

#temporal exit condition
url="${HOSTNAME}"
hostname="${url%%.*}"

check_connectivity() {
    local interface="$1"
    local remote_server="$2"

    # Ping the remote server using the specified interface, sending only 1 packet
    if ping -I "$interface" -c 1 "$remote_server" &> /dev/null; then
        echo "1"
    else
        echo "0"
    fi
}

#inputs
commit_name=$2
pullrq_id=$4
new_name=$6
device_name=$8
template_name=${10}
push_option=${12}

#all inputs must be provided
if [ "$commit_name" = "" ] || [ "$pullrq_id" = "" ] || [ "$new_name" = "" ] || [ "$device_name" = "" ] || [ "$template_name" = "" ] || [ "$push_option" = "" ]; then
    exit
fi

#constants
DEVICES_LIST_FPGA="$CLI_PATH/devices_acap_fpga"
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="coyote"

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$new_name"

#create directories
mkdir -p $DIR

#change directory
cd $MY_PROJECTS_PATH/$WORKFLOW/$commit_name

#create repository
if [ "$push_option" = "1" ]; then 
    gh repo create $new_name --public --clone
    echo ""
else
    mkdir -p $DIR
fi

#clone repository
$CLI_PATH/common/git_clone_coyote $CLI_PATH $DIR $commit_name $pullrq_id

#save commit_name (PR)
if [ "$pullrq_id" = "none" ]; then
    id="$commit_name"
else
    id="$pullrq_id"
fi
echo "$id" > $DIR/COYOTE_COMMIT

#save ONIC_DEVICE_NAME 
echo "$device_name" > $DIR/COYOTE_DEVICE_NAME

#save template_name
echo "$template_name" > $DIR/COYOTE_TEMPLATE

#move files
mv $DIR/coyote/* $DIR/
rm -rf $DIR/coyote

#remove files
rm $DIR/*.md

#create template_name folder
mkdir $DIR/$template_name

#copy template files
cp -r $DIR/examples/$template_name/* $DIR/$template_name

#delete examples
rm -rf $DIR/examples/

#add api files
cp $HDEV_PATH/api/config_add $DIR
cp $HDEV_PATH/api/config_delete $DIR

#add template files
cp $HDEV_PATH/templates/$WORKFLOW/config_parameters $DIR/config_parameters
cp -r $HDEV_PATH/templates/$WORKFLOW/configs $DIR
cp $HDEV_PATH/templates/$WORKFLOW/sh.cfg $DIR/sh.cfg

#compile files
chmod +x $DIR/config_add
chmod +x $DIR/config_delete

#add to sh.cfg (get index of the first FPGA)
device_index=$(awk -v devname="$device_name" '$6 == devname { print $1; exit }' "$DEVICES_LIST_FPGA")
if [[ -n "$device_index" ]]; then
    echo "$device_index: coyote" >> "$DIR/sh.cfg"
fi

#update CMakeLists.txt
sed -i 's|set(CYT_DIR ${CMAKE_SOURCE_DIR}/../../../)|set(CYT_DIR ${CMAKE_SOURCE_DIR}/../..)|' "$DIR/$template_name/hw/CMakeLists.txt" #hardware, hw
sed -i 's|set(CYT_DIR ${CMAKE_SOURCE_DIR}/../../../)|set(CYT_DIR ${CMAKE_SOURCE_DIR}/../..)|' "$DIR/$template_name/sw/CMakeLists.txt" #software, sw

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
#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
HDEV_PATH=$(dirname "$CLI_PATH")
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev new vrt --tag                            $tag_name --project   $new_name --name $device_name --template $template_name --push $push_option --number $pullrq_id
#example: /opt/hdev/cli/hdev new vrt --tag amd_v80_gen5x8_23.2_exdes_2_20240408 --project hello_world --name      xcv80_1 --template     00_axilite --push            0 --number          1

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)
#if [ "$is_build" = "1" ] || [ "$vivado_enabled_asoc" = "0" ]; then
if [ "$is_build" = "0" ] && [ "$vivado_enabled_asoc" = "0" ]; then
    exit 1
fi

#inputs
tag_name=$2
new_name=$4
device_name=$6
template_name=$8
push_option=${10}
pullrq_id=${12}

#all inputs must be provided
if [ "$tag_name" = "" ] || [ "$new_name" = "" ] || [ "$device_name" = "" ] || [ "$template_name" = "" ] || [ "$push_option" = "" ] || [ "$pullrq_id" = "" ]; then
    exit
fi

#constants
#AMI_HOME=$($CLI_PATH/common/get_constant $CLI_PATH AMI_HOME)
AVED_PATH=$($CLI_PATH/common/get_constant $CLI_PATH AVED_PATH)
AVED_SMBUS_IP=$($CLI_PATH/common/get_constant $CLI_PATH AVED_SMBUS_IP)
AVED_TAG=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TAG)
DEVICES_LIST_FPGA="$CLI_PATH/devices_acap_fpga"
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="vrt"

#get number of fpga and acap devices present
#MAX_DEVICES=""
#if [ -s "$DEVICES_LIST_FPGA" ]; then
#    source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST_FPGA"
#    MAX_DEVICES=$(grep -E "fpga|acap|asoc" $DEVICES_LIST_FPGA | wc -l)
#fi

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
$CLI_PATH/common/git_clone_vrt $CLI_PATH $DIR $tag_name $pullrq_id

#save tag_name and template_name
echo "$tag_name" > $DIR/VRT_TAG
echo "$template_name" > $DIR/VRT_TEMPLATE

#move files
mv $DIR/SLASH/* $DIR/
rm -rf $DIR/SLASH

#remove files
rm $DIR/README.md
rm $DIR/LICENSE

#create src folder
mkdir $DIR/src

#copy template files
cp -r $DIR/examples/$template_name/* $DIR/src

#delete examples
rm -rf $DIR/examples/

#create device directories (it will contain system_map.xml)
#if [ ! "$MAX_DEVICES" = "" ]; then
#    echo "${bold}Creating device directories:${normal}"
#    echo ""
#    for device_index in $(seq 1 $MAX_DEVICES); do 
#        device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
#        if [ "$device_type" = "asoc" ]; then
#            upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
#            echo "mkdir -p $AMI_HOME/$upstream_port"
#            mkdir -p "$AMI_HOME/$upstream_port"
#        fi
#    done
#    echo ""
#fi

#get tag base (from amd_v80_gen5x8_24.1_20241002 to amd_v80_gen5x8_24.1)
tag_base="${AVED_TAG%_*}"

#copy SMBus IP
cp -r $HDEV_PATH/templates/$WORKFLOW/$AVED_SMBUS_IP $DIR/submodules/v80-vitis-flow/submodules/aved/hw/$tag_base/src/iprepo

#add template files
cp $HDEV_PATH/templates/$WORKFLOW/config_add.sh $DIR/config_add
cp $HDEV_PATH/templates/$WORKFLOW/config_delete.sh $DIR/config_delete
cp $HDEV_PATH/templates/$WORKFLOW/config_parameters $DIR/config_parameters
cp -r $HDEV_PATH/templates/$WORKFLOW/configs $DIR
cp $HDEV_PATH/templates/$WORKFLOW/sh.cfg $DIR/sh.cfg
#cp -r $HDEV_PATH/templates/$WORKFLOW/src $DIR

#get device_name
#device_name=$($CLI_PATH/get/get_fpga_device_param $device_index device_name)

#save to 
echo "$device_name" > $DIR/VRT_DEVICE_NAME

#add to sh.cfg (get index of the first FPGA)
device_index=$(awk -v devname="$device_name" '$6 == devname { print $1; exit }' "$DEVICES_LIST_FPGA")
if [[ -n "$device_index" ]]; then
    echo "$device_index: $WORKFLOW" >> "$DIR/sh.cfg"
fi

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
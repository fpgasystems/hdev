#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil program image --device $device_index --path          $image_path --remote $deploy_option 
#example: /opt/sgrt/cli/sgutil program image --device             1 --path path_to_my_image.pdi --remote              0

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)
if [ "$is_build" = "1" ] || [ "$vivado_enabled_asoc" = "0" ]; then
    exit
fi

#inputs
device_index=$2
image_path=$4
deploy_option=$6
servers_family_list=$7

#all inputs must be provided
if [ "$device_index" = "" ] || [ "$image_path" = "" ] || [ "$deploy_option" = "" ]; then
    exit
fi

#check on remote aboslute path
if [ "$deploy_option" = "1" ] && [[ "$image_path" == "./"* ]]; then
    exit
fi

#constants
AVED_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TOOLS_PATH)
PARTITION_INDEX="1"
PARTITION_TYPE="primary"

echo "${bold}sgutil program image${normal}"
echo ""

#extend relative path
current_directory=$(pwd)
if [[ "$image_path" == "./"* ]]; then
    image_path="${current_directory}/${image_path#./}"
fi

#get path and file
path="${image_path%/*}/"
file="${image_path##*/}"

#change directory
echo "${bold}Changing directory:${normal}"
echo ""
echo "cd $path"
echo ""
cd $path

#get upstream_port
upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)

#get product_name
product_name=$($AVED_TOOLS_PATH/ami_tool mfg_info -d $upstream_port | grep "Product Name" | awk -F'|' '{print $2}' | xargs)

#check on AVED_UUID (this represents user’s UUID and is different from constants/AVED_UUID)
if [[ ! -e ./AVED_UUID ]]; then
    #AVED_UUID does not exist
    echo "${bold}Programming partition and booting device:${normal}"
    echo ""
    echo "sudo $AVED_TOOLS_PATH/ami_tool cfgmem_program -d $upstream_port -t $PARTITION_TYPE -i ./$file -p $PARTITION_INDEX -y"
    echo ""
    sudo $AVED_TOOLS_PATH/ami_tool cfgmem_program -d $upstream_port -t $PARTITION_TYPE -i ./$file -p $PARTITION_INDEX -y
    echo ""
    #get current_uuid
    current_uuid=$($AVED_TOOLS_PATH/ami_tool overview | grep "^$upstream_port" | tr -d '|' | sed "s/$product_name//g" | awk '{print $2}') ############## use AVED_TOOLS_PATH
    #create AVED_UUID
    if [[ -w "$path" ]]; then
        echo "$current_uuid" > ./AVED_UUID
    fi
else
    #AVED_UUID exists
    current_uuid=$($AVED_TOOLS_PATH/ami_tool overview | grep "^$upstream_port" | tr -d '|' | sed "s/$product_name//g" | awk '{print $2}')
    AVED_UUID=$(< ./AVED_UUID)
    if [ "$current_uuid" = "$AVED_UUID" ]; then
        sleep 2
        echo "OK. Partition selected ($PARTITION_INDEX) - already programmed."
        echo "***********************************************"
        echo ""
    else
        #program from partiton
        echo "${bold}Booting device from partition:${normal}"
        echo ""
        echo "sudo $AVED_TOOLS_PATH/ami_tool device_boot -d $upstream_port -p $PARTITION_INDEX"
        echo ""
        sudo $AVED_TOOLS_PATH/ami_tool device_boot -d $upstream_port -p $PARTITION_INDEX
        echo ""
        current_uuid=$($AVED_TOOLS_PATH/ami_tool overview | grep "^$upstream_port" | tr -d '|' | sed "s/$product_name//g" | awk '{print $2}')
        AVED_UUID=$(< ./AVED_UUID)
        if [ ! "$current_uuid" = "$AVED_UUID" ]; then
            #exactly the same as if AVED_UUID does not exist
            echo "Flash image update is required..."
            echo ""
            echo "${bold}Programming partition and booting device:${normal}"
            echo ""
            echo "sudo $AVED_TOOLS_PATH/ami_tool cfgmem_program -d $upstream_port -t $PARTITION_TYPE -i ./$file -p $PARTITION_INDEX -y"
            echo ""
            sudo $AVED_TOOLS_PATH/ami_tool cfgmem_program -d $upstream_port -t $PARTITION_TYPE -i ./$file -p $PARTITION_INDEX -y
            echo ""
        fi
    fi
fi

#programming remote servers (if applies)
programming_string="$CLI_PATH/program/image --device $device_index --path $file_path --remote 0"
$CLI_PATH/program/remote "$CLI_PATH" "$USER" "$deploy_option" "$programming_string" "$servers_family_list"

#author: https://github.com/jmoya82
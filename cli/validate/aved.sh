#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
CLI_NAME="sgutil"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil validate aved --device $device_index
#example: /opt/sgrt/cli/sgutil validate aved --device             1

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)
if [ "$vivado_enabled_asoc" = "0" ]; then
    exit
fi

#inputs
device_index=$2

#constants
AVED_PATH=$($CLI_PATH/common/get_constant $CLI_PATH AVED_PATH)
AVED_TAG=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TAG)
AVED_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TOOLS_PATH)
AVED_UUID=$($CLI_PATH/common/get_constant $CLI_PATH AVED_UUID)
AVED_VALIDATE_DESIGN="design.pdi"
PARTITION_INDEX="0"
PARTITION_TYPE="primary"

#all inputs must be provided
if [ "$device_index" = "" ]; then
    exit
fi

#get upstream_port
upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)

#get product_name
product_name=$(ami_tool mfg_info -d $upstream_port | grep "Product Name" | awk -F'|' '{print $2}' | xargs)

#add echo
echo ""

#change directory
echo "${bold}Changing directory:${normal}"
echo ""
echo "cd $AVED_PATH/$AVED_TAG"
echo ""
cd $AVED_PATH/$AVED_TAG

#similar to program image
current_uuid=$(ami_tool overview | grep "^$upstream_port" | tr -d '|' | sed "s/$product_name//g" | awk '{print $2}')
if [ "$current_uuid" = "$AVED_UUID" ]; then
    sleep 2
    echo "OK. Partition selected ($PARTITION_INDEX) - already programmed."
    echo "***********************************************"
    #echo ""
else
    #program from partiton
    echo "${bold}Booting device from partition:${normal}"
    echo ""
    echo "sudo $AVED_TOOLS_PATH/ami_tool device_boot -d $upstream_port -p $PARTITION_INDEX"
    echo ""
    sudo $AVED_TOOLS_PATH/ami_tool device_boot -d $upstream_port -p $PARTITION_INDEX
    echo ""
    current_uuid=$($AVED_TOOLS_PATH/ami_tool overview | grep "^$upstream_port" | tr -d '|' | sed "s/$product_name//g" | awk '{print $2}')
    if [ ! "$current_uuid" = "$AVED_UUID" ]; then
        #exactly the same as if AVED_UUID does not exist
        echo "Flash image update is required..."
        echo ""
        echo "${bold}Programming partition and booting device:${normal}"
        echo ""
        echo "sudo $AVED_TOOLS_PATH/ami_tool cfgmem_program -d $upstream_port -t $PARTITION_TYPE -i ./$AVED_VALIDATE_DESIGN -p $PARTITION_INDEX -y"
        echo ""
        sudo $AVED_TOOLS_PATH/ami_tool cfgmem_program -d $upstream_port -t $PARTITION_TYPE -i ./$AVED_VALIDATE_DESIGN -p $PARTITION_INDEX -y
        echo ""
    fi
fi

#ami_tool validation
$AVED_TOOLS_PATH/ami_tool overview
$AVED_TOOLS_PATH/ami_tool mfg_info -d $upstream_port
$AVED_TOOLS_PATH/ami_tool sensors -d $upstream_port

#xbtest validation
sudo $AVED_TOOLS_PATH/xbtest -d $upstream_port -c verify
sudo $AVED_TOOLS_PATH/xbtest -d $upstream_port -c memory

echo ""

#author: https://github.com/jmoya82
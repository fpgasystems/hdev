#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil program revert --device $device_index --version $vivado_version --remote $deploy_option
#example: /opt/sgrt/cli/sgutil program revert --device             1 --version          2022.2 --remote              0

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
is_virtualized=$($CLI_PATH/common/is_virtualized $CLI_PATH $hostname)
if [ "$is_virtualized" = "1" ] || ( [ "$is_acap" = "0" ] && [ "$is_asoc" = "0" ] && [ "$is_fpga" = "0" ] ); then
    exit
fi

#inputs
device_index=$2
vivado_version=$4
deploy_option=$6
servers_family_list=$7

#all inputs must be provided
if [ "$device_index" = "" ] || [ "$vivado_version" = "" ] || [ "$deploy_option" = "" ]; then
    exit
fi

#constants
AVED_PATH=$($CLI_PATH/common/get_constant $CLI_PATH AVED_PATH)
AVED_TAG=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TAG)
AVED_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TOOLS_PATH)
AVED_UUID=$($CLI_PATH/common/get_constant $CLI_PATH AVED_UUID)
AVED_VALIDATE_DESIGN="design.pdi"
PARTITION_INDEX="0"
PARTITION_TYPE="primary"
SERVERADDR="localhost"
XILINX_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_TOOLS_PATH)

#derived
VIVADO_PATH="$XILINX_TOOLS_PATH/Vivado"

#get device_type
device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)

#revert
if [ "$device_type" = "asoc" ]; then
    #get AVED example design name (amd_v80_gen5x8_23.2_exdes_2)
    aved_name=$(echo "$AVED_TAG" | sed 's/_[^_]*$//')

    #get upstream_port
    upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)

    #get product_name
    product_name=$(ami_tool mfg_info -d $upstream_port | grep "Product Name" | awk -F'|' '{print $2}' | xargs)

    #change directory
    echo "${bold}Changing directory:${normal}"
    echo ""
    echo "cd $AVED_PATH/$AVED_TAG"
    echo ""
    cd $AVED_PATH/$AVED_TAG

    #similar to program image (and validate)
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
elif [ "$device_type" = "acap" ] || [ "$device_type" = "fpga" ]; then
    #check on workflow
    workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index)
    if [[ $workflow = "vitis" ]]; then
        exit
    fi

    #get upstream_port
    upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)

    #get device and serial name
    serial_number=$($CLI_PATH/get/serial -d $device_index | awk -F': ' '{print $2}' | grep -v '^$')
    device_name=$($CLI_PATH/get/name -d $device_index | awk -F': ' '{print $2}' | grep -v '^$')

    #echo ""
    echo "${bold}Programming XRT shell:${normal}"

    $VIVADO_PATH/$vivado_version/bin/vivado -nolog -nojournal -mode batch -source $CLI_PATH/program/flash_xrt_bitstream.tcl -tclargs $SERVERADDR $serial_number $device_name

    #hotplug
    root_port=$($CLI_PATH/get/get_fpga_device_param $device_index root_port)
    LinkCtl=$($CLI_PATH/get/get_fpga_device_param $device_index LinkCtl)
    sudo $CLI_PATH/program/pci_hot_plug 1 $upstream_port $root_port $LinkCtl
fi

#reverting remote servers (if applies)
reverting_string="$CLI_PATH/program/revert --device $device_index --version $vivado_version --remote 0"
$CLI_PATH/program/remote "$CLI_PATH" "$USER" "$deploy_option" "$reverting_string" "$servers_family_list"

#author: https://github.com/jmoya82
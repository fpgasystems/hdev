#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil program bitstream --path      $bitstream_path --device $device_index --version $vivado_version --remote $deploy_option 
#example: /opt/sgrt/cli/sgutil program bitstream --path path_to_my_shell.bit --device             1 --version          2022.1 --remote              0

#arly exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
vivado_enabled=$([ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; } && echo 1 || echo 0)
if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "0" ]; then
    exit
fi

#inputs
bitstream_path=$2
device_index=$4
vivado_version=$6
deploy_option=$8
servers_family_list=$9

#all inputs must be provided
if [ "$bitstream_path" = "" ] || [ "$device_index" = "" ] || [ "$vivado_version" = "" ] || [ "$deploy_option" = "" ]; then
    exit
fi

#check on remote aboslute path
if [ "$deploy_option" = "1" ] && [[ "$bitstream_path" == "./"* ]]; then
    exit
fi

#constants
SERVERADDR="localhost"
XILINX_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_TOOLS_PATH)

#derived
VIVADO_PATH="$XILINX_TOOLS_PATH/Vivado"

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

echo "${bold}sgutil program bitstream${normal}"
echo ""

#get virtualized
virtualized=$($CLI_PATH/common/is_virtualized $CLI_PATH $hostname)

#get serial number
serial_number=$($CLI_PATH/get/get_fpga_device_param $device_index serial_number)

#get device name
device_name=$($CLI_PATH/get/get_fpga_device_param $device_index device_name)

echo "${bold}Vivado programming:${normal}"
$VIVADO_PATH/$vivado_version/bin/vivado -nolog -nojournal -mode batch -source $CLI_PATH/program/flash_bitstream.tcl -tclargs $SERVERADDR $serial_number $device_name $bitstream_path

#check for virtualized and apply pci_hot_plug (is always needed as we reverted first)
if [ "$virtualized" = "1" ] && [[ $(lspci | grep Xilinx | wc -l) = 2 ]]; then
    #echo ""
    #echo "${bold}The server needs to warm boot to operate in Vivado workflow. For this purpose:${normal}"
    #echo ""
    #echo "    Use the ${bold}go to baremetal${normal} button on the booking system, or"
    #echo "    Contact ${bold}$email${normal} for support."
    #echo ""
    #Using the terms guest reboot and host reboot is also common, where guest refers to the VM and host refers to the hypervisor.
    echo ""
    echo "${bold}The hypervisor needs a host reboot to operate in Vivado workflow.${normal}"
    echo ""
elif [ "$virtualized" = "0" ]; then 
    #get device params
    upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
    root_port=$($CLI_PATH/get/get_fpga_device_param $device_index root_port)
    LinkCtl=$($CLI_PATH/get/get_fpga_device_param $device_index LinkCtl)
    #hot plug boot
    sudo $CLI_PATH/program/pci_hot_plug 1 $upstream_port $root_port $LinkCtl
fi

#programming remote servers (if applies)
programming_string="$CLI_PATH/program/bitstream --path $bitstream_path --device $device_index --version $vivado_version --remote 0"
$CLI_PATH/program/remote "$CLI_PATH" "$USER" "$deploy_option" "$programming_string" "$servers_family_list"

#author: https://github.com/jmoya82
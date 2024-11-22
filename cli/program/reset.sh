#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
CLI_NAME="sgutil"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil program reset --device $device_index
#example: /opt/sgrt/cli/sgutil program reset --device             1

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
if { [[ "$is_acap" = "0" && "$is_fpga" = "0" ]]; } || [[ "$is_asoc" = "1" ]]; then
    exit
fi

#inputs
device_index=$2

#all inputs must be provided
if [ "$device_index" = "" ]; then
    exit
fi

#constants
XRT_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XRT_PATH)

#get BDF (i.e., Bus:Device.Function) 
upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
bdf="${upstream_port%?}1"

#reset device (we delete any xclbin) assuming xx:xx.1 (bdf) function is present after revert
$XRT_PATH/bin/xbutil reset --device $bdf --force

echo ""
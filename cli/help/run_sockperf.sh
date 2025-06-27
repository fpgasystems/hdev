#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2

#get server name
#first_dir=$(find "$CLI_PATH/cmdb" -mindepth 1 -maxdepth 1 -type d | head -n 1)
#first_name=$(basename "$first_dir")
#server_name=${first_name%%.*}

#similar to validate opennic
#target_host_ip=$($CLI_PATH/get/get_nic_device_param 1 IP $CLI_PATH/cmdb/$full_name/devices_network)
#first_ip="${target_host_ip%%/*}"

SOCKPERF_MIN=$($CLI_PATH/common/get_constant $CLI_PATH SOCKPERF_MIN)

#get maximum message size
safe_msg_size=$(( $(cat /proc/sys/net/core/wmem_max) / 4 ))

echo ""
echo "${bold}$CLI_NAME run sockperf [flags] [--help]${normal}"
echo ""
echo "Network performance assessment with sockperf."
echo ""
echo "FLAGS:"
echo "   ${bold}-i, --interface${normal} - Local interface (according to ${bold}$CLI_NAME get interfaces${normal})."
echo "   ${bold}    --server${normal}    - Remote sockperf server IP."
echo "   ${bold}    --size${normal}      - Message size in bytes (between ${bold}$SOCKPERF_MIN${normal} and ${bold}$safe_msg_size${normal})."
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""
#exit 1
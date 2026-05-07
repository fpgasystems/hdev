#!/bin/bash

CLI_NAME="hdev"
CLI_PATH="/opt/$CLI_NAME/cli"
bold=$(tput bold)
normal=$(tput sgr0)

source /opt/$CLI_NAME/login/login_functions.sh

username="${SUDO_USER:-$(id -un)}"

#skip welcome message for root
if [ "$username" = "root" ]; then
  exit 1
fi

#get hostname
hostname="$(hostname -s)"

kill_other_user_processes

echo ""
echo "${bold}Welcome, $username!${normal}"
echo ""

revert_devices

print_os_info
print_FPGA_tools_info
is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
[[ "$is_gpu" == "1" ]] && print_GPU_tools_info
print_module_help

echo ""
echo "${bold}Have a nice $(date +%A)!${normal}"
echo ""

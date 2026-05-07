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

echo ""
echo "${bold}Welcome, $username!${normal}"
echo ""

print_os_info
echo ""
print_FPGA_tools_info

echo ""
echo "${bold}Have a nice $(date +%A)!${normal}"
echo ""

#!/bin/bash

CLI_NAME="hdev"
CLI_PATH="/opt/$CLI_NAME/cli"
bold=$(tput bold)
normal=$(tput sgr0)

#constants
MTU_DEFAULT=$($CLI_PATH/common/get_constant $CLI_PATH MTU_DEFAULT)

#get username
if [[ -n "$SUDO_UID" ]]; then
  # when called using sudo
  username=$(getent passwd ${SUDO_UID})
  username=${username%%:*}
else
  # when called without using sudo
  username=$(whoami)
fi

# This script can't/shouldn't be executed by root
if [ "$username" = "root" ]; then
    exit 1
fi

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

# TODO: create an hdev command of this
print_os_info() {
    local distributor release description codename linux_kernel uptime_info

    distributor=$(lsb_release -i | awk -F':' '{print $2}' | xargs)
    release=$(lsb_release -r | awk -F':' '{print $2}' | xargs)
    description=$(lsb_release -d | awk -F'\t' '{print $2}' | sed 's/^[^0-9]*//')
    codename=$(lsb_release -c | awk -F':' '{print $2}' | xargs)
    linux_kernel=$(uname -r)
    uptime_info=$(uptime -p)

    echo "The server ${bold}$hostname${normal} is ready to work with ${bold}$distributor $release${normal}:"
    echo ""
    echo "    Description : ${bold}$description${normal}"
    echo "    Codename    : ${bold}$codename${normal}"
    echo "    Linux kernel: ${bold}$linux_kernel${normal}"
    echo "    Uptime      : ${bold}$uptime_info${normal}"
    echo ""
}

#TODO: make a hdev command for setting the MTU
reset_mtu_on_data_nic() {

  #TODO: hdev should keep track of the interface name and have a simple api to get this
  local data_network_iface=$(nmcli dev | grep mellanox-0 | awk '{print $1}')

  if command -v ip >/dev/null 2>&1; then
    # uses the modern ip command
    /usr/sbin/ip link set dev "$data_network_iface" mtu "$MTU_DEFAULT" up
  else
    # fallback for when ip is not yet supported
    /usr/sbin/ifconfig $data_network_iface mtu $MTU_DEFAULT up
  fi
}

# ---------------------

#print welcome message (1/2)
echo ""
echo "${bold}Welcome, $username!${normal}"
echo ""

# display OS info
print_os_info

#TODO: detect if XRT is installed and show based on that. To support difference between AVED and XRT flows
echo "Xilinx Tools (XRT, Vivado, Vitis, Vitis_HLS) need to be enabled for proper operation:"
echo ""
echo "    XRT             : ${bold}source /opt/hdev/cli/enable/xrt${normal} "
echo "    Vivado          : ${bold}source /opt/hdev/cli/enable/vivado${normal} "
echo "    Vitis, Vitis_HLS: ${bold}source /opt/hdev/cli/enable/vitis${normal} "
echo ""

#set MTU on data network interface
reset_mtu_on_data_nic

#print welcome message (2/2)
weekday=$(date +%A)
echo "${bold}Have a nice $weekday!${normal}"
echo ""

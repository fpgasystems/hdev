#!/bin/bash

CLI_NAME="hdev"
CLI_PATH="/opt/$CLI_NAME/cli"
bold=$(tput bold)
normal=$(tput sgr0)

#constants
EMAIL=$($CLI_PATH/common/get_constant $CLI_PATH EMAIL)
MTU_DEFAULT=$($CLI_PATH/common/get_constant $CLI_PATH MTU_DEFAULT)
XILINX_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_TOOLS_PATH)
XRT_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XRT_PATH)

#get username
username=$(getent passwd ${SUDO_UID})
username=${username%%:*}

#check on root
if [ "$username" = "root" ]; then
    exit 1
fi

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#derived
VIVADO_PATH="$XILINX_TOOLS_PATH/Vivado"
VITIS_PATH="$XILINX_TOOLS_PATH/Vitis"
VITIS_HLS_PATH="$XILINX_TOOLS_PATH/Vitis_HLS"

#print welcome message (1/2)
echo ""
echo "${bold}Welcome, $username!${normal}"
echo ""

#print operating system information
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

echo "Xilinx Tools (XRT, Vivado, Vitis, Vitis_HLS) need to be enabled for proper operation:"
echo ""
echo "    XRT             : ${bold}source /opt/hdev/cli/enable/xrt${normal} "
echo "    Vivado          : ${bold}source /opt/hdev/cli/enable/vivado${normal} "
echo "    Vitis, Vitis_HLS: ${bold}source /opt/hdev/cli/enable/vitis${normal} "
echo ""

#get installed versions
cd $VIVADO_PATH
versions=( *"/" )

#enable Xilinx tools version
version="none"
if [[ -n "$version/" ]] && [[ $version != "none" ]]; then
    #remove the last character, i.e. "/"
    version=${version::-1} 

    #copy the desired XRT version to user’s local and preserve /opt/xilinx/xrt structure (Xilinx workaroud)
	mkdir -p /local/home/$username/xrt_${version}$XRT_PATH
	cp -r $XRT_PATH"_"${version}/* /local/home/$username/xrt_${version}$XRT_PATH

    echo ""

	#source xrt
    source /local/home/$username/xrt_${version}$XRT_PATH/setup.sh

    #source tools
	source $VIVADO_PATH/${version}/settings64.sh
	source $VITIS_PATH/${version}/settings64.sh
	source $VITIS_HLS_PATH/${version}/settings64.sh

	#get XRT branch
	branch=$($XILINX_XRT/bin/xbutil --version | grep -i -w 'Branch' | tr -d '[:space:]')

	#print message
	echo ""
	if [[ -d $VITIS_PATH/${branch:7:6} ]]; then
		#Vitis is installed
		echo "The server is ready to work with Xilinx ${bold}${branch:7:6}${normal} release branch:"
		echo ""
		echo "    Xilinx Board Utility (xbutil)          : ${bold}$XILINX_XRT/bin${normal}"
		echo "    Xilinx Tools (Vivado, Vitis, Vitis_HLS): ${bold}/tools/Xilinx${normal}"
	elif [[ -d $VIVADO_PATH/${branch:7:6} ]]; then
		#Vitis is not installed
		echo "The server is ready to work with Xilinx ${bold}${branch:7:6}${normal} release branch:"
		echo ""
		echo "    Xilinx Board Utility (xbutil)       : ${bold}$XILINX_XRT/bin${normal}"
		echo "    Xilinx Tools (Vivado, Vitis_HLS)    : ${bold}/tools/Xilinx${normal}"
	else
		echo "The server needs special care to operate with XRT normally (Xilinx tools are not properly installed)."
		echo ""
		echo "${bold}An email has been sent to the person in charge;${normal} we will let you know when XRT is ready to use again."
		echo "Subject: $hostname requires special attention ($username): Xilinx tools are not properly installed" | sendmail $EMAIL
	fi
fi

#change to home directory
cd

#set MTU on Mellanox interface
while read -r line || [[ -n "$line" ]]; do
  # Extract all MAC addresses from the line
  # Match typical MAC patterns: xx:xx:xx:xx:xx:xx
  macs=$(echo "$line" | grep -oE '([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}')

  for mac in $macs; do
    # Find interface for this MAC
    iface=$(for i in /sys/class/net/*; do
      if [[ "$(cat "$i/address")" == "$mac" ]]; then
        basename "$i"
        break
      fi
    done)

    if [[ -n "$iface" ]]; then
      echo "Setting MTU $MTU_DEFAULT on interface $iface (MAC $mac)"
      sudo ip link set dev "$iface" mtu $MTU_DEFAULT up
    else
      echo "No interface found for MAC $mac"
    fi
  done
done < "/opt/hdev/cli/devices_network"
echo ""

#print welcome message (2/2)
weekday=$(date +%A)
#echo ""
echo "${bold}Have a nice $weekday!${normal}"
echo ""

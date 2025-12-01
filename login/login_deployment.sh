#!/bin/bash

CLI_NAME="hdev"
CLI_PATH="/opt/$CLI_NAME/cli"
bold=$(tput bold)
normal=$(tput sgr0)

#constants
ACAP_DEVICE_INDEX=3
AVED_PATH=$($CLI_PATH/common/get_constant $CLI_PATH AVED_PATH)
AVED_TAG=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TAG)
AVED_VALIDATE_DESIGN=$($CLI_PATH/common/get_constant $CLI_PATH AVED_VALIDATE_DESIGN)
EMAIL=$($CLI_PATH/common/get_constant $CLI_PATH EMAIL)
FPGA_DEVICE_INDEX=1
MTU_DEFAULT=$($CLI_PATH/common/get_constant $CLI_PATH MTU_DEFAULT)
MY_DRIVERS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_DRIVERS_PATH)
ROCM_PATH=$($CLI_PATH/common/get_constant $CLI_PATH ROCM_PATH)
SERVERADDR="localhost"
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
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"
VIVADO_PATH="$XILINX_TOOLS_PATH/Vivado"
VITIS_PATH="$XILINX_TOOLS_PATH/Vitis"

#check on DEVICES_LIST
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"

#get number of fpga and acap devices present
MAX_DEVICES=$(grep -E "fpga|acap|asoc" $DEVICES_LIST | wc -l)

#check on multiple devices
multiple_devices=$($CLI_PATH/common/get_multiple_devices $MAX_DEVICES)

#check on server_type
acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
is_numa=$($CLI_PATH/common/is_numa $CLI_PATH)

#get list of devices to revert
device_types=()
serial_numbers=()
device_names=()
upstream_ports=()
root_ports=()
LinkCtls=()
onicxdp_ifaces=()
devices_to_revert=0
for ((i=1; i<=$MAX_DEVICES; i++)); do
	upstream_port=$($CLI_PATH/get/get_fpga_device_param $i upstream_port)
	bdf="${upstream_port%??}" #i.e., we transform 81:00.0 into 81:00
	#add if the device is already on Vivado mode (only one BDF)
	if [[ $(lspci | grep Xilinx | grep $bdf | wc -l) = 1 ]]; then
		#get device_type
		device_type=$($CLI_PATH/get/get_fpga_device_param $i device_type)
		device_types+=("$device_type")
		#serial_numbers
		serial_number=$($CLI_PATH/get/serial -d $i | awk -F': ' '{print $2}' | grep -v '^$')
		serial_numbers+=("$serial_number")
		#device_names
		device_name=$($CLI_PATH/get/name -d $i | awk -F': ' '{print $2}' | grep -v '^$')
		device_names+=("$device_name")
		#upstream_ports
		upstream_port=$($CLI_PATH/get/get_fpga_device_param $i upstream_port)
		upstream_ports+=("$upstream_port")
		#root_ports
		root_port=$($CLI_PATH/get/get_fpga_device_param $i root_port)
		root_ports+=("$root_port")
		#LinkCtl
		LinkCtl=$($CLI_PATH/get/get_fpga_device_param $i LinkCtl)
		LinkCtls+=("$LinkCtl")
		#onicxdp
		id=$($CLI_PATH/get/get_fpga_device_param $i id)
		if [ -n "$id" ]; then
			workflow=$($CLI_PATH/get/workflow -d $id)
			workflow=$(echo "$workflow" $id | cut -d' ' -f2 | sed '/^\s*$/d')
			if [ $workflow = "onicxdp" ]; then
				#get interface name
				ip=$($CLI_PATH/get/get_fpga_device_param $id IP)
				ip0=$(echo "$ip" | cut -d'/' -f1)
				onicxdp_iface=$(ifconfig | grep -B1 "$ip0" | awk '/^[a-zA-Z0-9]/ {print $1}' | sed 's/://')
				onicxdp_ifaces+=("$onicxdp_iface")
			fi
		fi
		#increase counter
		((devices_to_revert++))
	fi
done

#print welcome message (1/2)
echo ""
echo "${bold}Welcome, $username!${normal}"
echo ""

#get XRT branch
branch=$($XRT_PATH/bin/xbutil --version 2>/dev/null | grep -i -w 'Branch' | tr -d '[:space:]')
vivado_version=$(ls /tools/Xilinx/Vivado/ | grep -Eo '[0-9]+\.[0-9]+' | head -n 1)

#send email (Xilinx)
xilinx_installed="1"
if (( ( "$fpga" == "1" ) || ( "$acap" == "1" ) || ( "$asoc" == "1" ) )) && [[ ! -d "$VIVADO_PATH/$vivado_version" ]]; then
  	#echo ""
	echo "The server needs special care to operate with XRT normally (Xilinx tools are not properly installed)."
	echo ""
	echo "${bold}An email has been sent to the person in charge;${normal} we will let you know when XRT is ready to use again."
	echo "Subject: $hostname requires special attention ($username): Xilinx tools are not properly installed" | sendmail $EMAIL
	#update
	xilinx_installed="0"
fi

#send email (AMD)
amd_installed="1"
if [ "$gpu" = "1" ] && [[ ! -d "$ROCM_PATH/bin/" ]]; then
  	echo "The server needs special care to operate with ROCm normally (AMD tools are not properly installed)."
	echo ""
	echo "${bold}An email has been sent to the person in charge;${normal} we will let you know when ROCm is ready to use again."
	echo "Subject: $hostname requires special attention ($username): AMD tools are not properly installed" | sendmail $EMAIL
	#update
	amd_installed="0"
fi

#revert devices
revert=0
if [ $devices_to_revert -ge 1 ]; then
	#dedicated environment (revert)
	echo "One or more reconfigurable devices need to be reverted to default fabric. ${bold}Do you want to continue (y/n)?${normal}"
	while true; do
		read -p "" yn
		case $yn in
			"y") 
				#similar to $CLI_PATH/program/revert
				revert="1"

				#xdp_detach
				if [[ ${#onicxdp_ifaces[@]} -gt 0 ]]; then
					echo ""
					for ((i=0; i<${#onicxdp_ifaces[@]}; i++)); do
						if [[ -n ${onicxdp_ifaces[i]} ]]; then
							onicxdp_iface=${onicxdp_ifaces[i]}
							sudo $CLI_PATH/program/xdp_detach $onicxdp_iface >/dev/null 2>&1
							countdown=$((RANDOM % 6 + 10))
							for j in $(seq $countdown -1 0); do
								echo -n "."
								sleep 0.5
							done
						fi
					done
					echo ""
				fi
				
				#program XRT/AVED shell
				for ((i=0; i<${#serial_numbers[@]}; i++)); do
					if [[ -n ${serial_numbers[i]} ]]; then
						device_type=${device_types[i]}
						serial_number=${serial_numbers[i]}
						device_name=${device_names[i]}
						if [ "$device_type" = "asoc" ]; then
							bitstream_path=$AVED_PATH/$AVED_TAG/$AVED_VALIDATE_DESIGN
							$VIVADO_PATH/$vivado_version/bin/vivado -nolog -nojournal -mode batch -source $CLI_PATH/program/flash_bitstream.tcl -tclargs $SERVERADDR $serial_number $device_name $bitstream_path
						else
							$VIVADO_PATH/$vivado_version/bin/vivado -nolog -nojournal -mode batch -source $CLI_PATH/program/flash_xrt_bitstream.tcl -tclargs $SERVERADDR $serial_number $device_name
						fi
					fi
				done
				#hotplug
				sudo $CLI_PATH/program/pci_hot_plug $i "${upstream_ports[@]}" "${root_ports[@]}" "${LinkCtls[@]}"
				
				#get loaded drivers
				if [ -d "$MY_DRIVERS_PATH" ]; then
					# Initialize vectors
					drivers=()
					loaded_drivers=()

					# Iterate over each file in the directory
					for file in "$MY_DRIVERS_PATH"/*; do
						# Extract file name without path
						filename=$(basename "$file")
						# Add file name to the array
						drivers+=("$filename")
					done

					# Filter drivers array
					for driver in "${drivers[@]}"; do
						if lsmod | grep -q "${driver%.*}"; then
							# Driver is currently loaded, add it to the loaded_drivers array
							loaded_drivers+=("$driver")
						fi
					done
				fi

				#remove loaded drivers
				if [ "${#loaded_drivers[@]}" -gt 0 ]; then
					#echo ""
					echo "${bold}Removing drivers:${normal}"
					echo ""

					#change directory 
					cd $MY_DRIVERS_PATH						

					for driver in "${loaded_drivers[@]}"; do
						echo "sudo rmmod ${driver%.*}"
						sudo rmmod "${driver%.*}" 2>/dev/null # with 2>/dev/null we avoid printing a message if the module does not exist
					done
					echo ""

				fi

				# Change to the base directory
				cd ${MY_DRIVERS_PATH%%/*/*}

				#delete folder
				rm -rf $MY_DRIVERS_PATH

				break
				;;
			"n") 
				revert="0"
				echo ""
				break
				;;
		esac
	done
fi

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

#print Vitis/XRT and setup devices
if [ "$xilinx_installed" = "1" ]; then
	#print tools info
	if [[ -d $VITIS_PATH/$vivado_version ]] && [ "$asoc" = "0" ]; then
		#Vitis is installed
		#echo ""
		echo "The server is ready to work with Xilinx ${bold}$vivado_version${normal} release branch:"
		echo ""
		if [ ! "$branch" = "" ]; then
		echo "    Xilinx Board Utility (xbutil)          : ${bold}$XRT_PATH/bin${normal}"
		fi
		echo "    Xilinx Tools (Vivado, Vitis, Vitis_HLS): ${bold}/tools/Xilinx${normal}"
	elif [[ -d $VIVADO_PATH/$vivado_version ]] && [ "$asoc" = "0" ]; then
		#Vitis is not installed
		#echo ""
		echo "The server is ready to work with Xilinx ${bold}$vivado_version${normal} release branch:"
		echo ""
		if [ ! "$branch" = "" ]; then
		echo "    Xilinx Board Utility (xbutil)          : ${bold}$XRT_PATH/bin${normal}"
		fi
		echo "    Xilinx Tools (Vivado, Vitis_HLS)       : ${bold}/tools/Xilinx${normal}"
	fi
	#print FPGA info
	if [ "$fpga" = "1" ]; then
		platform=$($CLI_PATH/get/platform -d $FPGA_DEVICE_INDEX | sed -n 's/^[^:]*: //p')
		echo "    Flashable partitions running on FPGA   : ${bold}$platform${normal}"
	fi
	#print ACAP info
	if [ "$acap" = "1" ]; then
		if [ "$multiple_devices" = "0" ]; then
			ACAP_DEVICE_INDEX=1
		fi
		platform=$($CLI_PATH/get/platform -d $ACAP_DEVICE_INDEX | sed -n 's/^[^:]*: //p')
		echo "    Flashable partitions running on ACAPs  : ${bold}$platform${normal}"
	fi
	#print ASOC info
	if [ "$asoc" = "1" ]; then
		xbtest_path=$(which xbtest)
		ami_tool_path=$(which ami_tool)
		echo "The server is ready to work with Vivado Design Suite ${bold}$vivado_version${normal} version:"
		echo ""
		echo "    Alveo Versal Example Design (AVED): ${bold}$AVED_TAG${normal}"
		if [ ! "$ami_tool_path" = "" ]; then
		echo "    AVED Management Interface         : ${bold}$ami_tool_path${normal}"
		fi
		#if [[ -e /dev/pcie_hotplug_* ]]; then
		if compgen -G "/dev/pcie_hotplug_*" > /dev/null; then
		echo "    AVED pcie_hotplug                 : ${bold}/dev/pcie_hotplug${normal}"
		fi
		if [ ! "$xbtest_path" = "" ]; then
		echo "    Xilinx Board Validation Test      : ${bold}$xbtest_path${normal}"
		fi
		echo "    Xilinx Tools (Vivado, Vitis_HLS)  : ${bold}/tools/Xilinx${normal}"
	fi
	echo ""
	#enable host memory (to be verified: xbutil examine -r pcie-info -d)
	$XRT_PATH/bin/xbutil configure --host-mem -s 1G enable -d >&/dev/null
fi

#print ROCm/HIP information and setup devices
if [ "$amd_installed" = "1" ] && [[ -d "$ROCM_PATH/bin/" ]]; then
	#print tools info
	hip_version=$(dpkg -l | grep rocm-core | awk '{print $3}' | cut -d '.' -f 1-3)
	rocm_runtime_version=$(rocminfo | awk -F ': *' '/Runtime Version/{print $2}')
	rocm_smi_version=$($ROCM_PATH/bin/rocm-smi -h 2>&1 | grep "AMD ROCm System Management Interface" | awk -F 'version: ' '{print $2}' | awk -F ' |' '{print $1}')
	rocm_smi_kernel_version=$(modinfo amdgpu | grep version | awk '/^version:/ {print $2}')
	#echo ""
	echo "The server is ready to work with ${bold}HIP $hip_version (ROCm Version $rocm_runtime_version)${normal} release branch:" #$rocm_smi_version
	echo ""
	#print GPU info
	echo "    ROCm System Management Interface (rocm-smi): ${bold}$ROCM_PATH/bin${normal}"
	echo "    ROCm SMI Version                           : ${bold}$rocm_smi_version${normal}"
	echo "    ROCm SMI Kernel Version                    : ${bold}$rocm_smi_kernel_version${normal}"
	echo ""

	# Now managed by a rule in /etc/pam.d/sshd
	##enable ROCm and HIP (add to render and video groups)
	#if [[ "$(groups $username | grep -c render)" -eq 0 ]]; then
	#	sudo usermod -aG render $username
	#fi
	##add to video group
	#if [[ "$(groups $username | grep -c video)" -eq 0 ]]; then
	#	sudo usermod -aG video $username
	#fi
fi

#kill processes from other users
for i in $(ps aux | awk '{ print $1 }' | sed '1 d' | sort | uniq); 
do 
	grep ^$i: /etc/passwd &>/dev/null || ( getent passwd $i &>/dev/null && [ "$i" != "$SUDO_USER" ] && killall -u $i ); 
done

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

#create devices_acap_fpga_coyote
sudo $CLI_PATH/common/get_devices_acap_fpga_coyote

#ensure numa balancing (similar to hdev ser balancing --value 1)
if [ "$is_numa" = "1" ]; then
	new_value="1"
	sudo sysctl kernel.numa_balancing=$new_value >/dev/null 2>&1
fi

#print welcome message (2/2)
weekday=$(date +%A)
#echo ""
echo "${bold}Have a nice $weekday!${normal}"
echo ""

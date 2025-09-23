#!/bin/bash

CLI_NAME="hdev"
CLI_PATH="/opt/$CLI_NAME/cli"
bold=$(tput bold)
normal=$(tput sgr0)

#constants
#TODO: clean up these variables
#ACAP_DEVICE_INDEX=3
#FPGA_DEVICE_INDEX=1
#AVED_PATH=$($CLI_PATH/common/get_constant $CLI_PATH AVED_PATH)
#AVED_TAG=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TAG)
#AVED_VALIDATE_DESIGN=$($CLI_PATH/common/get_constant $CLI_PATH AVED_VALIDATE_DESIGN)
#EMAIL=$($CLI_PATH/common/get_constant $CLI_PATH EMAIL)
#SERVERADDR="localhost"
MTU_DEFAULT=$($CLI_PATH/common/get_constant $CLI_PATH MTU_DEFAULT)
MY_DRIVERS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_DRIVERS_PATH)
ROCM_PATH=$($CLI_PATH/common/get_constant $CLI_PATH ROCM_PATH)
XILINX_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_TOOLS_PATH)
XRT_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XRT_PATH)

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

    local distributor=$(lsb_release -i | awk -F':' '{print $2}' | xargs)
    local release=$(lsb_release -r | awk -F':' '{print $2}' | xargs)
    local description=$(lsb_release -d | awk -F'\t' '{print $2}' | sed 's/^[^0-9]*//')
    local codename=$(lsb_release -c | awk -F':' '{print $2}' | xargs)
    local linux_kernel=$(uname -r)
    local uptime_info=$(uptime -p)

    echo "The server ${bold}$hostname${normal} is ready to work with ${bold}$distributor $release${normal}:"
    echo ""
    echo "    Description : ${bold}$description${normal}"
    echo "    Codename    : ${bold}$codename${normal}"
    echo "    Linux kernel: ${bold}$linux_kernel${normal}"
    echo "    Uptime      : ${bold}$uptime_info${normal}"
    echo ""
}

print_rocm_info() {
  local rocm_version=$(dpkg -l | grep rocm-core | awk '{print $3}' | cut -d '.' -f 1-3)
  local rocm_smi_version=$($ROCM_PATH/bin/rocm-smi -h 2>&1 | grep "AMD ROCm System Management Interface" | awk -F 'version: ' '{print $2}' | awk -F ' |' '{print $1}')
  local rocm_smi_kernel_version=$(modinfo amdgpu | grep version | awk '/^version:/ {print $2}')


  #print tools info
  echo "The server is ready to work with ${bold}ROCm $rocm_version${normal}:"
  echo ""
  #print GPU info
  echo "    ROCm System Management Interface (rocm-smi)       : ${bold}$(which rocm-smi)${normal}"
  echo "    HIP compiler (hipcc)                              : ${bold}$(which hipcc)${normal}"
  echo "    CUDA to HIP converter (hipify-clang, hipify-perl) : ${bold}$(which hipify-clang)${normal}"
  echo ""
}

remove_my_drivers() {
  #get loaded drivers
  if [ -d "$MY_DRIVERS_PATH" ]; then
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

    for driver in "${loaded_drivers[@]}"; do
      echo "sudo rmmod ${driver%.*}"
      sudo rmmod "${driver%.*}" 2>/dev/null
    done
    echo ""

  fi

  #delete MY_DRIVERS folder
  rm -rf $MY_DRIVERS_PATH
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

#derived
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"
VIVADO_PATH="$XILINX_TOOLS_PATH/Vivado"
VITIS_PATH="$XILINX_TOOLS_PATH/Vitis"

#check if DEVICES_LIST is correct/exists
#TODO: does this need a 'source' or can it just be ran and check the return?
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"

#get number of fpga and acap devices present
NUM_DEVICES=$(grep -E "fpga|acap|asoc" $DEVICES_LIST | wc -l)

#check on multiple devices
#TODO: remove, because it is redundant
#multiple_devices=$($CLI_PATH/common/get_multiple_devices $NUM_DEVICES)

#check on server_type
has_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
has_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
has_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
has_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)

# boolean setting wheter there is one numa node (0) or multiple (1)
has_multiple_numa_nodes=$($CLI_PATH/common/is_numa $CLI_PATH)

#get list of devices to revert
devices_to_revert=()
for ((device_index=1; device_index<=$NUM_DEVICES; device_index++)); do
  device_workflow=$($CLI_PATH/get/workflow -d $device_index | awk '{print $2}' | tr -d '\n')

  if [[ "$device_workflow" != "vitis" ]]; then
    devices_to_revert+=("$device_index")
  fi
done

# get Vivado version
#TODO: make more robust for 2024.2 vs 2025.1 folder structure + multiple versions
vivado_version=$(ls /tools/Xilinx/Vivado/ | grep -Eo '[0-9]+\.[0-9]+' | head -n 1)

#TODO: Remove this and replace with a monitoring solution
#send email when XRT is not properly installed
#xilinx_installed="1"
#if (( ( "$fpga" == "1" ) || ( "$acap" == "1" ) || ( "$asoc" == "1" ) )) && [[ ! -d "$VIVADO_PATH/$vivado_version" ]]; then
#  #echo ""
#  echo "The server needs special care to operate with XRT normally (Xilinx tools are not properly installed)."
#  echo ""
#  echo "${bold}An email has been sent to the person in charge;${normal} we will let you know when XRT is ready to use again."
#  echo "Subject: $hostname requires special attention ($username): Xilinx tools are not properly installed" | sendmail $EMAIL
#  #update
#  xilinx_installed="0"
#fi

#send email when ROCm is not properly installed
#amd_installed="1"
#if [ "$gpu" = "1" ] && [[ ! -d "$ROCM_PATH/bin/" ]]; then
#  echo "The server needs special care to operate with ROCm normally (AMD tools are not properly installed)."
#  echo ""
#  echo "${bold}An email has been sent to the person in charge;${normal} we will let you know when ROCm is ready to use again."
#  echo "Subject: $hostname requires special attention ($username): AMD tools are not properly installed" | sendmail $EMAIL
#  #update
#  amd_installed="0"
#fi

# ---------------------

#print welcome message (1/2)
echo ""
echo "${bold}Welcome, $username!${normal}"
echo ""

#revert devices
if [ ${#devices_to_revert[@]} -gt 0 ]; then

  echo "One or more reconfigurable devices is not using the default shell."
  echo "${bold}Do you want to revert all devices to use the default shell (y/n)?${normal}"
  while true; do
    read -p "" yn
    case $yn in
      "y")
        for device_index in "${devices_to_revert[@]}"
        do
          #TODO: this does not do parallel hotplug, which will cause problems.
          # Adapt the revert command to allow this.
          $CLI_PATH/program/revert --device $device_index --version $vivado_version --remote 0
        done

        remove_my_drivers

        break
        ;;

      "n")
        echo ""
        break
        ;;
    esac
  done
fi

# display OS info
print_os_info

#TODO: Make this prettier and more easy to read
#print Vitis/XRT and setup devices
vitis_installed=$(which vitis | wc -l)
vivado_installed=$(which vivado | wc -l)
xrt_installed=$(which xbutil | wc -l)
aved_installed=$(which ami_tool | wc -l)

#print tools info
echo "The server is ready to work with Xilinx Tools ${bold}$vivado_version${normal}:"
echo ""
if [ "$vivado_installed" -ge 1 ]; then
  echo "    Vivado                                 : ${bold}$(which vivado)${normal}"
fi
if [ "$vitis_installed" -ge 1 ]; then
  echo "    Vitis                                  : ${bold}$(which vitis)${normal}"
fi
if [ "$xrt_installed" -ge 1 ]; then
  echo "    XRT tools (xbutil, xbtop)              : ${bold}$(which xbutil)${normal}"
fi
if [ "$aved_installed" -ge 1 ]; then
  echo "    AVED tools (ami_tool)                  : ${bold}$(which xbutil)${normal}"
fi
echo ""

#TODO: rewrite to display the devices in the server
##print FPGA info
#if [ "$has_fpga" = "1" ]; then
#  platform=$($CLI_PATH/get/platform -d $FPGA_DEVICE_INDEX | sed -n 's/^[^:]*: //p')
#  echo "    Flashable partitions running on FPGA   : ${bold}$platform${normal}"
#fi
#
##print ACAP info
#if [ "$has_acap" = "1" ]; then
#  if [ "$multiple_devices" = "0" ]; then
#    ACAP_DEVICE_INDEX=1
#  fi
#  platform=$($CLI_PATH/get/platform -d $ACAP_DEVICE_INDEX | sed -n 's/^[^:]*: //p')
#  echo "    Flashable partitions running on ACAPs  : ${bold}$platform${normal}"
#fi
#
##print ASOC info
#if [ "$has_asoc" = "1" ]; then
#  xbtest_path=$(which xbtest)
#  ami_tool_path=$(which ami_tool)
#  echo "The server is ready to work with Vivado Design Suite ${bold}$vivado_version${normal} version:"
#  echo ""
#  echo "    Alveo Versal Example Design (AVED): ${bold}$AVED_TAG${normal}"
#  if [ "$aved_installed" -ge 1 ]; then
#    echo "    AVED Management Interface         : ${bold}$ami_tool_path${normal}"
#  fi
#  #if [[ -e /dev/pcie_hotplug_* ]]; then
#  if compgen -G "/dev/pcie_hotplug_*" > /dev/null; then
#    echo "    AVED pcie_hotplug                 : ${bold}/dev/pcie_hotplug${normal}"
#  fi
#  if [ ! "$xbtest_path" = "" ]; then
#    echo "    Xilinx Board Validation Test      : ${bold}$xbtest_path${normal}"
#  fi
#  echo "    Xilinx Tools (Vivado, Vitis_HLS)  : ${bold}/tools/Xilinx${normal}"
#fi
#echo ""

#enable host memory (to be verified: xbutil examine -r pcie-info -d)
if [ "$xrt_installed" -ge 1 ]; then
  $XRT_PATH/bin/xbutil configure --host-mem -s 1G enable -d >&/dev/null
fi

#print ROCm/HIP information
if [[ "$has_gpu" = "1" && -d "$ROCM_PATH/bin/" ]]; then
  print_rocm_info

  #TODO: Remove this and replace in our Ansible config. Document in hdev?
  ##enable ROCm and HIP (add to render and video groups)
  #if [[ "$(groups $username | grep -c render)" -eq 0 ]]; then 
  #  sudo usermod -aG render $username 
  #fi
  ##add to video group
  #if [[ "$(groups $username | grep -c video)" -eq 0 ]]; then 
  #  sudo usermod -aG video $username
  #fi
fi

#kill processes from other users
#TODO: this looks very dangerous, is there a safer way to do this?
for i in $(ps aux | awk '{ print $1 }' | sed '1 d' | sort | uniq); 
do
  grep ^$i: /etc/passwd &>/dev/null || ( getent passwd $i &>/dev/null && [ "$i" != "$username" ] && killall -u $i );
done

#set MTU on data network interface
reset_mtu_on_data_nic

#ensure numa balancing (similar to hdev set balancing --value 1)
if [ "$has_multiple_numa_nodes" = "1" ]; then
  $CLI_PATH/set/balancing --value 1
fi

#print welcome message (2/2)
weekday=$(date +%A)
#echo ""
echo "${bold}Have a nice $weekday!${normal}"
echo ""

#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
CLI_NAME="hdev"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev validate coyote --commit $commit_name --device $device_index --version $vivado_version
#example: /opt/hdev/cli/hdev validate coyote --commit      0e514ab --device             1 --version          2024.2

#early exit
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

check_connectivity() {
    local interface="$1"
    local remote_server="$2"

    # Ping the remote server using the specified interface, sending only 1 packet
    if ping -I "$interface" -c 1 "$remote_server" &> /dev/null; then
        echo "1"
    else
        echo "0"
    fi
}

#inputs
commit_name=$2
device_index=$4
vivado_version=$6

#all inputs must be provided
if [ "$commit_name" = "" ] || [ "$device_index" = "" ] || [ "$vivado_version" = "" ]; then
    exit
fi

#constants
BITSTREAM_NAME=$($CLI_PATH/common/get_constant $CLI_PATH COYOTE_SHELL_NAME)
BITSTREAMS_PATH="$CLI_PATH/bitstreams"
#CMDB_PATH="$CLI_PATH/cmdb"
COLOR_FAILED=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_FAILED)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)
COLOR_PASSED=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_PASSED)
DEPLOY_OPTION="0"
DRIVER_NAME=$($CLI_PATH/common/get_constant $CLI_PATH COYOTE_DRIVER_NAME)
MY_DRIVERS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_DRIVERS_PATH)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
SERVERADDR="localhost"
TEMPLATE_NAME="01_hello_world"
WORKFLOW="coyote"
XILINX_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_TOOLS_PATH)

#derived
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"
VIVADO_PATH="$XILINX_TOOLS_PATH/Vivado"

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#get device_name
device_name=$($CLI_PATH/get/get_fpga_device_param $device_index device_name)

#get platform_name
#platform_name=$($CLI_PATH/get/get_fpga_device_param $device_index platform)

#get FDEV_NAME
FDEV_NAME=$(echo "$device_name" | cut -d'_' -f2)

#set project name
project_name="validate_coyote.$hostname.$commit_name.$FDEV_NAME.$vivado_version"

#define directories (1)
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name"
SHELL_BUILD_DIR="$DIR/open-nic-shell/script"
DRIVER_DIR="$DIR/open-nic-driver"

#remove in the beginning
if [ -d "$DIR" ]; then
    rm -rf "$DIR"
fi

#new
if ! [ -d "$DIR" ]; then
    echo "${bold}$CLI_NAME new $WORKFLOW (commit ID: $commit_name)${normal}"
    echo ""
    $CLI_PATH/new/coyote --commit $commit_name --number "none" --project $project_name --name $device_name --template $TEMPLATE_NAME --push 0
fi

#cleanup
rm -f $DIR/configs/host_config_000

#create default configurations
#device
touch $DIR/configs/device_config
echo "min_pkt_len = 64;" >> "$DIR/configs/device_config"
#echo "max_pkt_len = 1514;" >> "$DIR/configs/device_config"
#echo "use_phys_func = 1;" >> "$DIR/configs/device_config"
#echo "num_phys_func = 1;" >> "$DIR/configs/device_config"
#echo "num_qdma = 1;" >> "$DIR/configs/device_config"
#echo "num_queue = 512;" >> "$DIR/configs/device_config"
#echo "num_cmac_port = 1;" >> "$DIR/configs/device_config"
#chmod a-w "$DIR/configs/device_config"

#host
touch $DIR/configs/host_config_001
echo "MAX_NUM_PINGS = 10;" >> "$DIR/configs/host_config_001"
#echo "NUM_PINGS = 5;" >> "$DIR/configs/host_config_001"
chmod a-w "$DIR/configs/host_config_001"

#save .device_config
#cp $DIR/configs/device_config $DIR/.device_config

#update shell configuration file
sed -i "/^\[workflows\]/!b;n;s/^[0-9]\+: /$device_index: /" "$DIR/sh.cfg"

#build
library_shell="$BITSTREAMS_PATH/$WORKFLOW/$commit_name/$TEMPLATE_NAME/${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
project_shell="$DIR/${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
if [ -e "$library_shell" ]; then
    cp "$library_shell" "$project_shell"
fi
echo "${bold}$CLI_NAME build $WORKFLOW (commit ID: $commit_name)${normal}"
echo ""

echo "commit_name: $commit_name"
echo "project_name: $project_name"
echo "vivado_version: $vivado_version"

$CLI_PATH/build/coyote --commit $commit_name --project $project_name --target "none" --version $vivado_version --is_build "0"
echo ""

#add additional echo (1/2)
#workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index)

#get devices number
MAX_DEVICES=$($CLI_PATH/common/get_max_devices "fpga|acap|asoc" $DEVICES_LIST)

#get list of devices to revert
serial_numbers=()
device_names=()
upstream_ports=()
root_ports=()
LinkCtls=()
devices_to_revert=0
for (( i=1; i<=MAX_DEVICES; i++ )); do
    workflow_i=$($CLI_PATH/common/get_workflow "$CLI_PATH" "$i")
    if [ "$workflow_i" = "coyote" ] || [ "$workflow_i" = "vivado" ]; then
        upstream_port=$($CLI_PATH/get/get_fpga_device_param $i upstream_port)
	    bdf="${upstream_port%??}" #i.e., we transform 81:00.0 into 81:00
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
		#increase counter
		((devices_to_revert++))
    fi
done

#revert devices
if [ $devices_to_revert -ge 1 ]; then
    echo "${bold}$CLI_NAME program revert${normal}"    
    echo ""
    echo "${bold}Programming XRT shell:${normal}"    
    
    #loop over the devices
    for ((i=0; i<${#serial_numbers[@]}; i++)); do
        if [[ -n ${serial_numbers[i]} ]]; then
            serial_number=${serial_numbers[i]}
            device_name=${device_names[i]}
            $VIVADO_PATH/$vivado_version/bin/vivado -nolog -nojournal -mode batch -source $CLI_PATH/program/flash_xrt_bitstream.tcl -tclargs $SERVERADDR $serial_number $device_name
        fi
    done
    #hotplug
    sudo $CLI_PATH/program/pci_hot_plug $i "${upstream_ports[@]}" "${root_ports[@]}" "${LinkCtls[@]}"
fi

#remove driver if exists
if lsmod | grep -q "${DRIVER_NAME%.ko}"; then
    #we mimic the text that would appear when >/dev/null 2>&1 whould be omitted
    echo "${bold}$CLI_NAME program driver:${normal}"
    echo ""
    echo "${bold}Removing ${DRIVER_NAME%.ko} driver:${normal}"
    echo ""
    echo "sudo rmmod ${DRIVER_NAME%.ko}"
    echo ""
    echo "${bold}Deleting driver from $MY_DRIVERS_PATH:${normal}"
    echo ""
    echo "sudo /opt/hdev/cli/common/chown $USER vivado_developers $MY_DRIVERS_PATH"
    echo "sudo /opt/hdev/cli/common/rm $MY_DRIVERS_PATH/${DRIVER_NAME%.ko}.*"
    $CLI_PATH/hdev program driver --remove "${DRIVER_NAME%.ko}" >/dev/null 2>&1
    echo ""
fi

#program coyote
echo "${bold}$CLI_NAME program $WORKFLOW (commit ID: $commit_name)${normal}"
echo ""
$CLI_PATH/program/coyote --commit $commit_name --device $device_index --project $project_name --version $vivado_version --remote $DEPLOY_OPTION

#get target remote host
#run
echo "${bold}$CLI_NAME run $WORKFLOW (commit ID: $commit_name)${normal}"
echo ""
$CLI_PATH/run/coyote --commit $commit_name --config 1 --project $project_name #--device $device_index 
return_code=$?

if [ $return_code -eq 0 ]; then
    #print
    echo -e "${COLOR_PASSED}Coyote validated on ${bold}$hostname (device $device_index)${normal}${COLOR_PASSED}!${normal}${COLOR_OFF}"
    echo ""
else 
    echo -e "${COLOR_FAILED}Coyote failed on ${bold}$hostname (device $device_index)${normal}${COLOR_FAILED}!${normal}${COLOR_OFF}"
    echo ""
fi

#cleaning
echo "${bold}Reverting device and removing driver:${normal}"

# Run revert in the background but attached to the current shell
$CLI_PATH/program/revert -d $device_index --version $vivado_version --remote 0 > /dev/null 2>&1 &

# Capture the PID of the background process
revert_pid=$!

#print progress
workflow="coyote"
while true; do
    if [ "$workflow" = "coyote" ] || [ "$workflow" = "vivado" ]; then
        echo -n "."
        sleep 0.5
    else
        break
    fi
    workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index 2>/dev/null)
done

# Wait for the revert process to complete
wait $revert_pid

# Remove driver
$CLI_PATH/hdev program driver --remove ${DRIVER_NAME%.ko} >/dev/null 2>&1

#remove at the end
rm -rf $DIR

# Ensure a new line after completion
echo
echo

#author: https://github.com/jmoya82
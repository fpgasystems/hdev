#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
CLI_NAME="sgutil"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/sgutil validate opennic --commit $commit_name_shell $commit_name_driver --device $device_index --fec $fec_option --version $vivado_version
#example: /opt/sgrt/cli/sgutil validate opennic --commit            8077751             1cf2578 --device             1 --fec 1           --version          2022.2

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
is_virtualized=$($CLI_PATH/common/is_virtualized $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
vivado_enabled=$([ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; } && echo 1 || echo 0)
if [ "$is_build" = "1" ] || [ "$is_virtualized" = "1" ] || [ "$vivado_enabled" = "0" ]; then
    exit
fi

#temporal exit condition
if [ "$is_asoc" = "1" ]; then
    echo ""
    echo "Sorry, we are working on this!"
    echo ""
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
commit_name_shell=$2
commit_name_driver=$3
device_index=$5
fec_option=$7
vivado_version=$9

#all inputs must be provided
if [ "$commit_name_shell" = "" ] || [ "$commit_name_driver" = "" ] || [ "$device_index" = "" ] || [ "$fec_option" = "" ] || [ "$vivado_version" = "" ]; then
    exit
fi

#constants
ACAP_SERVERS_LIST="$CLI_PATH/constants/ACAP_SERVERS_LIST"
BITSTREAM_NAME=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_NAME)
BITSTREAMS_PATH="$CLI_PATH/bitstreams"
BUILD_SERVERS_LIST="$CLI_PATH/constants/BUILD_SERVERS_LIST"
COLOR_FAILED=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_FAILED)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)
COLOR_PASSED=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_PASSED)
GPU_SERVERS_LIST="$CLI_PATH/constants/GPU_SERVERS_LIST"
DEPLOY_OPTION="0"
DRIVER_NAME=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_NAME)
FPGA_SERVERS_LIST="$CLI_PATH/constants/FPGA_SERVERS_LIST"
MY_DRIVERS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_DRIVERS_PATH)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
NUM_PINGS="5"
SERVERADDR="localhost"
WORKFLOW="opennic"
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
platform_name=$($CLI_PATH/get/get_fpga_device_param $device_index platform)

#get FDEV_NAME
FDEV_NAME=$($CLI_PATH/common/get_FDEV_NAME $CLI_PATH $device_index)

#set project name
project_name="validate_opennic.$hostname.$commit_name_driver.$FDEV_NAME.$vivado_version"

#define directories (1)
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name_shell/$project_name"
SHELL_BUILD_DIR="$DIR/open-nic-shell/script"
DRIVER_DIR="$DIR/open-nic-driver"

#remove in the beginning
if [ -d "$DIR" ]; then
    rm -rf "$DIR"
fi

#new
if ! [ -d "$DIR" ]; then
    echo "${bold}$CLI_NAME new $WORKFLOW (commit IDs for shell and driver: $commit_name_shell,$commit_name_driver)${normal}"
    echo ""
    $CLI_PATH/new/opennic --commit $commit_name_shell $commit_name_driver --project $project_name --push 0 
fi

#cleanup
rm -f $DIR/configs/host_config_000

#create default configurations
#device
touch $DIR/configs/device_config
echo "min_pkt_len = 64;" >> "$DIR/configs/device_config"
echo "max_pkt_len = 1514;" >> "$DIR/configs/device_config"
echo "use_phys_func = 1;" >> "$DIR/configs/device_config"
echo "num_phys_func = 1;" >> "$DIR/configs/device_config"
echo "num_qdma = 1;" >> "$DIR/configs/device_config"
echo "num_queue = 512;" >> "$DIR/configs/device_config"
echo "num_cmac_port = 1;" >> "$DIR/configs/device_config"
echo "rs_fec = $fec_option;" >> "$DIR/configs/device_config"
chmod a-w "$DIR/configs/device_config"

#host
touch $DIR/configs/host_config_001
echo "MAX_NUM_PINGS = 10;" >> "$DIR/configs/host_config_001"
echo "NUM_PINGS = 5;" >> "$DIR/configs/host_config_001"
#chmod a-w "$DIR/configs/host_config_001"

#save .device_config
cp $DIR/configs/device_config $DIR/.device_config

#build
library_shell="$BITSTREAMS_PATH/$WORKFLOW/$commit_name_shell/${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
project_shell="$DIR/${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
if [ -e "$library_shell" ]; then
    cp "$library_shell" "$project_shell"
fi
echo "${bold}$CLI_NAME build $WORKFLOW (commit ID for shell: $commit_name_shell)${normal}"
echo ""
$CLI_PATH/build/opennic --commit $commit_name_shell $commit_name_driver --platform $platform_name --project $project_name --version $vivado_version --all 0 #--config "host_config_001" 
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
    if [ "$workflow_i" = "opennic" ] || [ "$workflow_i" = "vivado" ]; then
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

#add additional echo (2/2)
#if [ "$workflow" = "opennic" ] || [ "$workflow" = "vivado" ]; then
#    echo ""
#fi

#get system interfaces (before adding the OpenNIC interface)
before=$(ifconfig -a | grep '^[a-zA-Z0-9]' | awk '{print $1}' | tr -d ':')

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
    echo "sudo /opt/sgrt/cli/common/chown $USER vivado_developers $MY_DRIVERS_PATH"
    echo "sudo /opt/sgrt/cli/common/rm $MY_DRIVERS_PATH/${DRIVER_NAME%.ko}.*"
    #echo "$CLI_PATH/sgutil program driver --remove ${DRIVER_NAME%.ko}"
    $CLI_PATH/sgutil program driver --remove "${DRIVER_NAME%.ko}" >/dev/null 2>&1
    echo ""
fi

#program opennic
echo "${bold}$CLI_NAME program $WORKFLOW (commit ID: $commit_name_shell)${normal}"
echo ""
$CLI_PATH/program/opennic --commit $commit_name_shell --device $device_index --project $project_name --version $vivado_version --remote $DEPLOY_OPTION

#get system interfaces (after adding the OpenNIC interface)
after=$(ifconfig -a | grep '^[a-zA-Z0-9]' | awk '{print $1}' | tr -d ':')

#remove the trailing colon if it exists
after=${after%:}

#use comm to find the "extra" OpenNIC
eno_onic=$(comm -13 <(echo "$before" | sort) <(echo "$after" | sort))

#read SERVERS_LISTS excluding the current hostname
IFS=$'\n' read -r -d '' -a remote_servers < <(cat "$ACAP_SERVERS_LIST" "$BUILD_SERVERS_LIST" "$FPGA_SERVERS_LIST" "$GPU_SERVERS_LIST" | grep -v "^$hostname$" | sort -u && printf '\0')

#set target host
target_host=""
connected=""
for server in "${remote_servers[@]}"; do
    # Check connectivity to the current server
    if [[ "$(check_connectivity "$eno_onic" "$server")" == "1" ]]; then
        connected="1"
        target_host="$server"
        #add to host_config_001 (this is only conceptual)
        echo "remote_server = $target_host;" >> "$DIR/configs/host_config_001"
        chmod a-w "$DIR/configs/host_config_001"
        break
    fi
done

#get target remote host
if [[ $connected = "1" ]]; then
    #run
    echo "${bold}$CLI_NAME run $WORKFLOW (commit ID: $commit_name_shell)${normal}"
    echo ""
    $CLI_PATH/run/opennic --commit $commit_name_shell --config 1 --device $device_index --project $project_name
    return_code=$?

    if [ $return_code -eq 0 ]; then
        #get RS_FEC_ENABLED from .device_config
        fec_option=$($CLI_PATH/common/get_config_param $CLI_PATH "$DIR/.device_config" "rs_fec")

        #print
        echo -e "${COLOR_PASSED}OpenNIC validated on ${bold}$hostname (device $device_index)${normal}${COLOR_PASSED} with ${bold}RS_FEC_ENABLED=$fec_option!${normal}${COLOR_OFF}"
        echo ""
    else 
        echo -e "${COLOR_PASSED}OpenNIC failed on ${bold}$hostname (device $device_index)${normal}${COLOR_FAILED} with ${bold}RS_FEC_ENABLED=$fec_option!${normal}${COLOR_OFF}"
        echo ""
    fi
else
    echo -e "${COLOR_FAILED}OpenNIC failed on ${bold}$hostname (device $device_index)${normal}${COLOR_FAILED} with ${bold}RS_FEC_ENABLED=$fec_option!${normal}${COLOR_OFF}"
    echo ""
fi

#cleaning
echo "${bold}Reverting device and removing driver:${normal}"

# Run revert in the background but attached to the current shell
$CLI_PATH/program/revert -d $device_index --version $vivado_version --remote 0 > /dev/null 2>&1 &

# Capture the PID of the background process
revert_pid=$!

#print progress
workflow="opennic"
while true; do
    if [ "$workflow" = "opennic" ] || [ "$workflow" = "vivado" ]; then
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
$CLI_PATH/sgutil program driver --remove ${DRIVER_NAME%.ko} >/dev/null 2>&1

#remove at the end
rm -rf $DIR

# Ensure a new line after completion
echo
echo

#author: https://github.com/jmoya82
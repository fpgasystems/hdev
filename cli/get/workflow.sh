#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
if [ "$is_acap" = "0" ] && [ "$is_asoc" = "0" ] && [ "$is_fpga" = "0" ]; then
    exit
fi

is_opennic(){
    local device_index=$1

    # Get device MAC address
    MACs=$($CLI_PATH/get/get_fpga_device_param "$device_index" MAC)
    MAC0="${MACs%%/*}"

    # Convert MAC address to lowercase
    MAC0=$(echo "$MAC0" | tr '[:upper:]' '[:lower:]')

    # Get device IP address
    IPs=$($CLI_PATH/get/get_fpga_device_param "$device_index" IP)
    IP0="${IPs%%/*}"

    # Use ifconfig and awk to check for both IP and MAC in the same interface block
    if ifconfig | awk -v ip="$IP0" -v mac="$MAC0" '
        BEGIN { found_ip = 0; found_mac = 0; }
        /inet/ && $2 == ip { found_ip = 1 }
        /ether/ && $2 == mac { found_mac = 1 }
        found_ip && found_mac { exit 0 }  # Found both IP and MAC, success
        END { exit (found_ip && found_mac ? 0 : 1) }  # Return success if both are found
    '; then
        echo "1"
    else
        echo "0"
    fi
}

#constants
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#check on ACAP or FPGA servers (server must have at least one ACAP or one FPGA)
#acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
#fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
#if [ "$acap" = "0" ] && [ "$fpga" = "0" ]; then
#    echo ""
#    echo "Sorry, this command is not available on ${bold}$hostname!${normal}"
#    echo ""
#    exit
#fi

#check on DEVICES_LIST
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"

#get number of fpga and acap devices present
MAX_DEVICES=$(grep -E "fpga|acap|asoc" $DEVICES_LIST | wc -l)

#check on multiple devices
multiple_devices=$($CLI_PATH/common/get_multiple_devices $MAX_DEVICES)

#inputs
read -a flags <<< "$@"

#check on flags
device_found=""
device_index=""
if [ "$flags" = "" ]; then
    echo ""
    #print devices information
    for device_index in $(seq 1 $MAX_DEVICES); do 
        #get Bus Device Function
        upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
	    bdf="${upstream_port%??}" #i.e., we transform 81:00.0 into 81:00    
        if [[ $(lspci | grep Xilinx | grep $bdf | wc -l) = 1 ]]; then
            #check on OpenNIC
            opennic=$(is_opennic "$device_index")

            #check on integrations
            if [ "$opennic" = "1" ]; then
                echo "$device_index: opennic"
            else
                echo "$device_index: vivado"
            fi
        elif [[ $(lspci | grep Xilinx | grep $bdf | wc -l) = 2 ]]; then
            #check on asoc
            is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)

            #check on workflows
            if [ "$is_asoc" = "1" ]; then
                echo "$device_index: aved"
            else
                echo "$device_index: vitis"
            fi
        else
            echo "$device_index: unknown"
        fi
    done
    echo ""
else
    #device_dialog_check
    result="$("$CLI_PATH/common/device_dialog_check" "${flags[@]}")"
    device_found=$(echo "$result" | sed -n '1p')
    device_index=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if ([ "$device_found" = "1" ] && [ "$device_index" = "" ]) || ([ "$device_found" = "1" ] && [ "$multiple_devices" = "0" ] && (( $device_index != 1 ))) || ([ "$device_found" = "1" ] && ([[ "$device_index" -gt "$MAX_DEVICES" ]] || [[ "$device_index" -lt 1 ]])); then
        #$CLI_PATH/sgutil get workflow -h
        echo ""
        echo "Please, choose a valid device index."
        echo ""
        exit
    fi
    #device_dialog (forgotten mandatory)
    if [[ $multiple_devices = "0" ]]; then
        device_found="1"
        device_index="1"
    elif [[ $device_found = "0" ]]; then
        $CLI_PATH/sgutil get workflow -h
        exit
    fi
    #get Bus Device Function
    upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
    bdf="${upstream_port%??}" #i.e., we transform 81:00.0 into 81:00    
    #print
    echo ""
    if [[ $(lspci | grep Xilinx | grep $bdf | wc -l) = 1 ]]; then
        #check on OpenNIC
        opennic=$(is_opennic "$device_index")

        #check on integrations
        if [ "$opennic" = "1" ]; then
            echo "$device_index: opennic"
        else
            echo "$device_index: vivado"
        fi
    elif [[ $(lspci | grep Xilinx | grep $bdf | wc -l) = 2 ]]; then
        #check on asoc
        is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)

        #check on workflows
        if [ "$is_asoc" = "1" ]; then
            echo "$device_index: aved"
        else
            echo "$device_index: vitis"
        fi
    else
        echo "$device_index: unknown"
    fi
    echo ""
fi
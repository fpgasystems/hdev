#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#constants
DEVICES_LIST="$CLI_PATH/devices_network"

#check on DEVICES_LIST
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"

#get number of fpga and acap devices present
MAX_DEVICES=$(grep -E "nic" $DEVICES_LIST | wc -l)

#check on multiple devices
multiple_devices=$($CLI_PATH/common/get_multiple_devices $MAX_DEVICES)

#inputs
read -a flags <<< "$@"

#helper functions
split_addresses (){
  #input parameters
  str_ip=$1
  str_mac=$2
  aux=$3
  #save the current IFS
  OLDIFS=$IFS
  #set the IFS to / to split the string at each /
  IFS="/"
  #read the two parts of the string into variables
  read ip0 ip1 <<< "$str_ip"
  read mac0 mac1 <<< "$str_mac"
  #reset the IFS to its original value
  IFS=$OLDIFS
  #print the two parts of the string
  if [[ "$aux" == "0" ]]; then
    echo "$ip0 ($mac0)"
  else
    echo "$ip1 ($mac1)"
  fi
}

#check on flags
device_found=""
device_index=""
if [ "$flags" = "" ]; then
    echo ""
    #print devices information
    for device_index in $(seq 1 $MAX_DEVICES); do 
        ip=$($CLI_PATH/get/get_nic_device_param $device_index IP)
        if [ -n "$ip" ]; then
            ip0=$(echo "$ip" | cut -d'/' -f1)
            ip1=$(echo "$ip" | cut -d'/' -f2)
            mac=$($CLI_PATH/get/get_nic_device_param $device_index MAC)
            add_0=$(split_addresses $ip $mac 0)
            add_1=$(split_addresses $ip $mac 1)
            iface_name_0=$(ifconfig | grep -B1 "$ip0" | awk '/^[a-zA-Z0-9]/ {print $1}' | sed 's/://') 
            iface_name_1=$(ifconfig | grep -B1 "$ip1" | awk '/^[a-zA-Z0-9]/ {print $1}' | sed 's/://')
            #first interface
            if [ -n "$iface_name_0" ]; then
                output=$(ip link show "$iface_name_0")
                if echo "$output" | grep -q "xdp"; then
                    #xdp_0="(ethxdp)"
                    xdp_0="(xdp)"
                fi
                #format
                iface_name_0=": $iface_name_0 $xdp_0"
            fi
            #second interface
            if [ -n "$iface_name_1" ]; then
                output=$(ip link show "$iface_name_1")
                if echo "$output" | grep -q "xdp"; then
                    #xdp_1="(ethxdp)"
                    xdp_1="(xdp)"
                fi
                #format
                iface_name_1=": $iface_name_1 $xdp_1"$'\n'
            else
                iface_name_1=" "$'\n'
            fi
            name="$device_index" 
            name_length=$(( ${#name} + 1 ))
            echo "$name: $add_0 $iface_name_0"
            printf "%-${name_length}s %s %s\n" "" "$add_1" "$iface_name_1"
        fi
    done
    #echo ""
else
    #device_dialog_check
    result="$("$CLI_PATH/common/device_dialog_check" "${flags[@]}")"
    device_found=$(echo "$result" | sed -n '1p')
    device_index=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if ([ "$device_found" = "1" ] && [ "$device_index" = "" ]) || ([ "$device_found" = "1" ] && [ "$multiple_devices" = "0" ] && (( $device_index != 1 ))) || ([ "$device_found" = "1" ] && ([[ "$device_index" -gt "$MAX_DEVICES" ]] || [[ "$device_index" -lt 1 ]])); then
        #$CLI_PATH/hdev get ifconfig -h
        echo ""
        echo "Please, choose a valid device index."
        echo ""
        exit
    fi
    #port_dialog_check
    result="$("$CLI_PATH/common/port_dialog_check" "${flags[@]}")"
    port_found=$(echo "$result" | sed -n '1p')
    port_index=$(echo "$result" | sed -n '2p')
    #device_dialog (forgotten mandatory)
    if [[ $multiple_devices = "0" ]]; then
        device_found="1"
        device_index="1"
    elif [[ $device_found = "0" ]]; then
        #$CLI_PATH/hdev get ifconfig -h
        echo ""
        echo "Please, choose a valid device index."
        echo ""
        exit
    fi
    #forbidden combinations (port)
    MAX_NUM_PORTS=$($CLI_PATH/get/get_nic_device_param $device_index IP | grep -o '/' | wc -l)
    MAX_NUM_PORTS=$((MAX_NUM_PORTS + 1))
    if ([ "$port_found" = "1" ] && [ "$port_index" = "" ]) || ([ "$port_found" = "1" ] && ([[ "$port_index" -gt "$MAX_NUM_PORTS" ]] || [[ "$port_index" -lt 1 ]])); then
        echo ""
        echo "Please, choose a valid port index."
        echo ""
        #$CLI_PATH/hdev get ifconfig -h
        exit
    fi
    
    #get values
    ip=$($CLI_PATH/get/get_nic_device_param $device_index IP)
    mac=$($CLI_PATH/get/get_nic_device_param $device_index MAC)
    add_0=$(split_addresses $ip $mac 0)
    add_1=$(split_addresses $ip $mac 1)
    name="$device_index"
    name_length=$(( ${#name} + 1 ))

    #print
    if [[ $port_found = "0" ]]; then
        echo ""
        echo "$name: $add_0"
        printf "%-${name_length}s %s\n" "" "$add_1"
        echo ""
    else
        port_index=$((port_index - 1))
        var_name="add_$port_index" # Create the variable name string
        echo ""
        echo "$name: ${!var_name}" 
        echo ""
    fi
fi
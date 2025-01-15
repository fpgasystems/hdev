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
is_nic=$($CLI_PATH/common/is_nic $CLI_PATH $hostname)
if [ "$is_acap" = "0" ] && [ "$is_asoc" = "0" ] && [ "$is_fpga" = "0" ] && [ "$is_nic" = "0" ]; then
    exit
fi

#constants
COLOR_ON1=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_CPU)
COLOR_ON2=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_XILINX)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"
TMP_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)

#check on DEVICES_LIST
source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"

#get number of fpga and acap devices present
MAX_DEVICES=$(grep -E "fpga|acap|asoc" $DEVICES_LIST | wc -l)

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

#legends
if [ "$is_nic" = "1" ]; then
    legend_nic="${bold}${COLOR_ON1}NICs${COLOR_OFF}${normal}"
fi
if [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; then
    legend_fpga="${bold}${COLOR_ON2}Adaptive Devices${COLOR_OFF}${normal}"
fi

#check on flags
device_found=""
device_index=""
if [ "$flags" = "" ]; then
    if [ "$is_nic" = "1" ]; then
        #$CLI_PATH/get/ifconfig
        $CLI_PATH/get/ifconfig > $TMP_PATH/interfaces.txt
        awk -v COLOR_ON1="$COLOR_ON1" -v COLOR_OFF="$COLOR_OFF" '{print COLOR_ON1 $0 COLOR_OFF}' $TMP_PATH/interfaces.txt
    fi
    if [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; then
        #$CLI_PATH/get/network
        $CLI_PATH/get/network > $TMP_PATH/interfaces.txt
        awk -v COLOR_ON2="$COLOR_ON2" -v COLOR_OFF="$COLOR_OFF" '{print COLOR_ON2 $0 COLOR_OFF}' $TMP_PATH/interfaces.txt
    fi
    if [ -n "$legend_nic" ] && [ -n "$legend_fpga" ]; then
        echo -e $legend_nic" "$legend_fpga
    elif [ -n "$legend_fpga" ]; then
        echo -e $legend_nic
    elif [ -n "$legend_nic" ]; then
        echo -e $legend_fpga
    fi
    echo ""
else
    #device_dialog_check
    result="$("$CLI_PATH/common/device_dialog_check" "${flags[@]}")"
    device_found=$(echo "$result" | sed -n '1p')
    device_index=$(echo "$result" | sed -n '2p')
    #forbidden combinations
    if ([ "$device_found" = "1" ] && [ "$device_index" = "" ]) || ([ "$device_found" = "1" ] && [ "$multiple_devices" = "0" ] && (( $device_index != 1 ))) || ([ "$device_found" = "1" ] && ([[ "$device_index" -gt "$MAX_DEVICES" ]] || [[ "$device_index" -lt 1 ]])); then
        #$CLI_PATH/hdev get network -h
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
        #$CLI_PATH/hdev get network -h
        echo ""
        echo "Please, choose a valid device index."
        echo ""
        exit
    fi
    #forbidden combinations (port)
    MAX_NUM_PORTS=$($CLI_PATH/get/get_fpga_device_param $device_index IP | grep -o '/' | wc -l)
    MAX_NUM_PORTS=$((MAX_NUM_PORTS + 1))
    #if ([ "$port_found" = "1" ] && [ "$port_index" = "" ]) || ([ "$port_found" = "1" ] && [ "$multiple_devices" = "0" ] && (( $port_index != 1 ))) || ([ "$port_found" = "1" ] && ([[ "$port_index" -gt "$MAX_NUM_PORTS" ]] || [[ "$port_index" -lt 1 ]])); then
    if ([ "$port_found" = "1" ] && [ "$port_index" = "" ]) || ([ "$port_found" = "1" ] && ([[ "$port_index" -gt "$MAX_NUM_PORTS" ]] || [[ "$port_index" -lt 1 ]])); then
        #$CLI_PATH/hdev get network -h
        echo ""
        echo "Please, choose a valid port index."
        echo ""
        exit
    fi
    
    #get values
    ip=$($CLI_PATH/get/get_fpga_device_param $device_index IP)
    mac=$($CLI_PATH/get/get_fpga_device_param $device_index MAC)
    device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
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

#delete temporal file
rm -f $TMP_PATH/interfaces.txt

#author: https://github.com/jmoya82
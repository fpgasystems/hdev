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
TMP_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)

#inputs
read -a flags <<< "$@"

#check on flags
if [ "$flags" = "" ]; then
    #legend 1
    if [ "$is_nic" = "1" ]; then
        legend_nic="${bold}${COLOR_ON1}NICs${COLOR_OFF}${normal}"
    fi

    #legend 2
    if [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; then
        legend_fpga="${bold}${COLOR_ON2}Adaptive Devices${COLOR_OFF}${normal}"
    fi

    #generate file
    if [ "$is_nic" = "1" ]; then
        $CLI_PATH/get/ifconfig > $TMP_PATH/interfaces.txt
        awk -v COLOR_ON1="$COLOR_ON1" -v COLOR_OFF="$COLOR_OFF" '{print COLOR_ON1 $0 COLOR_OFF}' $TMP_PATH/interfaces.txt
    fi
    if [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; then
        $CLI_PATH/get/network > $TMP_PATH/interfaces.txt
        awk -v COLOR_ON2="$COLOR_ON2" -v COLOR_OFF="$COLOR_OFF" '{print COLOR_ON2 $0 COLOR_OFF}' $TMP_PATH/interfaces.txt
    fi

    #print legend
    if [ -n "$legend_nic" ] && [ -n "$legend_fpga" ]; then
        echo -e "$legend_nic $legend_fpga"
    elif [ -n "$legend_nic" ]; then
        echo -e "$legend_nic"
    elif [ -n "$legend_fpga" ]; then
        echo -e "$legend_fpga"
    fi
    
    echo ""
    
    #delete temporal file
    rm -f $TMP_PATH/interfaces.txt
else
    #type dialog check
    result="$("$CLI_PATH/common/word_check" "-t" "--type" "${flags[@]}")"
    type_found=$(echo "$result" | sed -n '1p')
    type_value=$(echo "$result" | sed -n '2p')

    #forbidden combinations
    if [ "$type_found" = "1" ] && ([ "$type_value" = "" ] || ([ ! "$type_value" = "nic" ] && [ ! "$type_value" = "adaptive" ])); then
        echo ""
        echo "Please, choose a valid device type."
        echo ""
        exit 1        
    fi
    
    if [[ $type_value = "nic" ]]; then
        $CLI_PATH/get/ifconfig
    elif [[ $type_value = "adaptive" ]]; then
        echo ""
        $CLI_PATH/get/network
    fi
fi

#author: https://github.com/jmoya82
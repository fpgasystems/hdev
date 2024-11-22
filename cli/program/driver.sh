#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:        $CLI_PATH/sgutil program driver --insert $driver_name --params   $params_string --remote $deploy_option
#examples: /opt/sgrt/cli/sgutil program driver --insert      onic.ko --params RS_FEC_ENABLED=0 --remote              0
#          /opt/sgrt/cli/sgutil program driver --remove      onic

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

#inputs
driver_name=$2
params_string=$4
deploy_option=$6
servers_family_list=$7

#all inputs must be provided (params_string can be empty)
if [ "$driver_name" = "" ]; then
    exit
fi

#check on remote aboslute path
if [ "$deploy_option" = "1" ] && [[ "$driver_name" == "./"* ]]; then
    exit
fi

#constants
MY_DRIVERS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_DRIVERS_PATH)

#create folder
if [ ! -d "$MY_DRIVERS_PATH" ]; then
    mkdir "$MY_DRIVERS_PATH"
fi

#get current path
current_path=$(pwd)

#get actual filename (i.e. onik.ko without the path)
driver_name_base=$(basename "$driver_name")

#inserting driver
insert_driver="0"
if ! lsmod | grep -q ${driver_name_base%.ko}; then
    insert_driver="1"
else
    echo "The driver ${bold}${driver_name_base%.ko}${normal} is already inserted. Do you want to remove it and insert it again (y/n)?"
    #deploy_dialog
    while true; do
        read -p "" yn
        case $yn in
            "y")
                #driver will be reinserted
                insert_driver="1"
                
                #change directory (this is important)
                cd $MY_DRIVERS_PATH
                
                #adding echo
                echo ""

                #remove module
                echo "${bold}Removing ${driver_name_base%.ko} module:${normal}"
                echo ""
                echo "sudo rmmod ${driver_name_base%.ko}"
                echo ""
                sudo rmmod ${driver_name_base%.ko}

                echo "${bold}Deleting driver from $MY_DRIVERS_PATH:${normal}"
                echo ""
                echo "sudo $CLI_PATH/common/chown $USER vivado_developers $MY_DRIVERS_PATH"
                echo "sudo $CLI_PATH/common/rm $MY_DRIVERS_PATH/${driver_name_base%.ko}.*"
                #echo ""

                #change ownership to ensure writing permissions and remove
                sudo $CLI_PATH/common/chown $USER vivado_developers $MY_DRIVERS_PATH
                sudo $CLI_PATH/common/rm $MY_DRIVERS_PATH/${driver_name_base%.ko}.*
                break
                ;;
            "n") 
                #compile="0"
                break
                ;;
        esac
    done
    echo ""
fi

#inserting the driver
if [ "$insert_driver" = "1" ]; then 
    #change ownership to ensure writing permissions
    sudo $CLI_PATH/common/chown $USER vivado_developers $MY_DRIVERS_PATH

    #change back
    cd $current_path

    #we need to copy the driver to /local to avoid permission problems
    echo "${bold}Copying driver to $MY_DRIVERS_PATH:${normal}"
    echo ""
    echo "cp -f $driver_name $MY_DRIVERS_PATH"
    echo ""
    
    #copy driver
    cp -f $driver_name $MY_DRIVERS_PATH

    #echo ""
    echo "${bold}Inserting $driver_name_base module:${normal}"
    echo ""

    #check on params_string
    if [ "$params_string" = "none" ]; then
        params_string=""
    fi

    #replace commas with spaces
    params_string=$(echo "$params_string" | tr ',' ' ')
    params_string=$(echo "$params_string" | tr ';' ' ')

    #change directory (this is important)
    cd $MY_DRIVERS_PATH

    echo "sudo insmod $MY_DRIVERS_PATH/$driver_name_base $params_string"
    sudo insmod $MY_DRIVERS_PATH/$driver_name_base $params_string
    sleep 1
    echo ""
fi

#check on params_string
if [ "$params_string" = "" ]; then
    params_string="none"
fi

#programming remote servers (if applies)
programming_string_1="sudo rmmod ${driver_name_base%.ko} 2>/dev/null; sudo $CLI_PATH/common/chown $USER vivado_developers $MY_DRIVERS_PATH 2>/dev/null; sudo $CLI_PATH/common/rm $MY_DRIVERS_PATH/${driver_name_base%.ko}.* 2>/dev/null; $CLI_PATH/program/driver --insert $driver_name --params $params_string --remote 0"
$CLI_PATH/program/remote "$CLI_PATH" "$USER" "$deploy_option" "$programming_string_1" "$servers_family_list"

#author: https://github.com/jmoya82
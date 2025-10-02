#!/bin/bash

#early exit
if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "0" ]; then
    exit 1
fi

#check on groups
vivado_developers_check "$USER"

#check on flags
valid_flags="-i --insert -p --params --remote --remove -h --help"
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#checks (command line)
if [ "$flags_array" = "" ]; then
    program_driver_help
fi

#dialogs
driver_check "$CLI_PATH" "${flags_array[@]}"

#check on -r or --remove
if [ "$remove_flag_found" = "1" ]; then
    #get actual filename (i.e. onik.ko without the path)
    driver_name_base=$(basename "$driver_name")

    if lsmod | grep -q "${driver_name_base%.ko}" && ls "$MY_DRIVERS_PATH/$driver_name".* &>/dev/null; then
        echo ""
        echo "${bold}$CLI_NAME $command $arguments${normal}"
        echo ""

        #change directory (this is important)
        cd $MY_DRIVERS_PATH
        
        #remove module
        echo "${bold}Removing ${driver_name_base%.ko} module:${normal}"
        echo ""
        echo "sudo rmmod ${driver_name_base%.ko}"
        echo ""
        sudo rmmod ${driver_name_base%.ko}

        echo "${bold}Deleting driver from $MY_DRIVERS_PATH:${normal}"
        echo ""
        echo "sudo $CLI_PATH/common/chown $USER vivado_developers $MY_DRIVERS_PATH"
        echo "sudo $CLI_PATH/common/rm $MY_DRIVERS_PATH/$driver_name.*"
        echo ""

        #change ownership to ensure writing permissions and remove
        sudo $CLI_PATH/common/chown $USER vivado_developers $MY_DRIVERS_PATH
        sudo $CLI_PATH/common/rm $MY_DRIVERS_PATH/$driver_name.*
        exit 0
    else
        echo ""
        echo $CHECK_ON_DRIVER_ERR_MSG
        echo ""
        exit 1
    fi
    #exit
fi

echo ""
echo "${bold}$CLI_NAME $command $arguments${normal}"
echo ""

remote_dialog "$CLI_PATH" "$command" "$arguments" "$hostname" "$USER" "${flags_array[@]}"

#check on remote aboslute path
if [ "$deploy_option" = "1" ] && [[ "$driver_name" == "./"* ]]; then
    echo $CHECK_ON_REMOTE_FILE_ERR_MSG
    echo ""
    exit 1
fi

#check on params_string
if [ "$params_string" = "" ]; then
    params_string="none"
fi

#run
$CLI_PATH/program/driver --insert $driver_name --params $params_string --remote $deploy_option "${servers_family_list[@]}"
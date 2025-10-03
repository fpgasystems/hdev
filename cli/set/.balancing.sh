#!/bin/bash

#early exit
if [ "$is_build" = "1" ] || [ "$is_numa" = "0" ] || [ "$is_vivado_developer" = "0" ]; then
    exit 1
fi

#check on groups
vivado_developers_check "$USER"

valid_flags="-v --value -h --help"
#command_run $command_arguments_flags"@"$valid_flags
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#checks (command line)
if [ "$flags_array" = "" ]; then
    set_balancing_help
else
    #value
    result="$("$CLI_PATH/common/value_dialog_check" "${flags_array[@]}")"
    value_found=$(echo "$result" | sed -n '1p')
    value=$(echo "$result" | sed -n '2p')

    #check on value
    value_check "$CLI_PATH" "0" "1" "balancing" "${flags_array[@]}"
fi

#run
$CLI_PATH/set/balancing --value $value
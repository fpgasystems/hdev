#!/bin/bash

#check on flags
valid_flags="-s --source -h --help" 
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#checks (command line)
if [ "$flags" = "" ]; then
    #program_vivado_help
    echo ""
    echo "Your targeted file is missing."
    echo ""
    exit
else 
    #cfile_dialog_check
    result="$("$CLI_PATH/common/cfile_dialog_check" "${flags_array[@]}")"
    cfile_found=$(echo "$result" | sed -n '1p')
    cfile_path=$(echo "$result" | sed -n '2p')
    #forbidden combinations (1/2)
    if [ "$cfile_found" = "0" ] || ([ "$cfile_found" = "1" ] && ([ "$cfile_path" = "" ] || [ ! -f "$cfile_path" ] || ( [ "${cfile_path##*.}" != "c" ] && [ "${cfile_path##*.}" != "cpp" ] ))); then
        echo ""
        echo $CHECK_ON_FILENAME_ERR_MSG
        echo ""
    exit
    fi
fi
echo ""

#run
$CLI_PATH/build/c --source $cfile_path
echo ""
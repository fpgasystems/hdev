#!/bin/bash

#early exit
if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "0" ]; then
    exit 1
fi

#check on groups
vivado_developers_check "$USER"

#check on software
vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
vivado_check "$VIVADO_PATH" "$vivado_version"
gh_check "$CLI_PATH"

#check on flags
valid_flags="-p --path -h --help"
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#check on size
word_check "$CLI_PATH" "-p" "--path" "${flags_array[@]}"
path_found=$word_found
path_value=$word_value
if [[ "$path_found" == "1" && ( ! -f "$path_value" || "$path_value" != *.xpr ) ]]; then
    echo ""
    echo $CHECK_ON_XPR_FILE_ERR_MSG
    echo ""
    exit 1
fi

#check on X11 fordwarding
if [ -z "$DISPLAY" ]; then
    echo ""
    echo $CHECK_ON_X11_ERR_MSG
    echo ""
    exit 1
fi

#run
$CLI_PATH/open/vivado --path $path_value
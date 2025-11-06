#!/bin/bash

#early exit
if [ "$is_build" = "1" ] || [ "$is_vivado_developer" = "0" ]; then
    exit 1
fi

#check on groups
vivado_developers_check "$USER"

valid_flags="-p --pages -s --size"
flags_check $command_arguments_flags"@"$valid_flags

#inputs (split the string into an array)
read -r -a flags_array <<< "$flags"

#check on size
word_check "$CLI_PATH" "-s" "--size" "${flags_array[@]}"
size_found=$word_found
size_id=$word_value
if [[ ! "$size_id" =~ ^(2M|1G)$ ]]; then
    echo ""
    echo "Please, choose a valid value for size."
    echo ""
    exit 1
fi

#check on pages
word_check "$CLI_PATH" "-p" "--pages" "${flags_array[@]}"
pages_found=$word_found
pages_value=$word_value

#get maximum number of pages
max_pages=$($CLI_PATH/common/get_max_hugepages $size_id)
if [ "$pages_found" = "0" ] || [[ ! "$pages_value" =~ ^[0-9]+$ ]] || [ "$pages_value" -lt 1 ] || [ "$pages_value" -gt "$max_pages" ]; then
    echo ""
    echo "Please, choose a valid value for pages."
    echo ""
    exit
fi

#run
$CLI_PATH/set/hugepages --size $size_id --pages $pages_value
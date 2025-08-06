#!/bin/bash

LIST_PATH="$1"

# Declare global variables
declare -g item_found="0"
declare -g item_name=""

# Read device names into array
mapfile -t items < "$LIST_PATH"

# Check if there is only one item
if [ ${#items[@]} -eq 1 ]; then
    item_found="1"
    item_name=${items[0]}
else
    PS3=""
    select item_name in "${items[@]}"; do
        if [[ -n $item_name ]]; then
            item_found="1"
            break
        fi
    done
fi

# Return the values of item_found and item_name
echo "$item_found"
echo "$item_name"
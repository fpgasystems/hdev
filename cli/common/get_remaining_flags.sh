#!/bin/bash

# Arguments passed to the script
previous_flags="$1"
FLAGS="$2"

# Convert arguments back to arrays
IFS=" " read -r -a prev_flags <<< "$previous_flags"
IFS=" " read -r -a opennic_flags <<< "$FLAGS"

# Create a new array to store the strings that are not in previous_flags
new_flags=()

for flag in "${opennic_flags[@]}"; do
    if [[ ! " ${prev_flags[*]} " =~ " $flag " ]]; then
        new_flags+=("$flag")
    fi
done

# Print the result
echo "${new_flags[@]}"
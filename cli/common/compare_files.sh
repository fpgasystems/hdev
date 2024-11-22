#!/bin/bash

#read parameters
file1=$1
file2=$2

# Remove blank lines from file1 and file2
sed -i '/^\s*$/d' "$file1"
sed -i '/^\s*$/d' "$file2"

# Declare global variables
declare -g equals="1"

# Count the number of lines in each file
lines_file1=$(wc -l < "$file1")
lines_file2=$(wc -l < "$file2")

# Compare the line counts
if [ "$lines_file1" -ne "$lines_file2" ]; then
    equals="0"
else
    while IFS= read -r line; do
        # Check if the line exists in file2
        grep -qF "$line" "$file2"
        if [ $? -ne 0 ]; then
            equals="0"
            break
        fi
    done < "$file1"
fi

#return value
echo "$equals"
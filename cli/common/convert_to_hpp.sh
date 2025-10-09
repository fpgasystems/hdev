#!/bin/bash

# inputs
input_file=$1

# set output file
output_file="$input_file.hpp"

# Create the output file and add header guards
echo "// Auto-generated from $input_file" > "$output_file"
#echo "#pragma once" >> "$output_file"
echo "" >> "$output_file"

# Process each valid assignment line
while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^# ]] && continue

    # Match lines of the form NAME = VALUE;
    if [[ "$line" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)[[:space:]]*=[[:space:]]*([^;]+)\; ]]; then
        var_name="${BASH_REMATCH[1]}"
        var_value="${BASH_REMATCH[2]}"
        echo "const int ${var_name} = ${var_value};" >> "$output_file"
    fi
done < "$input_file"
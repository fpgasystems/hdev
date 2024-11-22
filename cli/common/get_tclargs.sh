#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

device_config=$1

# Initialize an empty string for shell_parameters
shell_parameters=""

# Read each line from the device_config file
while IFS= read -r line; do
  # Skip lines that are empty or start with a comment
  [[ -z "$line" || "$line" =~ ^# ]] && continue
  
  # Extract the variable name and value using parameter expansion
  var_name="${line%%=*}"
  var_value="${line#*=}"

  # Trim whitespace
  var_name=$(echo "$var_name" | xargs)
  var_value=$(echo "$var_value" | xargs)

  # Append to shell_parameters without trailing semicolon
  shell_parameters+="-${var_name} ${var_value} "
done < "$device_config"

# Trim trailing space and remove ;
shell_parameters=$(echo "$shell_parameters" | xargs | tr -d ';')

# Output the result
echo "$shell_parameters"
#!/bin/bash

# Set the constant STRING_LENGTH
STRING_LENGTH=3

# Check if an argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <config_index>"
  exit 1
fi

# Get the config_index from the argument
config_index=$1

# Format the config_index with zero-padding
config_string=$(printf "%0${STRING_LENGTH}d" "$config_index")

# Output the result
echo "$config_string"
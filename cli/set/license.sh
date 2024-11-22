#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

# Check if the user is part of the 'vivado_developers' group
if ! id -nG "$USER" | grep -qw "vivado_developers"; then
    return 1
fi

# Specify list of servers
file_path="$CLI_PATH/constants/XILINXD_LICENSE_FILE"

# Read the lines from the file into an array
mapfile -t lines < "$file_path"

# Join the array elements with ':' to create the desired format
XILINXD_LICENSE_FILE=$(IFS=:; echo "${lines[*]}")

# Set the environment variable
if printenv | grep -q XILINXD_LICENSE_FILE; then
    echo ""
    echo "The ${bold}XILINXD_LICENSE_FILE${normal} is already defined:"
    echo ""
    echo $XILINXD_LICENSE_FILE
    echo ""
else
    export XILINXD_LICENSE_FILE
    echo ""
    echo "The following ${bold}license servers${normal} have been defined:"
    echo ""
    cat $file_path
    echo ""
    echo ""
fi

# Print the result or use it as needed
#export XILINXD_LICENSE_FILE


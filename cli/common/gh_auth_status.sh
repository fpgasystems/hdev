#!/bin/bash

# Declare global variables
declare -g logged_in="0"

# Run gh auth status and capture the output
auth_status=$(gh auth status  2>&1)

#check if the output indicates that you are logged in
if grep -q "✓ Logged in to github.com" <<< "$auth_status"; then
    logged_in="1"  # You are logged in
fi

echo "$logged_in"
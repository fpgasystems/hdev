#!/bin/bash

process_name="$1"

if [[ -z "$process_name" ]]; then
    exit 1
fi

# Define allowed process names
allowed_commands=(
  "sockperf server"
)

# Check if the input matches one of the allowed commands
is_allowed=false
for allowed in "${allowed_commands[@]}"; do
    if [[ "$process_name" == "$allowed" ]]; then
        is_allowed=true
        break
    fi
done

if [[ "$is_allowed" != true ]]; then
    exit 1
fi

if pgrep -f -- "$process_name" > /dev/null; then
    sudo pkill -f -- "$process_name"
fi
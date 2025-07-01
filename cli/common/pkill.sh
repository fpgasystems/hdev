#!/bin/bash

process_name="$1"

if [[ -z "$process_name" ]]; then
    echo "Usage: $0 <process-name>"
    exit 1
fi

if pgrep -f -- "$process_name" > /dev/null; then
    sudo pkill -f -- "$process_name"
fi
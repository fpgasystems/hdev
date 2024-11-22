#!/bin/bash

username=$1

# Check if the user exists
if ! id "$username" &>/dev/null; then
    exit 1
fi

# Check if the user can run a command with sudo
if sudo -u "$USER" -n true &>/dev/null; then
    echo "1"
else
    echo "0"
fi
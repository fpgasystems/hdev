#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1
is_build=$2

if [ "$is_build" = "1" ]; then
    echo ""
    echo "${bold}$CLI_NAME enable vitis [--help]${normal}"
    echo ""
    echo "Enables Vitis SDK (Software Development Kit) and Vitis_HLS (High-Level Synthesis)."
    echo ""
    echo "FLAGS:"
    echo "   This command has no flags."
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
fi
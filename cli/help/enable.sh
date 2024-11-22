#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1
is_build=$2

if [ "$is_build" = "1" ]; then
    echo ""
    echo "${bold}$CLI_NAME enable [arguments [flags]] [--help]${normal}"
    echo ""
    echo "Enables your favorite development and deployment tools on your server."
    echo ""
    echo "ARGUMENTS:"
    echo "   ${bold}vitis${normal}           - Enables Vitis SDK (Software Development Kit) and Vitis_HLS (High-Level Synthesis)."
    echo "   ${bold}vivado${normal}          - Enables Vivado HDI (Hardware Design and Implementation)."
    echo "   ${bold}xrt${normal}             - Enables Xilinx Runtime (XRT)."
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
    exit 1
fi
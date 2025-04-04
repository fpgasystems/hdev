#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
XDP_BPFTOOL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH XDP_BPFTOOL_COMMIT)

#interface=$($CLI_PATH/get/get_nic_config 1 1 DEVICE)
#if [ ! "$interface" = "" ]; then
#    example=" (example: $interface)"
#fi

echo ""
echo "${bold}$CLI_NAME program xdp [flags] [--help]${normal}"
echo ""
echo "Programs your XDP/eBPF application on a given interface."
echo ""
echo "FLAGS:"
echo "   ${bold}-c, --commit${normal}    - GitHub commit ID for bpftool (default: ${bold}$XDP_BPFTOOL_COMMIT${normal})."
#echo "       ${bold}--config${normal}    - Configuration index."
echo "   ${bold}-i, --interface${normal} - Interface name to start your XDP/eBPF program (according to ${bold}$CLI_NAME get interfaces${normal})."
echo "   ${bold}-p, --project${normal}   - Specifies your XDP/eBPF project name."
echo "       ${bold}--start${normal}     - Program name to be started on the interface."
#echo "       ${bold}--stop${normal}      - Detaches an XDP/eBPF program from an interface$example."
echo "       ${bold}--stop${normal}      - Stop an XDP/eBPF program running on the specified interface."
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""
#exit 1
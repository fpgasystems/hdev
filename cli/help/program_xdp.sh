#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
XDP_BPFTOOL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH XDP_BPFTOOL_COMMIT)

echo ""
echo "${bold}$CLI_NAME program xdp [flags] [--help]${normal}"
echo ""
echo "Programs your XDP/eBPF application on a given device."
echo ""
echo "FLAGS:"
echo "   ${bold}-c, --commit${normal}    - GitHub commit ID for bpftool (default: ${bold}$XDP_BPFTOOL_COMMIT${normal})."
#echo "       ${bold}--config${normal}    - Configuration index."
echo "   ${bold}-i, --interface${normal} - Interface name to start your XDP/eBPF program (according to ${bold}$CLI_NAME get interface${normal})."
echo "   ${bold}-p, --project${normal}   - Project name."
echo "       ${bold}--start${normal}     - Program name to be started on the interface."
echo "       ${bold}--stop${normal}      - Interface name stop an XDP/eBPF (according to ${bold}$CLI_NAME get xdp${normal})."
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""
#exit 1
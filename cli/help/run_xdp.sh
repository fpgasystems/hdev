#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
XDP_BPFTOOL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH XDP_BPFTOOL_COMMIT)

echo ""
echo "${bold}$CLI_NAME run xdp [flags] [--help]${normal}"
echo ""
echo "Runs your XDP/eBPF program on a given device."
echo ""
echo "FLAGS:"
echo "   ${bold}-c, --commit${normal}    - GitHub commit ID for bpftool (default: ${bold}$XDP_BPFTOOL_COMMIT${normal})."
#echo "       ${bold}--config${normal}    - Configuration index."
echo "   ${bold}-i, --interface${normal} - Interface name (according to ${bold}$CLI_NAME get xdp${normal})."
echo "   ${bold}-p, --project${normal}   - Specifies your XDP/eBPF project name."
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""
#exit 1
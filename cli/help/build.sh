#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#inputs
CLI_PATH=$1
CLI_NAME=$2
is_acap=$3
is_asoc=$4
is_build=$5
is_fpga=$6
is_gpu=$7
is_nic=$8
is_gpu_developer=$9
is_vivado_developer=${10}
is_network_developer=${11}

#legend
COLOR_ON2=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_XILINX)
COLOR_ON5=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_GPU)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)

#evaluate integrations
gpu_enabled=$([ "$is_gpu_developer" = "1" ] && [ "$is_gpu" = "1" ] && echo 1 || echo 0)
vivado_enabled=$([ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; } && echo 1 || echo 0)
vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)

#print help
echo ""
echo "${bold}$CLI_NAME build [arguments [flags]] [--help]${normal}"
echo ""
echo "Creates binaries, bitstreams, and drivers for your accelerated applications."
echo ""
echo "ARGUMENTS:"
if [ "$is_build" = "1" ] || [ "$vivado_enabled_asoc" = "1" ]; then
    echo -e "   ${bold}${COLOR_ON2}aved${normal}${COLOR_OFF}            - AVED's hardware and software generation."  
fi
echo "   ${bold}c${normal}               - C and C++ binaries."
if [ "$is_build" = "1" ] || [ "$gpu_enabled" = "1" ]; then
    echo -e "   ${bold}${COLOR_ON5}hip${normal}${COLOR_OFF}             - Compiles a HIP project for ROCm GPUs."  
fi
if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "1" ]; then
    echo -e "   ${bold}${COLOR_ON2}opennic${COLOR_OFF}${normal}         - Generates OpenNIC's bitstreams and drivers."
fi
if [ "$is_build" = "1" ] || [ "$vivado_enabled_asoc" = "1" ]; then
    echo -e "   ${bold}${COLOR_ON2}vrt${normal}${COLOR_OFF}             - Builds your Alveo V80 RunTime-based application."  
fi
if [ "$is_nic" = "1" ] && [ "$is_network_developer" = "1" ]; then
    echo -e "   ${bold}xdp${normal}             - eBPF binaries for your Express Data Path (XDP) networking applications."
fi
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""
if [ "$is_build" = "1" ]; then
    $CLI_PATH/common/print_legend "$CLI_PATH" "$CLI_NAME" "0" "0" "1" "1"
else
    $CLI_PATH/common/print_legend "$CLI_PATH" "$CLI_NAME" "0" "0" "$vivado_enabled" "$gpu_enabled"
fi
echo ""
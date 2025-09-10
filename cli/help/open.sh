#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#inputs
CLI_PATH=$1
CLI_NAME=$2
parameter=$3

#legend
COLOR_ON1=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_CPU)
COLOR_ON2=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_XILINX)
COLOR_ON3=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_ACAP)
COLOR_ON4=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_FPGA)
COLOR_ON5=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_GPU)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)

#evaluate integrations
#gpu_enabled=$([ "$is_gpu_developer" = "1" ] && [ "$is_gpu" = "1" ] && echo 1 || echo 0)
#vivado_enabled=$([ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; } && echo 1 || echo 0)
#vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)

if [ "$parameter" = "--help" ]; then
    echo ""
    echo "${bold}$CLI_NAME open [arguments [flags]] [--help]${normal}"
    echo ""
    echo "Opens a windowed application for user interaction."
    echo ""
    echo "ARGUMENTS:"
    echo "   ${bold}vivado${normal}          - Vivado Graphical Unit Interface (GUI)."
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
    #$CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "0" "0" $vivado_enabled $gpu_enabled
    #echo ""
elif [ "$parameter" = "vivado" ]; then
    #if [ "$vivado_enabled" = "1" ]; then
        echo ""
        echo "${bold}$CLI_NAME open vivado [--help]${normal}"
        echo ""
        echo "Vivado Graphical Unit Interface (GUI)."
        echo ""
        echo "FLAGS:"
        echo "   ${bold}-p, --path${normal}      - Full path to the .xpr project file." 
        echo ""
        echo "   ${bold}-h, --help${normal}      - Help to use this command."
        #echo ""
        #$CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "0" "0" "0" "1" "yes"
        echo ""
    #fi
fi
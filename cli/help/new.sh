#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#inputs
CLI_PATH=$1
CLI_NAME=$2
parameter=$3
is_acap=$4
is_asoc=$5
is_build=$6
is_fpga=$7
is_gpu=$8
is_gpu_developer=$9
is_vivado_developer=${10}

#constants
AVED_TAG=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TAG)
ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)
ONIC_DRIVER_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_COMMIT)

#legend
COLOR_ON1=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_CPU)
COLOR_ON2=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_XILINX)
COLOR_ON3=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_ACAP)
COLOR_ON4=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_FPGA)
COLOR_ON5=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_GPU)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)

#evaluate integrations
gpu_enabled=$([ "$is_gpu_developer" = "1" ] && [ "$is_gpu" = "1" ] && echo 1 || echo 0)
vivado_enabled=$([ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; } && echo 1 || echo 0)
vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)

if [ "$is_build" = "1" ] || [ "$gpu_enabled" = "1" ] || [ "$vivado_enabled" = "1" ]; then
    if [ "$parameter" = "--help" ]; then
        echo ""
        echo "${bold}$CLI_NAME new [arguments] [--help]${normal}"
        echo ""
        echo "Creates a new project of your choice."
        echo ""
        echo "ARGUMENTS:"
        if [ "$is_build" = "1" ] || [ "$vivado_enabled_asoc" = "1" ]; then
        echo -e "   ${bold}${COLOR_ON2}aved${COLOR_OFF}${normal}            - Generates an AMD Versal Example Design (AVED) project."
        fi
        if [ "$is_build" = "1" ] || [ "$gpu_enabled" = "1" ]; then
        echo -e "   ${bold}${COLOR_ON5}hip${COLOR_OFF}${normal}             - Portable single-source ROCm applications."
        fi
        if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "1" ]; then
        echo -e "   ${bold}${COLOR_ON2}opennic${COLOR_OFF}${normal}         - Smart Network Interface Card (SmartNIC) applications with OpenNIC."
        fi
        echo ""
        echo "   ${bold}-h, --help${normal}      - Help to use this command."
        echo ""
        $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "0" "0" $vivado_enabled $gpu_enabled
        echo ""
    elif [ "$parameter" = "aved" ]; then
        if [ "$is_build" = "1" ] || [ "$vivado_enabled_asoc" = "1" ]; then
            echo ""
            echo "${bold}$CLI_NAME new aved [flags] [--help]${normal}"
            echo ""
            echo "Generates an AMD Versal Example Design (AVED) project."
            echo ""
            echo "FLAGS:"
            echo "       ${bold}--project${normal}   - Specifies your OpenNIC project name." 
            echo "       ${bold}--push${normal}      - Pushes your OpenNIC project to your GitHub account." 
            echo "   ${bold}-t, --tag${normal}       - GitHub tag ID (default: ${bold}$AVED_TAG${normal})."
            echo ""
            echo "   ${bold}-h, --help${normal}      - Help to use this command."
            echo ""
            $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "1" "1" "1" "0" "yes"
            echo ""
        fi
    elif [ "$parameter" = "hip" ]; then
        if [ "$is_build" = "1" ] || [ "$gpu_enabled" = "1" ]; then
            echo ""
            echo "${bold}$CLI_NAME new hip [--help]${normal}"
            echo ""
            echo "Portable single-source ROCm applications."
            echo ""
            echo "FLAGS"
            echo "   This command has no flags."
            echo ""
            echo "   ${bold}-h, --help${normal}      - Help to use this command."
            echo ""
            $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "0" "0" "0" "1" "yes"
            echo ""
        fi
    elif [ "$parameter" = "opennic" ]; then
        if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "1" ]; then
            echo ""
            echo "${bold}$CLI_NAME new opennic [flags] [--help]${normal}"
            echo ""
            echo "Smart Network Interface Card (SmartNIC) applications with OpenNIC."
            echo ""
            echo "FLAGS:"
            echo "   ${bold}-c, --commit${normal}    - GitHub shell and driver commit IDs (default: ${bold}$ONIC_SHELL_COMMIT,$ONIC_DRIVER_COMMIT${normal})."
            echo "       ${bold}--project${normal}   - Specifies your OpenNIC project name." 
            echo "       ${bold}--push${normal}      - Pushes your OpenNIC project to your GitHub account." 
            echo ""
            echo "   ${bold}-h, --help${normal}      - Help to use this command."
            echo ""
            $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "1" "1" "1" "0" "yes"
            echo ""
        fi
    fi
fi
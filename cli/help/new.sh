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
is_nic=$9
is_gpu_developer=${10}
is_vivado_developer=${11}
is_network_developer=${12}
is_hdev_developer=${13}

#constants
COYOTE_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH COYOTE_COMMIT)
COYOTE_REPO=$($CLI_PATH/common/get_constant $CLI_PATH COYOTE_REPO)
GITHUB_CLI_PATH=$($CLI_PATH/common/get_constant $CLI_PATH GITHUB_CLI_PATH)
ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)
ONIC_DRIVER_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_COMMIT)
VRT_REPO=$($CLI_PATH/common/get_constant $CLI_PATH VRT_REPO)
VRT_TAG=$($CLI_PATH/common/get_constant $CLI_PATH VRT_TAG)
XDP_BPFTOOL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH XDP_BPFTOOL_COMMIT)
XDP_LIBBPF_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH XDP_LIBBPF_COMMIT)

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
nic_enabled=$([ "$is_network_developer" = "1" ] && [ "$is_nic" = "1" ] && echo 1 || echo 0)

if [ "$is_build" = "1" ] || [ "$gpu_enabled" = "1" ] || [ "$vivado_enabled" = "1" ] || [ "$is_network_developer" = "1" ]; then
#if [ ! "$is_build" = "1" ] && ([ "$gpu_enabled" = "1" ] || [ "$vivado_enabled" = "1" ] || [ "$is_network_developer" = "1" ]); then
    if [ "$parameter" = "--help" ]; then
        echo ""
        echo "${bold}$CLI_NAME new [arguments] [--help]${normal}"
        echo ""
        echo "Creates a new project of your choice."
        echo ""
        echo "ARGUMENTS:"
        if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "1" ]; then
        echo -e "   ${bold}${COLOR_ON2}coyote${COLOR_OFF}${normal}          - Create a new application using OS abstractions for FPGA-based devices."
        echo -e "   ${bold}${COLOR_ON2}opennic${COLOR_OFF}${normal}         - Smart Network Interface Card (SmartNIC) applications with OpenNIC."
        fi
        if [ "$is_build" = "1" ] || [ "$gpu_enabled" = "1" ]; then
        echo -e "   ${bold}${COLOR_ON5}tensorflow${COLOR_OFF}${normal}      - Create machine and deep learning learning applications with TensorFlow."
        fi
        if [ "$is_build" = "1" ] || [ "$vivado_enabled_asoc" = "1" ]; then
        echo -e "   ${bold}${COLOR_ON2}vrt${COLOR_OFF}${normal}             - Generates an Alveo V80 RunTime (VRT) project."
        fi
        if [ "$is_build" = "1" ] || [ "$nic_enabled" = "1" ]; then
        echo "   ${bold}xdp${normal}             - Express Data Path (XDP) networking applications with Extended Berkeley Packet Filter (eBPF)."
        fi
        echo ""
        echo "   ${bold}-h, --help${normal}      - Help to use this command."
        echo ""
        if [ "$is_build" = "1" ]; then
            $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "0" "0" "1" "1"
        else
            $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "0" "0" $vivado_enabled $gpu_enabled
        fi
        echo ""
    elif [ "$parameter" = "coyote" ]; then
        if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "1" ]; then
            echo ""
            echo "${bold}$CLI_NAME new coyote [flags] [--help]${normal}"
            echo ""
            echo "Create a new application using OS abstractions for FPGA-based devices."
            echo ""
            echo "FLAGS:"
            echo "   ${bold}-c, --commit${normal}    - GitHub commit ID (default: ${bold}$COYOTE_COMMIT${normal})."
            echo "   ${bold}    --name${normal}      - Device Name (according to ${bold}$CLI_NAME get name${normal})."
            if [ "$is_hdev_developer" = "1" ]; then
            echo "   ${bold}    --number${normal}    - ${bold}$COYOTE_REPO${normal} GitHub repository pull request ID."
            fi
            echo "       ${bold}--project${normal}   - Specifies your Coyote project name." 
            echo "       ${bold}--push${normal}      - Pushes your Coyote project to your GitHub account." 
            echo ""
            echo "   ${bold}    --help${normal}      - Help to use this command."
            echo ""
            $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "1" "1" "1" "0" "yes"
            if [ "$is_hdev_developer" = "1" ]; then
                #echo ""
                #$GITHUB_CLI_PATH/gh pr list --repo $COYOTE_REPO
                $CLI_PATH/common/print_pr "$GITHUB_CLI_PATH" "$COYOTE_REPO"
                #echo ""
            else
                echo ""
            fi
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
            #echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
            echo "       ${bold}--hls${normal}       - Adds an HLS wrapper for user logic boxes."
            echo "   ${bold}-n, --name${normal}      - Device Name (according to ${bold}$CLI_NAME get name${normal})."
            echo "       ${bold}--project${normal}   - Specifies your OpenNIC project name." 
            echo "       ${bold}--push${normal}      - Pushes your OpenNIC project to your GitHub account." 
            echo ""
            echo "   ${bold}    --help${normal}      - Help to use this command."
            echo ""
            $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "1" "1" "1" "0" "yes"
            echo ""
        fi
    elif [ "$parameter" = "tensorflow" ]; then
        if [ "$is_build" = "1" ] || [ "$gpu_enabled" = "1" ]; then
            echo ""
            echo "${bold}$CLI_NAME new tensorflow [--help]${normal}"
            echo ""
            echo "Create machine and deep learning applications with TensorFlow."
            echo ""
            echo "FLAGS:"
            echo "       ${bold}--project${normal}   - Specifies your TensorFlow project name." 
            echo "       ${bold}--push${normal}      - Pushes the project to your GitHub account." 
            echo ""
            echo "   ${bold}-h, --help${normal}      - Help to use this command."
            echo ""
            $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "0" "0" "0" "1" "yes"
            echo ""
        fi
    elif [ "$parameter" = "vrt" ]; then
        if [ "$is_build" = "1" ] || [ "$vivado_enabled_asoc" = "1" ]; then
            echo ""
            echo "${bold}$CLI_NAME new vrt [flags] [--help]${normal}"
            echo ""
            echo "Generates an Alveo V80 RunTime (VRT) project."
            echo ""
            echo "FLAGS:"
            #echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
            echo "   ${bold}-n, --name${normal}      - Device Name (according to ${bold}$CLI_NAME get name${normal})."
            echo "       ${bold}--project${normal}   - Specifies your VRT project name." 
            echo "       ${bold}--push${normal}      - Pushes your VRT project to your GitHub account." 
            echo "       ${bold}--tag${normal}       - GitHub tag ID (default: ${bold}$VRT_TAG${normal})."
            echo "       ${bold}--template${normal}  - ${bold}$VRT_REPO${normal} GitHub repository examples."
            echo ""
            echo "   ${bold}-h, --help${normal}      - Help to use this command."
            echo ""
            $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "1" "1" "1" "0" "yes"
            echo ""
        fi
    elif [ "$parameter" = "xdp" ]; then
        if [ "$is_build" = "1" ] ||  [ "$nic_enabled" = "1" ]; then
            echo ""
            echo "${bold}$CLI_NAME new $parameter [flags] [--help]${normal}"
            echo ""
            echo "Express Data Path (XDP) networking applications with Extended Berkeley Packet Filter (eBPF)."
            echo ""
            echo "FLAGS:"
            echo "   ${bold}-c, --commit${normal}    - bpftool and libbpf commit IDs (default: ${bold}$XDP_BPFTOOL_COMMIT,$XDP_LIBBPF_COMMIT${normal})."
            echo "       ${bold}--project${normal}   - Specifies your XDP/eBPF project name." 
            echo "       ${bold}--push${normal}      - Pushes your XDP/eBPF project to your GitHub account." 
            echo ""
            echo "   ${bold}-h, --help${normal}      - Help to use this command."
            echo ""
            #$CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "1" "1" "1" "0" "yes"
            #echo ""
        fi
    fi
fi
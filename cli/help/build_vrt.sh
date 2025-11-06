#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_PATH=$1
CLI_NAME=$2
is_acap=$3
is_asoc=$4
is_build=$5 
is_fpga=$6
is_vivado_developer=$7

VRT_TAG=$($CLI_PATH/common/get_constant $CLI_PATH VRT_TAG)

#evaluate integrations
#vivado_enabled=$([ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; } && echo 1 || echo 0)
vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)

if [ "$is_build" = "1" ]; then
    targets="${bold}sim_all, emu_all, hw_all${normal}"
elif [ "$is_build" = "0" ]; then    
    targets="${bold}sim_all, emu_all${normal}"
fi

#if [ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_build" = "1" ] || [ "$is_fpga" = "1" ]; }; then
if [ "$is_build" = "1" ] || [ "$vivado_enabled_asoc" = "1" ]; then
    echo ""
    echo "${bold}$CLI_NAME build vrt [flags] [--help]${normal}"
    echo ""
    echo "Generates VRT's bitstreams and drivers."
    echo ""
    echo "FLAGS:"
    echo "       ${bold}--project${normal}   - Specifies your VRT project name."
    echo "   ${bold}    --tag${normal}       - GitHub commit tag (default: ${bold}$VRT_TAG${normal})."
    echo "   ${bold}    --target${normal}    - Hardware build target ($targets)."
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "1" "1" "1" "0" "yes"
    echo ""
fi
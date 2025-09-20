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

COYOTE_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH COYOTE_COMMIT)

#evaluate integrations
vivado_enabled=$([ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; } && echo 1 || echo 0)

#if [ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_build" = "1" ] || [ "$is_fpga" = "1" ]; }; then
if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "1" ]; then
    echo ""
    echo "${bold}$CLI_NAME build coyote [flags] [--help]${normal}"
    echo ""
    echo "Build your accelerated application on top of Coyote shell."
    echo ""
    echo "FLAGS:"
    echo "   ${bold}-c, --commit${normal}    - GitHub commit ID (default: ${bold}$COYOTE_COMMIT${normal})."
    #if [ "$is_build" = "1" ]; then
    #echo "       ${bold}--name${normal}      - Device Name (according to ${bold}$CLI_NAME get name${normal})."
    #fi
    echo "   ${bold}-p, --project${normal}   - Specifies your Coyote project name."
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "1" "1" "1" "0" "yes"
    echo ""
fi
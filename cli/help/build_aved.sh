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

AVED_TAG=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TAG)

#evaluate integrations
vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)

#if [ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_build" = "1" ] || [ "$is_fpga" = "1" ]; }; then
if [ "$is_build" = "1" ] || [ "$vivado_enabled_asoc" = "1" ]; then
    echo ""
    echo "${bold}$CLI_NAME build aved [flags] [--help]${normal}"
    echo ""
    echo "AVED's hardware and software generation."
    echo ""
    echo "FLAGS:"
    echo "   ${bold}-p, --project${normal}   - Specifies your AVED project name."
    echo "   ${bold}-t, --tag${normal}       - GitHub tag ID (default: ${bold}$AVED_TAG${normal})."
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "1" "1" "1" "0" "yes"
    echo ""
fi
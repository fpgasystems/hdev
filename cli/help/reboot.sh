#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1
is_sudo=$2
is_vivado_developer=$3
is_build=$4

if [ "$is_sudo" = "1" ] || ([ "$is_build" = "0" ] && [ "$is_vivado_developer" = "1" ]); then
    echo ""
    echo "${bold}$CLI_NAME reboot [--help]${normal}"
    echo ""
    echo "Reboots the server (warm boot)."
    echo ""
    echo "ARGUMENTS:"
    echo "   This command has no arguments."
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
fi
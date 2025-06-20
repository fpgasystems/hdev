#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1

echo ""
echo "${bold}$CLI_NAME examine [--help]${normal}"
echo ""
echo "System and device information."
echo ""
echo "ARGUMENTS"
echo "   This command has no arguments."
echo ""
echo "   -h, --help      - Help to use this command."
echo ""
exit 1
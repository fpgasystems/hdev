#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1

echo ""
echo "${bold}$CLI_NAME build c [flags] [--help]${normal}"
echo ""
echo "Generates C and C++ binaries."
echo ""
echo "FLAGS:"
echo "   ${bold}-s, --source${normal}    - Full path to the .c or .cpp file to be compiled."
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""
#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

CLI_NAME=$1

echo ""
echo "${bold}$CLI_NAME get topo [flags] [--help]${normal}"
echo ""
echo "Non-uniform memory access (NUMA) server topology."
echo ""
echo "FLAGS:"
echo "   This command has no flags."
echo ""
echo "   ${bold}-h, --help${normal}      - Help to use this command."
echo ""
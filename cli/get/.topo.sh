#!/bin/bash

valid_flags="-h --help"
command_run $command_arguments_flags"@"$valid_flags
#legend
legend="${legend}${bold}${COLOR_ON1}NICs${COLOR_OFF}${normal}"
if [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; then
    legend="${legend} ${bold}${COLOR_ON2}Adaptive Devices${COLOR_OFF}${normal}"
fi
if [ "$is_gpu" = "1" ]; then
    legend="${legend} ${bold}${COLOR_ON5}GPUs${COLOR_OFF}${normal}"
fi
#print legend
if [[ -n "$legend" ]]; then
    echo -e "$legend"
    echo ""
fi
#!/bin/bash

# build ------------------------------------------------------------------------------------------------------------------------

build_help() {
    is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
    is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
    is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
    is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
    is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
    is_nic=$($CLI_PATH/common/is_nic $CLI_PATH $hostname)
    is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
    is_network_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
    $CLI_PATH/help/build $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_build $is_fpga $is_gpu $is_nic $IS_GPU_DEVELOPER $is_vivado_developer $is_network_developer
    exit
}

#build_aved_help() {
#    is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
#    is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
#    is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
#    is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
#    is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
#    $CLI_PATH/help/build_aved $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_build $is_fpga $is_vivado_developer
#    exit
#}

build_c_help() {
    $CLI_PATH/help/build_c $CLI_NAME
    exit
}

build_coyote_help() {
    is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
    is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
    is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
    is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
    is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
    $CLI_PATH/help/build_coyote $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_build $is_fpga $is_vivado_developer
    exit
}

build_opennic_help() {
    is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
    is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
    is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
    is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
    is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
    $CLI_PATH/help/build_opennic $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_build $is_fpga $is_vivado_developer
    exit
}

build_vrt_help() {
    is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
    is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
    is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
    is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
    is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
    $CLI_PATH/help/build_vrt $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_build $is_fpga $is_vivado_developer
    exit
}

build_xdp_help() {
    #is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
    #is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
    #is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
    is_nic=$($CLI_PATH/common/is_nic $CLI_PATH $hostname)
    is_network_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
    $CLI_PATH/help/build_xdp $CLI_PATH $CLI_NAME $is_nic $is_network_developer
    exit
}

# enable ------------------------------------------------------------------------------------------------------------------------

enable_help() {
  $CLI_PATH/help/enable $CLI_NAME $($CLI_PATH/common/is_build $CLI_PATH $hostname)
  exit
}

enable_vitis_help() {
  $CLI_PATH/help/enable_vitis $CLI_NAME $($CLI_PATH/common/is_build $CLI_PATH $hostname)
  exit
}

enable_vivado_help() {    
  $CLI_PATH/help/enable_vivado $CLI_NAME $($CLI_PATH/common/is_build $CLI_PATH $hostname)
  exit
}

enable_xrt_help() {
  $CLI_PATH/help/enable_xrt $CLI_NAME $($CLI_PATH/common/is_build $CLI_PATH $hostname)
  exit
}

# examine ------------------------------------------------------------------------------------------------------------------------

examine_help() {
    $CLI_PATH/help/examine $CLI_NAME
    exit
}

# get ----------------------------------------------------------------------------------------------------------------------------

get_help() {
  is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
  is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
  is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
  is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
  is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
  is_nic=$($CLI_PATH/common/is_nic $CLI_PATH $hostname)
  is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
  is_network_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
  $CLI_PATH/help/get $CLI_PATH $CLI_NAME "--help" $is_acap $is_asoc $is_build $is_fpga $is_gpu $is_nic $is_vivado_developer $is_network_developer
  exit
}

get_bdf_help() {
  is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
  is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
  is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
  $CLI_PATH/help/get $CLI_PATH $CLI_NAME "bdf" $is_acap $is_asoc "-" $is_fpga "-" "-" "-"
  exit
}

get_bus_help() {
  is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
  $CLI_PATH/help/get $CLI_PATH $CLI_NAME "bus" "-" "-" "-" "-" $is_gpu "-" "-" "-"
  exit 
}

get_dmesg_help() {
  is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
  is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
  $CLI_PATH/help/get $CLI_PATH $CLI_NAME "dmesg" "-" "-" $is_build "-" "-" "-" $is_vivado_developer
  exit  
}

#get_clock_help() {
#  is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
#  is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
#  $CLI_PATH/help/get $CLI_PATH $CLI_NAME "clock" $is_acap "-" "-" $is_fpga "-" "-" "-" "-"
#  exit
#}

get_hugepages_help() {
  $CLI_PATH/help/get $CLI_PATH $CLI_NAME "hugepages" "-" "-" $is_build "-" "-" "-" $is_vivado_developer
  exit    
}

get_ifconfig_help() {
  $CLI_PATH/help/get $CLI_PATH $CLI_NAME "ifconfig" "-" "-" "-" "-" "-" "-" "-"
  exit    
}

get_interface_help() {
  is_nic=$($CLI_PATH/common/is_nic $CLI_PATH $hostname)
  is_network_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
  $CLI_PATH/help/get $CLI_PATH $CLI_NAME "interface" "-" "-" "-" "-" "-" $is_nic "-" $is_network_developer
  exit  
}

get_interfaces_help() {
  is_nic=$($CLI_PATH/common/is_nic $CLI_PATH $hostname)
  is_network_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
  $CLI_PATH/help/get $CLI_PATH $CLI_NAME "interfaces" "-" "-" "-" "-" "-" $is_nic "-" $is_network_developer
  exit  
}

#get_memory_help() {
#  is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
#  is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
#  $CLI_PATH/help/get $CLI_PATH $CLI_NAME "memory" $is_acap "-" "-" $is_fpga "-" "-" "-" "-"
#  exit
#}

get_name_help() {
  is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
  is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
  is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
  $CLI_PATH/help/get $CLI_PATH $CLI_NAME "name" $is_acap $is_asoc "-" $is_fpga "-" "-" "-"
  exit  
}

#get_network_help() {
#  is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
#  is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
#  is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
#  if [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; then
#    $CLI_PATH/help/get_network $CLI_PATH $CLI_NAME
#    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
#    echo ""
#  fi
#  exit
#}

get_performance_help() {  
  is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
  $CLI_PATH/help/get $CLI_PATH $CLI_NAME "performance" "-" "-" "-" "-" $is_gpu "-" "-" "-"
  exit
}

get_platform_help() {
  is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
  is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
  $CLI_PATH/help/get $CLI_PATH $CLI_NAME "platform" $is_acap "-" "-" $is_fpga "-" "-" "-" "-"
  exit 
}

#get_resource_help() {
#  is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
#  is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
#  $CLI_PATH/help/get $CLI_PATH $CLI_NAME "resource" $is_acap "-" "-" $is_fpga "-" "-" "-" "-"
#  exit    
#}

get_serial_help() {
  is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
  is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
  is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
  $CLI_PATH/help/get $CLI_PATH $CLI_NAME "serial" $is_acap $is_asoc "-" $is_fpga "-" "-" "-"
  exit  
}

#get_slr_help() {
#  is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
#  is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
#  $CLI_PATH/help/get $CLI_PATH $CLI_NAME "slr" $is_acap "-" "-" $is_fpga "-" "-" "-" "-"
#  exit  
#}

get_syslog_help() {
  is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
  is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
  $CLI_PATH/help/get $CLI_PATH $CLI_NAME "syslog" "-" "-" $is_build "-" "-" "-" $is_vivado_developer
  exit  
}

get_servers_help() {
  $CLI_PATH/help/get $CLI_PATH $CLI_NAME "servers" "-" "-" "-" "-" "-" "-" "-"
  exit
}

get_topo_help() {
  $CLI_PATH/help/get_topo $CLI_NAME
  exit
}

get_uuid_help() {
  is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
  $CLI_PATH/help/get $CLI_PATH $CLI_NAME "uuid" "-" "$is_asoc" "-" "-" "-" "-" "-"
  exit 
}

get_workflow_help() {  
  is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
  is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
  is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
  $CLI_PATH/help/get $CLI_PATH $CLI_NAME "workflow" $is_acap $is_asoc "-" "-" $is_fpga "-" "-" "-"
  exit
}

# new ------------------------------------------------------------------------------------------------------------------------

new_help() {
  is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
  is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
  is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
  is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
  is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
  is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
  is_network_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
  is_hdev_developer=$($CLI_PATH/common/is_member $USER hdev_developers)
  $CLI_PATH/help/new $CLI_PATH $CLI_NAME "--help" $is_acap $is_asoc $is_build $is_fpga $is_gpu $is_nic $IS_GPU_DEVELOPER $is_vivado_developer $is_network_developer $is_hdev_developer
  exit
}

new_coyote_help() {
  is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
  is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
  is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
  is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
  is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
  is_hdev_developer=$($CLI_PATH/common/is_member $USER hdev_developers)
  $CLI_PATH/help/new $CLI_PATH $CLI_NAME "coyote" $is_acap $is_asoc $is_build $is_fpga "0" "0" "0" $is_vivado_developer "0" $is_hdev_developer
  exit
}

new_opennic_help() {
  is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
  is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
  is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
  is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
  is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
  $CLI_PATH/help/new $CLI_PATH $CLI_NAME "opennic" $is_acap $is_asoc $is_build $is_fpga "0" "0" "0" $is_vivado_developer
  exit
}

new_tensorflow_help() {
  is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
  is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
  $CLI_PATH/help/new $CLI_PATH $CLI_NAME "tensorflow" "0" "0" $is_build "0" $is_gpu "0" $IS_GPU_DEVELOPER "0"
  exit
}

new_vrt_help() {
  is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
  is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
  is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
  $CLI_PATH/help/new $CLI_PATH $CLI_NAME "vrt" "0" $is_asoc $is_build "0" "0" "0" "0" $is_vivado_developer "0" $is_hdev_developer
  exit
}

new_xdp_help() {
  #is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
  #is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
  #is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
  #is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
  is_nic=$($CLI_PATH/common/is_nic $CLI_PATH $hostname)
  is_network_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
  $CLI_PATH/help/new $CLI_PATH $CLI_NAME "xdp" "0" "0" "$is_build" "0" "0" $is_nic "0" "0" $is_network_developer
  exit
}

# open ------------------------------------------------------------------------------------------------------------------------

open_help() {
  $CLI_PATH/help/open $CLI_PATH $CLI_NAME "--help"
  exit
}

open_vivado_help() {
  if [ "$is_build" = "0" ] && [ "$vivado_enabled" = "1" ]; then
    $CLI_PATH/help/open $CLI_PATH $CLI_NAME "vivado"
  fi
  exit
}

# program ------------------------------------------------------------------------------------------------------------------------

program_help() {
  #if [ "$vivado_enabled" = "1" ]; then
  if [ ! "$is_build" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; }; then
    echo ""
    echo "${bold}$CLI_NAME program [arguments [flags]] [--help]${normal}"
    echo ""
    echo "Driver and bitstream programming."
    echo ""
    echo "ARGUMENTS:"
    if [ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "0" ]; then
    echo -e "   ${bold}${COLOR_ON2}bitstream${COLOR_OFF}${normal}       - Programs a Vivado bitstream to a given device."
    fi
    if [ "$is_vivado_developer" = "1" ]; then
    echo -e "   ${bold}${COLOR_ON2}coyote${COLOR_OFF}${normal}          - Programs Coyote shell (dynamic and application layers) to a given device."
    fi
    if [ "$is_vivado_developer" = "1" ]; then
    echo "   ${bold}driver${normal}          - Inserts or removes a driver or module into the Linux kernel."
    fi
    if [ "$vivado_enabled_asoc" = "1" ]; then
    echo -e "   ${bold}${COLOR_ON2}image${COLOR_OFF}${normal}           - Programs a Programmable Device Image (PDI) to a given device."
    fi
    if [ "$is_vivado_developer" = "1" ]; then
    echo -e "   ${bold}${COLOR_ON2}opennic${COLOR_OFF}${normal}         - Programs OpenNIC to a given device."
    fi
    if [ ! "$is_asoc" = "1" ]; then
    echo -e "   ${bold}${COLOR_ON2}reset${COLOR_OFF}${normal}           - Performs a 'HOT Reset' on a Vitis device."
    fi
    if [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; then
      echo -e "   ${bold}${COLOR_ON2}revert${COLOR_OFF}${normal}          - Returns a device to its default fabric setup."
    fi
    if [ "$vivado_enabled_asoc" = "1" ]; then
    echo -e "   ${bold}${COLOR_ON2}vrt${COLOR_OFF}${normal}             - Programs a VRT application to a given device."
    fi
    if [ "$is_nic" = "1" ] && [ "$is_network_developer" = "1" ]; then
      echo "   ${bold}xdp${normal}             - Programs your XDP/eBPF program on a given device."
    fi
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0"
    echo ""
  fi
  exit
}

#program_aved_help() {
#  if [ ! "$is_build" = "1" ] && [ "$vivado_enabled_asoc" = "1" ]; then
#    $CLI_PATH/help/program_aved $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga
#    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
#    echo ""
#  fi
#  exit
#}

program_bitstream_help() {
  if [ ! "$is_build" = "1" ] && [ "$vivado_enabled" = "1" ] && [ "$is_asoc" = "0" ]; then
    $CLI_PATH/help/program_bitstream $CLI_NAME $COLOR_ON2 $COLOR_OFF
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
    echo ""
    exit
  fi
}

program_coyote_help() {
  if [ ! "$is_build" = "1" ] && [ "$vivado_enabled" = "1" ]; then
    $CLI_PATH/help/program_coyote $CLI_PATH $CLI_NAME $COLOR_ON2 $COLOR_OFF
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
    echo ""
  fi
  exit
}

program_driver_help() {
  if [ ! "$is_build" = "1" ] && [ "$vivado_enabled" = "1" ]; then
    $CLI_PATH/help/program_driver $CLI_NAME
  fi
  exit
}

program_image_help() {
  if [ ! "$is_build" = "1" ] && [ "$vivado_enabled_asoc" = "1" ]; then
    $CLI_PATH/help/program_image $CLI_NAME
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
    echo ""
  fi
  exit
}

program_opennic_help() {
  if [ ! "$is_build" = "1" ] && [ "$vivado_enabled" = "1" ]; then
    $CLI_PATH/help/program_opennic $CLI_PATH $CLI_NAME $COLOR_ON2 $COLOR_OFF
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
    echo ""
  fi
  exit
}

program_reset_help() {
  if { [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; } && [ ! "$is_asoc" = "1" ]; then
    $CLI_PATH/help/program_reset $CLI_NAME $COLOR_ON2 $COLOR_OFF
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
    echo ""
    exit
  fi
}

program_revert_help() {
  if [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; then
    $CLI_PATH/help/program_revert $CLI_NAME $COLOR_ON2 $COLOR_OFF
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
    echo ""
    exit
  fi
}

program_vivado_help() {
  #if [ ! "$is_build" = "1" ] && [ "$vivado_enabled" = "1" ]; then
  #  $CLI_PATH/help/program_vivado $CLI_NAME $COLOR_ON2 $COLOR_OFF
  #  $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
  #  echo ""
  #  exit
  #fi
  exit
}

program_vrt_help() {
  if [ ! "$is_build" = "1" ] && [ "$vivado_enabled_asoc" = "1" ]; then
    $CLI_PATH/help/program_vrt $CLI_PATH $CLI_NAME
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
    echo ""
  fi
  exit
}

program_xdp_help() {
  if [ "$is_nic" = "1" ] && [ "$is_network_developer" = "1" ]; then
    $CLI_PATH/help/program_xdp $CLI_PATH $CLI_NAME
    #$CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
    #echo ""
  fi
  exit
}

# reboot -------------------------------------------------------------------------------------------------------

reboot_help() {
  is_sudo=$($CLI_PATH/common/is_sudo $USER)
  is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
  is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
  $CLI_PATH/help/reboot $CLI_NAME $is_sudo $is_vivado_developer $is_build
  exit
}

# run ------------------------------------------------------------------------------------------------------------------------

run_help() {
  if [ ! "$is_build" = "1" ] && ([ "$gpu_enabled" = "1" ] || [ "$vivado_enabled" = "1" ]); then
    echo ""
    echo "${bold}$CLI_NAME run [arguments [flags]] [--help]${normal}"
    echo ""
    echo "Executes your accelerated application."
    echo ""
    echo "ARGUMENTS:"
    if [ "$vivado_enabled" = "1" ]; then
      echo -e "   ${bold}${COLOR_ON2}coyote${COLOR_OFF}${normal}          - Runs your Coyote application."
    fi
    if [ "$vivado_enabled" = "1" ]; then
      echo -e "   ${bold}${COLOR_ON2}opennic${COLOR_OFF}${normal}         - Runs your OpenNIC application."
    fi
    echo "   ${bold}sockperf${normal}        - Network performance assessment with sockperf."
    if [ "$gpu_enabled" = "1" ]; then
      echo -e "   ${bold}${COLOR_ON5}tensorflow${COLOR_OFF}${normal}      - Runs your TensorFlow application."
    fi
    if [ "$vivado_enabled_asoc" = "1" ]; then
      echo -e "   ${bold}${COLOR_ON2}vrt${COLOR_OFF}${normal}             - Runs your V80 RunTime (VRT) application."
    fi
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "0" "0" $vivado_enabled $gpu_enabled
    echo ""
  fi  
  exit
}

#run_aved_help() {
#  if [ ! "$is_build" = "1" ] && [ "$vivado_enabled_asoc" = "1" ]; then
#    $CLI_PATH/help/run_aved $CLI_PATH $CLI_NAME
#    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
#    echo ""
#  fi
#  exit
#}

run_coyote_help() {
  if [ ! "$is_build" = "1" ] && [ "$vivado_enabled" = "1" ]; then
    $CLI_PATH/help/run_coyote $CLI_PATH $CLI_NAME
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
    echo ""
  fi
  exit
}

run_opennic_help() {
  if [ ! "$is_build" = "1" ] && [ "$vivado_enabled" = "1" ]; then
    $CLI_PATH/help/run_opennic $CLI_PATH $CLI_NAME
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
    echo ""
  fi
  exit
}

run_sockperf_help() {
  if [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ] || [ "$is_nic" = "1" ]; then
    $CLI_PATH/help/run_sockperf $CLI_PATH $CLI_NAME
    #$CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
    #echo ""
  fi
  exit
}

run_tensorflow_help() {
  if [ ! "$is_build" = "1" ] && [ "$gpu_enabled" = "1" ]; then
    echo ""
    echo "${bold}$CLI_NAME run tensorflow [flags] [--help]${normal}"
    echo ""
    echo "Runs your TensorFlow application."
    echo ""
    echo "FLAGS:"
    echo "   ${bold}-c, --config${normal}    - Configuration Index."
    echo "   ${bold}-p, --project${normal}   - Specifies your TensorFlow project name."
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "0" "0" "0" "1" "yes"
    echo ""
  fi
  exit
}

run_vrt_help() {
  if [ ! "$is_build" = "1" ] && [ "$vivado_enabled" = "1" ]; then
    $CLI_PATH/help/run_vrt $CLI_PATH $CLI_NAME
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $is_acap $is_asoc $is_fpga "0" "yes"
    echo ""
  fi
  exit
}

# set ------------------------------------------------------------------------------------------------------------------------

set_help() {
    #legend
    legend="                     "
    show_nic="0"
    #help
    echo ""
    echo "${bold}$CLI_NAME set [arguments [flags]] [--help]${normal}"
    echo ""
    echo "Devices and host configuration."
    echo ""
    echo "ARGUMENTS:"
    if [ "$is_build" = "0" ] && [ "$is_numa" = "1" ] && [ "$is_vivado_developer" = "1" ]; then
    echo "   ${bold}balancing${normal}       - Enables or disables NUMA (Non-Uniform Memory Access) balancing."
    fi
    echo "   ${bold}gh${normal}              - Enables GitHub CLI on your host (default path: ${bold}$GITHUB_CLI_PATH${normal})."
    if [ ! "$is_build" = "1" ] && [ "$is_vivado_developer" = "1" ]; then
    echo "   ${bold}hugepages${normal}       - Sets the number of 2MB or 1G hugepages."
    fi
    echo "   ${bold}keys${normal}            - Creates your RSA key pairs and adds to authorized_keys and known_hosts."
    if [ "$is_vivado_developer" = "1" ]; then
    echo "   ${bold}license${normal}         - Configures a set of verified license servers for Xilinx tools."
    fi
    if [ ! "$is_build" = "1" ] && [ "$is_vivado_developer" = "1" ]; then
    echo -e "   ${bold}${COLOR_ON1}mtu${COLOR_OFF}${normal}             - Sets a valid MTU value to a device."
    show_nic="1"
    fi
    if [ "$is_gpu" = "1" ]; then
    echo -e "   ${bold}${COLOR_ON5}performance${COLOR_OFF}${normal}     - Change performance level to low, high, or auto."
    fi
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
    if [ "$show_nic" = "1" ]; then
      legend="${legend}${bold}${COLOR_ON1}NICs${COLOR_OFF}${normal}"
    fi
    if [ "$is_gpu" = "1" ]; then
      legend="${legend} ${bold}${COLOR_ON5}GPUs${COLOR_OFF}${normal}"
    fi
    #print legend
    if [[ "$legend" =~ [^[:space:]] ]]; then
      echo -e "$legend"
      echo ""
    fi
    exit 1
}

set_balancing_help() {
  if [ "$is_build" = "0" ] && [ "$is_numa" = "1" ] && [ "$is_vivado_developer" = "1" ]; then
    current_value=$(cat /proc/sys/kernel/numa_balancing)
    echo ""
    echo "${bold}$CLI_NAME set balancing [--help]${normal}"
    echo ""
    echo "Enables or disables NUMA (Non-Uniform Memory Access) balancing."
    echo ""
    echo "FLAGS:"
    if [ "$current_value" = "0" ]; then
      echo "   ${bold}-v, --value${normal}     - When set to one, NUMA balancing is enabled."
    elif [ "$current_value" = "1" ]; then
      echo "   ${bold}-v, --value${normal}     - When set to zero, NUMA balancing is disabled."
    fi
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
  fi
  exit
}

set_gh_help() {
    echo ""
    echo "${bold}$CLI_NAME set gh [--help]${normal}"
    echo ""
    echo "Enables GitHub CLI on your host (default path: ${bold}$GITHUB_CLI_PATH${normal})."
    echo ""
    echo "FLAGS:"
    echo "   This command has no flags."
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
    exit 1
}

set_hugepages_help() {
  if [ ! "$is_build" = "1" ] && [ "$is_vivado_developer" = "1" ]; then
    max_2M=$($CLI_PATH/common/get_max_hugepages "2M")
    max_1G=$($CLI_PATH/common/get_max_hugepages "1G")
    $CLI_PATH/help/set_hugepages $CLI_NAME $max_2M $max_1G
    exit
  fi
}

set_keys_help() {
  $CLI_PATH/help/set_keys $CLI_NAME
  exit
}

set_license_help() {
  if [ "$is_vivado_developer" = "1" ]; then
    echo ""
    echo "${bold}$CLI_NAME set license [--help]${normal}"
    echo ""
    echo "Configures a set of verified license servers for Xilinx tools."
    echo ""
    echo "FLAGS:"
    echo "   This command has no flags."
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
  fi
  exit
}

set_mtu_help() {
  if [ ! "$is_build" = "1" ] && [ "$is_vivado_developer" = "1" ]; then
    echo ""
    echo "${bold}$CLI_NAME set mtu [flags] [--help]${normal}"
    echo ""
    echo "Sets a valid MTU value to a device."
    echo ""
    echo "FLAGS:"
    echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
    echo "   ${bold}-p, --port${normal}      - Specifies the port number for the network adapter."
    echo "   ${bold}-v, --value${normal}     - Maximum Transmission Unit (MTU) value between ${bold}$MTU_MIN${normal} and ${bold}$MTU_MAX${normal} bytes."
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
    echo "                     ${bold}NICs${normal}"
    echo ""
  fi
  exit
}

set_performance_help() {
  if [ "$is_gpu" = "1" ]; then
    echo ""
    echo "${bold}$CLI_NAME set performance [--help]${normal}"
    echo ""
    echo "Change performance level to low, high, or auto."
    echo ""
    echo "FLAGS:"
    echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
    echo "   ${bold}-v, --value${normal}     - Low, high, or auto (as seen in ${bold}$CLI_NAME get performance${normal})."
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "0" "0" "0" "1" "yes"
    echo ""
  fi
  exit
}

# update ------------------------------------------------------------------------------------------------------------------------

update_help() {
  if [ "$is_sudo" = "1" ]; then
    #get latest tag
    latest_tag=$(gh release list -R "$HDEV_REPO" --limit 1 --json tagName --jq '.[0].tagName')
    echo ""
    echo "${bold}$CLI_NAME update [flags] [--latest --help]${normal}"
    echo ""
    echo "Updates ${bold}$CLI_NAME${normal} to a specific version."
    echo ""
    echo "FLAGS:"
    echo "   ${bold}    --latest${normal}    - Updates ${bold}$CLI_NAME${normal} to its latest version (tag ID: ${bold}$latest_tag${normal})."
    echo "   ${bold}-n, --number${normal}    - ${bold}$HDEV_REPO${normal} GitHub repository pull request ID."
    echo "   ${bold}-t, --tag${normal}       - GitHub tag ID."
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    #echo ""
    #$GITHUB_CLI_PATH/gh pr list --repo $HDEV_REPO
    #echo ""
    #if [ "$is_sudo" = "1" ]; then
      $CLI_PATH/common/print_pr "$GITHUB_CLI_PATH" "$HDEV_REPO"
    #else
    #  echo ""
    #fi
  fi
  exit
}

# validate -----------------------------------------------------------------------------------------------------------------------

validate_help() {
    vitis_enabled="0"
    echo ""
    echo "${bold}$CLI_NAME validate [arguments [flags]] [--help]${normal}"
    echo ""
    echo "Infrastructure functionality assessment."
    echo ""
    echo "ARGUMENTS:"
    if [ "$vivado_enabled_asoc" = "1" ]; then
    echo -e "   ${bold}${COLOR_ON2}aved${COLOR_OFF}${normal}            - Pre-built Alveo Versal Example Design (AVED) validation."
    fi
    echo "   ${bold}docker${normal}          - Validates Docker installation on the server."
    if [ ! "$is_build" = "1" ] && [ "$vivado_enabled" = "1" ]; then
    echo -e "   ${bold}${COLOR_ON2}opennic${COLOR_OFF}${normal}         - Validates OpenNIC on the selected device."
    fi
    if [ ! "$is_build" = "1" ] && [ "$gpu_enabled" = "1" ]; then
    echo -e "   ${bold}${COLOR_ON5}tensorflow${COLOR_OFF}${normal}      - Validates TensorFlow on the selected device." 
    fi
    if [ ! "$is_build" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; }; then
    echo -e "   ${bold}${COLOR_ON2}vitis${COLOR_OFF}${normal}           - Validates Vitis workflow on the selected device."
    vitis_enabled="1"
    fi
    if [ ! "$is_build" = "1" ] && [ "$vivado_enabled_asoc" = "1" ]; then
    echo -e "   ${bold}${COLOR_ON2}vrt${COLOR_OFF}${normal}             - Validates V80 RunTime (V80) on the selected device."
    fi
    echo "" 
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    if [ ! "$is_build" = "1" ]; then
    echo ""
    fi
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME $vitis_enabled "0" $vivado_enabled $gpu_enabled
    echo ""
    exit
}

validate_aved_help() {
  if [ ! "$is_build" = "1" ] && [ "$vivado_enabled_asoc" = "1" ]; then
    echo ""
    echo "${bold}$CLI_NAME validate aved [flags] [--help]${normal}"
    echo ""
    echo "Pre-built Alveo Versal Example Design (AVED) validation."
    echo ""
    echo "FLAGS:"
    echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "0" "0" "1" "0" "yes"
    echo ""
  fi
  exit
}

validate_docker_help() {
  echo ""
  echo "${bold}$CLI_NAME validate docker [--help]${normal}"
  echo ""
  echo "Validates Docker installation on the server."
  echo ""
  echo "FLAGS:"
  echo "   This command has no flags."
  echo ""
  echo "   ${bold}-h, --help${normal}      - Help to use this command."
  echo ""
  exit 1
}

validate_opennic_help() {
  if [ ! "$is_build" = "1" ] && [ "$vivado_enabled" = "1" ]; then
    $CLI_PATH/help/validate_opennic $CLI_PATH $CLI_NAME
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "0" "0" "1" "0" "yes"
    echo ""
  fi
  exit
}

validate_tensorflow_help() {
  if [ ! "$is_build" = "1" ] && [ "$gpu_enabled" = "1" ]; then
    echo ""
    echo "${bold}$CLI_NAME validate tensorflow [flags] [--help]${normal}"
    echo ""
    echo "Validates TensorFlow on the selected device."
    echo ""
    echo "FLAGS:"
    echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use this command."
    echo ""
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "0" "0" "0" "1" "yes"
    echo ""
  fi
  exit
}

validate_vitis_help() {
  if [ ! "$is_build" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; }; then
    echo ""
    echo "${bold}$CLI_NAME validate vitis [flags] [--help]${normal}"
    echo ""
    echo "Validates Vitis workflow on the selected device."
    echo ""
    echo "FLAGS:"
    echo "   ${bold}-d, --device${normal}    - Device Index (according to ${bold}$CLI_NAME examine${normal})."
    echo ""
    echo "   ${bold}-h, --help${normal}      - Help to use Vitis validation."
    echo ""
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "0" "0" "1" "0" "yes"
    echo ""
  fi
  exit
}

validate_vrt_help() {
  if [ ! "$is_build" = "1" ] && [ "$vivado_enabled_asoc" = "1" ]; then
    $CLI_PATH/help/validate_vrt $CLI_PATH $CLI_NAME
    $CLI_PATH/common/print_legend $CLI_PATH $CLI_NAME "0" "0" "1" "0" "yes"
    if [ "$is_hdev_developer" = "1" ]; then
      $CLI_PATH/common/print_pr "$GITHUB_CLI_PATH" "$VRT_REPO"
    else
      echo ""
    fi
  fi
  exit
}
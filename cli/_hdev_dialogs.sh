#!/bin/bash

#dialog messages
CHECK_ON_CONFIG_MSG="${bold}Please, choose your configuration:${normal}"
CHECK_ON_DEVICE_MSG="${bold}Please, choose your device:${normal}"
CHECK_ON_NEW_MSG="${bold}Please, type a non-existing name for your project:${normal}"
CHECK_ON_IFACE_MSG="${bold}Please, choose your interface:${normal}"
CHECK_ON_PLATFORM_MSG="${bold}Please, choose your platform:${normal}"
CHECK_ON_PROJECT_MSG="${bold}Please, choose your project:${normal}"
CHECK_ON_PUSH_MSG="${bold}Would you like to add the project to your GitHub account (y/n)?${normal}"
CHECK_ON_REMOTE_MSG="${bold}Please, choose your deployment servers:${normal}"
CHECK_ON_TARGET_MSG="${bold}Please, choose your target:${normal}"
CHECK_ON_TEMPLATE_MSG="${bold}Please, choose your template:${normal}"

#error messages
CHECK_ON_AMI_TOOL_ERR_MSG="Please, install a valid ami_tool version."
CHECK_ON_BOOT_TYPE_ERR_MSG="Please, choose a valid boot type option."
CHECK_ON_BITSTREAM_ERR_MSG="Your targeted bitstream is missing."
CHECK_ON_COMMIT_ERR_MSG="Please, choose a valid commit ID."
CHECK_ON_CONFIG_ERR_MSG="Please, choose a valid configuration index."
CHECK_ON_DEVICE_ERR_MSG="Please, choose a valid device index."
CHECK_ON_DRIVER_ERR_MSG="Please, choose a valid driver name."
CHECK_ON_DRIVER_PARAMS_ERR_MSG="Please, choose a valid list of module parameters." 
CHECK_ON_FEC_ERR_MSG="Please, choose a valid FEC option."
CHECK_ON_GH_ERR_MSG="Please, use ${bold}$CLI_NAME set gh${normal} to log in to your GitHub account."
CHECK_ON_GH_TAG_ERR_MSG="Please, choose a valid tag ID."
CHECK_ON_HOSTNAME_ERR_MSG="Sorry, this command is not available on ${bold}$hostname.${normal}"
CHECK_ON_HOTPLUG_ERR_MSG="Please, choose a valid hotplug option."
CHECK_ON_IFACE_ERR_MSG="Please, choose a valid interface name."
CHECK_ON_IP_ERR_MSG="Please, choose a valid IP address."
CHECK_ON_IMAGE_ERR_MSG="Your targeted image is missing."
CHECK_ON_VALUE_ERR_MSG="Please, choose a valid value."
CHECK_ON_PLATFORM_ERR_MSG="Please, choose a valid platform name."
CHECK_ON_PARTITION_ERR_MSG="Please, choose a valid partition index."
CHECK_ON_PERFORMANCE_ERR_MSG="Please, choose a valid performance value."
CHECK_ON_PORT_ERR_MSG="Please, choose a valid port index."
CHECK_ON_PR_ERR_MSG="Please, choose a valid pull request ID."
CHECK_ON_PROJECT_ERR_MSG="Please, choose a valid project name."
CHECK_ON_PROJECT_EMPTY_ERR_MSG="Please, create a project first."
CHECK_ON_PUSH_ERR_MSG="Please, choose a valid push option."
CHECK_ON_REMOTE_ERR_MSG="Please, choose a valid deploy option."
CHECK_ON_REMOTE_FILE_ERR_MSG="Please, specify an absolute path for remote programming."
CHECK_ON_REVERT_ERR_MSG="Please, revert your device first."
CHECK_ON_SERVER_ERR_MSG="Please, choose a valid server name."
CHECK_ON_SHELL_CFG_ERR_MSG="Your targeted shell configuration file is missing."
CHECK_ON_SOCKPERF_SERVER_ERR_MSG="Please, start your sockperf server first."
CHECK_ON_SUDO_ERR_MSG="Sorry, this command requires sudo capabilities."
CHECK_ON_TARGET_ERR_MSG="Please, choose a valid target name."
CHECK_ON_TARGET_BUILD_ERR_MSG="Please, build your target first."
CHECK_ON_TEMPLATE_ERR_MSG="Please, choose a valid template name."
CHECK_ON_VIVADO_ERR_MSG="Please, choose a valid Vivado version."
CHECK_ON_VIVADO_DEVELOPERS_ERR_MSG="Sorry, this command is not available for ${bold}$USER.${normal}."
CHECK_ON_WORKFLOW_ERR_MSG="Please, program your device(s) first."
CHECK_ON_X11_ERR_MSG="Please, login with ssh -X (or -Y) to enable X11 forwarding."
CHECK_ON_XPR_FILE_ERR_MSG="Please, choose a valid xpr project file."
CHECK_ON_XRT_ERR_MSG="Please, choose a valid XRT version."
CHECK_ON_XRT_SHELL_ERR_MSG="Sorry, this command is only available for XRT shells."

ami_check() {
  local AMI_TOOL_PATH=$1
  ami_tool_path=$(which ami_tool)
  if [[ "$ami_tool_path" = "" || "$ami_tool_path" != "$AMI_TOOL_PATH" ]]; then
    echo ""
    echo $CHECK_ON_AMI_TOOL_ERR_MSG
    echo ""
    exit 1
  fi
}

boot_type_check() {
  local CLI_PATH=$1
  shift 1
  local flags_array=("$@")
  result="$("$CLI_PATH/common/boot_type_check" "${flags_array[@]}")"
  boot_type_found=$(echo "$result" | sed -n '1p')
  boot_type=$(echo "$result" | sed -n '2p')
  #forbidden combinations
  if [ "$boot_type_found" = "1" ] && { [ "$boot_type" = "" ] || ([ "$boot_type" != "primary" ] && [ "$boot_type" != "secondary" ]); }; then
    echo ""
    echo "$CHECK_ON_BOOT_TYPE_ERR_MSG"
    echo ""
    exit
  fi
}

commit_dialog() {
  local CLI_PATH=$1
  local CLI_NAME=$2
  local MY_PROJECTS_PATH=$3
  local command=$4 #program
  local WORKFLOW=$5 #arguments and workflow are the same (i.e. opennic)
  local GITHUB_CLI_PATH=$6
  local REPO_ADDRESS=$7
  local DEFAULT_COMMIT=$8
  shift 8
  local flags_array=("$@")
  
  commit_found=""
  commit_name=""
  if [ "$flags_array" = "" ]; then
    #check on PWD
    project_path=$(dirname "$PWD")
    commit_name=$(basename "$project_path")
    project_found="0"
    if [ "$project_path" = "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name" ]; then 
        commit_found="1"
        project_found="1"
        project_name=$(basename "$PWD")
    elif [ "$commit_name" = "$WORKFLOW" ]; then
        commit_found="1"
        commit_name="${PWD##*/}"
    else
        commit_found="1"
        commit_name=$DEFAULT_COMMIT
    fi
  else
    commit_check "$CLI_PATH" "$CLI_NAME" "$command" "$WORKFLOW" "$GITHUB_CLI_PATH" "$REPO_ADDRESS" "$DEFAULT_COMMIT" "${flags_array[@]}"
  fi
}

commit_check() {
  local CLI_PATH=$1
  local CLI_NAME=$2
  local command=$3 #program
  local WORKFLOW=$4 #arguments and workflow are the same (i.e. opennic)
  local GITHUB_CLI_PATH=$5
  local REPO_ADDRESS=$6
  local DEFAULT_COMMIT=$7
  shift 7
  local flags_array=("$@")
  #commit_dialog_check
  result="$("$CLI_PATH/common/commit_dialog_check" "${flags_array[@]}")"
  commit_found=$(echo "$result" | sed -n '1p')
  commit_name=$(echo "$result" | sed -n '2p')
  #check if commit exists
  exists=$($CLI_PATH/common/gh_commit_check $GITHUB_CLI_PATH $REPO_ADDRESS $commit_name)
  #forbidden combinations
  if [ "$commit_found" = "0" ]; then 
    commit_found="1"
    commit_name=$DEFAULT_COMMIT
  elif [ "$commit_found" = "1" ] && ([ "$commit_name" = "" ] || [ "$exists" = "0" ]); then 
      echo ""
      echo $CHECK_ON_COMMIT_ERR_MSG
      echo ""
      exit 1
  fi
}

commit_check_pwd(){
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  local WORKFLOW=$3
  local commit_name_local=$4

  #evaluate current directory (2) /home/jmoyapaya/my_projects/opennic/940907f
  if [ -f "$PWD/$commit_name_local" ]; then
    #declare -g project_found="1"
    #declare -g project_name=$(basename "$PWD")
    declare -g commit_found="1"
    declare -g commit_name=$(cat "$PWD/$commit_name_local")
    return 1
  fi
}

config_dialog() {
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  local WORKFLOW=$3
  local commit_name=$4
  local project_name=$5
  #local file_name=$6
  local config_prefix=$6
  local add_echo=$7
  shift 7
  local flags_array=("$@")

  config_found=""
  config_name=""
  config_index=""
  
  if [ "$flags_array" = "" ]; then
    #config_dialog
    echo $CHECK_ON_CONFIG_MSG
    echo ""
    result=$($CLI_PATH/common/config_dialog $MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name)
    config_found=$(echo "$result" | sed -n '1p')
    config_name=$(echo "$result" | sed -n '2p')
    multiple_configs=$(echo "$result" | sed -n '3p')
    config_index=$(echo "$result" | sed -n '5p')
    #check on config_name
    if [[ $config_name = "" ]]; then
        echo ""
        echo $CHECK_ON_CONFIG_ERR_MSG
        echo ""
        exit 1
    elif [[ $multiple_configs = "0" ]]; then
        echo $config_name
        #set config_index
        config_index="1"
        #echo ""
    fi
    echo ""
  else
    config_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$WORKFLOW" "$commit_name" "$project_name" "$config_prefix" "$add_echo" "${flags_array[@]}"
    #forgotten mandatory
    if [[ $config_found = "0" ]]; then
        #echo ""
        echo $CHECK_ON_CONFIG_MSG
        echo ""
        result=$($CLI_PATH/common/config_dialog $MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name)
        config_found=$(echo "$result" | sed -n '1p')
        config_name=$(echo "$result" | sed -n '2p')
        multiple_configs=$(echo "$result" | sed -n '3p')
        config_index=$(echo "$result" | sed -n '5p')
        if [[ $multiple_configs = "0" ]]; then
            echo $config_name
            #set config_index
            config_index="1"
        fi
        echo ""
    fi
  fi
}

config_check() {
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  local commit_name=$4
  local project_name=$5
  local config_prefix=$6
  local add_echo=$7
  shift 7
  local flags_array=("$@")
  result="$("$CLI_PATH/common/config_dialog_check" "${flags_array[@]}")"
  config_found=$(echo "$result" | sed -n '1p')
  config_index=$(echo "$result" | sed -n '2p')
  #config_name=$(echo "$result" | sed -n '3p')

  #get config name (we use the config_prefix as a parameter)
  config_string=$($CLI_PATH/common/get_config_string $config_index)
  config_name="$config_prefix$config_string"

  #forbidden combinations
  if [ "$project_name" = "" ]; then
      echo ""
      echo $CHECK_ON_PROJECT_ERR_MSG
      echo ""
      exit 1
  elif [ "$config_found" = "1" ] && ([ "$config_index" = "" ] || [ "$config_index" = "0" ] || [ ! -e "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name/configs/$config_name" ]); then #implies that --project must be specified
      if [ "$add_echo" = "yes" ]; then
        echo ""
      fi
      echo $CHECK_ON_CONFIG_ERR_MSG
      echo ""
      exit 1
  fi
}

build_check() {
  local CLI_PATH=$1
  local hostname=$2
  is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
  if [ "$is_build" = "0" ]; then
      echo ""
      echo $CHECK_ON_HOSTNAME_ERR_MSG
      echo ""
      exit 1
  fi
}

device_dialog() {
  local CLI_PATH=$1
  local CLI_NAME=$2
  local command=$3
  local arguments=$4
  local multiple_devices=$5
  local MAX_DEVICES=$6
  shift 6
  local flags_array=("$@")
  
  device_found=""
  device_index=""

  if [[ $multiple_devices = "0" ]]; then
    device_found="1"
    device_index="1"
  else
    if [ "$flags_array" = "" ]; then
      #device_dialog
      echo $CHECK_ON_DEVICE_MSG
      echo ""
      result=$($CLI_PATH/common/device_dialog $CLI_PATH $MAX_DEVICES $multiple_devices)
      device_found=$(echo "$result" | sed -n '1p')
      device_index=$(echo "$result" | sed -n '2p')
      echo ""
    else
      #forgotten mandatory
      device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
      if [[ $device_found = "0" ]]; then
        echo $CHECK_ON_DEVICE_MSG
        echo ""
        result=$($CLI_PATH/common/device_dialog $CLI_PATH $MAX_DEVICES $multiple_devices)
        device_found=$(echo "$result" | sed -n '1p')
        device_index=$(echo "$result" | sed -n '2p')
        echo ""
      fi
    fi
  fi
}

device_check() {
  local CLI_PATH=$1
  local CLI_NAME=$2
  local command=$3
  local arguments=$4
  local multiple_devices=$5
  local MAX_DEVICES=$6
  shift 6
  local flags_array=("$@")
  result="$("$CLI_PATH/common/device_dialog_check" "${flags_array[@]}")"
  device_found=$(echo "$result" | sed -n '1p')
  device_index=$(echo "$result" | sed -n '2p')
  #forbidden combinations
  if ([ "$device_found" = "1" ] && [ "$device_index" = "" ]) || 
     ([ "$device_found" = "1" ] && [ "$multiple_devices" = "0" ] && ! [[ "$device_index" =~ ^[0-9]+$ ]]) || 
     ([ "$device_found" = "1" ] && (! [[ "$device_index" =~ ^[0-9]+$ ]] || [[ "$device_index" -gt "$MAX_DEVICES" ]] || [[ "$device_index" -lt 1 ]])); then
       echo ""
       echo "$CHECK_ON_DEVICE_ERR_MSG"
       echo ""
       exit
  fi
}

driver_check() {
  local CLI_PATH=$1
  shift 1
  local flags_array=("$@")
  
  #driver_dialog_check
  result="$("$CLI_PATH/common/driver_dialog_check" "${flags_array[@]}")"
  driver_found=$(echo "$result" | sed -n '1p')
  driver_name=$(echo "$result" | sed -n '2p') 

  #forbidden combinations (1)
  if [ "$driver_found" = "0" ]; then
      program_driver_help
  fi

  #forbidden combinations (2 - if -r or --remove are present no other flags are allowed)
  remove_flag_found="0"

  for flag in "${flags_array[@]}"; do
    if [[ "$flag" == "-r" || "$flag" == "--remove" ]]; then
      remove_flag_found="1"
      break
    fi
  done

  if [ "$remove_flag_found" = "1" ]; then
    for flag in "${flags_array[@]}"; do
      if [[ "$flag" != "-r" && "$flag" != "--remove" && "$flag" == -* ]]; then
        program_driver_help
      fi
    done

    #get actual filename (i.e. onik.ko without the path)
    driver_name_base=$(basename "$driver_name")

    #forbidden combinations (3)
    if [ "$driver_found" = "1" ] && ([ "$driver_name_base" = "" ] || ! (lsmod | grep -q "${driver_name_base%.ko}" 2>/dev/null)); then
        echo ""
        echo $CHECK_ON_DRIVER_ERR_MSG
        echo ""
        exit 1
    fi
  else
    #forbidden combinations (3)
    if [ "$driver_found" = "1" ] && ([ "$driver_name" = "" ] || [ ! -f "$driver_name" ] || [ "${driver_name##*.}" != "ko" ]); then
        echo ""
        echo $CHECK_ON_DRIVER_ERR_MSG
        echo ""
        exit 1
    fi
    #params_dialog_check
    result="$("$CLI_PATH/common/params_dialog_check" "${flags_array[@]}")"
    params_found=$(echo "$result" | sed -n '1p')
    params_string=$(echo "$result" | sed -n '2p')

    #define the expected pattern for driver parameters
    pattern='^[^=,]+=[^=,]+(,[^=,]+=[^=,]+)*$' 

    #forbidden combinations (4)
    if [ "$params_found" = "1" ] && ([ "$params_string" = "" ] || ! [[ $params_string =~ $pattern ]]); then
        echo ""
        echo $CHECK_ON_DRIVER_PARAMS_ERR_MSG
        echo ""
        exit 1
    fi
  fi
}

fec_check() {
  local CLI_PATH=$1
  shift 1
  local flags_array=("$@")
  result="$("$CLI_PATH/common/fec_dialog_check" "${flags_array[@]}")"
  fec_option_found=$(echo "$result" | sed -n '1p')
  fec_option=$(echo "$result" | sed -n '2p')
  #forbidden combinations
  if [ "$fec_option_found" = "1" ] && { [ "$fec_option" -ne 0 ] && [ "$fec_option" -ne 1 ]; }; then
      echo ""
      echo $CHECK_ON_FEC_ERR_MSG
      echo ""
      exit 1
  fi
}

flags_check() {
    # we use an @ to separate between command_arguments_flags and the valid_flags
    read input <<< $@
    aux_1="${input%%@*}"
    aux_2="${input##$aux_1@}"

    read -a command_arguments_flags <<< "$aux_1"
    read -a valid_flags <<< "$aux_2"

    START=2
    if [ "${command_arguments_flags[$START]}" = "-h" ] || [ "${command_arguments_flags[$START]}" = "--help" ]; then
      ${command_arguments_flags[0]}_${command_arguments_flags[1]}_help # i.e., validate_iperf_help
    else
      flags=""
      j=0
      for (( i=$START; i<${#command_arguments_flags[@]}; i++ ))
      do
	      if [[ " ${valid_flags[*]} " =~ " ${command_arguments_flags[$i]} " ]]; then
	        flags+="${command_arguments_flags[$i]} "
	        i=$(($i+1))
	        flags+="${command_arguments_flags[$i]} "
	      else
          ${command_arguments_flags[0]}_${command_arguments_flags[1]}_help # i.e., validate_iperf_help
          #echo "-1"
          #break
	      fi
      done
    fi
}

fpga_check() {
  local CLI_PATH=$1
  local hostname=$2
  acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
  fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
  if [ "$acap" = "0" ] && [ "$asoc" = "0" ] && [ "$fpga" = "0" ]; then
      echo ""
      echo $CHECK_ON_HOSTNAME_ERR_MSG
      echo ""
      exit 1
  fi
}

gh_check() {
  local CLI_PATH=$1
  logged_in=$($CLI_PATH/common/gh_auth_status)
  if [ "$logged_in" = "0" ]; then 
    echo ""
    echo $CHECK_ON_GH_ERR_MSG
    echo ""
    exit 1
  fi
}

gpu_check() {
  local CLI_PATH=$1
  local hostname=$2
  gpu_server=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
  if [ "$gpu_server" = "0" ]; then
      echo ""
      echo $CHECK_ON_HOSTNAME_ERR_MSG
      echo ""
      exit 1
  fi
}

iface_dialog() {
  local CLI_PATH=$1
  local CLI_NAME=$2
  #local MAX_DEVICES_NIC=$3
  #local MAX_DEVICES_FPGA=$4
  #local multiple_devices=$3
  #local MAX_DEVICES=$4
  shift 2
  local flags_array=("$@")
  
  #get interfaces
  interfaces=($($CLI_PATH/common/get_interfaces $CLI_PATH))
  
  interface_found=""
  interface_name=""

  if [[ ${#interfaces[@]} -eq 1 ]]; then
    echo $CHECK_ON_IFACE_MSG
    echo ""
    sleep 1
    interface_found="1"
    interface_name=${interfaces[0]}
    echo "$interface_name"
    echo ""
    sleep 2
  else
    if [ "$flags_array" = "" ]; then
      #interface_dialog
      echo $CHECK_ON_IFACE_MSG
      echo ""
      for i in "${!interfaces[@]}"; do
        echo "$((i + 1))) ${interfaces[i]}"
      done

      while true; do
        read -p "" choice
        # Validate the input
        if [[ $choice =~ ^[1-9][0-9]*$ ]] && ((choice >= 1 && choice <= ${#interfaces[@]})); then
            interface_found="1"
            interface_name=${interfaces[choice-1]}
            break
        fi
      done
      echo ""
    else
      #forgotten mandatory
      #device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
      iface_dialog "$CLI_PATH" "$CLI_NAME" "${flags_array[@]}"
      if [[ $interface_found = "0" ]]; then
        #interface_dialog
        echo $CHECK_ON_IFACE_MSG
        echo ""
        for i in "${!interfaces[@]}"; do
          echo "$((i + 1))) ${interfaces[i]}"
        done

        while true; do
          read -p "" choice
          # Validate the input
          if [[ $choice =~ ^[1-9][0-9]*$ ]] && ((choice >= 1 && choice <= ${#interfaces[@]})); then
              interface_found="1"
              interface_name=${interfaces[choice-1]}
              break
          fi
        done
        echo ""
      fi
    fi
  fi
}

iface_check() {
  local CLI_PATH=$1
  #local VALUE_MIN=$2
  #local VALUE_MAX=$3
  #local arguments=$4
  #local multiple_devices=$5
  #local MAX_DEVICES=$6
  shift 1
  local flags_array=("$@")
  result="$("$CLI_PATH/common/iface_dialog_check" "${flags_array[@]}")"
  interface_found=$(echo "$result" | sed -n '1p')
  interface_name=$(echo "$result" | sed -n '2p')
  #forbidden combinations
  if [ "$interface_found" = "1" ] && [ "$interface_name" = "" ]; then #[ "$interface_found" = "0" ] || 
      echo ""
      echo $CHECK_ON_IFACE_ERR_MSG
      echo ""
      exit
  fi
  #check if the interface is not present in the ifconfig output
  if ! ifconfig | grep -q "^${interface_name}"; then
      echo ""
      echo $CHECK_ON_IFACE_ERR_MSG
      echo ""
      exit
  fi
}

ipv4_check() {
    local ip=$1

    # Basic format check: 4 numbers separated by dots
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        # Check each octet is <= 255
        IFS='.' read -r o1 o2 o3 o4 <<< "$ip"
        for octet in $o1 $o2 $o3 $o4; do
            if ((octet < 0 || octet > 255)); then
                return 1
            fi
        done
        return 0
    else
        return 1
    fi
}

new_dialog() {
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  local commit_name=$4 #arguments and workflow are the same (i.e. opennic)
  shift 4
  local flags_array=("$@")

  new_found=""
  new_name=""

  if [ "$flags_array" = "" ]; then
    #new_dialog
    echo $CHECK_ON_NEW_MSG
    echo ""
    result=$($CLI_PATH/common/new_dialog $MY_PROJECTS_PATH $WORKFLOW $commit_name)
    new_found=$(echo "$result" | sed -n '1p')
    new_name=$(echo "$result" | sed -n '2p')
    echo ""
  else
    new_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$WORKFLOW" "$commit_name" "${flags_array[@]}"
    #forgotten mandatory
    if [[ $new_found = "0" ]]; then
        echo $CHECK_ON_NEW_MSG
        echo ""
        result=$($CLI_PATH/common/new_dialog $MY_PROJECTS_PATH $WORKFLOW $commit_name)
        new_found=$(echo "$result" | sed -n '1p')
        new_name=$(echo "$result" | sed -n '2p')
        echo ""
    fi
  fi
}

new_check(){
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  local commit_name=$4 #arguments and workflow are the same (i.e. opennic)
  shift 4
  local flags_array=("$@")
  #new_dialog_check
  result="$("$CLI_PATH/common/new_dialog_check" "${flags_array[@]}")"
  new_found=$(echo "$result" | sed -n '1p')
  new_name=$(echo "$result" | sed -n '2p')
  #forbidden combinations
  if [ "$new_found" = "1" ] && ([ "$new_name" = "" ] || [ -d "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$new_name" ]); then 
      echo ""
      echo $CHECK_ON_PROJECT_ERR_MSG
      echo ""
      exit 1
  fi
}

#partition_check() {
#  local CLI_PATH=$1
#  local device_index=$2
#  shift 2
#  local flags_array=("$@")
#  result="$("$CLI_PATH/common/partition_dialog_check" "${flags_array[@]}")"
#  partition_found=$(echo "$result" | sed -n '1p')
#  partition_index=$(echo "$result" | sed -n '2p')
#  #get partitions
#  MAX_PARTITIONS=$($CLI_PATH/get/partitions --device $device_index --type $AVED_PARTITION_TYPE | sed -n 's/.*\([0-9]\)]/\1/p')
#  if [ "$partition_found" = "0" ]; then
#    partition_found="1"
#    partition_index="1"
#  else
#    #forbidden combinations
#    if { [ "$partition_found" = "1" ] && [ "$partition_index" = "" ]; } || \
#      { [ "$partition_found" = "1" ] && { [ "$partition_index" -gt "$MAX_PARTITIONS" ] || [ "$partition_index" -lt 0 ]; }; }; then
#        echo ""
#        echo $CHECK_ON_PARTITION_ERR_MSG
#        echo ""
#        exit
#    fi
#  fi
#}

platform_dialog() {
  local CLI_PATH=$1
  local XILINX_PLATFORMS_PATH=$2
  local is_build=$3
  #local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  shift 3
  local flags_array=("$@")

  platform_found=""
  platform_name=""

  if [ "$is_build" = "0" ]; then
    platform_found="1"
    platform_name="none"
  else
    if [ "$flags_array" = "" ]; then
      echo $CHECK_ON_PLATFORM_MSG
      echo ""
      result=$($CLI_PATH/common/platform_dialog $XILINX_PLATFORMS_PATH)
      platform_found=$(echo "$result" | sed -n '1p')
      platform_name=$(echo "$result" | sed -n '2p')
      multiple_platforms=$(echo "$result" | sed -n '3p')
      if [[ $multiple_platforms = "0" ]]; then
          echo $platform_name
      fi
      echo ""
    else
      platform_check "$CLI_PATH" "$XILINX_PLATFORMS_PATH" "${flags_array[@]}"
      #forgotten mandatory
      if [[ $platform_found = "0" ]]; then
          echo $CHECK_ON_PLATFORM_MSG
          echo ""
          result=$($CLI_PATH/common/platform_dialog $XILINX_PLATFORMS_PATH)
          platform_found=$(echo "$result" | sed -n '1p')
          platform_name=$(echo "$result" | sed -n '2p')
          multiple_platforms=$(echo "$result" | sed -n '3p')
          if [[ $multiple_platforms = "0" ]]; then
              echo $platform_name
          fi
          echo ""
      fi
    fi
  fi
}

platform_check() {
  local CLI_PATH=$1
  local XILINX_PLATFORMS_PATH=$2
  #local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  shift 2
  local flags_array=("$@")
  result="$("$CLI_PATH/common/platform_dialog_check" "${flags_array[@]}")"
  platform_found=$(echo "$result" | sed -n '1p')
  platform_name=$(echo "$result" | sed -n '2p')    
  #forbidden combinations
  if ([ "$platform_found" = "1" ] && [ "$platform_name" = "" ]) || ([ "$platform_found" = "1" ] && [ ! -d "$XILINX_PLATFORMS_PATH/$platform_name" ]); then
      echo ""
      echo $CHECK_ON_PLATFORM_ERR_MSG
      echo ""
      exit 1
  fi
}

port_check() {
  local CLI_PATH=$1
  local CLI_NAME=$2
  local device_index=$3
  shift 3
  local flags_array=("$@")
  result="$("$CLI_PATH/common/port_dialog_check" "${flags_array[@]}")"
  port_found=$(echo "$result" | sed -n '1p')
  port_index=$(echo "$result" | sed -n '2p')

  #get number of ports
  MAX_NUM_PORTS=$($CLI_PATH/get/get_nic_device_param $device_index IP | grep -o '/' | wc -l)
  MAX_NUM_PORTS=$((MAX_NUM_PORTS + 1))

  if [ "$MAX_NUM_PORTS" = "1" ]; then #there is only one IP in the file (the character "/" does not appear)
    port_found="1"
    port_index="1"
  else
    #forbidden combinations
    if   [ "$port_found" = "0" ] || \
          ([[ "$port_found" = "1" ]] && [[ -z "$port_index" ]]) || \
          ([[ "$port_found" = "1" ]] && (! [[ "$port_index" =~ ^[0-9]+$ ]] || [[ "$port_index" -gt "$MAX_NUM_PORTS" ]] || [[ "$port_index" -lt 1 ]])); then
        echo ""
        echo "$CHECK_ON_PORT_ERR_MSG"
        echo ""
        exit
    fi
  fi
}

pow2_check() {
    local value=$1
    local minimum=$2
    local maximum=$3

    # Check if value is a number
    [[ "$value" =~ ^[0-9]+$ ]] || return 1

    # Check range
    if (( value < $minimum || value > $maximum )); then
        return 1
    fi

    # Check if it's a power of two using bitwise trick: value & (value - 1) == 0
    if (( (value & (value - 1)) == 0 )); then
        return 0
    else
        return 1
    fi
}

project_dialog() {
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  #local command=$3
  local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  local commit_name=$4
  shift 4
  local flags_array=("$@")

  project_found="0"
  project_name=""

  #check on PWD
  project_path=$(dirname "$PWD")  
  if [ "$project_path" = "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name" ]; then 
      project_found="1"
      project_name=$(basename "$PWD")
      return 1
  fi
  
  if [ "$flags_array" = "" ]; then
    #project_dialog
    if [[ $project_found = "0" ]]; then
      echo $CHECK_ON_PROJECT_MSG
      echo ""
      result=$($CLI_PATH/common/project_dialog $MY_PROJECTS_PATH/$WORKFLOW/$commit_name)
      project_found=$(echo "$result" | sed -n '1p')
      project_name=$(echo "$result" | sed -n '2p')
      multiple_projects=$(echo "$result" | sed -n '3p')
      if [[ $multiple_projects = "0" ]]; then
          echo $project_name
      fi
      echo ""
    fi
  else
    project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$WORKFLOW" "$commit_name" "${flags_array[@]}"
    #forgotten mandatory
    if [[ $project_found = "0" ]]; then
        #echo ""
        echo $CHECK_ON_PROJECT_MSG
        echo ""
        result=$($CLI_PATH/common/project_dialog $MY_PROJECTS_PATH/$WORKFLOW/$commit_name)
        project_found=$(echo "$result" | sed -n '1p')
        project_name=$(echo "$result" | sed -n '2p')
        multiple_projects=$(echo "$result" | sed -n '3p')
        if [[ $multiple_projects = "0" ]]; then
            echo $project_name
        fi
        echo ""
    fi
  fi
}

project_check() {
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  local commit_name=$4
  shift 4
  local flags_array=("$@")

  project_found="0"
  project_name=""

  #check on PWD
  project_path=$(dirname "$PWD")  

  #evaluate current directory
  if [ "$project_path" = "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name" ]; then 
      project_found="1"
      project_name=$(basename "$PWD")
      return 1
  fi

  #find project name
  result="$("$CLI_PATH/common/project_dialog_check" "${flags_array[@]}")"
  project_found=$(echo "$result" | sed -n '1p')
  project_path=$(echo "$result" | sed -n '2p')
  project_name=$(echo "$result" | sed -n '3p')

  #check if the project exists for WORKFLOW and commit/tag_name
  if [ ! "$project_name" = "" ] && [ -d "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name" ]; then
      project_found="1"
      return 1
  fi

  #forbidden combinations
  if [ "$project_found" = "1" ] && ([ "$project_name" = "" ] || [ ! -d "$project_path" ] || [ ! -d "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name" ]); then  
      echo ""
      echo $CHECK_ON_PROJECT_ERR_MSG
      echo ""
      exit 1
  fi
}

project_check_empty(){
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  local WORKFLOW=$3
  local commit_name=$4

  if [ -z "$(ls -d "$MY_PROJECTS_PATH/$WORKFLOW/$commit_name"/*/ 2>/dev/null)" ]; then
    echo ""
    echo $CHECK_ON_PROJECT_EMPTY_ERR_MSG
    echo ""
    exit 1
  fi
}

push_dialog() {
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  local commit_name=$4 #arguments and workflow are the same (i.e. opennic)
  shift 4
  local flags_array=("$@")

  push_found=""
  push_option=""

  #capture gh auth status
  logged_in=$($CLI_PATH/common/gh_auth_status)

  if [ "$flags_array" = "" ]; then
    #push_dialog
    push_option="0"
    if [ "$logged_in" = "1" ]; then
        echo $CHECK_ON_PUSH_MSG
        push_option=$($CLI_PATH/common/push_dialog)
        echo ""
    fi
  else
    push_check "$CLI_PATH" "${flags_array[@]}"
    #forgotten mandatory
    if [[ $push_found = "0" ]]; then
        push_option="0"
        if [ "$logged_in" = "1" ]; then
            echo $CHECK_ON_PUSH_MSG
            push_option=$($CLI_PATH/common/push_dialog)
            echo ""
        fi
    fi
  fi
}

push_check(){
  local CLI_PATH=$1
  shift 1
  local flags_array=("$@")
  #push_dialog_check
  result="$("$CLI_PATH/common/push_dialog_check" "${flags_array[@]}")"
  push_found=$(echo "$result" | sed -n '1p')
  push_option=$(echo "$result" | sed -n '2p')
  #forbidden combinations
  if [[ "$push_found" = "1" && "$push_option" != "0" && "$push_option" != "1" ]]; then 
      echo ""
      echo "$CHECK_ON_PUSH_ERR_MSG"
      echo ""
      exit 1
  fi
}

remote_dialog() {
  local CLI_PATH=$1
  local command=$2
  local WORKFLOW=$3 #arguments and workflow are the same (i.e. opennic)
  local hostname=$4
  local username=$5
  shift 5
  local flags_array=("$@")

  #combine ACAP and FPGA lists removing duplicates
  SERVER_LIST=$(sort -u $CLI_PATH/constants/ACAP_SERVERS_LIST /$CLI_PATH/constants/FPGA_SERVERS_LIST /$CLI_PATH/constants/ASOC_SERVERS_LIST)

  if [ "$flags_array" = "" ]; then
    result=$($CLI_PATH/common/get_servers $CLI_PATH "$SERVER_LIST" $hostname $username)
    servers_family_list=$(echo "$result" | sed -n '1p' | sed -n '1p')
    servers_family_list_string=$(echo "$result" | sed -n '2p' | sed -n '1p')
    num_remote_servers=$(echo "$servers_family_list" | wc -w)

    #deployment_dialog
    deploy_option="0"
    if [ "$num_remote_servers" -ge 1 ]; then
        #echo ""
        echo $CHECK_ON_REMOTE_MSG
        echo ""
        echo "0) $hostname"
        echo "1) $hostname, $servers_family_list_string"
        deploy_option=$($CLI_PATH/common/deployment_dialog $servers_family_list_string)
        echo ""
    fi
  else
    remote_check "$CLI_PATH" "${flags_array[@]}"
    #forgotten mandatory
    if [ "$deploy_option" = "1" ]; then
      result=$($CLI_PATH/common/get_servers $CLI_PATH "$SERVER_LIST" $hostname $username)
      servers_family_list=$(echo "$result" | sed -n '1p' | sed -n '1p')
      servers_family_list_string=$(echo "$result" | sed -n '2p' | sed -n '1p')
      num_remote_servers=$(echo "$servers_family_list" | wc -w)
      if [ "$servers_family_list" = "" ]; then
        echo "Please, verify that you can ssh the targeted remote servers."
        echo ""
        exit
      fi
    elif [ "$deploy_option_found" = "0" ]; then
      #no --remote flag means no remote programming
      deploy_option_found="1"
      deploy_option="0"
    fi
  fi
  #remove trailings
  deploy_option=$(echo "$deploy_option" | sed '/^$/d' | xargs)
}

remote_check() {
  local CLI_PATH=$1
  shift 1
  local flags_array=("$@")
  result="$("$CLI_PATH/common/deployment_dialog_check" "${flags_array[@]}")"
  deploy_option_found=$(echo "$result" | sed -n '1p')
  deploy_option=$(echo "$result" | sed -n '2p')
  #forbidden combinations (check if deploy_option is numeric before comparing)
  if [ "$deploy_option_found" = "1" ] && [ "$deploy_option" = "" ]; then
    echo ""
    echo $CHECK_ON_REMOTE_ERR_MSG
    echo ""
    exit 1
  fi
  if [ "$deploy_option_found" = "1" ] && [[ "$deploy_option" =~ ^[0-9]+$ ]] && { [ "$deploy_option" -ne 0 ] && [ "$deploy_option" -ne 1 ]; }; then
    echo ""
    echo $CHECK_ON_REMOTE_ERR_MSG
    echo ""
    exit 1
  fi
}

software_check() {
  local app_name=$1
  if [ -z "$(which "$app_name" 2>/dev/null)" ]; then
    echo ""
    echo "Sorry, ${bold}$app_name${normal} is not installed on ${bold}$hostname.${normal}"
    echo ""
    exit 1
  fi
}

sudo_check() {
  local username=$1
  is_sudo=$($CLI_PATH/common/is_sudo $username)
  if [ "$is_sudo" = "0" ]; then
    echo ""
    echo $CHECK_ON_SUDO_ERR_MSG
    echo ""
    exit 1
  fi
}

tag_dialog() {
  local CLI_PATH=$1
  local CLI_NAME=$2
  local MY_PROJECTS_PATH=$3
  local command=$4 #program
  local WORKFLOW=$5 #arguments and workflow are the same (i.e. opennic)
  local GITHUB_CLI_PATH=$6
  local REPO_ADDRESS=$7
  local DEFAULT_TAG=$8
  shift 8
  local flags_array=("$@")
  
  tag_found=""
  tag_name=""
  if [ "$flags_array" = "" ]; then
    #check on PWD
    project_path=$(dirname "$PWD")
    tag_name=$(basename "$project_path")
    project_found="0"
    if [ "$project_path" = "$MY_PROJECTS_PATH/$WORKFLOW/$tag_name" ]; then 
        tag_found="1"
        project_found="1"
        project_name=$(basename "$PWD")
    #elif [ "$tag_name" = "$WORKFLOW" ]; then
    #    tag_found="1"
    #    tag_name="${PWD##*/}"
    else
        tag_found="1"
        tag_name=$DEFAULT_TAG
    fi
  else
    tag_check "$CLI_PATH" "$CLI_NAME" "$command" "$WORKFLOW" "$GITHUB_CLI_PATH" "$REPO_ADDRESS" "$DEFAULT_TAG" "${flags_array[@]}"
  fi
}

tag_check() {
  local CLI_PATH=$1
  local CLI_NAME=$2
  local command=$3 #program
  local WORKFLOW=$4 #arguments and workflow are the same (i.e. opennic)
  local GITHUB_CLI_PATH=$5
  local REPO_ADDRESS=$6
  local DEFAULT_TAG=$7
  shift 7
  local flags_array=("$@")
  #commit_dialog_check
  result="$("$CLI_PATH/common/github_tag_dialog_check" "${flags_array[@]}")"
  tag_found=$(echo "$result" | sed -n '1p')
  tag_name=$(echo "$result" | sed -n '2p')
  #check if commit exists
  exists=$($CLI_PATH/common/gh_tag_check $GITHUB_CLI_PATH $REPO_ADDRESS $tag_name)
  #forbidden combinations
  if [ "$tag_found" = "0" ]; then 
    tag_found="1"
    tag_name=$DEFAULT_TAG
  elif [ "$tag_found" = "1" ] && ([ "$tag_name" = "" ] || [ "$exists" = "0" ]); then 
      echo ""
      echo $CHECK_ON_GH_TAG_ERR_MSG
      echo ""
      exit 1
  fi
}

tag_check_pwd(){
  local CLI_PATH=$1
  local MY_PROJECTS_PATH=$2
  local WORKFLOW=$3
  local tag_name_local=$4

  #evaluate current directory (2) /home/jmoyapaya/my_projects/opennic/940907f
  if [ -f "$PWD/$tag_name_local" ]; then
    #declare -g project_found="1"
    #declare -g project_name=$(basename "$PWD")
    declare -g tag_found="1"
    declare -g tag_name=$(cat "$PWD/$tag_name_local")
    return 1
  fi
}

template_check(){
  local CLI_PATH=$1
  local TEMPLATES_FILE=$2
  shift 2
  local flags_array=("$@")
  #template_dialog_check
  result="$("$CLI_PATH/common/template_dialog_check" "${flags_array[@]}")"
  template_found=$(echo "$result" | sed -n '1p')
  template_name=$(echo "$result" | sed -n '2p')
  if [ "$template_found" = "1" ]; then
    if ! grep -Fxq "$template_name" "$CLI_PATH/constants/$TEMPLATES_FILE"; then
      echo ""
      echo $CHECK_ON_TEMPLATE_ERR_MSG
      echo ""
      exit 1
    fi
  fi
}

template_dialog() {
  local CLI_PATH=$1
  local TEMPLATES_FILE=$2
  shift 2
  local flags_array=("$@")

  template_found=""
  template_name=""

  if [ "$flags_array" = "" ]; then
    #new_dialog
    echo $CHECK_ON_TEMPLATE_MSG
    echo ""
    result=$($CLI_PATH/common/template_dialog $CLI_PATH $TEMPLATES_FILE)
    template_found=$(echo "$result" | sed -n '1p')
    template_name=$(echo "$result" | sed -n '2p')
    echo ""
  else
    template_check "$CLI_PATH" "VRT_TEMPLATES" "${flags_array[@]}"
    #forgotten mandatory
    if [[ $template_found = "0" ]]; then
        echo $CHECK_ON_TEMPLATE_MSG
        echo ""
        result=$($CLI_PATH/common/template_dialog $CLI_PATH $TEMPLATES_FILE)
        template_found=$(echo "$result" | sed -n '1p')
        template_name=$(echo "$result" | sed -n '2p')
        echo ""
    fi
  fi
}

target_check(){
  local CLI_PATH=$1
  local TARGET_FILE=$2
  shift 2
  local flags_array=("$@")
  #template_dialog_check
  result="$("$CLI_PATH/common/target_dialog_check" "${flags_array[@]}")"
  target_found=$(echo "$result" | sed -n '1p')
  target_name=$(echo "$result" | sed -n '2p')
  if [ "$target_found" = "1" ]; then
    if ! grep -Fxq "$target_name" "$CLI_PATH/constants/$TARGET_FILE"; then
      echo ""
      echo $CHECK_ON_TARGET_ERR_MSG
      echo ""
      exit 1
    fi
  fi
}

target_dialog() {
  local CLI_PATH=$1
  local TARGETS_FILE=$2
  local TARGET_DEPLOY_EXCLUDE=$3
  local is_build=$4
  shift 4
  local flags_array=("$@")

  target_found=""
  target_name=""

  if [ "$flags_array" = "" ]; then
    #new_dialog
    echo $CHECK_ON_TARGET_MSG
    echo ""
    result=$($CLI_PATH/common/target_dialog $CLI_PATH $TARGETS_FILE $TARGET_DEPLOY_EXCLUDE $is_build)
    target_found=$(echo "$result" | sed -n '1p')
    target_name=$(echo "$result" | sed -n '2p')
    echo ""
  else
    target_check "$CLI_PATH" "$TARGETS_FILE" "${flags_array[@]}"
    #forgotten mandatory
    if [[ $target_found = "0" ]]; then
        echo $CHECK_ON_TARGET_MSG
        echo ""
        result=$($CLI_PATH/common/target_dialog $CLI_PATH $TARGETS_FILE $TARGET_DEPLOY_EXCLUDE $is_build)
        target_found=$(echo "$result" | sed -n '1p')
        target_name=$(echo "$result" | sed -n '2p')
        echo ""
    fi
  fi
}


value_check() {
  local CLI_PATH=$1
  local VALUE_MIN=$2
  local VALUE_MAX=$3
  local STRING=$4
  #local arguments=$4
  #local multiple_devices=$5
  #local MAX_DEVICES=$6
  shift 4
  local flags_array=("$@")
  result="$("$CLI_PATH/common/value_dialog_check" "${flags_array[@]}")"
  value_found=$(echo "$result" | sed -n '1p')
  value=$(echo "$result" | sed -n '2p')
  #add string after valid
  CHECK_ON_VALUE_ERR_MSG=$(echo "$CHECK_ON_VALUE_ERR_MSG" | sed "s/\(valid\)/\1 $STRING/")
  #forbidden combinations
  if [ "$value_found" = "0" ] || ([ "$value_found" = "1" ] && [ "$value" = "" ]); then
      echo ""
      echo $CHECK_ON_VALUE_ERR_MSG
      echo ""
      exit
  fi
  # Check if MTU_VALUE is a valid integer and within the valid range
  if ! [[ "$value" =~ ^[0-9]+$ ]] || ! [[ "$VALUE_MIN" =~ ^[0-9]+$ ]] || ! [[ "$VALUE_MAX" =~ ^[0-9]+$ ]] || \
    [ "$value" -lt "$VALUE_MIN" ] || [ "$value" -gt "$VALUE_MAX" ]; then
      echo ""
      echo "$CHECK_ON_VALUE_ERR_MSG"
      echo ""
      exit
  fi
}

vivado_check() {
  local VIVADO_PATH=$1
  local vivado_version=$2
  if [ -z "$vivado_version" ] || [ ! -d $VIVADO_PATH/$vivado_version ]; then
    echo ""
    echo $CHECK_ON_VIVADO_ERR_MSG
    echo ""
    exit 1
  fi
}

vivado_developers_check() {
  local username=$1
  member=$($CLI_PATH/common/is_member $username vivado_developers)
  if [ "$member" = "0" ]; then
      echo ""
      echo $CHECK_ON_VIVADO_DEVELOPERS_ERR_MSG
      echo ""
      exit 1
  fi
}

word_check() {
  local CLI_PATH=$1
  local word_1=$2 #-d
  local word_2=$3 #--driver
  shift 3
  local flags_array=("$@")

  result="$("$CLI_PATH/common/word_check" "$word_1" "$word_2" "${flags_array[@]}")"
  word_found=$(echo "$result" | sed -n '1p')
  word_value=$(echo "$result" | sed -n '2p')

  #forbidden combinations
  #if [ "$word_found" = "1" ] && [ "$word_value" = "" ]; then
  #  echo ""
  #  #echo "Please, choose a valid ${word_2#--} name."
  #  echo "Please, choose a valid parameter value."
  #  echo ""
  #  exit 1
  #fi
}

xrt_check() {
  local CLI_PATH=$1
  #check on valid XRT and Vivado version
  xrt_version=$($CLI_PATH/common/get_xilinx_version xrt)
  if [ -z "$xrt_version" ]; then
      echo ""
      echo $CHECK_ON_XRT_ERR_MSG
      echo ""
      exit 1
  fi
}

xrt_shell_check() {
  local CLI_PATH=$1
  local device_index=$2
  SHELLS=("xilinx_u250_gen" "xilinx_u280_gen" "xilinx_u50_gen" "xilinx_u55c_gen" "xilinx_vck5000_gen")

  platform_name=$($CLI_PATH/get/get_fpga_device_param $device_index platform)
  platform_name="${platform_name%%gen*}gen"

  #check if substring matches any array element
  match_found=false
  for shell in "${SHELLS[@]}"; do
    if [[ "$platform_name" == "$shell" ]]; then
        match_found=true
        break
    fi
  done

  if ! $match_found; then
    echo $CHECK_ON_XRT_SHELL_ERR_MSG
    echo ""
    exit 1
  fi
}
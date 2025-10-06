#!/bin/bash

CLI_PATH=$(dirname "$0")
CLI_NAME=${0##*/}
HDEV_PATH=$(dirname "$CLI_PATH")
bold=$(tput bold)
normal=$(tput sgr0)

#example: hdev program opennic --device 1

#inputs
command=$1
arguments=$2

#constants
AVED_DRIVER_NAME=$($CLI_PATH/common/get_constant $CLI_PATH AVED_DRIVER_NAME)
AVED_TAG=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TAG)
AVED_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH AVED_TOOLS_PATH)
AVED_UUID=$($CLI_PATH/common/get_constant $CLI_PATH AVED_UUID)
BITSTREAMS_PATH="$CLI_PATH/bitstreams"
CMDB_PATH="$CLI_PATH/cmdb"
COYOTE_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH COYOTE_COMMIT)
COYOTE_DEVICE_NAMES="$CLI_PATH/constants/COYOTE_DEVICE_NAMES"
COYOTE_REPO=$($CLI_PATH/common/get_constant $CLI_PATH COYOTE_REPO)
COYOTE_SHELL_NAME=$($CLI_PATH/common/get_constant $CLI_PATH COYOTE_SHELL_NAME)
GITHUB_CLI_PATH=$($CLI_PATH/common/get_constant $CLI_PATH GITHUB_CLI_PATH)
HDEV_REPO=$($CLI_PATH/common/get_constant $CLI_PATH HDEV_REPO)
HIP_TAG=$(cat $HDEV_PATH/TAG)
IS_HIP_DEVELOPER="1"
MTU_DEFAULT=$($CLI_PATH/common/get_constant $CLI_PATH MTU_DEFAULT)
MTU_MAX=$($CLI_PATH/common/get_constant $CLI_PATH MTU_MAX)
MTU_MIN=$($CLI_PATH/common/get_constant $CLI_PATH MTU_MIN)
MY_DRIVERS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_DRIVERS_PATH)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
ONIC_DEVICE_NAMES="$CLI_PATH/constants/ONIC_DEVICE_NAMES"
ONIC_DRIVER_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_COMMIT)
ONIC_DRIVER_NAME=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_NAME)
ONIC_DRIVER_REPO=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_REPO)
ONIC_SHELL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_COMMIT)
ONIC_SHELL_NAME=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_NAME)
ONIC_SHELL_REPO=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_REPO)
SOCKPERF_MIN=$($CLI_PATH/common/get_constant $CLI_PATH SOCKPERF_MIN)
REPO_NAME="hdev"
TENSORFLOW_COMMIT=$(cat $HDEV_PATH/TAG)
UPDATES_PATH=$($CLI_PATH/common/get_constant $CLI_PATH UPDATES_PATH)
VRT_DEVICE_NAMES="$CLI_PATH/constants/VRT_DEVICE_NAMES"
VRT_REPO=$($CLI_PATH/common/get_constant $CLI_PATH VRT_REPO)
VRT_TAG=$($CLI_PATH/common/get_constant $CLI_PATH VRT_TAG)
XDP_BPFTOOL_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH XDP_BPFTOOL_COMMIT)
XDP_BPFTOOL_REPO=$($CLI_PATH/common/get_constant $CLI_PATH XDP_BPFTOOL_REPO)
XDP_LIBBPF_COMMIT=$($CLI_PATH/common/get_constant $CLI_PATH XDP_LIBBPF_COMMIT)
XDP_LIBBPF_REPO=$($CLI_PATH/common/get_constant $CLI_PATH XDP_LIBBPF_REPO)
XILINX_PLATFORMS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_PLATFORMS_PATH)
XILINX_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_TOOLS_PATH)

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#derived
AMI_TOOL_PATH="$AVED_TOOLS_PATH/ami_tool"
DEVICES_LIST="$CLI_PATH/devices_acap_fpga"
DEVICES_LIST_NETWORKING="$CLI_PATH/devices_network"
REPO_URL="https://github.com/fpgasystems/$REPO_NAME.git"
VITIS_HLS_PATH="$XILINX_TOOLS_PATH/Vitis_HLS"
VIVADO_PATH="$XILINX_TOOLS_PATH/Vivado"

#check on server
is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
is_nic=$($CLI_PATH/common/is_nic $CLI_PATH $hostname)
is_numa=$($CLI_PATH/common/is_numa $CLI_PATH)

#check on groups
is_sudo=$($CLI_PATH/common/is_sudo $USER)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
is_network_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
is_hdev_developer=$($CLI_PATH/common/is_member $USER hdev_developers)
is_hip_developer=$IS_HIP_DEVELOPER

#legend
COLOR_ON1=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_CPU)
COLOR_ON2=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_XILINX)
COLOR_ON3=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_ACAP)
COLOR_ON4=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_FPGA)
COLOR_ON5=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_GPU)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)

#get devices number
if [ -s "$DEVICES_LIST" ]; then
  source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST"
  MAX_DEVICES=$($CLI_PATH/common/get_max_devices "fpga|acap|asoc" $DEVICES_LIST)
  multiple_devices=$($CLI_PATH/common/get_multiple_devices $MAX_DEVICES)
fi

if [ -s "$DEVICES_LIST_NETWORKING" ]; then
  source "$CLI_PATH/common/device_list_check" "$DEVICES_LIST_NETWORKING"
  MAX_DEVICES_NETWORKING=$($CLI_PATH/common/get_max_devices "nic" $DEVICES_LIST_NETWORKING)
  multiple_devices_networking=$($CLI_PATH/common/get_multiple_devices $MAX_DEVICES_NETWORKING)
fi

#evaluate integrations
hip_enabled=$([ "$is_hip_developer" = "1" ] && [ "$is_gpu" = "1" ] && echo 1 || echo 0)
vivado_enabled=$([ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; } && echo 1 || echo 0)
vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)

#help
cli_help() {
  echo ""
  echo "${bold}$CLI_NAME [commands] [arguments [flags]] [--help] [--release]${normal}"
  echo ""
  echo "COMMANDS:"
  echo "    ${bold}build${normal}          - Creates binaries, bitstreams, and drivers for your accelerated applications."
  if [ "$is_build" = "1" ]; then
  echo "    ${bold}enable${normal}         - Enables your favorite development and deployment tools."
  fi
  echo "    ${bold}examine${normal}        - System and device information."
  if [ "$is_build" = "1" ]; then
  echo "    ${bold}get${normal}            - Host information."
  else
  echo "    ${bold}get${normal}            - Devices and host information."
  fi
  if [ "$is_build" = "1" ] || [ "$hip_enabled" = "1" ] || [ "$vivado_enabled" = "1" ]; then
  echo "    ${bold}new${normal}            - Creates a new project of your choice."
  fi
  echo "    ${bold}open${normal}           - Opens a windowed application for user interaction."
  if [ ! "$is_build" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; }; then
  echo "    ${bold}program${normal}        - Driver and bitstream programming."
  fi
  if [ "$is_sudo" = "1" ] || ([ "$is_build" = "0" ] && [ "$is_vivado_developer" = "1" ]); then
  echo "    ${bold}reboot${normal}         - Reboots the server (warm boot)."
  fi
  if [ ! "$is_build" = "1" ] && ([ "$hip_enabled" = "1" ] || [ "$vivado_enabled" = "1" ]); then
  echo "    ${bold}run${normal}            - Executes your accelerated application."
  fi
  if [ "$is_build" = "1" ]; then
  echo "    ${bold}set${normal}            - Host configuration."
  else
  echo "    ${bold}set${normal}            - Devices and host configuration."
  fi
  if [ "$is_sudo" = "1" ]; then
  echo "    ${bold}update${normal}         - Updates ${bold}$CLI_NAME${normal} to a specific version."
  fi
  echo "    ${bold}validate${normal}       - Infrastructure functionality assessment."
  echo ""
  echo "    ${bold}-h, --help${normal}     - Help to use $CLI_NAME."
  echo "    ${bold}-r, --release${normal}  - Reports $CLI_NAME release."
  echo ""
  if [ "$is_build" = "1" ]; then
  echo "                     ${bold}This is a build server${normal}"
  elif [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ] || [ "$is_gpu" = "1" ]; then
  echo "                     ${bold}This is a deployment server${normal}"  
  fi
  echo ""
  exit 1
}

cli_release() {
    release=$(cat $HDEV_PATH/TAG)
    release_date=$(cat $HDEV_PATH/TAG_DATE)
    echo ""
    #echo "Release (commit_ID) : $release ($release_date)"
    echo "$release ($release_date)"
    echo ""
    exit 1
}

command_run() {
    
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
	      fi
      done

      $CLI_PATH/${command_arguments_flags[0]}/${command_arguments_flags[1]} $flags

    fi
}

#hdev_dialogs
source "$CLI_PATH/.${CLI_NAME}_dialogs"

#hdev_help
source "$CLI_PATH/.${CLI_NAME}_help"

# read all input parameters (@)
read command_arguments_flags <<< $@ #command$arguments

# ensure -h or --help are going at the beginning
#-h
if [[ $(echo "$command_arguments_flags" | grep "\-h\b" | wc -l) = 1 ]]; then
  command_arguments_flags=${command_arguments_flags/-h/""}
  command_arguments_flags=${command_arguments_flags/$command" "/""}
  command_arguments_flags=${command_arguments_flags/$arguments" "/""}
  command_arguments_flags=$command" "$arguments" -h "$command_arguments_flags
fi
#--help
if [[ $(echo "$command_arguments_flags" | grep "\-\-help\b" | wc -l) = 1 ]]; then
  command_arguments_flags=${command_arguments_flags/--help/""}
  command_arguments_flags=${command_arguments_flags/$command" "/""}
  command_arguments_flags=${command_arguments_flags/$arguments" "/""}
  command_arguments_flags=$command" "$arguments" -h "$command_arguments_flags
fi

#help 
if [ "$command_arguments_flags" = "$command $arguments -h " ]; then
  "${command}_${arguments}_help" 2>/dev/null
fi

#command and arguments switch
case "$command" in
  -h|--help)
    cli_help
    ;;
  -r|--release)
    cli_release
    ;;
  build)
    case "$arguments" in
      -h|--help)
        build_help
        ;;
      c)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      coyote)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      opennic)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      vrt)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      xdp)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      *)
        build_help
      ;;  
    esac
    ;;
  enable)
    #early exit
    if [ "$is_build" = "0" ]; then
      exit 1
    fi

    case "$arguments" in
      -h|--help)
        enable_help
        ;;
      vitis) 
        if [ "$#" -ne 2 ]; then
          enable_vitis_help
          exit 1
        fi
        eval "$CLI_PATH/enable/vitis-msg"
        ;;
      vivado) 
        if [ "$#" -ne 2 ]; then
          enable_vivado_help
          exit 1
        fi
        eval "$CLI_PATH/enable/vivado-msg"
        ;;
      xrt) 
        if [ "$#" -ne 2 ]; then
          enable_xrt_help
          exit 1
        fi
        eval "$CLI_PATH/enable/xrt-msg"
        ;;
      *)
        enable_help
      ;;  
    esac
    ;;
  examine)
    case "$arguments" in
      -h|--help)
        examine_help
        ;;
      *)
        if [ "$#" -ne 1 ]; then
          examine_help
          exit 1
        fi
        $CLI_PATH/examine
        ;;
    esac
    ;;
  get)
    case "$arguments" in
      -h|--help)
        get_help
        ;;
      bdf)
        #early exit
        if [ "$is_acap" = "0" ] && [ "$is_asoc" = "0" ] && [ "$is_fpga" = "0" ]; then
          exit
        fi

        valid_flags="-h --help -d --device"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      bus)
        #early exit
        if [ "$is_gpu" = "0" ]; then
          exit
        fi

        valid_flags="-h --help -d --device"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      dmesg)
        #early exit
        if [ "$is_build" = "1" ] || [ "$is_vivado_developer" = "0" ]; then
          exit
        fi

        valid_flags="-h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      hugepages)
        #early exit
        if [ "$is_build" = "1" ] || [ "$is_vivado_developer" = "0" ]; then
          exit
        fi

        valid_flags="-h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      ifconfig)
        valid_flags="-d --device -p --port -h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      interfaces)
        #early exit
        if [ "$is_acap" = "0" ] && [ "$is_asoc" = "0" ] && [ "$is_fpga" = "0" ] && [ "$is_nic" = "0" ]; then
          exit
        fi

        valid_flags="-h --help" # -t --type
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      name)
        #early exit
        if [ "$is_acap" = "0" ] && [ "$is_asoc" = "0" ] && [ "$is_fpga" = "0" ]; then
          exit
        fi

        valid_flags="-h --help -d --device"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      network)
        #early exit
        if [ "$is_acap" = "0" ] && [ "$is_asoc" = "0" ] && [ "$is_fpga" = "0" ]; then
          exit
        fi

        valid_flags="-h --help -d --device -p --port"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      performance)
        #early exit
        if [ "$is_gpu" = "0" ]; then
          exit
        fi

        valid_flags="-h --help -d --device"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      platform)
        #early exit
        if [ "$is_acap" = "0" ] && [ "$is_fpga" = "0" ]; then
          exit
        fi

        valid_flags="-h --help -d --device"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      serial)
        #early exit
        if [ "$is_acap" = "0" ] && [ "$is_asoc" = "0" ] && [ "$is_fpga" = "0" ]; then
          exit
        fi

        valid_flags="-h --help -d --device"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      servers)
        valid_flags="-h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      syslog)
        #early exit
        if [ "$is_build" = "1" ] || [ "$is_vivado_developer" = "0" ]; then
          exit
        fi

        valid_flags="-h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      topo)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      uuid)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      workflow)
        #early exit
        if [ "$is_acap" = "0" ] && [ "$is_asoc" = "0" ] && [ "$is_fpga" = "0" ]; then
          exit
        fi

        valid_flags="-h --help -d --device"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      *)
        get_help
      ;;
    esac
    ;;
  new)  
    #create workflow directory
    mkdir -p "$MY_PROJECTS_PATH/$arguments"
  
    case "$arguments" in
      -h|--help)
        new_help
        ;;
      coyote)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      hip)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      opennic)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      tensorflow)
        #early exit
        #if [ "$is_build" = "0" ] && [ "$hip_enabled" = "0" ]; then
        if [ "$is_build" = "0" ] && [ "$hip_enabled" = "0" ]; then
          exit 1
        fi

        #check on software
        gh_check "$CLI_PATH"
        tf_check "$CLI_PATH"

        #check on flags
        valid_flags="--project --push -h --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"
        
        #echo "HEY! Continue here $TENSORFLOW_COMMIT"

        #checks (command line)
        if [ ! "$flags_array" = "" ]; then
          new_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$TENSORFLOW_COMMIT" "${flags_array[@]}"
          #device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          push_check "$CLI_PATH" "${flags_array[@]}"
        fi

        #dialogs
        echo ""
        echo "${bold}$CLI_NAME $command $arguments (commit ID: $TENSORFLOW_COMMIT)${normal}"
        echo ""
        new_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$TENSORFLOW_COMMIT" "${flags_array[@]}"
        push_dialog  "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$TENSORFLOW_COMMIT" "${flags_array[@]}"
        
        #run
        $CLI_PATH/new/tensorflow --commit $TENSORFLOW_COMMIT --project $new_name --push $push_option
        ;;
      vrt)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      xdp)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      *)
        new_help
      ;;
    esac
    ;;
  open)
    case "$arguments" in
      -h|--help)
        open_help
        ;;
      vivado)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      *)
        open_help
      ;;
    esac
    ;; 
  program)
    case "$arguments" in
      -h|--help)
        program_help
        ;;
      bitstream|vivado)
        source "$CLI_PATH/$command/.bitstream"
        ;;
      coyote)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      driver)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      image)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      opennic)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      reset)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      revert)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      vrt)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      xdp)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      *)
        program_help
      ;;
    esac
    ;;
  reboot)
    case "$arguments" in
      -h|--help)
        reboot_help
        ;;
      *)
        #early exit
        if [ "$is_sudo" != "1" ] && ! ([ "$is_build" = "0" ] && [ "$is_vivado_developer" = "1" ]); then
          exit 1
        fi
        
        if [ "$#" -ne 1 ]; then
          reboot_help
          exit 1
        fi
        sudo $CLI_PATH/reboot
        ;;
    esac
    ;;
  run)
    case "$arguments" in
      -h|--help)
        run_help
        ;;
      coyote)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      opennic)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      tensorflow)
        #early exit
        if [ "$is_build" = "0" ] && [ "$hip_enabled" = "0" ]; then
          exit 1
        fi
        
        #check on software
        gh_check "$CLI_PATH"
        tf_check "$CLI_PATH"

        #check on flags
        valid_flags="-c --config -p --project -h --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #constants
        CONFIG_PREFIX="host_config_"

        #checks (command line)
        if [ ! "$flags_array" = "" ]; then
          #commit_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$ONIC_SHELL_REPO" "$ONIC_SHELL_COMMIT" "${flags_array[@]}"
          project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$TENSORFLOW_COMMIT" "${flags_array[@]}"
          if [ "$project_found" = "1" ]; then
            config_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$TENSORFLOW_COMMIT" "$project_name" "$CONFIG_PREFIX" "yes" "${flags_array[@]}"
          fi
        fi

        if [ "$project_found" = "0" ]; then
          add_echo="no"
        fi

        #dialogs
        #commit_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$ONIC_SHELL_REPO" "$ONIC_SHELL_COMMIT" "${flags_array[@]}"
        #commit_check_pwd "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "ONIC_SHELL_COMMIT"
        project_check_empty "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name"
        echo ""
        echo "${bold}$CLI_NAME $command $arguments${normal}" #(commit ID: $commit_name)
        echo ""
        project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$TENSORFLOW_COMMIT" "${flags_array[@]}"
        config_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$TENSORFLOW_COMMIT" "$project_name" "$CONFIG_PREFIX" "$add_echo" "${flags_array[@]}"
        if [ "$project_found" = "1" ] && [ ! -e "$MY_PROJECTS_PATH/$arguments/$TENSORFLOW_COMMIT/$project_name/configs/$config_name" ]; then
            echo ""
            echo "$CHECK_ON_CONFIG_ERR_MSG"
            echo ""
            exit
        fi

        #get onic devices from sh.cfg (similar to hdev program opennic)
        #if [ -f "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/sh.cfg" ]; then
        #  while IFS=":" read -r index name; do
        #    if [[ ${name// /} == "onic" ]]; then
        #        device_indexes+=("$index")
        #    fi
        #  done < <(grep -v '^\[' "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/sh.cfg")
        #else
        #  #echo ""
        #  echo $CHECK_ON_SHELL_CFG_ERR_MSG
        #  echo ""
        #  exit 1
        #fi

        #onic workflow check
        #for i in "${!device_indexes[@]}"; do
        #  device_index_i="${device_indexes[$i]}"
        #  workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index_i)
        #  if [ ! "$workflow" = "onic" ]; then
        #    echo "$CHECK_ON_WORKFLOW_ERR_MSG"
        #    echo ""
        #    exit
        #  fi
        #done

        #onic application check
        #if [ ! -x "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/onic" ]; then
        #  echo "Your targeted application is missing. Please, use ${bold}$CLI_NAME build $arguments.${normal}"
        #  echo ""
        #  exit 1
        #fi

        #check on data
        config_string=$($CLI_PATH/common/get_config_string $config_index)
        if [ ! -e "$MY_PROJECTS_PATH/$arguments/$TENSORFLOW_COMMIT/$project_name/data/input_$config_string" ]; then
          #echo ""
          echo "$CHECK_ON_DATA_ERR_MSG"
          echo ""
          exit
        fi

        #run
        #echo ""
        #echo "${bold}$CLI_NAME $command $arguments${normal}" #(commit ID: $commit_name)
        #echo ""
        $CLI_PATH/run/tensorflow --commit $TENSORFLOW_COMMIT --config $config_index --project $project_name
        ;;
      vrt)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      *)
        run_help
      ;;  
    esac
    ;;
  set)
    case "$arguments" in
      -h|--help)
        set_help
        ;;
      balancing)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      gh)
        if [ "$#" -ne 2 ]; then
          set_gh_help
          exit 1
        fi
        eval "$CLI_PATH/set/gh"
        ;;
      hugepages)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      keys)
        echo ""
        if [ "$#" -ne 2 ]; then
          set_keys_help
          exit 1
        fi
        eval "$CLI_PATH/set/keys"
        ;;
      license) 
        source "$CLI_PATH/$command/.$arguments"
        ;;
      mtu)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      performance)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      *)
        set_help
      ;;  
    esac
    ;;
  update)
    case "$arguments" in
      -h|--help)
        update_help
        ;;
      *)
        source "$HDEV_PATH/.$command"
        ;;
    esac
    ;;
  validate)
    case "$arguments" in
      aved)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      coyote)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      docker)
        valid_flags="-h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      opennic)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      tensorflow)
        #early exit
        if [ "$is_build" = "1" ] || [ "$hip_enabled" = "0" ]; then
          exit
        fi

        #create workflow directory
        mkdir -p "$MY_PROJECTS_PATH/$arguments"

        #valid_flags="-d --device -h --help"
        #command_run $command_arguments_flags"@"$valid_flags

        echo "Work in progress"
        exit

        ;;
      vitis)
        #early exit
        if [[ "$is_build" = "1" ]] || ([[ "$is_acap" = "0" ]] && [[ "$is_fpga" = "0" ]]); then
          exit
        fi

        valid_flags="-d --device -h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      vrt)
        source "$CLI_PATH/$command/.$arguments"
        ;;
      *)
        validate_help
        ;;
    esac
    ;;
  *)
    cli_help
    ;;
esac

#author: https://github.com/jmoya82
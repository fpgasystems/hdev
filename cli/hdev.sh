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
GITHUB_CLI_PATH=$($CLI_PATH/common/get_constant $CLI_PATH GITHUB_CLI_PATH)
HDEV_REPO=$($CLI_PATH/common/get_constant $CLI_PATH HDEV_REPO)
IS_GPU_DEVELOPER="1"
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
gpu_enabled=$([ "$IS_GPU_DEVELOPER" = "1" ] && [ "$is_gpu" = "1" ] && echo 1 || echo 0)
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
  if [ "$is_build" = "1" ] || [ "$gpu_enabled" = "1" ] || [ "$vivado_enabled" = "1" ]; then
  #if [ ! "$is_build" = "1" ] && ([ "$gpu_enabled" = "1" ] || [ "$vivado_enabled" = "1" ] || [ "$is_network_developer" = "1" ]); then
  echo "    ${bold}new${normal}            - Creates a new project of your choice."
  fi
  echo "    ${bold}open${normal}           - Opens a windowed application for user interaction."
  #if [ ! "$is_build" = "1" ] && [ "$vivado_enabled" = "1" ]; then
  if [ ! "$is_build" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; }; then
  echo "    ${bold}program${normal}        - Driver and bitstream programming."
  fi
  if [ "$is_sudo" = "1" ] || ([ "$is_build" = "0" ] && [ "$is_vivado_developer" = "1" ]); then
  echo "    ${bold}reboot${normal}         - Reboots the server (warm boot)."
  fi
  if [ ! "$is_build" = "1" ] && ([ "$gpu_enabled" = "1" ] || [ "$vivado_enabled" = "1" ]); then
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
source "$CLI_PATH/_${CLI_NAME}_dialogs"

#hdev_help
source "$CLI_PATH/_${CLI_NAME}_help"

# read all input parameters (@)
read command_arguments_flags <<< $@ #command$arguments

# ensure -h or --help are going at the beginning
#-h
if [[ $(echo "$command_arguments_flags" | grep "\-h\b" | wc -l) = 1 ]]; then
  #echo "first: $command_arguments_flags"
  #remove -h
  command_arguments_flags=${command_arguments_flags/-h/""}
  #echo "second: $command_arguments_flags"
  #remove command and arguments
  command_arguments_flags=${command_arguments_flags/$command" "/""}
  #echo "third: $command_arguments_flags"
  command_arguments_flags=${command_arguments_flags/$arguments" "/""}
  #echo "fourth: $command_arguments_flags"
  #add it at the beginning
  command_arguments_flags=$command" "$arguments" -h "$command_arguments_flags
  #echo "fifth: $command_arguments_flags"
fi
#--help
if [[ $(echo "$command_arguments_flags" | grep "\-\-help\b" | wc -l) = 1 ]]; then
  #echo "first: $command_arguments_flags"
  #remove --help
  command_arguments_flags=${command_arguments_flags/--help/""}
  #echo "second: $command_arguments_flags"
  #remove command and arguments
  command_arguments_flags=${command_arguments_flags/$command" "/""}
  #echo "third: $command_arguments_flags"
  command_arguments_flags=${command_arguments_flags/$arguments" "/""}
  #echo "fourth: $command_arguments_flags"
  #add it at the beginning
  command_arguments_flags=$command" "$arguments" -h "$command_arguments_flags
  #echo "fifth: $command_arguments_flags"
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
        #check on flags
        valid_flags="-s --source -h --help" 
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #checks (command line)
        if [ "$flags" = "" ]; then
          #program_vivado_help
          echo ""
          echo "Your targeted file is missing."
          echo ""
          exit
        else 
          #cfile_dialog_check
          result="$("$CLI_PATH/common/cfile_dialog_check" "${flags_array[@]}")"
          cfile_found=$(echo "$result" | sed -n '1p')
          cfile_path=$(echo "$result" | sed -n '2p')
          #forbidden combinations (1/2)
          if [ "$cfile_found" = "0" ] || ([ "$cfile_found" = "1" ] && ([ "$cfile_path" = "" ] || [ ! -f "$cfile_path" ] || ( [ "${cfile_path##*.}" != "c" ] && [ "${cfile_path##*.}" != "cpp" ] ))); then
            echo ""
            echo "Please, choose a valid filename."
            echo ""
            exit
          fi
        fi
        echo ""

        #run
        $CLI_PATH/build/c --source $cfile_path
        echo ""
        ;;
      opennic)
        #early exit
        if [ "$is_build" = "0" ] && [ "$vivado_enabled" = "0" ]; then
          exit 1
        fi

        #temporal exit condition
        if [ "$is_asoc" = "1" ]; then
            echo ""
            echo "Sorry, we are working on this!"
            echo ""
            exit
        fi

        #check on groups
        vivado_developers_check "$USER"
        
        #check on software
        vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
        vivado_check "$VIVADO_PATH" "$vivado_version"
        vitis_hls_version=$($CLI_PATH/common/get_xilinx_version vitis)
        vitis_hls_check "$VITIS_HLS_PATH" "$vitis_hls_version"
        gh_check "$CLI_PATH"

        #check on flags
        valid_flags="-c --commit --project -h --help" #--platform 
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #checks on command line
        if [ ! "$flags_array" = "" ]; then
          commit_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$ONIC_SHELL_REPO" "$ONIC_SHELL_COMMIT" "${flags_array[@]}"
          #platform_check "$CLI_PATH" "$XILINX_PLATFORMS_PATH" "${flags_array[@]}"
          project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
        fi

        #additional forbidden combination
        if [ "$is_build" = "0" ] && [ "$platform_found" = "1" ]; then
          build_opennic_help
        fi

        #dialogs
        commit_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$ONIC_SHELL_REPO" "$ONIC_SHELL_COMMIT" "${flags_array[@]}"
        commit_check_pwd "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "ONIC_SHELL_COMMIT"
        project_check_empty "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name"
        echo ""
        echo "${bold}$CLI_NAME $command $arguments (commit ID for shell: $commit_name)${normal}"
        echo ""
        project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
        #we force the user to create a configuration
        if [ ! -f "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/configs/device_config" ]; then
            #get current path
            current_path=$(pwd)
            cd "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name"
            echo "${bold}Adding device and host configurations with ./config_add:${normal}"
            ./config_add
            cd "$current_path"
        fi
        commit_name_driver=$(cat $MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/ONIC_DRIVER_COMMIT)
        #platform_dialog "$CLI_PATH" "$XILINX_PLATFORMS_PATH" "$is_build" "${flags_array[@]}"

        #get device name
        #device_name=$(cat $MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/ONIC_DEVICE_NAME)
        
        #run
        $CLI_PATH/build/opennic --commit $commit_name $commit_name_driver --project $project_name --version $vivado_version --all $is_build #--platform $device_name
        echo ""
        ;;
      vrt)
        #early exit
        if [ "$is_build" = "0" ] && [ "$vivado_enabled_asoc" = "0" ]; then
            exit 1
        fi

        #check on groups
        vivado_developers_check "$USER"
        
        #check on software
        vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
        vivado_check "$VIVADO_PATH" "$vivado_version"
        gh_check "$CLI_PATH"

        #check on flags
        valid_flags="--tag --target --project -h --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #checks (command line)
        if [ ! "$flags_array" = "" ]; then
          tag_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$VRT_REPO" "$VRT_TAG" "${flags_array[@]}"
          project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "${flags_array[@]}"
          target_check "$CLI_PATH" "VRT_TARGETS" "${flags_array[@]}"
        fi
        
        #dialogs
        tag_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$VRT_REPO" "$VRT_TAG" "${flags_array[@]}"
        tag_check_pwd "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "VRT_TAG"
        project_check_empty "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name"
        echo ""
        echo "${bold}$CLI_NAME $command $arguments (tag ID: $tag_name)${normal}"
        echo ""
        project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "${flags_array[@]}"
        #template_dialog  "$CLI_PATH" "VRT_TEMPLATES" "${flags_array[@]}"
        target_dialog "$CLI_PATH" "VRT_TARGETS" "hw_emu" "$is_build" "${flags_array[@]}"

        #run with all set to one (as compiling with hacc-build servers did not work) 
        $CLI_PATH/build/vrt --project $project_name --tag $tag_name --target $target_name --version $vivado_version --all 1
        ;;
      xdp)
        #early exit
        if [ "$is_nic" = "0" ] || [ "$is_network_developer" = "0" ]; then
          exit 1
        fi

        #check on groups
        vivado_developers_check "$USER"
        
        #check on software
        #vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
        #vivado_check "$VIVADO_PATH" "$vivado_version"
        gh_check "$CLI_PATH"

        #check on flags
        valid_flags="-c --commit -d --driver -p --project -h --help" 
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #checks on command line
        if [ ! "$flags_array" = "" ]; then
          commit_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$XDP_BPFTOOL_REPO" "$XDP_BPFTOOL_COMMIT" "${flags_array[@]}"
          project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
          #word_check "$CLI_PATH" "-d" "--driver" "${flags_array[@]}"
        fi

        #dialogs
        commit_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$XDP_BPFTOOL_REPO" "$XDP_BPFTOOL_COMMIT" "${flags_array[@]}"
        commit_check_pwd "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "XDP_BPFTOOL_COMMIT"
        project_check_empty "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name"
        echo ""
        echo "${bold}$CLI_NAME $command $arguments (commit ID for bpftool: $commit_name)${normal}"
        echo ""
        project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
        #we force the user to create a configuration
        #if [ ! -f "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/configs/device_config" ]; then
        #    #get current path
        #    current_path=$(pwd)
        #    cd "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name"
        #    echo "${bold}Adding device and host configurations with ./config_add:${normal}"
        #    ./config_add
        #    cd "$current_path"
        #fi
        #check on driver
        #if [ "$word_found" = "1" ] && [ ! "$word_value" = "" ]; then
        #  if [ ! -d "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/drivers/$word_value" ]; then
        #    echo $CHECK_ON_DRIVER_ERR_MSG
        #    echo ""
        #    exit 1
        #  fi
        #fi

        #get XDP_LIBBPF_COMMIT from project
        commit_name_libbpf=$(cat $MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/XDP_LIBBPF_COMMIT)
        
        #run
        $CLI_PATH/build/xdp --commit $commit_name $commit_name_libbpf --project $project_name #--driver $word_value
        echo ""
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
        ;;
      uuid)
        #early exit
        if [ "$is_asoc" = "0" ]; then
          exit
        fi

        #check on flags
        valid_flags="-d --device --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #checks (command line 2/2)
        if [ ! "$flags_array" = "" ]; then
          device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
          if [ "$device_found" = "1" ] && [ ! "$device_type" = "asoc" ]; then
            echo ""
            echo "Sorry, this command is not available on device $device_index."
            echo ""
            exit
          fi
        fi

        #run
        $CLI_PATH/get/uuid --device $device_index
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
      opennic)
        #early exit
        if [ "$is_build" = "0" ] && [ "$vivado_enabled" = "0" ]; then
        #if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "0" ]; then
            exit 1
        fi

        #temporal exit condition
        if [ "$is_asoc" = "1" ]; then
            echo ""
            echo "Sorry, we are working on this!"
            echo ""
            exit
        fi

        #check on groups
        vivado_developers_check "$USER"
        
        #check on software
        gh_check "$CLI_PATH"

        #check on flags
        valid_flags="-c --commit -n --name --project --push --hls --help" #-d --device
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #check_on_commits
        commit_found_shell=""
        commit_name_shell=""
        commit_found_driver=""
        commit_name_driver=""
        if [ "$flags_array" = "" ]; then
            #commit dialog
            commit_found_shell="1"
            commit_found_driver="1"
            commit_name_shell=$ONIC_SHELL_COMMIT
            commit_name_driver=$ONIC_DRIVER_COMMIT
            #checks (command line)
            #device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
        else
            #commit_dialog_check
            result="$("$CLI_PATH/common/commit_dialog_check" "${flags_array[@]}")"
            commit_found=$(echo "$result" | sed -n '1p')
            commit_name=$(echo "$result" | sed -n '2p')

            #check if commit_name is empty
            if [ "$commit_found" = "1" ] && [ "$commit_name" = "" ]; then
                #$CLI_PATH/help/validate_opennic $CLI_PATH $CLI_NAME
                $CLI_PATH/help/new $CLI_PATH $CLI_NAME "opennic" $is_acap $is_asoc $is_build $is_fpga "0" "0" $is_vivado_developer
                exit
            fi
            
            #check if commit_name contains exactly one comma
            if [ "$commit_found" = "1" ] && ! [[ "$commit_name" =~ ^[^,]+,[^,]+$ ]]; then
                echo ""
                echo "Please, choose valid shell and driver commit IDs."
                echo ""
                exit
            fi
            
            #get shell and driver commits (shell_commit,driver_commit)
            commit_name_shell=${commit_name%%,*}
            commit_name_driver=${commit_name#*,}

            #check if commits exist
            exists_shell=$($CLI_PATH/common/gh_commit_check $GITHUB_CLI_PATH $ONIC_SHELL_REPO $commit_name_shell)
            exists_driver=$($CLI_PATH/common/gh_commit_check $GITHUB_CLI_PATH $ONIC_DRIVER_REPO $commit_name_driver)

            if [ "$commit_found" = "0" ]; then 
                commit_name_shell=$ONIC_SHELL_COMMIT
                commit_name_driver=$ONIC_DRIVER_COMMIT
            elif [ "$commit_found" = "1" ] && ([ "$commit_name_shell" = "" ] || [ "$commit_name_driver" = "" ]); then 
                #$CLI_PATH/help/validate_opennic $CLI_PATH $CLI_NAME
                $CLI_PATH/help/new $CLI_PATH $CLI_NAME "opennic" $is_acap $is_asoc $is_build $is_fpga "0" "0" $is_vivado_developer
                exit
            elif [ "$commit_found" = "1" ] && ([ "$exists_shell" = "0" ] || [ "$exists_driver" = "0" ]); then 
                if [ "$exists_shell" = "0" ]; then
                  echo ""
                  echo "Please, choose a valid shell commit ID." #similar to CHECK_ON_COMMIT_ERR_MSG
                  echo ""
                  exit 1
                fi
                if [ "$exists_driver" = "0" ]; then
                  echo ""
                  echo "Please, choose a valid driver commit ID." #similar to CHECK_ON_COMMIT_ERR_MSG
                  echo ""
                  exit 1
                fi
            fi
        fi

        #checks (command line)
        if [ ! "$flags_array" = "" ]; then
          new_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name_shell" "${flags_array[@]}"
          #device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          list_check "$CLI_PATH" "$CLI_PATH/constants/ONIC_DEVICE_NAMES" "$CHECK_ON_DEVICE_NAME_ERR_MSG" "${flags_array[@]}"
          hls_check "$CLI_PATH" "${flags_array[@]}"
          push_check "$CLI_PATH" "${flags_array[@]}"
        fi

        #dialogs
        echo ""
        echo "${bold}$CLI_NAME $command $arguments (commit IDs for shell and driver: $commit_name_shell,$commit_name_driver)${normal}"
        echo ""
        new_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name_shell" "${flags_array[@]}"
        #device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
        list_dialog "$CLI_PATH" "$CLI_PATH/constants/ONIC_DEVICE_NAMES" "$CHECK_ON_DEVICE_MSG" "$CHECK_ON_DEVICE_NAME_ERR_MSG" "${flags_array[@]}"
        hls_dialog "$CLI_PATH" "${flags_array[@]}"
        push_dialog  "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name_shell" "${flags_array[@]}"

        #collect list results
        device_found=$item_found
        device_name=$item_name
        
        #get device_name
        #device_name=$($CLI_PATH/get/get_fpga_device_param $device_index device_name)

        #check on compatible device
        if ! grep -Fxq "$device_name" "$ONIC_DEVICE_NAMES"; then
          echo "Sorry, this command is not available for ${bold}$device_name.${normal}"
          echo ""
          exit 1
        fi

        #run
        $CLI_PATH/new/opennic --commit $commit_name_shell $commit_name_driver --project $new_name --name $device_name --push $push_option --hls $hls_option
        ;;
      tensorflow)
        #early exit
        #if [ "$is_build" = "0" ] && [ "$gpu_enabled" = "0" ]; then
        if [ "$is_build" = "0" ] && [ "$gpu_enabled" = "0" ]; then
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
        #early exit
        #if [ "$is_build" = "1" ] || [ "$vivado_enabled_asoc" = "0" ]; then
        if [ "$is_build" = "0" ] && [ "$vivado_enabled_asoc" = "0" ]; then
            exit 1
        fi

        #check on groups
        vivado_developers_check "$USER"
        
        #check on software
        gh_check "$CLI_PATH"

        #check on flags
        valid_flags="-n --name --tag --template --project --push -h --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #check_on_tag
        tag_found=""
        tag_name=""
        if [ "$flags_array" = "" ]; then
            #commit dialog
            tag_found="1"
            tag_name=$VRT_TAG
        else
            #github_tag_dialog_check
            result="$("$CLI_PATH/common/github_tag_dialog_check" "${flags_array[@]}")"
            tag_found=$(echo "$result" | sed -n '1p')
            tag_name=$(echo "$result" | sed -n '2p')

            #check if tag_name is empty
            if [ "$tag_found" = "1" ] && [ "$tag_name" = "" ]; then
                $CLI_PATH/help/new $CLI_PATH $CLI_NAME "vrt" "0" $is_asoc $is_build "0" "0" "0" $is_vivado_developer
                exit
            fi
            
            #check if tag exist
            exists_tag=$($CLI_PATH/common/gh_tag_check $GITHUB_CLI_PATH $VRT_REPO $tag_name)
            
            if [ "$tag_found" = "0" ]; then 
                tag_name=$VRT_TAG
            elif [ "$tag_found" = "1" ] && [ "$tag_name" = "" ]; then 
                $CLI_PATH/help/new $CLI_PATH $CLI_NAME "vrt" "0" $is_asoc $is_build "0" "0" "0" $is_vivado_developer
                exit
            elif [ "$tag_found" = "1" ] && [ "$exists_tag" = "0" ]; then 
                if [ "$exists_tag" = "0" ]; then
                  echo ""
                  echo $CHECK_ON_GH_TAG_ERR_MSG
                  echo ""
                  exit 1
                fi
            fi
        fi

        #checks (command line)
        if [ ! "$flags_array" = "" ]; then
          new_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "${flags_array[@]}"
          #device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          list_check "$CLI_PATH" "$CLI_PATH/constants/VRT_DEVICE_NAMES" "$CHECK_ON_DEVICE_NAME_ERR_MSG" "${flags_array[@]}"
          template_check "$CLI_PATH" "VRT_TEMPLATES" "${flags_array[@]}"
          push_check "$CLI_PATH" "${flags_array[@]}"
          #template_check "$CLI_PATH" "VRT_TEMPLATES" "${flags_array[@]}"
        fi

        #dialogs
        echo ""
        echo "${bold}$CLI_NAME $command $arguments (tag ID: $tag_name)${normal}"
        echo ""
        new_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "${flags_array[@]}"
        #device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
        list_dialog "$CLI_PATH" "$CLI_PATH/constants/VRT_DEVICE_NAMES" "$CHECK_ON_DEVICE_MSG" "$CHECK_ON_DEVICE_NAME_ERR_MSG" "${flags_array[@]}"
        template_dialog  "$CLI_PATH" "VRT_TEMPLATES" "${flags_array[@]}"
        push_dialog  "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "${flags_array[@]}"

        #collect list results
        device_found=$item_found
        device_name=$item_name

        #get device_name
        #device_name=$($CLI_PATH/get/get_fpga_device_param $device_index device_name)

        #check on compatible device
        if ! grep -Fxq "$device_name" "$VRT_DEVICE_NAMES"; then
          echo "Sorry, this command is not available for ${bold}$device_name.${normal}"
          echo ""
          exit 1
        fi

        #run
        $CLI_PATH/new/vrt --tag $tag_name --project $new_name --name $device_name --template $template_name --push $push_option --number "none"
        ;;
      xdp)
        #early exit
        if [ "$is_build" = "0" ] && [ "$nic_enabled" = "0" ]; then
        #if [ "$is_build" = "1" ] || [ "$is_nic" = "0" ] || [ "$is_network_developer" = "0" ]; then
            exit 1
        fi

        #check on groups
        #vivado_developers_check "$USER"
        
        #check on software
        gh_check "$CLI_PATH"

        #check on flags
        valid_flags="-c --commit --project --push -h --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #check_on_commits
        commit_found_bpftool=""
        commit_name_bpftool=""
        commit_found_libbpf=""
        commit_name_libbpf=""
        if [ "$flags_array" = "" ]; then
            #commit dialog
            commit_found_bpftool="1"
            commit_found_libbpf="1"
            commit_name_bpftool=$XDP_BPFTOOL_COMMIT
            commit_name_libbpf=$XDP_LIBBPF_COMMIT
            #checks (command line)
            #device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
        else
            #commit_dialog_check
            result="$("$CLI_PATH/common/commit_dialog_check" "${flags_array[@]}")"
            commit_found=$(echo "$result" | sed -n '1p')
            commit_name=$(echo "$result" | sed -n '2p')

            #check if commit_name is empty
            if [ "$commit_found" = "1" ] && [ "$commit_name" = "" ]; then
                $CLI_PATH/help/new $CLI_PATH $CLI_NAME "xdp" "0" "0" "$is_build" "0" "0" $is_nic "0" "0" $is_network_developer
                exit
            fi
            
            #check if commit_name contains exactly one comma
            if [ "$commit_found" = "1" ] && ! [[ "$commit_name" =~ ^[^,]+,[^,]+$ ]]; then
                echo ""
                echo "Please, choose valid bpftool and libbpf commit IDs."
                echo ""
                exit
            fi
            
            #get shell and driver commits (shell_commit,driver_commit)
            commit_name_bpftool=${commit_name%%,*}
            commit_name_libbpf=${commit_name#*,}

            #check if commits exist
            exists_bpftool=$($CLI_PATH/common/gh_commit_check $GITHUB_CLI_PATH $XDP_BPFTOOL_REPO $commit_name_bpftool)
            exists_libbpf=$($CLI_PATH/common/gh_commit_check $GITHUB_CLI_PATH $XDP_LIBBPF_REPO $commit_name_libbpf)

            if [ "$commit_found" = "0" ]; then 
                commit_name_bpftool=$XDP_BPFTOOL_COMMIT
                commit_name_libbpf=$XDP_LIBBPF_COMMIT
            elif [ "$commit_found" = "1" ] && ([ "$commit_name_bpftool" = "" ] || [ "$commit_name_libbpf" = "" ]); then 
                #$CLI_PATH/help/validate_opennic $CLI_PATH $CLI_NAME
                $CLI_PATH/help/new $CLI_PATH $CLI_NAME "opennic" $is_acap $is_asoc $is_build $is_fpga "0" "0" $is_vivado_developer
                exit
            elif [ "$commit_found" = "1" ] && ([ "$exists_bpftool" = "0" ] || [ "$exists_libbpf" = "0" ]); then 
                if [ "$exists_bpftool" = "0" ]; then
                  echo ""
                  echo "Please, choose a valid bpftool commit ID." #similar to CHECK_ON_COMMIT_ERR_MSG
                  echo ""
                  exit 1
                fi
                if [ "$exists_libbpf" = "0" ]; then
                  echo ""
                  echo "Please, choose a valid libbpf commit ID." #similar to CHECK_ON_COMMIT_ERR_MSG
                  echo ""
                  exit 1
                fi
            fi
        fi

        #checks (command line)
        if [ ! "$flags_array" = "" ]; then
          new_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name_bpftool" "${flags_array[@]}"
          push_check "$CLI_PATH" "${flags_array[@]}"
        fi

        #dialogs
        echo ""
        echo "${bold}$CLI_NAME $command $arguments (commit IDs for bpftool and libbpf: $commit_name_bpftool,$commit_name_libbpf)${normal}"
        echo ""
        new_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name_bpftool" "${flags_array[@]}"
        push_dialog  "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name_bpftool" "${flags_array[@]}"
  
        #run
        $CLI_PATH/new/xdp --commit $commit_name_bpftool $commit_name_libbpf --project $new_name --push $push_option
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
        #early exit
        if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "0" ]; then
            exit 1
        fi

        #check on groups
        vivado_developers_check "$USER"
        
        #check on software
        vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
        vivado_check "$VIVADO_PATH" "$vivado_version"
        gh_check "$CLI_PATH"

        #check on flags
        valid_flags="-p --path -h --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #check on size
        word_check "$CLI_PATH" "-p" "--path" "${flags_array[@]}"
        path_found=$word_found
        path_value=$word_value
        if [[ "$path_found" == "1" && ( ! -f "$path_value" || "$path_value" != *.xpr ) ]]; then
          echo ""
          echo $CHECK_ON_XPR_FILE_ERR_MSG
          echo ""
          exit 1
        fi
    
        #checks (command line)
        #if [ "$path_found" = "0" ]; then
        #  path_value="none"  
        #
        #fi

        #check on X11 fordwarding
        if [ -z "$DISPLAY" ]; then
          echo ""
          echo $CHECK_ON_X11_ERR_MSG
          echo ""
          exit 1
        fi

        #run
        $CLI_PATH/open/vivado --path $path_value #--device $device_index --project $project_name --tag $tag_name --version $vivado_version --remote $deploy_option "${servers_family_list[@]}"
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
        #early exit
        if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "0" ] || [ "$is_asoc" = "1" ]; then
          exit 1
        fi

        #check on server
        #virtualized_check "$CLI_PATH" "$hostname"
        fpga_check "$CLI_PATH" "$hostname"

        #check on groups
        vivado_developers_check "$USER"

        #check on software  
        vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
        vivado_check "$VIVADO_PATH" "$vivado_version"

        #check on flags
        #NOTE 1:  -v --version are not exposed and not shown in help command or completion
        #NOTE 2:  -p --path replace -b --bitstream (which are kept for compatibility)
        valid_flags="-b --bitstream -d --device --hotplug -p --path -r --remote -v --version --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #checks (command line)
        if [ "$flags_array" = "" ]; then
          #program_vivado_help
          echo ""
          echo "Your targeted bitstream and device are missing."
          echo ""
          exit 1
        else #if [ ! "$flags_array" = "" ]; then      
          device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          remote_check "$CLI_PATH" "${flags_array[@]}"
          #bitstream_dialog_check
          result="$("$CLI_PATH/common/bitstream_dialog_check" "${flags_array[@]}")"
          bitstream_found=$(echo "$result" | sed -n '1p')
          bitstream_name=$(echo "$result" | sed -n '2p')
          #forbidden combinations (1/2)
          if [ "$bitstream_found" = "0" ] || ([ "$bitstream_found" = "1" ] && ([ "$bitstream_name" = "" ] || [ ! -f "$bitstream_name" ] || [ "${bitstream_name##*.}" != "bit" ])); then
              echo ""
              echo "Please, choose a valid bitstream name."
              echo ""
              exit 1
          fi
          #forbidden combinations (2/2)
          if [ "$multiple_devices" = "1" ] && [ "$bitstream_found" = "1" ] && [ "$device_found" = "0" ]; then # this means bitstream always needs --device when multiple_devices
              echo ""
              echo $CHECK_ON_DEVICE_ERR_MSG
              echo ""
              exit 1
          fi
          #device values when there is only a device
          if [[ $multiple_devices = "0" ]]; then
              device_found="1"
              device_index="1"
          fi

          #check if hotplug flag is present (an empty value is controlled)
          word_check "$CLI_PATH" "--hotplug" "--hotplug" "${flags_array[@]}"
          hotplug_found=$word_found
          hotplug_value=$word_value
          
          #check on hotplug value
          if [ "$hotplug_found" = "0" ]; then
            #enabled by default
            hotplug_value="1"
          elif [ "$hotplug_found" = "1" ]; then
            if [ "$hotplug_value" != "0" ] && [ "$hotplug_value" != "1" ]; then
                echo ""
                echo $CHECK_ON_HOTPLUG_ERR_MSG
                echo ""
                exit 1
            fi
          fi
        fi
        echo ""

        remote_dialog "$CLI_PATH" "$command" "$arguments" "$hostname" "$USER" "${flags_array[@]}"

        #check on remote aboslute path
        if [ "$deploy_option" = "1" ] && [[ "$bitstream_name" == "./"* ]]; then
          echo $CHECK_ON_REMOTE_FILE_ERR_MSG
          echo ""
          exit 1
        fi

        #run
        $CLI_PATH/program/bitstream --path $bitstream_name --device $device_index --version $vivado_version --hotplug $hotplug_value --remote $deploy_option "${servers_family_list[@]}" 
        ;;
      driver)
        #early exit
        #if [ "$vivado_enabled" = "0" ]; then
        if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "0" ]; then
          exit 1
        fi

        #check on groups
        vivado_developers_check "$USER"

        #check on flags
        valid_flags="-i --insert -p --params --remote --remove -h --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"
        
        #checks (command line)
        if [ "$flags_array" = "" ]; then
          program_driver_help
        fi

        #dialogs
        driver_check "$CLI_PATH" "${flags_array[@]}"

        #check on -r or --remove
        if [ "$remove_flag_found" = "1" ]; then
          #get actual filename (i.e. onik.ko without the path)
          driver_name_base=$(basename "$driver_name")

          if lsmod | grep -q "${driver_name_base%.ko}" && ls "$MY_DRIVERS_PATH/$driver_name".* &>/dev/null; then
            echo ""
            echo "${bold}$CLI_NAME $command $arguments${normal}"
            echo ""

            #change directory (this is important)
            cd $MY_DRIVERS_PATH
            
            #remove module
            echo "${bold}Removing ${driver_name_base%.ko} module:${normal}"
            echo ""
            echo "sudo rmmod ${driver_name_base%.ko}"
            echo ""
            sudo rmmod ${driver_name_base%.ko}

            echo "${bold}Deleting driver from $MY_DRIVERS_PATH:${normal}"
            echo ""
            echo "sudo $CLI_PATH/common/chown $USER vivado_developers $MY_DRIVERS_PATH"
            echo "sudo $CLI_PATH/common/rm $MY_DRIVERS_PATH/$driver_name.*"
            echo ""

            #change ownership to ensure writing permissions and remove
            sudo $CLI_PATH/common/chown $USER vivado_developers $MY_DRIVERS_PATH
            sudo $CLI_PATH/common/rm $MY_DRIVERS_PATH/$driver_name.*
            exit 0
          else
            echo ""
            echo $CHECK_ON_DRIVER_ERR_MSG
            echo ""
            exit 1
          fi
          #exit
        fi

        echo ""
        echo "${bold}$CLI_NAME $command $arguments${normal}"
        echo ""

        remote_dialog "$CLI_PATH" "$command" "$arguments" "$hostname" "$USER" "${flags_array[@]}"

        #check on remote aboslute path
        if [ "$deploy_option" = "1" ] && [[ "$driver_name" == "./"* ]]; then
          echo $CHECK_ON_REMOTE_FILE_ERR_MSG
          echo ""
          exit 1
        fi

        #check on params_string
        if [ "$params_string" = "" ]; then
          params_string="none"
        fi

        #run
        $CLI_PATH/program/driver --insert $driver_name --params $params_string --remote $deploy_option "${servers_family_list[@]}"
        ;;
      image)
        #early exit
        if [ "$is_build" = "1" ] || [ "$vivado_enabled_asoc" = "0" ]; then
          exit
        fi

        #check on server
        fpga_check "$CLI_PATH" "$hostname"

        #check on groups
        vivado_developers_check "$USER"

        #check on software  
        vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
        vivado_check "$VIVADO_PATH" "$vivado_version"
        ami_check "$AMI_TOOL_PATH"

        #check on flags
        valid_flags="-d --device --partition --path -r --remote -h --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #checks (command line)
        if [ "$flags_array" = "" ]; then
          #program_vivado_help
          echo ""
          echo "Your targeted device and image are missing."
          echo ""
          exit
        else
          device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          #device values when there is only a device
          if [[ $multiple_devices = "0" ]]; then
              device_found="1"
              device_index="1"
          fi
          partition_check "$CLI_PATH" "$device_index" "${flags_array[@]}"
          remote_check "$CLI_PATH" "${flags_array[@]}"
          #file_path_dialog_check
          result="$("$CLI_PATH/common/file_path_dialog_check" "${flags_array[@]}")"
          file_path_found=$(echo "$result" | sed -n '1p')
          file_path=$(echo "$result" | sed -n '2p')
          #forbidden combinations (1/2)
          if [ "$file_path_found" = "0" ] || ([ "$file_path_found" = "1" ] && ([ "$file_path" = "" ] || [ ! -f "$file_path" ] || [ "${file_path##*.}" != "pdi" ])); then
              echo ""
              echo "Please, choose a valid image path."
              echo ""
              exit
          fi
          #forbidden combinations (2/2)
          if [ "$multiple_devices" = "1" ] && [ "$file_path_found" = "1" ] && [ "$device_found" = "0" ]; then # this means image always needs --device when multiple_devices
              echo ""
              echo $CHECK_ON_DEVICE_ERR_MSG
              echo ""
              exit
          fi
        fi
        echo ""

        remote_dialog "$CLI_PATH" "$command" "$arguments" "$hostname" "$USER" "${flags_array[@]}"

        #check on remote aboslute path
        if [ "$deploy_option" = "1" ] && [[ "$file_path" == "./"* ]]; then
          echo $CHECK_ON_REMOTE_FILE_ERR_MSG
          echo ""
          exit
        fi

        #echo "I am here"
        #echo "device_index: $device_index"
        #echo "path: $file_path"
        #echo "remote: $deploy_option"
        #echo "partition_index: $partition_index"
        #exit

        #run
        if [ "$partition_index" = "none" ]; then
          $CLI_PATH/program/bitstream --path $file_path --device $device_index --version $vivado_version --hotplug "1" --remote $deploy_option "${servers_family_list[@]}" 
        else
          $CLI_PATH/program/image --device $device_index --path $file_path --partition $partition_index --remote $deploy_option "${servers_family_list[@]}"
        fi
        ;;
      opennic)
        #early exit
        if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "0" ]; then
          exit
        fi

        #temporal exit condition
        if [ "$is_asoc" = "1" ]; then
            echo ""
            echo "Sorry, we are working on this!"
            echo ""
            exit
        fi

        #check on server
        #virtualized_check "$CLI_PATH" "$hostname"
        fpga_check "$CLI_PATH" "$hostname"
        
        #check on groups
        vivado_developers_check "$USER"
        
        #check on software
        vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
        vivado_check "$VIVADO_PATH" "$vivado_version"
        gh_check "$CLI_PATH"
      
        #check on flags
        valid_flags="-c --commit -d --device -f --fec -p --project -r --remote -h --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #initialize
        fec_option_found="0"
        fec_option=""

        #checks (command line)
        if [ ! "$flags_array" = "" ]; then
          commit_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$ONIC_SHELL_REPO" "$ONIC_SHELL_COMMIT" "${flags_array[@]}"
          device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
          fec_check "$CLI_PATH" "${flags_array[@]}"
          remote_check "$CLI_PATH" "${flags_array[@]}"
        fi

        #dialogs
        commit_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$ONIC_SHELL_REPO" "$ONIC_SHELL_COMMIT" "${flags_array[@]}"
        commit_check_pwd "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "ONIC_SHELL_COMMIT"
        project_check_empty "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name"
        echo ""
        echo "${bold}$CLI_NAME $command $arguments (commit ID: $commit_name)${normal}"
        echo ""
        project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"

        #get devices from sh.cfg (device_dialog comes at the end)
        device_indexes=()
        if [ "$device_found" = "1" ]; then 
          device_indexes=("$device_index")
        elif [[ ( "$device_found" = "" || "$device_found" = "0" ) && -f "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/sh.cfg" ]]; then #elif [ "$device_found" = "" ] && [ -f "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/sh.cfg" ]; then
          while IFS=":" read -r index name; do
            if [[ ${name// /} == "onic" ]]; then
                device_indexes+=("$index")
            fi
          done < <(grep -v '^\[' "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/sh.cfg")

          #there is at least one onic device
          if [[ ${#device_indexes[@]} -gt 0 ]]; then
            device_found="1"
          fi
        fi

        #final check
        if [ "$device_found" = "" ] || [ "$device_found" = "0" ]; then
          device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          device_indexes=("$device_index")

          #add to sh.cfg
          if [[ "$(cat "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/sh.cfg")" == "[workflows]" ]]; then
            if [[ -n "$device_index" ]]; then
                echo "$device_index: onic" >> "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/sh.cfg"
            fi
          fi
        fi

        #fec_dialog
        if ! (lsmod | grep -q "${ONIC_DRIVER_NAME%.ko}" 2>/dev/null); then
          if [ "$fec_option_found" = "0" ]; then
            echo "${bold}Please, choose your encoding scheme:${normal}"
            echo ""
            echo "0) RS_FEC_ENABLED = 0"
            echo "1) RS_FEC_ENABLED = 1"
            while true; do
                read -p "" choice
                case $choice in
                    "0")
                        fec_option="0"
                        break
                        ;;
                    "1")
                        fec_option="1"
                        break
                        ;;
                esac
            done
            echo ""
          fi
        else
          #when the driver is inserted fec_option is irrelevant
          fec_option="-" 
        fi

        #bitstream check (this should never happen as hdev new opennic is for a specific device_name)
        for i in "${!device_indexes[@]}"; do
          FDEV_NAME=$($CLI_PATH/common/get_FDEV_NAME $CLI_PATH "${device_indexes[$i]}") #$device_index
          bitstream_path="$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/${ONIC_SHELL_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
          if ! [ -e "$bitstream_path" ]; then
            #echo "$CHECK_ON_BITSTREAM_ERR_MSG Please, use ${bold}$CLI_NAME build $arguments.${normal}"
            echo "Your targeted bitstream ($FDEV_NAME) is missing. Please, use ${bold}$CLI_NAME build $arguments.${normal}"
            echo ""
            exit 1
          fi
        done
        
        #driver check
        driver_path="$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/$ONIC_DRIVER_NAME"
        if ! [ -e "$driver_path" ]; then
          echo "Your targeted driver is missing. Please, use ${bold}$CLI_NAME build $arguments.${normal}"
          echo ""
          exit 1
        fi

        remote_dialog "$CLI_PATH" "$command" "$arguments" "$hostname" "$USER" "${flags_array[@]}"

        #run
        for i in "${!device_indexes[@]}"; do
          #$CLI_PATH/program/opennic --commit $commit_name --device $device_index --fec $fec_option --project $project_name --version $vivado_version --remote $deploy_option "${servers_family_list[@]}" 
          $CLI_PATH/program/opennic --commit $commit_name --device ${device_indexes[$i]} --fec $fec_option --project $project_name --version $vivado_version --remote $deploy_option "${servers_family_list[@]}" 
        done
        ;;
      reset)
        #early exit
        if { [[ "$is_acap" = "0" && "$is_fpga" = "0" ]]; } || [[ "$is_asoc" = "1" ]]; then
          exit
        fi

        #check on server
        #virtualized_check "$CLI_PATH" "$hostname"
        fpga_check "$CLI_PATH" "$hostname"

        #check on software  
        vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
        vivado_check "$VIVADO_PATH" "$vivado_version"

        #check on flags
        valid_flags="-d --device -h --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #checks (command line)
        if [ ! "$flags_array" = "" ]; then
          device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          workflow=$($CLI_PATH/get/workflow -d $device_index | grep -v '^[[:space:]]*$' | awk -F': ' '{print $2}' | xargs)
          if [ ! "$workflow" = "vitis" ]; then
              echo ""
              echo $CHECK_ON_REVERT_ERR_MSG
              echo ""
              exit
          fi
        fi

        xrt_check "$CLI_PATH"
        echo ""

        #dialogs
        echo "${bold}$CLI_NAME $command $arguments${normal}"
        echo ""
        device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
        workflow=$($CLI_PATH/get/workflow -d $device_index | grep -v '^[[:space:]]*$' | awk -F': ' '{print $2}' | xargs)
        if [ ! "$workflow" = "vitis" ]; then
            echo $CHECK_ON_REVERT_ERR_MSG
            echo ""
            exit
        fi
        xrt_shell_check "$CLI_PATH" "$device_index"

        #run
        $CLI_PATH/program/reset --device $device_index
        ;;
      revert)
        #early exit
        if [ "$is_acap" = "0" ] && [ "$is_asoc" = "0" ] && [ "$is_fpga" = "0" ]; then
          exit
        fi

        #check on server
        #virtualized_check "$CLI_PATH" "$hostname"
        fpga_check "$CLI_PATH" "$hostname"

        #check on software  
        vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
        vivado_check "$VIVADO_PATH" "$vivado_version"

        #check on flags
        valid_flags="-d --device -r --remote -v --version -h --help" # -v --version are not exposed and not shown in help command or completion
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #initialize
        device_found="0"
        device_index=""

        #checks (command line)
        if [ ! "$flags_array" = "" ]; then
          device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          remote_check "$CLI_PATH" "${flags_array[@]}"
        fi

        #dialogs
        if [ "$multiple_devices" = "0" ]; then
          device_found="1"
          device_index="1"
          #check on device_type
          device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
          if [ "$device_type" = "asoc" ]; then
            #get current_uuid
            upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
            product_name=$(ami_tool mfg_info -d $upstream_port | grep "Product Name" | awk -F'|' '{print $2}' | xargs)
            current_uuid=$(ami_tool overview | grep "^$upstream_port" | tr -d '|' | sed "s/$product_name//g" | awk '{print $2}')
            if [ "$current_uuid" = "$AVED_UUID" ]; then
              exit
            fi
          elif [ "$device_type" = "acap" ] || [ "$device_type" = "fpga" ]; then
            workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index)
            if [[ $workflow = "vitis" ]]; then
                exit
            fi
          fi
          echo ""
          echo "${bold}$CLI_NAME $command $arguments${normal}"
          echo ""
        elif [ "$device_found" = "0" ]; then   
          echo ""
          echo "${bold}$CLI_NAME $command $arguments${normal}"    
          echo ""
          device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          #check on device_type
          device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
          if [ "$device_type" = "asoc" ]; then
            #get current_uuid
            upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
            product_name=$(ami_tool mfg_info -d $upstream_port | grep "Product Name" | awk -F'|' '{print $2}' | xargs)
            current_uuid=$(ami_tool overview | grep "^$upstream_port" | tr -d '|' | sed "s/$product_name//g" | awk '{print $2}')
            if [ "$current_uuid" = "$AVED_UUID" ]; then
              exit
            fi
          elif [ "$device_type" = "acap" ] || [ "$device_type" = "fpga" ]; then
            workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index)
            if [[ $workflow = "vitis" ]]; then
                exit
            fi
          fi
        elif [ "$device_found" = "1" ]; then   
          #check on device_type
          device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
          if [ "$device_type" = "asoc" ]; then
            #get current_uuid
            upstream_port=$($CLI_PATH/get/get_fpga_device_param $device_index upstream_port)
            product_name=$(ami_tool mfg_info -d $upstream_port | grep "Product Name" | awk -F'|' '{print $2}' | xargs)
            current_uuid=$(ami_tool overview | grep "^$upstream_port" | tr -d '|' | sed "s/$product_name//g" | awk '{print $2}')
            if [ "$current_uuid" = "$AVED_UUID" ]; then
              exit
            fi
          elif [ "$device_type" = "acap" ] || [ "$device_type" = "fpga" ]; then
            workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index)
            if [[ $workflow = "vitis" ]]; then
                exit
            fi
          fi
          echo ""
          echo "${bold}$CLI_NAME $command $arguments${normal}"    
          echo ""
        fi

        remote_dialog "$CLI_PATH" "$command" "$arguments" "$hostname" "$USER" "${flags_array[@]}"

        #run
        $CLI_PATH/program/revert --device $device_index --version $vivado_version --remote $deploy_option "${servers_family_list[@]}"
        ;;
      vrt)
        #early exit
        if [ "$is_build" = "1" ] || [ "$vivado_enabled_asoc" = "0" ]; then
          exit
        fi

        #check on server
        fpga_check "$CLI_PATH" "$hostname"
        
        #check on groups
        vivado_developers_check "$USER"
        
        #check on software
        vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
        vivado_check "$VIVADO_PATH" "$vivado_version"
        gh_check "$CLI_PATH"
        ami_check "$AMI_TOOL_PATH"
      
        #check on flags
        valid_flags="-d --device -p --project -t --tag -r --remote -h --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #check on driver (on the contrary to OpenNIC, the driver must be present--at system level--before programming)
        if ! lsmod | grep -q ${AVED_DRIVER_NAME%.ko}; then
          echo ""
          echo "Your targeted driver ($AVED_DRIVER_NAME) is missing."
          echo ""
          exit
        fi

        #checks (command line)
        if [ ! "$flags_array" = "" ]; then
          tag_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$VRT_REPO" "$VRT_TAG" "${flags_array[@]}"
          device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
          remote_check "$CLI_PATH" "${flags_array[@]}"
        fi

        #dialogs
        tag_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$VRT_REPO" "$VRT_TAG" "${flags_array[@]}"
        tag_check_pwd "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "VRT_TAG"
        project_check_empty "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name"
        echo ""
        echo "${bold}$CLI_NAME $command $arguments (tag ID: $tag_name)${normal}"
        echo ""
        project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "${flags_array[@]}"
        #device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"

        #get devices from sh.cfg (device_dialog comes at the end)
        device_indexes=()
        if [ "$device_found" = "1" ]; then 
          device_indexes=("$device_index")
        elif [[ ( "$device_found" = "" || "$device_found" = "0" ) && -f "$MY_PROJECTS_PATH/$arguments/$tag_name/$project_name/sh.cfg" ]]; then 
          while IFS=":" read -r index name; do
            if [[ ${name// /} == "vrt" ]]; then
                device_indexes+=("$index")
            fi
          done < <(grep -v '^\[' "$MY_PROJECTS_PATH/$arguments/$tag_name/$project_name/sh.cfg")

          #there is at least one onic device
          if [[ ${#device_indexes[@]} -gt 0 ]]; then
            device_found="1"
          fi
        fi

        #final check
        if [ "$device_found" = "" ] || [ "$device_found" = "0" ]; then
          device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          device_indexes=("$device_index")

          #add to sh.cfg
          if [[ "$(cat "$MY_PROJECTS_PATH/$arguments/$tag_name/$project_name/sh.cfg")" == "[workflows]" ]]; then
            if [[ -n "$device_index" ]]; then
                echo "$device_index: vrt" >> "$MY_PROJECTS_PATH/$arguments/$tag_name/$project_name/sh.cfg"
            fi
          fi
        fi

        #check on template
        VRT_TEMPLATE=$(cat $MY_PROJECTS_PATH/$arguments/$tag_name/$project_name/VRT_TEMPLATE)

        #vrtbin check
        vrtbin_path="$MY_PROJECTS_PATH/$arguments/$tag_name/$project_name/hw_all.$VRT_TEMPLATE.$vivado_version/${VRT_TEMPLATE}_hw.vrtbin"
        if ! [ -e "$vrtbin_path" ]; then
          echo "Your targeted VRT binary is missing. Please, use ${bold}$CLI_NAME build $arguments${normal} for ${bold}hw_all.${normal}"
          echo ""
          exit 1
        fi
        
        remote_dialog "$CLI_PATH" "$command" "$arguments" "$hostname" "$USER" "${flags_array[@]}"

        #run
        for i in "${!device_indexes[@]}"; do
          #$CLI_PATH/program/vrt --device $device_index --project $project_name --tag $tag_name --version $vivado_version --remote $deploy_option "${servers_family_list[@]}"
          $CLI_PATH/program/vrt --device ${device_indexes[$i]} --project $project_name --tag $tag_name --version $vivado_version --remote $deploy_option "${servers_family_list[@]}"
        done
        ;;
      xdp)
        #early exit
        if [ "$is_nic" = "0" ] || [ "$is_network_developer" = "0" ]; then
          exit 1
        fi

        #check on groups
        vivado_developers_check "$USER"
        
        #check on software
        gh_check "$CLI_PATH"

        #check on flags
        valid_flags="-c --commit -i --interface -p --project --start --stop -h --help" # -f --function 
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #initialize
        interface_found="0"
        start_found="0"

        #checks (command line)
        if [ ! "$flags_array" = "" ]; then
          #check on start/stop
          word_check "$CLI_PATH" "--start" "--start" "${flags_array[@]}"
          start_found=$word_found
          start_name=$word_value
          word_check "$CLI_PATH" "--stop" "--stop" "${flags_array[@]}"
          stop_found=$word_found
          stop_name=$word_value

          if [ "$stop_found" = "1" ] && [ "${#flags_array[@]}" -gt 2 ]; then
            exit
          elif [ "$stop_found" = "1" ]; then
            #echo "We need to take action"
            #check if the provided interface is already (xdp) otherwise error and then stop it by killing the pid

            #get XDP interfaces
            interfaces=($($CLI_PATH/common/get_interfaces $CLI_PATH))
            xdp_interfaces=()
            for i in "${interfaces[@]}"; do
              if ip link show "$i" | grep -q "xdp"; then
                xdp_interfaces+=("$i")
              fi
            done

            #check if the interface is an xdp interface
            if [ ${#xdp_interfaces[@]} -eq 0 ] || ! [[ " ${xdp_interfaces[@]} " =~ " $stop_name " ]]; then
                echo ""
                echo $CHECK_ON_IFACE_ERR_MSG
                echo ""
                exit
            fi

            #kill xdp propgram
            echo ""
            echo "${bold}Detaching XDP/eBPF function:${normal}"
            echo ""
            echo "sudo $CLI_PATH/program/xdp_detach $stop_name"
            echo ""            
            sudo $CLI_PATH/program/xdp_detach $stop_name
            exit
          elif [ "$stop_found" = "0" ]; then
            commit_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$XDP_BPFTOOL_REPO" "$XDP_BPFTOOL_COMMIT" "${flags_array[@]}"
            #device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
            iface_check "$CLI_PATH" "${flags_array[@]}"
            project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
            #remote_check "$CLI_PATH" "${flags_array[@]}"
          fi
        fi

        #early interface check (already XDP)
        if [ "$interface_found" = "1" ]; then
          if ip link show "$interface_name" | grep -q "xdp"; then
            echo ""
            #echo "$CHECK_ON_IFACE_ERR_MSG"
            echo "Sorry, the interface ${bold}$interface_name${normal} is already in use."
            echo ""
            exit
          fi
        fi

        #early XDP application check (already XDP)
        if [ "$project_found" = "1" ]; then
          if [ "$start_found" = "1" ] && ([ "$start_name" = "" ] || [ ! -e "$MY_PROJECTS_PATH/xdp/$commit_name/$project_name/$start_name" ]); then
            echo ""
            echo "Please, choose a valid XDP program."
            echo ""
            exit
          fi
        fi

        #dialogs
        commit_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$XDP_BPFTOOL_REPO" "$XDP_BPFTOOL_COMMIT" "${flags_array[@]}"
        project_check_empty "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name"
        echo ""
        echo "${bold}$CLI_NAME $command $arguments (commit ID: $commit_name)${normal}"
        echo ""
        project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
        #device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
        if [ "$interface_found" = "0" ]; then
          iface_dialog "$CLI_PATH" "$CLI_NAME" "${flags_array[@]}"
        fi

        #interface check (already XDP)
        if ip link show "$interface_name" | grep -q "xdp"; then
          echo "Sorry, the interface ${bold}$interface_name${normal} is already in use."
          echo ""
          exit
        fi

        #XDP programs check
        output_path="$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/.output"
        if ! [ -e "$output_path" ]; then
          echo "Your targeted XDP programs are missing. Please, use ${bold}$CLI_NAME build $arguments.${normal}"
          echo ""
          exit 1
        fi
        
        #start_name dialog
        if [ "$start_found" = "0" ]; then
          #get all eBPF/XDP programs
          folders=($(find "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/src" -mindepth 1 -maxdepth 1 -type d -printf "%f\n"))

          # Check if there are any folders
          if [[ ${#folders[@]} -eq 0 ]]; then
              #echo "No folders found in $functions."
              echo ""
              echo "Please, create an XDP/eBPF program first."
              echo ""
              exit 1
          fi

          # Display a menu using select
          PS3=""
          echo "${bold}Please, choose your program:${normal}"
          echo ""
          select folder in "${folders[@]}"; do
              if [[ -n "$folder" ]]; then
                  start_name=$folder
                  echo ""
                  break
              fi
          done
        fi

        #interface check (already XDP)
        #if ip link show "$interface_name" | grep -q "xdp"; then
        #  echo "Sorry, the interface ${bold}$interface_name${normal} is already in use."
        #  echo ""
        #  exit
        #fi

        #XDP application check
        if [ "$start_found" = "1" ] && ([ "$start_name" = "" ] || [ ! -e "$MY_PROJECTS_PATH/xdp/$commit_name/$project_name/$start_name" ]); then
          echo ""
          echo "Please, choose a valid XDP program."
          echo ""
          exit
        fi
        
        #run
        $CLI_PATH/program/xdp --commit $commit_name --interface $interface_name --project $project_name --start $start_name
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
      opennic)
        #early exit
        if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "0" ]; then
          exit
        fi

        #temporal exit condition
        if [ "$is_asoc" = "1" ]; then
            echo ""
            echo "Sorry, we are working on this!"
            echo ""
            exit
        fi

        #check on server
        fpga_check "$CLI_PATH" "$hostname"
        
        #check on groups
        vivado_developers_check "$USER"
        
        #check on software
        gh_check "$CLI_PATH"

        #check on flags
        valid_flags="--commit --config -p --project -h --help" #-d --device 
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #constants
        CONFIG_PREFIX="host_config_"

        #checks (command line)
        if [ ! "$flags_array" = "" ]; then
          commit_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$ONIC_SHELL_REPO" "$ONIC_SHELL_COMMIT" "${flags_array[@]}"
          #device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
          if [ "$project_found" = "1" ]; then
            config_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "$project_name" "$CONFIG_PREFIX" "yes" "${flags_array[@]}"
          fi
        fi

        #early onic workflow check
        #if [ "$device_found" = "1" ]; then
        #  workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index)
        #  if [ ! "$workflow" = "onic" ]; then
        #      echo ""
        #      echo "$CHECK_ON_WORKFLOW_ERR_MSG"
        #      echo ""
        #      exit
        #  fi
        #fi

        if [ "$project_found" = "0" ]; then
          add_echo="no"
        fi

        #dialogs
        commit_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$ONIC_SHELL_REPO" "$ONIC_SHELL_COMMIT" "${flags_array[@]}"
        commit_check_pwd "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "ONIC_SHELL_COMMIT"
        project_check_empty "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name"
        echo ""
        echo "${bold}$CLI_NAME $command $arguments (commit ID: $commit_name)${normal}"
        echo ""
        project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
        config_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "$project_name" "$CONFIG_PREFIX" "$add_echo" "${flags_array[@]}"
        if [ "$project_found" = "1" ] && [ ! -e "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/configs/$config_name" ]; then
            echo ""
            echo "$CHECK_ON_CONFIG_ERR_MSG"
            echo ""
            exit
        fi
        #device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"

        #get onic devices from sh.cfg (similar to hdev program opennic)
        if [ -f "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/sh.cfg" ]; then
          while IFS=":" read -r index name; do
            if [[ ${name// /} == "onic" ]]; then
                device_indexes+=("$index")
            fi
          done < <(grep -v '^\[' "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/sh.cfg")
        else
          #echo ""
          echo $CHECK_ON_SHELL_CFG_ERR_MSG
          echo ""
          exit 1
        fi

        #onic workflow check
        for i in "${!device_indexes[@]}"; do
          device_index_i="${device_indexes[$i]}"
          workflow=$($CLI_PATH/common/get_workflow $CLI_PATH $device_index_i)
          if [ ! "$workflow" = "onic" ]; then
            echo "$CHECK_ON_WORKFLOW_ERR_MSG"
            echo ""
            exit
          fi
        done

        #onic application check
        if [ ! -x "$MY_PROJECTS_PATH/$arguments/$commit_name/$project_name/onic" ]; then
          echo "Your targeted application is missing. Please, use ${bold}$CLI_NAME build $arguments.${normal}"
          echo ""
          exit 1
        fi

        #run
        $CLI_PATH/run/opennic --commit $commit_name --config $config_index --project $project_name 
        ;;
      sockperf)
        ##early exit
        if [ "$is_acap" = "0" ] && [ "$is_asoc" = "0" ] && [ "$is_fpga" = "0" ] && [ "$is_nic" = "0" ]; then
          exit
        fi

        #check on server
        #fpga_check "$CLI_PATH" "$hostname"
        
        #check on groups
        #vivado_developers_check "$USER"
        
        #check on software
        software_check "sockperf"

        #check on flags
        valid_flags="-i --interface --server --size -h --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #checks (command line)
        if [ "$flags_array" = "" ]; then
          echo ""
          echo "Your targeted interface and server are missing."
          echo ""
          exit 1
        else
          #check on flags
          word_check "$CLI_PATH" "-i" "--interface" "${flags_array[@]}"
          interface_found=$word_found
          interface_name=$word_value

          word_check "$CLI_PATH" "--server" "--server" "${flags_array[@]}"
          server_found=$word_found
          server_ip=$word_value

          word_check "$CLI_PATH" "--size" "--size" "${flags_array[@]}"
          size_found=$word_found
          size_value=$word_value

          #check on flags
          if [[ "$interface_found" == "0" && "$server_found" == "0" ]]; then
            run_sockperf_help
          elif [[ "$interface_found" == "0" && "$server_found" == "1" ]]; then
            if [ "$server_ip" == "" ]; then
              run_sockperf_help
            else
              #check on IP
              if ! ipv4_check "$server_ip"; then
                  echo ""
                  echo $CHECK_ON_IP_ERR_MSG
                  echo ""
                  exit 1
              fi

              #kill server first
              #sudo $CLI_PATH/common/pkill "sockperf server"

              #start server
              echo ""
              echo "${bold}Running sockperf server:${normal}"
              echo ""
              echo "sudo $CLI_PATH/common/pkill "sockperf server""
              echo "sockperf server --tcp -i $server_ip"
              echo ""
              sudo $CLI_PATH/common/pkill "sockperf server"
              sockperf server --tcp -i $server_ip
              echo ""
              exit 0
            fi
          fi
          
          #check on interface
          if [[ "$interface_found" == "1" && "$interface_name" == "" ]]; then
            run_sockperf_help
          elif [ "$interface_found" == "1" ]; then
            if ! ifconfig "$interface_name" >/dev/null 2>&1; then
              echo ""
              echo $CHECK_ON_IFACE_ERR_MSG
              echo ""
              exit 1
            fi
          fi

          #check on server
          if [[ "$server_found" == "1" && "$server_ip" == "" ]]; then
            run_sockperf_help
          elif [ "$server_found" == "1" ]; then
            if ! ipv4_check "$server_ip"; then
                echo ""
                echo $CHECK_ON_IP_ERR_MSG
                echo ""
                exit 1
            fi
          fi
        fi

        #check on size
        if [[ "$size_found" == "1" && "$size_value" == "" ]]; then
          run_sockperf_help
        elif [ "$size_found" == "0" ]; then
          size_value="1024"
        elif [ "$size_found" == "1" ]; then
          safe_msg_size=$(( $(cat /proc/sys/net/core/wmem_max) / 4 ))
          SOCKPERF_MIN=${SOCKPERF_MIN//[!0-9]/}

          if (( size_value < SOCKPERF_MIN || size_value > safe_msg_size )); then
            echo ""
            echo "Please, choose a valid size value."
            echo ""
            exit 1
          fi
        fi

        #get local IP from interface
        local_ip=$(ifconfig $interface_name | grep 'inet ' | awk '{print $2}')

        #check on server (attempt a minimal ping-pong run)
        #echo "sockperf ping-pong --tcp -i "$server_ip" --client_ip "$local_ip" --msg-size 64 --mps 1 --time 1"
        echo ""
        echo "${bold}Checking on sockperf server:${normal}"
        echo ""
        command="sockperf ping-pong --tcp -i "$server_ip" --client_ip "$local_ip" --msg-size 64 --mps 100 --time 10"
        echo "$command"

        output=$(eval "$command" 2>&1)

        #echo $output
        if echo "$output" | grep -q "sockperf: ERROR"; then
          echo ""
          echo $output
          echo ""
          #echo $CHECK_ON_SOCKPERF_SERVER_ERR_MSG
          #echo ""
          exit 1
        fi

        #run
        $CLI_PATH/run/sockperf --interface $interface_name --server $server_ip --size $size_value
        ;;
      tensorflow)
        #early exit
        if [ "$is_build" = "0" ] && [ "$gpu_enabled" = "0" ]; then
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
        #early exit
        if [ "$is_build" = "1" ] || [ "$vivado_enabled_asoc" = "0" ]; then
            exit 1
        fi

        #check on groups
        vivado_developers_check "$USER"
        
        #check on software
        vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
        vivado_check "$VIVADO_PATH" "$vivado_version"
        gh_check "$CLI_PATH"

        #check on flags
        valid_flags="--tag --target --project -h --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #checks (command line)
        if [ ! "$flags_array" = "" ]; then
          tag_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$VRT_REPO" "$VRT_TAG" "${flags_array[@]}"
          project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "${flags_array[@]}"
          target_check "$CLI_PATH" "VRT_TARGETS" "${flags_array[@]}"
        fi
        
        #dialogs
        tag_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$VRT_REPO" "$VRT_TAG" "${flags_array[@]}"
        tag_check_pwd "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "VRT_TAG"
        project_check_empty "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name"
        echo ""
        echo "${bold}$CLI_NAME $command $arguments (tag ID: $tag_name)${normal}"
        echo ""
        project_dialog "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$tag_name" "${flags_array[@]}"
        target_dialog "$CLI_PATH" "VRT_TARGETS" "none" "$is_build" "${flags_array[@]}"

        #check on target
        VRT_TEMPLATE=$(cat $MY_PROJECTS_PATH/$arguments/$tag_name/$project_name/VRT_TEMPLATE)
        if [ ! -d "$MY_PROJECTS_PATH/$arguments/$tag_name/$project_name/$target_name.$VRT_TEMPLATE.$vivado_version" ]; then
          echo $CHECK_ON_TARGET_BUILD_ERR_MSG
          echo ""
          exit
        fi

        #run
        $CLI_PATH/run/vrt --project $project_name --tag $tag_name --target $target_name --version $vivado_version
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
        #early exit
        if [ "$is_build" = "1" ] || [ "$is_numa" = "0" ] || [ "$is_vivado_developer" = "0" ]; then
            exit 1
        fi

        #check on groups
        vivado_developers_check "$USER"

        valid_flags="-v --value -h --help"
        #command_run $command_arguments_flags"@"$valid_flags
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #checks (command line)
        if [ "$flags_array" = "" ]; then
          set_balancing_help
        else
          #value
          result="$("$CLI_PATH/common/value_dialog_check" "${flags_array[@]}")"
          value_found=$(echo "$result" | sed -n '1p')
          value=$(echo "$result" | sed -n '2p')

          #check on value
          value_check "$CLI_PATH" "0" "1" "balancing" "${flags_array[@]}"
        fi

        #run
        $CLI_PATH/set/balancing --value $value
        ;;
      gh)
        if [ "$#" -ne 2 ]; then
          set_gh_help
          exit 1
        fi
        eval "$CLI_PATH/set/gh"
        ;;
      hugepages)
        #early exit
        if [ "$is_build" = "1" ] || [ "$is_vivado_developer" = "0" ]; then
            exit 1
        fi

        #check on groups
        vivado_developers_check "$USER"

        valid_flags="-p --pages -s --size"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"
        
        #check on size
        word_check "$CLI_PATH" "-s" "--size" "${flags_array[@]}"
        size_found=$word_found
        size_id=$word_value
        if [[ ! "$size_id" =~ ^(2M|1G)$ ]]; then
          echo ""
          echo "Please, choose a valid value for size."
          echo ""
          exit 1
        fi
        
        #check on pages
        word_check "$CLI_PATH" "-p" "--pages" "${flags_array[@]}"
        pages_found=$word_found
        pages_value=$word_value

        #get maximum number of pages
        max_pages=$($CLI_PATH/common/get_max_hugepages $size_id)
        if [ "$pages_found" = "0" ] || [[ ! "$pages_value" =~ ^[0-9]+$ ]] || [ "$pages_value" -lt 1 ] || [ "$pages_value" -gt "$max_pages" ]; then
          echo ""
          echo "Please, choose a valid value for pages."
          echo ""
          exit
        fi

        #run
        $CLI_PATH/set/hugepages --size $size_id --pages $pages_value
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
        #early exit
        if [ "$is_vivado_developer" = "0" ]; then
            exit 1
        fi
        
        if [ "$#" -ne 2 ]; then
          set_license_help
          exit 1
        fi

        #check for vivado_developers
        member=$($CLI_PATH/common/is_member $USER vivado_developers)
        if [ "$member" = "0" ]; then
            echo ""
            echo "Sorry, ${bold}$USER!${normal} You are not granted to use this command."
            echo ""
            exit
        fi

        eval "$CLI_PATH/set/license-msg"
        ;;
      mtu)
        #early exit
        if [ "$is_build" = "1" ] || [ "$is_vivado_developer" = "0" ]; then
            exit 1
        fi

        #check on groups
        vivado_developers_check "$USER"

        valid_flags="-d --device -p --port -v --value -h --help"
        #command_run $command_arguments_flags"@"$valid_flags
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #checks (command line)
        if [ "$flags_array" = "" ]; then
          set_mtu_help
        else
          #device
          result="$("$CLI_PATH/common/device_dialog_check" "${flags_array[@]}")"
          device_found=$(echo "$result" | sed -n '1p')
          device_index=$(echo "$result" | sed -n '2p')
          #port
          result="$("$CLI_PATH/common/port_dialog_check" "${flags_array[@]}")"
          port_found=$(echo "$result" | sed -n '1p')
          port_index=$(echo "$result" | sed -n '2p')
          #value
          result="$("$CLI_PATH/common/value_dialog_check" "${flags_array[@]}")"
          mtu_value_found=$(echo "$result" | sed -n '1p')
          mtu_value=$(echo "$result" | sed -n '2p')

          #device and port are binded
          if [ "$device_found" = "1" ] && [ "$port_found" = "0" ] && [ "$mtu_value_found" = "0" ]; then
            device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices_networking" "$MAX_DEVICES_NETWORKING" "${flags_array[@]}"
          elif [ "$device_found" = "0" ] && [ "$port_found" = "1" ] && [ "$mtu_value_found" = "0" ]; then
            echo ""
            echo $CHECK_ON_DEVICE_ERR_MSG
            echo ""
            exit
          elif [ "$device_found" = "0" ] && [ "$port_found" = "0" ] && [ "$mtu_value_found" = "1" ]; then
            value_check "$CLI_PATH" "$MTU_MIN" "$MTU_MAX" "MTU" "${flags_array[@]}"
            echo ""
            echo $CHECK_ON_DEVICE_ERR_MSG
            echo ""
            exit
          fi
          
          #natural order
          device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices_networking" "$MAX_DEVICES_NETWORKING" "${flags_array[@]}"
          port_check "$CLI_PATH" "$CLI_NAME" "$device_index" "${flags_array[@]}"
          value_check "$CLI_PATH" "$MTU_MIN" "$MTU_MAX" "MTU" "${flags_array[@]}"
        fi

        #check on interface
        interface_name=$($CLI_PATH/get/get_nic_config $device_index $port_index DEVICE)
        if [ "$interface_name" = "" ]; then
            echo ""
            echo "Please, choose a valid interface."
            echo ""
            exit
        fi

        #run
        $CLI_PATH/set/mtu --device $device_index --port $port_index --value $mtu_value
        ;;
      performance)
        #early exit
        if [ "$is_gpu" = "0" ]; then
            exit 1
        fi

        valid_flags="-d --device -v --value -h --help"
        #command_run $command_arguments_flags"@"$valid_flags
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #checks (command line)
        if [ "$flags_array" = "" ]; then
          set_performance_help
        else
          #device
          result="$("$CLI_PATH/common/device_dialog_check" "${flags_array[@]}")"
          device_found=$(echo "$result" | sed -n '1p')
          device_index=$(echo "$result" | sed -n '2p')

          #value
          result="$("$CLI_PATH/common/value_dialog_check" "${flags_array[@]}")"
          value_found=$(echo "$result" | sed -n '1p')
          value=$(echo "$result" | sed -n '2p')

          #check on device
          if [ "$device_found" = "1" ]; then
            device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          fi

          #check on value
          if [[ "$value" != "low" && "$value" != "high" && "$value" != "auto" ]]; then
              echo ""
              echo $CHECK_ON_PERFORMANCE_ERR_MSG
              echo ""
              exit
          fi
        fi

        #run
        $CLI_PATH/set/performance --value $value --device $device_index
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
        #early exit
        if [ "$is_sudo" = "0" ]; then
          exit
        fi
        
        #check on sudo
        sudo_check $USER

        #check on flags
        #valid_flags="-h --help --latest -t --tag -n --number"
        #command_run $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$@"

        #check on number of parameters
        if [ "$#" -lt 2 ]; then
          update_help
          exit 1
        elif [ "$2" = "--latest" ]; then
          if [ "$#" -gt 2 ]; then
            update_help
            exit 1
          fi
          tag_name=$(gh release list -R "$HDEV_REPO" --limit 1 --json tagName --jq '.[0].tagName')
          pullrq_id="none"
        elif [ "$2" = "-n" ] || [ "$2" = "--number" ]; then
          word_check "$CLI_PATH" "-n" "--number" "${flags_array[@]}"
          pullrq_found=$word_found
          pullrq_id=$word_value

          #check on pullrq_id
          if [[ "$pullrq_found" == "1" && "$pullrq_id" == "" ]]; then
            echo ""
            echo $CHECK_ON_PR_ERR_MSG
            echo ""
            exit 1
          fi

          #check if PR exist
          exists_pr=$($CLI_PATH/common/gh_pr_check $GITHUB_CLI_PATH $HDEV_REPO $pullrq_id)
          if [ "$pullrq_found" = "1" ] && [ "$exists_pr" = "0" ]; then
            echo ""
            echo $CHECK_ON_PR_ERR_MSG
            $GITHUB_CLI_PATH/gh pr list --repo $HDEV_REPO
            echo ""
            exit 1
          fi
          tag_name="none"
        elif [ "$2" = "-t" ] || [ "$2" = "--tag" ]; then
          word_check "$CLI_PATH" "-t" "--tag" "${flags_array[@]}"
          tag_found=$word_found
          tag_name=$word_value
          tag_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$HDEV_REPO" "$tag_name" "${flags_array[@]}"
          pullrq_id="none"
        fi

        #get update.sh
        cd $UPDATES_PATH
        git clone $REPO_URL > /dev/null 2>&1 #https://github.com/fpgasystems/hdev.git

        #copy update
        sudo mv $UPDATES_PATH/$REPO_NAME/update.sh $HDEV_PATH/update
        
        #remove temporal copy
        rm -rf $UPDATES_PATH/$REPO_NAME

        #run up to date update 
        $HDEV_PATH/update --number $pullrq_id --tag $tag_name
        ;;
    esac
    ;;
  validate)
    #create workflow directory
    #mkdir -p "$MY_PROJECTS_PATH/$arguments"

    case "$arguments" in
      aved)
        #early exit
        if [ "$is_build" = "1" ] || [ "$vivado_enabled_asoc" = "0" ]; then
          exit
        fi

        #check on flags
        valid_flags="-d --device --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #checks (command line 2/2)
        if [ ! "$flags_array" = "" ]; then
          device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
          if [ ! "$device_type" = "asoc" ]; then
            echo ""
            echo "Sorry, this command is not available on device $device_index."
            echo ""
            exit
          fi
        fi

        #dialogs
        echo ""
        echo "${bold}$CLI_NAME $command $arguments (tag ID: $AVED_TAG)${normal}"
        #echo ""
        if [ "$multiple_devices" = "0" ]; then
          device_found="1"
          device_index="1"
        else
          echo ""
          device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          device_type=$($CLI_PATH/get/get_fpga_device_param $device_index device_type)
          if [ ! "$device_type" = "asoc" ]; then
            echo ""
            echo "Sorry, this command is not available on device $device_index."
            echo ""
            exit
          fi
        fi

        #run
        $CLI_PATH/validate/aved --device $device_index
        ;;
      docker)
        valid_flags="-h --help"
        command_run $command_arguments_flags"@"$valid_flags
        ;;
      opennic)
        #early exit
        if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "0" ]; then
          exit
        fi

        #create workflow directory
        mkdir -p "$MY_PROJECTS_PATH/$arguments"

        #temporal exit condition
        if [ "$is_asoc" = "1" ]; then
            echo ""
            echo "Sorry, we are working on this!"
            echo ""
            exit
        fi

        #check on server
        #virtualized_check "$CLI_PATH" "$hostname"
        fpga_check "$CLI_PATH" "$hostname"

        #check on groups
        vivado_developers_check "$USER"

        #check on software
        vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
        vivado_check "$VIVADO_PATH" "$vivado_version"
        gh_check "$CLI_PATH"

        #check on flags
        valid_flags="-c --commit -d --device -f --fec -h --help"
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #checks (command line 1/2 - check_on_commits)
        commit_found_shell=""
        commit_name_shell=""
        commit_found_driver=""
        commit_name_driver=""
        if [ "$flags_array" = "" ]; then
            #commit dialog
            commit_found_shell="1"
            commit_found_driver="1"
            commit_name_shell=$ONIC_SHELL_COMMIT
            commit_name_driver=$ONIC_DRIVER_COMMIT
        else
            #commit_dialog_check
            result="$("$CLI_PATH/common/commit_dialog_check" "${flags_array[@]}")"
            commit_found=$(echo "$result" | sed -n '1p')
            commit_name=$(echo "$result" | sed -n '2p')

            #check if commit_name contains exactly one comma
            if [ "$commit_found" = "1" ] && { [ "$commit_name" = "" ] || ! [[ "$commit_name" =~ ^[^,]+,[^,]+$ ]]; }; then #if [ "$commit_found" = "1" ] && ! [[ "$commit_name" =~ ^[^,]+,[^,]+$ ]]; then
                echo ""
                echo "Please, choose valid shell and driver commit IDs."
                echo ""
                exit
            fi
            
            #get shell and driver commits (shell_commit,driver_commit)
            commit_name_shell=${commit_name%%,*}
            commit_name_driver=${commit_name#*,}

            #check if commits exist
            exists_shell=$($CLI_PATH/common/gh_commit_check $GITHUB_CLI_PATH $ONIC_SHELL_REPO $commit_name_shell)
            exists_driver=$($CLI_PATH/common/gh_commit_check $GITHUB_CLI_PATH $ONIC_DRIVER_REPO $commit_name_driver)

            if [ "$commit_found" = "0" ]; then 
                commit_name_shell=$ONIC_SHELL_COMMIT
                commit_name_driver=$ONIC_DRIVER_COMMIT
            elif [ "$commit_found" = "1" ] && ([ "$commit_name_shell" = "" ] || [ "$exists_shell" = "0" ]); then
                echo ""
                echo "Please, choose a valid shell commit ID." # similar to CHECK_ON_COMMIT_ERR_MSG
                echo ""
                exit 1
            elif [ "$commit_found" = "1" ] && ([ "$commit_name_driver" = "" ] || [ "$exists_driver" = "0" ]); then
                echo ""
                echo "Please, choose a valid driver commit ID." # similar to CHECK_ON_COMMIT_ERR_MSG
                echo ""
                exit 1
            fi
        fi
        #echo ""

        #initialize
        device_found="0"
        device_index=""
        fec_option_found="0"
        fec_option=""

        #checks (command line 2/2)
        if [ ! "$flags_array" = "" ]; then
          device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          fec_check "$CLI_PATH" "${flags_array[@]}"
        fi

        if [ "$multiple_devices" = "0" ]; then
          device_found="1"
          device_index="1"
          #bitstream check (the bitstream must be pre-compiled for validation)
          FDEV_NAME=$($CLI_PATH/common/get_FDEV_NAME $CLI_PATH $device_index)
          bitstream_path="$BITSTREAMS_PATH/$arguments/$commit_name_shell/${ONIC_SHELL_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
          if ! [ -e "$bitstream_path" ]; then
            echo ""
            echo "$CHECK_ON_BITSTREAM_ERR_MSG"
            echo ""
            exit 1
          fi
          echo ""
          echo "${bold}$CLI_NAME $command $arguments (shell and driver commit IDs: $commit_name_shell,$commit_name_driver)${normal}"
          echo ""
        else
          echo ""
          echo "${bold}$CLI_NAME $command $arguments (shell and driver commit IDs: $commit_name_shell,$commit_name_driver)${normal}"
          echo ""
          device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
        fi

        #get device_name
        device_name=$($CLI_PATH/get/get_fpga_device_param $device_index device_name)

        #check on compatible device
        if ! grep -Fxq "$device_name" "$ONIC_DEVICE_NAMES"; then
          echo "Sorry, this command is not available for ${bold}$device_name.${normal}"
          echo ""
          exit 1
        fi

        #bitstream check (the bitstream must be pre-compiled for validation)
        #FDEV_NAME=$($CLI_PATH/common/get_FDEV_NAME $CLI_PATH $device_index)
        FDEV_NAME=$(echo "$device_name" | cut -d'_' -f2)
        bitstream_path="$BITSTREAMS_PATH/$arguments/$commit_name_shell/${ONIC_SHELL_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
        if ! [ -e "$bitstream_path" ]; then
          echo "$CHECK_ON_BITSTREAM_ERR_MSG"
          echo ""
          exit 1
        fi

        #dialogs
        if [ "$fec_option_found" = "0" ]; then
          echo "${bold}Please, choose your encoding scheme:${normal}"
          echo ""
          echo "0) RS_FEC_ENABLED = 0"
          echo "1) RS_FEC_ENABLED = 1"
          while true; do
              read -p "" choice
              case $choice in
                  "0")
                      fec_option="0"
                      break
                      ;;
                  "1")
                      fec_option="1"
                      break
                      ;;
              esac
          done
          echo ""
        fi

        #run
        $CLI_PATH/validate/opennic --commit $commit_name_shell $commit_name_driver --device $device_index --fec $fec_option --version $vivado_version
        ;;
      tensorflow)
        #early exit
        if [ "$is_build" = "1" ] || [ "$gpu_enabled" = "0" ]; then
          exit
        fi

        #create workflow directory
        mkdir -p "$MY_PROJECTS_PATH/$arguments"

        #valid_flags="-d --device -h --help"
        #command_run $command_arguments_flags"@"$valid_flags

        echo "HEY! Continue here"

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
        #early exit
        if [ "$is_build" = "1" ] || [ "$vivado_enabled_asoc" = "0" ]; then
          exit
        fi

        #check on server
        fpga_check "$CLI_PATH" "$hostname"
        
        #check on groups
        vivado_developers_check "$USER"
        
        #check on software
        vivado_version=$($CLI_PATH/common/get_xilinx_version vivado)
        vivado_check "$VIVADO_PATH" "$vivado_version"
        gh_check "$CLI_PATH"
        ami_check "$AMI_TOOL_PATH"
      
        #check on flags
        #if [ "$is_hdev_developer" = "1" ]; then
          valid_flags="-d --device -n --number --tag --target -h --help"
        #else
        #  valid_flags="-d --device --tag --target -h --help"
        #fi
        flags_check $command_arguments_flags"@"$valid_flags

        #inputs (split the string into an array)
        read -r -a flags_array <<< "$flags"

        #check on driver (on the contrary to OpenNIC, the driver must be present--at system level--before programming)
        if ! lsmod | grep -q ${AVED_DRIVER_NAME%.ko}; then
          echo ""
          echo "Your targeted driver ($AVED_DRIVER_NAME) is missing."
          echo ""
          exit
        fi

        #checks (command line)
        pullrq_found="0"
        pullrq_id="none"
        exists_pr="0"
        if [ ! "$flags_array" = "" ]; then
          #check on PR
          if [ "$is_hdev_developer" = "1" ]; then
            word_check "$CLI_PATH" "-n" "--number" "${flags_array[@]}"
            pullrq_found=$word_found
            #pullrq_id=$word_value

            #check on pullrq_id
            if [[ "$pullrq_found" == "1" && "$pullrq_id" == "" ]]; then
              echo ""
              echo $CHECK_ON_PR_ERR_MSG
              echo ""
              exit 1
            elif [ "$pullrq_found" == "1" ]; then
              pullrq_id=$word_value
            fi

            #check if PR exist
            exists_pr=$($CLI_PATH/common/gh_pr_check $GITHUB_CLI_PATH $VRT_REPO $pullrq_id)
            if [ "$pullrq_found" = "1" ] && [ "$exists_pr" = "0" ]; then
              $GITHUB_CLI_PATH/gh pr list --repo $VRT_REPO
              echo ""
              echo $CHECK_ON_PR_ERR_MSG
              echo ""
              exit 1
            fi
          fi

          #either pullrq_id or tag_name
          if [ "$exists_pr" = "1" ]; then
            tag_found="1"
            tag_name=$VRT_TAG
          else
            tag_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$GITHUB_CLI_PATH" "$VRT_REPO" "$VRT_TAG" "${flags_array[@]}"
          fi
          device_check "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
          target_check "$CLI_PATH" "VRT_TARGETS" "${flags_array[@]}"
          #project_check "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "$commit_name" "${flags_array[@]}"
          #remote_check "$CLI_PATH" "${flags_array[@]}"
        fi

        #dialogs
        tag_dialog "$CLI_PATH" "$CLI_NAME" "$MY_PROJECTS_PATH" "$command" "$arguments" "$GITHUB_CLI_PATH" "$VRT_REPO" "$VRT_TAG" "${flags_array[@]}"
        tag_check_pwd "$CLI_PATH" "$MY_PROJECTS_PATH" "$arguments" "VRT_TAG"
        echo ""
        echo "${bold}$CLI_NAME $command $arguments (tag ID: $tag_name)${normal}"
        echo ""
        device_dialog "$CLI_PATH" "$CLI_NAME" "$command" "$arguments" "$multiple_devices" "$MAX_DEVICES" "${flags_array[@]}"
        target_dialog "$CLI_PATH" "VRT_TARGETS" "none" "$is_build" "${flags_array[@]}"

        remove_project="1"
        if [ ! "$pullrq_id" = "none" ]; then
          remove_project="0"
        fi

        #run
        $CLI_PATH/validate/vrt --device $device_index --tag $tag_name --target $target_name  --version $vivado_version --number $pullrq_id --remove $remove_project
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
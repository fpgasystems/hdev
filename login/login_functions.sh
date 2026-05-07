#!/bin/bash

print_os_info() {
  # load OS release environment variables for eg. PRETTY_NAME, NAME and VERSION
  local PRETTY_NAME NAME VERSION
  source /etc/os-release

  #print operating system information
  echo "The server ${bold}$(hostname -s)${normal} is ready to work with ${bold}$PRETTY_NAME${normal}:"
  echo ""
  echo "    Full OS version : ${bold}$NAME $VERSION${normal}"
  echo "    Linux kernel    : ${bold}$(uname -r)${normal}"
  echo "    Uptime          : ${bold}$(uptime -p)${normal}"
  echo ""
}

print_FPGA_tools_info() {
  if ! type module >/dev/null 2>&1; then
    source /etc/profile.d/modules.sh
  fi

  # Vivado
  local loaded_vivado_version=$(module list 2>&1 | grep -oP 'vivado/\K\S+')
  local available_vivado_versions
  mapfile -t available_vivado_versions < <( module avail -t 2>&1  | grep '^vivado/' | awk -F'/' '{print $2}' )

  case ${#available_vivado_versions[@]} in
    0)
      echo "No Xilinx Tools (Vivado, Vitis, Vitis_HLS) are installed on this server."
      ;;
    1)
      echo "Version ${bold}$available_vivado_versions${normal} of the Xilinx Tools (XRT, Vivado, Vitis, Vitis_HLS) is installed on this server."
      ;;
    *)
      echo "Multiple versions of the Xilinx Tools (Vivado, Vitis, Vitis_HLS) are installed on this server: ${bold}${available_vivado_versions[@]}${normal}."
      [[ -z $loaded_vivado_version ]] && echo "No version has been loaded by default."
      [[ ! -z $loaded_vivado_version ]] && echo "Version ${bold}$loaded_vivado_version${normal} has been loaded by default."
      echo "Load them into the environment using:"
      echo ""
      echo "    Vivado, Vitis, Vitis_HLS    : ${bold}module load vivado/<release>${normal}"
      # TODO: move xrt also to environment modules
      echo "    XRT                         : ${bold}source /opt/hdev/cli/enable/xrt${normal}"
      echo ""
      echo "You can swap between modules using the following:"
      echo "    ${bold}'module unload vivado && module load vivado/<release>'${normal} or ${bold}'module swap vivado/<current-release> vivado/<new-release>'${normal}"
      ;;
  esac
  echo ""

  #TODO: Print the devices installed in the server
}

#print ROCm/HIP information and setup devices
print_GPU_tools_info() {
  if ! type module >/dev/null 2>&1; then
    source /etc/profile.d/modules.sh
  fi

  local loaded_rocm_version=$(module list 2>&1 | grep -oP 'rocm/\K\S+')
  local available_rocm_versions
  mapfile -t available_rocm_versions < <( module avail -t 2>&1  | grep '^rocm/' | awk -F'/' '{print $2}' )

  local amdgpu_kernel_version
  if [[ -d /sys/module/amdgpu ]]; then
    amdgpu_kernel_version=$(modinfo -F version amdgpu 2>/dev/null)
  fi
  case ${#available_rocm_versions[@]} in
    0)
      echo "No ROCm versions are installed on this server."
      ;;
    1)
      echo "ROCm version ${bold}$available_rocm_versions${normal} is installed on this server."
      ;;
    *)
      echo "Multiple ROCm versions  are installed on this server: ${bold}${available_rocm_versions[@]}${normal}."
      echo "Select your prefered version using the 'module' command."
      ;;
  esac
  echo ""
  echo "    Loaded ROCm runtime version         : ${bold}${loaded_rocm_version:-'No ROCM version loaded'}${normal}"
  echo "    AMDGPU Kernel Version               : ${bold}${amdgpu_kernel_version:-'AMDGPU kernel not loaded'}${normal}"
  echo ""
}

print_module_help() {
  echo "The 'module' command allows for easy swapping of Bash Environment Variables. See all modules that are available using: ${bold}module avail${normal}"
  echo "More modules will follow in the future. If you have a request please send them to hacc@ethz.ch with the subject starting with '[Feature Request]'."
echo ""
}

revert_devices() {
  declare -A device_workflow_map
  declare -a devices_to_revert=()

  while read -r key value; do
    [[ -z $key ]] && continue
    local key=${key%:}                 # remove trailing colon
    local device_workflow_map["$key"]="$value"
  done < <($CLI_PATH/get/workflow)

  for k in "${!device_workflow_map[@]}"; do
    line=$(awk -v id="$k" '$1 == id {print; exit}' $CLI_PATH/devices_acap_fpga)

    # Extract type field: fpga / acap / asoc
    local device_type=$(awk '{print $5}' <<<"$line")
    local workflow="${device_workflow_map[$k]}"

    case "$device_type" in
      fpga|acap)
        if [[ "$workflow" != "vitis" ]]; then
          devices_to_revert+=("$k")
        fi
        ;;
      asoc)
        if [[ "$workflow" != "aved" ]]; then
          devices_to_revert+=("$k")
        fi
        ;;
    esac
  done

  #revert devices
  if [ ${#devices_to_revert[@]} -gt 0 ]; then
    echo "One or more reconfigurable devices need to be reverted to default fabric. ${bold}Do you want to continue (y/n)?${normal}"
    while true; do
      read -p "" yn
      case $yn in
        "y")
          for dev in ${devices_to_revert[@]}; do
            local workflow="${device_workflow_map[$dev]}"
            case $workflow in
              coyote)
                sudo rmmod coyote_driver
                ;;
            esac
            # TODO make more robust (don't rely on vivado 2024.2 explicitly)
            $CLI_PATH/program/revert --device $dev --version 2024.2 --remote 0
          done

          #get loaded drivers
          if [ -d "$MY_DRIVERS_PATH" ]; then

            for file in "$MY_DRIVERS_PATH"/*; do
              driver=$(basename "$file")

              if lsmod | grep -q "${driver%.*}"; then
                # Driver is currently loaded -> unload it
                sudo rmmod "${driver%.*}" 2>/dev/null # with 2>/dev/null we avoid printing a message if the module does not exist
              fi
            done

            #delete drivers folder
            rm -rf $MY_DRIVERS_PATH
          fi

          break
          ;;
        "n")
          echo ""
          break
          ;;
      esac
    done
  fi
}

kill_other_user_processes() {
  #kill processes from other users
  for i in $(ps aux | awk '{ print $1 }' | sed '1 d' | sort | uniq); 
  do
    grep ^$i: /etc/passwd &>/dev/null || ( getent passwd $i &>/dev/null && [ "$i" != "$SUDO_USER" ] && killall -u $i );
  done
}


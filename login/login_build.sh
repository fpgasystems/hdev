#!/bin/bash

CLI_NAME="hdev"
CLI_PATH="/opt/$CLI_NAME/cli"
bold=$(tput bold)
normal=$(tput sgr0)

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
}

print_FPGA_tools_info() {
  echo "Xilinx Tools (XRT, Vivado, Vitis, Vitis_HLS) are not loaded into the environment by default"
  echo "Load them into the environment using:"
  echo ""
  echo "    Vivado, Vitis, Vitis_HLS    : ${bold}module load vivado/<release>${normal}"
  # TODO: move xrt also to environment modules
  echo "    XRT                         : ${bold}source /opt/hdev/cli/enable/xrt${normal}"
  echo ""
  echo "The 'module' command allows for easy swapping of Bash Environment Variables. See all modules that are available using: ${bold}module avail${normal}"
  echo "More modules will follow in the future. If you have a request please send them to hacc@ethz.ch with the subject starting with '[Feature Request]'."
}

username="${SUDO_USER:-$(id -un)}"

#skip welcome message for root
if [ "$username" = "root" ]; then
  exit 1
fi

echo ""
echo "${bold}Welcome, $username!${normal}"
echo ""

print_os_info
echo ""
print_FPGA_tools_info

echo ""
echo "${bold}Have a nice $(date +%A)!${normal}"
echo ""


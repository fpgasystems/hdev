#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
CLI_PATH="$(dirname "$0")"
XRT_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XRT_PATH)
DEVICE_LIST_NETWORK="$CLI_PATH/devices_network"
DEVICE_LIST_FPGA="$CLI_PATH/devices_acap_fpga"
DEVICE_LIST_GPU="$CLI_PATH/devices_gpu"
DEVICE_TYPE_NAME_STR_LENGTH=20
SERIAL_NUMBER_STR_LENGTH=13
NETWORKING_STR_LENGTH=33

#legend
COLOR_ON1=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_CPU)
COLOR_ON2=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_XILINX)
COLOR_ON3=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_ACAP)
COLOR_ON4=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_FPGA)
COLOR_ON5=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_GPU)
COLOR_OFF=$($CLI_PATH/common/get_constant $CLI_PATH COLOR_OFF)

split_addresses (){
  #input parameters
  str_ip=$1
  str_mac=$2
  aux=$3
  #save the current IFS
  OLDIFS=$IFS
  #set the IFS to / to split the string at each /
  IFS="/"
  #read the two parts of the string into variables
  read ip0 ip1 <<< "$str_ip"
  read mac0 mac1 <<< "$str_mac"
  #reset the IFS to its original value
  IFS=$OLDIFS
  #print the two parts of the string
  if [[ "$aux" == "0" ]]; then
    echo "$ip0 ($mac0)"
  else
    echo "$ip1 ($mac1)"
  fi
}

print_nic_devices_header (){
  echo -e "${bold}${COLOR_ON1}Device Index : BDF     : Device Type (Name)   : Networking                        : Device (state) ${COLOR_OFF}${normal}"
  echo -e "${bold}${COLOR_ON1}------------------------------------------------------------------------------------------------------------${COLOR_OFF}${normal}"
}

print_reconfigurable_devices_header (){
  echo -e "${bold}${COLOR_ON2}Device Index : BDF     : Device Type (Name)   : Serial Number : Networking                        : Workflow${COLOR_OFF}${normal}"
  echo -e "${bold}${COLOR_ON2}------------------------------------------------------------------------------------------------------------${COLOR_OFF}${normal}"
}

print_gpu_devices_header (){
  echo -e "${bold}${COLOR_ON5}Device Index : PCI BUS : Device Type (GPU ID) : Serial Number : Unique ID${COLOR_OFF}${normal}"
  echo -e "${bold}${COLOR_ON5}------------------------------------------------------------------------------------------------------------${COLOR_OFF}${normal}"
}

#declare string
legend=""

#run get topo
$CLI_PATH/get/topo

#nics
if [[ -s "$DEVICE_LIST_NETWORK" ]]; then
  #print if the first gpu is valid
  device_1=$(head -n 1 "$DEVICE_LIST_NETWORK")
  bdf_1=$(echo "$device_1" | awk '{print $2}')
  if [[ -n "$(lspci | grep $bdf_1)" ]]; then
    legend="${legend}${bold}${COLOR_ON1}NICs${COLOR_OFF}${normal}"
    print_nic_devices_header
    #get number of fpga and acap devices present
    MAX_NETWORK_DEVICES=$(grep -E "nic" $DEVICE_LIST_NETWORK | wc -l)
    #loop over reconfigurable devices
    for ((i=1; i<=$MAX_NETWORK_DEVICES; i++)); do
      id=$($CLI_PATH/get/get_nic_device_param $i id)
      #print table
      if [ -n "$id" ]; then  
        bdf=$($CLI_PATH/get/get_nic_device_param $i bdf)
        device_type=$($CLI_PATH/get/get_nic_device_param $i device_type)
        device_name=$($CLI_PATH/get/get_nic_device_param $i device_name)
        ip=$($CLI_PATH/get/get_nic_device_param $i IP)
        mac=$($CLI_PATH/get/get_nic_device_param $i MAC)
        #adjust device type and name string length
        aux="$device_type ($device_name)"
        diff=$(( $DEVICE_TYPE_NAME_STR_LENGTH - ${#aux} ))
        device_type_name="$aux$(printf '%*s' $diff)"
        #split ip
        add_0=$(split_addresses $ip $mac 0)
        add_1=$(split_addresses $ip $mac 1)
        #adjust networking string length
        diff=$(( $NETWORKING_STR_LENGTH - ${#add_0} ))
        add_0="$add_0$(printf '%*s' $diff)"
        add_1="$add_1$(printf '%*s' $diff)"
        #get DEVICE and STATE (ports 1 and 2)
        DEVICE_1=$($CLI_PATH/get/get_nic_config $i 1 DEVICE)
        if [ ! "$DEVICE_1" = "" ]; then
          STATE_1=$($CLI_PATH/get/get_nic_config $i 1 STATE)
          STATE_1="($STATE_1)"
        fi
        DEVICE_2=$($CLI_PATH/get/get_nic_config $i 2 DEVICE)
        if [ ! "$DEVICE_2" = "" ]; then
          STATE_2=$($CLI_PATH/get/get_nic_config $i 2 STATE)
          STATE_2="($STATE_2)"
        fi
        #print row
        echo "$id            : $bdf : $device_type_name : $add_0 : $DEVICE_1 $STATE_1"
        echo "                                                $add_1 " " $DEVICE_2 $STATE_2"
      fi
    done
    echo ""
  fi
fi

#reconfigurable devices
if [[ -s "$DEVICE_LIST_FPGA" ]]; then
  #print if the first fpga/acap is valid
  device_1=$(head -n 1 "$DEVICE_LIST_FPGA")
  upstream_port_1=$(echo "$device_1" | awk '{print $2}')
  if [[ -n "$(lspci | grep $upstream_port_1)" ]]; then
    legend="${legend} ${bold}${COLOR_ON2}Adaptive Devices${COLOR_OFF}${normal}"
    print_reconfigurable_devices_header
    #get number of fpga and acap devices present
    MAX_RECONF_DEVICES=$(grep -E "fpga|acap|asoc" $DEVICE_LIST_FPGA | wc -l)
    #loop over reconfigurable devices
    for ((i=1; i<=$MAX_RECONF_DEVICES; i++)); do
      id=$($CLI_PATH/get/get_fpga_device_param $i id)
      #print table
      if [ -n "$id" ]; then
        #after Vitis discontinued BDF is the upstream_port (function .0) 
        upstream_port=$($CLI_PATH/get/get_fpga_device_param $i upstream_port)
        device_type=$($CLI_PATH/get/get_fpga_device_param $i device_type)
        device_name=$($CLI_PATH/get/get_fpga_device_param $i device_name)
        serial_number=$($CLI_PATH/get/get_fpga_device_param $i serial_number)
        ip=$($CLI_PATH/get/get_fpga_device_param $i IP)
        mac=$($CLI_PATH/get/get_fpga_device_param $i MAC)
        workflow=$($CLI_PATH/get/workflow -d $i)
        workflow=$(echo "$workflow" $i | cut -d' ' -f2 | sed '/^\s*$/d')
        #adjust device type and name string length
        aux="$device_type ($device_name)"
        diff=$(( $DEVICE_TYPE_NAME_STR_LENGTH - ${#aux} ))
        device_type_name="$aux$(printf '%*s' $diff)"
        #adjust serial number string length
        diff=$(( $SERIAL_NUMBER_STR_LENGTH - ${#serial_number} ))
        serial_number="$serial_number$(printf '%*s' $diff)"
        #split ip
        add_0=$(split_addresses $ip $mac 0)
        add_1=$(split_addresses $ip $mac 1)
        #adjust networking string length
        diff=$(( $NETWORKING_STR_LENGTH - ${#add_0} ))
        add_0="$add_0$(printf '%*s' $diff)"
        add_1="$add_1$(printf '%*s' $diff)"
        #convert to capital
        add_0=$(echo "$add_0" | tr '[:lower:]' '[:upper:]')
        add_1=$(echo "$add_1" | tr '[:lower:]' '[:upper:]')
        #print row
        echo "$id            : $upstream_port : $device_type_name : $serial_number : $add_0 : $workflow"
        echo "                                                                $add_1"
      fi
    done
    echo ""
  fi
fi

#GPU devices
if [[ -s "$DEVICE_LIST_GPU" ]]; then
  #print if the first gpu is valid
  device_1=$(head -n 1 "$DEVICE_LIST_GPU")
  bus_1=$(echo "$device_1" | awk '{print $2}')
  if [[ -n "$(lspci | grep $bus_1)" ]]; then
    legend="${legend} ${bold}${COLOR_ON5}GPUs${COLOR_OFF}${normal}"
    print_gpu_devices_header
    #get number of gpu devices present
    MAX_GPU_DEVICES=$(grep -E "gpu" $DEVICE_LIST_GPU | wc -l)
    #loop over gpu devices
    for ((i=1; i<=$MAX_GPU_DEVICES; i++)); do
      id=$($CLI_PATH/get/get_gpu_device_param $i id)
      #print table
      if [ -n "$id" ]; then
        bus=$($CLI_PATH/get/get_gpu_device_param $i bus)
        device_type=$($CLI_PATH/get/get_gpu_device_param $i device_type)
        gpu_id=$($CLI_PATH/get/get_gpu_device_param $i gpu_id)
        serial_number=$($CLI_PATH/get/get_gpu_device_param $i serial_number)
        unique_id=$($CLI_PATH/get/get_gpu_device_param $i unique_id)
        #print row
        echo "$id            : $bus : $device_type ($gpu_id)         : $serial_number  : $unique_id" 
      fi
    done
    echo ""
  fi
fi

#print legend
if [[ -n "$legend" ]]; then
  echo -e "$legend"
  echo ""
fi
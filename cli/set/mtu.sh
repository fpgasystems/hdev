#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

MTU_MAX=$("$CLI_PATH/common/get_constant" "$CLI_PATH" MTU_MAX)
MTU_MIN=$("$CLI_PATH/common/get_constant" "$CLI_PATH" MTU_MIN)
DEVICE_FILE="$CLI_PATH/devices_network"

print_usage_set_mtu() {
  echo ""
  echo "${bold}$CLI_NAME set mtu [flags] [--help]${normal}"
  echo ""
  echo "Set the MTU of a network device/port."
  echo ""
  echo "FLAGS:"
  echo "  ${bold}-d, --device${normal}   Device index (according to '${bold}$CLI_NAME examine${normal}')."
  echo "  ${bold}-p, --port${normal}     Port number on the device (1 or 2)."
  echo "  ${bold}-v, --value${normal}    MTU value between ${bold}$MTU_MIN${normal} and ${bold}$MTU_MAX${normal} bytes."
  echo ""
  echo "  ${bold}-h, --help${normal}     Show this help message."
  echo ""
  echo "Example:"
  echo "  $CLI_NAME set mtu --device 1 --port 1 --value 9000"
  exit 1
}

get_iface_from_devices_network() {
  local device_index=$1
  local port_index=$2
  local device_file="/opt/hdev/cli/devices_network"

  if [[ -z "$device_index" || -z "$port_index" ]]; then
    echo "Error: internal: missing device_index or port_index in get_iface_from_devices_network" >&2
    return 1
  fi

  if [[ ! -f "$device_file" ]]; then
    echo "Error: device file not found: $device_file" >&2
    return 1
  fi

  # Get the Nth line (device_index is 1-based, lines are 1-based)
  local device_line
  device_line=$(sed -n "${device_index}p" "$device_file")

  if [[ -z "$device_line" ]]; then
    echo "Error: no device with index '$device_index' available on $HOSTNAME" >&2
    return 1
  fi

  # Expected line format:
  #   <id> <pci> <type> <model> <ip1>/<ip2> <mac1>/<mac2>
  local _id _pci _type _model _ips mac_field
  read -r _id _pci _type _model _ips mac_field <<< "$device_line"

  if [[ -z "$mac_field" ]]; then
    echo "Error: malformed line for device index '$device_index' in $device_file" >&2
    return 1
  fi

  # Extract MAC1 and MAC2 from mac_field (e.g. "MAC1/MAC2")
  local mac1 mac2 mac
  IFS='/' read -r mac1 mac2 <<< "$mac_field"

  case "$port_index" in
    1) mac="$mac1" ;;
    2) mac="$mac2" ;;
    *)
      echo "Error: unsupported port index '$port_index' (expected 1 or 2)" >&2
      return 1
      ;;
  esac

  if [[ -z "$mac" ]]; then
    echo "Error: no MAC address for device $device_index port $port_index" >&2
    return 1
  fi

  # Normalize MAC to lowercase
  mac=${mac,,}

  # Map MAC → interface using /sys/class/net
  local iface=""
  local path sys_mac
  for path in /sys/class/net/*; do
    [[ -e "$path/address" ]] || continue
    sys_mac=$(tr 'A-F' 'a-f' < "$path/address")
    if [[ "$sys_mac" == "$mac" ]]; then
      iface=$(basename "$path")
      break
    fi
  done

  if [[ -z "$iface" ]]; then
    echo "Error: no interface found for device $device_index port $port_index (MAC $mac)" >&2
    return 1
  fi

  echo "$iface"
}

# ----------------------------------------------------------------------
# early exit: permission checks
# ----------------------------------------------------------------------

url="${HOSTNAME}"
hostname="${url%%.*}"
is_build=$("$CLI_PATH/common/is_build" "$CLI_PATH" "$hostname")
is_vivado_developer=$("$CLI_PATH/common/is_member" "$USER" vivado_developers)

if [ "$is_build" = "1" ]; then
  echo "Error: setting MTU is not allowed on build servers." >&2
  exit 1
fi

if [ "$is_vivado_developer" = "0" ]; then
  echo "Error: you are not allowed to set MTU. Request permissions from the system administrator." >&2
  exit 1
fi

# ----------------------------------------------------------------------
# argument parsing (flags in any order)
# ----------------------------------------------------------------------

if [ $# -eq 0 ]; then
  print_usage_set_mtu
fi

device_index=""
port_index=""
mtu_value=""

while [ $# -gt 0 ]; do
  case "$1" in
    -d|--device)
      device_index="$2"
      shift 2
      ;;
    -p|--port)
      port_index="$2"
      shift 2
      ;;
    -v|--value)
      mtu_value="$2"
      shift 2
      ;;
    -h|--help)
      print_usage_set_mtu
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      print_usage_set_mtu
      ;;
  esac
done

# all inputs must be provided
if [ -z "$device_index" ] || [ -z "$port_index" ] || [ -z "$mtu_value" ]; then
  echo "Error: missing required flags. Device, port, and value are all required." >&2
  print_usage_set_mtu
fi

# ----------------------------------------------------------------------
# basic validation
# ----------------------------------------------------------------------

# MTU must be numeric
if ! [[ "$mtu_value" =~ ^[0-9]+$ ]]; then
  echo "Error: MTU value must be an integer, got: '$mtu_value'." >&2
  exit 1
fi

# verify MTU is between valid range (no rounding, just range check)
if [ "$mtu_value" -lt "$MTU_MIN" ] || [ "$mtu_value" -gt "$MTU_MAX" ]; then
  echo "Error: MTU value is out of range. Min MTU: $MTU_MIN, Max MTU: $MTU_MAX." >&2
  exit 1
fi

# device_index must be numeric
if ! [[ "$device_index" =~ ^[0-9]+$ ]]; then
  echo "Error: device index must be numeric, got '$device_index'." >&2
  exit 1
fi

# port_index must be 1 or 2
if [[ "$port_index" != "1" && "$port_index" != "2" ]]; then
  echo "Error: port index must be 1 or 2, got '$port_index'." >&2
  exit 1
fi

# sanity check: device file exists (get_iface_from_devices_network will also check)
if [[ ! -f "$DEVICE_FILE" ]]; then
  echo "Error: device file not found: $DEVICE_FILE" >&2
  exit 1
fi

# ----------------------------------------------------------------------
# get interface name from device/port
# ----------------------------------------------------------------------

interface_name=$(get_iface_from_devices_network "$device_index" "$port_index") || exit 1

# ----------------------------------------------------------------------
# set MTU using ip(8)
# ----------------------------------------------------------------------

# Check that interface exists (cheap sanity check)
if ! ip link show "$interface_name" >/dev/null 2>&1; then
  echo "Error: interface '$interface_name' not found." >&2
  exit 1
fi

echo "Setting MTU $mtu_value on device $device_index port $port_index (interface: $interface_name)..."

if ! sudo ip link set dev "$interface_name" mtu "$mtu_value"; then
  echo "Error: failed to set MTU $mtu_value on $interface_name." >&2
  exit 1
fi

echo "MTU successfully set."
echo ""
ip addr show "$interface_name"
echo ""

exit 0

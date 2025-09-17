#!/usr/bin/env bash
# get_interface.sh
# Usage:
#   get_interface path device_index port_index type representation
# Example:
#   ./get_interface.sh /opt/hdev/cli/devices_acap_fpga 2 1 ip hex

set -euo pipefail

usage() {
  echo "Usage: $0 <path> <device_index> <port_index> <type: ip|mac> <representation: decimal|hex>" >&2
  exit 1
}

[[ $# -eq 5 ]] || usage

path="$1"
device_index="$2"     # 1-based line number
port_index="$3"       # 0-based index into the '/'-separated list
type_in="$4"          # "ip" or "mac"
repr_in="$5"          # "decimal" or "hex"

# normalize
type="${type_in,,}"
repr="${repr_in,,}"

# --- Helpers ---

convert_ip_to_hex () {
  # Input: dotted quad, e.g., 10.253.74.112
  local ip="$1"
  # Basic validation
  if [[ ! "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    echo "Invalid IP address: $ip" >&2
    exit 2
  fi
  # shellcheck disable=SC2206
  local parts=(${ip//./ })
  printf '%02X%02X%02X%02X\n' "${parts[0]}" "${parts[1]}" "${parts[2]}" "${parts[3]}"
}

get_line() {
  local file="$1"
  local idx="$2"
  sed -n "${idx}p" "$file"
}

# --- Validations ---

[[ -f "$path" ]] || { echo "File not found: $path" >&2; exit 2; }
[[ "$device_index" =~ ^[0-9]+$ ]] || { echo "device_index must be a positive integer" >&2; exit 2; }
[[ "$port_index" =~ ^[0-9]+$ ]] || { echo "port_index must be a non-negative integer" >&2; exit 2; }

case "$type" in
  ip|mac) ;;
  *) echo "Invalid type: $type (use 'ip' or 'mac')" >&2; exit 2 ;;
esac

case "$repr" in
  decimal|hex) ;;
  *) echo "Invalid representation: $repr (use 'decimal' or 'hex')" >&2; exit 2 ;;
esac

# --- Extract the line and the requested column ---

line="$(get_line "$path" "$device_index" || true)"
[[ -n "$line" ]] || { echo "No such device_index (line $device_index) in $path" >&2; exit 2; }

# Columns are space-separated:
# 1:id ... 8:IP(s) 9:MAC(s) ...
# IPs: column 8 e.g. 10.253.74.112/10.253.74.113
# MACs: column 9 e.g. 00:0A:35:0F:5D:60/00:0A:35:0F:5D:64
ips="$(awk '{print $8}' <<<"$line")"
macs="$(awk '{print $9}' <<<"$line")"

field=""
if [[ "$type" == "ip" ]]; then
  field="$ips"
else
  field="$macs"
fi

# Split by '/'
IFS='/' read -r -a parts <<< "$field"

# Bounds check
if (( port_index < 0 || port_index >= ${#parts[@]} )); then
  echo "port_index $port_index out of range (only ${#parts[@]} port(s) found) for device_index $device_index" >&2
  exit 2
fi

value="${parts[$port_index]}"

# --- Representation handling ---

if [[ "$type" == "ip" ]]; then
  if [[ "$repr" == "hex" ]]; then
    convert_ip_to_hex "$value"
  else
    echo "$value"
  fi
else
  # type=mac -> representation is ignored; just return the MAC as-is
  # (If you later want hex without colons, add a case here.)
  echo "$value"
fi
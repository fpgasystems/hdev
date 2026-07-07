#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

max_percent_page_ram_usage=25 # percentage of memory per NUMA domain

usage() {
    echo ""
    echo "Usage: ${bold}hdev set hugepages [--num-2m N] [--num-1g N] [--node N]${normal}"
    echo ""
    echo "Set the number of hugepages per NUMA node and per page size. ('sudo' required)"
    echo ""
    echo "Options:"
    echo "  -m, --num-2m N      Set the number of 2 MiB hugepages."
    echo "  -g, --num-1g N      Set the number of 1 GiB hugepages."
    echo "  -n, --node N        NUMA node index (integer)."
    echo "                      If omitted, hugepages are set system-wide."
    echo "                      The number of hugepages are then equally split"
    echo "                      over all NUMA domains"
    echo "  -h, --help          Show this help message and exit."
    echo ""
    echo "Notes:"
    echo "  - At least one of --num-2m or --num-1g must be provided."
    echo "  - All N values must be non-negative integers."
    echo "  - The total hugepage memory must stay below"
    echo "    ${max_percent_page_ram_usage}% of RAM in each NUMA domain."
    echo ""
}

function check_max_pages_limit() {
  local num_2m="$1"
  local num_1g="$2"
  local numa_node="$3"    # can be -1 for system-wide

  # Read total RAM (system-wide) in kB
  # (we use system total as policy limit, independent of NUMA node)
  local memtotal_kb
  if [ "$numa_node" -lt 0 ]; then
    memtotal_kb=$(awk '/^MemTotal:/ {print $2}' /proc/meminfo)
    if [ -z "$memtotal_kb" ]; then
      echo "Unable to read total memory from /proc/meminfo" >&2
      return 1
    fi
  else
    memtotal_kb=$(awk '/^Node [0-9]+ MemTotal:/ {print $4}' "/sys/devices/system/node/node${numa_node}/meminfo" 2>/dev/null)
    if [ -z "$memtotal_kb" ]; then
      echo "Unable to read total memory from /sys/devices/system/node/node${numa_node}/meminfo" >&2
      return 1
    fi
  fi

  # Target hugepage counts
  if [ "$num_2m" -lt 0 ]; then
    if [ "$numa_node" -lt 0 ]; then
        # No node specified: use system-wide value
        num_2m=$(cat /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages)
    else
        # Specific NUMA node: use node-local value
        num_2m=$(cat "/sys/devices/system/node/node${numa_node}/hugepages/hugepages-2048kB/nr_hugepages")
    fi
  fi
  if [ "$num_1g" -lt 0 ]; then
    if [ "$numa_node" -lt 0 ]; then
        # No node specified: use system-wide value
        num_2m=$(cat /sys/kernel/mm/hugepages/hugepages-1048576kB/nr_hugepages)
    else
        # Specific NUMA node: use node-local value
        num_2m=$(cat "/sys/devices/system/node/node${numa_node}/hugepages/hugepages-1048576kB/nr_hugepages")
    fi
  fi

  # Sizes in kB
  local size_2m_kb=2048          # 2 MB
  local size_1g_kb=1048576       # 1 GB

  # Total hugepage memory requested in kB
  local hp_kb
  hp_kb=$(( num_2m * size_2m_kb + num_1g * size_1g_kb ))

  # Max allowed hugepage memory in kB (memtotal_kb * max_percent_page_ram_usage)
  local max_hp_kb=$(( memtotal_kb * max_percent_page_ram_usage / 100 ))

  echo "hugepages usage kb: $hp_kb"
  echo "max allowed hugepage usage kb: $max_hp_kb"

  # Return 0 (OK) if within limit, 1 if exceeding
  if [ "$hp_kb" -le "$max_hp_kb" ]; then
    return 0
  else
    return 1
  fi
}

## --------------------- Command start ------------------------------

# parse flags
if [ $# -eq 0 ]; then
  echo "No argument provided."
  usage
  exit 1
fi

num_1g=-1
num_2m=-1
numa_node=-1
while [[ $# -gt 0 ]]; do
  case "$1" in
    -g|--num-1g)
      shift
      num_1g="$1"
      ;;
    -m|--num-2m)
      shift
      num_2m="$1"
      ;;
    -n|--node)
      shift
      numa_node="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  shift
done

# Enforce that script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Permission denied: this command must be run as root."
    exit 1
fi

# Enforce that script is not run on build servers
is_build=$($CLI_PATH/common/is_build $CLI_PATH $(hostname -s))
if [ "$is_build" = "1" ]; then
  echo "Permission denied: not allowed to set hugepages on build servers"
  exit 1
fi

# check if at least --num-1g or --num-2m is set
if [ "$num_1g" -eq -1 ] && [ "$num_2m" -eq -1 ]; then
  echo "Error: please provide at least the --num-1g or --num-2m flag"
  exit 1
fi

# check if not exceeding max pages
if ! check_max_pages_limit $num_2m $num_1g $numa_node; then
  echo "Exceeding maximum allowed RAM usage for hugepages. The policy forces you to stay below ${max_percent_page_ram_usage}% of RAM usage per NUMA domain."
  exit 1
fi

#set hugepages
sysfs_path="/sys/kernel/mm/hugepages"
if [ "$numa_node" -ge 0 ]; then
  sysfs_path="/sys/devices/system/node/node$numa_node/hugepages"
fi
if [ "$num_1g" -ge 0 ]; then
  echo $num_1g > $sysfs_path/hugepages-1048576kB/nr_hugepages
fi
if [ "$num_2m" -ge 0 ]; then
  echo $num_2m > $sysfs_path/hugepages-2048kB/nr_hugepages
fi

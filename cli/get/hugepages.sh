#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

# Column headers
printf "%-8s %15s %15s %18s %18s %18s\n" \
  "NUMA" "# 2M_pages" "# 1G_pages" "Mem_2M_pages_MB" "Mem_1G_pages_MB" "MemTotal_MB"
printf "%s\n" "---------------------------------------------------------------------------------------------------------------"

# Totals
total_2m=0
total_1g=0
total_hp_2m_mb=0
total_hp_1g_mb=0
total_mem_mb=0

for node_path in /sys/devices/system/node/node[0-9]*; do
    [ -d "$node_path" ] || continue

    node=$(basename "$node_path")  # e.g., "node0"

    # Default to 0 if not present
    two_MG=0
    one_GB=0

    # 2M hugepages per NUMA node (if exposed)
    if [ -f "$node_path/hugepages/hugepages-2048kB/nr_hugepages" ]; then
        two_MG=$(<"$node_path/hugepages/hugepages-2048kB/nr_hugepages")
    fi

    # 1G hugepages per NUMA node (if exposed)
    if [ -f "$node_path/hugepages/hugepages-1048576kB/nr_hugepages" ]; then
        one_GB=$(<"$node_path/hugepages/hugepages-1048576kB/nr_hugepages")
    fi

    # Memory taken by hugepages on this node (in MB)
    # 2M = 2 MB, 1G = 1024 MB
    hp_2m_mb=$(( two_MG * 2 ))
    hp_1g_mb=$(( one_GB * 1024 ))

    # Total memory for this NUMA node from meminfo (kB -> MB)
    memtotal_kb=$(awk '/^Node [0-9]+ MemTotal:/ {print $4}' "$node_path/meminfo" 2>/dev/null)
    [ -z "$memtotal_kb" ] && memtotal_kb=0
    memtotal_mb=$(( memtotal_kb / 1024 ))

    printf "%-8s %15d %15d %18d %18d %18d\n" \
        "$node" "$two_MG" "$one_GB" "$hp_2m_mb" "$hp_1g_mb" "$memtotal_mb"

    # Accumulate totals
    total_2m=$(( total_2m + two_MG ))
    total_1g=$(( total_1g + one_GB ))
    total_hp_2m_mb=$(( total_hp_2m_mb + hp_2m_mb ))
    total_hp_1g_mb=$(( total_hp_1g_mb + hp_1g_mb ))
    total_mem_mb=$(( total_mem_mb + memtotal_mb ))

done

# Separator and totals line
printf "%s\n" "---------------------------------------------------------------------------------------------------------------"
printf "%-8s %15d %15d %18d %18d %18d\n" \
  "TOTAL" "$total_2m" "$total_1g" "$total_hp_2m_mb" "$total_hp_1g_mb" "$total_mem_mb"

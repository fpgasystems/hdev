#!/bin/bash

# Exit script if:
#   - '-e':          any command returns a non-zero exit status
#   - '-u':          an undefined variable is referenced
#   - '-o pipefail': any command in a pipeline fails (using pipes '|')
set -euo pipefail

CLI_PATH="$(dirname "$0")"
bold=$(tput bold)
normal=$(tput sgr0)

# Source - https://stackoverflow.com/questions/29436275/how-to-prompt-for-yes-or-no-in-bash
# Posted by Tiago Lopo
# Retrieved 2025-11-06, License - CC BY-SA 3.0
# usage: prompt_yn "question to ask"
function prompt_yn {
  local yn
  while true; do
      read -p "$* [y/n]: " yn
      case $yn in
          [Yy]*) return 0 ;;
          [Nn]*) return 1 ;;
      esac
  done
}

# TODO: make this more general not only for ETHZ HACC
#     - Track the BMC hostname/ip in the constants or cmdb
# Function to append '-ra' to the first part of the hostname
get_hacc_bmc_hostname() {
    local full_hostname
    local parts
    local bmc_hostname

    # If no argument provided, use the current hostname
    if [ "$#" -eq "0" ]; then
      full_hostname=$(hostname)
    else
      full_hostname=$1
    fi

    # Split hostname into array using '.' as delimiter
    IFS='.' read -r -a parts <<< "$full_hostname"

    # Modify the first element
    parts[0]="${parts[0]}-ra"

    # Reconstruct the hostname
    bmc_hostname=$(IFS=. ; echo "${parts[*]}")

    echo "$bmc_hostname"
}

function cold_reboot() {
  # references:
  #   - https://cloudcult.dev/fishing-for-sushy-with-curl/
  #   - https://github.com/openbmc/docs/blob/master/REDFISH-cheatsheet.md
  #   - https://servermanagementportal.ext.hpe.com/docs/concepts/redfishauthentication

  # Load variables
  local BMC_HOSTNAME=$(get_hacc_bmc_hostname)
  local BMC_CREDENTIALS_FILE=/etc/hdev/bmc-credentials.sh
  if [ ! -f "$BMC_CREDENTIALS_FILE" ]; then
    echo "ERROR: BMC credentials file not found" >&2
    return 1
  fi
  source $BMC_CREDENTIALS_FILE

  # Authenticate a Redfish BMC session and capture headers + status
  echo "INFO: Authenticating with BMC at ${BMC_HOSTNAME}"

  # Temporary files for headers and body (deleted automatically)
  tmp_headers=$(mktemp)
  tmp_body=$(mktemp)
  trap 'rm -f "$tmp_headers" "$tmp_body"' RETURN

  # Retry up to 3 times with exponential backoff in case BMC is temporarily unresponsive
  local max_retries=3
  local delay=2
  local http_code=0
  local success=false

  for attempt in $(seq 1 $max_retries); do
    http_code=$(curl --insecure -s -S -D "$tmp_headers" -o "$tmp_body" -w "%{http_code}" \
      -H "Content-Type: application/json" \
      -X POST \
      "https://${BMC_HOSTNAME}/redfish/v1/SessionService/Sessions" \
      -d "{\"UserName\":\"$BMC_USERNAME\", \"Password\":\"$BMC_PASSWORD\"}" \
      2>/dev/null || echo "000")

    if [[ "$http_code" == "200" || "$http_code" == "201" ]]; then
      success=true
      break
    else
      echo "WARN: Authentication attempt $attempt failed (HTTP $http_code)." >&2
      if (( attempt < max_retries )); then
        echo "INFO: Retrying in ${delay}s..." >&2
        sleep "$delay"
        ((delay *= 2))
      fi
    fi
  done

  if [[ $success != true ]]; then
    echo "ERROR: Failed to authenticate with BMC at ${BMC_HOSTNAME} after ${max_retries} attempts." >&2
    echo "DEBUG: Last HTTP code: ${http_code}" >&2
    echo "DEBUG RESPONSE BODY:" >&2
    sed 's/^/    /' "$tmp_body" >&2
    echo ""
    return 1
  fi

  # Extract the X-Auth-Token from headers
  token=$(grep -i '^X-Auth-Token:' "$tmp_headers" | awk '{print $2}' | tr -d '\r\n' || true)

  if [[ -z "$token" ]]; then
    echo "ERROR: Authentication succeeded (HTTP ${http_code}) but no X-Auth-Token found in response headers." >&2
    echo "DEBUG HEADERS:" >&2
    sed 's/^/    /' "$tmp_headers" >&2
    echo ""
    return 1
  fi

  echo "INFO: Successfully obtained session token."

  # Check the vendor of the system to determine the redfish api url
  local system_vendor=$(<"/sys/class/dmi/id/sys_vendor")
  local vendor_specific_system_name=""
  case "$system_vendor" in
      "Dell Inc.")
          vendor_specific_system_name="System.Embedded.1"
          ;;
      "Supermicro")
          vendor_specific_system_name="1"
          ;;
      *)
          echo "ERROR: The system is not from a supported vendor. Vendor $system_vendor unsupported." >&2
          return 1
          ;;
  esac

  # Perform the power cycle
  echo "INFO: Sending PowerCycle request to ${BMC_HOSTNAME}..."
  if ! curl -k -s -S \
    -H "X-Auth-Token: $token" \
    -H "Content-Type: application/json" \
    -X POST "https://${BMC_HOSTNAME}/redfish/v1/Systems/${vendor_specific_system_name}/Actions/ComputerSystem.Reset" \
    -d '{"ResetType": "PowerCycle"}' >/dev/null; then
    echo "ERROR: Failed to send PowerCycle command to ${BMC_HOSTNAME}." >&2
    return 1
  fi

  echo "INFO: PowerCycle command sent successfully."

  # TODO: retrieve powercycle delay from redfish api
  echo "INFO: The server will reboot shortly (in ~5 seconds)." | tee >(wall 2>/dev/null || true)

  # TODO: kill parent shell to kill ssh connection and give same behaviour as /sbin/reboot
  return 0
}

# Parse flags
reboot_type="warm"
reboot_confirmed=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --cold|-c)
      reboot_type="cold"
      ;;
    --yes|-y)
      reboot_confirmed=1
      ;;
    -h|--help)
      echo ""
      echo "Usage: ${bold}hdev reboot [--cold] [--yes]${normal}"
      echo ""
      echo "Reboots the server."
      echo ""
      echo "ARGUMENTS:"
      echo "   ${bold}-c, --cold${normal}     Do cold boot/power cycle. By default the"
      echo "                  reboot is a warm boot. A cold boot completely"
      echo "                  removes power, which causes many devices to"
      echo "                  do a complete reset (for example FPGAs)."
      echo "   ${bold}-y, --yes${normal}      Say yes to confirmation prompt"
      echo ""
      echo "   ${bold}-h, --help${normal}     This help prompt, with all command options."
      echo ""
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
  # move to next argument
  shift
done


#Check permissions
if [ "$EUID" -ne 0 ]; then
  echo "Permission denied: This command must be run as root (using sudo)."
  exit 1
fi

set +e
# temporarily disable 'fail on non-zero', because is_sudo does not adhere to this
is_sudo=$($CLI_PATH/common/is_sudo $CLI_PATH $USER)
set -e
if [ "$is_sudo" = "0" ]; then
  is_build=$($CLI_PATH/common/is_build $CLI_PATH $(hostname -s))
  if  [ "$is_build" = "1" ]; then
    echo "Permission denied: This is a build server, only admins are allowed to reboot these."
    exit 1
  fi

  is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
  if [ "$is_vivado_developer" = "0" ]; then
    echo "Permission denied: You don't have the correct privileges to reboot servers."
    echo "If you believe you need this ability, contact the cluster maintainer to request access to the 'vivado_developers' group."
    exit 1
  fi
fi

# Confirmation prompt
if [[ "$reboot_confirmed" -eq "0" ]]; then
  echo "NOTE: Rebooting a server may cause data loss. Make sure you have saved your work."
  if ! prompt_yn "Are you sure you want to ${bold}$reboot_type reboot${normal}?"; then
    echo "${bold}Reboot Aborted${normal}"
    exit 0
  fi
  reboot_confirmed=1
fi

# Print the final message
echo ""
echo "Going down for a ${bold}$reboot_type boot${normal}."
echo "You can check if the server is back online, by running 'ping ${HOSTNAME}' on your command line."
echo ""

# Reboot the server
case "$reboot_type" in
  warm)
    # warm boot / Gracefull Reset
    /sbin/reboot
    ;;
  cold)
    # cold boot / Power Cycle
    if ! cold_reboot; then
      echo "${bold}Reboot Aborted${normal}"
      exit 1
    fi
    exit 0
    ;;
  *)
    echo "ERROR: Invalid reboot_type ($reboot_type)."
    echo "${bold}Reboot Aborted${normal}"
    ;;
esac

exit 1

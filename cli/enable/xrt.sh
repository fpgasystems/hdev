#!/bin/bash

bold=$(tput bold)
normal=$(tput sgr0)

#constants
#CLI_PATH="/opt/sgrt/cli" #"$(dirname "$(dirname "$0")")" # CLI_PATH is declared as an environment variable
EMAIL=$($CLI_PATH/common/get_constant $CLI_PATH EMAIL)
CHECK_ON_XRT_ERR_MSG="Please, choose a valid XRT version."
LOCAL_PATH=$($CLI_PATH/common/get_constant $CLI_PATH LOCAL_PATH)
XRT_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XRT_PATH)
#XILINX_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_TOOLS_PATH)
#VIVADO_PATH="$XILINX_TOOLS_PATH/Vivado"

#this needs to be consistent with the installed XRT versions
VERSIONS=("2022.1" "2022.2" "2023.1" "2024.1")

#get Xilinx opt path
XILINX_OPT_PATH="${XRT_PATH%/xrt}"

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#early exit
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
if [ "$is_build" = "0" ]; then
    (return 0 2>/dev/null) && return 1 || exit 1
fi

#inputs
read -a flags <<< "$@"

#set to false
enable="0"

#check on valid XRT version
if [ -n "$XILINX_XRT" ]; then #if [ -z "$(echo $XILINX_XRT)" ]; then
    echo ""
    echo "Xilinx Runtime (XRT) is already active on ${bold}$hostname!${normal}"
    echo ""
    #exit
else
    #check on flags
    version_found=""
    version_name=""
    if [ "$flags" = "" ]; then
        #header
        echo ""
        echo "${bold}sgutil enable xrt${normal}"
        #version_dialog
        echo ""
        echo "${bold}Please, choose your XRT version:${normal}"
        echo ""
        #result=$($CLI_PATH/common/version_dialog $VIVADO_PATH)
        #version_found=$(echo "$result" | sed -n '1p')
        #version_name=$(echo "$result" | sed -n '2p')

        version_found="0"
        version_name=""
        PS3=""
        select version_name in "${VERSIONS[@]}"; do
            if [[ -z $version_name ]]; then
                echo "" >&/dev/null
            else
                version_found="1"
                break
            fi
        done

        #set to true
        enable="1"

        echo ""
    else
        #version_dialog_check
        result="$("$CLI_PATH/common/version_dialog_check" "${flags[@]}")"
        version_found=$(echo "$result" | sed -n '1p')
        version_name=$(echo "$result" | sed -n '2p')
        #forbidden combinations
        if [ "$version_found" = "1" ] && ([ "$version_name" = "" ] || [ ! -d "$XILINX_OPT_PATH/xrt_$version_name" ]); then #-d "$VIVADO_PATH/$version_name"
            #$CLI_PATH/sgutil enable xrt -h
            echo ""
            echo $CHECK_ON_XRT_ERR_MSG
            echo ""
            #exit
        else
            #set to true
            enable="1"
            echo ""
        fi
    fi

    if [ "$enable" = "1" ]; then
        #copy the desired XRT version to user’s local and preserve /opt/xilinx/xrt structure (Xilinx workaroud)
        mkdir -p $LOCAL_PATH/xrt_${version_name}$XRT_PATH
        cp -r $XRT_PATH"_"${version_name}/* $LOCAL_PATH/xrt_${version_name}$XRT_PATH 

        #source xrt
        source $LOCAL_PATH/xrt_${version_name}$XRT_PATH/setup.sh

        echo ""

        #print message
        #echo ""
        if [[ -d $XILINX_OPT_PATH/xrt_$version_name ]]; then #$VIVADO_PATH/$version_name
            #Vitis is not installed
            echo "The server is ready to work with ${bold}XRT $version_name${normal} release branch:"
            echo ""
            echo "    Xilinx Board Utility (xbutil): ${bold}$XILINX_XRT/bin${normal}"
            echo ""
        else
            echo "The server needs special care to operate with XRT normally (Xilinx tools are not properly installed)."
            echo ""
            echo "${bold}An email has been sent to the person in charge;${normal} we will let you know when XRT is ready to use again."
            echo "Subject: $hostname requires special attention ($username): Xilinx tools are not properly installed" | sendmail $EMAIL
        fi
    fi
fi
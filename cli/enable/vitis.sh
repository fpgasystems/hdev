bold=$(tput bold)
normal=$(tput sgr0)

#constants
#CLI_PATH="/opt/hdev/cli" #"$(dirname "$(dirname "$0")")"
CHECK_ON_VITIS_ERR_MSG="Please, choose a valid Vitis version."
EMAIL=$($CLI_PATH/common/get_constant $CLI_PATH EMAIL)
XILINX_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_TOOLS_PATH) # CLI_PATH is declared as an environment variable
VITIS_PATH="$XILINX_TOOLS_PATH/Vitis"

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

#check on valid Vitis version
if [ -n "$XILINX_VITIS" ]; then
    echo ""
    echo "Vitis is already active on ${bold}$hostname!${normal}"
    echo ""
    #exit
else
    #check on flags
    version_found=""
    version_name=""
    if [ "$flags" = "" ]; then
        #header
        echo ""
        echo "${bold}hdev enable vitis${normal}"
        #version_dialog
        echo ""
        echo "${bold}Please, choose your Vitis version:${normal}"
        echo ""
        result=$($CLI_PATH/common/version_dialog $VITIS_PATH)
        version_found=$(echo "$result" | sed -n '1p')
        version_name=$(echo "$result" | sed -n '2p')
        version_unique=$(echo "$result" | sed -n '3p')

        if [ "$version_unique" = "1" ]; then
            echo $version_name
            sleep 2
        fi

        #set to true
        enable="1"

        echo ""
    else
        #version_dialog_check
        result="$("$CLI_PATH/common/version_dialog_check" "${flags[@]}")"
        version_found=$(echo "$result" | sed -n '1p')
        version_name=$(echo "$result" | sed -n '2p')
        #forbidden combinations
        if [ "$version_found" = "1" ] && ([ "$version_name" = "" ] || [ ! -d "$VITIS_PATH/$version_name" ]); then 
            #$CLI_PATH/hdev enable vitis -h
            echo ""
            echo $CHECK_ON_VITIS_ERR_MSG
            echo ""
            #exit
        else
            #set to true
            enable="1"
            echo ""
        fi
    fi

    if [ "$enable" = "1" ]; then
        #source vitis
        source $XILINX_TOOLS_PATH//Vitis/$version_name/.settings64-Vitis.sh
        source $XILINX_TOOLS_PATH//Vitis_HLS/$version_name/.settings64-Vitis_HLS.sh

        #echo ""

        #print message
        #echo ""
        if [[ -d $VITIS_PATH/$version_name ]]; then
            #Vitis is installed
            echo "The server is ready to work with ${bold}Vitis $version_name${normal} release branch:"
            echo ""
            echo "    Vitis, Vitis_HLS             : ${bold}$VITIS_PATH/$version_name${normal}"
            echo ""
        else
            echo "The server needs special care to operate with Vitis normally (Xilinx tools are not properly installed)."
            echo ""
            echo "${bold}An email has been sent to the person in charge;${normal} we will let you know when Vitis is ready to use again."
            echo "Subject: $hostname requires special attention ($username): Xilinx tools are not properly installed" | sendmail $EMAIL
        fi
    fi
fi
bold=$(tput bold)
normal=$(tput sgr0)

#constants
#CLI_PATH="/opt/sgrt/cli" #"$(dirname "$(dirname "$0")")"
CHECK_ON_VIVADO_ERR_MSG="Please, choose a valid Vivado version."
EMAIL=$($CLI_PATH/common/get_constant $CLI_PATH EMAIL)
XILINX_TOOLS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH XILINX_TOOLS_PATH) # CLI_PATH is declared as an environment variable
VIVADO_PATH="$XILINX_TOOLS_PATH/Vivado"

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

#check on valid Vivado version
if [ -n "$XILINX_VIVADO" ]; then
    echo ""
    echo "Vivado is already active on ${bold}$hostname!${normal}"
    echo ""
    #exit
else
    #check on flags
    version_found=""
    version_name=""
    if [ "$flags" = "" ]; then
        #header
        echo ""
        echo "${bold}sgutil enable vivado${normal}"
        #version_dialog
        echo ""
        echo "${bold}Please, choose your Vivado version:${normal}"
        echo ""
        result=$($CLI_PATH/common/version_dialog $VIVADO_PATH)
        version_found=$(echo "$result" | sed -n '1p')
        version_name=$(echo "$result" | sed -n '2p')

        #set to true
        enable="1"

        echo ""
    else
        #version_dialog_check
        result="$("$CLI_PATH/common/version_dialog_check" "${flags[@]}")"
        version_found=$(echo "$result" | sed -n '1p')
        version_name=$(echo "$result" | sed -n '2p')
        #forbidden combinations
        if [ "$version_found" = "1" ] && ([ "$version_name" = "" ] || [ ! -d "$VIVADO_PATH/$version_name" ]); then 
            #$CLI_PATH/sgutil enable vivado -h
            echo ""
            echo $CHECK_ON_VIVADO_ERR_MSG
            echo ""
            #exit
        else
            #set to true
            enable="1"
            echo ""
        fi
    fi 

    if [ "$enable" = "1" ]; then
        #source vivado
        source $XILINX_TOOLS_PATH//Vivado/$version_name/.settings64-Vivado.sh

        #echo ""

        #print message
        #echo ""
        if [[ -d $VIVADO_PATH/$version_name ]]; then
            #Vivado is installed
            echo "The server is ready to work with ${bold}Vivado $version_name${normal} release branch:"
            echo ""
            echo "    Vivado                       : ${bold}$VIVADO_PATH/$version_name${normal}"
            echo ""
        else
            echo "The server needs special care to operate with Vivado normally (Xilinx tools are not properly installed)."
            echo ""
            echo "${bold}An email has been sent to the person in charge;${normal} we will let you know when Vivado is ready to use again."
            echo "Subject: $hostname requires special attention ($username): Xilinx tools are not properly installed" | sendmail $EMAIL
        fi
    fi
fi
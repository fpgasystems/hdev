#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev build opennic --commit $commit_name_shell $commit_name_driver --project $project_name --version $vivado_version --all $all 
#example: /opt/hdev/cli/hdev build opennic --commit            8077751             1cf2578 --project   hello_world --version          2022.2 --all    1 

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
vivado_enabled=$([ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; } && echo 1 || echo 0)
if [ "$is_build" = "0" ] && [ "$vivado_enabled" = "0" ]; then
    exit 1
fi

#temporal exit condition
if [ "$is_asoc" = "1" ]; then
    echo ""
    echo "Sorry, we are working on this!"
    echo ""
    exit
fi

#inputs
commit_name=$2
commit_name_driver=$3
project_name=$5
vivado_version=$7
all=$9

#all inputs must be provided
if [ "$commit_name" = "" ] || [ "$commit_name_driver" = "" ] || [ "$project_name" = "" ] || [ "$vivado_version" = "" ] || [ "$all" = "" ]; then
    exit
fi

#constants
BITSTREAM_NAME=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_NAME)
BITSTREAMS_PATH="$CLI_PATH/bitstreams"
DRIVER_NAME=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_NAME)
LOCAL_PATH=$($CLI_PATH/common/get_constant $CLI_PATH LOCAL_PATH)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
NUM_JOBS="8"
WORKFLOW="opennic"

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name"
DRIVER_DIR="$DIR/open-nic-driver"

#get device name
device_name=$(cat $DIR/ONIC_DEVICE_NAME)

#device_name to FDEV_NAME
FDEV_NAME=$(echo "$device_name" | cut -d'_' -f2)

#define shell
project_shell="$DIR/${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"

#bitstream compilation is only allowed on CPU (build) servers
if [ "$all" = "1" ]; then
    #check on bitstream configuration
    are_equals="0"
    if [ -f "$DIR/.device_config" ]; then
        are_equals=$($CLI_PATH/common/compare_files "$DIR/configs/device_config" "$DIR/.device_config")
    fi

    compile="0"
    if [ ! -e "$project_shell" ]; then
        compile="1"
    elif [ -e "$project_shell" ] && [ "$are_equals" = "0" ] && [ "$project_name" != "validate_opennic.$hostname.$commit_name_driver.$FDEV_NAME.$vivado_version" ]; then
        #echo ""
        echo "The shell ${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit already exists. Do you want to remove it and compile it again (y/n)?"
        while true; do
            read -p "" yn
            case $yn in
                "y")
                    rm -f $project_shell 
                    compile="1"
                    break
                    ;;
                "n") 
                    #compile="0"
                    break
                    ;;
            esac
        done
        echo ""
    fi

    #launch vivado
    if [ "$compile" = "1" ]; then 
        #shell compilation
        echo "${bold}Shell compilation (commit ID: $commit_name)${normal}"
        echo ""

        #read configuration
        tcl_args=$($CLI_PATH/common/get_tclargs $DIR/configs/device_config)
        
        #copy and compile on local
        echo "${bold}Change to LOCAL_PATH:${normal}"
        echo ""
        echo "cp -rf $DIR/* $LOCAL_PATH/$project_name/"
        echo "cd $LOCAL_PATH/$project_name/open-nic-shell/script"
        echo ""
        mkdir -p $LOCAL_PATH/$project_name/
        cp -rf $DIR/* $LOCAL_PATH/$project_name/
        cd $LOCAL_PATH/$project_name/open-nic-shell/script
        
        #run compilation
        echo "${bold}Running vivado:${normal}"
        echo ""
        echo "vivado -mode batch -source build.tcl -tclargs -board a$FDEV_NAME -jobs $NUM_JOBS -impl 1 $tcl_args"
        echo ""
        vivado -mode batch -source build.tcl -tclargs -board a$FDEV_NAME -jobs $NUM_JOBS -impl 1 $tcl_args
        
        #copy and send email
        if [ -f "$LOCAL_PATH/$project_name/open-nic-shell/build/a$FDEV_NAME/open_nic_shell/open_nic_shell.runs/impl_1/$BITSTREAM_NAME" ]; then
            #copy back
            cp -rf $LOCAL_PATH/$project_name/open-nic-shell/* $DIR/open-nic-shell
            
            #remove temporal project on local
            rm -rf $LOCAL_PATH/$project_name
            
            #copy to project
            cp "$DIR/open-nic-shell/build/a$FDEV_NAME/open_nic_shell/open_nic_shell.runs/impl_1/$BITSTREAM_NAME" "$project_shell"

            #save .device_config
            cp $DIR/configs/device_config $DIR/.device_config
            chmod a-w "$DIR/.device_config"

            #print message
            echo ""
            echo "${bold}${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit is done!${normal}"
            echo ""

            #create xpr simlink
            ln -s $DIR/open-nic-shell/build/au55c/open_nic_shell/open_nic_shell.xpr $DIR/open_nic_shell.xpr

            #send email
            #user_email=$USER@ethz.ch
            #echo "Subject: Good news! hdev build opennic (${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit) is done!" | sendmail $user_email
        fi
    fi
fi

#compile driver
echo "${bold}Driver compilation (commit ID: $commit_name_driver)${normal}"
echo ""
echo "cd $DRIVER_DIR && make"
echo ""
cd $DRIVER_DIR && make
echo ""

#application compilation
echo "${bold}Application compilation:${normal}"
echo ""
echo "cd $DIR"
echo "make"
echo ""
cd $DIR
make

#copy driver
cp -f $DRIVER_DIR/$DRIVER_NAME $DIR/$DRIVER_NAME

#remove drivier files (generated while compilation)
rm $DRIVER_DIR/Module.symvers
rm -rf $DRIVER_DIR/hwmon
rm $DRIVER_DIR/modules.order
rm $DRIVER_DIR/$DRIVER_NAME
rm $DRIVER_DIR/onic.mod
rm $DRIVER_DIR/onic.mod.c
rm $DRIVER_DIR/onic.mod.o
rm $DRIVER_DIR/onic.o
rm $DRIVER_DIR/onic_common.o
rm $DRIVER_DIR/onic_ethtool.o
rm $DRIVER_DIR/onic_hardware.o
rm $DRIVER_DIR/onic_lib.o
rm $DRIVER_DIR/onic_main.o
rm $DRIVER_DIR/onic_netdev.o
rm $DRIVER_DIR/onic_sysfs.o

#author: https://github.com/jmoya82
#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev build vrt --project $project_name --tag $tag_name --target $target_name
#example: /opt/hdev/cli/hdev build vrt --project   hello_world --tag    v1.0.0 --target       hw_all

#early exit
url="${HOSTNAME}"
hostname="${url%%.*}"
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)
if [ "$is_build" = "0" ] && [ "$vivado_enabled_asoc" = "0" ]; then
    exit 1
fi

#inputs
project_name=$2
tag_name=$4
target_name=$6

#all inputs must be provided
if [ "$project_name" = "" ] || [ "$tag_name" = "" ] || [ "$target_name" = "" ]; then
    exit
fi

#constants
#BITSTREAM_NAME=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_SHELL_NAME)
#BITSTREAMS_PATH="$CLI_PATH/bitstreams"
#DRIVER_NAME=$($CLI_PATH/common/get_constant $CLI_PATH ONIC_DRIVER_NAME)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
#NUM_JOBS="8"
WORKFLOW="vrt"

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$tag_name/$project_name"
#SHELL_BUILD_DIR="$DIR/open-nic-shell/script"
#DRIVER_DIR="$DIR/open-nic-driver"

#platform_name to FDEV_NAME
#FDEV_NAME=$(echo "$platform_name" | cut -d'_' -f2)

#define shell
#library_shell="$BITSTREAMS_PATH/$WORKFLOW/$commit_name/${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
#project_shell="$DIR/${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"

#modify Makefile
sed -i 's|^V80PP_PATH=$(shell realpath ../../submodules/v80-vitis-flow)$|V80PP_PATH=$(shell realpath ../submodules/v80-vitis-flow)|' $DIR/src/Makefile

#bitstream compilation is only allowed on CPU (build) servers
compile="1"
if [ "$target_name" = "hw_all" ]; then
    #check on bitstream configuration
    #are_equals="0"
    #if [ -f "$DIR/.device_config" ]; then
    #    are_equals=$($CLI_PATH/common/compare_files "$DIR/configs/device_config" "$DIR/.device_config")
    #fi

    #compile="0"
    #if [ ! -e "$project_shell" ]; then
    #    compile="1"
    #elif [ -e "$project_shell" ] && [ "$are_equals" = "0" ] && [ "$project_name" != "validate_opennic.$hostname.$commit_name_driver.$FDEV_NAME.$vivado_version" ]; then
    #    #echo ""
    #    echo "The shell ${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit already exists. Do you want to remove it and compile it again (y/n)?"
    #    while true; do
    #        read -p "" yn
    #        case $yn in
    #            "y")
    #                rm -f $project_shell 
    #                compile="1"
    #                break
    #                ;;
    #            "n") 
    #                #compile="0"
    #                break
    #                ;;
    #        esac
    #    done
    #    echo ""
    #fi

    ##launch vivado
    #if [ "$compile" = "1" ]; then 
    #    #shell compilation
    #    echo "${bold}Shell compilation (commit ID: $commit_name)${normal}"
    #    echo ""
    #
    #    #read configuration
    #    tcl_args=$($CLI_PATH/common/get_tclargs $DIR/configs/device_config)
    #    
    #    echo "vivado -mode batch -source build.tcl -tclargs -board a$FDEV_NAME -jobs $NUM_JOBS -impl 1 $tcl_args"
    #    cd $SHELL_BUILD_DIR
    #    vivado -mode batch -source build.tcl -tclargs -board a$FDEV_NAME -jobs $NUM_JOBS -impl 1 $tcl_args
    #    echo ""
    #
    #    #copy and send email
    #    if [ -f "$DIR/open-nic-shell/build/a$FDEV_NAME/open_nic_shell/open_nic_shell.runs/impl_1/$BITSTREAM_NAME" ]; then
    #        #copy to project
    #        cp "$DIR/open-nic-shell/build/a$FDEV_NAME/open_nic_shell/open_nic_shell.runs/impl_1/$BITSTREAM_NAME" "$project_shell"
    #
    #        #save .device_config
    #        cp $DIR/configs/device_config $DIR/.device_config
    #        chmod a-w "$DIR/.device_config"
    #
    #        #print message
    #        echo "${bold}${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit is done!${normal}"
    #        echo ""
    #
    #        #send email
    #        #user_email=$USER@ethz.ch
    #        #echo "Subject: Good news! hdev build opennic (${BITSTREAM_NAME%.bit}.$FDEV_NAME.$vivado_version.bit) is done!" | sendmail $user_email
    #    fi
    #fi
    compile="1"
fi

if [ "$compile" = "1" ]; then
    #compile driver
    echo "${bold}Programmable Device Image (PDI) compilation (tag ID: $tag_name)${normal}"
    echo ""
    echo "cd $DIR/src && make $target_name"
    echo ""
    cd $DIR/src && make $target_name
    echo ""
fi


#compile driver
#echo "${bold}Driver compilation (commit ID: $commit_name_driver)${normal}"
#echo ""
#echo "cd $DRIVER_DIR && make"
#echo ""
#cd $DRIVER_DIR && make
#echo ""

#application compilation
#echo "${bold}Application compilation:${normal}"
#echo ""
#echo "cd $DIR"
#echo "make"
#echo ""
#cd $DIR
#make

#copy driver
#cp -f $DRIVER_DIR/$DRIVER_NAME $DIR/$DRIVER_NAME

#remove drivier files (generated while compilation)
#rm $DRIVER_DIR/Module.symvers
#rm -rf $DRIVER_DIR/hwmon
#rm $DRIVER_DIR/modules.order
#rm $DRIVER_DIR/$DRIVER_NAME
#rm $DRIVER_DIR/onic.mod
#rm $DRIVER_DIR/onic.mod.c
#rm $DRIVER_DIR/onic.mod.o
#rm $DRIVER_DIR/onic.o
#rm $DRIVER_DIR/onic_common.o
#rm $DRIVER_DIR/onic_ethtool.o
#rm $DRIVER_DIR/onic_hardware.o
#rm $DRIVER_DIR/onic_lib.o
#rm $DRIVER_DIR/onic_main.o
#rm $DRIVER_DIR/onic_netdev.o
#rm $DRIVER_DIR/onic_sysfs.o

#author: https://github.com/jmoya82
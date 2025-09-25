#!/bin/bash

CLI_PATH="$(dirname "$(dirname "$0")")"
bold=$(tput bold)
normal=$(tput sgr0)

#usage:       $CLI_PATH/hdev build coyote --commit $commit_name --project $project_name --target $target_name --version $vivado_version --is_build $is_build 
#example: /opt/hdev/cli/hdev build coyote --commit      0e514ab --project   hello_world --target           hw --version          2024.1 --is_build         1 

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

#inputs
commit_name=$2
project_name=$4
target_name=$6
vivado_version=$8
is_build=${10}

#all inputs must be provided
if [ "$commit_name" = "" ] || [ "$project_name" = "" ] || [ "$target_name" = "" ] || [ "$vivado_version" = "" ] || [ "$is_build" = "" ]; then
    exit
fi

#constants
COYOTE_DRIVER_NAME=$($CLI_PATH/common/get_constant $CLI_PATH COYOTE_DRIVER_NAME)
COYOTE_SHELL_NAME=$($CLI_PATH/common/get_constant $CLI_PATH COYOTE_SHELL_NAME)
COYOTE_SHELL_TOP="shell_top.bin"
LOCAL_PATH=$($CLI_PATH/common/get_constant $CLI_PATH LOCAL_PATH)
MY_PROJECTS_PATH=$($CLI_PATH/common/get_constant $CLI_PATH MY_PROJECTS_PATH)
WORKFLOW="coyote"

#define directories
DIR="$MY_PROJECTS_PATH/$WORKFLOW/$commit_name/$project_name"
DRIVER_DIR="$DIR/driver"

#get device name
device_name=$(cat $DIR/COYOTE_DEVICE_NAME)

#device_name to FDEV_NAME
FDEV_NAME=$(echo "$device_name" | cut -d'_' -f2)

#echo "FDEV_NAME: $FDEV_NAME"
#exit

#get template_name
template_name=$(cat $DIR/COYOTE_TEMPLATE)

#get BITSTREAM_NAME 
BITSTREAM_NAME=${COYOTE_SHELL_NAME%.bit}.$FDEV_NAME.$vivado_version.bit
#SHELL_TOP_NAME=${COYOTE_SHELL_TOP%.bin}.$FDEV_NAME.$vivado_version.bin

#define shell
#project_shell="$DIR/${COYOTE_SHELL_NAME%.bit}.$FDEV_NAME.$vivado_version.bit"
project_shell="$DIR/$BITSTREAM_NAME"

#bitstream compilation is only allowed on CPU (build) servers
if [ "$is_build" = "1" ] && [ "$target_name" = "hw" ]; then
    #check on bitstream configuration
    are_equals="0"
    if [ -f "$DIR/.device_config" ]; then
        are_equals=$($CLI_PATH/common/compare_files "$DIR/configs/device_config" "$DIR/.device_config")
    fi

    compile="0"
    if [ ! -e "$project_shell" ]; then
        compile="1"
    elif [ -e "$project_shell" ] && [ "$are_equals" = "0" ] && [ "$project_name" != "validate_coyote.$hostname.$commit_name.$FDEV_NAME.$vivado_version" ]; then
        #echo ""
        echo "The shell ${bold}$project_shell${normal} already exists. Do you want to remove it and compile it again (y/n)?"
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
        echo "${bold}Shell compilation${normal}"
        echo ""

        #read configuration
        #tcl_args=$($CLI_PATH/common/get_tclargs $DIR/configs/device_config)
        
        #copy and compile on local
        echo "${bold}Copy to LOCAL_PATH:${normal}"
        echo ""
        echo "cp -rf $DIR/* $LOCAL_PATH/$project_name/"
        #echo "cd $LOCAL_PATH/$project_name/open-nic-shell/script"
        echo ""
        mkdir -p $LOCAL_PATH/$project_name/
        cp -rf $DIR/* $LOCAL_PATH/$project_name/
        #cd $LOCAL_PATH/$project_name/open-nic-shell/script

        #run compilation
        echo "${bold}Building Coyote shell:${normal}"
        echo ""
        echo "cd $LOCAL_PATH/$project_name/$template_name/hw"
        echo "mkdir build_hw && cd build_hw"
        echo "cmake ../ -DFDEV_NAME=$FDEV_NAME"
        echo "make project && make bitgen"
        echo ""
        cd $LOCAL_PATH/$project_name/$template_name/hw
        mkdir build_hw && cd build_hw
        cmake ../ -DFDEV_NAME=$FDEV_NAME
        make project && make bitgen

        #define build_folder
        build_folder="$LOCAL_PATH/$project_name/$template_name/hw/build_hw"

        #copy
        if [ -f "$build_folder/bitstreams/$COYOTE_SHELL_NAME" ]; then
            #copy relevant compile files
            cp -rf $build_folder $DIR/$template_name/hw
            cp $DIR/$template_name/hw/build_hw/bitstreams/$COYOTE_SHELL_NAME $DIR/$BITSTREAM_NAME
            #cp $DIR/$template_name/hw/build_hw/bitstreams/$COYOTE_SHELL_TOP $DIR/$SHELL_TOP_NAME
            #cp $build_folder/bitstreams/$COYOTE_SHELL_NAME $DIR
            #cp $build_folder/bitstreams/$COYOTE_SHELL_TOP $DIR
            #cp -rf $build_folder $DIR/src/hw

            #create xpr simlink
            echo "create xpr simlink!"
            echo ""
            #ln -s $DIR/open-nic-shell/build/au55c/open_nic_shell/open_nic_shell.xpr $DIR/open_nic_shell.xpr

            #save .device_config
            cp $DIR/configs/device_config $DIR/.device_config
            chmod a-w "$DIR/.device_config"

            #remove
            #rm -rf $build_folder

            #print message
            echo ""
            echo "${bold}${COYOTE_SHELL_NAME%.bit}.$FDEV_NAME.$vivado_version.bit is done!${normal}"
            echo ""
        fi

        #remove from local
        rm -rf $LOCAL_PATH/$project_name
    fi
fi

if [ "$compile" = "0" ]; then
    echo ""
fi

#compile driver
echo "${bold}Driver compilation${normal}"
echo ""
echo "cd $DRIVER_DIR && make"
echo ""
cd $DRIVER_DIR && make
echo ""

#copy and remove driver
cp -f $DRIVER_DIR/build/$COYOTE_DRIVER_NAME $DIR/$COYOTE_DRIVER_NAME
rm -rf $DRIVER_DIR/build

#check on build_sw
if [ -d "$DIR/$template_name/sw/build_sw" ]; then
    rm -rf "$DIR/$template_name/sw/build_sw"
fi

#application compilation
echo "${bold}Application compilation:${normal}"
echo ""
echo "cd $DIR/$template_name/sw"
echo "mkdir build_sw && cd build_sw"
echo "cmake ../"
echo "make"
echo ""
cd $DIR/$template_name/sw
mkdir build_sw && cd build_sw
cmake ../
make

#copy and remove build_sw (we assume there is only one executable)
cp -f "$DIR/$template_name/sw/build_sw/bin/coyote" "$DIR/coyote"
#rm -rf $DIR/$template_name/sw/build_sw

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
#!/bin/bash

#get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

#check on server
is_acap=$($CLI_PATH/common/is_acap $CLI_PATH $hostname)
is_asoc=$($CLI_PATH/common/is_asoc $CLI_PATH $hostname)
is_build=$($CLI_PATH/common/is_build $CLI_PATH $hostname)
is_fpga=$($CLI_PATH/common/is_fpga $CLI_PATH $hostname)
is_gpu=$($CLI_PATH/common/is_gpu $CLI_PATH $hostname)
is_virtualized=$($CLI_PATH/common/is_virtualized $CLI_PATH $hostname)

#check on groups
IS_GPU_DEVELOPER="1"
is_sudo=$($CLI_PATH/common/is_sudo $USER)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)

#flags
OPENNIC_PROGRAM_FLAGS=("--commit" "--device" "--fec" "--project" "--remote" "--xdp")

command_completion_5() {
    CURRENT_WORD=$1
    COMP_CWORD=$2
    COMP_WORDS_1=$3
    COMP_WORDS_2=$4

    # Define an array for the remaining arguments
    shift 4
    args=("$@")

    # Access elements of the array (we could extend this)
    COMP_CWORD_2_1=${args[0]} #--device
    COMP_CWORD_2_2=${args[1]} #--project
    COMP_CWORD_2_3=${args[2]} 
    COMP_CWORD_2_4=${args[3]} 

    if [[ "${COMP_WORDS[1]}" == "$COMP_WORDS_1" && "${COMP_WORDS[2]}" == "$COMP_WORDS_2" ]]; then
        if [[ "${COMP_WORDS[${COMP_CWORD}-2]}" == "$COMP_CWORD_2_1" || "${COMP_WORDS[${COMP_CWORD}-2]}" == "-${COMP_CWORD_2_1:2:1}" ]]; then
            COMPREPLY=($(compgen -W "$COMP_CWORD_2_2 $COMP_CWORD_2_3 $COMP_CWORD_2_4" -- ${CURRENT_WORD}))
        elif [[ "${COMP_WORDS[${COMP_CWORD}-2]}" == "$COMP_CWORD_2_2" || "${COMP_WORDS[${COMP_CWORD}-2]}" == "-${COMP_CWORD_2_2:2:1}" ]]; then
            COMPREPLY=($(compgen -W "$COMP_CWORD_2_1 $COMP_CWORD_2_3 $COMP_CWORD_2_4" -- ${CURRENT_WORD}))
        elif [[ "${COMP_WORDS[${COMP_CWORD}-2]}" == "$COMP_CWORD_2_3" || "${COMP_WORDS[${COMP_CWORD}-2]}" == "-${COMP_CWORD_2_3:2:1}" ]]; then
            COMPREPLY=($(compgen -W "$COMP_CWORD_2_1 $COMP_CWORD_2_2 $COMP_CWORD_2_4" -- ${CURRENT_WORD}))
        elif [[ "${COMP_WORDS[${COMP_CWORD}-2]}" == "$COMP_CWORD_2_4" || "${COMP_WORDS[${COMP_CWORD}-2]}" == "-${COMP_CWORD_2_4:2:1}" ]]; then
            COMPREPLY=($(compgen -W "$COMP_CWORD_2_1 $COMP_CWORD_2_2 $COMP_CWORD_2_3" -- ${CURRENT_WORD}))
        fi
    fi
}

command_completion_7() {
    CURRENT_WORD=$1
    COMP_CWORD=$2
    COMP_WORDS_1=$3
    COMP_WORDS_2=$4
    COMP_WORDS_3=$5

    # Define an array for the remaining arguments
    shift 5
    args=("$@")

    # Access elements of the array (we could extend this)
    COMP_CWORD_2_1=${args[0]}
    COMP_CWORD_2_2=${args[1]}
    COMP_CWORD_2_3=${args[2]}

    if [[ "${COMP_WORDS[1]}" == "$COMP_WORDS_1" && "${COMP_WORDS[2]}" == "$COMP_WORDS_2" && ( "${COMP_WORDS[3]}" == "$COMP_WORDS_3" || "${COMP_WORDS[3]}" == "-${COMP_WORDS_3:2:1}" ) ]]; then
        if [[ "${COMP_WORDS[${COMP_CWORD}-2]}" == "$COMP_CWORD_2_1" || "${COMP_WORDS[${COMP_CWORD}-2]}" == "-${COMP_CWORD_2_1:2:1}" ]]; then
            COMPREPLY=($(compgen -W "$COMP_CWORD_2_2 $COMP_CWORD_2_3" -- ${CURRENT_WORD}))
        elif [[ "${COMP_WORDS[${COMP_CWORD}-2]}" == "$COMP_CWORD_2_2" || "${COMP_WORDS[${COMP_CWORD}-2]}" == "-${COMP_CWORD_2_2:2:1}" ]]; then
            COMPREPLY=($(compgen -W "$COMP_CWORD_2_1 $COMP_CWORD_2_3" -- ${CURRENT_WORD}))
        elif [[ "${COMP_WORDS[${COMP_CWORD}-2]}" == "$COMP_CWORD_2_3" || "${COMP_WORDS[${COMP_CWORD}-2]}" == "-${COMP_CWORD_2_3:2:1}" ]]; then
            COMPREPLY=($(compgen -W "$COMP_CWORD_2_1 $COMP_CWORD_2_2" -- ${CURRENT_WORD}))
        fi
    fi
}

command_completion_9() {
    CURRENT_WORD=$1
    COMP_CWORD=$2
    COMP_WORDS_1=$3
    COMP_WORDS_2=$4
    COMP_WORDS_3=$5
    COMP_WORDS_5=$6 

    # Define an array for the remaining arguments
    shift 6
    args=("$@")

    # Access elements of the array (we could extend this)
    COMP_CWORD_2_1=${args[0]}
    COMP_CWORD_2_2=${args[1]}
    COMP_CWORD_2_3=${args[2]}

    if [[ "${COMP_WORDS[1]}" == "$COMP_WORDS_1" && "${COMP_WORDS[2]}" == "$COMP_WORDS_2" && ( "${COMP_WORDS[3]}" == "$COMP_WORDS_3" || "${COMP_WORDS[3]}" == "-${COMP_WORDS_3:2:1}" ) && ( "${COMP_WORDS[5]}" == "$COMP_WORDS_5" || "${COMP_WORDS[5]}" == "-${COMP_WORDS_5:2:1}" ) ]]; then
        if [[ "${COMP_WORDS[${COMP_CWORD}-2]}" == "$COMP_CWORD_2_1" || "${COMP_WORDS[${COMP_CWORD}-2]}" == "-${COMP_CWORD_2_1:2:1}" ]]; then
            COMPREPLY=($(compgen -W "$COMP_CWORD_2_2" -- ${CURRENT_WORD}))
        elif [[ "${COMP_WORDS[${COMP_CWORD}-2]}" == "$COMP_CWORD_2_2" || "${COMP_WORDS[${COMP_CWORD}-2]}" == "-${COMP_CWORD_2_2:2:1}" ]]; then
            COMPREPLY=($(compgen -W "$COMP_CWORD_2_1" -- ${CURRENT_WORD}))
        fi
    fi
}

get_remaining_flags() {
    # First argument: Array of previous flags to exclude
    local -a previous_flags=("${!1}")
    # Remaining arguments: All available flags
    shift
    local -a FLAGS=("$@")

    # Array to hold remaining flags
    local -a remaining_flags=()

    for flag in "${FLAGS[@]}"; do
        # Check if the current flag is NOT in the previous_flags array
        local exclude=false
        for prev_flag in "${previous_flags[@]}"; do
            if [[ "$flag" == "$prev_flag" ]]; then
                exclude=true
                break
            fi
        done
        # Add the flag to remaining_flags if it's not excluded
        if [[ "$exclude" == false ]]; then
            remaining_flags+=("$flag")
        fi
    done

    # Print the resulting array
    echo "${remaining_flags[@]}"
}

_hdev_completions()
{
    local cur

    cur=${COMP_WORDS[COMP_CWORD]}

    # Check if the current word is a file path
    if [[ ${cur} == ./* || ${cur} == /* || ${cur} == ../* ]]; then
        # Trim trailing spaces and slash if present
        cur="${cur%%[[:space:]]}"

        # Generate completions for directories and files
        dir_completions=($(compgen -d -- "${cur}"))
        file_completions=($(compgen -f -- "${cur}"))

        # Combine both directory and file completions
        COMPREPLY=("${dir_completions[@]}" "${file_completions[@]}")

        # Add a trailing slash for directory completions
        for ((i = 0; i < ${#COMPREPLY[@]}; i++)); do
            if [[ -d ${COMPREPLY[$i]} ]]; then
                COMPREPLY[$i]+="/"
            fi
        done

        # Disable appending space after completion
        compopt -o nospace
        return 0
    fi

    #evaluate integrations
    gpu_enabled=$([ "$IS_GPU_DEVELOPER" = "1" ] && [ "$is_gpu" = "1" ] && echo 1 || echo 0)
    vivado_enabled=$([ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; } && echo 1 || echo 0)
    vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)

    case ${COMP_CWORD} in
        1)
            #check on server
            commands="examine get set validate --help --release"
            if [ "$is_acap" = "1" ]; then
                commands="${commands} build"
            fi
            if [ "$is_asoc" = "1" ]; then
                commands="${commands} build"
            fi
            if [ "$is_build" = "1" ]; then
                commands="${commands} build enable examine new"
            fi
            if [ "$is_fpga" = "1" ]; then
                commands="${commands} build"
            fi
            if [ "$is_gpu" = "1" ]; then
                commands="${commands} build"
            fi
            if [ "$gpu_enabled" = "1" ]; then
                commands="${commands} build new"
            fi
            if [ "$vivado_enabled" = "1" ]; then
                commands="${commands} build new"
            fi
            if [ ! "$is_build" = "1" ] && [ "$gpu_enabled" = "1" ]; then
                commands="${commands} run"
            fi
            if [ ! "$is_build" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; }; then
                commands="${commands} program"
            fi
            if [ ! "$is_build" = "1" ] && ([ "$gpu_enabled" = "1" ] || [ "$vivado_enabled" = "1" ] || [ "$vivado_enabled_asoc" = "1" ]); then
                commands="${commands} run"
            fi

            # Check on groups
            if [ "$is_sudo" = "1" ]; then
                commands="${commands} reboot update"
            fi
            if [ "$is_build" = "0" ] && [ "$is_vivado_developer" = "1" ]; then
                commands="${commands} reboot"
            fi

            commands_array=($commands)
            commands_array=($(echo "${commands_array[@]}" | tr ' ' '\n' | sort | uniq))
            commands_string=$(echo "${commands_array[@]}")
            COMPREPLY=($(compgen -W "${commands_string}" -- ${cur}))
            ;;
        2)
            case ${COMP_WORDS[COMP_CWORD-1]} in
                build)
                    commands="c --help"
                    if [ "$is_build" = "1" ] || [ "$vivado_enabled_asoc" = "1" ]; then
                        commands="${commands} aved"
                    fi
                    if [ "$is_build" = "1" ] || [ "$gpu_enabled" = "1" ]; then
                        commands="${commands} hip"
                    fi
                    if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "1" ]; then
                        commands="${commands} opennic"
                    fi
                    commands_array=($commands)
                    commands_array=($(echo "${commands_array[@]}" | tr ' ' '\n' | sort | uniq))
                    commands_string=$(echo "${commands_array[@]}")
                    COMPREPLY=($(compgen -W "${commands_string}" -- ${cur}))
                    ;;
                enable)
                    COMPREPLY=($(compgen -W "vitis vivado xrt --help" -- ${cur}))
                    ;;
                examine)
                    COMPREPLY=($(compgen -W "--help" -- ${cur}))
                    ;;
                get)
                    commands="ifconfig servers topo --help"
                    if [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; then
                        commands="${commands} bdf clock memory name network platform resource serial slr workflow"
                    fi
                    if [ "$is_asoc" = "1" ]; then
                        commands="${commands} bdf name network serial uuid workflow"
                    fi
                    if [ "$is_gpu" = "1" ]; then
                        commands="${commands} bus"
                    fi 
                    if [ ! "$is_build" = "1" ] && [ "$is_vivado_developer" = "1" ]; then
                        commands="${commands} syslog"
                    fi 
                    commands_array=($commands)
                    commands_array=($(echo "${commands_array[@]}" | tr ' ' '\n' | sort | uniq))
                    commands_string=$(echo "${commands_array[@]}")
                    COMPREPLY=($(compgen -W "${commands_string}" -- ${cur}))
                    ;;
                new)
                    commands="--help"
                    if [ "$is_build" = "1" ] || [ "$vivado_enabled_asoc" = "1" ]; then
                        commands="${commands} aved"
                    fi
                    if [ "$is_build" = "1" ] || [ "$gpu_enabled" = "1" ]; then
                        commands="${commands} hip"
                    fi
                    if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "1" ]; then
                        commands="${commands} opennic"
                    fi
                    commands_array=($commands)
                    commands_array=($(echo "${commands_array[@]}" | tr ' ' '\n' | sort | uniq))
                    commands_string=$(echo "${commands_array[@]}")
                    COMPREPLY=($(compgen -W "${commands_string}" -- ${cur}))
                    #COMPREPLY=($(compgen -W "hip opennic --help" -- ${cur}))
                    ;;
                program)
                    commands="--help"
                    if [ "$is_vivado_developer" = "1" ]; then
                        commands="${commands} bitstream driver" #vivado
                    fi
                    if [ ! "$is_virtualized" = "1" ] && [ "$is_vivado_developer" = "1" ]; then
                        commands="${commands} opennic"
                    fi
                    if [ ! "$is_asoc" = "1" ]; then
                        commands="${commands} reset"
                    fi
                    if [ ! "$is_virtualized" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; }; then
                        commands="${commands} revert"
                    fi
                    if [ "$vivado_enabled_asoc" = "1" ]; then
                        commands="${commands} image aved"
                    fi
                    commands_array=($commands)
                    commands_array=($(echo "${commands_array[@]}" | tr ' ' '\n' | sort | uniq))
                    commands_string=$(echo "${commands_array[@]}")
                    COMPREPLY=($(compgen -W "${commands_string}" -- ${cur}))
                    ;;
                reboot)
                    COMPREPLY=($(compgen -W "--help" -- ${cur}))
                    ;;
                run)
                    commands="--help"
                    if [ "$vivado_enabled_asoc" = "1" ]; then
                        commands="${commands} aved"
                    fi
                    if [ ! "$is_build" = "1" ] && [ "$gpu_enabled" = "1" ]; then
                        commands="${commands} hip"
                    fi
                    if [ ! "$is_build" = "1" ] && [ "$vivado_enabled" = "1" ]; then
                        commands="${commands} opennic"
                    fi
                    commands_array=($commands)
                    commands_array=($(echo "${commands_array[@]}" | tr ' ' '\n' | sort | uniq))
                    commands_string=$(echo "${commands_array[@]}")
                    COMPREPLY=($(compgen -W "${commands_string}" -- ${cur}))
                    ;;
                set)
                    commands="gh keys --help"
                    if [ "$is_vivado_developer" = "1" ]; then
                        commands="${commands} license"
                    fi
                    if [ ! "$is_build" = "1" ] && [ "$is_vivado_developer" = "1" ]; then
                        commands="${commands} mtu"
                    fi
                    commands_array=($commands)
                    commands_array=($(echo "${commands_array[@]}" | tr ' ' '\n' | sort | uniq))
                    commands_string=$(echo "${commands_array[@]}")
                    COMPREPLY=($(compgen -W "${commands_string}" -- ${cur}))
                    #COMPREPLY=($(compgen -W "gh keys license mtu --help" -- ${cur})) #write
                    ;;
                update)
                    COMPREPLY=($(compgen -W "--help" -- ${cur}))
                    ;;
                validate)
                    commands="docker --help"
                    if [ "$vivado_enabled_asoc" = "1" ]; then
                        commands="${commands} aved"
                    fi
                    if [ ! "$is_build" = "1" ] && [ "$gpu_enabled" = "1" ]; then
                        commands="${commands} hip"
                    fi
                    if [ ! "$is_build" = "1" ] && [ ! "$is_virtualized" = "1" ] && [ "$vivado_enabled" = "1" ]; then
                        commands="${commands} opennic"
                    fi
                    if [ ! "$is_build" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; }; then
                        commands="${commands} vitis"
                    fi
                    commands_array=($commands)
                    commands_array=($(echo "${commands_array[@]}" | tr ' ' '\n' | sort | uniq))
                    commands_string=$(echo "${commands_array[@]}")
                    COMPREPLY=($(compgen -W "${commands_string}" -- ${cur}))
                    #COMPREPLY=($(compgen -W "docker hip opennic vitis --help" -- ${cur}))
                    ;;
            esac
            ;;
        3)
            case ${COMP_WORDS[COMP_CWORD-2]} in
                build)
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        aved)
                            COMPREPLY=($(compgen -W "--project --tag --help" -- ${cur}))
                            ;;
                        c)
                            COMPREPLY=($(compgen -W "--source --help" -- ${cur}))
                            ;;
                        hip)
                            COMPREPLY=($(compgen -W "--project --help" -- ${cur}))
                            ;;
                        opennic)
                            if [ "$is_build" = "0" ] && [ "$is_vivado_developer" = "1" ]; then
                                #platform is not offered
                                COMPREPLY=($(compgen -W "--commit --project --help" -- ${cur}))
                            elif [ "$is_vivado_developer" = "1" ]; then
                                COMPREPLY=($(compgen -W "--commit --platform --project --help" -- ${cur}))
                            fi
                            ;;
                    esac
                    ;;
                enable) 
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        vitis)
                            COMPREPLY=($(compgen -W "--help" -- ${cur}))
                            ;;
                        vivado) 
                            COMPREPLY=($(compgen -W "--help" -- ${cur}))
                            ;;
                        xrt) 
                            COMPREPLY=($(compgen -W "--help" -- ${cur}))
                            ;;
                    esac
                    ;;
                get)
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        bdf)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        clock)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        bus)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        memory)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        name)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        ifconfig) 
                            COMPREPLY=($(compgen -W "--device --port --help" -- ${cur}))
                            ;;
                        network) 
                            COMPREPLY=($(compgen -W "--device --port --help" -- ${cur}))
                            ;;
                        platform) 
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        resource)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        serial) 
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        slr)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        servers) 
                            COMPREPLY=($(compgen -W "--help" -- ${cur}))
                            ;;
                        syslog) 
                            COMPREPLY=($(compgen -W "--help" -- ${cur}))
                            ;;
                        topo) 
                            COMPREPLY=($(compgen -W "--help" -- ${cur}))
                            ;;
                        uuid)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        workflow) 
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                    esac
                    ;;
                new) 
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        aved)
                            COMPREPLY=($(compgen -W "--project --push --tag --help" -- ${cur}))
                            ;;
                        hip)
                            COMPREPLY=($(compgen -W "--help" -- ${cur}))
                            ;;
                        opennic)
                            COMPREPLY=($(compgen -W "--commit --project --push --help" -- ${cur}))
                            ;;
                    esac
                    ;;
                program)
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        aved)
                            COMPREPLY=($(compgen -W "--device --project --tag --remote --help" -- ${cur})) # --type
                            ;;
                        bitstream) 
                            COMPREPLY=($(compgen -W "--device --path --remote --help" -- ${cur})) #--bitstream
                            ;;
                        driver)
                            COMPREPLY=($(compgen -W "--insert --params --remote --remove --help" -- ${cur}))
                            ;;
                        image)
                            COMPREPLY=($(compgen -W "--device --path --remote --help" -- ${cur})) # --type --partition
                            ;;
                        opennic)
                            #COMPREPLY=($(compgen -W "--commit --device --project --remote --help" -- ${cur}))
                            COMPREPLY=($(compgen -W "${OPENNIC_PROGRAM_FLAGS[*]}" -- "${cur}"))
                            ;;
                        reset)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        revert)
                            COMPREPLY=($(compgen -W "--device --remote --help" -- ${cur}))
                            ;;
                        #vivado) 
                        #    COMPREPLY=($(compgen -W "--bitstream --device --remote --help" -- ${cur}))
                        #    ;;
                    esac
                    ;;
                run)
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        aved)
                            COMPREPLY=($(compgen -W "--config --device --project --tag --help" -- ${cur})) 
                            ;;
                        hip)
                            COMPREPLY=($(compgen -W "--device --project --help" -- ${cur}))
                            ;;
                        opennic)
                            COMPREPLY=($(compgen -W "--commit --config --device --project --help" -- ${cur})) 
                            ;;
                    esac
                    ;;
                set)
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        gh)
                            COMPREPLY=($(compgen -W "--help" -- ${cur})) 
                            ;;
                        keys)
                            COMPREPLY=($(compgen -W "--help" -- ${cur})) 
                            ;;
                        license)
                            COMPREPLY=($(compgen -W "--help" -- ${cur})) 
                            ;;
                        mtu)
                            COMPREPLY=($(compgen -W "--device --port --value --help" -- ${cur})) 
                            ;;
                    esac
                    ;;
                validate)
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        aved)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        docker)
                            COMPREPLY=($(compgen -W "--help" -- ${cur}))
                            ;;
                        hip)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        opennic)
                            COMPREPLY=($(compgen -W "--commit --device --fec --help" -- ${cur}))
                            ;;
                        vitis) 
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                    esac
                    ;;
            esac
            ;;
        5) 
            #one flag is already present (the previous_flag)
            #program opennic --device 1 --
            #COMP_CWORD-4: program
            #COMP_CWORD-3: opennic
            #COMP_CWORD-2: --device
            #COMP_CWORD-1: 1

            previous_flags=${COMP_WORDS[COMP_CWORD-2]}

            #program opennic
            if [[ "${COMP_WORDS[COMP_CWORD-4]}" == "program" && "${COMP_WORDS[COMP_CWORD-3]}" == "opennic" ]]; then
                remaining_flags=$(get_remaining_flags previous_flags[@] "${OPENNIC_PROGRAM_FLAGS[@]}")
                COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
            fi

            ;;
        7)
            #two flags are already present
            #program opennic --device 1 --commit 8077751 --
            #COMP_CWORD-6: program
            #COMP_CWORD-5: opennic
            #COMP_CWORD-4: --device
            #COMP_CWORD-3: 1
            #COMP_CWORD-2: --commit
            #COMP_CWORD-1: 8077751

            previous_flags=("${COMP_WORDS[COMP_CWORD-2]}" "${COMP_WORDS[COMP_CWORD-4]}")

            #program opennic
            if [[ "${COMP_WORDS[COMP_CWORD-6]}" == "program" && "${COMP_WORDS[COMP_CWORD-5]}" == "opennic" ]]; then
                remaining_flags=$(get_remaining_flags previous_flags[@] "${OPENNIC_PROGRAM_FLAGS[@]}")
                COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
            fi

            ;;
        9)
            #three flags are already present
            #program opennic --device 1 --commit 8077751 --fec 1 --
            #COMP_CWORD-8: program
            #COMP_CWORD-7: opennic
            #COMP_CWORD-6: --device
            #COMP_CWORD-5: 1
            #COMP_CWORD-4: --commit
            #COMP_CWORD-3: 8077751
            #COMP_CWORD-2: --fec
            #COMP_CWORD-1: 0
            
            previous_flags=("${COMP_WORDS[COMP_CWORD-2]}" "${COMP_WORDS[COMP_CWORD-4]}" "${COMP_WORDS[COMP_CWORD-6]}")

            #program opennic
            if [[ "${COMP_WORDS[COMP_CWORD-8]}" == "program" && "${COMP_WORDS[COMP_CWORD-7]}" == "opennic" ]]; then
                remaining_flags=$(get_remaining_flags previous_flags[@] "${OPENNIC_PROGRAM_FLAGS[@]}")
                COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
            fi

            ;;
        11)
            #four flags are already present
            #program opennic --device 1 --commit 8077751 --fec 0 --project my_project --
            #COMP_CWORD-10: program
            #COMP_CWORD-9: opennic
            #COMP_CWORD-8: --device
            #COMP_CWORD-7: 1
            #COMP_CWORD-6: --commit
            #COMP_CWORD-5: 8077751
            #COMP_CWORD-4: --fec
            #COMP_CWORD-3: 0
            #COMP_CWORD-2: --project
            #COMP_CWORD-1: my_project

            previous_flags=("${COMP_WORDS[COMP_CWORD-2]}" "${COMP_WORDS[COMP_CWORD-4]}" "${COMP_WORDS[COMP_CWORD-6]}" "${COMP_WORDS[COMP_CWORD-8]}")

            #program opennic
            if [[ "${COMP_WORDS[COMP_CWORD-10]}" == "program" && "${COMP_WORDS[COMP_CWORD-9]}" == "opennic" ]]; then
                remaining_flags=$(get_remaining_flags previous_flags[@] "${OPENNIC_PROGRAM_FLAGS[@]}")
                COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
            fi

            ;;
        13)
            

            #program opennic --device 1 --commit 8077751 --fec 0 --project my_project --remote 0 --
            #COMP_CWORD-12: program
            #COMP_CWORD-11: opennic
            #COMP_CWORD-10: --device
            #COMP_CWORD-9: 1
            #COMP_CWORD-8: --commit
            #COMP_CWORD-7: 8077751
            #COMP_CWORD-6: --fec
            #COMP_CWORD-5: 0
            #COMP_CWORD-4: --project
            #COMP_CWORD-3: my_project
            #COMP_CWORD-2: --remote
            #COMP_CWORD-1: 0

            previous_flags=("${COMP_WORDS[COMP_CWORD-2]}" "${COMP_WORDS[COMP_CWORD-4]}" "${COMP_WORDS[COMP_CWORD-6]}" "${COMP_WORDS[COMP_CWORD-8]}" "${COMP_WORDS[COMP_CWORD-10]}")

            #program opennic
            if [[ "${COMP_WORDS[COMP_CWORD-12]}" == "program" && "${COMP_WORDS[COMP_CWORD-11]}" == "opennic" ]]; then
                remaining_flags=$(get_remaining_flags previous_flags[@] "${OPENNIC_PROGRAM_FLAGS[@]}")
                COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
            fi

            ;;
        15)
            echo "I am 15!"

            echo "-14: ${COMP_WORDS[COMP_CWORD-14]}"
            echo "-13: ${COMP_WORDS[COMP_CWORD-13]}"
            echo "-12: ${COMP_WORDS[COMP_CWORD-12]}"
            echo "-11: ${COMP_WORDS[COMP_CWORD-11]}"
            echo "-10: ${COMP_WORDS[COMP_CWORD-10]}"
            echo "-9: ${COMP_WORDS[COMP_CWORD-9]}"
            echo "-8: ${COMP_WORDS[COMP_CWORD-8]}"
            echo "-7: ${COMP_WORDS[COMP_CWORD-7]}"
            echo "-6: ${COMP_WORDS[COMP_CWORD-6]}"
            echo "-5: ${COMP_WORDS[COMP_CWORD-5]}"
            echo "-4: ${COMP_WORDS[COMP_CWORD-4]}"
            echo "-3: ${COMP_WORDS[COMP_CWORD-3]}"
            echo "-2: ${COMP_WORDS[COMP_CWORD-2]}"
            echo "-1: ${COMP_WORDS[COMP_CWORD-1]}"

            ;;
        *)
            COMPREPLY=()
            ;;
    esac
}

complete -F _hdev_completions hdev
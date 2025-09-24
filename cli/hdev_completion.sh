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
is_nic=$($CLI_PATH/common/is_nic $CLI_PATH $hostname)
is_numa=$($CLI_PATH/common/is_numa $CLI_PATH)

#check on groups
IS_GPU_DEVELOPER="1"
is_sudo=$($CLI_PATH/common/is_sudo $USER)
is_vivado_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
is_network_developer=$($CLI_PATH/common/is_member $USER vivado_developers)
is_hdev_developer=$($CLI_PATH/common/is_member $USER hdev_developers)

#evaluate integrations
gpu_enabled=$([ "$IS_GPU_DEVELOPER" = "1" ] && [ "$is_gpu" = "1" ] && echo 1 || echo 0)
vivado_enabled=$([ "$is_vivado_developer" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; } && echo 1 || echo 0)
vivado_enabled_asoc=$([ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "1" ] && echo 1 || echo 0)
nic_enabled=$([ "$is_network_developer" = "1" ] && [ "$is_nic" = "1" ] && echo 1 || echo 0)

#flags
COYOTE_BUILD_FLAGS=( "--commit" "--project" "--target" )
COYOTE_NEW_FLAGS=( "--commit" "--name" "--project" "--push" "--number" "--template" )
COYOTE_PROGRAM_FLAGS=( "--commit" "--device" "--project" "--remote" )
COYOTE_RUN_FLAGS=( "--commit" "--config" "--project" )
GET_PERFORMANCE_FLAGS=( "--device" )
OPENNIC_BUILD_FLAGS=( "--commit" "--project" )
OPENNIC_NEW_FLAGS=( "--commit" "--name" "--project" "--push" "--hls" ) #--device
OPENNIC_PROGRAM_FLAGS=( "--commit" "--device" "--fec" "--project" "--remote" ) #"--xdp"
OPENNIC_RUN_FLAGS=( "--commit" "--config" "--project" ) #"--device" 
OPENNIC_VALIDATE_FLAGS=( "--commit" "--device" "--fec" )
PROGRAM_BITSTREAM_FLAGS=( "--device" "--hotplug" "--path" "--remote" )
PROGRAM_IMAGE_FLAGS=( "--device" "--path" "--remote" "--partition" )
PROGRAM_REVERT_FLAGS=( "--device" "--remote" )
SET_BALANCING_FLAGS=( "--value" )
SET_HUGEPAGES_FLAGS=( "--pages" "--size" )
SET_MTU_FLAGS=( "--device" "--port" "--value" )
SET_PERFORMANCE_FLAGS=( "--device" "--value" )
SOCKPERF_RUN_FLAGS=( "--interface" "--server" "--size" )
TENSORFLOW_RUN_FLAGS=( "--config" "--project" )
TENSORFLOW_NEW_FLAGS=( "--project" "--push" )
UPDATE_FLAGS=( "--latest" "--number" "--tag" )
VIVADO_OPEN_FLAGS=( "--path" )
VRT_NEW_FLAGS=( "--project" "--push" "--tag" "--template" "--name" "--number" )
VRT_BUILD_FLAGS=( "--project" "--tag" "--target" )
VRT_PROGRAM_FLAGS=( "--device" "--project" "--tag" "--remote" )
VRT_RUN_FLAGS=( "--project" "--tag" "--target" )
if [ "$is_hdev_developer" = "1" ]; then
    VRT_VALIDATE_FLAGS=( "--device" "--tag" "--target" "--number" )
else
    VRT_VALIDATE_FLAGS=( "--device" "--tag" "--target" )
fi
XDP_BUILD_FLAGS=( "--commit" "--project" )
XDP_NEW_FLAGS=( "--commit" "--project" "--push" )
XDP_PROGRAM_FLAGS=( "--commit" "--interface" "--project" "--start" ) #"--stop"

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

    case ${COMP_CWORD} in
        1)
            #check on server
            commands="examine get open set validate --help --release"
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
            if [ ! "$is_build" = "1" ] && ([ "$gpu_enabled" = "1" ] || [ "$vivado_enabled" = "1" ] || [ "$nic_enabled" = "1" ]); then
                commands="${commands} new"
            fi
            if [ "$gpu_enabled" = "1" ]; then
                commands="${commands} build"
            fi
            if [ "$vivado_enabled" = "1" ]; then
                commands="${commands} build"
            fi
            if [ ! "$is_nic" = "1" ] && [ "$is_network_developer" = "1" ]; then
                commands="${commands} build run"
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
            #if [ "$is_sudo" = "1" ]; then
            #    commands="${commands} checkout"
            #fi
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
                        commands="${commands} vrt coyote"
                    fi
                    if [ "$is_build" = "1" ] || [ "$vivado_enabled" = "1" ]; then
                        commands="${commands} opennic coyote"
                    fi
                    if [ "$is_nic" = "1" ] && [ "$is_network_developer" = "1" ]; then
                        commands="${commands} xdp"
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
                    commands="interfaces servers topo --help"
                    if [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; then
                        commands="${commands} bdf name platform serial workflow"
                    fi
                    if [ "$is_asoc" = "1" ]; then
                        commands="${commands} bdf name serial uuid workflow"
                    fi
                    if [ "$is_gpu" = "1" ]; then
                        commands="${commands} bus performance"
                    fi 
                    if [ ! "$is_build" = "1" ] && [ "$is_vivado_developer" = "1" ]; then
                        commands="${commands} dmesg syslog hugepages"
                    fi 
                    commands_array=($commands)
                    commands_array=($(echo "${commands_array[@]}" | tr ' ' '\n' | sort | uniq))
                    commands_string=$(echo "${commands_array[@]}")
                    COMPREPLY=($(compgen -W "${commands_string}" -- ${cur}))
                    ;;
                new)
                    #if [ ! "$is_build" = "1" ]; then
                        commands="--help"
                    
                        if [ "$is_build" = "1" ]; then
                            commands="${commands} vrt tensorflow opennic xdp coyote"
                        fi

                        if [ "$is_build" = "0" ] && [ "$vivado_enabled_asoc" = "1" ]; then
                            commands="${commands} vrt"
                        fi
                        if [ "$is_build" = "0" ] && [ "$gpu_enabled" = "1" ]; then
                            commands="${commands} tensorflow"
                        fi
                        if [ "$is_build" = "0" ] && [ "$vivado_enabled" = "1" ]; then
                            commands="${commands} opennic coyote"
                        fi
                        if [ "$is_build" = "0" ] && [ "$nic_enabled" = "1" ]; then
                            commands="${commands} xdp"
                        fi
                        commands_array=($commands)
                        commands_array=($(echo "${commands_array[@]}" | tr ' ' '\n' | sort | uniq))
                        commands_string=$(echo "${commands_array[@]}")
                        COMPREPLY=($(compgen -W "${commands_string}" -- ${cur}))
                    #fi
                    ;;
                open)
                    commands="vivado --help"
                    commands_array=($commands)
                    commands_array=($(echo "${commands_array[@]}" | tr ' ' '\n' | sort | uniq))
                    commands_string=$(echo "${commands_array[@]}")
                    COMPREPLY=($(compgen -W "${commands_string}" -- ${cur}))
                    ;;
                program)
                    if [ ! "$is_build" = "1" ]; then
                        commands="--help"
                        if [ "$is_vivado_developer" = "1" ]; then
                            commands="${commands} driver" #vivado #bitstream
                        fi
                        if [ "$is_vivado_developer" = "1" ] && [ "$is_asoc" = "0" ]; then
                            commands="${commands} bitstream"
                        fi
                        if [ "$is_vivado_developer" = "1" ]; then
                            commands="${commands} opennic coyote"
                        fi
                        if [ ! "$is_asoc" = "1" ]; then
                            commands="${commands} reset"
                        fi
                        if [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ]; then
                            commands="${commands} revert"
                        fi
                        if [ "$vivado_enabled_asoc" = "1" ]; then
                            commands="${commands} image vrt"
                        fi
                        if [ "$is_nic" = "1" ] && [ "$is_network_developer" = "1" ]; then
                            commands="${commands} xdp"
                        fi
                        commands_array=($commands)
                        commands_array=($(echo "${commands_array[@]}" | tr ' ' '\n' | sort | uniq))
                        commands_string=$(echo "${commands_array[@]}")
                        COMPREPLY=($(compgen -W "${commands_string}" -- ${cur}))
                    fi
                    ;;
                reboot)
                    COMPREPLY=($(compgen -W "--help" -- ${cur}))
                    ;;
                run)
                    commands="--help"
                    if [ "$vivado_enabled_asoc" = "1" ]; then
                        commands="${commands} vrt"
                    fi
                    if [ ! "$is_build" = "1" ] && [ "$gpu_enabled" = "1" ]; then
                        commands="${commands} tensorflow"
                    fi
                    if [ ! "$is_build" = "1" ] && [ "$vivado_enabled" = "1" ]; then
                        commands="${commands} opennic coyote"
                    fi
                    if [ "$is_acap" = "1" ] || [ "$is_asoc" = "1" ] || [ "$is_fpga" = "1" ] || [ "$is_nic" = "1" ]; then
                        commands="${commands} sockperf"
                    fi
                    commands_array=($commands)
                    commands_array=($(echo "${commands_array[@]}" | tr ' ' '\n' | sort | uniq))
                    commands_string=$(echo "${commands_array[@]}")
                    COMPREPLY=($(compgen -W "${commands_string}" -- ${cur}))
                    ;;
                set)
                    commands="gh keys --help"
                    if [ "$is_build" = "0" ] && [ "$is_numa" = "1" ] && [ "$is_vivado_developer" = "1" ]; then
                        commands="${commands} balancing"
                    fi
                    if [ "$is_vivado_developer" = "1" ]; then
                        commands="${commands} license"
                    fi
                    if [ ! "$is_build" = "1" ] && [ "$is_vivado_developer" = "1" ]; then
                        commands="${commands} mtu hugepages"
                    fi
                    if [ "$is_gpu" = "1" ]; then
                        commands="${commands} performance"
                    fi 
                    commands_array=($commands)
                    commands_array=($(echo "${commands_array[@]}" | tr ' ' '\n' | sort | uniq))
                    commands_string=$(echo "${commands_array[@]}")
                    COMPREPLY=($(compgen -W "${commands_string}" -- ${cur}))
                    ;;
                update)
                    commands="--latest --number --tag --help"
                    commands_array=($commands)
                    commands_array=($(echo "${commands_array[@]}" | tr ' ' '\n' | sort | uniq))
                    commands_string=$(echo "${commands_array[@]}")
                    COMPREPLY=($(compgen -W "${commands_string}" -- ${cur}))
                    ;;
                validate)
                    commands="docker --help"
                    if [ ! "$is_build" = "1" ] && [ "$vivado_enabled_asoc" = "1" ]; then
                        commands="${commands} aved vrt"
                    fi
                    if [ ! "$is_build" = "1" ] && [ "$gpu_enabled" = "1" ]; then
                        commands="${commands} tensorflow"
                    fi
                    if [ ! "$is_build" = "1" ] && [ "$vivado_enabled" = "1" ]; then
                        commands="${commands} opennic"
                    fi
                    if [ ! "$is_build" = "1" ] && { [ "$is_acap" = "1" ] || [ "$is_fpga" = "1" ]; }; then
                        commands="${commands} vitis"
                    fi
                    commands_array=($commands)
                    commands_array=($(echo "${commands_array[@]}" | tr ' ' '\n' | sort | uniq))
                    commands_string=$(echo "${commands_array[@]}")
                    COMPREPLY=($(compgen -W "${commands_string}" -- ${cur}))
                    ;;
            esac
            ;;
        3)
            case ${COMP_WORDS[COMP_CWORD-2]} in
                build)
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        c)
                            COMPREPLY=($(compgen -W "--source --help" -- ${cur}))
                            ;;
                        coyote)
                            COMPREPLY=($(compgen -W "${COYOTE_BUILD_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                        opennic)
                            #if [ "$is_build" = "0" ] && [ "$is_vivado_developer" = "1" ]; then
                                COMPREPLY=($(compgen -W "${OPENNIC_BUILD_FLAGS[*]} --help" -- "${cur}"))
                            #elif [ "$is_vivado_developer" = "1" ]; then
                            #    COMPREPLY=($(compgen -W "${OPENNIC_BUILD_FLAGS[*]} --platform --help" -- "${cur}"))
                            #fi
                            ;;
                        vrt)
                            COMPREPLY=($(compgen -W "${VRT_BUILD_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                        xdp)
                            COMPREPLY=($(compgen -W "${XDP_BUILD_FLAGS[*]} --help" -- "${cur}"))
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
                        bus)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        name)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        dmesg) 
                            COMPREPLY=($(compgen -W "--help" -- ${cur}))
                            ;;
                        hugepages) 
                            COMPREPLY=($(compgen -W "--help" -- ${cur}))
                            ;;
                        interfaces)
                            COMPREPLY=($(compgen -W "--help" -- "${cur}"))
                            ;;
                        performance)
                            COMPREPLY=($(compgen -W "${GET_PERFORMANCE_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                        platform) 
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        serial) 
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
                        coyote)
                            COMPREPLY=($(compgen -W "${COYOTE_NEW_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                        opennic)
                            COMPREPLY=($(compgen -W "${OPENNIC_NEW_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                        tensorflow)
                            COMPREPLY=($(compgen -W "${TENSORFLOW_NEW_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                        vrt)
                            COMPREPLY=($(compgen -W "${VRT_NEW_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                        xdp)
                            COMPREPLY=($(compgen -W "${XDP_NEW_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                    esac
                    ;;
                open) 
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        vivado)
                            COMPREPLY=($(compgen -W "${VIVADO_OPEN_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                    esac
                    ;;
                program)
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        bitstream) 
                            COMPREPLY=($(compgen -W "${PROGRAM_BITSTREAM_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                        coyote)
                            COMPREPLY=($(compgen -W "${COYOTE_PROGRAM_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                        driver)
                            COMPREPLY=($(compgen -W "--insert --params --remote --remove --help" -- ${cur}))
                            ;;
                        image)
                            COMPREPLY=($(compgen -W "${PROGRAM_IMAGE_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                        opennic)
                            COMPREPLY=($(compgen -W "${OPENNIC_PROGRAM_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                        reset)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        revert)
                            COMPREPLY=($(compgen -W "${PROGRAM_REVERT_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                        vrt)
                            COMPREPLY=($(compgen -W "${VRT_PROGRAM_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                        xdp)
                            COMPREPLY=($(compgen -W "${XDP_PROGRAM_FLAGS[*]} --stop --help" -- "${cur}"))
                            ;;
                    esac
                    ;;
                run)
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        coyote)
                            COMPREPLY=($(compgen -W "${COYOTE_RUN_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                        opennic)
                            COMPREPLY=($(compgen -W "${OPENNIC_RUN_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                        sockperf)
                            COMPREPLY=($(compgen -W "${SOCKPERF_RUN_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                        tensorflow)
                            COMPREPLY=($(compgen -W "${TENSORFLOW_RUN_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                        vrt)
                            COMPREPLY=($(compgen -W "${VRT_RUN_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                    esac
                    ;;
                set)
                    case ${COMP_WORDS[COMP_CWORD-1]} in
                        balancing)
                            COMPREPLY=($(compgen -W "${SET_BALANCING_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                        gh)
                            COMPREPLY=($(compgen -W "--help" -- ${cur})) 
                            ;;
                        hugepages)
                            COMPREPLY=($(compgen -W "${SET_HUGEPAGES_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                        keys)
                            COMPREPLY=($(compgen -W "--help" -- ${cur})) 
                            ;;
                        license)
                            COMPREPLY=($(compgen -W "--help" -- ${cur})) 
                            ;;
                        mtu)
                            COMPREPLY=($(compgen -W "${SET_MTU_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                        performance)
                            COMPREPLY=($(compgen -W "${SET_PERFORMANCE_FLAGS[*]} --help" -- "${cur}"))
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
                        opennic)
                            COMPREPLY=($(compgen -W "${OPENNIC_VALIDATE_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                        tensorflow)
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        vitis) 
                            COMPREPLY=($(compgen -W "--device --help" -- ${cur}))
                            ;;
                        vrt)
                            COMPREPLY=($(compgen -W "${VRT_VALIDATE_FLAGS[*]} --help" -- "${cur}"))
                            ;;
                    esac
                    ;;
            esac
            ;;
        5) 
            #one flag is already present
            #program opennic --device 1 --
            #COMP_CWORD-4: program
            #COMP_CWORD-3: opennic
            #COMP_CWORD-2: --device (flag_1)
            #COMP_CWORD-1: 1

            previous_flags=( "${COMP_WORDS[COMP_CWORD-2]}" )

            case "${COMP_WORDS[COMP_CWORD-4]}" in
                build)
                    case "${COMP_WORDS[COMP_CWORD-3]}" in
                        coyote)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${COYOTE_BUILD_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        opennic)
                            #--commit --platform --project
                            #if [ "$is_build" = "0" ] && [ "$is_vivado_developer" = "1" ]; then
                                #platform is not offered
                                remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${OPENNIC_BUILD_FLAGS[*]}")
                                COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            #elif [ "$is_vivado_developer" = "1" ]; then
                            #    remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${OPENNIC_BUILD_FLAGS[*]} --platform")
                            #    COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            #fi
                            ;;
                        vrt)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${VRT_BUILD_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        xdp)
                            #--commit --project
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${XDP_BUILD_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                    esac
                    ;;
                new)
                    case "${COMP_WORDS[COMP_CWORD-3]}" in
                        coyote)
                            # Start from the default flags
                            local coyote_flags=("${COYOTE_NEW_FLAGS[@]}")
                            local prev="${previous_flags[*]}"

                            # Enforce mutual exclusion between --commit and --number
                            if [[ " $prev " == *" --commit "* ]]; then
                                # remove --number
                                local tmp=()
                                for f in "${coyote_flags[@]}"; do [[ "$f" != "--number" ]] && tmp+=("$f"); done
                                coyote_flags=("${tmp[@]}")
                            elif [[ " $prev " == *" --number "* ]]; then
                                # remove --commit
                                local tmp=()
                                for f in "${coyote_flags[@]}"; do [[ "$f" != "--commit" ]] && tmp+=("$f"); done
                                coyote_flags=("${tmp[@]}")
                            fi
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${coyote_flags[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        opennic)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${OPENNIC_NEW_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        tensorflow)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${TENSORFLOW_NEW_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        xdp)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${XDP_NEW_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        vrt)
                            # Start from the default flags
                            local vrt_flags=("${VRT_NEW_FLAGS[@]}")
                            local prev="${previous_flags[*]}"

                            # Enforce mutual exclusion between --tag and --number
                            if [[ " $prev " == *" --tag "* ]]; then
                                # remove --number
                                local tmp=()
                                for f in "${vrt_flags[@]}"; do [[ "$f" != "--number" ]] && tmp+=("$f"); done
                                vrt_flags=("${tmp[@]}")
                            elif [[ " $prev " == *" --number "* ]]; then
                                # remove --tag
                                local tmp=()
                                for f in "${vrt_flags[@]}"; do [[ "$f" != "--tag" ]] && tmp+=("$f"); done
                                vrt_flags=("${tmp[@]}")
                            fi
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${vrt_flags[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                    esac
                    ;;
                program)
                    case "${COMP_WORDS[COMP_CWORD-3]}" in
                        bitstream)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${PROGRAM_BITSTREAM_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        coyote)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${COYOTE_PROGRAM_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        driver)
                            if [ "${COMP_WORDS[COMP_CWORD-2]}" = "--insert" ]; then
                                remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "--params --remote")
                            elif [ "${COMP_WORDS[COMP_CWORD-2]}" = "--params" ]; then
                                remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "--insert --remote")
                            elif [ "${COMP_WORDS[COMP_CWORD-2]}" = "--remote" ]; then
                                remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "--insert --params")
                            elif [ "${COMP_WORDS[COMP_CWORD-2]}" = "--remove" ]; then
                                remaining_flags=""
                            fi
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        image)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${PROGRAM_IMAGE_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        opennic)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${OPENNIC_PROGRAM_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        revert)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${PROGRAM_REVERT_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        vrt)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${VRT_PROGRAM_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        xdp)
                            if [ "${previous_flags[0]}" = "--stop" ]; then
                                remaining_flags=""
                            else
                                remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${XDP_PROGRAM_FLAGS[*]}")
                            fi
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                    esac
                    ;;
                run)
                    case "${COMP_WORDS[COMP_CWORD-3]}" in
                        coyote)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${COYOTE_RUN_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        opennic)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${OPENNIC_RUN_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        sockperf)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${SOCKPERF_RUN_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        tensorflow)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${TENSORFLOW_RUN_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        vrt)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${VRT_RUN_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                    esac
                    ;;
                set)
                    case "${COMP_WORDS[COMP_CWORD-3]}" in
                        hugepages)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${SET_HUGEPAGES_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        mtu)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${SET_MTU_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        performance)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${SET_PERFORMANCE_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags[*]}" -- "${cur}"))
                            ;;
                    esac
                    ;;
                validate)
                    case "${COMP_WORDS[COMP_CWORD-3]}" in
                        opennic)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${OPENNIC_VALIDATE_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        vrt)
                            
                            #echo "HEY"
                            #echo "${previous_flags[*]}"
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${VRT_VALIDATE_FLAGS[*]}")
                            if [[ " ${previous_flags[*]} " == *"--number"* ]]; then
                                remaining_flags=("${remaining_flags[@]/--tag}")
                            elif [[ " ${previous_flags[*]} " == *"--tag"* ]]; then
                                remaining_flags=("${remaining_flags[@]/--number}")
                            fi
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                    esac
                    ;;
            esac
            ;;
        7)
            #two flags are already present
            #program opennic --device 1 --commit 8077751 --
            #COMP_CWORD-6: program
            #COMP_CWORD-5: opennic
            #COMP_CWORD-4: --device (flag_1)
            #COMP_CWORD-3: 1
            #COMP_CWORD-2: --commit (flag_2)
            #COMP_CWORD-1: 8077751

            previous_flags=("${COMP_WORDS[COMP_CWORD-2]}" "${COMP_WORDS[COMP_CWORD-4]}")

            case "${COMP_WORDS[COMP_CWORD-6]}" in
                build)
                    case "${COMP_WORDS[COMP_CWORD-5]}" in
                        coyote)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${COYOTE_BUILD_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        vrt)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${VRT_BUILD_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                    esac
                    ;;
                new)
                    case "${COMP_WORDS[COMP_CWORD-5]}" in
                        coyote)
                            # Start from the default flags
                            local coyote_flags=("${COYOTE_NEW_FLAGS[@]}")
                            local prev="${previous_flags[*]}"

                            # Enforce mutual exclusion between --commit and --number
                            if [[ " $prev " == *" --commit "* ]]; then
                                # remove --number
                                local tmp=()
                                for f in "${coyote_flags[@]}"; do [[ "$f" != "--number" ]] && tmp+=("$f"); done
                                coyote_flags=("${tmp[@]}")
                            elif [[ " $prev " == *" --number "* ]]; then
                                # remove --commit
                                local tmp=()
                                for f in "${coyote_flags[@]}"; do [[ "$f" != "--commit" ]] && tmp+=("$f"); done
                                coyote_flags=("${tmp[@]}")
                            fi
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${coyote_flags[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        opennic)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${OPENNIC_NEW_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        xdp)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${XDP_NEW_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        vrt)
                            # Start from the default flags
                            local vrt_flags=("${VRT_NEW_FLAGS[@]}")
                            local prev="${previous_flags[*]}"

                            # Enforce mutual exclusion between --tag and --number
                            if [[ " $prev " == *" --tag "* ]]; then
                                # remove --number
                                local tmp=()
                                for f in "${vrt_flags[@]}"; do [[ "$f" != "--number" ]] && tmp+=("$f"); done
                                vrt_flags=("${tmp[@]}")
                            elif [[ " $prev " == *" --number "* ]]; then
                                # remove --tag
                                local tmp=()
                                for f in "${vrt_flags[@]}"; do [[ "$f" != "--tag" ]] && tmp+=("$f"); done
                                vrt_flags=("${tmp[@]}")
                            fi
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${vrt_flags[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                    esac
                    ;;
                program)
                    case "${COMP_WORDS[COMP_CWORD-5]}" in
                        bitstream)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${PROGRAM_BITSTREAM_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        coyote)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${COYOTE_PROGRAM_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        driver)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "--insert --params --remote")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        image)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${PROGRAM_IMAGE_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        opennic)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${OPENNIC_PROGRAM_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        vrt)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${VRT_PROGRAM_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        xdp)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${XDP_PROGRAM_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                    esac
                    ;;
                run)
                    case "${COMP_WORDS[COMP_CWORD-5]}" in
                        coyote)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${COYOTE_RUN_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        opennic)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${OPENNIC_RUN_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        sockperf)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${SOCKPERF_RUN_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        vrt)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${VRT_RUN_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                    esac
                    ;;
                set)
                    case "${COMP_WORDS[COMP_CWORD-5]}" in
                        mtu)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${SET_MTU_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                    esac
                    ;;
                validate)
                    case "${COMP_WORDS[COMP_CWORD-5]}" in
                        opennic)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${OPENNIC_VALIDATE_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        vrt)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${VRT_VALIDATE_FLAGS[*]}")
                            if [[ " ${previous_flags[*]} " == *"--number"* ]]; then
                                remaining_flags=("${remaining_flags[@]/--tag}")
                            elif [[ " ${previous_flags[*]} " == *"--tag"* ]]; then
                                remaining_flags=("${remaining_flags[@]/--number}")
                            fi
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                    esac
                    ;;
            esac
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

            case "${COMP_WORDS[COMP_CWORD-8]}" in
                new)
                    case "${COMP_WORDS[COMP_CWORD-7]}" in
                        coyote)
                            # Start from the default flags
                            local coyote_flags=("${COYOTE_NEW_FLAGS[@]}")
                            local prev="${previous_flags[*]}"

                            # Enforce mutual exclusion between --commit and --number
                            if [[ " $prev " == *" --commit "* ]]; then
                                # remove --number
                                local tmp=()
                                for f in "${coyote_flags[@]}"; do [[ "$f" != "--number" ]] && tmp+=("$f"); done
                                coyote_flags=("${tmp[@]}")
                            elif [[ " $prev " == *" --number "* ]]; then
                                # remove --commit
                                local tmp=()
                                for f in "${coyote_flags[@]}"; do [[ "$f" != "--commit" ]] && tmp+=("$f"); done
                                coyote_flags=("${tmp[@]}")
                            fi
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${coyote_flags[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        opennic)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${OPENNIC_NEW_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        vrt)
                            # Start from the default flags
                            local vrt_flags=("${VRT_NEW_FLAGS[@]}")
                            local prev="${previous_flags[*]}"

                            # Enforce mutual exclusion between --tag and --number
                            if [[ " $prev " == *" --tag "* ]]; then
                                # remove --number
                                local tmp=()
                                for f in "${vrt_flags[@]}"; do [[ "$f" != "--number" ]] && tmp+=("$f"); done
                                vrt_flags=("${tmp[@]}")
                            elif [[ " $prev " == *" --number "* ]]; then
                                # remove --tag
                                local tmp=()
                                for f in "${vrt_flags[@]}"; do [[ "$f" != "--tag" ]] && tmp+=("$f"); done
                                vrt_flags=("${tmp[@]}")
                            fi
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${vrt_flags[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                    esac
                    ;;
                program)
                    case "${COMP_WORDS[COMP_CWORD-7]}" in
                        bitstream)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${PROGRAM_BITSTREAM_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        coyote)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${COYOTE_PROGRAM_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        image)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${PROGRAM_IMAGE_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        opennic)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${OPENNIC_PROGRAM_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        vrt)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${VRT_PROGRAM_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        xdp)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${XDP_PROGRAM_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                    esac
                    ;;
            esac
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

            case "${COMP_WORDS[COMP_CWORD-10]}" in
                new)
                    case "${COMP_WORDS[COMP_CWORD-9]}" in
                        coyote)
                            # Start from the default flags
                            local coyote_flags=("${COYOTE_NEW_FLAGS[@]}")
                            local prev="${previous_flags[*]}"

                            # Enforce mutual exclusion between --commit and --number
                            if [[ " $prev " == *" --commit "* ]]; then
                                # remove --number
                                local tmp=()
                                for f in "${coyote_flags[@]}"; do [[ "$f" != "--number" ]] && tmp+=("$f"); done
                                coyote_flags=("${tmp[@]}")
                            elif [[ " $prev " == *" --number "* ]]; then
                                # remove --commit
                                local tmp=()
                                for f in "${coyote_flags[@]}"; do [[ "$f" != "--commit" ]] && tmp+=("$f"); done
                                coyote_flags=("${tmp[@]}")
                            fi
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${coyote_flags[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        opennic)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${OPENNIC_NEW_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        vrt)
                            # Start from the default flags
                            local vrt_flags=("${VRT_NEW_FLAGS[@]}")
                            local prev="${previous_flags[*]}"

                            # Enforce mutual exclusion between --tag and --number
                            if [[ " $prev " == *" --tag "* ]]; then
                                # remove --number
                                local tmp=()
                                for f in "${vrt_flags[@]}"; do [[ "$f" != "--number" ]] && tmp+=("$f"); done
                                vrt_flags=("${tmp[@]}")
                            elif [[ " $prev " == *" --number "* ]]; then
                                # remove --tag
                                local tmp=()
                                for f in "${vrt_flags[@]}"; do [[ "$f" != "--tag" ]] && tmp+=("$f"); done
                                vrt_flags=("${tmp[@]}")
                            fi
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${vrt_flags[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                    esac
                    ;;
                program)
                    case "${COMP_WORDS[COMP_CWORD-9]}" in
                        opennic)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${OPENNIC_PROGRAM_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        xdp)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${XDP_PROGRAM_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                    esac
                    ;;
            esac
            ;;
        13)
            #five flags are already present
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

            case "${COMP_WORDS[COMP_CWORD-12]}" in
                new)
                    case "${COMP_WORDS[COMP_CWORD-11]}" in
                        coyote)
                            # Start from the default flags
                            local coyote_flags=("${COYOTE_NEW_FLAGS[@]}")
                            local prev="${previous_flags[*]}"

                            # Enforce mutual exclusion between --commit and --number
                            if [[ " $prev " == *" --commit "* ]]; then
                                # remove --number
                                local tmp=()
                                for f in "${coyote_flags[@]}"; do [[ "$f" != "--number" ]] && tmp+=("$f"); done
                                coyote_flags=("${tmp[@]}")
                            elif [[ " $prev " == *" --number "* ]]; then
                                # remove --commit
                                local tmp=()
                                for f in "${coyote_flags[@]}"; do [[ "$f" != "--commit" ]] && tmp+=("$f"); done
                                coyote_flags=("${tmp[@]}")
                            fi
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${coyote_flags[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        vrt)
                            # Start from the default flags
                            local vrt_flags=("${VRT_NEW_FLAGS[@]}")
                            local prev="${previous_flags[*]}"

                            # Enforce mutual exclusion between --tag and --number
                            if [[ " $prev " == *" --tag "* ]]; then
                                # remove --number
                                local tmp=()
                                for f in "${vrt_flags[@]}"; do [[ "$f" != "--number" ]] && tmp+=("$f"); done
                                vrt_flags=("${tmp[@]}")
                            elif [[ " $prev " == *" --number "* ]]; then
                                # remove --tag
                                local tmp=()
                                for f in "${vrt_flags[@]}"; do [[ "$f" != "--tag" ]] && tmp+=("$f"); done
                                vrt_flags=("${tmp[@]}")
                            fi
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${vrt_flags[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                    esac
                    ;;
                program)
                    case "${COMP_WORDS[COMP_CWORD-11]}" in
                        opennic)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${OPENNIC_PROGRAM_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                        xdp)
                            remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${XDP_PROGRAM_FLAGS[*]}")
                            COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
                            ;;
                    esac
                    ;;
            esac
            ;;
        #15)
        #    #six flags are already present
        #    #program opennic --device 1 --commit 8077751 --fec 0 --project my_project --remote 0 --xdp 0 --
        #    #COMP_CWORD-14: program
        #    #COMP_CWORD-13: opennic
        #    #COMP_CWORD-12: --device
        #    #COMP_CWORD-11: 1
        #    #COMP_CWORD-10: --commit
        #    #COMP_CWORD-9: 8077751
        #    #COMP_CWORD-8: --fec
        #    #COMP_CWORD-7: 0
        #    #COMP_CWORD-6: --project
        #    #COMP_CWORD-5: my_project
        #    #COMP_CWORD-4: --remote
        #    #COMP_CWORD-3: 0
        #    #COMP_CWORD-2: --xdp
        #    #COMP_CWORD-1: 0
        #
        #    #    For extending the code: 
        #    #        echo "-14: ${COMP_WORDS[COMP_CWORD-14]}"
        #    #        ...
        #    #        echo "-1: ${COMP_WORDS[COMP_CWORD-1]}"
        #    #        echo "previous_flags: ${previous_flags[@]}"
        #    #        echo "remaining_flags: ${remaining_flags[@]}"
        #    
        #    # The following is code that is working (jmoya82, 16.09.2025)
        #       
        #    previous_flags=("${COMP_WORDS[COMP_CWORD-2]}" "${COMP_WORDS[COMP_CWORD-4]}" "${COMP_WORDS[COMP_CWORD-6]}" "${COMP_WORDS[COMP_CWORD-8]}" "${COMP_WORDS[COMP_CWORD-10]}" "${COMP_WORDS[COMP_CWORD-12]}")
        #
        #    case "${COMP_WORDS[COMP_CWORD-14]}" in
        #        new)
        #            case "${COMP_WORDS[COMP_CWORD-13]}" in
        #                vrt)
        #                    remaining_flags=$($CLI_PATH/common/get_remaining_flags "${previous_flags[*]}" "${VRT_NEW_FLAGS[*]}")
        #                    COMPREPLY=($(compgen -W "${remaining_flags}" -- "${cur}"))
        #                    ;;
        #            esac
        #            ;;
        #    esac
        #    ;;
        *)
            COMPREPLY=()
            ;;
    esac
}

complete -F _hdev_completions hdev

#author: https://github.com/jmoya82
set command [lindex $argv 0]
set device [lindex $argv 1]
set ipname [lindex $argv 2]

set do_sim 0
set do_syn 0
set do_export 0
set do_cosim 0

switch $command {
    "sim" {
        set do_sim 1
    }
    "syn" {
        set do_syn 1
    }
    "ip" {
        set do_syn 1
        set do_export 1
    }
    "cosim" {
        set do_syn 1
        set do_cosim 1
    }
    "all" {
        set do_sim 1
        set do_syn 1
        set do_export 1
        set do_cosim 1
    }
    default {
        puts "Unrecognized command"
        exit
    }
}


open_project build_${ipname}.${device}

add_files $ipname.cpp -cflags "-std=c++14"

set_top $ipname

open_solution sol1

if {$do_syn} {
    set_part $device
    create_clock -period 4 -name default
    config_interface -m_axi_addr64=true
    csynth_design
}

if {$do_export} {
    config_export -format ip_catalog
    export_design
}

exit
open_project hls_project
open_solution "solution1"
set_part "xcu55c-fsvh2892-2L-e"

set freq_mhz 322
set period_ns [expr 1000.0 / $freq_mhz]
create_clock -period $period_ns -name default
set_clock_uncertainty "27%" default

add_files p2p_322mhz_hls.cpp

set_top onic_hls

csynth_design

export_design -format ip_catalog -ipname "hls_ip" -display_name "hls_ip" -description "" -vendor "user.org" -version "1.0"

close_project

exit
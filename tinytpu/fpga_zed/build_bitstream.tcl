# Builds Tiny-TPU Version 1 for the ZedBoard from nothing to an exported hardware file (Vivado 2019.1).
#
# From a Command Prompt (no GUI):
#   cd tinytpu\fpga_zed
#   C:\Xilinx\Vivado\2019.1\bin\vivado.bat -mode batch -source build_bitstream.tcl
# or in the Vivado GUI: Tools > Run Tcl Script... and pick this file.
#
# Steps: create_tinytpu_zed_project.tcl (project + block design), synthesis, implementation, bitstream,
# timing check, then the hardware export the SDK needs:
#   tinytpu_zed_project/tinytpu_zed.sdk/system_wrapper.hdf   (with the bitstream inside)
# The same file File > Export > Export Hardware (include bitstream) writes. Then run sdk_build.tcl.
# About 10 minutes. Ends with BUILD OK, or BUILD FAILED and the reason.

set here [file dirname [file normalize [info script]]]
source [file join $here create_tinytpu_zed_project.tcl]

if {[llength [get_files -quiet system.bd]] == 0} {
    puts "BUILD FAILED: the block design was not made (see the NOTE above)."
    return -code error "no block design"
}

reset_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} {
    puts "BUILD FAILED: implementation stopped ([get_property STATUS [get_runs impl_1]])."
    return -code error "impl failed"
}

open_run impl_1
set rpt [file join $here tinytpu_zed_project timing_summary.rpt]
report_timing_summary -file $rpt
set wns [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]]
set whs [get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -hold]]
report_utilization -file [file join $here tinytpu_zed_project utilization.rpt]

# Hardware export: the run writes system_wrapper.sysdef (the .hdf with the bitstream inside); the SDK reads it
# as system_wrapper.hdf in the project's .sdk folder, which is what Export Hardware does.
set impl [get_property DIRECTORY [get_runs impl_1]]
set sdk  [file join $here tinytpu_zed_project tinytpu_zed.sdk]
file mkdir $sdk
file copy -force [file join $impl system_wrapper.sysdef] [file join $sdk system_wrapper.hdf]

puts ""
puts "Bitstream: [file join $impl system_wrapper.bit]"
puts "Hardware:  [file join $sdk system_wrapper.hdf]"
puts "Timing:    WNS $wns ns, WHS $whs ns (report: $rpt)"
if {$wns < 0 || $whs < 0} {
    puts "BUILD FAILED: timing not met. Lower FCLK_MHZ in create_tinytpu_zed_project.tcl and run this again."
} else {
    puts "BUILD OK: next, sdk_build.tcl (or the SDK by hand, README.md)."
}

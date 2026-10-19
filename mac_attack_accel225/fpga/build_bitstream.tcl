# Build the bitstream for the Arty A7. Run from the project folder:
#
#   vivado -mode batch -source fpga/build_bitstream.tcl -tclargs 16 xc7a100tcsg324-1
#   vivado -mode batch -source fpga/build_bitstream.tcl -tclargs 8  xc7a35ticsg324-1L
#
# Output: fpga/build/mac_attack_P<P>.bit, plus utilization and timing reports.
# The worst setup slack (WNS) printed at the end must be 0 or more.
set P 16
set part xc7a100tcsg324-1
if {$argc >= 1} { set P [lindex $argv 0] }
if {$argc >= 2} { set part [lindex $argv 1] }
set root [file normalize [file join [file dirname [info script]] ..]]
file mkdir $root/fpga/build

read_verilog -sv [concat [glob $root/rtl/*.sv] [list $root/fpga/arty_top.sv]]
read_xdc $root/fpga/arty_a7.xdc
synth_design -top arty_top -part $part -generic P=$P
opt_design
place_design
route_design
report_utilization    -file $root/fpga/build/util_P${P}.txt
report_timing_summary -file $root/fpga/build/timing_P${P}.txt
write_bitstream -force $root/fpga/build/mac_attack_P${P}.bit
puts "WNS (must be 0 or more): [get_property SLACK [get_timing_paths -max_paths 1 -setup]] ns"
puts "Bitstream: $root/fpga/build/mac_attack_P${P}.bit"

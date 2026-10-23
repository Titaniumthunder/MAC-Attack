# Synthesize the chip for one array size and report how much of the FPGA it uses.
# No board needed. Run from the project folder:
#
#   vivado -mode batch -source fpga/synth_check.tcl -tclargs 16 xc7a100tcsg324-1
#   vivado -mode batch -source fpga/synth_check.tcl -tclargs 8  xc7a35ticsg324-1L
#
# Results go to fpga/build/: utilization and timing reports for that size.
set P 16
set part xc7a100tcsg324-1
if {$argc >= 1} { set P [lindex $argv 0] }
if {$argc >= 2} { set part [lindex $argv 1] }
set root [file normalize [file join [file dirname [info script]] ..]]
file mkdir $root/fpga/build

read_verilog -sv [glob $root/rtl/*.sv]
synth_design -top chip_top -part $part -generic P=$P -mode out_of_context
create_clock -name clk -period 10.0 [get_ports clk]
report_utilization    -file $root/fpga/build/synth_util_P${P}.txt
report_timing_summary -file $root/fpga/build/synth_timing_P${P}.txt
report_utilization
puts "Estimated worst setup slack at 100 MHz: [get_property SLACK [get_timing_paths -max_paths 1 -setup]] ns"
puts "Reports written to $root/fpga/build/"

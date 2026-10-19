set root [file dirname [file normalize [info script]]]
create_project -in_memory -part xc7z020clg484-1
read_verilog -sv [glob $root/rtl_final/*.sv]
read_verilog $root/mac_axi.v
synth_design -top mac_axi -part xc7z020clg484-1 -generic P=8 -mode out_of_context
create_clock -name clk -period 5.0 [get_ports s_axi_aclk]
set_property HD.CLK_SRC BUFGCTRL_X0Y16 [get_ports s_axi_aclk]
set_input_delay 1.0 -clock clk [get_ports -filter {DIRECTION == IN && NAME != s_axi_aclk}]
set_output_delay 1.0 -clock clk [get_ports -filter {DIRECTION == OUT}]
opt_design
place_design
phys_opt_design -directive AggressiveExplore
route_design -directive Explore
report_timing_summary -file $root/final_timing.rpt
report_timing -max_paths 20 -file $root/final_paths.rpt
report_utilization -file $root/final_util.rpt
write_checkpoint -force $root/final.dcp
puts "CANDIDATE_WNS [get_property SLACK [get_timing_paths -setup -max_paths 1]]"




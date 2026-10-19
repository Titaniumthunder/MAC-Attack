open_checkpoint C:/mac_attack_accel/timing_work/final.dcp
create_clock -name clk -period 9.091 [get_ports s_axi_aclk]
report_timing_summary -file C:/mac_attack_accel/timing_work/final_110mhz_timing.rpt
puts "CHECK_110MHZ_SETUP [get_property SLACK [get_timing_paths -setup -max_paths 1]]"
puts "CHECK_110MHZ_HOLD [get_property SLACK [get_timing_paths -hold -max_paths 1]]"

set root [file dirname [file normalize [info script]]]
if {[file exists $root/zed_cascade/mac_zed_cascade.xpr]} {
    open_project $root/zed_cascade/mac_zed_cascade.xpr
} else {
    open_project -read_only C:/mac_attack_accel/zed/mac_zed_project/mac_zed.xpr
    save_project_as mac_zed_cascade $root/zed_cascade -exclude_run_results
}
foreach f [get_files -quiet *] {
    if {[file tail $f] in {mm_core.sv pe.sv systolic_array.sv mac_axi.v mac_axi_fast.v mac_axi_readpipe.v}} { remove_files $f }
}
add_files -norecurse [list $root/rtl_cascade/mm_core.sv $root/rtl_cascade/pe.sv $root/rtl_cascade/systolic_array.sv $root/mac_axi_readpipe.v]
update_compile_order -fileset sources_1
set bd [get_files */system.bd]
if {![string match "$root/zed_cascade/*" [file normalize $bd]]} { error "BD is not isolated: $bd" }
open_bd_design $bd
update_module_reference [get_ips system_mac_0]
set_property CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ 250 [get_bd_cells ps7]
validate_bd_design
save_bd_design
reset_target all $bd
generate_target all $bd
set_property strategy Performance_Explore [get_runs impl_1]
set_property STEPS.PLACE_DESIGN.ARGS.DIRECTIVE Default [get_runs impl_1]
reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1
if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} { error "Synthesis failed" }
launch_runs impl_1 -to_step route_design -jobs 4
wait_on_run impl_1
if {[get_property PROGRESS [get_runs impl_1]] ne "100%"} { error "Implementation failed" }
open_run impl_1
report_timing_summary -file $root/system_cascade_timing.rpt
report_timing -max_paths 30 -file $root/system_cascade_paths.rpt
report_utilization -file $root/system_cascade_util.rpt
puts "SYSTEM_WNS [get_property SLACK [get_timing_paths -setup -max_paths 1]]"











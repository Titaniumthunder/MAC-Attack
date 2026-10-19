set root [file dirname [file normalize [info script]]]
open_project $root/zed_bounds/mac_zed_bounds.xpr
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.IS_ENABLED true [get_runs impl_1]
set_property STEPS.POST_ROUTE_PHYS_OPT_DESIGN.ARGS.DIRECTIVE AggressiveExplore [get_runs impl_1]
launch_runs impl_1 -to_step {phys_opt_design (Post-Route)} -jobs 4
wait_on_run impl_1
open_run impl_1
report_timing_summary -file $root/system_bounds_postopt_timing.rpt
report_timing -max_paths 30 -file $root/system_bounds_postopt_paths.rpt
report_utilization -file $root/system_bounds_postopt_util.rpt
puts "POSTOPT_WNS [get_property SLACK [get_timing_paths -setup -max_paths 1]]"



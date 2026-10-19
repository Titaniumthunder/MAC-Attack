# Reproduce the verified full-system 250 MHz run, including post-route optimization.
set root [file dirname [file normalize [info script]]]
source $root/build_fullctrl.tcl
close_project
source $root/postopt_fullctrl.tcl
set setup_slack [get_property SLACK [get_timing_paths -setup -max_paths 1]]
set hold_slack [get_property SLACK [get_timing_paths -hold -max_paths 1]]
if {$setup_slack < 0 || $hold_slack < 0} { error "Timing failed: setup=$setup_slack hold=$hold_slack" }

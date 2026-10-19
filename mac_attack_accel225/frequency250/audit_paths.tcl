open_checkpoint C:/mac_attack_accel/frequency250/zed_dsp/mac_zed_dsp.runs/impl_1/system_wrapper_routed.dcp
set f [open C:/mac_attack_accel/frequency250/dsp_failing_paths.tsv w]
foreach p [get_timing_paths -setup -slack_lesser_than 0 -max_paths 400] {
    puts $f "[get_property SLACK $p]\t[get_property STARTPOINT_PIN $p]\t[get_property ENDPOINT_PIN $p]"
}
close $f

open_project C:/mac_attack_accel/frequency250/zed_resetguard/mac_zed_resetguard.xpr
foreach p [list_property [get_runs impl_1]] {if {[string match *POST_ROUTE* $p]} {puts "$p = [get_property $p [get_runs impl_1]]"}}

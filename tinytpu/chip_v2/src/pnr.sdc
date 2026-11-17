# Place-and-route constraints for Version 2: LibreLane's default, but repair aims below the signoff
# limits, so the small difference between the routing estimate and the final extracted wires cannot push
# a net over them. Signoff (signoff.sdc) still checks the unchanged limits: 0.75 ns and fanout 10.
source $::env(SCRIPTS_DIR)/base.sdc
set_max_transition 0.6 [current_design]
set_max_fanout 8 [current_design]

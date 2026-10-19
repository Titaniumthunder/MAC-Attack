open_checkpoint C:/mac_attack_accel/frequency250/zed_cascade/mac_zed_cascade.runs/system_mac_0_synth_1/system_mac_0.dcp
set links [get_nets -of_objects [get_pins -hierarchical -filter {REF_PIN_NAME =~ PCIN*}]]
set drivers [get_pins -of_objects $links -filter {DIRECTION == OUT && REF_PIN_NAME =~ PCOUT*}]
puts "CASCADE_SOURCE_DSPS [llength [get_cells -of_objects $drivers]]"
puts "CASCADE_BITS [llength $drivers]"
puts "TOTAL_DSPS [llength [get_cells -hierarchical -filter {REF_NAME == DSP48E1}]]"

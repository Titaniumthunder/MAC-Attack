# Creates the Vivado project for the MAC Attack accelerator, with every file added.
#
# In Vivado: Tools > Run Tcl Script..., and pick this file.
# Or type in the Tcl Console (use forward slashes):
#     source C:/mac_attack_accel/vivado/create_project.tcl
#
# The project is created in vivado/mac_attack_project, next to this script.
# Then click  SIMULATION > Run Simulation > Run Behavioral Simulation.

set here [file dirname [file normalize [info script]]]
set root [file normalize [file join $here ..]]

# Vivado's simulator runs a Windows batch file, and Windows cannot run one from a
# network path such as \\Mac\Home\... (a Mac shared folder seen from a Windows VM)
# or \\server\share\... . The simulation then fails with [USF-XSim-62]. Stop early.
if {[string match "//*" $here] || [string match {\\\\*} $here]} {
    puts ""
    puts "ERROR: this folder is on a network path:"
    puts "    $root"
    puts "Vivado's simulation cannot run from there. Copy the mac_attack_accel folder to a"
    puts "local drive, for example C:\\mac_attack_accel, then run"
    puts "C:\\mac_attack_accel\\vivado\\create_project.tcl again."
    return -code error "project folder is on a network path; copy it to C:\\ first"
}

# FPGA part: Arty A7-100T. For an Arty A7-35T use xc7a35ticsg324-1L
set part xc7a100tcsg324-1

create_project mac_attack [file join $here mac_attack_project] -part $part -force

# Design sources: the chip (rtl/) and the Arty board top
add_files -norecurse [glob [file join $root rtl *.sv]]
add_files -norecurse [file join $root fpga arty_top.sv]
set_property top arty_top [get_filesets sources_1]

# Pin constraints for the Arty A7
add_files -fileset constrs_1 -norecurse [file join $root fpga arty_a7.xdc]

# Simulation sources: three self-checking testbenches (no Python or input files needed)
add_files -fileset sim_1 -norecurse [list \
    [file join $root tb tb_selfcheck.sv] \
    [file join $root tb tb_compare.sv] \
    [file join $root tb tb_extras.sv]]
# A saved waveform layout (for example vivado/tb_selfcheck.wcfg) opens automatically
foreach wcfg [glob -nocomplain [file join $here *.wcfg]] {
    add_files -fileset sim_1 -norecurse $wcfg
    puts "Added waveform layout [file tail $wcfg]"
}
set_property top tb_selfcheck [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]

# Run until the testbench finishes, instead of stopping after 1 us
set_property -name {xsim.simulate.runtime} -value {all} -objects [get_filesets sim_1]

# Record every signal, so anything added to the waveform later (for example one PE's
# a_in, w and psum_out) shows its whole history without re-running the simulation
if {[catch {set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]}]} {
    puts "Note: could not turn on log_all_signals. After adding a signal, type  restart  then  run all"
}

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts ""
puts "Project created. Click SIMULATION > Run Simulation > Run Behavioral Simulation."
puts "Results are printed in the Tcl Console. To run another testbench, right-click it under"
puts "Simulation Sources > sim_1 and choose Set as Top."

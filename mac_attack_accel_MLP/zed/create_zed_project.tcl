# Creates the ZedBoard project for the MAC Attack accelerator.
#
# In Vivado: Tools > Run Tcl Script..., pick this file (zed\create_zed_project.tcl).
#
# What it builds:
#   1. A project for the ZedBoard (xc7z020clg484-1) with the RTL, the AXI wrapper and its testbench.
#      Run Behavioral Simulation right away: tb_axi plays the ARM and must end with ALL AXI TESTS PASSED.
#   2. A block design "system": Zynq processing system (ARM, DDR, UART) -> AXI interconnect -> mac_axi,
#      with a 200 MHz PL clock. If a block-design step fails in your Vivado version, the project is still
#      made and the README has the same steps for the GUI.
# Then: Generate Bitstream, File > Export > Export Hardware (include bitstream), and Vitis (README).

set here [file dirname [file normalize [info script]]]
set root [file normalize [file join $here ..]]

# Vivado's simulator cannot run from a network path such as \\Mac\Home\...
if {[string match "//*" $here] || [string match {\\\\*} $here]} {
    puts "ERROR: this folder is on a network path: $root"
    puts "Copy the mac_attack_accel folder to a local drive such as C:\\mac_attack_accel and run this again."
    return -code error "project folder is on a network path"
}

set P 8          ;# array size for the board; 8x8 first, 16x16 once timing is clean
set FCLK_MHZ 200 ;# PL clock from the Zynq (1000 MHz IO PLL / 5); set FCLK_HZ in mac_test.c to the same value
set PIPE 2       ;# PE pipeline: 2 = input, multiply, add in the DSP (step 11); 1 = multiply, then add in LUTs
set CORE_MHZ 0   ;# 0 = one clock for everything. > 0 (e.g. 250): the core gets its own clock of this
                 ;# frequency from a Clocking Wizard fed by FCLK_CLK0 (step 12); set CORE_HZ in mac_test.c

create_project mac_zed [file join $here mac_zed_project] -part xc7z020clg484-1 -force

# Use the ZedBoard board files if Vivado has them, so the Zynq gets the board's DDR and UART settings
set bp [lindex [lsort [get_board_parts -quiet *:zed*:*]] end]
if {$bp ne ""} {
    set_property board_part $bp [current_project]
    puts "Board: $bp"
} else {
    puts "WARNING: no ZedBoard board files found. Install them (Tools > Vivado Store > Boards, search ZedBoard),"
    puts "         then run this script again. The block design needs them for the DDR settings."
}

# Sources: the core (SystemVerilog) and the AXI wrapper (plain Verilog, for the block design)
add_files -norecurse [glob [file join $root rtl *.sv]]
add_files -norecurse [file join $here mac_axi.v]
add_files -norecurse [file join $here pe_dsp48.sv]   ;# each PE as one DSP48E1 (mac_axi PE_PRIM = 1)
set_property top mac_axi [get_filesets sources_1]
# Two clocks: tell timing analysis the core clock and the AXI clock are unrelated (see the file)
if {$CORE_MHZ > 0} {
    add_files -fileset constrs_1 -norecurse [file join $here mac_zed_cdc.xdc]
}

# Simulation: tb_axi plays the ARM over AXI
add_files -fileset sim_1 -norecurse [file join $here tb_axi.sv]
set_property top tb_axi [get_filesets sim_1]
set_property top_lib xil_defaultlib [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {all} -objects [get_filesets sim_1]
catch {set_property -name {xsim.simulate.log_all_signals} -value {true} -objects [get_filesets sim_1]}
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

# Newest installed version of a Xilinx IP, so the script does not depend on one Vivado release
proc ipv {name} { return [lindex [lsort [get_ipdefs -all "xilinx.com:ip:${name}:*"]] end] }

proc build_block_design {P FCLK_MHZ PIPE CORE_MHZ} {
    create_bd_design system

    # Zynq processing system: ARM cores, DDR, USB-UART; board preset from the ZedBoard files
    set ps [create_bd_cell -type ip -vlnv [ipv processing_system7] ps7]
    apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
        -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable"} $ps
    set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ $FCLK_MHZ CONFIG.PCW_USE_M_AXI_GP0 {1}] $ps

    # Our accelerator, straight from the RTL
    set mac [create_bd_cell -type module -reference mac_axi mac]
    set_property -dict [list CONFIG.P $P CONFIG.PIPE $PIPE] $mac

    # Interconnect and reset block, wired by hand so it works the same in every version
    set ic  [create_bd_cell -type ip -vlnv [ipv axi_interconnect] axi_ic]
    set_property CONFIG.NUM_MI {1} $ic
    set rst [create_bd_cell -type ip -vlnv [ipv proc_sys_reset] rst_fclk0]
    # Register slice between the interconnect and mac (step 15b, 22 Oct, timing at 250 MHz): every
    # AXI-Lite channel fully registered, so no path runs from mac_axi's handshake registers into the
    # interconnect's protocol converter. About 2 clocks more per bus access; results unchanged.
    set rs  [create_bd_cell -type ip -vlnv [ipv axi_register_slice] mac_rs]
    set_property -dict [list CONFIG.PROTOCOL {AXI4LITE} CONFIG.REG_AW {1} CONFIG.REG_AR {1} \
        CONFIG.REG_W {1} CONFIG.REG_R {1} CONFIG.REG_B {1}] $rs

    connect_bd_intf_net [get_bd_intf_pins ps7/M_AXI_GP0] [get_bd_intf_pins axi_ic/S00_AXI]
    connect_bd_intf_net [get_bd_intf_pins axi_ic/M00_AXI] [get_bd_intf_pins mac_rs/S_AXI]
    connect_bd_intf_net [get_bd_intf_pins mac_rs/M_AXI] [get_bd_intf_pins -of_objects $mac -filter {MODE == Slave}]

    set clk [get_bd_pins ps7/FCLK_CLK0]
    foreach p {ps7/M_AXI_GP0_ACLK axi_ic/ACLK axi_ic/S00_ACLK axi_ic/M00_ACLK mac_rs/aclk mac/s_axi_aclk rst_fclk0/slowest_sync_clk} {
        connect_bd_net $clk [get_bd_pins $p]
    }
    connect_bd_net [get_bd_pins ps7/FCLK_RESET0_N] [get_bd_pins rst_fclk0/ext_reset_in]

    # The core's clock (step 12)
    if {$CORE_MHZ > 0} {
        # Clocking Wizard (MMCM) fed by FCLK_CLK0. FCLK already has a global buffer, so no input
        # buffer here. Held in reset while the Zynq holds the PL in reset (FCLK_RESET0_N), because
        # ps7_init can change FCLK after the bitstream is loaded and the MMCM must lock again.
        set cw [create_bd_cell -type ip -vlnv [ipv clk_wiz] clk_core]
        set_property -dict [list CONFIG.PRIM_SOURCE {No_buffer} CONFIG.PRIM_IN_FREQ $FCLK_MHZ \
            CONFIG.CLKOUT1_REQUESTED_OUT_FREQ $CORE_MHZ CONFIG.RESET_TYPE {ACTIVE_LOW} CONFIG.USE_LOCKED {true}] $cw
        connect_bd_net $clk [get_bd_pins clk_core/clk_in1]
        connect_bd_net [get_bd_pins ps7/FCLK_RESET0_N] [get_bd_pins clk_core/resetn]
        connect_bd_net [get_bd_pins clk_core/clk_out1] [get_bd_pins mac/core_clk]
        connect_bd_net [get_bd_pins clk_core/locked] [get_bd_pins mac/core_locked]
        set_property CONFIG.CORE_CLK 1 $mac
    } else {
        # One clock: core_clk is not used; tie it to FCLK_CLK0 and core_locked to 1
        connect_bd_net $clk [get_bd_pins mac/core_clk]
        set one [create_bd_cell -type ip -vlnv [ipv xlconstant] one]
        connect_bd_net [get_bd_pins one/dout] [get_bd_pins mac/core_locked]
        set_property CONFIG.CORE_CLK 0 $mac
    }
    connect_bd_net [get_bd_pins rst_fclk0/interconnect_aresetn] [get_bd_pins axi_ic/ARESETN]
    foreach p {axi_ic/S00_ARESETN axi_ic/M00_ARESETN mac_rs/aresetn mac/s_axi_aresetn} {
        connect_bd_net [get_bd_pins rst_fclk0/peripheral_aresetn] [get_bd_pins $p]
    }

    assign_bd_address
    validate_bd_design
    save_bd_design

    # HDL wrapper becomes the top for synthesis
    make_wrapper -files [get_files system.bd] -top -import
    set_property top system_wrapper [get_filesets sources_1]
    update_compile_order -fileset sources_1
}

if {[catch {build_block_design $P $FCLK_MHZ $PIPE $CORE_MHZ} err]} {
    puts ""
    puts "NOTE: the block design step stopped: $err"
    puts "The project and simulation are ready. Build the block design in the GUI (zed\\README.md, steps 3 to 9)."
} else {
    puts ""
    puts "Block design 'system' built: Zynq -> AXI interconnect -> register slice -> mac_axi (P = $P, PIPE = $PIPE), PL clock $FCLK_MHZ MHz."
    if {$CORE_MHZ > 0} {
        puts "Core clock: Clocking Wizard clk_core, $CORE_MHZ MHz requested (check its actual frequency in the block)."
    }
    foreach seg [get_bd_addr_segs -quiet -of_objects [get_bd_addr_spaces ps7/Data]] {
        puts "  [get_property NAME $seg]: offset [get_property OFFSET $seg], range [get_property RANGE $seg]"
    }
    puts "Check that the mac offset is 0x43C00000 (MAC_BASE in mac_test.c); if not, change MAC_BASE."
}
puts ""
puts "Next: Run Behavioral Simulation (tb_axi), then Generate Bitstream and export the hardware (README)."

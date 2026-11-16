# Creates the ZedBoard project for the Tiny-TPU processing element (Vivado 2019.1).
#
# In Vivado: Tools > Run Tcl Script..., pick this file (tinytpu\fpga_zed\create_tinytpu_zed_project.tcl).
#
# What it builds:
#   1. A project for the ZedBoard (xc7z020clg484-1) with tiny_tpu_axi.v and the chip's own PE file,
#      ..\chip\src\tiny_tpu_pe.v (the same RTL as the Tiny Tapeout chip; only the wrapper differs).
#   2. A block design "system": Zynq processing system (ARM, DDR, UART) -> AXI interconnect -> tiny_tpu_axi,
#      with a 100 MHz PL clock. If a block-design step fails in your Vivado version, the project is still made;
#      README.md has the same steps for the GUI.
# Then: Generate Bitstream, File > Export > Export Hardware (include bitstream), and the SDK (README.md).
# Same structure as mac_attack_accel_MLP\zed\create_zed_project.tcl, which builds on this Vivado.

set here [file dirname [file normalize [info script]]]
set chip [file normalize [file join $here .. chip src]]

if {[string match "//*" $here] || [string match {\\\\*} $here]} {
    puts "ERROR: this folder is on a network path: $here"
    puts "Copy the repo to a local drive such as C:\\School\\MAC_Attack and run this again."
    return -code error "project folder is on a network path"
}

set FCLK_MHZ 100   ;# PL clock from the Zynq; the PE is one small adder, so any clock up to 200+ MHz works

create_project tinytpu_zed [file join $here tinytpu_zed_project] -part xc7z020clg484-1 -force

set bp [lindex [lsort [get_board_parts -quiet *:zed*:*]] end]
if {$bp ne ""} {
    set_property board_part $bp [current_project]
    puts "Board: $bp"
} else {
    puts "WARNING: no ZedBoard board files found. Install them (Tools > Vivado Store > Boards, search ZedBoard),"
    puts "         then run this script again. The block design needs them for the DDR settings."
}

# Sources: the PE exactly as the chip uses it, plus the AXI wrapper (plain Verilog, so the block design
# can use it as a module reference)
add_files -norecurse [file join $chip tiny_tpu_pe.v]
add_files -norecurse [file join $here tiny_tpu_axi.v]
set_property top tiny_tpu_axi [get_filesets sources_1]
update_compile_order -fileset sources_1

proc ipv {name} { return [lindex [lsort [get_ipdefs -all "xilinx.com:ip:${name}:*"]] end] }

proc build_block_design {FCLK_MHZ} {
    create_bd_design system

    set ps [create_bd_cell -type ip -vlnv [ipv processing_system7] ps7]
    apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 \
        -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable"} $ps
    set_property -dict [list CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ $FCLK_MHZ CONFIG.PCW_USE_M_AXI_GP0 {1}] $ps

    # The PE, straight from the RTL
    set tpu [create_bd_cell -type module -reference tiny_tpu_axi tpu]

    set ic  [create_bd_cell -type ip -vlnv [ipv axi_interconnect] axi_ic]
    set_property CONFIG.NUM_MI {1} $ic
    set rst [create_bd_cell -type ip -vlnv [ipv proc_sys_reset] rst_fclk0]

    connect_bd_intf_net [get_bd_intf_pins ps7/M_AXI_GP0] [get_bd_intf_pins axi_ic/S00_AXI]
    connect_bd_intf_net [get_bd_intf_pins axi_ic/M00_AXI] [get_bd_intf_pins -of_objects $tpu -filter {MODE == Slave}]

    set clk [get_bd_pins ps7/FCLK_CLK0]
    foreach p {ps7/M_AXI_GP0_ACLK axi_ic/ACLK axi_ic/S00_ACLK axi_ic/M00_ACLK tpu/s_axi_aclk rst_fclk0/slowest_sync_clk} {
        connect_bd_net $clk [get_bd_pins $p]
    }
    connect_bd_net [get_bd_pins ps7/FCLK_RESET0_N] [get_bd_pins rst_fclk0/ext_reset_in]
    connect_bd_net [get_bd_pins rst_fclk0/interconnect_aresetn] [get_bd_pins axi_ic/ARESETN]
    foreach p {axi_ic/S00_ARESETN axi_ic/M00_ARESETN tpu/s_axi_aresetn} {
        connect_bd_net [get_bd_pins rst_fclk0/peripheral_aresetn] [get_bd_pins $p]
    }

    assign_bd_address
    validate_bd_design
    save_bd_design

    make_wrapper -files [get_files system.bd] -top -import
    set_property top system_wrapper [get_filesets sources_1]
    update_compile_order -fileset sources_1
}

if {[catch {build_block_design $FCLK_MHZ} err]} {
    puts ""
    puts "NOTE: the block design step stopped: $err"
    puts "The project is ready. Build the block design in the GUI (README.md, 'Block design by hand')."
} else {
    puts ""
    puts "Block design 'system' built: Zynq -> AXI interconnect -> tiny_tpu_axi, PL clock $FCLK_MHZ MHz."
    foreach seg [get_bd_addr_segs -quiet -of_objects [get_bd_addr_spaces ps7/Data]] {
        puts "  [get_property NAME $seg]: offset [get_property OFFSET $seg], range [get_property RANGE $seg]"
    }
    puts "Check that the tpu offset is 0x43C00000 (TPU_BASE in sw/tinytpu_test.c); if not, change TPU_BASE."
}
puts ""
puts "Next: Generate Bitstream, export the hardware with the bitstream, then the SDK app (README.md)."

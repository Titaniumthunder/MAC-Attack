set root [file dirname [file normalize [info script]]]
foreach variant {baseline final} {
    create_project -in_memory -part xc7z020clg484-1
    foreach f [glob $root/rtl/*.sv] {
        if {[file tail $f] eq "mm_core.sv" && $variant eq "baseline"} {
            read_verilog -sv $root/mm_core_original.sv
        } else { read_verilog -sv $f }
    }
    read_verilog $root/zed/mac_axi.v
    synth_design -top mac_axi -part xc7z020clg484-1 -generic P=8 -mode out_of_context
    create_clock -name clk -period 8.0 [get_ports s_axi_aclk]
    set_input_delay 2.0 -clock clk [get_ports -filter {DIRECTION == IN && NAME != s_axi_aclk}]
    set_output_delay 2.0 -clock clk [get_ports -filter {DIRECTION == OUT}]
    opt_design
    place_design
    phys_opt_design
    route_design
    report_timing_summary -file $root/${variant}_timing.rpt
    report_timing -max_paths 10 -file $root/${variant}_paths.rpt
    report_utilization -file $root/${variant}_util.rpt
    write_checkpoint -force $root/${variant}.dcp
    puts "TIMING_RESULT $variant [get_property SLACK [get_timing_paths -setup -max_paths 1]]"
    close_project
}




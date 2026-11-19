# Programs the ZedBoard and starts one Tiny-TPU Version 1 test program over JTAG (SDK 2019.1, no GUI).
# Run after build_bitstream.tcl and sdk_build.tcl.
#
#   1. Board: power on, micro-USB to J17 (PROG / JTAG) and to J14 (UART), boot jumpers on JTAG.
#   2. Open a serial terminal on the UART's COM port: 115200 baud, 8N1 (PuTTY, Tera Term, ...).
#   3. From a Command Prompt:
#        cd tinytpu\fpga_zed
#        C:\Xilinx\SDK\2019.1\bin\xsct.bat run_on_board.tcl tinytpu_model_test
#   4. The terminal shows the test and its last line:
#        tinytpu_model_test   ALL TINY-TPU MODEL TESTS PASSED (2/2)
#        tinytpu_test         ALL TINY-TPU TESTS PASSED (5/5)
#        modelv2_int4_test    ALL MODELV2 INT4 TESTS PASSED (4/4)
#        modelv3_int4_test    ALL MODELV3 INT4 TESTS PASSED (4/4)
#   Run it again with another program name for the next test (it resets the board and reloads everything).
#
# The same steps the SDK's Run As > Launch on Hardware does with "Reset entire system", "Program FPGA",
# "Run ps7_init" and "Run ps7_post_config" ticked.

set apps {tinytpu_model_test tinytpu_test modelv2_int4_test modelv3_int4_test}
set app [lindex $argv 0]
if {$app eq ""} { set app tinytpu_model_test }
if {[lsearch -exact $apps $app] < 0} {
    puts "Unknown program '$app'. One of: $apps"
    exit 1
}

set here [file dirname [file normalize [info script]]]
set sdk  [file join $here tinytpu_zed_project tinytpu_zed.sdk]
set hdf  [file join $sdk system_wrapper.hdf]
set bit  [file join $sdk system_wrapper.bit]
set init [file join $sdk ps7_init.tcl]
set elf  [file join $here tinytpu_zed_project sw_build $app $app.elf]
foreach f [list $hdf $bit $init $elf] {
    if {![file exists $f]} { puts "RUN FAILED: missing $f. Run build_bitstream.tcl and sdk_build.tcl first."; exit 1 }
}
# the JTAG tools are safer without spaces in paths: Windows' short (8.3) form of the same files
if {$tcl_platform(platform) eq "windows"} {
    foreach v {hdf bit init elf} { set $v [file attributes [set $v] -shortname] }
}

puts "Programming the ZedBoard and starting $app ..."
connect
targets -set -nocase -filter {name =~ "APU*"}
rst -system
after 3000
targets -set -nocase -filter {name =~ "xc7z020*"}
fpga -file $bit
targets -set -nocase -filter {name =~ "APU*"}
loadhw -hw $hdf -mem-ranges [list {0x40000000 0xbfffffff}]
configparams force-mem-access 1
targets -set -nocase -filter {name =~ "*A9*#0"}
source $init
ps7_init
ps7_post_config
dow $elf
configparams force-mem-access 0
con
puts "$app started: watch the UART terminal (115200 8N1)."

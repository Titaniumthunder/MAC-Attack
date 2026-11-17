# Builds the ARM test programs for Tiny-TPU Version 1 (SDK 2019.1 tools, no GUI). Run after build_bitstream.tcl.
#
# From a Command Prompt:
#   cd tinytpu\fpga_zed
#   C:\Xilinx\SDK\2019.1\bin\xsct.bat sdk_build.tcl
#
# Two programs, Release (-O2), linked with libm, each in tinytpu_zed_project/sw_build/<app>/<app>.elf:
#   tinytpu_model_test   the professor's Tiny-TPU RSCL model, host mode (the same rows and checks as
#                        MAC_model_TinyTPU and the Version 2 program)
#   tinytpu_test         the PE's own hardware test (golden command stream, host flow, products, overflow, timing)
# (modelV2 cannot run on Version 1: it is INT8, the PE takes INT4.) Then: xsct run_on_board.tcl <app>.
#
# No Eclipse: the BSP comes from hsi::generate_app and each program is built with the SDK's make and ARM gcc.
# (SDK 2019.1's Eclipse-based commands, createhw / createapp, fail when the folder path has a space in it, as
# C:\Users\James Manikyan\... does.) The SDK GUI is still an option; README.md has those steps.

set here [file dirname [file normalize [info script]]]
set hdf  [file join $here tinytpu_zed_project tinytpu_zed.sdk system_wrapper.hdf]
if {![file exists $hdf]} {
    puts "SDK BUILD FAILED: $hdf not found. Run build_bitstream.tcl first."
    exit 1
}
set out [file join $here tinytpu_zed_project sw_build]
file delete -force $out
file mkdir $out
# make and gcc cannot handle spaces in paths: work in Windows' short (8.3) form of the same folders
if {$tcl_platform(platform) eq "windows"} {
    set out [file attributes $out -shortname]
    set hdf [file attributes $hdf -shortname]
}
# The SDK install folder: XILINX_SDK (set by xsct.bat), else up from xsct.exe until gnu/ is found
if {[info exists ::env(XILINX_SDK)] && [file isdirectory [file join $::env(XILINX_SDK) gnu]]} {
    set sdk $::env(XILINX_SDK)
} else {
    set sdk [file dirname [info nameofexecutable]]
    while {![file isdirectory [file join $sdk gnu]] && [file dirname $sdk] ne $sdk} { set sdk [file dirname $sdk] }
}
foreach d [list [file join $sdk gnu aarch32 nt gcc-arm-none-eabi bin] [file join $sdk gnuwin bin]] {
    if {![file isdirectory $d]} { puts "SDK BUILD FAILED: $d not found (SDK 2019.1 install?)"; exit 1 }
    set ::env(PATH) "[file nativename $d];$::env(PATH)"
}

# app -> the sources it needs from sw/
set apps {
    tinytpu_model_test {tinytpu_model_test.c tinytpu_model.h}
    tinytpu_test       {tinytpu_test.c model_data.h}
}

# The BSP (standalone, ps7_cortexa9_0) and an empty application, once
hsi::open_hw_design $hdf
set base [file join $out base]
hsi::generate_app -hw [hsi::current_hw_design] -os standalone -proc ps7_cortexa9_0 -app empty_application \
                  -sw tinytpu_bsp -dir $base
# Release flags, and libm (the hardware test uses rint() and fabs())
set mk [file join $base Makefile]
set f [open $mk r]; set text [read $f]; close $f
set text [string map {"CFLAGS := " "CFLAGS := -O2 -Wall " "-lxil,-lgcc,-lc," "-lxil,-lgcc,-lc,-lm,"} $text]
set f [open $mk w]; puts -nonewline $f $text; close $f
puts "Building the BSP ..."
if {[catch {exec make -C $base empty_application_bsp/ps7_cortexa9_0/lib/libxil.a 2>@1} msg]} {
    puts $msg
    puts "SDK BUILD FAILED: the BSP did not build."
    exit 1
}

set missing 0
dict for {app files} $apps {
    set d [file join $out $app]
    file mkdir $d
    foreach f {Makefile lscript.ld Xilinx.spec empty_application_bsp} { file copy -force [file join $base $f] $d }
    foreach f $files { file copy -force [file join $here sw $f] $d }
    puts "Building $app ..."
    if {[catch {exec make -C $d 2>@1} msg]} { puts $msg }
    set elf [file join $d executable.elf]
    if {[file exists $elf]} {
        file rename -force $elf [file join $d $app.elf]
        puts "  built: [file join $d $app.elf]"
    } else {
        puts "  MISSING: $app (see the compiler output above)"
        incr missing
    }
}
if {$missing} {
    puts "SDK BUILD FAILED: $missing program(s) did not build."
    exit 1
}
puts "SDK BUILD OK: next, xsct run_on_board.tcl <app>, e.g. xsct run_on_board.tcl tinytpu_model_test"

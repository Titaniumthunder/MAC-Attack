#!/bin/sh
# Builds and runs the co-simulation: the ARM test program (sw/tinytpu_v2_test.c) against the RTL.
# Needs Verilator (5.x) and a C/C++ compiler. Usage, from anywhere:  sh run_cosim.sh [max random wait]
# It must end with "ALL TINY-TPU V2 TESTS PASSED (7/7)" and "program returned 0".
set -e
here=$(cd "$(dirname "$0")" && pwd)
sw="$here/../../sw"
rtl="$here/../.."
core="$here/../../../chip_v2/src"
build="$here/build"
mkdir -p "$build"

# The test program exactly as the SDK builds it, except: simulation headers, main() renamed, and
# 2 timing rounds instead of 20 (to keep the run short)
cc -std=c99 -O2 -Wall -Wextra -I"$here/host_include" -I"$sw" -Dmain=tinytpu_v2_main -DROUNDS=2 \
   -c "$sw/tinytpu_v2_test.c" -o "$build/tinytpu_v2_test.o"

verilator --cc --exe --build -j 4 -O2 -Wno-fatal --Mdir "$build/obj" --top-module tiny_tpu_v2_axi \
   "$rtl/tiny_tpu_v2_axi.v" "$core/tiny_tpu_v2_core.v" "$here/cosim.cpp" \
   -CFLAGS "-O2 -I$here/host_include" -LDFLAGS "$build/tinytpu_v2_test.o -lm" -o cosim > "$build/verilator.log"

"$build/obj/cosim" "$@"

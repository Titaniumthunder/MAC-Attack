#!/bin/bash
# usage: run_s14.sh <name> MODE HREG P PE_PRIM SEED NSCEN FAST
N=$1; MODE=$2; HREG=$3; P=$4; PRIM=$5; SEED=$6; NS=$7; FAST=$8
X=/home/claude/mac_work/xil; D=/home/claude/mac_work/s14
EXTRA=""; TOPS="-s tb_s14"
if [ "$PRIM" = "1" ]; then EXTRA="$X/DSP48E1.v $X/glbl.v"; TOPS="-s tb_s14 -s glbl"; fi
iverilog -g2012 -o out/$N.vvp $TOPS -P tb_s14.MODE=$MODE -P tb_s14.HREG=$HREG -P tb_s14.P=$P -P tb_s14.PE_PRIM=$PRIM \
  -P tb_s14.SEED=$SEED -P tb_s14.NSCEN=$NS -P tb_s14.FAST=$FAST \
  $D/tb_s14.sv $D/new/zed/mac_axi.v $D/new/rtl/mm_core.sv $D/old/mac_axi_old.v $D/old/mm_core_old.sv \
  $D/new/rtl/systolic_array.sv $D/new/rtl/pe.sv $D/new/rtl/delay_line.sv $D/new/zed/pe_dsp48.sv $EXTRA 2> out/$N.build.txt \
  || { echo "$N BUILD FAILED"; head -20 out/$N.build.txt; exit 1; }
vvp -n out/$N.vvp +LOGFILE=out/$N.log > out/$N.txt 2>&1
tail -2 out/$N.txt

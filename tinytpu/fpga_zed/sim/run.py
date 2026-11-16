# Runs test_axi.py on tiny_tpu_axi.v + the chip's tiny_tpu_pe.v with Icarus Verilog.
# Usage (from this folder):  pip install cocotb cocotbext-axi   then   python run.py
from pathlib import Path

from cocotb_tools.runner import get_runner

here = Path(__file__).resolve().parent
sources = [here.parent / "tiny_tpu_axi.v", here.parents[1] / "chip" / "src" / "tiny_tpu_pe.v"]

runner = get_runner("icarus")
runner.build(sources=sources, hdl_toplevel="tiny_tpu_axi", build_dir=here / "sim_build",
             timescale=("1ns", "1ps"), always=True)
runner.test(hdl_toplevel="tiny_tpu_axi", test_module="test_axi", test_dir=here)

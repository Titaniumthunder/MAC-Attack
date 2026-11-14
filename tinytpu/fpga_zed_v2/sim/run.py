# Runs test_axi_v2.py on tiny_tpu_v2_axi.v + the chip's tiny_tpu_v2_core.v with Icarus Verilog.
# Usage (from this folder):  pip install cocotb cocotbext-axi   then   python run.py
from pathlib import Path

from cocotb_tools.runner import get_runner

here = Path(__file__).resolve().parent
sources = [here.parent / "tiny_tpu_v2_axi.v", here.parents[1] / "chip_v2" / "src" / "tiny_tpu_v2_core.v"]

runner = get_runner("icarus")
runner.build(sources=sources, hdl_toplevel="tiny_tpu_v2_axi", build_dir=here / "sim_build",
             timescale=("1ns", "1ps"), always=True)
runner.test(hdl_toplevel="tiny_tpu_v2_axi", test_module="test_axi_v2", test_dir=here)

# Runs the RP2350 drivers against the RTL of both chips (cocotb + Icarus Verilog).
# Usage (from this folder):  pip install cocotb   then   python run.py
# Must end with both tests passing: driver_runs_professor_model (Version 1) and driver_runs_modelv2 (Version 2).
from pathlib import Path

from cocotb_tools.runner import get_runner

here = Path(__file__).resolve().parent
tinytpu = here.parents[1]

for name, srcs, test in (
    ("chip", ["project.v", "tiny_tpu_pe.v"], "test_v1_driver"),
    ("chip_v2", ["project.v", "tiny_tpu_v2_core.v"], "test_v2_driver"),
):
    sources = [tinytpu / name / "src" / s for s in srcs] + [tinytpu / name / "test" / "tb.v"]
    runner = get_runner("icarus")
    runner.build(sources=sources, hdl_toplevel="tb", build_dir=here / f"sim_build_{name}",
                 timescale=("1ns", "1ps"), always=True)
    runner.test(hdl_toplevel="tb", test_module=test, test_dir=here, build_dir=here / f"sim_build_{name}")

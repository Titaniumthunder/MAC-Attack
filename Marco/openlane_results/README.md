# MAC Attack — OpenLane 2 ASIC Results

**Date:** October 19, 2026  
**Contributor:** Marco Flores  
**Tool:** OpenLane 2 v2.3.10  
**Technology:** SKY130  
**Design:** 4×4 INT8 Systolic MAC Array

## Design Specifications

| Parameter | Value |
|---|---|
| Array size | 4×4 (16 processing elements) |
| Input precision | INT8 |
| Accumulator width | 32-bit |
| Maximum matrix dimensions | 8×8 |
| Clock target | 40 MHz (25 ns) |
| Interface | UART |

## Physical Design Results

| Metric | Result |
|---|---|
| OpenLane stages | 78/78 completed |
| Runtime | 9 minutes 45 seconds |
| Standard-cell count | 39,167 |
| Standard-cell area | 0.3308 mm² |
| Die area | 0.604244 mm² |
| Core area | 0.577386 mm² |
| Setup WNS (overall) | 0 ns |
| Setup TNS | 0 ns |
| DRC | Passed |
| LVS | Passed |
| Antenna | Failed — 21 pin violations across 20 nets |

## Summary

Successfully completed the OpenLane 2 physical design flow for the MAC Attack TPU using the SKY130 process.

The run generated final physical implementation files, including the GDSII layout, and produced area and timing metrics.

The design passed DRC and LVS checks. However, antenna violations and maximum slew/capacitance warnings remain, so the design is not yet ready for fabrication.

## Next Steps

1. Inspect the TPU layout using KLayout.
2. Investigate and fix antenna violations.
3. Review detailed timing reports and constraints.
4. Evaluate different TPU array sizes and clock targets.
5. Compare ASIC area and performance with FPGA results.

## Notes

This is a preliminary ASIC implementation of the 4×4 TPU configuration, not a physical implementation of the latest 250 MHz FPGA configuration.

The 40 MHz clock is the configured target, not a verified maximum operating frequency.

# Simulation Results

This directory contains **simulation artifacts** generated from RTL testbenches.
The results demonstrate **functional correctness, timing alignment, and boundary behavior**
of the Mid-Side transform design.

All data is generated from **cycle-accurate RTL simulation** and logged as CSV files.
Plots shown here are derived directly from those CSVs.

---

## Contents

| File                          | Description                                  |
| ----------------------------- | -------------------------------------------- |
| `tb_data_midside_core.csv`    | Output of `mid_side_core` testbench          |
| `tb_data_midside_inverse.csv` | Output of `mid_side_inverse` testbench       |
| `tb_data_midside_axis.csv`    | Output of full AXI wrapper testbench         |
| `*.png`                       | Plots generated from corresponding CSV files |

CSV files are considered the **primary verification artifact**.  
Plots are provided for visualization only.

---

## 1. Mid-Side Core (`mid_side_core`)

![Mid-Side Core Simulation](./tb_data_midside_core.png)

**What is verified:**

- Correct Mid/Side computation  
  - `mid  = (L + R) >>> 1`  
  - `side = (L - R) >>> 1`
- Proper bypass behavior when `enable = 0`
- Signed arithmetic correctness
- Fixed **1-cycle latency**

**Observations:**

- Output transitions occur exactly one clock cycle after input application.
- Odd-sum cases show expected truncation due to arithmetic shift.
- No overflow or wrap-around is observed in forward transform.

---

## 2. Mid-Side Inverse (`mid_side_inverse`)

![Mid-Side Inverse Simulation](./tb_data_midside_inverse.png)

**What is verified:**

- Correct reconstruction  
  - `L = mid + side`  
  - `R = mid - side`
- Explicit **saturation behavior**
- Proper bypass behavior
- Fixed **1-cycle latency**

**Critical cases validated:**

- Positive overflow → clipped to `+32767`
- Negative overflow → clipped to `-32768`
- Non-overflow cases pass through unchanged

**Observations:**

- Saturation occurs only in inverse path, by design.
- No wrap-around artifacts are present.
- Latency is deterministic and matches specification.

---

## 3. AXI Wrapper Integration (`midside_axis_wrapper`)

![AXI Wrapper Simulation](./tb_data_midside_axis.png)

**What is verified:**

- AXI-Stream data flow with backpressure support
- AXI-Lite register control
- Mode switching during runtime
- End-to-end timing alignment across pipeline

**Modes exercised:**

| Mode | Encode | Decode | Description |
| ---: | :----: | :----: | ----------- |
| 0    | 0      | 0      | Bypass      |
| 1    | 1      | 0      | Encoder     |
| 2    | 0      | 1      | Decoder     |

**Observations:**

- Fixed **2-cycle end-to-end latency** is preserved.
- Input samples are correctly aligned with outputs.
- AXI-Lite writes take effect immediately and deterministically.
- No data corruption under continuous streaming.

---

## Verification Philosophy

- **Deterministic**: No random stimulus  
- **Cycle-accurate**: Latency treated as a contract  
- **Tool-agnostic**: CSV-first, plots are secondary  
- **Reproducible**: Results can be regenerated from source RTL  

This approach prioritizes **engineering clarity** over exhaustive testing.

---

## Notes

- These simulations validate **functional correctness**, not performance limits.
- Hardware validation has been performed separately and is not included here.
- No bitstreams, overlays, or software artifacts are published.

---

## Status

> These results confirm that the design behaves as specified.  
> The verification scope is complete.

---

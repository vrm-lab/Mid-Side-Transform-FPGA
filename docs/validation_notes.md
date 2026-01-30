# Validation Notes

This document summarizes the verification approach used for this design.

---

## Simulation-Based Verification

Each arithmetic core is verified using:

- directed test vectors
- cycle-accurate checking
- CSV-based result logging

Key behaviors validated:
- bypass mode
- correct arithmetic
- saturation behavior
- signed corner cases

---

## AXI Integration Verification

The AXI wrapper is verified using:

- AXI-Lite register writes
- AXI-Stream stimulus
- multi-mode operation within a single run

Input samples are delayed explicitly in the testbench to match pipeline latency.

---

## Hardware Validation

The design has been validated on FPGA hardware.

Validation focus:
- correct AXI behavior
- stable audio processing
- absence of timing-related artifacts

No hardware-specific assumptions are baked into the RTL.

---

## Reproducibility

All verification artifacts are:
- deterministic
- tool-agnostic
- reproducible from source

CSV files are treated as primary verification output.

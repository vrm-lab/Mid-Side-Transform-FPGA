# Build Overview

This repository provides a reference RTL design.
It is intended to be read, simulated, and reviewed — not replayed as a turnkey project.

---

## Included

- Verilog RTL source files
- SystemVerilog testbenches
- Documentation describing design decisions

---

## Not Included

- Vivado project files
- Bitstreams or hardware handoff files
- Python scripts or PYNQ overlays
- Software drivers or applications

---

## Recommended Flow

1. Compile RTL and testbenches using your preferred simulator
2. Run simulations to generate CSV output
3. Inspect results using external plotting or analysis tools

The design is tool-agnostic and does not depend on GUI-based workflows.

---

## Hardware Validation

The RTL has been validated on real FPGA hardware using a PYNQ-based test setup.
PYNQ is used strictly as:

- stimulus generation
- observability interface

Hardware artifacts are intentionally not published.

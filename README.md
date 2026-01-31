# Mid-Side Transform (AXI-Stream) on FPGA

This repository provides a **reference RTL implementation** of a
**Mid-Side (M/S) audio transform**
implemented in **Verilog** and integrated with **AXI-Stream** and **AXI-Lite**.

Target platform: **AMD Kria KV260**  
Focus: **RTL architecture, fixed-point DSP decisions, and AXI correctness**

The module is designed for continuous real-time audio streaming, not block-based or offline processing.

---

## Overview

This module implements a **Mid-Side transform pair** for stereo audio processing.

**Function**
- Mid-Side encoding:  
  `mid = (L + R) / 2`, `side = (L - R) / 2`
- Mid-Side inverse reconstruction:  
  `L = mid + side`, `R = mid - side`

**Data type**
- Fixed-point signed integer (16-bit I/O, 24-bit internal)

**Scope**
- Minimal, single-purpose DSP building block

The design is intentionally **not generic** and **not feature-rich**.  
It exists to demonstrate how the problem is solved in hardware,
not to provide a turnkey audio solution.

---

## Key Characteristics

- RTL written in **Verilog**
- **AXI-Stream** data interface
- **AXI-Lite** control interface
- Fixed-point arithmetic with explicit bit-width control
- Deterministic, cycle-accurate behavior
- Designed and verified for real-time audio processing
- No software runtime included

---

## Architecture

High-level structure:
```
AXI-Stream In
|
v
+----------------------+
| Mid-Side DSP Core |
| (encode / decode) |
+----------------------+
|
v
AXI-Stream Out
```

**Design notes**
- Processing is fully synchronous
- No hidden state outside the RTL
- Arithmetic behavior is explicit and documented
- Control logic is isolated from DSP arithmetic

---

## Data Format

- **AXI-Stream width**: 32-bit
- **Fixed-point format**: signed integer (audio PCM style)

**Channel layout**
- `[31:16]` : Left / Mid channel
- `[15:0]`  : Right / Side channel

---

## Latency

- **Fixed processing latency**: **2 clock cycles** (wrapper level)

Latency is:
- deterministic
- independent of input signal characteristics

This behavior is intentional and suitable for streaming DSP pipelines.

---

## Verification & Validation

Verification was performed at two levels.

### 1. RTL Simulation

Dedicated testbenches verify:
- Functional correctness
- Fixed-point behavior
- Saturation / clipping behavior (inverse path)
- AXI-Stream handshake correctness
- Cycle-accurate latency

Simulation results are logged as **CSV files** and visualized via plots.
See the `results/` directory.

### 2. Hardware Validation

The design was tested on **real FPGA hardware**.

- Tested via **PYNQ overlay**
- PYNQ used only as:
  - signal stimulus
  - observability tool

PYNQ software, overlays, and bitstreams are **not** included in this repository.

---

## What This Repository Is

- A clean RTL reference
- A demonstration of:
  - DSP reasoning
  - fixed-point trade-offs
  - AXI integration
- A reusable **building block** for larger FPGA audio systems

---

## What This Repository Is Not

❌ A complete audio system  
❌ A framework or reusable DSP library  
❌ A parameter-heavy generic IP  
❌ A software-driven demo  

The scope is intentionally constrained.

---

## Design Rationale (Summary)

Key design decisions:
- Separation between DSP arithmetic and AXI protocol logic
- Fixed-point arithmetic chosen for determinism and hardware efficiency
- Saturation applied only in inverse path to prevent wrap-around artifacts
- Minimal control interface to avoid feature creep

These decisions reflect **engineering trade-offs**, not missing features.

---

## Project Status

**This repository is considered complete.**

- RTL is stable
- Hardware testing has been performed
- No further feature development is planned

The design is published as a **reference implementation**.

---

## Bare-Metal Driver (AXI-Lite Sanity Test)

This repository includes a **minimal bare-metal driver** for the AXI-Lite control
interface of the Mid-Side core.

The driver is provided **only for sanity checking**:

- AXI-Lite register accessibility
- Mode switching (bypass / encoder / decoder)
- Read-back correctness

The bare-metal code is **not required** to use the RTL
and is **not intended as a software API or runtime control layer**.

It was used during early hardware bring-up to verify:
deterministic register behavior and correct integration with the processing system.

No firmware, application framework, or runtime dependency
is implied by the presence of this code.

---

## License

Licensed under the **MIT License**.  
Provided *as-is*, without warranty.

> This repository demonstrates design decisions, not design possibilities.

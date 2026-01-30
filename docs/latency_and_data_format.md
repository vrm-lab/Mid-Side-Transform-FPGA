# Latency and Data Format

This document defines the timing and data contracts of the design.

---

## Data Format

- Stereo samples packed into 32-bit AXI-Stream words
- Format:
  - [31:16] : Left channel (signed)
  - [15:0]  : Right channel (signed)

All arithmetic uses two's complement signed representation.

---

## Core Latency

| Module              | Latency |
|---------------------|---------|
| mid_side_core       | 1 cycle |
| mid_side_inverse    | 1 cycle |

---

## Wrapper Latency

Total fixed latency through the AXI wrapper:

**2 clock cycles**

This latency is:
- fixed
- deterministic
- independent of data values

---

## Handshake Behavior

- Fully AXI-Stream compliant
- Backpressure supported
- No internal buffering beyond pipeline registers

Latency does not change under stall conditions.

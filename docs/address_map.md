# AXI-Lite Address Map

This document describes the AXI4-Lite register map for the Mid-Side AXI wrapper.

The control interface is intentionally minimal and deterministic.
Only essential control bits are exposed.

---

## Register Summary

| Offset | Name      | Description                  |
|------:|-----------|------------------------------|
| 0x00  | CONTROL   | Core enable configuration    |
| 0x04  | RESERVED  | Reserved for future use      |

---

## CONTROL Register (0x00)

| Bit | Name            | Description                                  |
|----:|-----------------|----------------------------------------------|
| 0   | ENCODE_ENABLE   | Enable Mid-Side encoding (L/R → M/S)         |
| 1   | DECODE_ENABLE   | Enable Mid-Side decoding (M/S → L/R)         |
| 31:2| —               | Reserved (must be written as zero)           |

---

## Operating Modes

| ENCODE | DECODE | Mode Description                    |
|:------:|:------:|-------------------------------------|
| 0      | 0      | Bypass (L → L, R → R)               |
| 1      | 0      | Mid-Side Encoder                    |
| 0      | 1      | Mid-Side Decoder                    |
| 1      | 1      | Encode + Decode (identity loopback) |

---

## Design Notes

- No side effects on read.
- No auto-clear or toggle behavior.
- Register writes take effect immediately.
- Undefined bits must be written as zero.

This interface is designed for clarity, not extensibility.

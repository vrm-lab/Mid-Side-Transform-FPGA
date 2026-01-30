#ifndef MIDSIDE_CORE_H
#define MIDSIDE_CORE_H

#include "xil_types.h"
#include "xil_io.h"
#include "xstatus.h"

// =============================================================
// Register Map
// =============================================================
// AXI-Lite register offsets
#define MIDSIDE_CTRL_REG_OFFSET   0x00
#define MIDSIDE_STAT_REG_OFFSET   0x04   // Reserved / optional (future use)

// =============================================================
// Mode Definitions
// =============================================================
// Control register values
#define MIDSIDE_MODE_BYPASS       0x00000000
#define MIDSIDE_MODE_ENCODER      0x00000001
#define MIDSIDE_MODE_DECODER      0x00000002

// =============================================================
// Driver Instance Structure
// =============================================================
// Minimal configuration object following Xilinx standalone style
typedef struct {
    u32 BaseAddress;   // Physical base address of AXI-Lite interface
    u32 IsReady;       // Driver initialization status
} MidsideConfig;

// =============================================================
// API Prototypes
// =============================================================

/**
 * Initialize Mid-Side core driver
 */
int  Midside_Init(MidsideConfig *InstancePtr, u32 BaseAddress);

/**
 * Set operating mode (bypass / encoder / decoder)
 */
void Midside_SetMode(MidsideConfig *InstancePtr, u32 Mode);

/**
 * Read back current operating mode
 */
u32  Midside_GetMode(MidsideConfig *InstancePtr);

/**
 * Logical reset (forces BYPASS mode)
 */
void Midside_Reset(MidsideConfig *InstancePtr);

#endif // MIDSIDE_CORE_H

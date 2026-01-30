`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// Mid-Side Transform Core
// -----------------------------------------------------------------------------
// Function:
//   mid  = (L + R) >>> 1
//   side = (L - R) >>> 1
//
// Characteristics:
//   - Fixed-point, signed
//   - Deterministic 1-cycle latency
//   - Explicit internal bit growth
//   - No hidden state
// -----------------------------------------------------------------------------

module mid_side_core (
    input  wire               clk,
    input  wire               ce,      // clock enable
    input  wire               enable,  // transform enable
    input  wire signed [15:0] L,
    input  wire signed [15:0] R,
    output wire signed [15:0] mid,
    output wire signed [15:0] side
);

    // -------------------------------------------------------------------------
    // Internal bit expansion (16-bit -> 24-bit)
    // Explicit sign extension to prevent overflow ambiguity
    // -------------------------------------------------------------------------
    wire signed [23:0] L_ext = {{8{L[15]}}, L};
    wire signed [23:0] R_ext = {{8{R[15]}}, R};

    // -------------------------------------------------------------------------
    // Arithmetic domain (24-bit)
    // -------------------------------------------------------------------------
    wire signed [23:0] sum_lr  = L_ext + R_ext;
    wire signed [23:0] diff_lr = L_ext - R_ext;

    // Divide-by-2 using arithmetic shift
    wire signed [23:0] mid_24  = sum_lr  >>> 1;
    wire signed [23:0] side_24 = diff_lr >>> 1;

    // Truncate back to 16-bit (safe after scaling)
    wire signed [15:0] mid_calc  = mid_24[15:0];
    wire signed [15:0] side_calc = side_24[15:0];

    // -------------------------------------------------------------------------
    // Output registers (1-cycle latency)
    // -------------------------------------------------------------------------
    reg signed [15:0] mid_reg;
    reg signed [15:0] side_reg;

    always @(posedge clk) begin
        if (ce) begin
            if (enable) begin
                mid_reg  <= mid_calc;
                side_reg <= side_calc;
            end else begin
                // Bypass mode
                mid_reg  <= L;
                side_reg <= R;
            end
        end
    end

    assign mid  = mid_reg;
    assign side = side_reg;

endmodule

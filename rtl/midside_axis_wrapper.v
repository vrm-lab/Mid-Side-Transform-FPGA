`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// AXI-Stream Mid-Side Transform Wrapper
// -----------------------------------------------------------------------------
// Function:
//   - Stereo AXI-Stream in  (L/R)
//   - Optional Mid-Side encode
//   - Optional Mid-Side decode
//   - Stereo AXI-Stream out (L/R)
//
// Characteristics:
//   - Deterministic 2-cycle latency
//   - Backpressure-aware pipeline
//   - Core logic free of reset
// -----------------------------------------------------------------------------

module midside_axis_wrapper #
(
    parameter integer C_S_AXI_DATA_WIDTH = 32,
    parameter integer C_S_AXI_ADDR_WIDTH = 4,
    parameter integer C_AXIS_DATA_WIDTH  = 32
)
(
    // -------------------------------------------------------------------------
    // Global
    // -------------------------------------------------------------------------
    input  wire aclk,
    input  wire aresetn,

    // -------------------------------------------------------------------------
    // AXI4-Lite Control Interface
    // -------------------------------------------------------------------------
    input  wire [C_S_AXI_ADDR_WIDTH-1:0]  s_axi_awaddr,
    input  wire [2:0]                     s_axi_awprot,
    input  wire                           s_axi_awvalid,
    output wire                           s_axi_awready,
    input  wire [C_S_AXI_DATA_WIDTH-1:0]  s_axi_wdata,
    input  wire [(C_S_AXI_DATA_WIDTH/8)-1:0] s_axi_wstrb,
    input  wire                           s_axi_wvalid,
    output wire                           s_axi_wready,
    output wire [1:0]                     s_axi_bresp,
    output wire                           s_axi_bvalid,
    input  wire                           s_axi_bready,

    input  wire [C_S_AXI_ADDR_WIDTH-1:0]  s_axi_araddr,
    input  wire [2:0]                     s_axi_arprot,
    input  wire                           s_axi_arvalid,
    output wire                           s_axi_arready,
    output wire [C_S_AXI_DATA_WIDTH-1:0]  s_axi_rdata,
    output wire [1:0]                     s_axi_rresp,
    output wire                           s_axi_rvalid,
    input  wire                           s_axi_rready,

    // -------------------------------------------------------------------------
    // AXI4-Stream Interface
    // -------------------------------------------------------------------------
    input  wire [C_AXIS_DATA_WIDTH-1:0] s_axis_tdata,
    input  wire                         s_axis_tvalid,
    output wire                         s_axis_tready,
    input  wire                         s_axis_tlast,

    output wire [C_AXIS_DATA_WIDTH-1:0] m_axis_tdata,
    output wire                         m_axis_tvalid,
    input  wire                         m_axis_tready,
    output wire                         m_axis_tlast
);

    // =========================================================================
    // AXI4-Lite Registers
    // =========================================================================
    // slv_reg0[0] : Mid-Side encode enable
    // slv_reg0[1] : Mid-Side decode enable

    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg0;
    reg [C_S_AXI_DATA_WIDTH-1:0] slv_reg1; // reserved

    // AXI-Lite internal signals
    reg axi_awready, axi_wready;
    reg axi_bvalid;
    reg axi_arready;
    reg axi_rvalid;
    reg [C_S_AXI_DATA_WIDTH-1:0] axi_rdata;

    assign s_axi_awready = axi_awready;
    assign s_axi_wready  = axi_wready;
    assign s_axi_bresp   = 2'b00;
    assign s_axi_bvalid  = axi_bvalid;

    assign s_axi_arready = axi_arready;
    assign s_axi_rdata   = axi_rdata;
    assign s_axi_rresp   = 2'b00;
    assign s_axi_rvalid  = axi_rvalid;

    // -------------------------------------------------------------------------
    // AXI Write
    // -------------------------------------------------------------------------
    wire slv_reg_wren = axi_awready && s_axi_awvalid &&
                        axi_wready  && s_axi_wvalid;

    always @(posedge aclk) begin
        if (!aresetn) begin
            axi_awready <= 1'b0;
            axi_wready  <= 1'b0;
        end else begin
            axi_awready <= (~axi_awready && s_axi_awvalid && s_axi_wvalid);
            axi_wready  <= (~axi_wready  && s_axi_wvalid  && s_axi_awvalid);
        end
    end

    always @(posedge aclk) begin
        if (!aresetn) begin
            slv_reg0 <= 32'd0;
            slv_reg1 <= 32'd0;
        end else if (slv_reg_wren) begin
            case (s_axi_awaddr[C_S_AXI_ADDR_WIDTH-1:2])
                2'h0: slv_reg0 <= s_axi_wdata;
                2'h1: slv_reg1 <= s_axi_wdata;
                default: ;
            endcase
        end
    end

    always @(posedge aclk) begin
        if (!aresetn)
            axi_bvalid <= 1'b0;
        else if (slv_reg_wren && ~axi_bvalid)
            axi_bvalid <= 1'b1;
        else if (s_axi_bready)
            axi_bvalid <= 1'b0;
    end

    // -------------------------------------------------------------------------
    // AXI Read
    // -------------------------------------------------------------------------
    always @(posedge aclk) begin
        if (!aresetn) begin
            axi_arready <= 1'b0;
            axi_rvalid  <= 1'b0;
        end else begin
            axi_arready <= (~axi_arready && s_axi_arvalid);
            axi_rvalid  <= (axi_arready && s_axi_arvalid) ? 1'b1 :
                           (axi_rvalid  && s_axi_rready) ? 1'b0 : axi_rvalid;
        end
    end

    always @(posedge aclk) begin
        if (!aresetn)
            axi_rdata <= 32'd0;
        else if (axi_arready && s_axi_arvalid) begin
            case (s_axi_araddr[C_S_AXI_ADDR_WIDTH-1:2])
                2'h0: axi_rdata <= slv_reg0;
                2'h1: axi_rdata <= slv_reg1;
                default: axi_rdata <= 32'd0;
            endcase
        end
    end

    // =========================================================================
    // Processing Pipeline (2-cycle fixed latency)
    // =========================================================================

    wire core_enable    = slv_reg0[0];
    wire inverse_enable = slv_reg0[1];

    wire signed [15:0] axis_L = s_axis_tdata[31:16];
    wire signed [15:0] axis_R = s_axis_tdata[15:0];

    // Pipeline control
    reg [1:0] valid_pipe;
    reg [1:0] last_pipe;

    wire pipeline_ce = m_axis_tready || !valid_pipe[1];

    assign s_axis_tready = pipeline_ce;

    always @(posedge aclk) begin
        if (!aresetn) begin
            valid_pipe <= 2'b00;
            last_pipe  <= 2'b00;
        end else if (pipeline_ce) begin
            valid_pipe[0] <= s_axis_tvalid;
            last_pipe[0]  <= s_axis_tlast;
            valid_pipe[1] <= valid_pipe[0];
            last_pipe[1]  <= last_pipe[0];
        end
    end

    // -------------------------------------------------------------------------
    // Core Instantiation
    // -------------------------------------------------------------------------
    wire signed [15:0] mid_sig, side_sig;
    wire signed [15:0] out_L, out_R;

    mid_side_core u_ms_encode (
        .clk    (aclk),
        .ce     (pipeline_ce),
        .enable (core_enable),
        .L      (axis_L),
        .R      (axis_R),
        .mid    (mid_sig),
        .side   (side_sig)
    );

    mid_side_inverse u_ms_decode (
        .clk    (aclk),
        .ce     (pipeline_ce),
        .enable (inverse_enable),
        .mid    (mid_sig),
        .side   (side_sig),
        .L      (out_L),
        .R      (out_R)
    );

    // Output
    assign m_axis_tdata  = {out_L, out_R};
    assign m_axis_tvalid = valid_pipe[1];
    assign m_axis_tlast  = last_pipe[1];

endmodule

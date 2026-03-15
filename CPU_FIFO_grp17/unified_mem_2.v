`timescale 1ns/1ps

///////////////////////////////////////////////////////////////////////////////
// Module: unified_mem.v
// Description:
//   Unified memory wrapper integrating FIFO_bram (addresses 0-255) and
//   shared_regfile (addresses 256-287) into two fully symmetric ports.
//
//   Address map:
//     Addresses   0-255 : FIFO_bram (72-bit wide)
//     Addresses 256-287 : shared_regfile (32-bit, zero-padded to 72-bit)
//
//   Port A — Generic access port (network_mem, GPU, or any other module)
//   Port B — CPU port
//
//   Both ports are fully symmetric:
//     - 9-bit unified address
//     - read_shared_file pin per port, OR'd with addr[8] to form sel
//     - sel == 0 : access FIFO_bram
//     - sel == 1 : access shared_regfile
//     - BRAM we gated OFF when sel == 1
//     - Regfile we gated OFF when sel == 0
//     - Output mux selects based on registered sel (matches 1-cycle latency)
//
//   Shared regfile port mapping:
//     Port A -> regfile GPU port  (generic accessor)
//     Port B -> regfile CPU port
//
//   Compatibility: Verilog-2001
///////////////////////////////////////////////////////////////////////////////

module unified_mem (
    // --- Port A (Generic access port)
    input  wire [8:0]  addra,
    input  wire [71:0] dina,
    input  wire        wea,
    output wire [71:0] douta,
    input  wire        clka,
    input  wire        read_shared_file_a,   // force shared regfile access on port A

    // --- Port B (CPU port)
    input  wire [8:0]  addrb,
    input  wire [71:0] dinb,
    input  wire        web,
    output wire [71:0] doutb,
    input  wire        clkb,
    input  wire        read_shared_file_b,   // force shared regfile access on port B

    // --- Reset (for shared_regfile flip-flops only, BRAM has no reset)
    input  wire        reset,

    // --- External hardwired read inputs to shared_regfile (locations 0-7)
    //     Pointer signals from network_mem
    input  wire [31:0] ext_in_0,
    input  wire [31:0] ext_in_1,
    input  wire [31:0] ext_in_2,
    input  wire [31:0] ext_in_3,
    input  wire [31:0] ext_in_4,
    input  wire [31:0] ext_in_5,
    input  wire [31:0] ext_in_6,
    input  wire [31:0] ext_in_7,

    // --- Broadcast outputs from shared_regfile (locations 8-31)
    output wire [31:0] reg_out_8,
    output wire [31:0] reg_out_9,
    output wire [31:0] reg_out_10,
    output wire [31:0] reg_out_11,
    output wire [31:0] reg_out_12,
    output wire [31:0] reg_out_13,
    output wire [31:0] reg_out_14,
    output wire [31:0] reg_out_15,
    output wire [31:0] reg_out_16,
    output wire [31:0] reg_out_17,
    output wire [31:0] reg_out_18,
    output wire [31:0] reg_out_19,
    output wire [31:0] reg_out_20,
    output wire [31:0] reg_out_21,
    output wire [31:0] reg_out_22,
    output wire [31:0] reg_out_23,
    output wire [31:0] reg_out_24,
    output wire [31:0] reg_out_25,
    output wire [31:0] reg_out_26,
    output wire [31:0] reg_out_27,
    output wire [31:0] reg_out_28,
    output wire [31:0] reg_out_29,
    output wire [31:0] reg_out_30,
    output wire [31:0] reg_out_31
);

//-----------------------------------------------------------------------------
// Selection signals
// sel == 0 : access BRAM
// sel == 1 : access shared_regfile
//-----------------------------------------------------------------------------
wire sel_a;
wire sel_b;

assign sel_a = addra[8] | read_shared_file_a;
assign sel_b = addrb[8] | read_shared_file_b;

//-----------------------------------------------------------------------------
// Write enable gating
//-----------------------------------------------------------------------------
wire bram_wea;
wire bram_web;
wire regfile_gpu_we;    // port A -> regfile GPU port
wire regfile_cpu_we;    // port B -> regfile CPU port

assign bram_wea      = wea && !sel_a;
assign bram_web      = web && !sel_b;
assign regfile_gpu_we = wea &&  sel_a;
assign regfile_cpu_we = web &&  sel_b;

//-----------------------------------------------------------------------------
// BRAM and regfile output wires
//-----------------------------------------------------------------------------
wire [71:0] bram_douta;
wire [71:0] bram_doutb;
wire [31:0] regfile_gpu_dout;   // port A output from regfile
wire [31:0] regfile_cpu_dout;   // port B output from regfile

//-----------------------------------------------------------------------------
// Registered sel to match 1-cycle read latency of both BRAM and regfile
//-----------------------------------------------------------------------------
reg sel_a_reg;
reg sel_b_reg;

always @(posedge clka) begin
    sel_a_reg <= sel_a;
end

always @(posedge clkb) begin
    sel_b_reg <= sel_b;
end

//-----------------------------------------------------------------------------
// Output mux
// sel == 1 : {40'b0, 32-bit regfile dout}
// sel == 0 : 72-bit BRAM dout
//-----------------------------------------------------------------------------
assign douta = sel_a_reg ? {40'b0, regfile_gpu_dout} : bram_douta;
assign doutb = sel_b_reg ? {40'b0, regfile_cpu_dout} : bram_doutb;

//-----------------------------------------------------------------------------
// FIFO_bram instantiation
// addr[7:0] passed directly
//-----------------------------------------------------------------------------
FIFO_bram fifo_bram_i (
    .addra (addra[7:0]),
    .addrb (addrb[7:0]),
    .clka  (clka),
    .clkb  (clkb),
    .dina  (dina),
    .dinb  (dinb),
    .douta (bram_douta),
    .doutb (bram_doutb),
    .wea   (bram_wea),
    .web   (bram_web)
);

//-----------------------------------------------------------------------------
// shared_regfile instantiation
// addr[4:0] passed — maps unified addresses 256-287 to regfile locations 0-31
// Port A -> regfile GPU port (generic accessor)
// Port B -> regfile CPU port
//-----------------------------------------------------------------------------
shared_regfile regfile_i (
    .clk        (clka),

    .reset      (reset),

    // GPU port (driven by port A)
    .gpu_addr   (addra[4:0]),
    .gpu_din    (dina[31:0]),
    .gpu_we     (regfile_gpu_we),
    .gpu_dout   (regfile_gpu_dout),

    // CPU port (driven by port B)
    .cpu_addr   (addrb[4:0]),
    .cpu_din    (dinb[31:0]),
    .cpu_we     (regfile_cpu_we),
    .cpu_dout   (regfile_cpu_dout),

    // External hardwired inputs (locations 0-7)
    .ext_in_0   (ext_in_0),
    .ext_in_1   (ext_in_1),
    .ext_in_2   (ext_in_2),
    .ext_in_3   (ext_in_3),
    .ext_in_4   (ext_in_4),
    .ext_in_5   (ext_in_5),
    .ext_in_6   (ext_in_6),
    .ext_in_7   (ext_in_7),

    // Broadcast outputs (locations 8-31)
    .reg_out_8  (reg_out_8),
    .reg_out_9  (reg_out_9),
    .reg_out_10 (reg_out_10),
    .reg_out_11 (reg_out_11),
    .reg_out_12 (reg_out_12),
    .reg_out_13 (reg_out_13),
    .reg_out_14 (reg_out_14),
    .reg_out_15 (reg_out_15),
    .reg_out_16 (reg_out_16),
    .reg_out_17 (reg_out_17),
    .reg_out_18 (reg_out_18),
    .reg_out_19 (reg_out_19),
    .reg_out_20 (reg_out_20),
    .reg_out_21 (reg_out_21),
    .reg_out_22 (reg_out_22),
    .reg_out_23 (reg_out_23),
    .reg_out_24 (reg_out_24),
    .reg_out_25 (reg_out_25),
    .reg_out_26 (reg_out_26),
    .reg_out_27 (reg_out_27),
    .reg_out_28 (reg_out_28),
    .reg_out_29 (reg_out_29),
    .reg_out_30 (reg_out_30),
    .reg_out_31 (reg_out_31)
);

endmodule

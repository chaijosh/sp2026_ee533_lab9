`timescale 1ns/1ps


///////////////////////////////////////////////////////////////////////////////
// Sub-module: write_decoder
// 32-deep one-hot write enable decoder
// Lines 0-7 are valid outputs but left unconnected at the top level
///////////////////////////////////////////////////////////////////////////////
module write_decoder (
    input  wire [4:0]  addr,
    input  wire        we,
    output wire [31:0] lines
);

assign lines[0]  = we && (addr == 5'd0);
assign lines[1]  = we && (addr == 5'd1);
assign lines[2]  = we && (addr == 5'd2);
assign lines[3]  = we && (addr == 5'd3);
assign lines[4]  = we && (addr == 5'd4);
assign lines[5]  = we && (addr == 5'd5);
assign lines[6]  = we && (addr == 5'd6);
assign lines[7]  = we && (addr == 5'd7);
assign lines[8]  = we && (addr == 5'd8);
assign lines[9]  = we && (addr == 5'd9);
assign lines[10] = we && (addr == 5'd10);
assign lines[11] = we && (addr == 5'd11);
assign lines[12] = we && (addr == 5'd12);
assign lines[13] = we && (addr == 5'd13);
assign lines[14] = we && (addr == 5'd14);
assign lines[15] = we && (addr == 5'd15);
assign lines[16] = we && (addr == 5'd16);
assign lines[17] = we && (addr == 5'd17);
assign lines[18] = we && (addr == 5'd18);
assign lines[19] = we && (addr == 5'd19);
assign lines[20] = we && (addr == 5'd20);
assign lines[21] = we && (addr == 5'd21);
assign lines[22] = we && (addr == 5'd22);
assign lines[23] = we && (addr == 5'd23);
assign lines[24] = we && (addr == 5'd24);
assign lines[25] = we && (addr == 5'd25);
assign lines[26] = we && (addr == 5'd26);
assign lines[27] = we && (addr == 5'd27);
assign lines[28] = we && (addr == 5'd28);
assign lines[29] = we && (addr == 5'd29);
assign lines[30] = we && (addr == 5'd30);
assign lines[31] = we && (addr == 5'd31);

endmodule


///////////////////////////////////////////////////////////////////////////////
// Sub-module: read_decoder
// 32-deep mux: selects output based on registered address
// Locations 0-7  : ext_in signals (hardwired from network_mem)
// Locations 8-31 : reg_cells flip-flop outputs
///////////////////////////////////////////////////////////////////////////////
module read_decoder (
    input  wire [4:0]  addr,

    // External inputs for locations 0-7
    input  wire [31:0] ext_in_0,
    input  wire [31:0] ext_in_1,
    input  wire [31:0] ext_in_2,
    input  wire [31:0] ext_in_3,
    input  wire [31:0] ext_in_4,
    input  wire [31:0] ext_in_5,
    input  wire [31:0] ext_in_6,
    input  wire [31:0] ext_in_7,

    // Flip-flop outputs for locations 8-31
    input  wire [31:0] reg_cells_8,
    input  wire [31:0] reg_cells_9,
    input  wire [31:0] reg_cells_10,
    input  wire [31:0] reg_cells_11,
    input  wire [31:0] reg_cells_12,
    input  wire [31:0] reg_cells_13,
    input  wire [31:0] reg_cells_14,
    input  wire [31:0] reg_cells_15,
    input  wire [31:0] reg_cells_16,
    input  wire [31:0] reg_cells_17,
    input  wire [31:0] reg_cells_18,
    input  wire [31:0] reg_cells_19,
    input  wire [31:0] reg_cells_20,
    input  wire [31:0] reg_cells_21,
    input  wire [31:0] reg_cells_22,
    input  wire [31:0] reg_cells_23,
    input  wire [31:0] reg_cells_24,
    input  wire [31:0] reg_cells_25,
    input  wire [31:0] reg_cells_26,
    input  wire [31:0] reg_cells_27,
    input  wire [31:0] reg_cells_28,
    input  wire [31:0] reg_cells_29,
    input  wire [31:0] reg_cells_30,
    input  wire [31:0] reg_cells_31,

    output reg  [31:0] dout
);

always @(*) begin
    case (addr)
        5'd0  : dout = ext_in_0;
        5'd1  : dout = ext_in_1;
        5'd2  : dout = ext_in_2;
        5'd3  : dout = ext_in_3;
        5'd4  : dout = ext_in_4;
        5'd5  : dout = ext_in_5;
        5'd6  : dout = ext_in_6;
        5'd7  : dout = ext_in_7;
        5'd8  : dout = reg_cells_8;
        5'd9  : dout = reg_cells_9;
        5'd10 : dout = reg_cells_10;
        5'd11 : dout = reg_cells_11;
        5'd12 : dout = reg_cells_12;
        5'd13 : dout = reg_cells_13;
        5'd14 : dout = reg_cells_14;
        5'd15 : dout = reg_cells_15;
        5'd16 : dout = reg_cells_16;
        5'd17 : dout = reg_cells_17;
        5'd18 : dout = reg_cells_18;
        5'd19 : dout = reg_cells_19;
        5'd20 : dout = reg_cells_20;
        5'd21 : dout = reg_cells_21;
        5'd22 : dout = reg_cells_22;
        5'd23 : dout = reg_cells_23;
        5'd24 : dout = reg_cells_24;
        5'd25 : dout = reg_cells_25;
        5'd26 : dout = reg_cells_26;
        5'd27 : dout = reg_cells_27;
        5'd28 : dout = reg_cells_28;
        5'd29 : dout = reg_cells_29;
        5'd30 : dout = reg_cells_30;
        5'd31 : dout = reg_cells_31;
        default: dout = 32'd0;
    endcase
end

endmodule


///////////////////////////////////////////////////////////////////////////////
// Sub-module: regfile_cell
// Single 32-bit flip-flop cell with dual write ports
// CPU write takes priority over GPU write
///////////////////////////////////////////////////////////////////////////////
module regfile_cell (
    input  wire        clk,
    input  wire        reset,
    input  wire        cpu_we,
    input  wire        gpu_we,
    input  wire [31:0] cpu_din,
    input  wire [31:0] gpu_din,
    output reg  [31:0] dout
);

always @(posedge clk) begin
    if (reset) begin
        dout <= 32'd0;
    end else if (cpu_we) begin
        dout <= cpu_din;
    end else if (gpu_we) begin
        dout <= gpu_din;
    end
end

endmodule



///////////////////////////////////////////////////////////////////////////////
// Module: shared_regfile.v
// Description:
//   Shared register file (32 locations x 32-bit) built from flip-flops.
//   Maps to addresses 256-287 in the SOC memory map.
//
//   Location layout:
//     Locations  0- 7 : Read-only, hardwired to ext_in_0..7 from network_mem
//                       Write decoder lines 0-7 are generated but left unconnected
//     Locations  8-31 : True read/write flip-flop storage (24 cells)
//
//   Port behavior (mirrors BRAM timing):
//     - addr, din, we are all registered on clock edge (input stage)
//     - reads and writes both have 1-cycle latency
//
//   Arbitration:
//     - If CPU and GPU write to the same address simultaneously, GPU is blocked
//     - CPU always wins on address conflict
//
//   Broadcast:
//     - All 24 stored values (locations 8-31) driven out combinationally
//     - reg_out_8 corresponds to location 8, reg_out_31 to location 31
//
//   Compatibility: Verilog-2001. No unpacked arrays, no genvar, no generate.
///////////////////////////////////////////////////////////////////////////////

module shared_regfile (
    input  wire        clk,
    input  wire        reset,

    // CPU port
    input  wire [4:0]  cpu_addr,
    input  wire [31:0] cpu_din,
    input  wire        cpu_we,
    output wire [31:0] cpu_dout,

    // GPU port
    input  wire [4:0]  gpu_addr,
    input  wire [31:0] gpu_din,
    input  wire        gpu_we,
    output wire [31:0] gpu_dout,

    // External hardwired read inputs from network_mem (locations 0-7)
    input  wire [31:0] ext_in_0,
    input  wire [31:0] ext_in_1,
    input  wire [31:0] ext_in_2,
    input  wire [31:0] ext_in_3,
    input  wire [31:0] ext_in_4,
    input  wire [31:0] ext_in_5,
    input  wire [31:0] ext_in_6,
    input  wire [31:0] ext_in_7,

    // Broadcast outputs - all 24 stored flip-flop values (locations 8-31)
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
// Input Stage Registers (mirrors BRAM input register stage)
//-----------------------------------------------------------------------------
reg [4:0]  cpu_addr_reg;
reg [31:0] cpu_din_reg;
reg        cpu_we_reg;

reg [4:0]  gpu_addr_reg;
reg [31:0] gpu_din_reg;
reg        gpu_we_reg;

always @(posedge clk) begin
    if (reset) begin
        cpu_addr_reg <= 5'd0;
        cpu_din_reg  <= 32'd0;
        cpu_we_reg   <= 1'b0;
        gpu_addr_reg <= 5'd0;
        gpu_din_reg  <= 32'd0;
        gpu_we_reg   <= 1'b0;
    end else begin
        cpu_addr_reg <= cpu_addr;
        cpu_din_reg  <= cpu_din;
        cpu_we_reg   <= cpu_we;
        gpu_addr_reg <= gpu_addr;
        gpu_din_reg  <= gpu_din;
        gpu_we_reg   <= gpu_we;
    end
end

//-----------------------------------------------------------------------------
// Write Arbitration
// If CPU and GPU write to the same address, GPU write is blocked
//-----------------------------------------------------------------------------
wire cpu_we_gated;
wire gpu_we_gated;

assign cpu_we_gated = cpu_we_reg;
assign gpu_we_gated = gpu_we_reg && !((gpu_addr_reg == cpu_addr_reg) && cpu_we_reg);

//-----------------------------------------------------------------------------
// Write Decoders (32-deep, one per port)
// Lines 0-7 are generated but unconnected (no flip-flops at those locations)
// Lines 8-31 drive the flip-flop write enables
//-----------------------------------------------------------------------------
wire [31:0] cpu_we_lines;
wire [31:0] gpu_we_lines;

write_decoder cpu_write_dec (
    .addr (cpu_addr_reg),
    .we   (cpu_we_gated),
    .lines(cpu_we_lines)
);

write_decoder gpu_write_dec (
    .addr (gpu_addr_reg),
    .we   (gpu_we_gated),
    .lines(gpu_we_lines)
);

//-----------------------------------------------------------------------------
// Internal cell wires - one named wire per location (8-31)
//-----------------------------------------------------------------------------
wire [31:0] cell_8;
wire [31:0] cell_9;
wire [31:0] cell_10;
wire [31:0] cell_11;
wire [31:0] cell_12;
wire [31:0] cell_13;
wire [31:0] cell_14;
wire [31:0] cell_15;
wire [31:0] cell_16;
wire [31:0] cell_17;
wire [31:0] cell_18;
wire [31:0] cell_19;
wire [31:0] cell_20;
wire [31:0] cell_21;
wire [31:0] cell_22;
wire [31:0] cell_23;
wire [31:0] cell_24;
wire [31:0] cell_25;
wire [31:0] cell_26;
wire [31:0] cell_27;
wire [31:0] cell_28;
wire [31:0] cell_29;
wire [31:0] cell_30;
wire [31:0] cell_31;

//-----------------------------------------------------------------------------
// Register File Cells - explicit instantiation (locations 8-31)
//-----------------------------------------------------------------------------
regfile_cell cell_inst_8  (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[8]),  .gpu_we(gpu_we_lines[8]),  .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_8));
regfile_cell cell_inst_9  (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[9]),  .gpu_we(gpu_we_lines[9]),  .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_9));
regfile_cell cell_inst_10 (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[10]), .gpu_we(gpu_we_lines[10]), .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_10));
regfile_cell cell_inst_11 (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[11]), .gpu_we(gpu_we_lines[11]), .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_11));
regfile_cell cell_inst_12 (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[12]), .gpu_we(gpu_we_lines[12]), .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_12));
regfile_cell cell_inst_13 (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[13]), .gpu_we(gpu_we_lines[13]), .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_13));
regfile_cell cell_inst_14 (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[14]), .gpu_we(gpu_we_lines[14]), .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_14));
regfile_cell cell_inst_15 (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[15]), .gpu_we(gpu_we_lines[15]), .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_15));
regfile_cell cell_inst_16 (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[16]), .gpu_we(gpu_we_lines[16]), .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_16));
regfile_cell cell_inst_17 (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[17]), .gpu_we(gpu_we_lines[17]), .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_17));
regfile_cell cell_inst_18 (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[18]), .gpu_we(gpu_we_lines[18]), .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_18));
regfile_cell cell_inst_19 (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[19]), .gpu_we(gpu_we_lines[19]), .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_19));
regfile_cell cell_inst_20 (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[20]), .gpu_we(gpu_we_lines[20]), .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_20));
regfile_cell cell_inst_21 (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[21]), .gpu_we(gpu_we_lines[21]), .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_21));
regfile_cell cell_inst_22 (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[22]), .gpu_we(gpu_we_lines[22]), .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_22));
regfile_cell cell_inst_23 (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[23]), .gpu_we(gpu_we_lines[23]), .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_23));
regfile_cell cell_inst_24 (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[24]), .gpu_we(gpu_we_lines[24]), .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_24));
regfile_cell cell_inst_25 (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[25]), .gpu_we(gpu_we_lines[25]), .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_25));
regfile_cell cell_inst_26 (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[26]), .gpu_we(gpu_we_lines[26]), .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_26));
regfile_cell cell_inst_27 (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[27]), .gpu_we(gpu_we_lines[27]), .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_27));
regfile_cell cell_inst_28 (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[28]), .gpu_we(gpu_we_lines[28]), .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_28));
regfile_cell cell_inst_29 (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[29]), .gpu_we(gpu_we_lines[29]), .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_29));
regfile_cell cell_inst_30 (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[30]), .gpu_we(gpu_we_lines[30]), .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_30));
regfile_cell cell_inst_31 (.clk(clk), .reset(reset), .cpu_we(cpu_we_lines[31]), .gpu_we(gpu_we_lines[31]), .cpu_din(cpu_din_reg), .gpu_din(gpu_din_reg), .dout(cell_31));

//-----------------------------------------------------------------------------
// Broadcast outputs - direct wire connections from cells to output ports
//-----------------------------------------------------------------------------
assign reg_out_8  = cell_8;
assign reg_out_9  = cell_9;
assign reg_out_10 = cell_10;
assign reg_out_11 = cell_11;
assign reg_out_12 = cell_12;
assign reg_out_13 = cell_13;
assign reg_out_14 = cell_14;
assign reg_out_15 = cell_15;
assign reg_out_16 = cell_16;
assign reg_out_17 = cell_17;
assign reg_out_18 = cell_18;
assign reg_out_19 = cell_19;
assign reg_out_20 = cell_20;
assign reg_out_21 = cell_21;
assign reg_out_22 = cell_22;
assign reg_out_23 = cell_23;
assign reg_out_24 = cell_24;
assign reg_out_25 = cell_25;
assign reg_out_26 = cell_26;
assign reg_out_27 = cell_27;
assign reg_out_28 = cell_28;
assign reg_out_29 = cell_29;
assign reg_out_30 = cell_30;
assign reg_out_31 = cell_31;

//-----------------------------------------------------------------------------
// Read Decoders (32-deep, one per port)
// Locations 0-7  : hardwired to ext_in
// Locations 8-31 : from cell wires
//-----------------------------------------------------------------------------
read_decoder cpu_read_dec (
    .addr         (cpu_addr_reg),
    .ext_in_0     (ext_in_0),
    .ext_in_1     (ext_in_1),
    .ext_in_2     (ext_in_2),
    .ext_in_3     (ext_in_3),
    .ext_in_4     (ext_in_4),
    .ext_in_5     (ext_in_5),
    .ext_in_6     (ext_in_6),
    .ext_in_7     (ext_in_7),
    .reg_cells_8  (cell_8),
    .reg_cells_9  (cell_9),
    .reg_cells_10 (cell_10),
    .reg_cells_11 (cell_11),
    .reg_cells_12 (cell_12),
    .reg_cells_13 (cell_13),
    .reg_cells_14 (cell_14),
    .reg_cells_15 (cell_15),
    .reg_cells_16 (cell_16),
    .reg_cells_17 (cell_17),
    .reg_cells_18 (cell_18),
    .reg_cells_19 (cell_19),
    .reg_cells_20 (cell_20),
    .reg_cells_21 (cell_21),
    .reg_cells_22 (cell_22),
    .reg_cells_23 (cell_23),
    .reg_cells_24 (cell_24),
    .reg_cells_25 (cell_25),
    .reg_cells_26 (cell_26),
    .reg_cells_27 (cell_27),
    .reg_cells_28 (cell_28),
    .reg_cells_29 (cell_29),
    .reg_cells_30 (cell_30),
    .reg_cells_31 (cell_31),
    .dout         (cpu_dout)
);

read_decoder gpu_read_dec (
    .addr         (gpu_addr_reg),
    .ext_in_0     (ext_in_0),
    .ext_in_1     (ext_in_1),
    .ext_in_2     (ext_in_2),
    .ext_in_3     (ext_in_3),
    .ext_in_4     (ext_in_4),
    .ext_in_5     (ext_in_5),
    .ext_in_6     (ext_in_6),
    .ext_in_7     (ext_in_7),
    .reg_cells_8  (cell_8),
    .reg_cells_9  (cell_9),
    .reg_cells_10 (cell_10),
    .reg_cells_11 (cell_11),
    .reg_cells_12 (cell_12),
    .reg_cells_13 (cell_13),
    .reg_cells_14 (cell_14),
    .reg_cells_15 (cell_15),
    .reg_cells_16 (cell_16),
    .reg_cells_17 (cell_17),
    .reg_cells_18 (cell_18),
    .reg_cells_19 (cell_19),
    .reg_cells_20 (cell_20),
    .reg_cells_21 (cell_21),
    .reg_cells_22 (cell_22),
    .reg_cells_23 (cell_23),
    .reg_cells_24 (cell_24),
    .reg_cells_25 (cell_25),
    .reg_cells_26 (cell_26),
    .reg_cells_27 (cell_27),
    .reg_cells_28 (cell_28),
    .reg_cells_29 (cell_29),
    .reg_cells_30 (cell_30),
    .reg_cells_31 (cell_31),
    .dout         (gpu_dout)
);

endmodule




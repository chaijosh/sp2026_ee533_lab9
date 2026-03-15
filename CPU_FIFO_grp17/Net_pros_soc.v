`timescale 1ns/1ps

module Net_pros_soc 
   #(
      parameter DATA_WIDTH = 64,
      parameter CTRL_WIDTH = DATA_WIDTH/8,
      parameter UDP_REG_SRC_WIDTH = 2
   )
   (
      input  [DATA_WIDTH-1:0]             in_data,
      input  [CTRL_WIDTH-1:0]             in_ctrl,
      input                               in_wr,
      output                              in_rdy,

      output [DATA_WIDTH-1:0]             out_data,
      output [CTRL_WIDTH-1:0]             out_ctrl,
      output                              out_wr,
      input                               out_rdy,
      
      // --- Register interface
      input                               reg_req_in,
      input                               reg_ack_in,
      input                               reg_rd_wr_L_in,
      input  [`UDP_REG_ADDR_WIDTH-1:0]    reg_addr_in,
      input  [`CPCI_NF2_DATA_WIDTH-1:0]   reg_data_in,
      input  [UDP_REG_SRC_WIDTH-1:0]      reg_src_in,

      output                              reg_req_out,
      output                              reg_ack_out,
      output                              reg_rd_wr_L_out,
      output  [`UDP_REG_ADDR_WIDTH-1:0]   reg_addr_out,
      output  [`CPCI_NF2_DATA_WIDTH-1:0]  reg_data_out,
      output  [UDP_REG_SRC_WIDTH-1:0]     reg_src_out,

      // misc
      input                                reset,
      input                                clk
   );

   wire                             netmem_DPU_in_reg_req;
   wire                             netmem_DPU_in_reg_ack;
   wire                             netmem_DPU_in_reg_rd_wr_L;
   wire [`UDP_REG_ADDR_WIDTH-1:0]   netmem_DPU_in_reg_addr;
   wire [`CPCI_NF2_DATA_WIDTH-1:0]  netmem_DPU_in_reg_data;
   wire [UDP_REG_SRC_WIDTH-1:0]     netmem_DPU_in_reg_src;

   wire [8:0]                      netmem_dpu_addr_in;
   wire [63:0]                     netmem_dpu_data_in;                              
   wire                            netmem_dpu_we;
   wire [63:0]                     netmem_dpu_data_out;


//read_shared_file_a/b not used for now

network_mem 
   #(
      .DATA_WIDTH(64),
      .CTRL_WIDTH(8),
      .UDP_REG_SRC_WIDTH(2)
   ) network_mem_0 (
      .in_data(in_data),
      .in_ctrl(in_ctrl),
      .in_wr(in_wr),
      .in_rdy(in_rdy),

      .out_data(out_data),
      .out_ctrl(out_ctrl),
      .out_wr(out_wr),
      .out_rdy(out_rdy),

      .cpu_addr_in(netmem_dpu_addr_in),
      .cpu_data_in(netmem_dpu_data_in),                              
      .cpu_we(netmem_dpu_we),
      .cpu_data_out(netmem_dpu_data_out),

      
      // --- Register interface
      .reg_req_in(reg_req_in),
      .reg_ack_in(reg_ack_in),
      .reg_rd_wr_L_in(reg_rd_wr_L_in),
      .reg_addr_in(reg_addr_in),
      .reg_data_in(reg_data_in),
      .reg_src_in(reg_src_in),

      .reg_req_out(netmem_DPU_in_reg_req),
      .reg_ack_out(netmem_DPU_in_reg_ack),
      .reg_rd_wr_L_out(netmem_DPU_in_reg_rd_wr_L),
      .reg_addr_out(netmem_DPU_in_reg_addr),
      .reg_data_out(netmem_DPU_in_reg_data),
      .reg_src_out(netmem_DPU_in_reg_src),

      // misc
      .reset(reset),
      .clk(clk)
   );


np_dpu 
   #(
      .DATA_WIDTH(64),
      .CTRL_WIDTH(DATA_WIDTH/8),
      .UDP_REG_SRC_WIDTH(2)
   )
   np_dpu_0 (
      //Signals line to interface with dmem in Network_memory
      .dmem_dout(netmem_dpu_data_out),
      .dmem_addr(netmem_dpu_addr_in),
      .dmem_datain(netmem_dpu_data_in),
      .dmem_we(netmem_dpu_we),                
      
      // --- Register interface
      .reg_req_in(netmem_DPU_in_reg_req),
      .reg_ack_in(netmem_DPU_in_reg_ack),
      .reg_rd_wr_L_in(netmem_DPU_in_reg_rd_wr_L),
      .reg_addr_in(netmem_DPU_in_reg_addr),
      .reg_data_in(netmem_DPU_in_reg_data),
      .reg_src_in(netmem_DPU_in_reg_src),

      .reg_req_out(reg_req_out),
      .reg_ack_out(reg_ack_out),
      .reg_rd_wr_L_out(reg_rd_wr_L_out),
      .reg_addr_out(reg_addr_out),
      .reg_data_out(reg_data_out),
      .reg_src_out(reg_src_out),

      // misc
      .reset(reset),
      .clk(clk)
   );




endmodule


// -- (c) Copyright 2012 Xilinx, Inc. All rights reserved.
// --
// -- This file contains confidential and proprietary information
// -- of Xilinx, Inc. and is protected under U.S. and 
// -- international copyright and other intellectual property
// -- laws.
// --
// -- DISCLAIMER
// -- This disclaimer is not a license and does not grant any
// -- rights to the materials distributed herewith. Except as
// -- otherwise provided in a valid license issued to you by
// -- Xilinx, and to the maximum extent permitted by applicable
// -- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// -- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// -- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// -- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// -- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// -- (2) Xilinx shall not be liable (whether in contract or tort,
// -- including negligence, or under any other theory of
// -- liability) for any loss or damage of any kind or nature
// -- related to, arising under or in connection with these
// -- materials, including for any direct, or any indirect,
// -- special, incidental, or consequential loss or damage
// -- (including loss of data, profits, goodwill, or any type of
// -- loss or damage suffered as a result of any action brought
// -- by a third party) even if such damage or loss was
// -- reasonably foreseeable or Xilinx had been advised of the
// -- possibility of the same.
// --
// -- CRITICAL APPLICATIONS
// -- Xilinx products are not designed or intended to be fail-
// -- safe, or for use in any application requiring fail-safe
// -- performance, such as life-support or safety devices or
// -- systems, Class III medical devices, nuclear facilities,
// -- applications related to the deployment of airbags, or any
// -- other applications that could lead to death, personal
// -- injury, or severe property or environmental damage
// -- (individually and collectively, "Critical
// -- Applications"). Customer assumes the sole risk and
// -- liability of any use of Xilinx products in Critical
// -- Applications, subject only to applicable laws and
// -- regulations governing limitations on product liability.
// --
// -- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// -- PART OF THIS FILE AT ALL TIMES.
//-----------------------------------------------------------------------------
//
// Description: Write Data Up-Sizer with Packet FIFO
//
//--------------------------------------------------------------------------

`timescale 1ps/1ps

(* DowngradeIPIdentifiedWarnings="yes" *) 
module axi_dwidth_converter_v2_1_r_upsizer_pktfifo #
  (
   parameter         C_FAMILY                         = "virtex7", 
                       // FPGA Family. Current version: virtex6 or spartan6.
   parameter integer C_S_AXI_DATA_WIDTH               = 64,
                       // Width of s_axi_wdata and s_axi_rdata.
                       // Range: 32, 64, 128, 256, 512, 1024.
   parameter integer C_M_AXI_DATA_WIDTH               = 32,
                       // Width of m_axi_wdata and m_axi_rdata. 
                       // Assume always >= than C_S_AXI_DATA_WIDTH.
                       // Range: 32, 64, 128, 256, 512, 1024.
   parameter integer C_AXI_ID_WIDTH                   = 1, 
   parameter integer C_AXI_ADDR_WIDTH                 = 32, 
   parameter         C_CLK_CONV         = 1'b0,
   parameter integer C_S_AXI_ACLK_RATIO = 1,     // Clock frequency ratio of SI w.r.t. MI.
                                                 // Range = [1..16].
   parameter integer C_M_AXI_ACLK_RATIO = 2,     // Clock frequency ratio of MI w.r.t. SI.
                                                 // Range = [2..16] if C_S_AXI_ACLK_RATIO = 1; else must be 1.
   parameter integer C_AXI_IS_ACLK_ASYNC = 0,    // Indicates whether S and M clocks are asynchronous.
                                                 // FUTURE FEATURE
                                                 // Range = [0, 1].
   parameter integer C_S_AXI_BYTES_LOG                = 3,
                       // Log2 of number of 32bit word on SI-side.
   parameter integer C_M_AXI_BYTES_LOG                = 3,
                       // Log2 of number of 32bit word on MI-side.
   parameter integer C_RATIO                          = 2,
                       // Up-Sizing ratio for data.
   parameter integer C_RATIO_LOG                      = 1,
                       // Log2 of Up-Sizing ratio for data.
   parameter integer C_SYNCHRONIZER_STAGE             = 3
   )
  (
   // Global Signals
   input  wire                              S_AXI_ACLK,
   input  wire                              M_AXI_ACLK,
   input  wire                              S_AXI_ARESETN,
   input  wire                              M_AXI_ARESETN,

   // Command Interface
   input  wire [C_AXI_ADDR_WIDTH-1:0]       cmd_si_addr,
   input  wire [C_AXI_ID_WIDTH-1:0]         cmd_si_id,
   input  wire [8-1:0]                      cmd_si_len,
   input  wire [3-1:0]                      cmd_si_size,
   input  wire [2-1:0]                      cmd_si_burst,
   output wire                              cmd_ready,
   
   // Slave Interface Write Address Port
   input  wire [C_AXI_ADDR_WIDTH-1:0]          S_AXI_ARADDR,
   input  wire [8-1:0]                         S_AXI_ARLEN,
   input  wire [3-1:0]                         S_AXI_ARSIZE,
   input  wire [2-1:0]                         S_AXI_ARBURST,
   input  wire [2-1:0]                         S_AXI_ARLOCK,
   input  wire [4-1:0]                         S_AXI_ARCACHE,
   input  wire [3-1:0]                         S_AXI_ARPROT,
   input  wire [4-1:0]                         S_AXI_ARREGION,
   input  wire [4-1:0]                         S_AXI_ARQOS,
   input  wire                                 S_AXI_ARVALID,
   output wire                                 S_AXI_ARREADY,

   // Master Interface Write Address Port
   output wire [C_AXI_ADDR_WIDTH-1:0]          M_AXI_ARADDR,
   output wire [8-1:0]                         M_AXI_ARLEN,
   output wire [3-1:0]                         M_AXI_ARSIZE,
   output wire [2-1:0]                         M_AXI_ARBURST,
   output wire [2-1:0]                         M_AXI_ARLOCK,
   output wire [4-1:0]                         M_AXI_ARCACHE,
   output wire [3-1:0]                         M_AXI_ARPROT,
   output wire [4-1:0]                         M_AXI_ARREGION,
   output wire [4-1:0]                         M_AXI_ARQOS,
   output wire                                 M_AXI_ARVALID,
   input  wire                                 M_AXI_ARREADY,

   // Slave Interface Write Data Ports
   output wire [C_AXI_ID_WIDTH-1:0]         S_AXI_RID,
   output wire [C_S_AXI_DATA_WIDTH-1:0]     S_AXI_RDATA,
   output wire [1:0]                        S_AXI_RRESP,
   output wire                              S_AXI_RLAST,
   output wire                              S_AXI_RVALID,
   input  wire                              S_AXI_RREADY,

   // Master Interface Write Data Ports
   input  wire [C_M_AXI_DATA_WIDTH-1:0]     M_AXI_RDATA,
   input  wire [1:0]                        M_AXI_RRESP,
   input  wire                              M_AXI_RLAST,
   input  wire                              M_AXI_RVALID,
   output wire                              M_AXI_RREADY,
   
   input wire                               SAMPLE_CYCLE_EARLY,
   input wire                               SAMPLE_CYCLE

   );

  assign cmd_ready = 1'b1;

  localparam integer P_SI_BYTES = C_S_AXI_DATA_WIDTH / 8;
  localparam integer P_MI_BYTES = C_M_AXI_DATA_WIDTH / 8;
  localparam integer P_MAX_BYTES = 1024 / 8;
  localparam integer P_SI_SIZE = f_ceil_log2(P_SI_BYTES);
  localparam integer P_MI_SIZE = f_ceil_log2(P_MI_BYTES);
  localparam integer P_RATIO = C_M_AXI_DATA_WIDTH / C_S_AXI_DATA_WIDTH;
  localparam integer P_RATIO_LOG = f_ceil_log2(P_RATIO);
  localparam integer P_NUM_BUF = (P_RATIO == 2) ? 4 : 8;
  localparam integer P_BUF_LIMIT = P_NUM_BUF - 1;
  localparam integer P_NUM_BUF_LOG = f_ceil_log2(P_NUM_BUF);
  localparam integer P_M_RBUFFER_DEPTH = 512;
  localparam integer P_M_RBUFFER_DEPTH_LOG = 9;
  localparam integer P_S_RBUFFER_DEPTH = P_M_RBUFFER_DEPTH * P_RATIO;
  localparam integer P_S_RBUFFER_DEPTH_LOG = f_ceil_log2(P_S_RBUFFER_DEPTH);
  localparam integer P_M_RBUFFER_WORDS = P_M_RBUFFER_DEPTH / P_NUM_BUF;
  localparam integer P_M_RBUFFER_WORDS_LOG = f_ceil_log2(P_M_RBUFFER_WORDS);
  localparam integer P_S_RBUFFER_WORDS = P_M_RBUFFER_WORDS * P_RATIO;
  localparam integer P_S_RBUFFER_WORDS_LOG = f_ceil_log2(P_S_RBUFFER_WORDS);
  localparam integer P_M_RBUFFER_BYTES = P_M_RBUFFER_WORDS * P_MI_BYTES;
  localparam integer P_M_RBUFFER_BYTES_LOG = f_ceil_log2(P_M_RBUFFER_BYTES);
  localparam integer P_MAX_RBUFFER_BYTES_LOG = f_ceil_log2((P_M_RBUFFER_DEPTH / 4) * P_MAX_BYTES);
  localparam [1:0] P_INCR = 2'b01, P_WRAP = 2'b10, P_FIXED = 2'b00;
  localparam  P_SI_LT_MI = (C_S_AXI_ACLK_RATIO < C_M_AXI_ACLK_RATIO);
  localparam integer P_ACLK_RATIO = P_SI_LT_MI ? (C_M_AXI_ACLK_RATIO / C_S_AXI_ACLK_RATIO) : (C_S_AXI_ACLK_RATIO / C_M_AXI_ACLK_RATIO);
  localparam integer P_NUM_RAMB = C_M_AXI_DATA_WIDTH / 32;
  localparam integer P_S_RAMB_WIDTH = C_S_AXI_DATA_WIDTH / P_NUM_RAMB;
  localparam integer P_S_RAMB_PWIDTH = (P_S_RAMB_WIDTH < 8) ? P_S_RAMB_WIDTH : ((P_SI_BYTES * 9) / P_NUM_RAMB);
  localparam integer P_S_CMD_WIDTH = P_MI_SIZE+4 + C_AXI_ID_WIDTH + 4 + 3 + 8 + 3 + 2;
  localparam integer P_M_CMD_WIDTH = P_MI_SIZE+4 + 8 + 3 + 2;
  localparam integer P_ARFIFO_WIDTH = 29 + C_AXI_ADDR_WIDTH;
  localparam integer P_COMMON_CLOCK = (C_CLK_CONV & C_AXI_IS_ACLK_ASYNC) ? 0 : 1;
  
  genvar i;
  genvar j;
  reg  S_AXI_ARREADY_i;
  reg  M_AXI_RREADY_i;
  reg  M_AXI_ARVALID_i;
  wire [C_AXI_ADDR_WIDTH-1:0] M_AXI_ARADDR_i;
  wire [7:0] M_AXI_ARLEN_i;
  wire [2:0] M_AXI_ARSIZE_i;
  wire [1:0] M_AXI_ARBURST_i;
  wire M_AXI_ARLOCK_i;
  wire ar_push;
  wire ar_fifo_ready;
  wire ar_fifo_valid;
  wire ar_pop;
  wire s_rbuf_en;
  wire [P_NUM_RAMB-1:0] m_rbuf_en;
  reg  [P_NUM_BUF_LOG-1:0] s_buf;
  reg  [P_NUM_BUF_LOG-1:0] m_buf;
  reg  [P_NUM_BUF_LOG-1:0] buf_cnt;
  wire buf_limit;
  reg  [7:0] s_rcnt;
  wire [P_NUM_RAMB*16-1 : 0] s_rdata ;
  wire [C_M_AXI_DATA_WIDTH-1 : 0] m_rdata ;
  reg  [1:0] s_rburst;
  reg  [2:0] s_rsize;
  reg  [3:0] s_wrap_cnt;
  reg  s_rvalid;
  reg  s_rvalid_d1;
  reg  s_rvalid_d2;
  reg  first_rvalid_d1;
  reg  s_rlast;
  reg  s_rlast_d1;
  reg  s_rlast_d2;
  wire [1:0] s_rresp;
  wire [3:0] s_rresp_i;
  wire [1:0] m_rresp;
  wire [3:0] m_rresp_i;
  reg  [1:0] s_rresp_reg;
  reg  [1:0] m_rresp_reg;
  reg  [1:0] s_rresp_d1;
  reg  [1:0] s_rresp_d2;
  reg  [1:0] s_rresp_first;
  reg  [1:0] m_rburst;
  reg  [2:0] m_rsize;
  reg  [3:0] m_wrap_cnt;
  wire s_cmd_push;
  wire s_cmd_pop;
  wire s_cmd_empty;
  wire s_cmd_full;
  wire m_cmd_push;
  wire m_cmd_pop;
  wire m_cmd_empty;
  wire m_cmd_full;
  reg  m_cmd_valid;
  wire [P_S_CMD_WIDTH-1 : 0] s_ar_cmd;
  wire [P_S_CMD_WIDTH-1 : 0] s_r_cmd;
  wire [P_M_CMD_WIDTH-1 : 0] m_ar_cmd;
  wire [P_M_CMD_WIDTH-1 : 0] m_r_cmd;
  wire [P_MI_SIZE+4-1:0] s_cmd_addr;
  wire [C_AXI_ID_WIDTH-1:0] s_cmd_id;
  reg  [C_AXI_ID_WIDTH-1:0] s_id_reg;
  reg  [C_AXI_ID_WIDTH-1:0] s_id_d1;
  reg  [C_AXI_ID_WIDTH-1:0] s_id_d2;
  wire [3:0] s_cmd_conv_len;
  reg  [3:0] s_conv_len;
  wire [2:0] s_cmd_conv_size;
  reg  [2:0] s_conv_size;
  wire [7:0] s_cmd_len;
  wire [2:0] s_cmd_size;
  wire [1:0] s_cmd_burst;
  wire [P_MI_SIZE+4-1:0] m_cmd_addr;
  wire [C_AXI_ID_WIDTH-1:0] m_cmd_id;
  wire [7:0] m_cmd_len;
  wire [2:0] m_cmd_size;
  wire [1:0] m_cmd_burst;
  wire m_transfer;
  wire rresp_fifo_push;
  wire rresp_fifo_pop;
  wire rresp_fifo_empty;
  wire rresp_fifo_full;
  reg  rresp_wrap;
  wire rresp_reuse;
  reg  s_rresp_fifo_stall;
  reg  m_rresp_fifo_stall;
  wire s_eol;
  reg  [P_M_RBUFFER_BYTES_LOG-1:0] s_raddr;
  reg  [P_M_RBUFFER_BYTES_LOG-1:0] m_raddr;
  wire [P_M_RBUFFER_BYTES_LOG-1:0] m_raddr_incr;
  reg  [P_M_RBUFFER_BYTES_LOG-1:0] s_wrap_addr;
  reg  [P_M_RBUFFER_BYTES_LOG-1:0] m_wrap_addr;
  wire [13:0] s_rbuf_addr;
  wire [13:0] m_rbuf_addr;
  wire [3:0] m_rbuf_we;  
  reg  large_incr_last;
  reg  [3:0] large_incr_mask;
  
  wire m_aclk;
  wire m_aresetn;
  wire s_aresetn;
  wire ar_fifo_s_aclk;
  wire ar_fifo_m_aclk;
  wire ar_fifo_aresetn;
  wire s_fifo_rst;
  wire m_fifo_rst;
  wire rresp_fifo_clk;
  wire rresp_fifo_wrclk;
  wire rresp_fifo_rdclk;
  wire rresp_fifo_rst;
  wire s_sample_cycle;
  wire s_sample_cycle_early;
  wire m_sample_cycle;
  wire m_sample_cycle_early;
  wire fast_aclk;
  reg  reset_r;
  reg  s_reset_r;
  reg  m_reset_r;
  reg  fast_aresetn_r;
  reg  fast_reset_r;
  
  function integer f_ceil_log2
    (
     input integer x
     );
    integer acc;
    begin
      acc=0;
      while ((2**acc) < x)
        acc = acc + 1;
      f_ceil_log2 = acc;
    end
  endfunction

  // RAMB SI-side port address
  function [13:0] f_s_rbuf_addr
    (
      input [P_M_RBUFFER_BYTES_LOG-1:0] addr,
      input [2:0] size,
      input [1:0] burst,
      input [P_NUM_BUF_LOG-1:0] s_buf
    );
    reg [P_MAX_RBUFFER_BYTES_LOG-1:0] addr_i;
    reg [P_MAX_RBUFFER_BYTES_LOG-1:0] sparse_addr;
    begin
      if (burst == P_FIXED) begin
        sparse_addr = addr;
      end else begin
      addr_i = addr;
        case (P_MI_SIZE)
          3: case (size)
            3'h0:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : 3], addr_i[0:0], addr_i[2:0]};
            default: sparse_addr =  addr_i;
          endcase
          4: case (size)
            3'h0:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : 4], addr_i[1:0], addr_i[3:0]};
            3'h1:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : 4], addr_i[1:1], addr_i[3:0]};
            default: sparse_addr =  addr_i;
          endcase
          5: case (size)
            3'h0:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : 5], addr_i[2:0], addr_i[4:0]};
            3'h1:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : 5], addr_i[2:1], addr_i[4:0]};
            3'h2:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : 5], addr_i[2:2], addr_i[4:0]};
            default: sparse_addr =  addr_i;
          endcase
          6: case (size)
            3'h0:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : 6], addr_i[3:1], addr_i[5:0]};
            3'h1:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : 6], addr_i[3:1], addr_i[5:0]};
            3'h2:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : 6], addr_i[3:2], addr_i[5:0]};
            3'h3:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : 6], addr_i[3:3], addr_i[5:0]};
            default: sparse_addr =  addr_i;
          endcase
          7: case (size)
            3'h0:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : 7], addr_i[4:2], addr_i[6:0]};
            3'h1:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : 7], addr_i[4:2], addr_i[6:0]};
            3'h2:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : 7], addr_i[4:2], addr_i[6:0]};
            3'h3:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : 7], addr_i[4:3], addr_i[6:0]};
            3'h4:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : 7], addr_i[4:4], addr_i[6:0]};
            default: sparse_addr =  addr_i;
          endcase
        endcase
      end
      f_s_rbuf_addr = {s_buf, {14-P_NUM_BUF_LOG{1'b0}}};
      f_s_rbuf_addr[13-P_NUM_BUF_LOG : 5-P_RATIO_LOG] = sparse_addr[P_SI_SIZE +: 9+P_RATIO_LOG-P_NUM_BUF_LOG];
    end
  endfunction
 
  // RAMB MI-side port address
  function [13:0] f_m_rbuf_addr
    (
      input [P_M_RBUFFER_BYTES_LOG-1:0] addr,
      input [2:0] size,
      input [1:0] burst,
      input [P_NUM_BUF_LOG-1:0] m_buf
    );
    reg [P_MAX_RBUFFER_BYTES_LOG-1:0] addr_i;
    reg [P_MAX_RBUFFER_BYTES_LOG-1:0] sparse_addr;
    begin
      addr_i = addr;
      if (burst == P_FIXED) begin
        sparse_addr = addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : P_MI_SIZE];
      end else begin
        case (P_MI_SIZE)
          3: case (size)
            3'h0:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : P_MI_SIZE], addr_i[0:0]};
            default: sparse_addr =  addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : P_MI_SIZE];
          endcase
          4: case (size)
            3'h0:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : P_MI_SIZE], addr_i[1:0]};
            3'h1:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : P_MI_SIZE], addr_i[1:1]};
            default: sparse_addr =  addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : P_MI_SIZE];
          endcase
          5: case (size)
            3'h0:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : P_MI_SIZE], addr_i[2:0]};
            3'h1:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : P_MI_SIZE], addr_i[2:1]};
            3'h2:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : P_MI_SIZE], addr_i[2:2]};
            default: sparse_addr =  addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : P_MI_SIZE];
          endcase
          6: case (size)
            3'h0:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : P_MI_SIZE], addr_i[3:1]};
            3'h1:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : P_MI_SIZE], addr_i[3:1]};
            3'h2:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : P_MI_SIZE], addr_i[3:2]};
            3'h3:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : P_MI_SIZE], addr_i[3:3]};
            default: sparse_addr =  addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : P_MI_SIZE];
          endcase
          7: case (size)
            3'h0:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : P_MI_SIZE], addr_i[4:2]};
            3'h1:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : P_MI_SIZE], addr_i[4:2]};
            3'h2:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : P_MI_SIZE], addr_i[4:2]};
            3'h3:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : P_MI_SIZE], addr_i[4:3]};
            3'h4:    sparse_addr = {addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : P_MI_SIZE], addr_i[4:4]};
            default: sparse_addr =  addr_i[P_MAX_RBUFFER_BYTES_LOG-1 : P_MI_SIZE];
          endcase
        endcase
      end
      f_m_rbuf_addr = {m_buf, sparse_addr[0 +: 9-P_NUM_BUF_LOG], 5'b0};
    end
  endfunction
 
  // RAMB MI-side port write-enables
  function [3:0] f_m_rbuf_we
    (
      input [P_M_RBUFFER_BYTES_LOG-1:0] addr,
      input [2:0] size
    );
    reg [P_MAX_RBUFFER_BYTES_LOG-1:0] addr_i;
    begin
      addr_i = addr;
      case (P_MI_SIZE)
        3: case (size)
          3'h2:    f_m_rbuf_we = addr_i[2] ? 4'b1100 : 4'b0011;
          3'h3:    f_m_rbuf_we = 4'b1111;
          default: f_m_rbuf_we = 4'b0001 << addr_i[2:1];
        endcase
        4: case (size)
          3'h3:    f_m_rbuf_we = addr_i[3] ? 4'b1100 : 4'b0011;
          3'h4:    f_m_rbuf_we = 4'b1111;
          default: f_m_rbuf_we = 4'b0001 << addr_i[3:2];
        endcase
        5: case (size)
          3'h4:    f_m_rbuf_we = addr_i[4] ? 4'b1100 : 4'b0011;
          3'h5:    f_m_rbuf_we = 4'b1111;
          default: f_m_rbuf_we = 4'b0001 << addr_i[4:3];
        endcase
        6: case (size)
          3'h5:    f_m_rbuf_we = addr_i[5] ? 4'b1100 : 4'b0011;
          3'h6:    f_m_rbuf_we = 4'b1111;
          default: f_m_rbuf_we = 4'b0001 << addr_i[5:4];
        endcase
        7: case (size)
          3'h6:    f_m_rbuf_we = addr_i[6] ? 4'b1100 : 4'b0011;
          3'h7:    f_m_rbuf_we = 4'b1111;
          default: f_m_rbuf_we = 4'b0001 << addr_i[6:5];
        endcase
      endcase
    end
  endfunction
 
  // RAMB MI-side write-enable mask for last beat of long unaligned INCR burst wrapping to 1st buffer addr.
  //   Only applies to full-size SI bursts when RATIO = 2 or 4.
  function [3:0] f_large_incr_mask
    (
      input [P_M_RBUFFER_BYTES_LOG-1:0] addr
    );
    reg [P_MAX_RBUFFER_BYTES_LOG-1:0] addr_i;
    reg [3:0] result;
    begin
      addr_i = addr;
      result = 4'b1111;
      case (P_MI_SIZE)
        3:         result = 4'b0011;
        4: case (P_SI_SIZE)
          3'h3:    result = 4'b0011;
          3'h2: case (addr_i[3:2])
            2'b01: result = 4'b0001;
            2'b10: result = 4'b0011;
            2'b11: result = 4'b0111;
          endcase
        endcase
        5: case (P_SI_SIZE)
          3'h4:    result = 4'b0011;
          3'h3: case (addr_i[4:3])
            2'b01: result = 4'b0001;
            2'b10: result = 4'b0011;
            2'b11: result = 4'b0111;
          endcase
        endcase
        6: case (P_SI_SIZE)
          3'h5:    result = 4'b0011;
          3'h4: case (addr_i[5:4])
            2'b01: result = 4'b0001;
            2'b10: result = 4'b0011;
            2'b11: result = 4'b0111;
          endcase
        endcase
        7: case (P_SI_SIZE)
          3'h6:    result = 4'b0011;
          3'h5: case (addr_i[6:5])
            2'b01: result = 4'b0001;
            2'b10: result = 4'b0011;
            2'b11: result = 4'b0111;
          endcase
        endcase
      endcase
      f_large_incr_mask = result;
    end
  endfunction
 
  // RAMB MI-side port-enables
  function [P_NUM_RAMB-1:0] f_m_rbuf_en
    (
      input [P_M_RBUFFER_BYTES_LOG-1:0] addr,
      input [2:0] size
    );
    reg [P_MAX_RBUFFER_BYTES_LOG-1:0] addr_i;
    begin
      addr_i = addr;
      case (P_MI_SIZE)
        6: case (size)
          3'h0:    f_m_rbuf_en = addr_i[0] ? 16'hFF00 : 16'h00FF;
          default: f_m_rbuf_en = 16'hFFFF;
        endcase
        7: case (size)
          3'h0: case (addr_i[1:0])
            2'b00: f_m_rbuf_en = 32'h000000FF;
            2'b01: f_m_rbuf_en = 32'h0000FF00;
            2'b10: f_m_rbuf_en = 32'h00FF0000;
            2'b11: f_m_rbuf_en = 32'hFF000000;
          endcase
          3'h1:    f_m_rbuf_en = addr_i[1] ? 32'hFFFF0000 : 32'h0000FFFF;
          default: f_m_rbuf_en = 32'hFFFFFFFF;
        endcase
        default:   f_m_rbuf_en = {P_NUM_RAMB{1'b1}};
      endcase
    end
  endfunction
 
  // SI-side buffer line fault detection
  function f_s_eol
    (
      input [P_MI_SIZE-1:0] addr,
      input [2:0] s_size,
      input [2:0] m_size
    );
    reg [7-1:0] addr_i;
    begin
      addr_i = addr;
      if (m_size == P_MI_SIZE) begin
        case (P_MI_SIZE)
          3: case (s_size)
            3'h0:    f_s_eol = &(addr_i[2:0]);
            3'h1:    f_s_eol = &(addr_i[2:1]);
            3'h2:    f_s_eol = &(addr_i[2:2]);
          endcase
          4: case (s_size)
            3'h0:    f_s_eol = &(addr_i[3:0]);
            3'h1:    f_s_eol = &(addr_i[3:1]);
            3'h2:    f_s_eol = &(addr_i[3:2]);
            3'h3:    f_s_eol = &(addr_i[3:3]);
          endcase
          5: case (s_size)
            3'h0:    f_s_eol = &(addr_i[4:0]);
            3'h1:    f_s_eol = &(addr_i[4:1]);
            3'h2:    f_s_eol = &(addr_i[4:2]);
            3'h3:    f_s_eol = &(addr_i[4:3]);
            3'h4:    f_s_eol = &(addr_i[4:4]);
          endcase
          6: case (s_size)
            3'h0:    f_s_eol = &(addr_i[5:0]);
            3'h1:    f_s_eol = &(addr_i[5:1]);
            3'h2:    f_s_eol = &(addr_i[5:2]);
            3'h3:    f_s_eol = &(addr_i[5:3]);
            3'h4:    f_s_eol = &(addr_i[5:4]);
            3'h5:    f_s_eol = &(addr_i[5:5]);
          endcase
          7: case (s_size)
            3'h0:    f_s_eol = &(addr_i[6:0]);
            3'h1:    f_s_eol = &(addr_i[6:1]);
            3'h2:    f_s_eol = &(addr_i[6:2]);
            3'h3:    f_s_eol = &(addr_i[6:3]);
            3'h4:    f_s_eol = &(addr_i[6:4]);
            3'h5:    f_s_eol = &(addr_i[6:5]);
            3'h6:    f_s_eol = &(addr_i[6:6]);
          endcase
        endcase
      end else begin
        // Assumes that AR transform is either fully-packed (m_size == P_MI_SIZE) or unpacked (m_size == s_size), no intermediate sizes.
        f_s_eol = 1'b1;
      end
    end
  endfunction
 
  // Number of SI transfers until wrapping (0 = wrap after first transfer; 4'hF = no wrapping)
  function [3:0] f_s_wrap_cnt
    (
      input [P_M_RBUFFER_BYTES_LOG-1:0] addr,
      input [2:0] size,
      input [7:0] len
    );
    reg [3:0] start;
    reg [P_MAX_RBUFFER_BYTES_LOG-1:0] addr_i;
    begin
      addr_i = addr;
      case (P_SI_SIZE)
        2: case (size[1:0])
          2'h0:    start = addr_i[ 0 +: 4];
          2'h1:    start = addr_i[ 1 +: 4];
          default: start = addr_i[ 2 +: 4];
        endcase
        3: case (size[1:0])
          2'h0:    start = addr_i[ 0 +: 4];
          2'h1:    start = addr_i[ 1 +: 4];
          2'h2:    start = addr_i[ 2 +: 4];
          default: start = addr_i[ 3 +: 4];
        endcase
        4: case (size)
          3'h0:    start = addr_i[ 0 +: 4];
          3'h1:    start = addr_i[ 1 +: 4];
          3'h2:    start = addr_i[ 2 +: 4];
          3'h3:    start = addr_i[ 3 +: 4];
          default: start = addr_i[ 4 +: 4];
        endcase
        5: case (size)
          3'h0:    start = addr_i[ 0 +: 4];
          3'h1:    start = addr_i[ 1 +: 4];
          3'h2:    start = addr_i[ 2 +: 4];
          3'h3:    start = addr_i[ 3 +: 4];
          3'h4:    start = addr_i[ 4 +: 4];
          default: start = addr_i[ 5 +: 4];
        endcase
        6: case (size)
          3'h0:    start = addr_i[ 0 +: 4];
          3'h1:    start = addr_i[ 1 +: 4];
          3'h2:    start = addr_i[ 2 +: 4];
          3'h3:    start = addr_i[ 3 +: 4];
          3'h4:    start = addr_i[ 4 +: 4];
          3'h5:    start = addr_i[ 5 +: 4];
          default: start = addr_i[ 6 +: 4];
        endcase
      endcase
      f_s_wrap_cnt = {len[3:1], 1'b1} & ~start;
    end
  endfunction
 
  // Number of MI transfers until wrapping (0 = wrap after first transfer; 4'hF = no wrapping)
  function [3:0] f_m_wrap_cnt
    (
      input [P_M_RBUFFER_BYTES_LOG-1:0] addr,
      input [2:0] size,
      input [7:0] len
    );
    reg [3:0] start;
    reg [P_MAX_RBUFFER_BYTES_LOG-1:0] addr_i;
    begin
      addr_i = addr;
      case (P_MI_SIZE)
        3: case (size)
          3'h0:    start = addr_i[ 0 +: 4];
          3'h1:    start = addr_i[ 1 +: 4];
          3'h2:    start = addr_i[ 2 +: 4];
          default: start = addr_i[ 3 +: 4];
        endcase
        4: case (size)
          3'h0:    start = addr_i[ 0 +: 4];
          3'h1:    start = addr_i[ 1 +: 4];
          3'h2:    start = addr_i[ 2 +: 4];
          3'h3:    start = addr_i[ 3 +: 4];
          default: start = addr_i[ 4 +: 4];
        endcase
        5: case (size)
          3'h0:    start = addr_i[ 0 +: 4];
          3'h1:    start = addr_i[ 1 +: 4];
          3'h2:    start = addr_i[ 2 +: 4];
          3'h3:    start = addr_i[ 3 +: 4];
          3'h4:    start = addr_i[ 4 +: 4];
          default: start = addr_i[ 5 +: 4];
        endcase
        6: case (size)
          3'h0:    start = addr_i[ 0 +: 4];
          3'h1:    start = addr_i[ 1 +: 4];
          3'h2:    start = addr_i[ 2 +: 4];
          3'h3:    start = addr_i[ 3 +: 4];
          3'h4:    start = addr_i[ 4 +: 4];
          3'h5:    start = addr_i[ 5 +: 4];
          default: start = addr_i[ 6 +: 4];
        endcase
        7: case (size)
          3'h0:    start = addr_i[ 0 +: 4];
          3'h1:    start = addr_i[ 1 +: 4];
          3'h2:    start = addr_i[ 2 +: 4];
          3'h3:    start = addr_i[ 3 +: 4];
          3'h4:    start = addr_i[ 4 +: 4];
          3'h5:    start = addr_i[ 5 +: 4];
          3'h6:    start = addr_i[ 6 +: 4];
          default: start = addr_i[ 7 +: 4];
        endcase
      endcase
      f_m_wrap_cnt = {len[3:1], 1'b1} & ~start;
    end
  endfunction
 
  // Mask of address bits used to point to first SI wrap transfer.
  function [P_M_RBUFFER_BYTES_LOG-1:0] f_s_wrap_mask
    (
      input [2:0] size,
      input [7:0] len
    );
    begin
      case (P_MI_SIZE)
        3: case (size)
          3'h0:    f_s_wrap_mask = {len[3:3], 3'b111    };
          3'h1:    f_s_wrap_mask = {len[3:2], 3'b110    };
          3'h2:    f_s_wrap_mask = {len[3:1], 3'b100    };
        endcase
        4: case (size)
          3'h0:    f_s_wrap_mask =            4'b1111    ;
          3'h1:    f_s_wrap_mask = {len[3:3], 4'b1110   };
          3'h2:    f_s_wrap_mask = {len[3:2], 4'b1100   };
          3'h3:    f_s_wrap_mask = {len[3:1], 4'b1000   };
        endcase
        5: case (size)
          3'h0:    f_s_wrap_mask =            5'b11111   ;
          3'h1:    f_s_wrap_mask =            5'b11110   ;
          3'h2:    f_s_wrap_mask = {len[3:3], 5'b11100  };
          3'h3:    f_s_wrap_mask = {len[3:2], 5'b11000  };
          3'h4:    f_s_wrap_mask = {len[3:1], 5'b10000  };
        endcase
        6: case (size)
          3'h0:    f_s_wrap_mask =            6'b111111  ;
          3'h1:    f_s_wrap_mask =            6'b111110  ;
          3'h2:    f_s_wrap_mask =            6'b111100  ;
          3'h3:    f_s_wrap_mask = {len[3:3], 6'b111000 };
          3'h4:    f_s_wrap_mask = {len[3:2], 6'b110000 };
          3'h5:    f_s_wrap_mask = {len[3:1], 6'b100000 };
        endcase
        7: case (size)
          3'h0:    f_s_wrap_mask =            7'b1111111 ;
          3'h1:    f_s_wrap_mask =            7'b1111110 ;
          3'h2:    f_s_wrap_mask =            7'b1111100 ;
          3'h3:    f_s_wrap_mask =            7'b1111000 ;
          3'h4:    f_s_wrap_mask = {len[3:3], 7'b1110000};
          3'h5:    f_s_wrap_mask = {len[3:2], 7'b1100000};
          3'h6:    f_s_wrap_mask = {len[3:1], 7'b1000000};
        endcase
      endcase
    end
  endfunction

  // Mask of address bits used to point to first MI wrap transfer.
  function [P_M_RBUFFER_BYTES_LOG-1:0] f_m_wrap_mask
    (
      input [2:0] size,
      input [7:0] len
    );
    begin
      case (P_MI_SIZE)
        3: case (size)
          3'h0:    f_m_wrap_mask = {len[3:3], 3'b111    };
          3'h1:    f_m_wrap_mask = {len[3:2], 3'b110    };
          3'h2:    f_m_wrap_mask = {len[3:1], 3'b100    };
          3'h3:    f_m_wrap_mask = {len[3:1], 4'b1000    };
        endcase
        4: case (size)                                   
          3'h0:    f_m_wrap_mask =            4'b1111     ;
          3'h1:    f_m_wrap_mask = {len[3:3], 4'b1110    };
          3'h2:    f_m_wrap_mask = {len[3:2], 4'b1100    };
          3'h3:    f_m_wrap_mask = {len[3:1], 4'b1000    };
          3'h4:    f_m_wrap_mask = {len[3:1], 5'b10000   };
        endcase                                          
        5: case (size)                                   
          3'h0:    f_m_wrap_mask =            5'b11111    ;
          3'h1:    f_m_wrap_mask =            5'b11110    ;
          3'h2:    f_m_wrap_mask = {len[3:3], 5'b11100   };
          3'h3:    f_m_wrap_mask = {len[3:2], 5'b11000   };
          3'h4:    f_m_wrap_mask = {len[3:1], 5'b10000   };
          3'h5:    f_m_wrap_mask = {len[3:1], 6'b100000  };
        endcase                                          
        6: case (size)                                   
          3'h0:    f_m_wrap_mask =            6'b111111   ;
          3'h1:    f_m_wrap_mask =            6'b111110   ;
          3'h2:    f_m_wrap_mask =            6'b111100   ;
          3'h3:    f_m_wrap_mask = {len[3:3], 6'b111000  };
          3'h4:    f_m_wrap_mask = {len[3:2], 6'b110000  };
          3'h5:    f_m_wrap_mask = {len[3:1], 6'b100000  };
          3'h6:    f_m_wrap_mask = {len[3:1], 7'b1000000 };
        endcase                                          
        7: case (size)                                   
          3'h0:    f_m_wrap_mask =            7'b1111111  ;
          3'h1:    f_m_wrap_mask =            7'b1111110  ;
          3'h2:    f_m_wrap_mask =            7'b1111100  ;
          3'h3:    f_m_wrap_mask =            7'b1111000  ;
          3'h4:    f_m_wrap_mask = {len[3:3], 7'b1110000 };
          3'h5:    f_m_wrap_mask = {len[3:2], 7'b1100000 };
          3'h6:    f_m_wrap_mask = {len[3:1], 7'b1000000 };
          3'h7:    f_m_wrap_mask = {len[3:1], 8'b10000000};
        endcase                                          
      endcase
    end
  endfunction

  // Address of SI transfer following wrap
  function [P_M_RBUFFER_BYTES_LOG-1:0] f_s_wrap_addr
    (
      input [P_M_RBUFFER_BYTES_LOG-1:0] addr,
      input [2:0] size,
      input [7:0] len
    );
    reg [P_M_RBUFFER_BYTES_LOG-1:0] mask;
    begin
      case (P_MI_SIZE)
        3: case (size)
          3'h0:    mask = {        ~len[2:1], 1'b0};
          3'h1:    mask = {        ~len[1:1], 2'b0};
          default: mask =                     3'b0 ;
        endcase
        4: case (size)
          3'h0:    mask = {        ~len[3:1], 1'b0};
          3'h1:    mask = {        ~len[2:1], 2'b0};
          3'h2:    mask = {        ~len[1:1], 3'b0};
          default: mask =                     4'b0 ;
        endcase
        5: case (size)
          3'h0:    mask = {1'b1  , ~len[3:1], 1'b0};
          3'h1:    mask = {        ~len[3:1], 2'b0};
          3'h2:    mask = {        ~len[2:1], 3'b0};
          3'h3:    mask = {        ~len[1:1], 4'b0};
          default: mask =                     5'b0 ;
        endcase
        6: case (size)
          3'h0:    mask = {2'b11 , ~len[3:1], 1'b0};
          3'h1:    mask = {1'b1  , ~len[3:1], 2'b0};
          3'h2:    mask = {        ~len[3:1], 3'b0};
          3'h3:    mask = {        ~len[2:1], 4'b0};
          3'h4:    mask = {        ~len[1:1], 5'b0};
          default: mask =                     6'b0 ;
        endcase
        7: case (size)
          3'h0:    mask = {3'b111, ~len[3:1], 1'b0};
          3'h1:    mask = {2'b11 , ~len[3:1], 2'b0};
          3'h2:    mask = {1'b1  , ~len[3:1], 3'b0};
          3'h3:    mask = {        ~len[3:1], 4'b0};
          3'h4:    mask = {        ~len[2:1], 5'b0};
          3'h5:    mask = {        ~len[1:1], 6'b0};
          default: mask =                     7'b0 ;
        endcase
      endcase
      f_s_wrap_addr = addr & mask;
    end
  endfunction
 
  // Address of MI transfer following wrap
  function [P_M_RBUFFER_BYTES_LOG-1:0] f_m_wrap_addr
    (
      input [P_M_RBUFFER_BYTES_LOG-1:0] addr,
      input [2:0] size,
      input [7:0] len
    );
    reg [P_M_RBUFFER_BYTES_LOG-1:0] mask;
    begin
      case (P_MI_SIZE)
        3: case (size)
          3'h0:    mask = {        ~len[2:1], 1'b0};
          3'h1:    mask = {        ~len[1:1], 2'b0};
          default: mask =                     3'b0 ;
        endcase
        4: case (size)
          3'h0:    mask = {        ~len[3:1], 1'b0};
          3'h1:    mask = {        ~len[2:1], 2'b0};
          3'h2:    mask = {        ~len[1:1], 3'b0};
          default: mask =                     4'b0 ;
        endcase
        5: case (size)
          3'h0:    mask = {1'b1  , ~len[3:1], 1'b0};
          3'h1:    mask = {        ~len[3:1], 2'b0};
          3'h2:    mask = {        ~len[2:1], 3'b0};
          3'h3:    mask = {        ~len[1:1], 4'b0};
          default: mask =                     5'b0 ;
        endcase
        6: case (size)
          3'h0:    mask = {2'b11 , ~len[3:1], 1'b0};
          3'h1:    mask = {1'b1  , ~len[3:1], 2'b0};
          3'h2:    mask = {        ~len[3:1], 3'b0};
          3'h3:    mask = {        ~len[2:1], 4'b0};
          3'h4:    mask = {        ~len[1:1], 5'b0};
          default: mask =                     6'b0 ;
        endcase
        7: case (size)
          3'h0:    mask = {3'b111, ~len[3:1], 1'b0};
          3'h1:    mask = {2'b11 , ~len[3:1], 2'b0};
          3'h2:    mask = {1'b1  , ~len[3:1], 3'b0};
          3'h3:    mask = {        ~len[3:1], 4'b0};
          3'h4:    mask = {        ~len[2:1], 5'b0};
          3'h5:    mask = {        ~len[1:1], 6'b0};
          default: mask =                     7'b0 ;
        endcase
      endcase
      f_m_wrap_addr = addr & mask;
    end
  endfunction
 
  // Mask of address bits used to point to first SI non-wrap transfer.
  function [P_M_RBUFFER_BYTES_LOG-1:0] f_s_size_mask
    (
      input [2:0] size
    );
    begin
      case (P_MI_SIZE)
        3: case (size)
          3'h0:    f_s_size_mask = 3'b111;
          3'h1:    f_s_size_mask = 3'b110;
          3'h2:    f_s_size_mask = 3'b100;
        endcase
        4: case (size)
          3'h0:    f_s_size_mask = 4'b1111;
          3'h1:    f_s_size_mask = 4'b1110;
          3'h2:    f_s_size_mask = 4'b1100;
          3'h3:    f_s_size_mask = 4'b1000;
        endcase
        5: case (size)
          3'h0:    f_s_size_mask = 5'b11111;
          3'h1:    f_s_size_mask = 5'b11110;
          3'h2:    f_s_size_mask = 5'b11100;
          3'h3:    f_s_size_mask = 5'b11000;
          3'h4:    f_s_size_mask = 5'b10000;
        endcase
        6: case (size)
          3'h0:    f_s_size_mask = 6'b111111;
          3'h1:    f_s_size_mask = 6'b111110;
          3'h2:    f_s_size_mask = 6'b111100;
          3'h3:    f_s_size_mask = 6'b111000;
          3'h4:    f_s_size_mask = 6'b110000;
          3'h5:    f_s_size_mask = 6'b100000;
        endcase
        7: case (size)
          3'h0:    f_s_size_mask = 7'b1111111;
          3'h1:    f_s_size_mask = 7'b1111110;
          3'h2:    f_s_size_mask = 7'b1111100;
          3'h3:    f_s_size_mask = 7'b1111000;
          3'h4:    f_s_size_mask = 7'b1110000;
          3'h5:    f_s_size_mask = 7'b1100000;
          3'h6:    f_s_size_mask = 7'b1000000;
        endcase
      endcase
    end
  endfunction

  // Mask of address bits used to point to first MI non-wrap transfer.
  function [P_M_RBUFFER_BYTES_LOG-1:0] f_m_size_mask
    (
      input [2:0] size
    );
    begin
      case (P_MI_SIZE)
        3: case (size)
          3'h0:    f_m_size_mask = 3'b111;
          3'h1:    f_m_size_mask = 3'b110;
          3'h2:    f_m_size_mask = 3'b100;
          3'h3:    f_m_size_mask = 3'b000;
        endcase
        4: case (size)
          3'h0:    f_m_size_mask = 4'b1111;
          3'h1:    f_m_size_mask = 4'b1110;
          3'h2:    f_m_size_mask = 4'b1100;
          3'h3:    f_m_size_mask = 4'b1000;
          3'h4:    f_m_size_mask = 4'b0000;
        endcase
        5: case (size)
          3'h0:    f_m_size_mask = 5'b11111;
          3'h1:    f_m_size_mask = 5'b11110;
          3'h2:    f_m_size_mask = 5'b11100;
          3'h3:    f_m_size_mask = 5'b11000;
          3'h4:    f_m_size_mask = 5'b10000;
          3'h5:    f_m_size_mask = 5'b00000;
        endcase
        6: case (size)
          3'h0:    f_m_size_mask = 6'b111111;
          3'h1:    f_m_size_mask = 6'b111110;
          3'h2:    f_m_size_mask = 6'b111100;
          3'h3:    f_m_size_mask = 6'b111000;
          3'h4:    f_m_size_mask = 6'b110000;
          3'h5:    f_m_size_mask = 6'b100000;
          3'h6:    f_m_size_mask = 6'b000000;
        endcase
        7: case (size)
          3'h0:    f_m_size_mask = 7'b1111111;
          3'h1:    f_m_size_mask = 7'b1111110;
          3'h2:    f_m_size_mask = 7'b1111100;
          3'h3:    f_m_size_mask = 7'b1111000;
          3'h4:    f_m_size_mask = 7'b1110000;
          3'h5:    f_m_size_mask = 7'b1100000;
          3'h6:    f_m_size_mask = 7'b1000000;
          3'h7:    f_m_size_mask = 7'b0000000;
        endcase
      endcase
    end
  endfunction

  // Address increment for SI non-wrap transfer.
  function [P_M_RBUFFER_BYTES_LOG-1:0] f_s_size_incr
    (
      input [2:0] size
    );
    begin
      case (P_SI_SIZE)
        2: case (size[1:0])
          2'h0:    f_s_size_incr = 4'b001;
          2'h1:    f_s_size_incr = 4'b010;
          2'h2:    f_s_size_incr = 4'b100;
        endcase
        3: case (size[1:0])
          2'h0:    f_s_size_incr = 4'b0001;
          2'h1:    f_s_size_incr = 4'b0010;
          2'h2:    f_s_size_incr = 4'b0100;
          2'h3:    f_s_size_incr = 4'b1000;
        endcase
        4: case (size)
          3'h0:    f_s_size_incr = 5'b00001;
          3'h1:    f_s_size_incr = 5'b00010;
          3'h2:    f_s_size_incr = 5'b00100;
          3'h3:    f_s_size_incr = 5'b01000;
          3'h4:    f_s_size_incr = 5'b10000;
        endcase
        5: case (size)
          3'h0:    f_s_size_incr = 6'b000001;
          3'h1:    f_s_size_incr = 6'b000010;
          3'h2:    f_s_size_incr = 6'b000100;
          3'h3:    f_s_size_incr = 6'b001000;
          3'h4:    f_s_size_incr = 6'b010000;
          3'h5:    f_s_size_incr = 6'b100000;
        endcase
        6: case (size)
          3'h0:    f_s_size_incr = 7'b0000001;
          3'h1:    f_s_size_incr = 7'b0000010;
          3'h2:    f_s_size_incr = 7'b0000100;
          3'h3:    f_s_size_incr = 7'b0001000;
          3'h4:    f_s_size_incr = 7'b0010000;
          3'h5:    f_s_size_incr = 7'b0100000;
          3'h6:    f_s_size_incr = 7'b1000000;
        endcase
      endcase
    end
  endfunction

  // Address increment for MI non-wrap transfer.
  function [P_M_RBUFFER_BYTES_LOG-1:0] f_m_size_incr
    (
      input [2:0] size
    );
    begin
      case (P_MI_SIZE)
        3: case (size)
          3'h0:    f_m_size_incr = 4'b0001;
          3'h1:    f_m_size_incr = 4'b0010;
          3'h2:    f_m_size_incr = 4'b0100;
          3'h3:    f_m_size_incr = 4'b1000;
        endcase
        4: case (size)
          3'h0:    f_m_size_incr = 5'b00001;
          3'h1:    f_m_size_incr = 5'b00010;
          3'h2:    f_m_size_incr = 5'b00100;
          3'h3:    f_m_size_incr = 5'b01000;
          3'h4:    f_m_size_incr = 5'b10000;
        endcase
        5: case (size)
          3'h0:    f_m_size_incr = 6'b000001;
          3'h1:    f_m_size_incr = 6'b000010;
          3'h2:    f_m_size_incr = 6'b000100;
          3'h3:    f_m_size_incr = 6'b001000;
          3'h4:    f_m_size_incr = 6'b010000;
          3'h5:    f_m_size_incr = 6'b100000;
        endcase
        6: case (size)
          3'h0:    f_m_size_incr = 7'b0000001;
          3'h1:    f_m_size_incr = 7'b0000010;
          3'h2:    f_m_size_incr = 7'b0000100;
          3'h3:    f_m_size_incr = 7'b0001000;
          3'h4:    f_m_size_incr = 7'b0010000;
          3'h5:    f_m_size_incr = 7'b0100000;
          3'h6:    f_m_size_incr = 7'b1000000;
        endcase
        7: case (size)
          3'h0:    f_m_size_incr = 8'b00000001;
          3'h1:    f_m_size_incr = 8'b00000010;
          3'h2:    f_m_size_incr = 8'b00000100;
          3'h3:    f_m_size_incr = 8'b00001000;
          3'h4:    f_m_size_incr = 8'b00010000;
          3'h5:    f_m_size_incr = 8'b00100000;
          3'h6:    f_m_size_incr = 8'b01000000;
          3'h7:    f_m_size_incr = 8'b10000000;
        endcase
      endcase
    end
  endfunction

  generate
  
  if (C_CLK_CONV) begin : gen_clock_conv
    if (C_AXI_IS_ACLK_ASYNC) begin : gen_async_conv

      assign m_aclk = M_AXI_ACLK;
      assign m_aresetn = M_AXI_ARESETN;
      assign s_aresetn = S_AXI_ARESETN;
      assign ar_fifo_s_aclk = S_AXI_ACLK;
      assign ar_fifo_m_aclk = M_AXI_ACLK;
      assign ar_fifo_aresetn = S_AXI_ARESETN & M_AXI_ARESETN;
      assign s_fifo_rst = ~S_AXI_ARESETN;
      assign m_fifo_rst = ~M_AXI_ARESETN;
      assign rresp_fifo_clk = 1'b0;
      assign rresp_fifo_wrclk = M_AXI_ACLK;
      assign rresp_fifo_rdclk = S_AXI_ACLK;
      assign rresp_fifo_rst = ~S_AXI_ARESETN | ~M_AXI_ARESETN;
      assign s_sample_cycle_early = 1'b1;
      assign s_sample_cycle       = 1'b1;
      assign m_sample_cycle_early = 1'b1;
      assign m_sample_cycle       = 1'b1;
      
    end else begin : gen_sync_conv
    
      if (P_SI_LT_MI) begin : gen_fastclk_mi
        assign fast_aclk = M_AXI_ACLK;
      end else begin : gen_fastclk_si
        assign fast_aclk = S_AXI_ACLK;
      end
    
      assign m_aclk = M_AXI_ACLK;
      assign m_aresetn = fast_aresetn_r;
      assign s_aresetn = fast_aresetn_r;
      assign ar_fifo_s_aclk = fast_aclk;
      assign ar_fifo_m_aclk = 1'b0;
      assign ar_fifo_aresetn = fast_aresetn_r;
      assign s_fifo_rst = fast_reset_r;
      assign m_fifo_rst = fast_reset_r;
      assign rresp_fifo_clk = fast_aclk;
      assign rresp_fifo_wrclk = 1'b0;
      assign rresp_fifo_rdclk = 1'b0;
      assign rresp_fifo_rst = fast_reset_r;
      assign s_sample_cycle_early = P_SI_LT_MI ? 1'b1 : SAMPLE_CYCLE_EARLY;
      assign s_sample_cycle       = P_SI_LT_MI ? 1'b1 : SAMPLE_CYCLE;
      assign m_sample_cycle_early = P_SI_LT_MI ? SAMPLE_CYCLE_EARLY : 1'b1;
      assign m_sample_cycle       = P_SI_LT_MI ? SAMPLE_CYCLE : 1'b1;
  
      always @(posedge fast_aclk) begin
        if (~S_AXI_ARESETN | ~M_AXI_ARESETN) begin
          fast_aresetn_r <= 1'b0;
          fast_reset_r <= 1'b1;
        end else if (S_AXI_ARESETN & M_AXI_ARESETN & SAMPLE_CYCLE_EARLY) begin
          fast_aresetn_r <= 1'b1;
          fast_reset_r <= 1'b0;
        end
      end
    end
  
  end else begin : gen_no_clk_conv
    
    assign m_aclk = S_AXI_ACLK;
    assign m_aresetn = S_AXI_ARESETN;
    assign s_aresetn = S_AXI_ARESETN;
    assign ar_fifo_s_aclk = S_AXI_ACLK;
    assign ar_fifo_m_aclk = 1'b0;
    assign ar_fifo_aresetn = S_AXI_ARESETN;
    assign s_fifo_rst = reset_r;
    assign m_fifo_rst = reset_r;
    assign rresp_fifo_clk = S_AXI_ACLK;
    assign rresp_fifo_wrclk = 1'b0;
    assign rresp_fifo_rdclk = 1'b0;
    assign rresp_fifo_rst = reset_r;
    assign fast_aclk = S_AXI_ACLK;
    assign s_sample_cycle_early = 1'b1;
    assign s_sample_cycle       = 1'b1;
    assign m_sample_cycle_early = 1'b1;
    assign m_sample_cycle       = 1'b1;
    
    always @(posedge S_AXI_ACLK) begin
      reset_r <= ~S_AXI_ARESETN;
    end
  
  end
  
  for (i=0; i<P_NUM_RAMB; i=i+1) begin : gen_rdata
    for (j=0; j<32; j=j+1) begin : gen_m_rdata
      assign m_rdata[i*32+j] = M_AXI_RDATA[j*P_NUM_RAMB+i];
    end
    for (j=0; j<P_S_RAMB_WIDTH; j=j+1) begin : gen_s_rdata
      assign S_AXI_RDATA[j*P_NUM_RAMB+i] = s_rdata[i*16+j];
    end
  end  // gen_rdata
  
  assign S_AXI_ARREADY = S_AXI_ARREADY_i;
  assign S_AXI_RVALID = s_rvalid_d2;
  assign S_AXI_RRESP = s_rresp_d2;
  assign S_AXI_RLAST = s_rlast_d2;
  assign S_AXI_RID    = s_id_d2;
  assign s_rbuf_en = ~s_rvalid_d2 | S_AXI_RREADY;
  assign buf_limit = buf_cnt == P_BUF_LIMIT;
  assign s_cmd_pop = (s_rbuf_en | ~s_rvalid) & (s_rcnt == 0) & ~s_cmd_empty & ~rresp_fifo_empty & ~s_rresp_fifo_stall;
  assign s_eol = f_s_eol(s_raddr, s_rsize, s_conv_size) | (s_rburst == P_FIXED);
  assign rresp_fifo_pop = (s_rbuf_en | ~s_rvalid) & (((s_rcnt == 0) ? ~s_cmd_empty : (s_eol & ~rresp_wrap)) | s_rresp_fifo_stall) &
           ~rresp_fifo_empty & m_sample_cycle;  // Sample strobe when RRESP FIFO is on faster M_AXI_ACLK.
  assign rresp_reuse = (s_rbuf_en | ~s_rvalid) & s_eol & rresp_wrap;
  assign ar_push = S_AXI_ARVALID & S_AXI_ARREADY_i & m_sample_cycle;  // Sample strobe when AR FIFO is on faster M_AXI_ACLK.
  assign s_cmd_push = S_AXI_ARVALID & S_AXI_ARREADY_i;
  assign s_ar_cmd = {cmd_si_addr[0 +: P_MI_SIZE+4], cmd_si_id, S_AXI_ARLEN[3:0], S_AXI_ARSIZE, cmd_si_len, cmd_si_size, cmd_si_burst};
  assign s_cmd_addr = s_r_cmd[(20+C_AXI_ID_WIDTH) +: P_MI_SIZE+4];
  assign s_cmd_id = s_r_cmd[20 +: C_AXI_ID_WIDTH];
  assign s_cmd_conv_len = s_r_cmd[16 +: 4];
  assign s_cmd_conv_size = s_r_cmd[13 +: 3];
  assign s_cmd_len = s_r_cmd[5 +: 8];
  assign s_cmd_size = s_r_cmd[2 +: 3];
  assign s_cmd_burst = s_r_cmd[0 +: 2];
  assign s_rbuf_addr = f_s_rbuf_addr(s_raddr, s_conv_size, s_rburst, s_buf);
  assign s_rresp = s_rresp_i[1:0];
 
  always @(posedge S_AXI_ACLK) begin
    if (~s_aresetn) begin
      S_AXI_ARREADY_i <= 1'b0;
      buf_cnt <= 0;
    end else begin
      if (ar_push) begin
        S_AXI_ARREADY_i <= 1'b0;
      end else if (ar_fifo_ready & ~s_cmd_full & ~buf_limit) begin
        S_AXI_ARREADY_i <= 1'b1;  // pre-assert READY
      end
      if (s_cmd_push & ~s_cmd_pop) begin
        buf_cnt <= buf_cnt + 1;
      end else if (~s_cmd_push & s_cmd_pop & (buf_cnt != 0)) begin
        buf_cnt <= buf_cnt - 1;
      end
    end
  end

  always @(posedge S_AXI_ACLK) begin
    if (~s_aresetn) begin
      s_rvalid <= 1'b0;
      s_rvalid_d1 <= 1'b0;
      s_rvalid_d2 <= 1'b0;
      first_rvalid_d1 <= 1'b0;
      s_rlast <= 1'b0;
      s_rlast_d1 <= 1'b0;
      s_rlast_d2 <= 1'b0;
      s_rcnt <= 0;
      s_buf <= 0;
      rresp_wrap <= 1'b0;
      s_rresp_fifo_stall <= 1'b0;
      s_rresp_d2 <= 2'b00;
      s_id_d2 <= {C_AXI_ID_WIDTH{1'b0}};
    end else begin
      if (s_rbuf_en) begin
        s_rvalid_d2 <= s_rvalid_d1;
        s_rvalid_d1 <= s_rvalid;
        s_rlast_d2 <= s_rlast_d1;
        s_rlast_d1 <= s_rlast;
        if (first_rvalid_d1) begin
          s_rresp_d2 <= s_rresp_d1;
          s_id_d2 <= s_id_d1;
        end
        if (s_rvalid) begin
          first_rvalid_d1 <= 1'b1;  // forever
        end
      end
      
      if (s_cmd_pop) begin
        s_rlast <= (s_cmd_len == 0);
      end else if (s_rvalid & s_rbuf_en & (s_rcnt != 0)) begin
        s_rlast <= (s_rcnt == 1);
      end

      if ((s_rcnt == 0) & ~s_rresp_fifo_stall) begin
        if (s_cmd_pop) begin
          s_rvalid <= 1'b1;
          s_rcnt <= s_cmd_len;
          rresp_wrap <= (s_cmd_burst == P_WRAP) & (s_cmd_conv_len == 0);
          s_buf <= s_buf + 1;
        end else if (s_rbuf_en) begin
          s_rvalid <= 1'b0;
        end
      end else begin
        if (s_rvalid & s_rbuf_en) begin
          s_rcnt <= s_rcnt - 1;
        end
        if ((s_eol & ~rresp_wrap) | s_rresp_fifo_stall) begin
          if (rresp_fifo_pop) begin
            rresp_wrap <= (s_rburst == P_WRAP) && (s_conv_len == 1);  // Last rresp pop of wrap burst
            s_rvalid <= 1'b1;
            s_rresp_fifo_stall <= 1'b0;
          end else if (s_rbuf_en) begin
            s_rvalid <= 1'b0;
            s_rresp_fifo_stall <= 1'b1;
          end
        end
      end
    end
  end

  always @(posedge S_AXI_ACLK) begin
    if (s_rbuf_en) begin
      s_rresp_d1 <= s_rresp_reg;
      s_id_d1 <= s_id_reg;
    end
    if (s_cmd_pop) begin
      if (s_cmd_burst == P_WRAP) begin
        s_raddr <= s_cmd_addr & f_s_wrap_mask(s_cmd_size, s_cmd_len);
      end else begin
        s_raddr <= s_cmd_addr & f_s_size_mask(s_cmd_size);
      end
      s_rsize <= s_cmd_size;
      s_rburst <= s_cmd_burst;
      s_id_reg <= s_cmd_id;
      s_wrap_cnt <= f_s_wrap_cnt(s_cmd_addr, s_cmd_size, s_cmd_len);
      s_wrap_addr <= f_s_wrap_addr(s_cmd_addr, s_cmd_size, s_cmd_len);
      s_conv_size <= s_cmd_conv_size;
      s_conv_len <= s_cmd_conv_len;  // MI len to count wrap beats for rresp reuse.
      s_rresp_first <= s_rresp;  // Save first beat of wrap burst.
    end else if (s_rvalid & s_rbuf_en & (s_rcnt != 0)) begin
      if ((s_rburst == P_WRAP) && (s_wrap_cnt == 0)) begin
        s_raddr <= s_wrap_addr;
      end else if (s_rburst == P_FIXED) begin
        s_raddr <= s_raddr + P_MI_BYTES;
      end else begin
        s_raddr <= s_raddr + f_s_size_incr(s_rsize);
      end
      s_wrap_cnt <= s_wrap_cnt - 1;
    end
    if (rresp_fifo_pop) begin
      s_rresp_reg <= s_rresp;
      if (~s_cmd_pop) begin
        s_conv_len <= s_conv_len - 1;  // Count rresp pops during wrap burst
      end
    end else if (rresp_reuse) begin  // SI wrap revisits first buffer line; reuse firt rresp.
      s_rresp_reg <= s_rresp_first;
    end
  end
  
  assign M_AXI_ARADDR = M_AXI_ARADDR_i;
  assign M_AXI_ARLEN = M_AXI_ARLEN_i;
  assign M_AXI_ARSIZE = M_AXI_ARSIZE_i;
  assign M_AXI_ARBURST = M_AXI_ARBURST_i;
  assign M_AXI_ARLOCK = {1'b0,M_AXI_ARLOCK_i};
  assign M_AXI_ARVALID = M_AXI_ARVALID_i;
  assign M_AXI_RREADY = M_AXI_RREADY_i;
  assign ar_pop = M_AXI_ARVALID_i & M_AXI_ARREADY & s_sample_cycle;  // Sample strobe when AR FIFO is on faster S_AXI_ACLK.
  assign m_cmd_push = M_AXI_ARVALID_i & M_AXI_ARREADY;
  assign m_transfer = M_AXI_RREADY_i & M_AXI_RVALID;
  assign rresp_fifo_push = (m_transfer | m_rresp_fifo_stall) & ~rresp_fifo_full & s_sample_cycle;  // Sample strobe when RRESP FIFO is on faster S_AXI_ACLK.
  assign m_cmd_pop = ((m_transfer & M_AXI_RLAST) | (~m_cmd_valid & ~rresp_fifo_full)) & ~m_cmd_empty;
  assign m_rresp = m_rresp_fifo_stall ? m_rresp_reg : M_AXI_RRESP;
  assign m_rresp_i = {2'b0, m_rresp};
  assign m_ar_cmd = {M_AXI_ARADDR_i[0 +: P_MI_SIZE+4], M_AXI_ARLEN_i, M_AXI_ARSIZE_i, M_AXI_ARBURST_i};
  assign m_cmd_addr = m_r_cmd[13 +: P_MI_SIZE+4];
  assign m_cmd_len = m_r_cmd[5 +: 8];
  assign m_cmd_size = m_r_cmd[2 +: 3];
  assign m_cmd_burst = m_r_cmd[0 +: 2];
  assign m_rbuf_addr = f_m_rbuf_addr(m_raddr, m_rsize, m_rburst, m_buf);
  assign m_rbuf_we = (large_incr_last ? large_incr_mask : 4'b1111) & f_m_rbuf_we(m_raddr, m_rsize);
  assign m_rbuf_en = f_m_rbuf_en(m_raddr, m_rsize) & {P_NUM_RAMB{m_transfer}};
  assign m_raddr_incr = m_raddr + f_m_size_incr(m_rsize);
  
  always @(posedge m_aclk) begin
    if (~m_aresetn) begin
      M_AXI_ARVALID_i <= 1'b0;
    end else begin
      if (ar_pop) begin
        M_AXI_ARVALID_i <= 1'b0;
      end else if (ar_fifo_valid & ~m_cmd_full) begin
        M_AXI_ARVALID_i <= 1'b1;
      end
    end
  end

  always @(posedge m_aclk) begin
    if (~m_aresetn) begin
      m_buf <= 0;
      M_AXI_RREADY_i <= 1'b0;
      m_cmd_valid <= 1'b0;
      m_rresp_fifo_stall <= 1'b0;
    end else begin
      if (M_AXI_RREADY_i) begin
        if (M_AXI_RVALID) begin
          m_rresp_reg <= M_AXI_RRESP;
          if (rresp_fifo_full) begin
            M_AXI_RREADY_i <= 1'b0;
            m_rresp_fifo_stall <= 1'b1;
          end
          if (M_AXI_RLAST & m_cmd_empty) begin
            M_AXI_RREADY_i <= 1'b0;
            m_cmd_valid <= 1'b0;
          end
        end
      end else if (~rresp_fifo_full) begin
        m_rresp_fifo_stall <= 1'b0;
        if (m_cmd_valid) begin
          M_AXI_RREADY_i <= 1'b1;
        end else if (~m_cmd_empty) begin
          m_cmd_valid <= 1'b1;
          M_AXI_RREADY_i <= 1'b1;
        end
      end
      if (m_cmd_pop) begin
        m_buf <= m_buf + 1;
      end
    end
  end
  
  always @(posedge m_aclk) begin
    if (m_cmd_pop) begin
      if (m_cmd_burst == P_WRAP) begin
        m_raddr <= m_cmd_addr & f_m_wrap_mask(m_cmd_size, m_cmd_len);
      end else begin
        m_raddr <= m_cmd_addr & f_m_size_mask(m_cmd_size);
      end
      m_rsize <= m_cmd_size;
      m_rburst <= m_cmd_burst;
      m_wrap_cnt <= f_m_wrap_cnt(m_cmd_addr, m_cmd_size, m_cmd_len);
      m_wrap_addr <= f_m_wrap_addr(m_cmd_addr, m_cmd_size, m_cmd_len);
      large_incr_last <= 1'b0;
      large_incr_mask <= f_large_incr_mask(m_cmd_addr);
    end else if (m_transfer) begin
      if ((m_rburst == P_WRAP) && (m_wrap_cnt == 0)) begin
        m_raddr <= m_wrap_addr;
      end else if (m_rburst == P_FIXED) begin
        m_raddr <= m_raddr + P_MI_BYTES;
      end else begin
        if (~|m_raddr_incr) begin  // Addr pointer is about to wrap to zero?
          large_incr_last <= 1'b1;
        end
        m_raddr <= m_raddr_incr;
      end
      m_wrap_cnt <= m_wrap_cnt - 1;
    end
  end

  for (i=0; i<P_NUM_RAMB; i=i+1) begin : gen_ramb
    RAMB18E1 #(
      .READ_WIDTH_A(P_S_RAMB_PWIDTH),
      .WRITE_WIDTH_B(36),
      .RDADDR_COLLISION_HWCONFIG("PERFORMANCE"),
      .SIM_COLLISION_CHECK("NONE"),
      .DOA_REG(1),
      .DOB_REG(1),
      .RAM_MODE("SDP"),
      .READ_WIDTH_B(0),
      .WRITE_WIDTH_A(0),
      .RSTREG_PRIORITY_A("RSTREG"),
      .RSTREG_PRIORITY_B("RSTREG"),
      .SRVAL_A(18'h00000),
      .SRVAL_B(18'h00000),
      .SIM_DEVICE("7SERIES"),
      .WRITE_MODE_A("WRITE_FIRST"),
      .WRITE_MODE_B("WRITE_FIRST")
    ) ramb_inst (
      .DOADO(s_rdata[(i*16) +: 16]),
      .DIADI(m_rdata[(i*32) +: 16]),
      .DIBDI(m_rdata[(i*32+16) +: 16]),
      .WEBWE(m_rbuf_we),
      .ADDRARDADDR(s_rbuf_addr),
      .ADDRBWRADDR(m_rbuf_addr),
      .ENARDEN(s_rbuf_en),
      .REGCEAREGCE(s_rbuf_en),
      .ENBWREN(m_rbuf_en[i]),
      .CLKARDCLK(S_AXI_ACLK),
      .CLKBWRCLK(m_aclk),
      .RSTRAMARSTRAM(1'b0),
      .RSTREGARSTREG(1'b0),
      .WEA(2'b0),
      .DIPADIP(2'b0),
      .DIPBDIP(2'b0),
      .REGCEB(1'b1),
      .RSTRAMB(1'b0),
      .RSTREGB(1'b0),
      .DOBDO(),
      .DOPADOP(),
      .DOPBDOP()
    );   
  end 
    
  fifo_generator_v12_0 #(
    .C_FAMILY(C_FAMILY),
    .C_COMMON_CLOCK(P_COMMON_CLOCK),
    .C_MEMORY_TYPE(1),
    .C_SYNCHRONIZER_STAGE(C_SYNCHRONIZER_STAGE),
    .C_INTERFACE_TYPE(2),
    .C_AXI_TYPE(1),
    .C_HAS_AXI_ID(0),
    .C_AXI_LEN_WIDTH(8),
    .C_AXI_LOCK_WIDTH(1),
    .C_DIN_WIDTH_WACH(P_ARFIFO_WIDTH),
    .C_DIN_WIDTH_WDCH(37),
    .C_DIN_WIDTH_WRCH(2),
    .C_DIN_WIDTH_RACH(P_ARFIFO_WIDTH),
    .C_DIN_WIDTH_RDCH(35),
    .C_AXIS_TYPE(0),
    .C_HAS_AXI_WR_CHANNEL(0),
    .C_HAS_AXI_RD_CHANNEL(1),
    .C_AXI_ID_WIDTH(1),
    .C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
    .C_AXI_DATA_WIDTH(32),
    .C_HAS_AXI_AWUSER(0),
    .C_HAS_AXI_WUSER(0),
    .C_HAS_AXI_BUSER(0),
    .C_HAS_AXI_ARUSER(0),
    .C_HAS_AXI_RUSER(0),
    .C_AXI_ARUSER_WIDTH(1),
    .C_AXI_AWUSER_WIDTH(1),
    .C_AXI_WUSER_WIDTH(1),
    .C_AXI_BUSER_WIDTH(1),
    .C_AXI_RUSER_WIDTH(1),
    .C_WACH_TYPE(0),
    .C_WDCH_TYPE(0),
    .C_WRCH_TYPE(0),
    .C_RACH_TYPE(0),
    .C_RDCH_TYPE(2),
    .C_IMPLEMENTATION_TYPE_WACH(P_COMMON_CLOCK ? 2 : 12),
    .C_IMPLEMENTATION_TYPE_WDCH(P_COMMON_CLOCK ? 1 : 11),
    .C_IMPLEMENTATION_TYPE_WRCH(P_COMMON_CLOCK ? 2 : 12),
    .C_IMPLEMENTATION_TYPE_RACH(P_COMMON_CLOCK ? 2 : 12),
    .C_IMPLEMENTATION_TYPE_RDCH(P_COMMON_CLOCK ? 1 : 11),
    .C_IMPLEMENTATION_TYPE_AXIS(1),
    .C_DIN_WIDTH_AXIS(1),
    .C_WR_DEPTH_WACH(16),
    .C_WR_DEPTH_WDCH(1024),
    .C_WR_DEPTH_WRCH(16),
    .C_WR_DEPTH_RACH(32),
    .C_WR_DEPTH_RDCH(1024),
    .C_WR_DEPTH_AXIS(1024),
    .C_WR_PNTR_WIDTH_WACH(4),
    .C_WR_PNTR_WIDTH_WDCH(10),
    .C_WR_PNTR_WIDTH_WRCH(4),
    .C_WR_PNTR_WIDTH_RACH(5),
    .C_WR_PNTR_WIDTH_RDCH(10),
    .C_WR_PNTR_WIDTH_AXIS(10),
    .C_APPLICATION_TYPE_WACH(0),
    .C_APPLICATION_TYPE_WDCH(0),
    .C_APPLICATION_TYPE_WRCH(0),
    .C_APPLICATION_TYPE_RACH(P_COMMON_CLOCK ? 2 : 0),
    .C_APPLICATION_TYPE_RDCH(0),
    .C_APPLICATION_TYPE_AXIS(0),
    .C_USE_ECC_WACH(0),
    .C_USE_ECC_WDCH(0),
    .C_USE_ECC_WRCH(0),
    .C_USE_ECC_RACH(0),
    .C_USE_ECC_RDCH(0),
    .C_USE_ECC_AXIS(0),
    .C_ERROR_INJECTION_TYPE_WACH(0),
    .C_ERROR_INJECTION_TYPE_WDCH(0),
    .C_ERROR_INJECTION_TYPE_WRCH(0),
    .C_ERROR_INJECTION_TYPE_RACH(0),
    .C_ERROR_INJECTION_TYPE_RDCH(0),
    .C_ERROR_INJECTION_TYPE_AXIS(0),
    .C_HAS_DATA_COUNTS_WACH(0),
    .C_HAS_DATA_COUNTS_WDCH(0),
    .C_HAS_DATA_COUNTS_WRCH(0),
    .C_HAS_DATA_COUNTS_RACH(0),
    .C_HAS_DATA_COUNTS_RDCH(0),
    .C_HAS_DATA_COUNTS_AXIS(0),
    .C_HAS_PROG_FLAGS_WACH(0),
    .C_HAS_PROG_FLAGS_WDCH(0),
    .C_HAS_PROG_FLAGS_WRCH(0),
    .C_HAS_PROG_FLAGS_RACH(0),
    .C_HAS_PROG_FLAGS_RDCH(0),
    .C_HAS_PROG_FLAGS_AXIS(0),
    .C_PROG_FULL_TYPE_WACH(0),
    .C_PROG_FULL_TYPE_WDCH(0),
    .C_PROG_FULL_TYPE_WRCH(0),
    .C_PROG_FULL_TYPE_RACH(0),
    .C_PROG_FULL_TYPE_RDCH(0),
    .C_PROG_FULL_TYPE_AXIS(0),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WACH(31),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WDCH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WRCH(15),
    .C_PROG_FULL_THRESH_ASSERT_VAL_RACH(15),
    .C_PROG_FULL_THRESH_ASSERT_VAL_RDCH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_AXIS(1023),
    .C_PROG_EMPTY_TYPE_WACH(0),
    .C_PROG_EMPTY_TYPE_WDCH(0),
    .C_PROG_EMPTY_TYPE_WRCH(0),
    .C_PROG_EMPTY_TYPE_RACH(0),
    .C_PROG_EMPTY_TYPE_RDCH(0),
    .C_PROG_EMPTY_TYPE_AXIS(0),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH(30),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH(14),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH(14),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS(1022),
    .C_REG_SLICE_MODE_WACH(0),
    .C_REG_SLICE_MODE_WDCH(0),
    .C_REG_SLICE_MODE_WRCH(0),
    .C_REG_SLICE_MODE_RACH(0),
    .C_REG_SLICE_MODE_RDCH(0),
    .C_REG_SLICE_MODE_AXIS(0),
    .C_HAS_AXIS_TDATA(0),
    .C_HAS_AXIS_TID(0),
    .C_HAS_AXIS_TDEST(0),
    .C_HAS_AXIS_TUSER(0),
    .C_HAS_AXIS_TREADY(1),
    .C_HAS_AXIS_TLAST(0),
    .C_HAS_AXIS_TSTRB(0),
    .C_HAS_AXIS_TKEEP(0),
    .C_AXIS_TDATA_WIDTH(64),
    .C_AXIS_TID_WIDTH(8),
    .C_AXIS_TDEST_WIDTH(4),
    .C_AXIS_TUSER_WIDTH(4),
    .C_AXIS_TSTRB_WIDTH(4),
    .C_AXIS_TKEEP_WIDTH(4),
    .C_HAS_SLAVE_CE(0),
    .C_HAS_MASTER_CE(0),
    .C_ADD_NGC_CONSTRAINT(0),
    .C_USE_COMMON_OVERFLOW(0),
    .C_USE_COMMON_UNDERFLOW(0),
    .C_USE_DEFAULT_SETTINGS(0),
    .C_COUNT_TYPE(0),
    .C_DATA_COUNT_WIDTH(10),
    .C_DEFAULT_VALUE("BlankString"),
    .C_DIN_WIDTH(18),
    .C_DOUT_RST_VAL("0"),
    .C_DOUT_WIDTH(18),
    .C_ENABLE_RLOCS(0),
    .C_FULL_FLAGS_RST_VAL(1),
    .C_HAS_ALMOST_EMPTY(0),
    .C_HAS_ALMOST_FULL(0),
    .C_HAS_BACKUP(0),
    .C_HAS_DATA_COUNT(0),
    .C_HAS_INT_CLK(0),
    .C_HAS_MEMINIT_FILE(0),
    .C_HAS_OVERFLOW(0),
    .C_HAS_RD_DATA_COUNT(0),
    .C_HAS_RD_RST(0),
    .C_HAS_RST(1),
    .C_HAS_SRST(0),
    .C_HAS_UNDERFLOW(0),
    .C_HAS_VALID(0),
    .C_HAS_WR_ACK(0),
    .C_HAS_WR_DATA_COUNT(0),
    .C_HAS_WR_RST(0),
    .C_IMPLEMENTATION_TYPE(0),
    .C_INIT_WR_PNTR_VAL(0),
    .C_MIF_FILE_NAME("BlankString"),
    .C_OPTIMIZATION_MODE(0),
    .C_OVERFLOW_LOW(0),
    .C_PRELOAD_LATENCY(1),
    .C_PRELOAD_REGS(0),
    .C_PRIM_FIFO_TYPE("4kx4"),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL(2),
    .C_PROG_EMPTY_THRESH_NEGATE_VAL(3),
    .C_PROG_EMPTY_TYPE(0),
    .C_PROG_FULL_THRESH_ASSERT_VAL(1022),
    .C_PROG_FULL_THRESH_NEGATE_VAL(1021),
    .C_PROG_FULL_TYPE(0),
    .C_RD_DATA_COUNT_WIDTH(10),
    .C_RD_DEPTH(1024),
    .C_RD_FREQ(1),
    .C_RD_PNTR_WIDTH(10),
    .C_UNDERFLOW_LOW(0),
    .C_USE_DOUT_RST(1),
    .C_USE_ECC(0),
    .C_USE_EMBEDDED_REG(0),
    .C_USE_FIFO16_FLAGS(0),
    .C_USE_FWFT_DATA_COUNT(0),
    .C_VALID_LOW(0),
    .C_WR_ACK_LOW(0),
    .C_WR_DATA_COUNT_WIDTH(10),
    .C_WR_DEPTH(1024),
    .C_WR_FREQ(1),
    .C_WR_PNTR_WIDTH(10),
    .C_WR_RESPONSE_LATENCY(1),
    .C_MSGON_VAL(1),
    .C_ENABLE_RST_SYNC(1),
    .C_ERROR_INJECTION_TYPE(0)
  ) dw_fifogen_ar (
    .s_aclk(ar_fifo_s_aclk),
    .m_aclk(ar_fifo_m_aclk),
    .s_aresetn(ar_fifo_aresetn),
    .s_axi_arid     (1'b0),
    .s_axi_araddr   (S_AXI_ARADDR),  
    .s_axi_arlen    (S_AXI_ARLEN),   
    .s_axi_arsize   (S_AXI_ARSIZE),  
    .s_axi_arburst  (S_AXI_ARBURST), 
    .s_axi_arlock   (S_AXI_ARLOCK[0]),  
    .s_axi_arcache  (S_AXI_ARCACHE), 
    .s_axi_arprot   (S_AXI_ARPROT),  
    .s_axi_arqos    (S_AXI_ARQOS),
    .s_axi_arregion (S_AXI_ARREGION),   
    .s_axi_aruser   (1'b0),
    .s_axi_arvalid  (ar_push),
    .s_axi_arready  (ar_fifo_ready),
    .s_axi_rid(),
    .s_axi_rdata(),
    .s_axi_rresp(),
    .s_axi_rlast(),
    .s_axi_ruser(),
    .s_axi_rvalid(),
    .s_axi_rready(1'b0),
    .m_axi_arid      (),
    .m_axi_araddr    (M_AXI_ARADDR_i),
    .m_axi_arlen     (M_AXI_ARLEN_i),
    .m_axi_arsize    (M_AXI_ARSIZE_i),
    .m_axi_arburst   (M_AXI_ARBURST_i),
    .m_axi_arlock    (M_AXI_ARLOCK_i),
    .m_axi_arcache   (M_AXI_ARCACHE),
    .m_axi_arprot    (M_AXI_ARPROT),
    .m_axi_arqos     (M_AXI_ARQOS),
    .m_axi_arregion  (M_AXI_ARREGION),
    .m_axi_aruser    (),
    .m_axi_arvalid   (ar_fifo_valid),
    .m_axi_arready   (ar_pop),
    .m_axi_rid(1'b0),
    .m_axi_rdata(32'b0),
    .m_axi_rresp(2'b0),
    .m_axi_rlast(1'b0),
    .m_axi_ruser(1'b0),
    .m_axi_rvalid(1'b0),
    .m_axi_rready(),
    .s_axi_awid(1'b0),
    .s_axi_awaddr({C_AXI_ADDR_WIDTH{1'b0}}),
    .s_axi_awlen(8'b0),
    .s_axi_awsize(3'b0),
    .s_axi_awburst(2'b0),
    .s_axi_awlock(1'b0),
    .s_axi_awcache(4'b0),
    .s_axi_awprot(3'b0),
    .s_axi_awqos(4'b0),
    .s_axi_awregion(4'b0),
    .s_axi_awuser(1'b0),
    .s_axi_awvalid(1'b0),
    .s_axi_awready(),
    .s_axi_wid(1'b0),
    .s_axi_wdata(32'b0),
    .s_axi_wstrb(4'b0),
    .s_axi_wlast(1'b0),
    .s_axi_wuser(1'b0),
    .s_axi_wvalid(1'b0),
    .s_axi_wready(),
    .s_axi_bid(),
    .s_axi_bresp(),
    .s_axi_buser(),
    .s_axi_bvalid(),
    .s_axi_bready(1'b0),
    .m_axi_awid(),
    .m_axi_awaddr(),
    .m_axi_awlen(),
    .m_axi_awsize(),
    .m_axi_awburst(),
    .m_axi_awlock(),
    .m_axi_awcache(),
    .m_axi_awprot(),
    .m_axi_awqos(),
    .m_axi_awregion(),
    .m_axi_awuser(),
    .m_axi_awvalid(),
    .m_axi_awready(1'b0),
    .m_axi_wid(),
    .m_axi_wdata(),
    .m_axi_wstrb(),
    .m_axi_wuser(),
    .m_axi_wlast(),
    .m_axi_wvalid(),
    .m_axi_wready(1'b0),
    .m_axi_bid(1'b0),
    .m_axi_bresp(2'b0),
    .m_axi_buser(1'b0),
    .m_axi_bvalid(1'b0),
    .m_axi_bready(),
    .m_aclk_en(1'b0),
    .s_aclk_en(1'b0),
    .backup(1'b0),
    .backup_marker(1'b0),
    .clk(1'b0),
    .rst(1'b0),
    .srst(1'b0),
    .wr_clk(1'b0),
    .wr_rst(1'b0),
    .rd_clk(1'b0),
    .rd_rst(1'b0),
    .din(18'b0),
    .wr_en(1'b0),
    .rd_en(1'b0),
    .prog_empty_thresh(10'b0),
    .prog_empty_thresh_assert(10'b0),
    .prog_empty_thresh_negate(10'b0),
    .prog_full_thresh(10'b0),
    .prog_full_thresh_assert(10'b0),
    .prog_full_thresh_negate(10'b0),
    .int_clk(1'b0),
    .injectdbiterr(1'b0),
    .injectsbiterr(1'b0),
    .dout(),
    .full(),
    .almost_full(),
    .wr_ack(),
    .overflow(),
    .empty(),
    .almost_empty(),
    .valid(),
    .underflow(),
    .data_count(),
    .rd_data_count(),
    .wr_data_count(),
    .prog_full(),
    .prog_empty(),
    .sbiterr(),
    .dbiterr(),
    .s_axis_tvalid(1'b0),
    .s_axis_tready(),
    .s_axis_tdata(64'b0),
    .s_axis_tstrb(4'b0),
    .s_axis_tkeep(4'b0),
    .s_axis_tlast(1'b0),
    .s_axis_tid(8'b0),
    .s_axis_tdest(4'b0),
    .s_axis_tuser(4'b0),
    .m_axis_tvalid(),
    .m_axis_tready(1'b0),
    .m_axis_tdata(),
    .m_axis_tstrb(),
    .m_axis_tkeep(),
    .m_axis_tlast(),
    .m_axis_tid(),
    .m_axis_tdest(),
    .m_axis_tuser(),
    .axi_aw_injectsbiterr(1'b0),
    .axi_aw_injectdbiterr(1'b0),
    .axi_aw_prog_full_thresh(4'b0),
    .axi_aw_prog_empty_thresh(4'b0),
    .axi_aw_data_count(),
    .axi_aw_wr_data_count(),
    .axi_aw_rd_data_count(),
    .axi_aw_sbiterr(),
    .axi_aw_dbiterr(),
    .axi_aw_overflow(),
    .axi_aw_underflow(),
    .axi_aw_prog_full(),
    .axi_aw_prog_empty(),
    .axi_w_injectsbiterr(1'b0),
    .axi_w_injectdbiterr(1'b0),
    .axi_w_prog_full_thresh(10'b0),
    .axi_w_prog_empty_thresh(10'b0),
    .axi_w_data_count(),
    .axi_w_wr_data_count(),
    .axi_w_rd_data_count(),
    .axi_w_sbiterr(),
    .axi_w_dbiterr(),
    .axi_w_overflow(),
    .axi_w_underflow(),
    .axi_b_injectsbiterr(1'b0),
    .axi_w_prog_full(),
    .axi_w_prog_empty(),
    .axi_b_injectdbiterr(1'b0),
    .axi_b_prog_full_thresh(4'b0),
    .axi_b_prog_empty_thresh(4'b0),
    .axi_b_data_count(),
    .axi_b_wr_data_count(),
    .axi_b_rd_data_count(),
    .axi_b_sbiterr(),
    .axi_b_dbiterr(),
    .axi_b_overflow(),
    .axi_b_underflow(),
    .axi_ar_injectsbiterr(1'b0),
    .axi_b_prog_full(),
    .axi_b_prog_empty(),
    .axi_ar_injectdbiterr(1'b0),
    .axi_ar_prog_full_thresh(5'b0),
    .axi_ar_prog_empty_thresh(5'b0),
    .axi_ar_data_count(),
    .axi_ar_wr_data_count(),
    .axi_ar_rd_data_count(),
    .axi_ar_sbiterr(),
    .axi_ar_dbiterr(),
    .axi_ar_overflow(),
    .axi_ar_underflow(),
    .axi_ar_prog_full(),
    .axi_ar_prog_empty(),
    .axi_r_injectsbiterr(1'b0),
    .axi_r_injectdbiterr(1'b0),
    .axi_r_prog_full_thresh(10'b0),
    .axi_r_prog_empty_thresh(10'b0),
    .axi_r_data_count(),
    .axi_r_wr_data_count(),
    .axi_r_rd_data_count(),
    .axi_r_sbiterr(),
    .axi_r_dbiterr(),
    .axi_r_overflow(),
    .axi_r_underflow(),
    .axis_injectsbiterr(1'b0),
    .axi_r_prog_full(),
    .axi_r_prog_empty(),
    .axis_injectdbiterr(1'b0),
    .axis_prog_full_thresh(10'b0),
    .axis_prog_empty_thresh(10'b0),
    .axis_data_count(),
    .axis_wr_data_count(),
    .axis_rd_data_count(),
    .axis_sbiterr(),
    .axis_dbiterr(),
    .axis_overflow(),
    .axis_underflow(),
    .axis_prog_full(),
    .axis_prog_empty(),
    .wr_rst_busy(),
    .rd_rst_busy(),
    .sleep(1'b0)
  );
  
  fifo_generator_v12_0 #(
    .C_DIN_WIDTH(P_S_CMD_WIDTH),
    .C_DOUT_WIDTH(P_S_CMD_WIDTH),
    .C_RD_DEPTH(32),
    .C_RD_PNTR_WIDTH(5),
    .C_RD_DATA_COUNT_WIDTH(5),
    .C_WR_DEPTH(32),
    .C_WR_PNTR_WIDTH(5),
    .C_WR_DATA_COUNT_WIDTH(5),
    .C_DATA_COUNT_WIDTH(5),
    .C_COMMON_CLOCK(1),
    .C_COUNT_TYPE(0),
    .C_DEFAULT_VALUE("BlankString"),
    .C_DOUT_RST_VAL("0"),
    .C_ENABLE_RLOCS(0),
    .C_FAMILY(C_FAMILY),
    .C_FULL_FLAGS_RST_VAL(0),
    .C_HAS_ALMOST_EMPTY(0),
    .C_HAS_ALMOST_FULL(0),
    .C_HAS_BACKUP(0),
    .C_HAS_DATA_COUNT(0),
    .C_HAS_INT_CLK(0),
    .C_HAS_MEMINIT_FILE(0),
    .C_HAS_OVERFLOW(0),
    .C_HAS_RD_DATA_COUNT(0),
    .C_HAS_RD_RST(0),
    .C_HAS_RST(0),
    .C_HAS_SRST(1),
    .C_HAS_UNDERFLOW(0),
    .C_HAS_VALID(0),
    .C_HAS_WR_ACK(0),
    .C_HAS_WR_DATA_COUNT(0),
    .C_HAS_WR_RST(0),
    .C_IMPLEMENTATION_TYPE(0),
    .C_INIT_WR_PNTR_VAL(0),
    .C_MEMORY_TYPE(2),
    .C_MIF_FILE_NAME("BlankString"),
    .C_OPTIMIZATION_MODE(0),
    .C_OVERFLOW_LOW(0),
    .C_PRELOAD_LATENCY(0),
    .C_PRELOAD_REGS(1),
    .C_PRIM_FIFO_TYPE("512x36"),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL(4),
    .C_PROG_EMPTY_THRESH_NEGATE_VAL(5),
    .C_PROG_EMPTY_TYPE(0),
    .C_PROG_FULL_THRESH_ASSERT_VAL(31),
    .C_PROG_FULL_THRESH_NEGATE_VAL(30),
    .C_PROG_FULL_TYPE(0),
    .C_RD_FREQ(1),
    .C_UNDERFLOW_LOW(0),
    .C_USE_DOUT_RST(0),
    .C_USE_ECC(0),
    .C_USE_EMBEDDED_REG(0),
    .C_USE_FIFO16_FLAGS(0),
    .C_USE_FWFT_DATA_COUNT(1),
    .C_VALID_LOW(0),
    .C_WR_ACK_LOW(0),
    .C_WR_FREQ(1),
    .C_WR_RESPONSE_LATENCY(1),
    .C_MSGON_VAL(1),
    .C_ENABLE_RST_SYNC(1),
    .C_ERROR_INJECTION_TYPE(0),
    .C_SYNCHRONIZER_STAGE(C_SYNCHRONIZER_STAGE),
    .C_INTERFACE_TYPE(0),
    .C_AXI_TYPE(0),
    .C_HAS_AXI_WR_CHANNEL(0),
    .C_HAS_AXI_RD_CHANNEL(0),
    .C_HAS_SLAVE_CE(0),
    .C_HAS_MASTER_CE(0),
    .C_ADD_NGC_CONSTRAINT(0),
    .C_USE_COMMON_OVERFLOW(0),
    .C_USE_COMMON_UNDERFLOW(0),
    .C_USE_DEFAULT_SETTINGS(0),
    .C_AXI_ID_WIDTH(4),
    .C_AXI_ADDR_WIDTH(32),
    .C_AXI_DATA_WIDTH(64),
    .C_HAS_AXI_AWUSER(0),
    .C_HAS_AXI_WUSER(0),
    .C_HAS_AXI_BUSER(0),
    .C_HAS_AXI_ARUSER(0),
    .C_HAS_AXI_RUSER(0),
    .C_AXI_ARUSER_WIDTH(1),
    .C_AXI_AWUSER_WIDTH(1),
    .C_AXI_WUSER_WIDTH(1),
    .C_AXI_BUSER_WIDTH(1),
    .C_AXI_RUSER_WIDTH(1),
    .C_HAS_AXIS_TDATA(0),
    .C_HAS_AXIS_TID(0),
    .C_HAS_AXIS_TDEST(0),
    .C_HAS_AXIS_TUSER(0),
    .C_HAS_AXIS_TREADY(1),
    .C_HAS_AXIS_TLAST(0),
    .C_HAS_AXIS_TSTRB(0),
    .C_HAS_AXIS_TKEEP(0),
    .C_AXIS_TDATA_WIDTH(64),
    .C_AXIS_TID_WIDTH(8),
    .C_AXIS_TDEST_WIDTH(4),
    .C_AXIS_TUSER_WIDTH(4),
    .C_AXIS_TSTRB_WIDTH(4),
    .C_AXIS_TKEEP_WIDTH(4),
    .C_WACH_TYPE(0),
    .C_WDCH_TYPE(0),
    .C_WRCH_TYPE(0),
    .C_RACH_TYPE(0),
    .C_RDCH_TYPE(0),
    .C_AXIS_TYPE(0),
    .C_IMPLEMENTATION_TYPE_WACH(1),
    .C_IMPLEMENTATION_TYPE_WDCH(1),
    .C_IMPLEMENTATION_TYPE_WRCH(1),
    .C_IMPLEMENTATION_TYPE_RACH(1),
    .C_IMPLEMENTATION_TYPE_RDCH(1),
    .C_IMPLEMENTATION_TYPE_AXIS(1),
    .C_APPLICATION_TYPE_WACH(0),
    .C_APPLICATION_TYPE_WDCH(0),
    .C_APPLICATION_TYPE_WRCH(0),
    .C_APPLICATION_TYPE_RACH(0),
    .C_APPLICATION_TYPE_RDCH(0),
    .C_APPLICATION_TYPE_AXIS(0),
    .C_USE_ECC_WACH(0),
    .C_USE_ECC_WDCH(0),
    .C_USE_ECC_WRCH(0),
    .C_USE_ECC_RACH(0),
    .C_USE_ECC_RDCH(0),
    .C_USE_ECC_AXIS(0),
    .C_ERROR_INJECTION_TYPE_WACH(0),
    .C_ERROR_INJECTION_TYPE_WDCH(0),
    .C_ERROR_INJECTION_TYPE_WRCH(0),
    .C_ERROR_INJECTION_TYPE_RACH(0),
    .C_ERROR_INJECTION_TYPE_RDCH(0),
    .C_ERROR_INJECTION_TYPE_AXIS(0),
    .C_DIN_WIDTH_WACH(32),
    .C_DIN_WIDTH_WDCH(64),
    .C_DIN_WIDTH_WRCH(2),
    .C_DIN_WIDTH_RACH(32),
    .C_DIN_WIDTH_RDCH(64),
    .C_DIN_WIDTH_AXIS(1),
    .C_WR_DEPTH_WACH(16),
    .C_WR_DEPTH_WDCH(1024),
    .C_WR_DEPTH_WRCH(16),
    .C_WR_DEPTH_RACH(16),
    .C_WR_DEPTH_RDCH(1024),
    .C_WR_DEPTH_AXIS(1024),
    .C_WR_PNTR_WIDTH_WACH(4),
    .C_WR_PNTR_WIDTH_WDCH(10),
    .C_WR_PNTR_WIDTH_WRCH(4),
    .C_WR_PNTR_WIDTH_RACH(4),
    .C_WR_PNTR_WIDTH_RDCH(10),
    .C_WR_PNTR_WIDTH_AXIS(10),
    .C_HAS_DATA_COUNTS_WACH(0),
    .C_HAS_DATA_COUNTS_WDCH(0),
    .C_HAS_DATA_COUNTS_WRCH(0),
    .C_HAS_DATA_COUNTS_RACH(0),
    .C_HAS_DATA_COUNTS_RDCH(0),
    .C_HAS_DATA_COUNTS_AXIS(0),
    .C_HAS_PROG_FLAGS_WACH(0),
    .C_HAS_PROG_FLAGS_WDCH(0),
    .C_HAS_PROG_FLAGS_WRCH(0),
    .C_HAS_PROG_FLAGS_RACH(0),
    .C_HAS_PROG_FLAGS_RDCH(0),
    .C_HAS_PROG_FLAGS_AXIS(0),
    .C_PROG_FULL_TYPE_WACH(0),
    .C_PROG_FULL_TYPE_WDCH(0),
    .C_PROG_FULL_TYPE_WRCH(0),
    .C_PROG_FULL_TYPE_RACH(0),
    .C_PROG_FULL_TYPE_RDCH(0),
    .C_PROG_FULL_TYPE_AXIS(0),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WACH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WDCH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WRCH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_RACH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_RDCH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_AXIS(1023),
    .C_PROG_EMPTY_TYPE_WACH(0),
    .C_PROG_EMPTY_TYPE_WDCH(0),
    .C_PROG_EMPTY_TYPE_WRCH(0),
    .C_PROG_EMPTY_TYPE_RACH(0),
    .C_PROG_EMPTY_TYPE_RDCH(0),
    .C_PROG_EMPTY_TYPE_AXIS(0),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS(1022),
    .C_REG_SLICE_MODE_WACH(0),
    .C_REG_SLICE_MODE_WDCH(0),
    .C_REG_SLICE_MODE_WRCH(0),
    .C_REG_SLICE_MODE_RACH(0),
    .C_REG_SLICE_MODE_RDCH(0),
    .C_REG_SLICE_MODE_AXIS(0),
    .C_AXI_LEN_WIDTH(8),
    .C_AXI_LOCK_WIDTH(2)
  ) s_cmd_fifo (
    .clk(S_AXI_ACLK),
    .srst(s_fifo_rst),
    .din(s_ar_cmd),
    .dout(s_r_cmd),
    .full(s_cmd_full),
    .empty(s_cmd_empty),
    .wr_en(s_cmd_push),
    .rd_en(s_cmd_pop),
    .backup(1'b0),
    .backup_marker(1'b0),
    .rst(1'b0),
    .wr_clk(1'b0),
    .wr_rst(1'b0),
    .rd_clk(1'b0),
    .rd_rst(1'b0),
    .prog_empty_thresh(5'b0),
    .prog_empty_thresh_assert(5'b0),
    .prog_empty_thresh_negate(5'b0),
    .prog_full_thresh(5'b0),
    .prog_full_thresh_assert(5'b0),
    .prog_full_thresh_negate(5'b0),
    .int_clk(1'b0),
    .injectdbiterr(1'b0),
    .injectsbiterr(1'b0),
    .almost_full(),
    .wr_ack(),
    .overflow(),
    .almost_empty(),
    .valid(),
    .underflow(),
    .data_count(),
    .rd_data_count(),
    .wr_data_count(),
    .prog_full(),
    .prog_empty(),
    .sbiterr(),
    .dbiterr(),
    .m_aclk(1'b0),
    .s_aclk(1'b0),
    .s_aresetn(1'b0),
    .m_aclk_en(1'b0),
    .s_aclk_en(1'b0),
    .s_axi_awid(4'b0),
    .s_axi_awaddr(32'b0),
    .s_axi_awlen(8'b0),
    .s_axi_awsize(3'b0),
    .s_axi_awburst(2'b0),
    .s_axi_awlock(2'b0),
    .s_axi_awcache(4'b0),
    .s_axi_awprot(3'b0),
    .s_axi_awqos(4'b0),
    .s_axi_awregion(4'b0),
    .s_axi_awuser(1'b0),
    .s_axi_awvalid(1'b0),
    .s_axi_awready(),
    .s_axi_wid(4'b0),
    .s_axi_wdata(64'b0),
    .s_axi_wstrb(8'b0),
    .s_axi_wlast(1'b0),
    .s_axi_wuser(1'b0),
    .s_axi_wvalid(1'b0),
    .s_axi_wready(),
    .s_axi_bid(),
    .s_axi_bresp(),
    .s_axi_buser(),
    .s_axi_bvalid(),
    .s_axi_bready(1'b0),
    .m_axi_awid(),
    .m_axi_awaddr(),
    .m_axi_awlen(),
    .m_axi_awsize(),
    .m_axi_awburst(),
    .m_axi_awlock(),
    .m_axi_awcache(),
    .m_axi_awprot(),
    .m_axi_awqos(),
    .m_axi_awregion(),
    .m_axi_awuser(),
    .m_axi_awvalid(),
    .m_axi_awready(1'b0),
    .m_axi_wid(),
    .m_axi_wdata(),
    .m_axi_wstrb(),
    .m_axi_wlast(),
    .m_axi_wuser(),
    .m_axi_wvalid(),
    .m_axi_wready(1'b0),
    .m_axi_bid(4'b0),
    .m_axi_bresp(2'b0),
    .m_axi_buser(1'b0),
    .m_axi_bvalid(1'b0),
    .m_axi_bready(),
    .s_axi_arid(4'b0),
    .s_axi_araddr(32'b0),
    .s_axi_arlen(8'b0),
    .s_axi_arsize(3'b0),
    .s_axi_arburst(2'b0),
    .s_axi_arlock(2'b0),
    .s_axi_arcache(4'b0),
    .s_axi_arprot(3'b0),
    .s_axi_arqos(4'b0),
    .s_axi_arregion(4'b0),
    .s_axi_aruser(1'b0),
    .s_axi_arvalid(1'b0),
    .s_axi_arready(),
    .s_axi_rid(),
    .s_axi_rdata(),
    .s_axi_rresp(),
    .s_axi_rlast(),
    .s_axi_ruser(),
    .s_axi_rvalid(),
    .s_axi_rready(1'b0),
    .m_axi_arid(),
    .m_axi_araddr(),
    .m_axi_arlen(),
    .m_axi_arsize(),
    .m_axi_arburst(),
    .m_axi_arlock(),
    .m_axi_arcache(),
    .m_axi_arprot(),
    .m_axi_arqos(),
    .m_axi_arregion(),
    .m_axi_aruser(),
    .m_axi_arvalid(),
    .m_axi_arready(1'b0),
    .m_axi_rid(4'b0),
    .m_axi_rdata(64'b0),
    .m_axi_rresp(2'b0),
    .m_axi_rlast(1'b0),
    .m_axi_ruser(1'b0),
    .m_axi_rvalid(1'b0),
    .m_axi_rready(),
    .s_axis_tvalid(1'b0),
    .s_axis_tready(),
    .s_axis_tdata(64'b0),
    .s_axis_tstrb(4'b0),
    .s_axis_tkeep(4'b0),
    .s_axis_tlast(1'b0),
    .s_axis_tid(8'b0),
    .s_axis_tdest(4'b0),
    .s_axis_tuser(4'b0),
    .m_axis_tvalid(),
    .m_axis_tready(1'b0),
    .m_axis_tdata(),
    .m_axis_tstrb(),
    .m_axis_tkeep(),
    .m_axis_tlast(),
    .m_axis_tid(),
    .m_axis_tdest(),
    .m_axis_tuser(),
    .axi_aw_injectsbiterr(1'b0),
    .axi_aw_injectdbiterr(1'b0),
    .axi_aw_prog_full_thresh(4'b0),
    .axi_aw_prog_empty_thresh(4'b0),
    .axi_aw_data_count(),
    .axi_aw_wr_data_count(),
    .axi_aw_rd_data_count(),
    .axi_aw_sbiterr(),
    .axi_aw_dbiterr(),
    .axi_aw_overflow(),
    .axi_aw_underflow(),
    .axi_aw_prog_full(),
    .axi_aw_prog_empty(),
    .axi_w_injectsbiterr(1'b0),
    .axi_w_injectdbiterr(1'b0),
    .axi_w_prog_full_thresh(10'b0),
    .axi_w_prog_empty_thresh(10'b0),
    .axi_w_data_count(),
    .axi_w_wr_data_count(),
    .axi_w_rd_data_count(),
    .axi_w_sbiterr(),
    .axi_w_dbiterr(),
    .axi_w_overflow(),
    .axi_w_underflow(),
    .axi_b_injectsbiterr(1'b0),
    .axi_w_prog_full(),
    .axi_w_prog_empty(),
    .axi_b_injectdbiterr(1'b0),
    .axi_b_prog_full_thresh(4'b0),
    .axi_b_prog_empty_thresh(4'b0),
    .axi_b_data_count(),
    .axi_b_wr_data_count(),
    .axi_b_rd_data_count(),
    .axi_b_sbiterr(),
    .axi_b_dbiterr(),
    .axi_b_overflow(),
    .axi_b_underflow(),
    .axi_ar_injectsbiterr(1'b0),
    .axi_b_prog_full(),
    .axi_b_prog_empty(),
    .axi_ar_injectdbiterr(1'b0),
    .axi_ar_prog_full_thresh(4'b0),
    .axi_ar_prog_empty_thresh(4'b0),
    .axi_ar_data_count(),
    .axi_ar_wr_data_count(),
    .axi_ar_rd_data_count(),
    .axi_ar_sbiterr(),
    .axi_ar_dbiterr(),
    .axi_ar_overflow(),
    .axi_ar_underflow(),
    .axi_ar_prog_full(),
    .axi_ar_prog_empty(),
    .axi_r_injectsbiterr(1'b0),
    .axi_r_injectdbiterr(1'b0),
    .axi_r_prog_full_thresh(10'b0),
    .axi_r_prog_empty_thresh(10'b0),
    .axi_r_data_count(),
    .axi_r_wr_data_count(),
    .axi_r_rd_data_count(),
    .axi_r_sbiterr(),
    .axi_r_dbiterr(),
    .axi_r_overflow(),
    .axi_r_underflow(),
    .axis_injectsbiterr(1'b0),
    .axi_r_prog_full(),
    .axi_r_prog_empty(),
    .axis_injectdbiterr(1'b0),
    .axis_prog_full_thresh(10'b0),
    .axis_prog_empty_thresh(10'b0),
    .axis_data_count(),
    .axis_wr_data_count(),
    .axis_rd_data_count(),
    .axis_sbiterr(),
    .axis_dbiterr(),
    .axis_overflow(),
    .axis_underflow(),
    .axis_prog_full(),
    .axis_prog_empty(),
    .wr_rst_busy(),
    .rd_rst_busy(),
    .sleep(1'b0)
  );

  fifo_generator_v12_0 #(
    .C_DIN_WIDTH(P_M_CMD_WIDTH),
    .C_DOUT_WIDTH(P_M_CMD_WIDTH),
    .C_RD_DEPTH(32),
    .C_RD_PNTR_WIDTH(5),
    .C_RD_DATA_COUNT_WIDTH(5),
    .C_WR_DEPTH(32),
    .C_WR_PNTR_WIDTH(5),
    .C_WR_DATA_COUNT_WIDTH(5),
    .C_DATA_COUNT_WIDTH(5),
    .C_COMMON_CLOCK(1),
    .C_COUNT_TYPE(0),
    .C_DEFAULT_VALUE("BlankString"),
    .C_DOUT_RST_VAL("0"),
    .C_ENABLE_RLOCS(0),
    .C_FAMILY(C_FAMILY),
    .C_FULL_FLAGS_RST_VAL(0),
    .C_HAS_ALMOST_EMPTY(0),
    .C_HAS_ALMOST_FULL(0),
    .C_HAS_BACKUP(0),
    .C_HAS_DATA_COUNT(0),
    .C_HAS_INT_CLK(0),
    .C_HAS_MEMINIT_FILE(0),
    .C_HAS_OVERFLOW(0),
    .C_HAS_RD_DATA_COUNT(0),
    .C_HAS_RD_RST(0),
    .C_HAS_RST(0),
    .C_HAS_SRST(1),
    .C_HAS_UNDERFLOW(0),
    .C_HAS_VALID(0),
    .C_HAS_WR_ACK(0),
    .C_HAS_WR_DATA_COUNT(0),
    .C_HAS_WR_RST(0),
    .C_IMPLEMENTATION_TYPE(0),
    .C_INIT_WR_PNTR_VAL(0),
    .C_MEMORY_TYPE(2),
    .C_MIF_FILE_NAME("BlankString"),
    .C_OPTIMIZATION_MODE(0),
    .C_OVERFLOW_LOW(0),
    .C_PRELOAD_LATENCY(0),
    .C_PRELOAD_REGS(1),
    .C_PRIM_FIFO_TYPE("512x36"),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL(4),
    .C_PROG_EMPTY_THRESH_NEGATE_VAL(5),
    .C_PROG_EMPTY_TYPE(0),
    .C_PROG_FULL_THRESH_ASSERT_VAL(31),
    .C_PROG_FULL_THRESH_NEGATE_VAL(30),
    .C_PROG_FULL_TYPE(0),
    .C_RD_FREQ(1),
    .C_UNDERFLOW_LOW(0),
    .C_USE_DOUT_RST(0),
    .C_USE_ECC(0),
    .C_USE_EMBEDDED_REG(0),
    .C_USE_FIFO16_FLAGS(0),
    .C_USE_FWFT_DATA_COUNT(1),
    .C_VALID_LOW(0),
    .C_WR_ACK_LOW(0),
    .C_WR_FREQ(1),
    .C_WR_RESPONSE_LATENCY(1),
    .C_MSGON_VAL(1),
    .C_ENABLE_RST_SYNC(1),
    .C_ERROR_INJECTION_TYPE(0),
    .C_SYNCHRONIZER_STAGE(C_SYNCHRONIZER_STAGE),
    .C_INTERFACE_TYPE(0),
    .C_AXI_TYPE(0),
    .C_HAS_AXI_WR_CHANNEL(0),
    .C_HAS_AXI_RD_CHANNEL(0),
    .C_HAS_SLAVE_CE(0),
    .C_HAS_MASTER_CE(0),
    .C_ADD_NGC_CONSTRAINT(0),
    .C_USE_COMMON_OVERFLOW(0),
    .C_USE_COMMON_UNDERFLOW(0),
    .C_USE_DEFAULT_SETTINGS(0),
    .C_AXI_ID_WIDTH(4),
    .C_AXI_ADDR_WIDTH(32),
    .C_AXI_DATA_WIDTH(64),
    .C_HAS_AXI_AWUSER(0),
    .C_HAS_AXI_WUSER(0),
    .C_HAS_AXI_BUSER(0),
    .C_HAS_AXI_ARUSER(0),
    .C_HAS_AXI_RUSER(0),
    .C_AXI_ARUSER_WIDTH(1),
    .C_AXI_AWUSER_WIDTH(1),
    .C_AXI_WUSER_WIDTH(1),
    .C_AXI_BUSER_WIDTH(1),
    .C_AXI_RUSER_WIDTH(1),
    .C_HAS_AXIS_TDATA(0),
    .C_HAS_AXIS_TID(0),
    .C_HAS_AXIS_TDEST(0),
    .C_HAS_AXIS_TUSER(0),
    .C_HAS_AXIS_TREADY(1),
    .C_HAS_AXIS_TLAST(0),
    .C_HAS_AXIS_TSTRB(0),
    .C_HAS_AXIS_TKEEP(0),
    .C_AXIS_TDATA_WIDTH(64),
    .C_AXIS_TID_WIDTH(8),
    .C_AXIS_TDEST_WIDTH(4),
    .C_AXIS_TUSER_WIDTH(4),
    .C_AXIS_TSTRB_WIDTH(4),
    .C_AXIS_TKEEP_WIDTH(4),
    .C_WACH_TYPE(0),
    .C_WDCH_TYPE(0),
    .C_WRCH_TYPE(0),
    .C_RACH_TYPE(0),
    .C_RDCH_TYPE(0),
    .C_AXIS_TYPE(0),
    .C_IMPLEMENTATION_TYPE_WACH(1),
    .C_IMPLEMENTATION_TYPE_WDCH(1),
    .C_IMPLEMENTATION_TYPE_WRCH(1),
    .C_IMPLEMENTATION_TYPE_RACH(1),
    .C_IMPLEMENTATION_TYPE_RDCH(1),
    .C_IMPLEMENTATION_TYPE_AXIS(1),
    .C_APPLICATION_TYPE_WACH(0),
    .C_APPLICATION_TYPE_WDCH(0),
    .C_APPLICATION_TYPE_WRCH(0),
    .C_APPLICATION_TYPE_RACH(0),
    .C_APPLICATION_TYPE_RDCH(0),
    .C_APPLICATION_TYPE_AXIS(0),
    .C_USE_ECC_WACH(0),
    .C_USE_ECC_WDCH(0),
    .C_USE_ECC_WRCH(0),
    .C_USE_ECC_RACH(0),
    .C_USE_ECC_RDCH(0),
    .C_USE_ECC_AXIS(0),
    .C_ERROR_INJECTION_TYPE_WACH(0),
    .C_ERROR_INJECTION_TYPE_WDCH(0),
    .C_ERROR_INJECTION_TYPE_WRCH(0),
    .C_ERROR_INJECTION_TYPE_RACH(0),
    .C_ERROR_INJECTION_TYPE_RDCH(0),
    .C_ERROR_INJECTION_TYPE_AXIS(0),
    .C_DIN_WIDTH_WACH(32),
    .C_DIN_WIDTH_WDCH(64),
    .C_DIN_WIDTH_WRCH(2),
    .C_DIN_WIDTH_RACH(32),
    .C_DIN_WIDTH_RDCH(64),
    .C_DIN_WIDTH_AXIS(1),
    .C_WR_DEPTH_WACH(16),
    .C_WR_DEPTH_WDCH(1024),
    .C_WR_DEPTH_WRCH(16),
    .C_WR_DEPTH_RACH(16),
    .C_WR_DEPTH_RDCH(1024),
    .C_WR_DEPTH_AXIS(1024),
    .C_WR_PNTR_WIDTH_WACH(4),
    .C_WR_PNTR_WIDTH_WDCH(10),
    .C_WR_PNTR_WIDTH_WRCH(4),
    .C_WR_PNTR_WIDTH_RACH(4),
    .C_WR_PNTR_WIDTH_RDCH(10),
    .C_WR_PNTR_WIDTH_AXIS(10),
    .C_HAS_DATA_COUNTS_WACH(0),
    .C_HAS_DATA_COUNTS_WDCH(0),
    .C_HAS_DATA_COUNTS_WRCH(0),
    .C_HAS_DATA_COUNTS_RACH(0),
    .C_HAS_DATA_COUNTS_RDCH(0),
    .C_HAS_DATA_COUNTS_AXIS(0),
    .C_HAS_PROG_FLAGS_WACH(0),
    .C_HAS_PROG_FLAGS_WDCH(0),
    .C_HAS_PROG_FLAGS_WRCH(0),
    .C_HAS_PROG_FLAGS_RACH(0),
    .C_HAS_PROG_FLAGS_RDCH(0),
    .C_HAS_PROG_FLAGS_AXIS(0),
    .C_PROG_FULL_TYPE_WACH(0),
    .C_PROG_FULL_TYPE_WDCH(0),
    .C_PROG_FULL_TYPE_WRCH(0),
    .C_PROG_FULL_TYPE_RACH(0),
    .C_PROG_FULL_TYPE_RDCH(0),
    .C_PROG_FULL_TYPE_AXIS(0),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WACH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WDCH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WRCH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_RACH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_RDCH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_AXIS(1023),
    .C_PROG_EMPTY_TYPE_WACH(0),
    .C_PROG_EMPTY_TYPE_WDCH(0),
    .C_PROG_EMPTY_TYPE_WRCH(0),
    .C_PROG_EMPTY_TYPE_RACH(0),
    .C_PROG_EMPTY_TYPE_RDCH(0),
    .C_PROG_EMPTY_TYPE_AXIS(0),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS(1022),
    .C_REG_SLICE_MODE_WACH(0),
    .C_REG_SLICE_MODE_WDCH(0),
    .C_REG_SLICE_MODE_WRCH(0),
    .C_REG_SLICE_MODE_RACH(0),
    .C_REG_SLICE_MODE_RDCH(0),
    .C_REG_SLICE_MODE_AXIS(0),
    .C_AXI_LEN_WIDTH(8),
    .C_AXI_LOCK_WIDTH(2)
  ) m_cmd_fifo (
    .clk(m_aclk),
    .srst(m_fifo_rst),
    .din(m_ar_cmd),
    .dout(m_r_cmd),
    .full(m_cmd_full),
    .empty(m_cmd_empty),
    .wr_en(m_cmd_push),
    .rd_en(m_cmd_pop),
    .backup(1'b0),
    .backup_marker(1'b0),
    .rst(1'b0),
    .wr_clk(1'b0),
    .wr_rst(1'b0),
    .rd_clk(1'b0),
    .rd_rst(1'b0),
    .prog_empty_thresh(5'b0),
    .prog_empty_thresh_assert(5'b0),
    .prog_empty_thresh_negate(5'b0),
    .prog_full_thresh(5'b0),
    .prog_full_thresh_assert(5'b0),
    .prog_full_thresh_negate(5'b0),
    .int_clk(1'b0),
    .injectdbiterr(1'b0),
    .injectsbiterr(1'b0),
    .almost_full(),
    .wr_ack(),
    .overflow(),
    .almost_empty(),
    .valid(),
    .underflow(),
    .data_count(),
    .rd_data_count(),
    .wr_data_count(),
    .prog_full(),
    .prog_empty(),
    .sbiterr(),
    .dbiterr(),
    .m_aclk(1'b0),
    .s_aclk(1'b0),
    .s_aresetn(1'b0),
    .m_aclk_en(1'b0),
    .s_aclk_en(1'b0),
    .s_axi_awid(4'b0),
    .s_axi_awaddr(32'b0),
    .s_axi_awlen(8'b0),
    .s_axi_awsize(3'b0),
    .s_axi_awburst(2'b0),
    .s_axi_awlock(2'b0),
    .s_axi_awcache(4'b0),
    .s_axi_awprot(3'b0),
    .s_axi_awqos(4'b0),
    .s_axi_awregion(4'b0),
    .s_axi_awuser(1'b0),
    .s_axi_awvalid(1'b0),
    .s_axi_awready(),
    .s_axi_wid(4'b0),
    .s_axi_wdata(64'b0),
    .s_axi_wstrb(8'b0),
    .s_axi_wlast(1'b0),
    .s_axi_wuser(1'b0),
    .s_axi_wvalid(1'b0),
    .s_axi_wready(),
    .s_axi_bid(),
    .s_axi_bresp(),
    .s_axi_buser(),
    .s_axi_bvalid(),
    .s_axi_bready(1'b0),
    .m_axi_awid(),
    .m_axi_awaddr(),
    .m_axi_awlen(),
    .m_axi_awsize(),
    .m_axi_awburst(),
    .m_axi_awlock(),
    .m_axi_awcache(),
    .m_axi_awprot(),
    .m_axi_awqos(),
    .m_axi_awregion(),
    .m_axi_awuser(),
    .m_axi_awvalid(),
    .m_axi_awready(1'b0),
    .m_axi_wid(),
    .m_axi_wdata(),
    .m_axi_wstrb(),
    .m_axi_wlast(),
    .m_axi_wuser(),
    .m_axi_wvalid(),
    .m_axi_wready(1'b0),
    .m_axi_bid(4'b0),
    .m_axi_bresp(2'b0),
    .m_axi_buser(1'b0),
    .m_axi_bvalid(1'b0),
    .m_axi_bready(),
    .s_axi_arid(4'b0),
    .s_axi_araddr(32'b0),
    .s_axi_arlen(8'b0),
    .s_axi_arsize(3'b0),
    .s_axi_arburst(2'b0),
    .s_axi_arlock(2'b0),
    .s_axi_arcache(4'b0),
    .s_axi_arprot(3'b0),
    .s_axi_arqos(4'b0),
    .s_axi_arregion(4'b0),
    .s_axi_aruser(1'b0),
    .s_axi_arvalid(1'b0),
    .s_axi_arready(),
    .s_axi_rid(),
    .s_axi_rdata(),
    .s_axi_rresp(),
    .s_axi_rlast(),
    .s_axi_ruser(),
    .s_axi_rvalid(),
    .s_axi_rready(1'b0),
    .m_axi_arid(),
    .m_axi_araddr(),
    .m_axi_arlen(),
    .m_axi_arsize(),
    .m_axi_arburst(),
    .m_axi_arlock(),
    .m_axi_arcache(),
    .m_axi_arprot(),
    .m_axi_arqos(),
    .m_axi_arregion(),
    .m_axi_aruser(),
    .m_axi_arvalid(),
    .m_axi_arready(1'b0),
    .m_axi_rid(4'b0),
    .m_axi_rdata(64'b0),
    .m_axi_rresp(2'b0),
    .m_axi_rlast(1'b0),
    .m_axi_ruser(1'b0),
    .m_axi_rvalid(1'b0),
    .m_axi_rready(),
    .s_axis_tvalid(1'b0),
    .s_axis_tready(),
    .s_axis_tdata(64'b0),
    .s_axis_tstrb(4'b0),
    .s_axis_tkeep(4'b0),
    .s_axis_tlast(1'b0),
    .s_axis_tid(8'b0),
    .s_axis_tdest(4'b0),
    .s_axis_tuser(4'b0),
    .m_axis_tvalid(),
    .m_axis_tready(1'b0),
    .m_axis_tdata(),
    .m_axis_tstrb(),
    .m_axis_tkeep(),
    .m_axis_tlast(),
    .m_axis_tid(),
    .m_axis_tdest(),
    .m_axis_tuser(),
    .axi_aw_injectsbiterr(1'b0),
    .axi_aw_injectdbiterr(1'b0),
    .axi_aw_prog_full_thresh(4'b0),
    .axi_aw_prog_empty_thresh(4'b0),
    .axi_aw_data_count(),
    .axi_aw_wr_data_count(),
    .axi_aw_rd_data_count(),
    .axi_aw_sbiterr(),
    .axi_aw_dbiterr(),
    .axi_aw_overflow(),
    .axi_aw_underflow(),
    .axi_aw_prog_full(),
    .axi_aw_prog_empty(),
    .axi_w_injectsbiterr(1'b0),
    .axi_w_injectdbiterr(1'b0),
    .axi_w_prog_full_thresh(10'b0),
    .axi_w_prog_empty_thresh(10'b0),
    .axi_w_data_count(),
    .axi_w_wr_data_count(),
    .axi_w_rd_data_count(),
    .axi_w_sbiterr(),
    .axi_w_dbiterr(),
    .axi_w_overflow(),
    .axi_w_underflow(),
    .axi_b_injectsbiterr(1'b0),
    .axi_w_prog_full(),
    .axi_w_prog_empty(),
    .axi_b_injectdbiterr(1'b0),
    .axi_b_prog_full_thresh(4'b0),
    .axi_b_prog_empty_thresh(4'b0),
    .axi_b_data_count(),
    .axi_b_wr_data_count(),
    .axi_b_rd_data_count(),
    .axi_b_sbiterr(),
    .axi_b_dbiterr(),
    .axi_b_overflow(),
    .axi_b_underflow(),
    .axi_ar_injectsbiterr(1'b0),
    .axi_b_prog_full(),
    .axi_b_prog_empty(),
    .axi_ar_injectdbiterr(1'b0),
    .axi_ar_prog_full_thresh(4'b0),
    .axi_ar_prog_empty_thresh(4'b0),
    .axi_ar_data_count(),
    .axi_ar_wr_data_count(),
    .axi_ar_rd_data_count(),
    .axi_ar_sbiterr(),
    .axi_ar_dbiterr(),
    .axi_ar_overflow(),
    .axi_ar_underflow(),
    .axi_ar_prog_full(),
    .axi_ar_prog_empty(),
    .axi_r_injectsbiterr(1'b0),
    .axi_r_injectdbiterr(1'b0),
    .axi_r_prog_full_thresh(10'b0),
    .axi_r_prog_empty_thresh(10'b0),
    .axi_r_data_count(),
    .axi_r_wr_data_count(),
    .axi_r_rd_data_count(),
    .axi_r_sbiterr(),
    .axi_r_dbiterr(),
    .axi_r_overflow(),
    .axi_r_underflow(),
    .axis_injectsbiterr(1'b0),
    .axi_r_prog_full(),
    .axi_r_prog_empty(),
    .axis_injectdbiterr(1'b0),
    .axis_prog_full_thresh(10'b0),
    .axis_prog_empty_thresh(10'b0),
    .axis_data_count(),
    .axis_wr_data_count(),
    .axis_rd_data_count(),
    .axis_sbiterr(),
    .axis_dbiterr(),
    .axis_overflow(),
    .axis_underflow(),
    .axis_prog_full(),
    .axis_prog_empty(),
    .wr_rst_busy(),
    .rd_rst_busy(),
    .sleep(1'b0)
  );

  fifo_generator_v12_0 #(
    .C_DIN_WIDTH(4),
    .C_DOUT_WIDTH(4),
    .C_RD_DEPTH(512),
    .C_RD_PNTR_WIDTH(9),
    .C_RD_DATA_COUNT_WIDTH(9),
    .C_WR_DEPTH(512),
    .C_WR_PNTR_WIDTH(9),
    .C_WR_DATA_COUNT_WIDTH(9),
    .C_DATA_COUNT_WIDTH(9),
    .C_COMMON_CLOCK(P_COMMON_CLOCK),
    .C_COUNT_TYPE(0),
    .C_DEFAULT_VALUE("BlankString"),
    .C_DOUT_RST_VAL("0"),
    .C_ENABLE_RLOCS(0),
    .C_FAMILY(C_FAMILY),
    .C_FULL_FLAGS_RST_VAL(0),
    .C_HAS_ALMOST_EMPTY(0),
    .C_HAS_ALMOST_FULL(0),
    .C_HAS_BACKUP(0),
    .C_HAS_DATA_COUNT(0),
    .C_HAS_INT_CLK(0),
    .C_HAS_MEMINIT_FILE(0),
    .C_HAS_OVERFLOW(0),
    .C_HAS_RD_DATA_COUNT(0),
    .C_HAS_RD_RST(0),
    .C_HAS_RST(P_COMMON_CLOCK ? 0 : 1),
    .C_HAS_SRST(P_COMMON_CLOCK ? 1 : 0),
    .C_HAS_UNDERFLOW(0),
    .C_HAS_VALID(0),
    .C_HAS_WR_ACK(0),
    .C_HAS_WR_DATA_COUNT(0),
    .C_HAS_WR_RST(0),
    .C_IMPLEMENTATION_TYPE(P_COMMON_CLOCK ? 0 : 2),
    .C_INIT_WR_PNTR_VAL(0),
    .C_MEMORY_TYPE(2),
    .C_MIF_FILE_NAME("BlankString"),
    .C_OPTIMIZATION_MODE(0),
    .C_OVERFLOW_LOW(0),
    .C_PRELOAD_LATENCY(0),
    .C_PRELOAD_REGS(1),
    .C_PRIM_FIFO_TYPE("512x36"),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL(4),
    .C_PROG_EMPTY_THRESH_NEGATE_VAL(5),
    .C_PROG_EMPTY_TYPE(0),
    .C_PROG_FULL_THRESH_ASSERT_VAL(31),
    .C_PROG_FULL_THRESH_NEGATE_VAL(30),
    .C_PROG_FULL_TYPE(0),
    .C_RD_FREQ(1),
    .C_UNDERFLOW_LOW(0),
    .C_USE_DOUT_RST(0),
    .C_USE_ECC(0),
    .C_USE_EMBEDDED_REG(0),
    .C_USE_FIFO16_FLAGS(0),
    .C_USE_FWFT_DATA_COUNT(1),
    .C_VALID_LOW(0),
    .C_WR_ACK_LOW(0),
    .C_WR_FREQ(1),
    .C_WR_RESPONSE_LATENCY(1),
    .C_MSGON_VAL(1),
    .C_ENABLE_RST_SYNC(1),
    .C_ERROR_INJECTION_TYPE(0),
    .C_SYNCHRONIZER_STAGE(C_SYNCHRONIZER_STAGE),
    .C_INTERFACE_TYPE(0),
    .C_AXI_TYPE(0),
    .C_HAS_AXI_WR_CHANNEL(0),
    .C_HAS_AXI_RD_CHANNEL(0),
    .C_HAS_SLAVE_CE(0),
    .C_HAS_MASTER_CE(0),
    .C_ADD_NGC_CONSTRAINT(0),
    .C_USE_COMMON_OVERFLOW(0),
    .C_USE_COMMON_UNDERFLOW(0),
    .C_USE_DEFAULT_SETTINGS(0),
    .C_AXI_ID_WIDTH(4),
    .C_AXI_ADDR_WIDTH(32),
    .C_AXI_DATA_WIDTH(64),
    .C_HAS_AXI_AWUSER(0),
    .C_HAS_AXI_WUSER(0),
    .C_HAS_AXI_BUSER(0),
    .C_HAS_AXI_ARUSER(0),
    .C_HAS_AXI_RUSER(0),
    .C_AXI_ARUSER_WIDTH(1),
    .C_AXI_AWUSER_WIDTH(1),
    .C_AXI_WUSER_WIDTH(1),
    .C_AXI_BUSER_WIDTH(1),
    .C_AXI_RUSER_WIDTH(1),
    .C_HAS_AXIS_TDATA(0),
    .C_HAS_AXIS_TID(0),
    .C_HAS_AXIS_TDEST(0),
    .C_HAS_AXIS_TUSER(0),
    .C_HAS_AXIS_TREADY(1),
    .C_HAS_AXIS_TLAST(0),
    .C_HAS_AXIS_TSTRB(0),
    .C_HAS_AXIS_TKEEP(0),
    .C_AXIS_TDATA_WIDTH(64),
    .C_AXIS_TID_WIDTH(8),
    .C_AXIS_TDEST_WIDTH(4),
    .C_AXIS_TUSER_WIDTH(4),
    .C_AXIS_TSTRB_WIDTH(4),
    .C_AXIS_TKEEP_WIDTH(4),
    .C_WACH_TYPE(0),
    .C_WDCH_TYPE(0),
    .C_WRCH_TYPE(0),
    .C_RACH_TYPE(0),
    .C_RDCH_TYPE(0),
    .C_AXIS_TYPE(0),
    .C_IMPLEMENTATION_TYPE_WACH(1),
    .C_IMPLEMENTATION_TYPE_WDCH(1),
    .C_IMPLEMENTATION_TYPE_WRCH(1),
    .C_IMPLEMENTATION_TYPE_RACH(1),
    .C_IMPLEMENTATION_TYPE_RDCH(1),
    .C_IMPLEMENTATION_TYPE_AXIS(1),
    .C_APPLICATION_TYPE_WACH(0),
    .C_APPLICATION_TYPE_WDCH(0),
    .C_APPLICATION_TYPE_WRCH(0),
    .C_APPLICATION_TYPE_RACH(0),
    .C_APPLICATION_TYPE_RDCH(0),
    .C_APPLICATION_TYPE_AXIS(0),
    .C_USE_ECC_WACH(0),
    .C_USE_ECC_WDCH(0),
    .C_USE_ECC_WRCH(0),
    .C_USE_ECC_RACH(0),
    .C_USE_ECC_RDCH(0),
    .C_USE_ECC_AXIS(0),
    .C_ERROR_INJECTION_TYPE_WACH(0),
    .C_ERROR_INJECTION_TYPE_WDCH(0),
    .C_ERROR_INJECTION_TYPE_WRCH(0),
    .C_ERROR_INJECTION_TYPE_RACH(0),
    .C_ERROR_INJECTION_TYPE_RDCH(0),
    .C_ERROR_INJECTION_TYPE_AXIS(0),
    .C_DIN_WIDTH_WACH(32),
    .C_DIN_WIDTH_WDCH(64),
    .C_DIN_WIDTH_WRCH(2),
    .C_DIN_WIDTH_RACH(32),
    .C_DIN_WIDTH_RDCH(64),
    .C_DIN_WIDTH_AXIS(1),
    .C_WR_DEPTH_WACH(16),
    .C_WR_DEPTH_WDCH(1024),
    .C_WR_DEPTH_WRCH(16),
    .C_WR_DEPTH_RACH(16),
    .C_WR_DEPTH_RDCH(1024),
    .C_WR_DEPTH_AXIS(1024),
    .C_WR_PNTR_WIDTH_WACH(4),
    .C_WR_PNTR_WIDTH_WDCH(10),
    .C_WR_PNTR_WIDTH_WRCH(4),
    .C_WR_PNTR_WIDTH_RACH(4),
    .C_WR_PNTR_WIDTH_RDCH(10),
    .C_WR_PNTR_WIDTH_AXIS(10),
    .C_HAS_DATA_COUNTS_WACH(0),
    .C_HAS_DATA_COUNTS_WDCH(0),
    .C_HAS_DATA_COUNTS_WRCH(0),
    .C_HAS_DATA_COUNTS_RACH(0),
    .C_HAS_DATA_COUNTS_RDCH(0),
    .C_HAS_DATA_COUNTS_AXIS(0),
    .C_HAS_PROG_FLAGS_WACH(0),
    .C_HAS_PROG_FLAGS_WDCH(0),
    .C_HAS_PROG_FLAGS_WRCH(0),
    .C_HAS_PROG_FLAGS_RACH(0),
    .C_HAS_PROG_FLAGS_RDCH(0),
    .C_HAS_PROG_FLAGS_AXIS(0),
    .C_PROG_FULL_TYPE_WACH(0),
    .C_PROG_FULL_TYPE_WDCH(0),
    .C_PROG_FULL_TYPE_WRCH(0),
    .C_PROG_FULL_TYPE_RACH(0),
    .C_PROG_FULL_TYPE_RDCH(0),
    .C_PROG_FULL_TYPE_AXIS(0),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WACH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WDCH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_WRCH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_RACH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_RDCH(1023),
    .C_PROG_FULL_THRESH_ASSERT_VAL_AXIS(1023),
    .C_PROG_EMPTY_TYPE_WACH(0),
    .C_PROG_EMPTY_TYPE_WDCH(0),
    .C_PROG_EMPTY_TYPE_WRCH(0),
    .C_PROG_EMPTY_TYPE_RACH(0),
    .C_PROG_EMPTY_TYPE_RDCH(0),
    .C_PROG_EMPTY_TYPE_AXIS(0),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH(1022),
    .C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS(1022),
    .C_REG_SLICE_MODE_WACH(0),
    .C_REG_SLICE_MODE_WDCH(0),
    .C_REG_SLICE_MODE_WRCH(0),
    .C_REG_SLICE_MODE_RACH(0),
    .C_REG_SLICE_MODE_RDCH(0),
    .C_REG_SLICE_MODE_AXIS(0),
    .C_AXI_LEN_WIDTH(8),
    .C_AXI_LOCK_WIDTH(2)
  ) dw_fifogen_rresp (
    .clk(rresp_fifo_clk),
    .wr_clk(rresp_fifo_wrclk),
    .rd_clk(rresp_fifo_rdclk),
    .srst(P_COMMON_CLOCK ? rresp_fifo_rst : 1'b0),
    .rst(P_COMMON_CLOCK ? 1'b0 : rresp_fifo_rst),
    .wr_rst(1'b0),
    .rd_rst(1'b0),
    .din(m_rresp_i),
    .dout(s_rresp_i),
    .full(rresp_fifo_full),
    .empty(rresp_fifo_empty),
    .wr_en(rresp_fifo_push),
    .rd_en(rresp_fifo_pop),
    .backup(1'b0),
    .backup_marker(1'b0),
    .prog_empty_thresh(9'b0),
    .prog_empty_thresh_assert(9'b0),
    .prog_empty_thresh_negate(9'b0),
    .prog_full_thresh(9'b0),
    .prog_full_thresh_assert(9'b0),
    .prog_full_thresh_negate(9'b0),
    .int_clk(1'b0),
    .injectdbiterr(1'b0),
    .injectsbiterr(1'b0),
    .almost_full(),
    .wr_ack(),
    .overflow(),
    .almost_empty(),
    .valid(),
    .underflow(),
    .data_count(),
    .rd_data_count(),
    .wr_data_count(),
    .prog_full(),
    .prog_empty(),
    .sbiterr(),
    .dbiterr(),
    .m_aclk(1'b0),
    .s_aclk(1'b0),
    .s_aresetn(1'b0),
    .m_aclk_en(1'b0),
    .s_aclk_en(1'b0),
    .s_axi_awid(4'b0),
    .s_axi_awaddr(32'b0),
    .s_axi_awlen(8'b0),
    .s_axi_awsize(3'b0),
    .s_axi_awburst(2'b0),
    .s_axi_awlock(2'b0),
    .s_axi_awcache(4'b0),
    .s_axi_awprot(3'b0),
    .s_axi_awqos(4'b0),
    .s_axi_awregion(4'b0),
    .s_axi_awuser(1'b0),
    .s_axi_awvalid(1'b0),
    .s_axi_awready(),
    .s_axi_wid(4'b0),
    .s_axi_wdata(64'b0),
    .s_axi_wstrb(8'b0),
    .s_axi_wlast(1'b0),
    .s_axi_wuser(1'b0),
    .s_axi_wvalid(1'b0),
    .s_axi_wready(),
    .s_axi_bid(),
    .s_axi_bresp(),
    .s_axi_buser(),
    .s_axi_bvalid(),
    .s_axi_bready(1'b0),
    .m_axi_awid(),
    .m_axi_awaddr(),
    .m_axi_awlen(),
    .m_axi_awsize(),
    .m_axi_awburst(),
    .m_axi_awlock(),
    .m_axi_awcache(),
    .m_axi_awprot(),
    .m_axi_awqos(),
    .m_axi_awregion(),
    .m_axi_awuser(),
    .m_axi_awvalid(),
    .m_axi_awready(1'b0),
    .m_axi_wid(),
    .m_axi_wdata(),
    .m_axi_wstrb(),
    .m_axi_wlast(),
    .m_axi_wuser(),
    .m_axi_wvalid(),
    .m_axi_wready(1'b0),
    .m_axi_bid(4'b0),
    .m_axi_bresp(2'b0),
    .m_axi_buser(1'b0),
    .m_axi_bvalid(1'b0),
    .m_axi_bready(),
    .s_axi_arid(4'b0),
    .s_axi_araddr(32'b0),
    .s_axi_arlen(8'b0),
    .s_axi_arsize(3'b0),
    .s_axi_arburst(2'b0),
    .s_axi_arlock(2'b0),
    .s_axi_arcache(4'b0),
    .s_axi_arprot(3'b0),
    .s_axi_arqos(4'b0),
    .s_axi_arregion(4'b0),
    .s_axi_aruser(1'b0),
    .s_axi_arvalid(1'b0),
    .s_axi_arready(),
    .s_axi_rid(),
    .s_axi_rdata(),
    .s_axi_rresp(),
    .s_axi_rlast(),
    .s_axi_ruser(),
    .s_axi_rvalid(),
    .s_axi_rready(1'b0),
    .m_axi_arid(),
    .m_axi_araddr(),
    .m_axi_arlen(),
    .m_axi_arsize(),
    .m_axi_arburst(),
    .m_axi_arlock(),
    .m_axi_arcache(),
    .m_axi_arprot(),
    .m_axi_arqos(),
    .m_axi_arregion(),
    .m_axi_aruser(),
    .m_axi_arvalid(),
    .m_axi_arready(1'b0),
    .m_axi_rid(4'b0),
    .m_axi_rdata(64'b0),
    .m_axi_rresp(2'b0),
    .m_axi_rlast(1'b0),
    .m_axi_ruser(1'b0),
    .m_axi_rvalid(1'b0),
    .m_axi_rready(),
    .s_axis_tvalid(1'b0),
    .s_axis_tready(),
    .s_axis_tdata(64'b0),
    .s_axis_tstrb(4'b0),
    .s_axis_tkeep(4'b0),
    .s_axis_tlast(1'b0),
    .s_axis_tid(8'b0),
    .s_axis_tdest(4'b0),
    .s_axis_tuser(4'b0),
    .m_axis_tvalid(),
    .m_axis_tready(1'b0),
    .m_axis_tdata(),
    .m_axis_tstrb(),
    .m_axis_tkeep(),
    .m_axis_tlast(),
    .m_axis_tid(),
    .m_axis_tdest(),
    .m_axis_tuser(),
    .axi_aw_injectsbiterr(1'b0),
    .axi_aw_injectdbiterr(1'b0),
    .axi_aw_prog_full_thresh(4'b0),
    .axi_aw_prog_empty_thresh(4'b0),
    .axi_aw_data_count(),
    .axi_aw_wr_data_count(),
    .axi_aw_rd_data_count(),
    .axi_aw_sbiterr(),
    .axi_aw_dbiterr(),
    .axi_aw_overflow(),
    .axi_aw_underflow(),
    .axi_aw_prog_full(),
    .axi_aw_prog_empty(),
    .axi_w_injectsbiterr(1'b0),
    .axi_w_injectdbiterr(1'b0),
    .axi_w_prog_full_thresh(10'b0),
    .axi_w_prog_empty_thresh(10'b0),
    .axi_w_data_count(),
    .axi_w_wr_data_count(),
    .axi_w_rd_data_count(),
    .axi_w_sbiterr(),
    .axi_w_dbiterr(),
    .axi_w_overflow(),
    .axi_w_underflow(),
    .axi_b_injectsbiterr(1'b0),
    .axi_w_prog_full(),
    .axi_w_prog_empty(),
    .axi_b_injectdbiterr(1'b0),
    .axi_b_prog_full_thresh(4'b0),
    .axi_b_prog_empty_thresh(4'b0),
    .axi_b_data_count(),
    .axi_b_wr_data_count(),
    .axi_b_rd_data_count(),
    .axi_b_sbiterr(),
    .axi_b_dbiterr(),
    .axi_b_overflow(),
    .axi_b_underflow(),
    .axi_ar_injectsbiterr(1'b0),
    .axi_b_prog_full(),
    .axi_b_prog_empty(),
    .axi_ar_injectdbiterr(1'b0),
    .axi_ar_prog_full_thresh(4'b0),
    .axi_ar_prog_empty_thresh(4'b0),
    .axi_ar_data_count(),
    .axi_ar_wr_data_count(),
    .axi_ar_rd_data_count(),
    .axi_ar_sbiterr(),
    .axi_ar_dbiterr(),
    .axi_ar_overflow(),
    .axi_ar_underflow(),
    .axi_ar_prog_full(),
    .axi_ar_prog_empty(),
    .axi_r_injectsbiterr(1'b0),
    .axi_r_injectdbiterr(1'b0),
    .axi_r_prog_full_thresh(10'b0),
    .axi_r_prog_empty_thresh(10'b0),
    .axi_r_data_count(),
    .axi_r_wr_data_count(),
    .axi_r_rd_data_count(),
    .axi_r_sbiterr(),
    .axi_r_dbiterr(),
    .axi_r_overflow(),
    .axi_r_underflow(),
    .axis_injectsbiterr(1'b0),
    .axi_r_prog_full(),
    .axi_r_prog_empty(),
    .axis_injectdbiterr(1'b0),
    .axis_prog_full_thresh(10'b0),
    .axis_prog_empty_thresh(10'b0),
    .axis_data_count(),
    .axis_wr_data_count(),
    .axis_rd_data_count(),
    .axis_sbiterr(),
    .axis_dbiterr(),
    .axis_overflow(),
    .axis_underflow(),
    .axis_prog_full(),
    .axis_prog_empty(),
    .wr_rst_busy(),
    .rd_rst_busy(),
    .sleep(1'b0)
  );

  endgenerate

endmodule

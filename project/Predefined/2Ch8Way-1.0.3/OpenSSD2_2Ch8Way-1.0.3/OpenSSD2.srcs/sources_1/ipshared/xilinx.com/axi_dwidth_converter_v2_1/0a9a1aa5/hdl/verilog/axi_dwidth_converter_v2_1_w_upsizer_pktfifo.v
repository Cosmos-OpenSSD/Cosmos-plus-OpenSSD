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
module axi_dwidth_converter_v2_1_w_upsizer_pktfifo #
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
   input  wire [8-1:0]                      cmd_si_len,
   input  wire [3-1:0]                      cmd_si_size,
   input  wire [2-1:0]                      cmd_si_burst,
   output wire                              cmd_ready,
   
   // Slave Interface Write Address Port
   input  wire [C_AXI_ADDR_WIDTH-1:0]          S_AXI_AWADDR,
   input  wire [8-1:0]                         S_AXI_AWLEN,
   input  wire [3-1:0]                         S_AXI_AWSIZE,
   input  wire [2-1:0]                         S_AXI_AWBURST,
   input  wire [2-1:0]                         S_AXI_AWLOCK,
   input  wire [4-1:0]                         S_AXI_AWCACHE,
   input  wire [3-1:0]                         S_AXI_AWPROT,
   input  wire [4-1:0]                         S_AXI_AWREGION,
   input  wire [4-1:0]                         S_AXI_AWQOS,
   input  wire                                 S_AXI_AWVALID,
   output wire                                 S_AXI_AWREADY,

   // Master Interface Write Address Port
   output wire [C_AXI_ADDR_WIDTH-1:0]          M_AXI_AWADDR,
   output wire [8-1:0]                         M_AXI_AWLEN,
   output wire [3-1:0]                         M_AXI_AWSIZE,
   output wire [2-1:0]                         M_AXI_AWBURST,
   output wire [2-1:0]                         M_AXI_AWLOCK,
   output wire [4-1:0]                         M_AXI_AWCACHE,
   output wire [3-1:0]                         M_AXI_AWPROT,
   output wire [4-1:0]                         M_AXI_AWREGION,
   output wire [4-1:0]                         M_AXI_AWQOS,
   output wire                                 M_AXI_AWVALID,
   input  wire                                 M_AXI_AWREADY,

   // Slave Interface Write Data Ports
   input  wire [C_S_AXI_DATA_WIDTH-1:0]     S_AXI_WDATA,
   input  wire [C_S_AXI_DATA_WIDTH/8-1:0]   S_AXI_WSTRB,
   input  wire                              S_AXI_WLAST,
   input  wire                              S_AXI_WVALID,
   output wire                              S_AXI_WREADY,

   // Master Interface Write Data Ports
   output wire [C_M_AXI_DATA_WIDTH-1:0]     M_AXI_WDATA,
   output wire [C_M_AXI_DATA_WIDTH/8-1:0]   M_AXI_WSTRB,
   output wire                              M_AXI_WLAST,
   output wire                              M_AXI_WVALID,
   input  wire                              M_AXI_WREADY,
   
   input wire                               SAMPLE_CYCLE_EARLY,
   input wire                               SAMPLE_CYCLE

   );

  localparam integer P_SI_BYTES = C_S_AXI_DATA_WIDTH / 8;
  localparam integer P_MI_BYTES = C_M_AXI_DATA_WIDTH / 8;
  localparam integer P_MAX_BYTES = 1024 / 8;
  localparam integer P_SI_SIZE = f_ceil_log2(P_SI_BYTES);
  localparam integer P_MI_SIZE = f_ceil_log2(P_MI_BYTES);
  localparam integer P_RATIO = C_M_AXI_DATA_WIDTH / C_S_AXI_DATA_WIDTH;
  localparam integer P_RATIO_LOG = f_ceil_log2(P_RATIO);
  localparam integer P_NUM_BUF = (P_RATIO > 16) ? 32 : (P_RATIO * 2);
  localparam integer P_NUM_BUF_LOG = f_ceil_log2(P_NUM_BUF);
  localparam integer P_AWFIFO_TRESHOLD = P_NUM_BUF - 2;
  localparam integer P_M_WBUFFER_WIDTH = P_MI_BYTES * 9;
  localparam integer P_M_WBUFFER_DEPTH = 512;
  localparam integer P_M_WBUFFER_DEPTH_LOG = 9;
  localparam integer P_M_WBUFFER_WORDS = P_M_WBUFFER_DEPTH / P_NUM_BUF;
  localparam integer P_M_WBUFFER_WORDS_LOG = f_ceil_log2(P_M_WBUFFER_WORDS);
  localparam integer P_MAX_RBUFFER_BYTES_LOG = f_ceil_log2((P_M_WBUFFER_DEPTH / 4) * P_MAX_BYTES);
  localparam [1:0] P_INCR = 2'b01, P_WRAP = 2'b10, P_FIXED = 2'b00;
  localparam [1:0] S_IDLE = 2'b00, S_WRITING = 2'b01, S_AWFULL = 2'b11;
  localparam [2:0] M_IDLE = 3'b000, M_ISSUE1 = 3'b001, M_WRITING1 = 3'b011, M_AW_STALL = 3'b010, M_AW_DONE1 = 3'b110, M_ISSUE2 = 3'b111, M_WRITING2 = 3'b101, M_AW_DONE2 = 3'b100;
  localparam  P_SI_LT_MI = (C_S_AXI_ACLK_RATIO < C_M_AXI_ACLK_RATIO);
  localparam integer P_ACLK_RATIO = P_SI_LT_MI ? (C_M_AXI_ACLK_RATIO / C_S_AXI_ACLK_RATIO) : (C_S_AXI_ACLK_RATIO / C_M_AXI_ACLK_RATIO);
  localparam integer P_AWFIFO_WIDTH = 29 + C_AXI_ADDR_WIDTH + P_MI_SIZE;
  localparam integer P_COMMON_CLOCK = (C_CLK_CONV & C_AXI_IS_ACLK_ASYNC) ? 0 : 1;
  
  reg  S_AXI_WREADY_i;
  reg  M_AXI_AWVALID_i;
  wire [C_AXI_ADDR_WIDTH-1:0] M_AXI_AWADDR_i;
  wire [7:0] M_AXI_AWLEN_i;
  wire [2:0] M_AXI_AWSIZE_i;
  wire [1:0] M_AXI_AWBURST_i;
  wire M_AXI_AWLOCK_i;
  reg  M_AXI_WVALID_i;
  reg  M_AXI_WLAST_i;
  wire S_AXI_AWLOCK_i;
  reg  aw_push;
  wire push_ready;
  wire aw_ready;
  reg  load_si_ptr;
  reg  [1:0] si_state;
  reg  [1:0] si_state_ns;
  reg  S_AXI_WREADY_ns;
  reg  aw_pop;
  reg  aw_pop_extend;
  wire aw_pop_event;
  wire aw_pop_resync;
  reg  cmd_ready_i;
  wire si_buf_en;
  reg  [P_NUM_BUF_LOG-1:0] si_buf;
  reg  [P_NUM_BUF_LOG-1:0] buf_cnt;
  reg  [P_M_WBUFFER_WORDS_LOG-1:0] si_ptr;
  reg  [1:0] si_burst;
  reg  [2:0] si_size;
  reg  [P_SI_BYTES-1:0] si_be;
  wire [P_MI_BYTES-1:0] si_we;
  reg  [P_SI_BYTES-1:0] si_wrap_be_next;
  reg  [P_MI_SIZE-P_SI_SIZE-1:0] si_word;
  reg  [P_MI_SIZE-P_SI_SIZE-1:0] si_wrap_word_next;
  reg  [3:0] si_wrap_cnt;
  reg  [2:0] mi_state;
  reg  [2:0] mi_state_ns;
  reg  M_AXI_AWVALID_ns;
  reg  M_AXI_WVALID_ns;
  reg  load_mi_ptr;
  reg  load_mi_next;
  reg  load_mi_d1;
  reg  load_mi_d2;
  reg  first_load_mi_d1;
  wire mi_w_done;
  reg  mi_last;
  reg  mi_last_d1;
  reg  next_valid;
  reg  [P_NUM_BUF_LOG-1:0] mi_buf;
  reg  [P_M_WBUFFER_WORDS_LOG-1:0] mi_ptr;
  reg  [7:0] mi_wcnt;
  wire mi_buf_en;
  wire mi_awvalid;
  reg  [1:0] mi_burst;
  reg  [2:0] mi_size;
  reg  [P_MI_BYTES-1:0] mi_be;
  reg  [P_MI_BYTES-1:0] mi_be_d1;
  reg  [P_MI_BYTES-1:0] mi_wstrb_mask_d2;
  reg  [P_MI_BYTES-1:0] mi_wrap_be_next;
  reg  [P_MI_SIZE-1:0] mi_addr;
  reg  [P_MI_SIZE-1:0] mi_addr_d1;
  wire [P_MI_SIZE-1:0] si_last_index;
  wire [P_MI_SIZE-1:0] si_last_index_reg;
  wire [P_MI_SIZE-1:0] mi_last_index_reg;
  reg  [P_MI_SIZE-1:0] mi_last_index_reg_d0;
  reg  [P_MI_SIZE-1:0] mi_last_index_reg_d1;
  reg  [P_MI_SIZE-1:0] next_mi_last_index_reg;
  reg  mi_first;
  reg  mi_first_d1;
  reg  [3:0] mi_wrap_cnt;
  reg  [7:0] next_mi_len;
  reg  [1:0] next_mi_burst;
  reg  [2:0] next_mi_size;
  reg  [P_MI_SIZE+4-1:0] next_mi_addr;
  wire [P_M_WBUFFER_WIDTH-1:0] si_wpayload;
  wire [P_M_WBUFFER_WIDTH-1:0] mi_wpayload;
  wire [P_M_WBUFFER_DEPTH_LOG-1:0] si_buf_addr;
  wire [P_M_WBUFFER_DEPTH_LOG-1:0] mi_buf_addr;
  wire s_awvalid_reg;
  wire s_awready_reg;
  wire [C_AXI_ADDR_WIDTH-1:0] s_awaddr_reg;
  wire [7:0] s_awlen_reg;
  wire [2:0] s_awsize_reg;
  wire [1:0] s_awburst_reg;
  wire s_awlock_reg;
  wire [3:0] s_awcache_reg;
  wire [2:0] s_awprot_reg;
  wire [3:0] s_awqos_reg;
  wire [3:0] s_awregion_reg;
  
  wire m_aclk;
  wire m_aresetn;
  wire s_aresetn;
  wire aw_fifo_s_aclk;
  wire aw_fifo_m_aclk;
  wire aw_fifo_aresetn;
  wire awpop_reset;
  wire s_sample_cycle;
  wire s_sample_cycle_early;
  wire m_sample_cycle;
  wire m_sample_cycle_early;
  wire fast_aclk;
  reg  fast_aresetn_r;
  
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

  // Byte-enable pattern, for a full SI data-width transfer, at the given starting address.
  function [P_SI_BYTES-1:0] f_si_be_init
    (
      input [P_SI_SIZE-1:0] addr,
      input [2:0] size
    );
    integer i;
    reg [P_MAX_RBUFFER_BYTES_LOG-1:0] addr_i;
    begin
      addr_i = addr;
      for (i=0; i<P_SI_BYTES; i=i+1) begin
        case (P_SI_SIZE)
          2: case (size[1:0])
            2'h0: f_si_be_init[i] = addr_i[ 1 :  0] == i[ 1 :  0];
            2'h1: f_si_be_init[i] = addr_i[ 1 :  1] == i[ 1 :  1];
            default: f_si_be_init[i] = 1'b1;
          endcase
          3: case (size[1:0])
            2'h0: f_si_be_init[i] = addr_i[ 2 :  0] == i[ 2 :  0];
            2'h1: f_si_be_init[i] = addr_i[ 2 :  1] == i[ 2 :  1];
            2'h2: f_si_be_init[i] = addr_i[ 2 :  2] == i[ 2 :  2];
            default: f_si_be_init[i] = 1'b1;
          endcase
          4: case (size)
            3'h0: f_si_be_init[i] = addr_i[ 3 :  0] == i[ 3 :  0];
            3'h1: f_si_be_init[i] = addr_i[ 3 :  1] == i[ 3 :  1];
            3'h2: f_si_be_init[i] = addr_i[ 3 :  2] == i[ 3 :  2];
            3'h3: f_si_be_init[i] = addr_i[ 3 :  3] == i[ 3 :  3];
            default: f_si_be_init[i] = 1'b1;
          endcase
          5: case (size)
            3'h0: f_si_be_init[i] = addr_i[ 4 :  0] == i[ 4 :  0];
            3'h1: f_si_be_init[i] = addr_i[ 4 :  1] == i[ 4 :  1];
            3'h2: f_si_be_init[i] = addr_i[ 4 :  2] == i[ 4 :  2];
            3'h3: f_si_be_init[i] = addr_i[ 4 :  3] == i[ 4 :  3];
            3'h4: f_si_be_init[i] = addr_i[ 4 :  4] == i[ 4 :  4];
            default: f_si_be_init[i] = 1'b1;
          endcase
          6: case (size)
            3'h0: f_si_be_init[i] = addr_i[ 5 :  0] == i[ 5 :  0];
            3'h1: f_si_be_init[i] = addr_i[ 5 :  1] == i[ 5 :  1];
            3'h2: f_si_be_init[i] = addr_i[ 5 :  2] == i[ 5 :  2];
            3'h3: f_si_be_init[i] = addr_i[ 5 :  3] == i[ 5 :  3];
            3'h4: f_si_be_init[i] = addr_i[ 5 :  4] == i[ 5 :  4];
            3'h5: f_si_be_init[i] = addr_i[ 5 :  5] == i[ 5 :  5];
            default: f_si_be_init[i] = 1'b1;
          endcase
        endcase
      end
    end
  endfunction
 
  // Byte-enable pattern, for a full MI data-width transfer, at the given starting address.
  function [P_MI_BYTES-1:0] f_mi_be_init
    (
      input [P_MI_SIZE-1:0] addr,
      input [2:0] size
    );
    integer i;
    reg [P_MAX_RBUFFER_BYTES_LOG-1:0] addr_i;
    begin
      addr_i = addr;
      for (i=0; i<P_MI_BYTES; i=i+1) begin
        case (P_MI_SIZE)
          3: case (size)
            3'h0: f_mi_be_init[i] = addr_i[ 2 :  0] == i[ 2 :  0];
            3'h1: f_mi_be_init[i] = addr_i[ 2 :  1] == i[ 2 :  1];
            3'h2: f_mi_be_init[i] = addr_i[ 2 :  2] == i[ 2 :  2];
            default: f_mi_be_init[i] = 1'b1;  // Fully-packed
          endcase
          4: case (size)
            3'h0: f_mi_be_init[i] = addr_i[ 3 :  0] == i[ 3 :  0];
            3'h1: f_mi_be_init[i] = addr_i[ 3 :  1] == i[ 3 :  1];
            3'h2: f_mi_be_init[i] = addr_i[ 3 :  2] == i[ 3 :  2];
            3'h3: f_mi_be_init[i] = addr_i[ 3 :  3] == i[ 3 :  3];
            default: f_mi_be_init[i] = 1'b1;
          endcase
          5: case (size)
            3'h0: f_mi_be_init[i] = addr_i[ 4 :  0] == i[ 4 :  0];
            3'h1: f_mi_be_init[i] = addr_i[ 4 :  1] == i[ 4 :  1];
            3'h2: f_mi_be_init[i] = addr_i[ 4 :  2] == i[ 4 :  2];
            3'h3: f_mi_be_init[i] = addr_i[ 4 :  3] == i[ 4 :  3];
            3'h4: f_mi_be_init[i] = addr_i[ 4 :  4] == i[ 4 :  4];
            default: f_mi_be_init[i] = 1'b1;
          endcase
          6: case (size)
            3'h0: f_mi_be_init[i] = addr_i[ 5 :  0] == i[ 5 :  0];
            3'h1: f_mi_be_init[i] = addr_i[ 5 :  1] == i[ 5 :  1];
            3'h2: f_mi_be_init[i] = addr_i[ 5 :  2] == i[ 5 :  2];
            3'h3: f_mi_be_init[i] = addr_i[ 5 :  3] == i[ 5 :  3];
            3'h4: f_mi_be_init[i] = addr_i[ 5 :  4] == i[ 5 :  4];
            3'h5: f_mi_be_init[i] = addr_i[ 5 :  5] == i[ 5 :  5];
            default: f_mi_be_init[i] = 1'b1;
          endcase
          7: case (size)
            3'h0: f_mi_be_init[i] = addr_i[ 6 :  0] == i[ 6 :  0];
            3'h1: f_mi_be_init[i] = addr_i[ 6 :  1] == i[ 6 :  1];
            3'h2: f_mi_be_init[i] = addr_i[ 6 :  2] == i[ 6 :  2];
            3'h3: f_mi_be_init[i] = addr_i[ 6 :  3] == i[ 6 :  3];
            3'h4: f_mi_be_init[i] = addr_i[ 6 :  4] == i[ 6 :  4];
            3'h5: f_mi_be_init[i] = addr_i[ 6 :  5] == i[ 6 :  5];
            3'h6: f_mi_be_init[i] = addr_i[ 6 :  6] == i[ 6 :  6];
            default: f_mi_be_init[i] = 1'b1;
          endcase
        endcase
      end
    end
  endfunction
 
  // Byte-enable mask for the first fully-packed MI transfer (mask off ragged-head burst).
  function [P_MI_BYTES-1:0] f_mi_be_first_mask
    (
      input [P_MI_SIZE-1:0] addr
    );
    integer i;
    begin
      for (i=0; i<P_MI_BYTES; i=i+1) begin
        f_mi_be_first_mask[i] = (i >= {1'b0, addr});
      end
    end
  endfunction
 
  // Index of last byte written in last MI transfer.
  function [P_MI_SIZE-1:0] f_mi_be_last_index
    (
      input [P_MI_SIZE-1:0] addr,
      input [2:0] size,
      input [7:0] len,
      input [1:0] burst
    );
    reg [P_MI_SIZE-1:0] bytes;
    reg [P_MI_SIZE-1:0] mask;
    begin
      case (P_SI_SIZE)
        2: case (size)
          3'h0:    begin bytes =  len       ; mask =    1'b0  ; end
          3'h1:    begin bytes = {len, 1'b0}; mask = {1{1'b1}}; end
          3'h2:    begin bytes = {len, 2'b0}; mask = {2{1'b1}}; end
        endcase
        3: case (size)
          3'h0:    begin bytes =  len       ; mask =    1'b0  ; end
          3'h1:    begin bytes = {len, 1'b0}; mask = {1{1'b1}}; end
          3'h2:    begin bytes = {len, 2'b0}; mask = {2{1'b1}}; end
          3'h3:    begin bytes = {len, 3'b0}; mask = {3{1'b1}}; end
        endcase
        4: case (size)
          3'h0:    begin bytes =  len       ; mask =    1'b0  ; end
          3'h1:    begin bytes = {len, 1'b0}; mask = {1{1'b1}}; end
          3'h2:    begin bytes = {len, 2'b0}; mask = {2{1'b1}}; end
          3'h3:    begin bytes = {len, 3'b0}; mask = {3{1'b1}}; end
          3'h4:    begin bytes = {len, 4'b0}; mask = {4{1'b1}}; end
        endcase
        5: case (size)
          3'h0:    begin bytes =  len       ; mask =    1'b0  ; end
          3'h1:    begin bytes = {len, 1'b0}; mask = {1{1'b1}}; end
          3'h2:    begin bytes = {len, 2'b0}; mask = {2{1'b1}}; end
          3'h3:    begin bytes = {len, 3'b0}; mask = {3{1'b1}}; end
          3'h4:    begin bytes = {len, 4'b0}; mask = {4{1'b1}}; end
          3'h5:    begin bytes = {len, 5'b0}; mask = {5{1'b1}}; end
        endcase
        6: case (size)
          3'h0:    begin bytes =  len       ; mask =    1'b0  ; end
          3'h1:    begin bytes = {len, 1'b0}; mask = {1{1'b1}}; end
          3'h2:    begin bytes = {len, 2'b0}; mask = {2{1'b1}}; end
          3'h3:    begin bytes = {len, 3'b0}; mask = {3{1'b1}}; end
          3'h4:    begin bytes = {len, 4'b0}; mask = {4{1'b1}}; end
          3'h5:    begin bytes = {len, 5'b0}; mask = {5{1'b1}}; end
          3'h6:    begin bytes = {len, 6'b0}; mask = {6{1'b1}}; end
        endcase
      endcase

      case (burst)
        P_INCR:
          f_mi_be_last_index = (addr + bytes) | mask;
        P_WRAP:
          f_mi_be_last_index = addr | bytes | mask;
        P_FIXED:
          f_mi_be_last_index = {P_MI_SIZE{1'b1}};
      endcase
    end
  endfunction
 
  // Byte-enable mask for the last fully-packed MI transfer (mask off ragged-tail burst).
  function [P_MI_BYTES-1:0] f_mi_be_last_mask
    (
      input [P_MI_SIZE-1:0] index
    );
    integer i;
    begin
      for (i=0; i<P_MI_BYTES; i=i+1) begin
        f_mi_be_last_mask[i] = (i <= {1'b0, index});
      end
    end
  endfunction
 
  // Byte-enable pattern, within the SI data-width, of the transfer at the wrap boundary.
  function [P_SI_BYTES-1:0] f_si_wrap_be
    (
      input [P_SI_SIZE-1:0] addr,
      input [2:0] size,
      input [7:0] len
    );
    integer i;
    reg [P_MAX_RBUFFER_BYTES_LOG-1:0] addr_i;
    begin
      addr_i = addr;
      for (i=0; i<P_SI_BYTES; i=i+1) begin
        case (P_SI_SIZE)
          2: case (size[1:0])
            2'h0:    f_si_wrap_be[i] =                                                                                   len[1] ? (            2'b0  == i[1:0]) : ({addr_i[1:1], 1'b0} == i[1:0]);
            2'h1:    f_si_wrap_be[i] =                                                                                                                            (            1'b0  == i[1:1]);
            default: f_si_wrap_be[i] = 1'b1;
          endcase
          3: case (size[1:0])
            2'h0:    f_si_wrap_be[i] =                                          len[2] ? (            3'b0  == i[2:0]) : len[1] ? ({addr_i[2:2], 2'b0} == i[2:0]) : ({addr_i[2:1], 1'b0} == i[2:0]);
            2'h1:    f_si_wrap_be[i] =                                                                                   len[1] ? (            2'b0  == i[2:1]) : ({addr_i[2:2], 1'b0} == i[2:1]);
            2'h2:    f_si_wrap_be[i] =                                                                                                                            (            1'b0  == i[2:2]);
            default: f_si_wrap_be[i] = 1'b1;
          endcase
          4: case (size)
            3'h0:    f_si_wrap_be[i] = len[3] ? (            4'b0  == i[3:0]) : len[2] ? ({addr_i[3:3], 3'b0} == i[3:0]) : len[1] ? ({addr_i[3:2], 2'b0} == i[3:0]) : ({addr_i[3:1], 1'b0} == i[3:0]);
            3'h1:    f_si_wrap_be[i] =                                          len[2] ? (            3'b0  == i[3:1]) : len[1] ? ({addr_i[3:3], 2'b0} == i[3:1]) : ({addr_i[3:2], 1'b0} == i[3:1]);
            3'h2:    f_si_wrap_be[i] =                                                                                   len[1] ? (            2'b0  == i[3:2]) : ({addr_i[3:3], 1'b0} == i[3:2]);
            3'h3:    f_si_wrap_be[i] =                                                                                                                            (            1'b0  == i[3:3]);
            default: f_si_wrap_be[i] = 1'b1;
          endcase
          5: case (size)
            3'h0:    f_si_wrap_be[i] = len[3] ? ({addr_i[4:4], 4'b0} == i[4:0]) : len[2] ? ({addr_i[4:3], 3'b0} == i[4:0]) : len[1] ? ({addr_i[4:2], 2'b0} == i[4:0]) : ({addr_i[4:1], 1'b0} == i[4:0]);
            3'h1:    f_si_wrap_be[i] = len[3] ? (            4'b0  == i[4:1]) : len[2] ? ({addr_i[4:4], 3'b0} == i[4:1]) : len[1] ? ({addr_i[4:3], 2'b0} == i[4:1]) : ({addr_i[4:2], 1'b0} == i[4:1]);
            3'h2:    f_si_wrap_be[i] =                                          len[2] ? (            3'b0  == i[4:2]) : len[1] ? ({addr_i[4:4], 2'b0} == i[4:2]) : ({addr_i[4:3], 1'b0} == i[4:2]);
            3'h3:    f_si_wrap_be[i] =                                                                                   len[1] ? (            2'b0  == i[4:3]) : ({addr_i[4:4], 1'b0} == i[4:3]);
            3'h4:    f_si_wrap_be[i] =                                                                                                                            (            1'b0  == i[4:4]);
            default: f_si_wrap_be[i] = 1'b1;
          endcase
          6: case (size)
            3'h0:    f_si_wrap_be[i] = len[3] ? ({addr_i[5:4], 4'b0} == i[5:0]) : len[2] ? ({addr_i[5:3], 3'b0} == i[5:0]) : len[1] ? ({addr_i[5:2], 2'b0} == i[5:0]) : ({addr_i[5:1], 1'b0} == i[5:0]);
            3'h1:    f_si_wrap_be[i] = len[3] ? ({addr_i[5:5], 4'b0} == i[5:1]) : len[2] ? ({addr_i[5:4], 3'b0} == i[5:1]) : len[1] ? ({addr_i[5:3], 2'b0} == i[5:1]) : ({addr_i[5:2], 1'b0} == i[5:1]);
            3'h2:    f_si_wrap_be[i] = len[3] ? (            4'b0  == i[5:2]) : len[2] ? ({addr_i[5:5], 3'b0} == i[5:2]) : len[1] ? ({addr_i[5:4], 2'b0} == i[5:2]) : ({addr_i[5:3], 1'b0} == i[5:2]);
            3'h3:    f_si_wrap_be[i] =                                          len[2] ? (            3'b0  == i[5:3]) : len[1] ? ({addr_i[5:5], 2'b0} == i[5:3]) : ({addr_i[5:4], 1'b0} == i[5:3]);
            3'h4:    f_si_wrap_be[i] =                                                                                   len[1] ? (            2'b0  == i[5:4]) : ({addr_i[5:5], 1'b0} == i[5:4]);
            3'h5:    f_si_wrap_be[i] =                                                                                                                            (            1'b0  == i[5:5]);
            default: f_si_wrap_be[i] = 1'b1;
          endcase
        endcase
      end
    end
  endfunction
 
  // Byte-enable pattern, within the MI data-width, of the transfer at the wrap boundary.
  function [P_MI_BYTES-1:0] f_mi_wrap_be
    (
      input [P_MI_SIZE-1:0] addr,
      input [2:0] size,
      input [7:0] len
    );
    integer i;
    reg [P_MAX_RBUFFER_BYTES_LOG-1:0] addr_i;
    begin
      addr_i = addr;
      for (i=0; i<P_MI_BYTES; i=i+1) begin
        case (P_MI_SIZE)
          3: case (size)
            3'h0:    f_mi_wrap_be[i] =                                          len[2] ? (            3'b0  == i[2:0]) : len[1] ? ({addr_i[2:2], 2'b0} == i[2:0]) : ({addr_i[2:1], 1'b0} == i[2:0]);
            3'h1:    f_mi_wrap_be[i] =                                                                                   len[1] ? (            2'b0  == i[2:1]) : ({addr_i[2:2], 1'b0} == i[2:1]);
            3'h2:    f_mi_wrap_be[i] =                                                                                                                            (            1'b0  == i[2:2]);
            default: f_mi_wrap_be[i] = 1'b1;
          endcase
          4: case (size)
            3'h0:    f_mi_wrap_be[i] = len[3] ? (            4'b0  == i[3:0]) : len[2] ? ({addr_i[3:3], 3'b0} == i[3:0]) : len[1] ? ({addr_i[3:2], 2'b0} == i[3:0]) : ({addr_i[3:1], 1'b0} == i[3:0]);
            3'h1:    f_mi_wrap_be[i] =                                          len[2] ? (            3'b0  == i[3:1]) : len[1] ? ({addr_i[3:3], 2'b0} == i[3:1]) : ({addr_i[3:2], 1'b0} == i[3:1]);
            3'h2:    f_mi_wrap_be[i] =                                                                                   len[1] ? (            2'b0  == i[3:2]) : ({addr_i[3:3], 1'b0} == i[3:2]);
            3'h3:    f_mi_wrap_be[i] =                                                                                                                            (            1'b0  == i[3:3]);
            default: f_mi_wrap_be[i] = 1'b1;
          endcase
          5: case (size)
            3'h0:    f_mi_wrap_be[i] = len[3] ? ({addr_i[4:4], 4'b0} == i[4:0]) : len[2] ? ({addr_i[4:3], 3'b0} == i[4:0]) : len[1] ? ({addr_i[4:2], 2'b0} == i[4:0]) : ({addr_i[4:1], 1'b0} == i[4:0]);
            3'h1:    f_mi_wrap_be[i] = len[3] ? (            4'b0  == i[4:1]) : len[2] ? ({addr_i[4:4], 3'b0} == i[4:1]) : len[1] ? ({addr_i[4:3], 2'b0} == i[4:1]) : ({addr_i[4:2], 1'b0} == i[4:1]);
            3'h2:    f_mi_wrap_be[i] =                                          len[2] ? (            3'b0  == i[4:2]) : len[1] ? ({addr_i[4:4], 2'b0} == i[4:2]) : ({addr_i[4:3], 1'b0} == i[4:2]);
            3'h3:    f_mi_wrap_be[i] =                                                                                   len[1] ? (            2'b0  == i[4:3]) : ({addr_i[4:4], 1'b0} == i[4:3]);
            3'h4:    f_mi_wrap_be[i] =                                                                                                                            (            1'b0  == i[4:4]);
            default: f_mi_wrap_be[i] = 1'b1;
          endcase
          6: case (size)
            3'h0:    f_mi_wrap_be[i] = len[3] ? ({addr_i[5:4], 4'b0} == i[5:0]) : len[2] ? ({addr_i[5:3], 3'b0} == i[5:0]) : len[1] ? ({addr_i[5:2], 2'b0} == i[5:0]) : ({addr_i[5:1], 1'b0} == i[5:0]);
            3'h1:    f_mi_wrap_be[i] = len[3] ? ({addr_i[5:5], 4'b0} == i[5:1]) : len[2] ? ({addr_i[5:4], 3'b0} == i[5:1]) : len[1] ? ({addr_i[5:3], 2'b0} == i[5:1]) : ({addr_i[5:2], 1'b0} == i[5:1]);
            3'h2:    f_mi_wrap_be[i] = len[3] ? (            4'b0  == i[5:2]) : len[2] ? ({addr_i[5:5], 3'b0} == i[5:2]) : len[1] ? ({addr_i[5:4], 2'b0} == i[5:2]) : ({addr_i[5:3], 1'b0} == i[5:2]);
            3'h3:    f_mi_wrap_be[i] =                                          len[2] ? (            3'b0  == i[5:3]) : len[1] ? ({addr_i[5:5], 2'b0} == i[5:3]) : ({addr_i[5:4], 1'b0} == i[5:3]);
            3'h4:    f_mi_wrap_be[i] =                                                                                   len[1] ? (            2'b0  == i[5:4]) : ({addr_i[5:5], 1'b0} == i[5:4]);
            3'h5:    f_mi_wrap_be[i] =                                                                                                                            (            1'b0  == i[5:5]);
            default: f_mi_wrap_be[i] = 1'b1;
          endcase
          7: case (size)
            3'h0:    f_mi_wrap_be[i] = len[3] ? ({addr_i[6:4], 4'b0} == i[6:0]) : len[2] ? ({addr_i[6:3], 3'b0} == i[6:0]) : len[1] ? ({addr_i[6:2], 2'b0} == i[6:0]) : ({addr_i[6:1], 1'b0} == i[6:0]);
            3'h1:    f_mi_wrap_be[i] = len[3] ? ({addr_i[6:5], 4'b0} == i[6:1]) : len[2] ? ({addr_i[6:4], 3'b0} == i[6:1]) : len[1] ? ({addr_i[6:3], 2'b0} == i[6:1]) : ({addr_i[6:2], 1'b0} == i[6:1]);
            3'h2:    f_mi_wrap_be[i] = len[3] ? ({addr_i[6:6], 4'b0} == i[6:2]) : len[2] ? ({addr_i[6:5], 3'b0} == i[6:2]) : len[1] ? ({addr_i[6:4], 2'b0} == i[6:2]) : ({addr_i[6:3], 1'b0} == i[6:2]);
            3'h3:    f_mi_wrap_be[i] = len[3] ? (            4'b0  == i[6:3]) : len[2] ? ({addr_i[6:6], 3'b0} == i[6:3]) : len[1] ? ({addr_i[6:5], 2'b0} == i[6:3]) : ({addr_i[6:4], 1'b0} == i[6:3]);
            3'h4:    f_mi_wrap_be[i] =                                          len[2] ? (            3'b0  == i[6:4]) : len[1] ? ({addr_i[6:6], 2'b0} == i[6:4]) : ({addr_i[6:5], 1'b0} == i[6:4]);
            3'h5:    f_mi_wrap_be[i] =                                                                                   len[1] ? (            2'b0  == i[6:5]) : ({addr_i[6:6], 1'b0} == i[6:5]);
            3'h6:    f_mi_wrap_be[i] =                                                                                                                            (            1'b0  == i[6:6]);
            default: f_mi_wrap_be[i] = 1'b1;
          endcase
        endcase
      end
    end
  endfunction
 
  // Number of SI transfers until wrapping (0 = wrap after first transfer; 4'hF = no wrapping)
  function [3:0] f_si_wrap_cnt
    (
      input [(P_MI_SIZE+4-1):0] addr,
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
      f_si_wrap_cnt = {len[3:1], 1'b1} & ~start;
    end
  endfunction
 
  // Number of MI transfers until wrapping (0 = wrap after first transfer; 4'hF = no wrapping)
  function [3:0] f_mi_wrap_cnt
    (
      input [(P_MI_SIZE+4-1):0] addr,
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
      f_mi_wrap_cnt = {len[3:1], 1'b1} & ~start;
    end
  endfunction
 
  // Mask of address bits used to point to buffer line (MI data-width) of first SI wrap transfer.
  function [2:0] f_si_wrap_mask
    (
      input [2:0] size,
      input [7:0] len
    );
    begin
      case (P_RATIO_LOG)
        1: case (P_SI_SIZE)
          6: case (size)
            3'h6:    f_si_wrap_mask = len[3:1];
            3'h5:    f_si_wrap_mask = len[3:2];
            3'h4:    f_si_wrap_mask = len[3:3];
            default: f_si_wrap_mask = 0    ;
          endcase
          5: case (size)
            3'h5:    f_si_wrap_mask = len[3:1];
            3'h4:    f_si_wrap_mask = len[3:2];
            3'h3:    f_si_wrap_mask = len[3:3];
            default: f_si_wrap_mask = 0    ;
          endcase
          4: case (size)
            3'h4:    f_si_wrap_mask = len[3:1];
            3'h3:    f_si_wrap_mask = len[3:2];
            3'h2:    f_si_wrap_mask = len[3:3];
            default: f_si_wrap_mask = 0    ;
          endcase
          3: case (size[1:0])
            2'h3:    f_si_wrap_mask = len[3:1];
            2'h2:    f_si_wrap_mask = len[3:2];
            2'h1:    f_si_wrap_mask = len[3:3];
            default: f_si_wrap_mask = 0    ;
          endcase
          2: case (size[1:0])
            2'h2:    f_si_wrap_mask = len[3:1];
            2'h1:    f_si_wrap_mask = len[3:2];
            default: f_si_wrap_mask = len[3:3];
          endcase
        endcase
        2: case (P_SI_SIZE)
          5: case (size)
            3'h5:    f_si_wrap_mask = len[3:2];
            3'h4:    f_si_wrap_mask = len[3:3];
            default: f_si_wrap_mask = 0    ;
          endcase
          4: case (size)
            3'h4:    f_si_wrap_mask = len[3:2];
            3'h3:    f_si_wrap_mask = len[3:3];
            default: f_si_wrap_mask = 0    ;
          endcase
          3: case (size[1:0])
            2'h3:    f_si_wrap_mask = len[3:2];
            2'h2:    f_si_wrap_mask = len[3:3];
            default: f_si_wrap_mask = 0    ;
          endcase
          2: case (size[1:0])
            2'h2:    f_si_wrap_mask = len[3:2];
            2'h1:    f_si_wrap_mask = len[3:3];
            default: f_si_wrap_mask = 0    ;
          endcase
        endcase
        3: case (P_SI_SIZE)
          4: case (size)
            3'h4:    f_si_wrap_mask = len[3:3];
            default: f_si_wrap_mask = 0    ;
          endcase
          3: case (size[1:0])
            2'h3:    f_si_wrap_mask = len[3:3];
            default: f_si_wrap_mask = 0    ;
          endcase
          2: case (size[1:0])
            2'h2:    f_si_wrap_mask = len[3:3];
            default: f_si_wrap_mask = 0    ;
          endcase
        endcase
        default: f_si_wrap_mask = 0    ;
      endcase
    end
  endfunction
 
  // Mask of address bits used to point to buffer line of first MI wrap transfer.
  function [2:0] f_mi_wrap_mask
    (
      input [2:0] size,
      input [7:0] len
    );
    begin
      case (P_RATIO_LOG)
        1: case (P_MI_SIZE)
          7: case (size)
            3'h7:    f_mi_wrap_mask = {len[2:1], 1'b1};
            3'h6:    f_mi_wrap_mask = len[3:1];
            3'h5:    f_mi_wrap_mask = len[3:2];
            3'h4:    f_mi_wrap_mask = len[3:3];
            default: f_mi_wrap_mask = 0    ;
          endcase
          6: case (size)
            3'h6:    f_mi_wrap_mask = {len[2:1], 1'b1};
            3'h5:    f_mi_wrap_mask = len[3:1];
            3'h4:    f_mi_wrap_mask = len[3:2];
            3'h3:    f_mi_wrap_mask = len[3:3];
            default: f_mi_wrap_mask = 0    ;
          endcase
          5: case (size)
            3'h5:    f_mi_wrap_mask = {len[2:1], 1'b1};
            3'h4:    f_mi_wrap_mask = len[3:1];
            3'h3:    f_mi_wrap_mask = len[3:2];
            3'h2:    f_mi_wrap_mask = len[3:3];
            default: f_mi_wrap_mask = 0    ;
          endcase
          4: case (size)
            3'h4:    f_mi_wrap_mask = {len[2:1], 1'b1};
            3'h3:    f_mi_wrap_mask = len[3:1];
            3'h2:    f_mi_wrap_mask = len[3:2];
            3'h1:    f_mi_wrap_mask = len[3:3];
            default: f_mi_wrap_mask = 0    ;
          endcase
          3: case (size[1:0])
            2'h3:    f_mi_wrap_mask = {len[2:1], 1'b1};
            2'h2:    f_mi_wrap_mask = len[3:1];
            2'h1:    f_mi_wrap_mask = len[3:2];
            default: f_mi_wrap_mask = len[3:3];
          endcase
        endcase
        2: case (P_MI_SIZE)
          7: case (size)
            3'h7:    f_mi_wrap_mask = {len[1:1], 1'b1};
            3'h5:    f_mi_wrap_mask = len[3:2];
            3'h4:    f_mi_wrap_mask = len[3:3];
            default: f_mi_wrap_mask = 0    ;
          endcase
          6: case (size)
            3'h6:    f_mi_wrap_mask = {len[1:1], 1'b1};
            3'h4:    f_mi_wrap_mask = len[3:2];
            3'h3:    f_mi_wrap_mask = len[3:3];
            default: f_mi_wrap_mask = 0    ;
          endcase
          5: case (size)
            3'h5:    f_mi_wrap_mask = {len[1:1], 1'b1};
            3'h3:    f_mi_wrap_mask = len[3:2];
            3'h2:    f_mi_wrap_mask = len[3:3];
            default: f_mi_wrap_mask = 0    ;
          endcase
          4: case (size)
            3'h4:    f_mi_wrap_mask = {len[1:1], 1'b1};
            3'h2:    f_mi_wrap_mask = len[3:2];
            3'h1:    f_mi_wrap_mask = len[3:3];
            default: f_mi_wrap_mask = 0    ;
          endcase
        endcase
        3: case (P_MI_SIZE)
          7: case (size)
            3'h7:    f_mi_wrap_mask = 1'b1;
            3'h4:    f_mi_wrap_mask = len[3:3];
            default: f_mi_wrap_mask = 0    ;
          endcase
          6: case (size)
            3'h6:    f_mi_wrap_mask = 1'b1;
            3'h3:    f_mi_wrap_mask = len[3:3];
            default: f_mi_wrap_mask = 0    ;
          endcase
          5: case (size)
            3'h5:    f_mi_wrap_mask = 1'b1;
            3'h2:    f_mi_wrap_mask = len[3:3];
            default: f_mi_wrap_mask = 0    ;
          endcase
        endcase
        default: f_mi_wrap_mask = 0    ;
      endcase
    end
  endfunction
 
  // Index of SI transfer within buffer line following wrap
  function [P_MI_SIZE-P_SI_SIZE-1:0] f_si_wrap_word
    (
      input [(P_MI_SIZE+4-1):0] addr,
      input [2:0] size,
      input [7:0] len
    );
    reg [P_MI_SIZE-P_SI_SIZE-1:0] mask;
    begin
      case (P_SI_SIZE)
        2: case (size[1:0])
          3'h2:    mask =  {len[3:1], {1{1'b1}}};
          3'h1:    mask =  len[3:1];
          default: mask =  len[3:2];
        endcase            
        3: case (size)     
          3'h3:    mask =  {len[3:1], {1{1'b1}}};
          3'h2:    mask =  len[3:1];
          3'h1:    mask =  len[3:2];
          default: mask =  len[3:3];
        endcase            
        4: case (size)     
          3'h4:    mask =  {len[3:1], {1{1'b1}}};
          3'h3:    mask =  len[3:1];
          3'h2:    mask =  len[3:2];
          3'h1:    mask =  len[3:3];
          default: mask =  0;
        endcase            
        5: case (size)     
          3'h5:    mask =  {len[3:1], {1{1'b1}}};
          3'h4:    mask =  len[3:1];
          3'h3:    mask =  len[3:2];
          3'h2:    mask =  len[3:3];
          default: mask =  0;
        endcase            
        6: case (size)     
          3'h6:    mask =  {len[3:1], {1{1'b1}}};
          3'h5:    mask =  len[3:1];
          3'h4:    mask =  len[3:2];
          3'h3:    mask =  len[3:3];
          default: mask =  0;
        endcase
      endcase
      f_si_wrap_word = addr[P_MI_SIZE-1 : P_SI_SIZE] & ~mask;
    end
  endfunction
 
  // Complete byte-enable pattern for writing SI data word to buffer (MI data-width).
  function [P_MI_BYTES-1:0] f_si_we
    (
      input [P_RATIO_LOG-1:0] word,  // Index of SI transfer within buffer line
      input [P_SI_BYTES-1:0] be     // Byte-enable pattern within SI transfer (SI data-width)
    );
    integer i;
    begin
      for (i=0; i<P_RATIO; i=i+1) begin
        f_si_we[i*P_SI_BYTES +: P_SI_BYTES] = (i == word) ? be : 0;
      end
    end
  endfunction
 
  // Rotate byte-enable mask around SI-width boundary.
  function [P_SI_BYTES-1:0] f_si_be_rot
    (
      input [P_SI_BYTES-1:0] be,     // Byte-enable pattern within SI transfer (SI data-width)
      input [2:0] size
    );
    reg [63:0] be_i;
    begin
      be_i = be;
      case (P_SI_SIZE)
        2: case (size[1:0])
          2'h0:    f_si_be_rot = {be_i[0 +: ( 4 -  1)], be_i[ 3 -:  1]};
          2'h1:    f_si_be_rot = {be_i[0 +: ( 4 -  2)], be_i[ 3 -:  2]};
          default: f_si_be_rot =  {4{1'b1}};
        endcase
        3: case (size[1:0])
          2'h0:    f_si_be_rot = {be_i[0 +: ( 8 -  1)], be_i[ 7 -:  1]};
          2'h1:    f_si_be_rot = {be_i[0 +: ( 8 -  2)], be_i[ 7 -:  2]};
          2'h2:    f_si_be_rot = {be_i[0 +: ( 8 -  4)], be_i[ 7 -:  4]};
          default: f_si_be_rot =  {8{1'b1}};
        endcase
        4: case (size)
          3'h0:    f_si_be_rot = {be_i[0 +: (16 -  1)], be_i[15 -:  1]};
          3'h1:    f_si_be_rot = {be_i[0 +: (16 -  2)], be_i[15 -:  2]};
          3'h2:    f_si_be_rot = {be_i[0 +: (16 -  4)], be_i[15 -:  4]};
          3'h3:    f_si_be_rot = {be_i[0 +: (16 -  8)], be_i[15 -:  8]};
          default: f_si_be_rot =  {16{1'b1}};
        endcase
        5: case (size)
          3'h0:    f_si_be_rot = {be_i[0 +: (32 -  1)], be_i[31 -:  1]};
          3'h1:    f_si_be_rot = {be_i[0 +: (32 -  2)], be_i[31 -:  2]};
          3'h2:    f_si_be_rot = {be_i[0 +: (32 -  4)], be_i[31 -:  4]};
          3'h3:    f_si_be_rot = {be_i[0 +: (32 -  8)], be_i[31 -:  8]};
          3'h4:    f_si_be_rot = {be_i[0 +: (32 - 16)], be_i[31 -: 16]};
          default: f_si_be_rot =  {32{1'b1}};
        endcase
        6: case (size)
          3'h0:    f_si_be_rot = {be_i[0 +: (64 -  1)], be_i[63 -:  1]};
          3'h1:    f_si_be_rot = {be_i[0 +: (64 -  2)], be_i[63 -:  2]};
          3'h2:    f_si_be_rot = {be_i[0 +: (64 -  4)], be_i[63 -:  4]};
          3'h3:    f_si_be_rot = {be_i[0 +: (64 -  8)], be_i[63 -:  8]};
          3'h4:    f_si_be_rot = {be_i[0 +: (64 - 16)], be_i[63 -: 16]};
          3'h5:    f_si_be_rot = {be_i[0 +: (64 - 32)], be_i[63 -: 32]};
          default: f_si_be_rot =  {64{1'b1}};
        endcase
      endcase
    end
  endfunction
 
  // Rotate byte-enable mask around MI-width boundary.
  function [P_MI_BYTES-1:0] f_mi_be_rot
    (
      input [P_MI_BYTES-1:0] be,     // Byte-enable pattern within MI transfer
      input [2:0] size
    );
    reg [127:0] be_i;
    begin
      be_i = be;
      case (P_MI_SIZE)
        3: case (size)
          3'h0:    f_mi_be_rot = {be_i[0 +: (  8 -  1)], be_i[  7 -:  1]};
          3'h1:    f_mi_be_rot = {be_i[0 +: (  8 -  2)], be_i[  7 -:  2]};
          3'h2:    f_mi_be_rot = {be_i[0 +: (  8 -  4)], be_i[  7 -:  4]};
          default: f_mi_be_rot =  {8{1'b1}};
        endcase
        4: case (size)
          3'h0:    f_mi_be_rot = {be_i[0 +: ( 16 -  1)], be_i[ 15 -:  1]};
          3'h1:    f_mi_be_rot = {be_i[0 +: ( 16 -  2)], be_i[ 15 -:  2]};
          3'h2:    f_mi_be_rot = {be_i[0 +: ( 16 -  4)], be_i[ 15 -:  4]};
          3'h3:    f_mi_be_rot = {be_i[0 +: ( 16 -  8)], be_i[ 15 -:  8]};
          default: f_mi_be_rot =  {16{1'b1}};
        endcase
        5: case (size)
          3'h0:    f_mi_be_rot = {be_i[0 +: ( 32 -  1)], be_i[ 31 -:  1]};
          3'h1:    f_mi_be_rot = {be_i[0 +: ( 32 -  2)], be_i[ 31 -:  2]};
          3'h2:    f_mi_be_rot = {be_i[0 +: ( 32 -  4)], be_i[ 31 -:  4]};
          3'h3:    f_mi_be_rot = {be_i[0 +: ( 32 -  8)], be_i[ 31 -:  8]};
          3'h4:    f_mi_be_rot = {be_i[0 +: ( 32 - 16)], be_i[ 31 -: 16]};
          default: f_mi_be_rot =  {32{1'b1}};
        endcase
        6: case (size)
          3'h0:    f_mi_be_rot = {be_i[0 +: ( 64 -  1)], be_i[ 63 -:  1]};
          3'h1:    f_mi_be_rot = {be_i[0 +: ( 64 -  2)], be_i[ 63 -:  2]};
          3'h2:    f_mi_be_rot = {be_i[0 +: ( 64 -  4)], be_i[ 63 -:  4]};
          3'h3:    f_mi_be_rot = {be_i[0 +: ( 64 -  8)], be_i[ 63 -:  8]};
          3'h4:    f_mi_be_rot = {be_i[0 +: ( 64 - 16)], be_i[ 63 -: 16]};
          3'h5:    f_mi_be_rot = {be_i[0 +: ( 64 - 32)], be_i[ 63 -: 32]};
          default: f_mi_be_rot =  {64{1'b1}};
        endcase
        7: case (size)
          3'h0:    f_mi_be_rot = {be_i[0 +: (128 -  1)], be_i[127 -:  1]};
          3'h1:    f_mi_be_rot = {be_i[0 +: (128 -  2)], be_i[127 -:  2]};
          3'h2:    f_mi_be_rot = {be_i[0 +: (128 -  4)], be_i[127 -:  4]};
          3'h3:    f_mi_be_rot = {be_i[0 +: (128 -  8)], be_i[127 -:  8]};
          3'h4:    f_mi_be_rot = {be_i[0 +: (128 - 16)], be_i[127 -: 16]};
          3'h5:    f_mi_be_rot = {be_i[0 +: (128 - 32)], be_i[127 -: 32]};
          3'h6:    f_mi_be_rot = {be_i[0 +: (128 - 64)], be_i[127 -: 64]};
          default: f_mi_be_rot =  {128{1'b1}};
        endcase
      endcase
    end
  endfunction
 
  function [P_SI_BYTES*9-1:0] f_wpayload
    (
      input [C_S_AXI_DATA_WIDTH-1:0] wdata,
      input [C_S_AXI_DATA_WIDTH/8-1:0] wstrb
    );
    integer i;
    begin
      for (i=0; i<P_SI_BYTES; i=i+1) begin
        f_wpayload[i*9 +: 9] = {wstrb[i], wdata[i*8 +: 8]};
      end
    end
  endfunction
 
  function [C_M_AXI_DATA_WIDTH-1:0] f_wdata
    (
      input [P_MI_BYTES*9-1:0] wpayload
    );
    integer i;
    begin
      for (i=0; i<P_MI_BYTES; i=i+1) begin
        f_wdata[i*8 +: 8] = wpayload[i*9 +: 8];
      end
    end
  endfunction
 
  function [C_M_AXI_DATA_WIDTH/8-1:0] f_wstrb
    (
      input [P_MI_BYTES*9-1:0] wpayload
    );
    integer i;
    begin
      for (i=0; i<P_MI_BYTES; i=i+1) begin
        f_wstrb[i] = wpayload[i*9+8];
      end
    end
  endfunction
  
  generate
  
  if (C_CLK_CONV) begin : gen_clock_conv
    if (C_AXI_IS_ACLK_ASYNC) begin : gen_async_conv
      
      assign m_aclk = M_AXI_ACLK;
      assign m_aresetn = M_AXI_ARESETN;
      assign s_aresetn = S_AXI_ARESETN;
      assign aw_fifo_s_aclk = S_AXI_ACLK;
      assign aw_fifo_m_aclk = M_AXI_ACLK;
      assign aw_fifo_aresetn = S_AXI_ARESETN & M_AXI_ARESETN;
      assign awpop_reset = ~S_AXI_ARESETN | ~M_AXI_ARESETN;
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
      assign aw_fifo_s_aclk = fast_aclk;
      assign aw_fifo_m_aclk = 1'b0;
      assign aw_fifo_aresetn = fast_aresetn_r;
      assign s_sample_cycle_early = P_SI_LT_MI ? 1'b1 : SAMPLE_CYCLE_EARLY;
      assign s_sample_cycle       = P_SI_LT_MI ? 1'b1 : SAMPLE_CYCLE;
      assign m_sample_cycle_early = P_SI_LT_MI ? SAMPLE_CYCLE_EARLY : 1'b1;
      assign m_sample_cycle       = P_SI_LT_MI ? SAMPLE_CYCLE : 1'b1;
  
      always @(posedge fast_aclk) begin
        if (~S_AXI_ARESETN | ~M_AXI_ARESETN) begin
          fast_aresetn_r <= 1'b0;
        end else if (S_AXI_ARESETN & M_AXI_ARESETN & SAMPLE_CYCLE_EARLY) begin
          fast_aresetn_r <= 1'b1;
        end
      end
    end
  
  end else begin : gen_no_clk_conv
    
    assign m_aclk = S_AXI_ACLK;
    assign m_aresetn = S_AXI_ARESETN;
    assign s_aresetn = S_AXI_ARESETN;
    assign aw_fifo_s_aclk = S_AXI_ACLK;
    assign aw_fifo_m_aclk = 1'b0;
    assign aw_fifo_aresetn = S_AXI_ARESETN;
    assign fast_aclk = S_AXI_ACLK;
    assign s_sample_cycle_early = 1'b1;
    assign s_sample_cycle       = 1'b1;
    assign m_sample_cycle_early = 1'b1;
    assign m_sample_cycle       = 1'b1;
    
  end

    assign S_AXI_WREADY = S_AXI_WREADY_i;
    assign S_AXI_AWLOCK_i = S_AXI_AWLOCK[0];
    assign si_buf_en = S_AXI_WVALID & S_AXI_WREADY_i;
    assign cmd_ready = cmd_ready_i;
    assign s_awready_reg = aw_push;
    assign si_last_index = f_mi_be_last_index(cmd_si_addr[0 +: P_MI_SIZE], cmd_si_size, cmd_si_len, cmd_si_burst);
    assign push_ready = s_awvalid_reg & aw_ready & (buf_cnt != P_AWFIFO_TRESHOLD);

        
    always @ * begin
      aw_push = 1'b0;
      load_si_ptr = 1'b0;
      si_state_ns = si_state;
      S_AXI_WREADY_ns = S_AXI_WREADY_i;
      case (si_state)
        S_IDLE: begin
          if (S_AXI_AWVALID) begin
            load_si_ptr = 1'b1;
            S_AXI_WREADY_ns = 1'b1;
            si_state_ns = S_WRITING;
          end
        end
        S_WRITING: begin
          if (S_AXI_WVALID & S_AXI_WREADY_i & S_AXI_WLAST) begin
            if (push_ready) begin
              aw_push = m_sample_cycle;  // Sample strobe when AW FIFO is on faster M_AXI_ACLK.
              if (S_AXI_AWVALID) begin
                load_si_ptr = 1'b1;
              end else begin
                S_AXI_WREADY_ns = 1'b0;  //stall W-channel waiting for new AW command
                si_state_ns = S_IDLE;
              end
            end else begin
              S_AXI_WREADY_ns = 1'b0;  //stall W-channel waiting for AW FIFO push
              si_state_ns = S_AWFULL;
            end
          end
        end
        S_AWFULL: begin
          if (push_ready) begin
            aw_push = m_sample_cycle;  // Sample strobe when AW FIFO is on faster M_AXI_ACLK.
            if (S_AXI_AWVALID) begin
              load_si_ptr = 1'b1;
              S_AXI_WREADY_ns = 1'b1;
              si_state_ns = S_WRITING;
            end else begin
              S_AXI_WREADY_ns = 1'b0;  //stall W-channel waiting for new AW command
              si_state_ns = S_IDLE;
            end
          end
        end
        default: si_state_ns = S_IDLE;
      endcase
    end
    
    always @ (posedge S_AXI_ACLK) begin
      if (~s_aresetn) begin
        si_state <= S_IDLE;
        S_AXI_WREADY_i <= 1'b0;
        si_buf <= 0;
        buf_cnt <= 0;
        cmd_ready_i <= 1'b0;
      end else begin
        si_state <= si_state_ns;
        S_AXI_WREADY_i <= S_AXI_WREADY_ns;
        cmd_ready_i <= aw_pop_resync;

        if (aw_push) begin
          si_buf <= si_buf + 1;
        end
        
        if (aw_push & ~aw_pop_resync) begin
          buf_cnt <= buf_cnt + 1;
        end else if (~aw_push & aw_pop_resync & |buf_cnt) begin
          buf_cnt <= buf_cnt - 1;
        end
      end
    end
    
    always @ (posedge S_AXI_ACLK) begin
      if (load_si_ptr) begin
        if (cmd_si_burst == P_WRAP) begin
          si_ptr <= cmd_si_addr[P_MI_SIZE +: 3] & f_si_wrap_mask(cmd_si_size, cmd_si_len);
        end else begin
          si_ptr <= 0;
        end
        si_burst <= cmd_si_burst;
        si_size <= cmd_si_size;
        si_be <= f_si_be_init(cmd_si_addr[0 +: P_SI_SIZE], cmd_si_size);
        si_word <= cmd_si_addr[P_MI_SIZE-1 : P_SI_SIZE];
        si_wrap_cnt <= f_si_wrap_cnt(cmd_si_addr[0 +: (P_MI_SIZE + 4)], cmd_si_size, cmd_si_len);
        si_wrap_be_next <= f_si_wrap_be(cmd_si_addr[0 +: P_SI_SIZE], cmd_si_size, cmd_si_len);
        si_wrap_word_next <= f_si_wrap_word(cmd_si_addr[0 +: (P_MI_SIZE + 4)], cmd_si_size, cmd_si_len);
      end else if (si_buf_en) begin
        if (si_burst == P_FIXED) begin
          si_ptr <= si_ptr + 1;
        end else if ((si_burst == P_WRAP) && (si_wrap_cnt == 0)) begin
          si_ptr <= 0;
          si_be <= si_wrap_be_next;
          si_word <= si_wrap_word_next;
        end else begin
          if (si_be[P_SI_BYTES-1]) begin
            if (&si_word) begin
              si_ptr <= si_ptr + 1;  // Wrap long INCR bursts around end of buffer
            end
            si_word <= si_word + 1;
          end
          si_be <= f_si_be_rot(si_be, si_size);
        end
        si_wrap_cnt <= si_wrap_cnt - 1;
      end
    end
    
    always @ * begin
      mi_state_ns = mi_state;
      M_AXI_AWVALID_ns = M_AXI_AWVALID_i;
      M_AXI_WVALID_ns = M_AXI_WVALID_i;
      aw_pop = 1'b0;
      load_mi_ptr = 1'b0;
      load_mi_next = 1'b0;
      case (mi_state)
        M_IDLE: begin  // mi_state = 0
          M_AXI_AWVALID_ns = 1'b0;
          M_AXI_WVALID_ns = 1'b0;
          if (mi_awvalid) begin
            load_mi_ptr = 1'b1;
            mi_state_ns = M_ISSUE1;
          end
        end
        M_ISSUE1: begin  // mi_state = 1
          M_AXI_AWVALID_ns = 1'b1;
          mi_state_ns = M_WRITING1;
        end
        M_WRITING1: begin  // mi_state = 3
          M_AXI_WVALID_ns = 1'b1;
          if (M_AXI_AWREADY) begin
            aw_pop = s_sample_cycle;  // Sample strobe when AW FIFO is on faster S_AXI_ACLK.
            M_AXI_AWVALID_ns = 1'b0;
            if (mi_w_done) begin
              M_AXI_WVALID_ns = 1'b0;
              mi_state_ns = M_IDLE;
            end else begin
              mi_state_ns = M_AW_DONE1;
            end
          end else if (mi_w_done) begin
            M_AXI_WVALID_ns = 1'b0;
            mi_state_ns = M_AW_STALL;
          end
        end
        M_AW_STALL: begin  // mi_state = 2
          if (M_AXI_AWREADY) begin
            aw_pop = s_sample_cycle;  // Sample strobe when AW FIFO is on faster S_AXI_ACLK.
            M_AXI_AWVALID_ns = 1'b0;
            mi_state_ns = M_IDLE;
          end
        end
        M_AW_DONE1: begin  // mi_state = 6
          if (mi_awvalid) begin
            if (mi_w_done) begin
              M_AXI_WVALID_ns = 1'b0;
              load_mi_ptr = 1'b1;
              mi_state_ns = M_ISSUE1;
            end else if (~mi_last & ~mi_last_d1 & ~M_AXI_WLAST_i) begin
              load_mi_next = 1'b1;
              mi_state_ns = M_ISSUE2;
            end
          end else if (mi_w_done) begin
            M_AXI_WVALID_ns = 1'b0;
            mi_state_ns = M_IDLE;
          end
        end
        M_ISSUE2: begin  // mi_state = 7
          M_AXI_AWVALID_ns = 1'b1;
          if (mi_w_done) begin
            M_AXI_WVALID_ns = 1'b0;
            load_mi_ptr = 1'b1;
            mi_state_ns = M_ISSUE1;
          end else begin
            mi_state_ns = M_WRITING2;
          end
        end
        M_WRITING2: begin  // mi_state = 5
          if (M_AXI_AWREADY) begin
            M_AXI_AWVALID_ns = 1'b0;
            if (mi_w_done) begin
            aw_pop = s_sample_cycle;  // Sample strobe when AW FIFO is on faster S_AXI_ACLK.
              mi_state_ns = M_AW_DONE1;
            end else begin
              mi_state_ns = M_AW_DONE2;
            end
          end else if (mi_w_done) begin
            mi_state_ns = M_WRITING1;
          end
        end
        M_AW_DONE2: begin  // mi_state = 4
          if (mi_w_done) begin
            aw_pop = s_sample_cycle;  // Sample strobe when AW FIFO is on faster S_AXI_ACLK.
            mi_state_ns = M_AW_DONE1;
          end
        end
        default: mi_state_ns = M_IDLE;
      endcase
    end
    
    always @ (posedge m_aclk) begin
      if (~m_aresetn) begin
        mi_state <= M_IDLE;
        mi_buf <= 0;
        M_AXI_AWVALID_i <= 1'b0;
        M_AXI_WVALID_i <= 1'b0;
        mi_last <= 1'b0;
        mi_last_d1 <= 1'b0;
        M_AXI_WLAST_i <= 1'b0;
        mi_wstrb_mask_d2 <= {P_MI_BYTES{1'b1}}; 
        first_load_mi_d1 <= 1'b0; 
        next_valid <= 1'b0;
      end else begin
        mi_state <= mi_state_ns;
        M_AXI_AWVALID_i <= M_AXI_AWVALID_ns;
        M_AXI_WVALID_i <= M_AXI_WVALID_ns;
        
        if (mi_buf_en & mi_last) begin
          mi_buf <= mi_buf + 1;
        end
        
        if (load_mi_ptr) begin
          mi_last <= (M_AXI_AWLEN_i == 0);
          M_AXI_WLAST_i <= 1'b0;
        end else if (mi_buf_en) begin
          M_AXI_WLAST_i <= mi_last_d1;
          mi_last_d1 <= mi_last;
          if (first_load_mi_d1) begin
            mi_wstrb_mask_d2 <= mi_be_d1 & 
              (mi_first_d1 ? f_mi_be_first_mask(mi_addr_d1) : {P_MI_BYTES{1'b1}}) & 
              (mi_last_d1 ? f_mi_be_last_mask(mi_last_index_reg_d1) : {P_MI_BYTES{1'b1}});
          end
          if (mi_last) begin
            mi_last <= next_valid & (next_mi_len == 0);
          end else begin
            mi_last <= (mi_wcnt == 1);
          end
        end
      
        if (load_mi_d1) begin
          first_load_mi_d1 <= 1'b1;  // forever
        end
        
        if (mi_last & mi_buf_en) begin
          next_valid <= 1'b0;
        end else if (load_mi_next) begin
          next_valid <= 1'b1;
        end
        
        if (m_sample_cycle) begin
          aw_pop_extend <= 1'b0;
        end else if (aw_pop) begin
          aw_pop_extend <= 1'b1;
        end
      end
    end
    
    assign mi_buf_en = (M_AXI_WVALID_i & M_AXI_WREADY) | load_mi_d1 | load_mi_d2;
    assign mi_w_done = M_AXI_WVALID_i & M_AXI_WREADY & M_AXI_WLAST_i;
    
    always @ (posedge m_aclk) begin
      load_mi_d2 <= load_mi_d1;
      load_mi_d1 <= load_mi_ptr;
      if (load_mi_ptr) begin
        if (M_AXI_AWBURST_i == P_WRAP) begin
          mi_ptr <= M_AXI_AWADDR_i[P_MI_SIZE +: 3] & f_mi_wrap_mask(M_AXI_AWSIZE_i, M_AXI_AWLEN_i);
        end else begin
          mi_ptr <= 0;
        end
        mi_wcnt <= M_AXI_AWLEN_i;
        mi_burst <= M_AXI_AWBURST_i;
        mi_size <= M_AXI_AWSIZE_i;
        mi_be <= f_mi_be_init(M_AXI_AWADDR_i[0 +: P_MI_SIZE], M_AXI_AWSIZE_i);
        mi_wrap_cnt <= f_mi_wrap_cnt(M_AXI_AWADDR_i[0 +: (P_MI_SIZE + 4)], M_AXI_AWSIZE_i, M_AXI_AWLEN_i);
        mi_wrap_be_next <= f_mi_wrap_be(M_AXI_AWADDR_i[0 +: P_MI_SIZE], M_AXI_AWSIZE_i, M_AXI_AWLEN_i);
        mi_first <= 1'b1;
        mi_addr <= M_AXI_AWADDR_i[0 +: P_MI_SIZE];
        mi_last_index_reg_d0 <= mi_last_index_reg;
      end else if (mi_buf_en) begin
        mi_be_d1 <= mi_be;
        mi_first_d1 <= mi_first;
        mi_last_index_reg_d1 <= mi_last_index_reg_d0;
        mi_addr_d1 <= mi_addr;
        if (mi_last) begin
          if (next_mi_burst == P_WRAP) begin
            mi_ptr <= next_mi_addr[P_MI_SIZE +: 3] & f_mi_wrap_mask(next_mi_size, next_mi_len);
          end else begin
            mi_ptr <= 0;
          end
          if (next_valid) begin
            mi_wcnt <= next_mi_len;
            mi_addr <= next_mi_addr[0 +: P_MI_SIZE];
            mi_last_index_reg_d0 <= next_mi_last_index_reg;
          end
          mi_burst <= next_mi_burst;
          mi_size <= next_mi_size;
          mi_be <= f_mi_be_init(next_mi_addr[0 +: P_MI_SIZE], next_mi_size);
          mi_wrap_cnt <= f_mi_wrap_cnt(next_mi_addr, next_mi_size, next_mi_len);
          mi_wrap_be_next <= f_mi_wrap_be(next_mi_addr[0 +: P_MI_SIZE], next_mi_size, next_mi_len);
          mi_first <= 1'b1;
        end else begin
          mi_first <= 1'b0;
          if (mi_burst == P_FIXED) begin
            mi_ptr <= mi_ptr + 1;
          end else if ((mi_burst == P_WRAP) && (mi_wrap_cnt == 0)) begin
            mi_ptr <= 0;
            mi_be <= mi_wrap_be_next;
          end else begin
            if (mi_be[P_MI_BYTES-1]) begin
              mi_ptr <= (mi_ptr + 1);  // Wrap long INCR bursts around end of buffer
            end
            mi_be <= f_mi_be_rot(mi_be, mi_size);
          end
          mi_wcnt <= mi_wcnt - 1;
          mi_wrap_cnt <= mi_wrap_cnt - 1;
        end
      end
      
      if (load_mi_next) begin
        next_mi_len <= M_AXI_AWLEN_i;
        next_mi_burst <= M_AXI_AWBURST_i;
        next_mi_size <= M_AXI_AWSIZE_i;
        next_mi_addr <= M_AXI_AWADDR_i[0 +: (P_MI_SIZE + 4)];
        next_mi_last_index_reg <= mi_last_index_reg;
      end
    end
    
    assign si_wpayload = {P_RATIO{f_wpayload(S_AXI_WDATA,S_AXI_WSTRB)}};
    assign M_AXI_WDATA = f_wdata(mi_wpayload);
    assign M_AXI_WSTRB = f_wstrb(mi_wpayload) & mi_wstrb_mask_d2 & {P_MI_BYTES{M_AXI_WVALID_i}};
    assign M_AXI_WVALID = M_AXI_WVALID_i;
    assign M_AXI_WLAST = M_AXI_WLAST_i;
    assign M_AXI_AWVALID = M_AXI_AWVALID_i;
    assign M_AXI_AWADDR = M_AXI_AWADDR_i;
    assign M_AXI_AWLEN = M_AXI_AWLEN_i;
    assign M_AXI_AWSIZE = M_AXI_AWSIZE_i;
    assign M_AXI_AWBURST = M_AXI_AWBURST_i;
    assign M_AXI_AWLOCK = {1'b0,M_AXI_AWLOCK_i};
    assign si_buf_addr = {si_buf, si_ptr};
    assign mi_buf_addr = {mi_buf, mi_ptr};
    assign si_we = f_si_we(si_word, si_be);
    
  blk_mem_gen_v8_2 #(
    .C_FAMILY(C_FAMILY),
    .C_XDEVICEFAMILY(C_FAMILY),
    .C_INTERFACE_TYPE(0),
    .C_AXI_TYPE(1),
    .C_AXI_SLAVE_TYPE(0),
    .C_HAS_AXI_ID(0),
    .C_AXI_ID_WIDTH(4),
    .C_MEM_TYPE(1),
    .C_BYTE_SIZE(9),
    .C_ALGORITHM(1),
    .C_PRIM_TYPE(1),
    .C_LOAD_INIT_FILE(0),
    .C_INIT_FILE_NAME("BlankString"),
    .C_INIT_FILE("BlankString"),
    .C_USE_DEFAULT_DATA(0),
    .C_DEFAULT_DATA("0"),
    .C_HAS_RSTA(0),
    .C_RST_PRIORITY_A("CE"),
    .C_RSTRAM_A(0),
    .C_INITA_VAL("0"),
    .C_HAS_ENA(1),
    .C_HAS_REGCEA(0),
    .C_USE_BYTE_WEA(1),
    .C_WEA_WIDTH(P_MI_BYTES),
    .C_WRITE_MODE_A("WRITE_FIRST"),
    .C_WRITE_WIDTH_A(P_M_WBUFFER_WIDTH),
    .C_READ_WIDTH_A(P_M_WBUFFER_WIDTH),
    .C_WRITE_DEPTH_A(P_M_WBUFFER_DEPTH),
    .C_READ_DEPTH_A(P_M_WBUFFER_DEPTH),
    .C_ADDRA_WIDTH(P_M_WBUFFER_DEPTH_LOG),
    .C_HAS_RSTB(0),
    .C_RST_PRIORITY_B("CE"),
    .C_RSTRAM_B(0),
    .C_INITB_VAL("0"),
    .C_HAS_ENB(1),
    .C_HAS_REGCEB(0),
    .C_USE_BYTE_WEB(1),
    .C_WEB_WIDTH(P_MI_BYTES),
    .C_WRITE_MODE_B("WRITE_FIRST"),
    .C_WRITE_WIDTH_B(P_M_WBUFFER_WIDTH),
    .C_READ_WIDTH_B(P_M_WBUFFER_WIDTH),
    .C_WRITE_DEPTH_B(P_M_WBUFFER_DEPTH),
    .C_READ_DEPTH_B(P_M_WBUFFER_DEPTH),
    .C_ADDRB_WIDTH(P_M_WBUFFER_DEPTH_LOG),
    .C_HAS_MEM_OUTPUT_REGS_A(0),
    .C_HAS_MEM_OUTPUT_REGS_B(1),
    .C_HAS_MUX_OUTPUT_REGS_A(0),
    .C_HAS_MUX_OUTPUT_REGS_B(0),
    .C_MUX_PIPELINE_STAGES(0),
    .C_HAS_SOFTECC_INPUT_REGS_A(0),
    .C_HAS_SOFTECC_OUTPUT_REGS_B(0),
    .C_USE_SOFTECC(0),
    .C_USE_ECC(0),
    .C_HAS_INJECTERR(0),
    .C_SIM_COLLISION_CHECK("GENERATE_X_ONLY"),
    .C_COMMON_CLK(0),
    .C_ENABLE_32BIT_ADDRESS(0),
    .C_DISABLE_WARN_BHV_COLL(1),
    .C_DISABLE_WARN_BHV_RANGE(0),
    .C_USE_BRAM_BLOCK(0)
  ) w_buffer (
    .clka(S_AXI_ACLK),
    .rsta(1'b0),
    .ena(si_buf_en),
    .regcea(1'b1),
    .wea(si_we),
    .addra(si_buf_addr),
    .dina(si_wpayload),
    .douta(),
    .clkb(m_aclk),
    .rstb(1'b0),
    .enb(mi_buf_en),
    .regceb(1'b1),
    .web({P_MI_BYTES{1'b0}}),
    .addrb(mi_buf_addr),
    .dinb({P_M_WBUFFER_WIDTH{1'b0}}),
    .doutb(mi_wpayload),
    .injectsbiterr(1'b0),
    .injectdbiterr(1'b0),
    .sbiterr(),
    .dbiterr(),
    .rdaddrecc(),
    .s_aclk(1'b0),
    .s_aresetn(1'b0),
    .s_axi_awid(4'b0),
    .s_axi_awaddr(32'b0),
    .s_axi_awlen(8'b0),
    .s_axi_awsize(3'b0),
    .s_axi_awburst(2'b0),
    .s_axi_awvalid(1'b0),
    .s_axi_awready(),
    .s_axi_wdata({P_M_WBUFFER_WIDTH{1'b0}}),
    .s_axi_wstrb({P_MI_BYTES{1'b0}}),
    .s_axi_wlast(1'b0),
    .s_axi_wvalid(1'b0),
    .s_axi_wready(),
    .s_axi_bid(),
    .s_axi_bresp(),
    .s_axi_bvalid(),
    .s_axi_bready(1'b0),
    .s_axi_arid(4'b0),
    .s_axi_araddr(32'b0),
    .s_axi_arlen(8'b0),
    .s_axi_arsize(3'b0),
    .s_axi_arburst(2'b0),
    .s_axi_arvalid(1'b0),
    .s_axi_arready(),
    .s_axi_rid(),
    .s_axi_rdata(),
    .s_axi_rresp(),
    .s_axi_rlast(),
    .s_axi_rvalid(),
    .s_axi_rready(1'b0),
    .s_axi_injectsbiterr(1'b0),
    .s_axi_injectdbiterr(1'b0),
    .s_axi_sbiterr(),
    .s_axi_dbiterr(),
    .s_axi_rdaddrecc(),
    .sleep(1'b0),
    .eccpipece(1'b0)
  );
    
  fifo_generator_v12_0 #(
    .C_FAMILY(C_FAMILY),
    .C_COMMON_CLOCK(P_COMMON_CLOCK),
    .C_MEMORY_TYPE(1),
    .C_SYNCHRONIZER_STAGE(C_SYNCHRONIZER_STAGE),
    .C_INTERFACE_TYPE(2),
    .C_AXI_TYPE(1),
    .C_AXIS_TYPE(0),
    .C_HAS_AXI_ID(0),
    .C_AXI_LEN_WIDTH(8),
    .C_AXI_LOCK_WIDTH(1),
    .C_DIN_WIDTH_WACH(P_AWFIFO_WIDTH),
    .C_DIN_WIDTH_WDCH(37),
    .C_DIN_WIDTH_WRCH(2),
    .C_DIN_WIDTH_RACH(P_AWFIFO_WIDTH),
    .C_DIN_WIDTH_RDCH(35),
    .C_HAS_AXI_WR_CHANNEL(1),
    .C_HAS_AXI_RD_CHANNEL(0),
    .C_AXI_ID_WIDTH(1),
    .C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
    .C_AXI_DATA_WIDTH(32),
    .C_HAS_AXI_AWUSER(1),
    .C_HAS_AXI_WUSER(0),
    .C_HAS_AXI_BUSER(0),
    .C_HAS_AXI_ARUSER(1),
    .C_HAS_AXI_RUSER(0),
    .C_AXI_ARUSER_WIDTH(P_MI_SIZE),
    .C_AXI_AWUSER_WIDTH(P_MI_SIZE),
    .C_AXI_WUSER_WIDTH(1),
    .C_AXI_BUSER_WIDTH(1),
    .C_AXI_RUSER_WIDTH(1),
    .C_WACH_TYPE(0),
    .C_WDCH_TYPE(2),
    .C_WRCH_TYPE(2),
    .C_RACH_TYPE(0),
    .C_RDCH_TYPE(0),
    .C_IMPLEMENTATION_TYPE_WACH(P_COMMON_CLOCK ? 2 : 12),
    .C_IMPLEMENTATION_TYPE_WDCH(P_COMMON_CLOCK ? 1 : 11),
    .C_IMPLEMENTATION_TYPE_WRCH(P_COMMON_CLOCK ? 2 : 12),
    .C_IMPLEMENTATION_TYPE_RACH(P_COMMON_CLOCK ? 2 : 12),
    .C_IMPLEMENTATION_TYPE_RDCH(P_COMMON_CLOCK ? 1 : 11),
    .C_IMPLEMENTATION_TYPE_AXIS(1),
    .C_DIN_WIDTH_AXIS(1),
    .C_WR_DEPTH_WACH(32),
    .C_WR_DEPTH_WDCH(1024),
    .C_WR_DEPTH_WRCH(16),
    .C_WR_DEPTH_RACH(32),
    .C_WR_DEPTH_RDCH(1024),
    .C_WR_DEPTH_AXIS(1024),
    .C_WR_PNTR_WIDTH_WACH(5),
    .C_WR_PNTR_WIDTH_WDCH(10),
    .C_WR_PNTR_WIDTH_WRCH(4),
    .C_WR_PNTR_WIDTH_RACH(5),
    .C_WR_PNTR_WIDTH_RDCH(10),
    .C_WR_PNTR_WIDTH_AXIS(10),
    .C_APPLICATION_TYPE_WACH(P_COMMON_CLOCK ? 2 : 0),
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
  ) dw_fifogen_aw (
    .s_aclk(aw_fifo_s_aclk),
    .m_aclk(aw_fifo_m_aclk),
    .s_aresetn(aw_fifo_aresetn),
    .s_axi_awid     (1'b0),
    .s_axi_awaddr   (s_awaddr_reg),
    .s_axi_awlen    (s_awlen_reg),
    .s_axi_awsize   (s_awsize_reg),
    .s_axi_awburst  (s_awburst_reg),
    .s_axi_awlock   (s_awlock_reg),
    .s_axi_awcache  (s_awcache_reg),
    .s_axi_awprot   (s_awprot_reg),
    .s_axi_awqos    (s_awqos_reg),
    .s_axi_awregion (s_awregion_reg),
    .s_axi_awuser   (si_last_index_reg),
    .s_axi_awvalid  (aw_push),
    .s_axi_awready  (aw_ready),
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
    .m_axi_awaddr   (M_AXI_AWADDR_i),
    .m_axi_awlen    (M_AXI_AWLEN_i),
    .m_axi_awsize   (M_AXI_AWSIZE_i),
    .m_axi_awburst  (M_AXI_AWBURST_i),
    .m_axi_awlock   (M_AXI_AWLOCK_i),
    .m_axi_awcache  (M_AXI_AWCACHE),
    .m_axi_awprot   (M_AXI_AWPROT),
    .m_axi_awqos    (M_AXI_AWQOS),
    .m_axi_awregion (M_AXI_AWREGION),
    .m_axi_awuser   (mi_last_index_reg),
    .m_axi_awvalid  (mi_awvalid),
    .m_axi_awready  (aw_pop),
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
    .s_axi_arid(1'b0),
    .s_axi_araddr({C_AXI_ADDR_WIDTH{1'b0}}),
    .s_axi_arlen(8'b0),
    .s_axi_arsize(3'b0),
    .s_axi_arburst(2'b0),
    .s_axi_arlock(1'b0),
    .s_axi_arcache(4'b0),
    .s_axi_arprot(3'b0),
    .s_axi_arqos(4'b0),
    .s_axi_arregion(4'b0),
    .s_axi_aruser({P_MI_SIZE{1'b0}}),
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
    .m_axi_rid(1'b0),
    .m_axi_rdata(32'b0),
    .m_axi_rresp(2'b0),
    .m_axi_rlast(1'b0),
    .m_axi_ruser(1'b0),
    .m_axi_rvalid(1'b0),
    .m_axi_rready(),
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
    .axi_aw_prog_full_thresh(5'b0),
    .axi_aw_prog_empty_thresh(5'b0),
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
  
  axi_register_slice_v2_1_axi_register_slice #(
    .C_FAMILY(C_FAMILY),
    .C_AXI_PROTOCOL(0),
    .C_AXI_ID_WIDTH(1),
    .C_AXI_ADDR_WIDTH(C_AXI_ADDR_WIDTH),
    .C_AXI_DATA_WIDTH(32),
    .C_AXI_SUPPORTS_USER_SIGNALS(1),
    .C_AXI_AWUSER_WIDTH(P_MI_SIZE),
    .C_AXI_ARUSER_WIDTH(1),
    .C_AXI_WUSER_WIDTH(1),
    .C_AXI_RUSER_WIDTH(1),
    .C_AXI_BUSER_WIDTH(1),
    .C_REG_CONFIG_AW(7),
    .C_REG_CONFIG_W(0),
    .C_REG_CONFIG_B(0),
    .C_REG_CONFIG_AR(0),
    .C_REG_CONFIG_R(0)
  ) s_aw_reg (
    .aclk(S_AXI_ACLK),
    .aresetn(s_aresetn),
    .s_axi_awid(1'b0),
    .s_axi_awaddr  (S_AXI_AWADDR),
    .s_axi_awlen   (S_AXI_AWLEN),
    .s_axi_awsize  (S_AXI_AWSIZE),
    .s_axi_awburst (S_AXI_AWBURST),
    .s_axi_awlock  (S_AXI_AWLOCK_i),
    .s_axi_awcache (S_AXI_AWCACHE),
    .s_axi_awprot  (S_AXI_AWPROT),
    .s_axi_awregion(S_AXI_AWREGION),
    .s_axi_awqos   (S_AXI_AWQOS),
    .s_axi_awuser  (si_last_index),
    .s_axi_awvalid (S_AXI_AWVALID),
    .s_axi_awready (S_AXI_AWREADY),
    .s_axi_wid(1'b0),
    .s_axi_wdata(32'b0),
    .s_axi_wstrb(4'b00),
    .s_axi_wlast(1'b0),
    .s_axi_wuser(1'b0),
    .s_axi_wvalid(1'b0),
    .s_axi_wready(),
    .s_axi_bid(),
    .s_axi_buser(),
    .s_axi_bresp(),
    .s_axi_bvalid(),
    .s_axi_bready(1'b0),
    .s_axi_arid(1'b0),
    .s_axi_araddr({C_AXI_ADDR_WIDTH{1'B0}}),
    .s_axi_arlen(8'b0),
    .s_axi_arsize(3'b0),
    .s_axi_arburst(2'b0),
    .s_axi_arlock(1'b0),
    .s_axi_arcache(4'b0),
    .s_axi_arprot(3'b0),
    .s_axi_arregion(4'b0),
    .s_axi_arqos(4'b0),
    .s_axi_aruser(1'b0),
    .s_axi_arvalid(1'b0),
    .s_axi_arready(),
    .s_axi_rid(),
    .s_axi_ruser(),
    .s_axi_rdata(),
    .s_axi_rresp(),
    .s_axi_rlast(),
    .s_axi_rvalid(),
    .s_axi_rready(1'b0),
    .m_axi_awid(),
    .m_axi_awaddr  (s_awaddr_reg),
    .m_axi_awlen   (s_awlen_reg),
    .m_axi_awsize  (s_awsize_reg),
    .m_axi_awburst (s_awburst_reg),
    .m_axi_awlock  (s_awlock_reg),
    .m_axi_awcache (s_awcache_reg),
    .m_axi_awprot  (s_awprot_reg),
    .m_axi_awregion(s_awregion_reg),
    .m_axi_awqos   (s_awqos_reg),
    .m_axi_awuser  (si_last_index_reg),
    .m_axi_awvalid (s_awvalid_reg),
    .m_axi_awready (s_awready_reg),
    .m_axi_wid(),
    .m_axi_wuser(),
    .m_axi_wdata(),
    .m_axi_wstrb(),
    .m_axi_wlast(),
    .m_axi_wvalid(),
    .m_axi_wready(1'b0),
    .m_axi_bid(1'b0),
    .m_axi_bresp(2'b0),
    .m_axi_buser(1'b0),
    .m_axi_bvalid(1'b0),
    .m_axi_bready(),
    .m_axi_arid(),
    .m_axi_aruser(),
    .m_axi_araddr(),
    .m_axi_arlen(),
    .m_axi_arsize(),
    .m_axi_arburst(),
    .m_axi_arlock(),
    .m_axi_arcache(),
    .m_axi_arprot(),
    .m_axi_arregion(),
    .m_axi_arqos(),
    .m_axi_arvalid(),
    .m_axi_arready(1'b0),
    .m_axi_rid(1'b0),
    .m_axi_rdata(32'b0),
    .m_axi_rresp(2'b0),
    .m_axi_rlast(1'b0),
    .m_axi_ruser(1'b0),
    .m_axi_rvalid(1'b0),
    .m_axi_rready()
  );
  
  if (C_CLK_CONV && C_AXI_IS_ACLK_ASYNC) begin : gen_awpop_fifo
    
    fifo_generator_v12_0 #(
      .C_DIN_WIDTH(1),
      .C_DOUT_WIDTH(1),
      .C_RD_DEPTH(32),
      .C_RD_PNTR_WIDTH(5),
      .C_RD_DATA_COUNT_WIDTH(5),
      .C_WR_DEPTH(32),
      .C_WR_PNTR_WIDTH(5),
      .C_WR_DATA_COUNT_WIDTH(5),
      .C_DATA_COUNT_WIDTH(5),
      .C_COMMON_CLOCK(0),
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
      .C_HAS_RST(1),
      .C_HAS_SRST(0),
      .C_HAS_UNDERFLOW(0),
      .C_HAS_VALID(0),
      .C_HAS_WR_ACK(0),
      .C_HAS_WR_DATA_COUNT(0),
      .C_HAS_WR_RST(0),
      .C_IMPLEMENTATION_TYPE(2),
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
    ) dw_fifogen_awpop (
      .clk(1'b0),
      .wr_clk(M_AXI_ACLK),
      .rd_clk(S_AXI_ACLK),
      .rst(awpop_reset),
      .wr_rst(1'b0),
      .rd_rst(1'b0),
      .srst(1'b0),
      .din(1'b0),
      .dout(),
      .full(),
      .empty(aw_pop_event),
      .wr_en(aw_pop),
      .rd_en(aw_pop_resync),
      .backup(1'b0),
      .backup_marker(1'b0),
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
    
    assign aw_pop_resync = ~aw_pop_event;
  end else begin : gen_no_awpop_fifo
    assign aw_pop_resync = aw_pop | aw_pop_extend;
  end

  endgenerate
endmodule

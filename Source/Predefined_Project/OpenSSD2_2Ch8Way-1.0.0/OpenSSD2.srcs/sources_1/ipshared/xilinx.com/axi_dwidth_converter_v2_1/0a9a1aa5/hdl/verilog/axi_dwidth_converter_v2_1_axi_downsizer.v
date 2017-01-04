// -- (c) Copyright 2010 - 2011 Xilinx, Inc. All rights reserved.
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
// Description: Down-Sizer
// Down-Sizer for generic SI- and MI-side data widths. This module instantiates
// Address, Write Data, Write Response and Read Data Down-Sizer modules, each one taking care
// of the channel specific tasks.
// The Address Down-Sizer can handle both AR and AW channels.
//
// Verilog-standard:  Verilog 2001
//--------------------------------------------------------------------------
//
// Structure:
//   downsizer
//     a_downsizer
//       axic_fifo
//         fifo_gen
//           fifo_coregen
//     w_downsizer
//     b_downsizer
//     r_downsizer
//
//--------------------------------------------------------------------------
`timescale 1ps/1ps

(* DowngradeIPIdentifiedWarnings="yes" *) 
module axi_dwidth_converter_v2_1_axi_downsizer #
  (
   parameter         C_FAMILY                         = "none", 
                       // FPGA Family.
   parameter integer C_AXI_PROTOCOL = 0, 
                       // Protocol of SI and MI (0=AXI4, 1=AXI3).
   parameter integer C_S_AXI_ID_WIDTH                   = 1, 
                       // Width of all ID signals on SI side of converter.
                       // Range: 1 - 32.
   parameter integer C_SUPPORTS_ID                    = 0, 
                       // Indicates whether SI-side ID needs to be stored and compared.
                       // 0 = No, SI is single-threaded, propagate all transactions.
                       // 1 = Yes, stall any transaction with ID different than outstanding transactions.
   parameter integer C_AXI_ADDR_WIDTH                 = 32, 
                       // Width of all ADDR signals on SI and MI.
                       // Range (AXI4, AXI3): 12 - 64.
   parameter integer C_S_AXI_DATA_WIDTH               = 64,
                       // Width of s_axi_wdata and s_axi_rdata.
                       // Range: 64, 128, 256, 512, 1024.
   parameter integer C_M_AXI_DATA_WIDTH               = 32,
                       // Width of m_axi_wdata and m_axi_rdata. 
                       // Assume always smaller than C_S_AXI_DATA_WIDTH.
                       // Range: 32, 64, 128, 256, 512.
                       // S_DATA_WIDTH = M_DATA_WIDTH not allowed.
   parameter integer C_AXI_SUPPORTS_WRITE             = 1,
   parameter integer C_AXI_SUPPORTS_READ              = 1,
   parameter integer C_MAX_SPLIT_BEATS              = 256
                       // Max burst length after transaction splitting.
                       // Range: 0 (no splitting), 1 (convert to singles), 16, 256.
   )
  (
   // Global Signals
   input  wire                              aresetn,
   input  wire                              aclk,

   // Slave Interface Write Address Ports
   input  wire [C_S_AXI_ID_WIDTH-1:0]       s_axi_awid,
   input  wire [C_AXI_ADDR_WIDTH-1:0]       s_axi_awaddr,
   input  wire [8-1:0]                      s_axi_awlen,
   input  wire [3-1:0]                      s_axi_awsize,
   input  wire [2-1:0]                      s_axi_awburst,
   input  wire [2-1:0]                      s_axi_awlock,
   input  wire [4-1:0]                      s_axi_awcache,
   input  wire [3-1:0]                      s_axi_awprot,
   input  wire [4-1:0]                      s_axi_awregion,
   input  wire [4-1:0]                      s_axi_awqos,
   input  wire                              s_axi_awvalid,
   output wire                              s_axi_awready,
   // Slave Interface Write Data Ports
   input  wire [C_S_AXI_DATA_WIDTH-1:0]     s_axi_wdata,
   input  wire [C_S_AXI_DATA_WIDTH/8-1:0]   s_axi_wstrb,
   input  wire                              s_axi_wlast,
   input  wire                              s_axi_wvalid,
   output wire                              s_axi_wready,
   // Slave Interface Write Response Ports
   output wire [C_S_AXI_ID_WIDTH-1:0]       s_axi_bid,
   output wire [2-1:0]                      s_axi_bresp,
   output wire                              s_axi_bvalid,
   input  wire                              s_axi_bready,
   // Slave Interface Read Address Ports
   input  wire [C_S_AXI_ID_WIDTH-1:0]       s_axi_arid,
   input  wire [C_AXI_ADDR_WIDTH-1:0]       s_axi_araddr,
   input  wire [8-1:0]                      s_axi_arlen,
   input  wire [3-1:0]                      s_axi_arsize,
   input  wire [2-1:0]                      s_axi_arburst,
   input  wire [2-1:0]                      s_axi_arlock,
   input  wire [4-1:0]                      s_axi_arcache,
   input  wire [3-1:0]                      s_axi_arprot,
   input  wire [4-1:0]                      s_axi_arregion,
   input  wire [4-1:0]                      s_axi_arqos,
   input  wire                              s_axi_arvalid,
   output wire                              s_axi_arready,
   // Slave Interface Read Data Ports
   output wire [C_S_AXI_ID_WIDTH-1:0]       s_axi_rid,
   output wire [C_S_AXI_DATA_WIDTH-1:0]     s_axi_rdata,
   output wire [2-1:0]                      s_axi_rresp,
   output wire                              s_axi_rlast,
   output wire                              s_axi_rvalid,
   input  wire                              s_axi_rready,

   // Master Interface Write Address Port
   output wire [C_AXI_ADDR_WIDTH-1:0]       m_axi_awaddr,
   output wire [8-1:0]                      m_axi_awlen,
   output wire [3-1:0]                      m_axi_awsize,
   output wire [2-1:0]                      m_axi_awburst,
   output wire [2-1:0]                      m_axi_awlock,
   output wire [4-1:0]                      m_axi_awcache,
   output wire [3-1:0]                      m_axi_awprot,
   output wire [4-1:0]                      m_axi_awregion,
   output wire [4-1:0]                      m_axi_awqos,
   output wire                              m_axi_awvalid,
   input  wire                              m_axi_awready,
   // Master Interface Write Data Ports
   output wire [C_M_AXI_DATA_WIDTH-1:0]     m_axi_wdata,
   output wire [C_M_AXI_DATA_WIDTH/8-1:0]   m_axi_wstrb,
   output wire                              m_axi_wlast,
   output wire                              m_axi_wvalid,
   input  wire                              m_axi_wready,
   // Master Interface Write Response Ports
   input  wire [2-1:0]                      m_axi_bresp,
   input  wire                              m_axi_bvalid,
   output wire                              m_axi_bready,
   // Master Interface Read Address Port
   output wire [C_AXI_ADDR_WIDTH-1:0]       m_axi_araddr,
   output wire [8-1:0]                      m_axi_arlen,
   output wire [3-1:0]                      m_axi_arsize,
   output wire [2-1:0]                      m_axi_arburst,
   output wire [2-1:0]                      m_axi_arlock,
   output wire [4-1:0]                      m_axi_arcache,
   output wire [3-1:0]                      m_axi_arprot,
   output wire [4-1:0]                      m_axi_arregion,
   output wire [4-1:0]                      m_axi_arqos,
   output wire                              m_axi_arvalid,
   input  wire                              m_axi_arready,
   // Master Interface Read Data Ports
   input  wire [C_M_AXI_DATA_WIDTH-1:0]     m_axi_rdata,
   input  wire [2-1:0]                      m_axi_rresp,
   input  wire                              m_axi_rlast,
   input  wire                              m_axi_rvalid,
   output wire                              m_axi_rready
   );

  /////////////////////////////////////////////////////////////////////////////
  // Functions
  /////////////////////////////////////////////////////////////////////////////
  
  // Log2.
  function integer log2
    (
     input integer x
     );
    integer acc;
    begin
      acc=0;
      while ((2**acc) < x)
        acc = acc + 1;
      log2 = acc;
    end
  endfunction
  
  
  /////////////////////////////////////////////////////////////////////////////
  // Local params
  /////////////////////////////////////////////////////////////////////////////
  
  // Log2 of number of 32bit word on SI-side.
  localparam integer C_S_AXI_BYTES_LOG                = log2(C_S_AXI_DATA_WIDTH/8);
  
  // Log2 of number of 32bit word on MI-side.
  localparam integer C_M_AXI_BYTES_LOG                = log2(C_M_AXI_DATA_WIDTH/8);
  
  // Log2 of Up-Sizing ratio for data.
  localparam integer C_RATIO                          = C_S_AXI_DATA_WIDTH / C_M_AXI_DATA_WIDTH;
  localparam integer C_RATIO_LOG                      = log2(C_RATIO);
  localparam integer P_AXI_ADDR_WIDTH                 = (C_AXI_ADDR_WIDTH < 13) ? 13 : C_AXI_ADDR_WIDTH;
  
  wire [P_AXI_ADDR_WIDTH-1:0] s_axi_awaddr_i;
  wire [P_AXI_ADDR_WIDTH-1:0] s_axi_araddr_i;
  wire [P_AXI_ADDR_WIDTH-1:0] m_axi_awaddr_i;
  wire [P_AXI_ADDR_WIDTH-1:0] m_axi_araddr_i;
  assign s_axi_awaddr_i = s_axi_awaddr;
  assign s_axi_araddr_i = s_axi_araddr;
  assign m_axi_awaddr = m_axi_awaddr_i[0 +: C_AXI_ADDR_WIDTH] ;
  assign m_axi_araddr = m_axi_araddr_i[0 +: C_AXI_ADDR_WIDTH];
  
  localparam integer P_AXI4 = 0;
  localparam integer P_AXI3 = 1;
  localparam integer P_AXILITE = 2;
  
  localparam integer P_MAX_SPLIT_BEATS = (C_MAX_SPLIT_BEATS >= 16) ? C_MAX_SPLIT_BEATS :
    (C_AXI_PROTOCOL == P_AXI4) ? 256 : 16;
  localparam integer P_MAX_SPLIT_BEATS_LOG = log2(P_MAX_SPLIT_BEATS);
  
  /////////////////////////////////////////////////////////////////////////////
  // Handle Write Channels (AW/W/B)
  /////////////////////////////////////////////////////////////////////////////
  generate
    if (C_AXI_SUPPORTS_WRITE == 1) begin : USE_WRITE
    
      // Write Channel Signals for Commands Queue Interface.
      wire                              wr_cmd_valid;
      wire                              wr_cmd_split;
      wire                              wr_cmd_mirror;
      wire                              wr_cmd_fix;
      wire [C_S_AXI_BYTES_LOG-1:0]      wr_cmd_first_word;
      wire [C_S_AXI_BYTES_LOG-1:0]      wr_cmd_offset;
      wire [C_S_AXI_BYTES_LOG-1:0]      wr_cmd_mask;
      wire [C_M_AXI_BYTES_LOG:0]        wr_cmd_step;
      wire [3-1:0]                      wr_cmd_size;
      wire [8-1:0]                      wr_cmd_length;
      wire                              wr_cmd_ready;
      
      wire                              wr_cmd_b_valid;
      wire                              wr_cmd_b_split;
      wire [8-1:0]                      wr_cmd_b_repeat ;
      wire                              wr_cmd_b_ready;
      wire [C_S_AXI_ID_WIDTH-1:0]       wr_cmd_b_id;
      
      wire [8-1:0]                  s_axi_awlen_i;
      wire [2-1:0]                  s_axi_awlock_i;
      
      assign s_axi_awlen_i = (C_AXI_PROTOCOL == P_AXI3) ? {4'b0000, s_axi_awlen[3:0]}: s_axi_awlen;
      assign s_axi_awlock_i = (C_AXI_PROTOCOL == P_AXI3) ? s_axi_awlock : {1'b0, s_axi_awlock[0]};
      
      // Write Address Channel.
      axi_dwidth_converter_v2_1_a_downsizer #
      (
       .C_FAMILY                    (C_FAMILY),
       .C_AXI_PROTOCOL              (C_AXI_PROTOCOL),
       .C_AXI_ID_WIDTH              (C_S_AXI_ID_WIDTH),
       .C_SUPPORTS_ID               (C_SUPPORTS_ID),
       .C_AXI_ADDR_WIDTH            (P_AXI_ADDR_WIDTH),
       .C_S_AXI_DATA_WIDTH          (C_S_AXI_DATA_WIDTH),
       .C_M_AXI_DATA_WIDTH          (C_M_AXI_DATA_WIDTH),
       .C_AXI_CHANNEL               (0),
       .C_MAX_SPLIT_BEATS           (P_MAX_SPLIT_BEATS),
       .C_MAX_SPLIT_BEATS_LOG       (P_MAX_SPLIT_BEATS_LOG),
       .C_S_AXI_BYTES_LOG           (C_S_AXI_BYTES_LOG),
       .C_M_AXI_BYTES_LOG           (C_M_AXI_BYTES_LOG),
       .C_RATIO_LOG                 (C_RATIO_LOG)
        ) write_addr_inst
       (
        // Global Signals
        .ARESET                     (!aresetn),
        .ACLK                       (aclk),
    
        // Command Interface (W)
        .cmd_valid                  (wr_cmd_valid),
        .cmd_split                  (wr_cmd_split),
        .cmd_mirror                 (wr_cmd_mirror),
        .cmd_fix                    (wr_cmd_fix),
        .cmd_first_word             (wr_cmd_first_word),
        .cmd_offset                 (wr_cmd_offset),
        .cmd_mask                   (wr_cmd_mask),
        .cmd_step                   (wr_cmd_step),
        .cmd_size                   (wr_cmd_size),
        .cmd_length                 (wr_cmd_length),
        .cmd_ready                  (wr_cmd_ready),
       
        // Command Interface (B)
        .cmd_b_valid                (wr_cmd_b_valid),
        .cmd_b_split                (wr_cmd_b_split),
        .cmd_b_repeat               (wr_cmd_b_repeat),
        .cmd_b_ready                (wr_cmd_b_ready),
        .cmd_id                     (wr_cmd_b_id),
       
        // Slave Interface Write Address Ports
        .S_AXI_AID                  (s_axi_awid),
        .S_AXI_AADDR                (s_axi_awaddr_i),
        .S_AXI_ALEN                 (s_axi_awlen_i),
        .S_AXI_ASIZE                (s_axi_awsize),
        .S_AXI_ABURST               (s_axi_awburst),
        .S_AXI_ALOCK                (s_axi_awlock_i),
        .S_AXI_ACACHE               (s_axi_awcache),
        .S_AXI_APROT                (s_axi_awprot),
        .S_AXI_AREGION              (s_axi_awregion),
        .S_AXI_AQOS                 (s_axi_awqos),
        .S_AXI_AVALID               (s_axi_awvalid),
        .S_AXI_AREADY               (s_axi_awready),
        
        // Master Interface Write Address Port
        .M_AXI_AADDR                (m_axi_awaddr_i),
        .M_AXI_ALEN                 (m_axi_awlen),
        .M_AXI_ASIZE                (m_axi_awsize),
        .M_AXI_ABURST               (m_axi_awburst),
        .M_AXI_ALOCK                (m_axi_awlock),
        .M_AXI_ACACHE               (m_axi_awcache),
        .M_AXI_APROT                (m_axi_awprot),
        .M_AXI_AREGION              (m_axi_awregion),
        .M_AXI_AQOS                 (m_axi_awqos),
        .M_AXI_AVALID               (m_axi_awvalid),
        .M_AXI_AREADY               (m_axi_awready)
       );
       
      // Write Data channel.
      axi_dwidth_converter_v2_1_w_downsizer #
      (
       .C_FAMILY                    (C_FAMILY),
       .C_S_AXI_DATA_WIDTH          (C_S_AXI_DATA_WIDTH),
       .C_M_AXI_DATA_WIDTH          (C_M_AXI_DATA_WIDTH),
       .C_S_AXI_BYTES_LOG           (C_S_AXI_BYTES_LOG),
       .C_M_AXI_BYTES_LOG           (C_M_AXI_BYTES_LOG),
       .C_RATIO_LOG                 (C_RATIO_LOG)
        ) write_data_inst
       (
        // Global Signals
        .ARESET                     (!aresetn),
        .ACLK                       (aclk),
    
        // Command Interface
        .cmd_valid                  (wr_cmd_valid),
        .cmd_mirror                 (wr_cmd_mirror),
        .cmd_fix                    (wr_cmd_fix),
        .cmd_first_word             (wr_cmd_first_word),
        .cmd_offset                 (wr_cmd_offset),
        .cmd_mask                   (wr_cmd_mask),
        .cmd_step                   (wr_cmd_step),
        .cmd_size                   (wr_cmd_size),
        .cmd_length                 (wr_cmd_length),
        .cmd_ready                  (wr_cmd_ready),
       
        // Slave Interface Write Data Ports
        .S_AXI_WDATA                (s_axi_wdata),
        .S_AXI_WSTRB                (s_axi_wstrb),
        .S_AXI_WLAST                (s_axi_wlast),
        .S_AXI_WVALID               (s_axi_wvalid),
        .S_AXI_WREADY               (s_axi_wready),
        
        // Master Interface Write Data Ports
        .M_AXI_WDATA                (m_axi_wdata),
        .M_AXI_WSTRB                (m_axi_wstrb),
        .M_AXI_WLAST                (m_axi_wlast),
        .M_AXI_WVALID               (m_axi_wvalid),
        .M_AXI_WREADY               (m_axi_wready)
       );
      
      // Write Response channel.
      if ( P_MAX_SPLIT_BEATS > 0 ) begin : USE_SPLIT
        axi_dwidth_converter_v2_1_b_downsizer #
        (
         .C_FAMILY                    (C_FAMILY),
         .C_AXI_ID_WIDTH              (C_S_AXI_ID_WIDTH)
          ) write_resp_inst
         (
          // Global Signals
          .ARESET                     (!aresetn),
          .ACLK                       (aclk),
      
          // Command Interface
          .cmd_valid                  (wr_cmd_b_valid),
          .cmd_split                  (wr_cmd_b_split),
          .cmd_repeat                 (wr_cmd_b_repeat),
          .cmd_ready                  (wr_cmd_b_ready),
          .cmd_id                     (wr_cmd_b_id),
          
          // Slave Interface Write Response Ports
          .S_AXI_BID                  (s_axi_bid),
          .S_AXI_BRESP                (s_axi_bresp),
          .S_AXI_BVALID               (s_axi_bvalid),
          .S_AXI_BREADY               (s_axi_bready),
          
          // Master Interface Write Response Ports
          .M_AXI_BRESP                (m_axi_bresp),
          .M_AXI_BVALID               (m_axi_bvalid),
          .M_AXI_BREADY               (m_axi_bready)
         );
        
      end else begin : NO_SPLIT
        assign s_axi_bid     = wr_cmd_b_id;
        assign s_axi_bresp   = m_axi_bresp;
        assign s_axi_bvalid  = m_axi_bvalid;
        assign m_axi_bready  = s_axi_bready;
        
      end
    end else begin : NO_WRITE
      // Slave Interface Write Address Ports
      assign s_axi_awready = 1'b0;
      // Slave Interface Write Data Ports
      assign s_axi_wready  = 1'b0;
      // Slave Interface Write Response Ports
      assign s_axi_bid     = {C_S_AXI_ID_WIDTH{1'b0}};
      assign s_axi_bresp   = 2'b0;
      assign s_axi_bvalid  = 1'b0;
      
      // Master Interface Write Address Port
      assign m_axi_awaddr_i  = {P_AXI_ADDR_WIDTH{1'b0}};
      assign m_axi_awlen   = 8'b0;
      assign m_axi_awsize  = 3'b0;
      assign m_axi_awburst = 2'b0;
      assign m_axi_awlock  = 2'b0;
      assign m_axi_awcache = 4'b0;
      assign m_axi_awprot  = 3'b0;
      assign m_axi_awregion = 4'b0;
      assign m_axi_awqos   = 4'b0;
      assign m_axi_awvalid = 1'b0;
      // Master Interface Write Data Ports
      assign m_axi_wdata   = {C_M_AXI_DATA_WIDTH{1'b0}};
      assign m_axi_wstrb   = {C_M_AXI_DATA_WIDTH/8{1'b0}};
      assign m_axi_wlast   = 1'b0;
//      assign m_axi_wuser   = {C_AXI_WUSER_WIDTH{1'b0}};
      assign m_axi_wvalid  = 1'b0;
      // Master Interface Write Response Ports
      assign m_axi_bready  = 1'b0;
      
    end
  endgenerate
  
  /////////////////////////////////////////////////////////////////////////////
  // Handle Read Channels (AR/R)
  /////////////////////////////////////////////////////////////////////////////
  generate
    if (C_AXI_SUPPORTS_READ == 1) begin : USE_READ
    
      // Read Channel Signals for Commands Queue Interface.
      wire                              rd_cmd_valid;
      wire                              rd_cmd_split;
      wire                              rd_cmd_mirror;
      wire                              rd_cmd_fix;
      wire [C_S_AXI_BYTES_LOG-1:0]      rd_cmd_first_word;
      wire [C_S_AXI_BYTES_LOG-1:0]      rd_cmd_offset;
      wire [C_S_AXI_BYTES_LOG-1:0]      rd_cmd_mask;
      wire [C_M_AXI_BYTES_LOG:0]        rd_cmd_step;
      wire [3-1:0]                      rd_cmd_size;
      wire [8-1:0]                      rd_cmd_length;
      wire                              rd_cmd_ready;
      wire [C_S_AXI_ID_WIDTH-1:0]       rd_cmd_id;
      
      wire [8-1:0]                  s_axi_arlen_i;
      wire [2-1:0]                  s_axi_arlock_i;
      
      assign s_axi_arlen_i = (C_AXI_PROTOCOL == P_AXI3) ? {4'b0000, s_axi_arlen[3:0]}: s_axi_arlen;
      assign s_axi_arlock_i = (C_AXI_PROTOCOL == P_AXI3) ? s_axi_arlock : {1'b0, s_axi_arlock[0]};
      
      // Write Address Channel.
      axi_dwidth_converter_v2_1_a_downsizer #
      (
       .C_FAMILY                    (C_FAMILY),
       .C_AXI_PROTOCOL              (C_AXI_PROTOCOL),
       .C_AXI_ID_WIDTH              (C_S_AXI_ID_WIDTH),
       .C_SUPPORTS_ID               (C_SUPPORTS_ID),
       .C_AXI_ADDR_WIDTH            (P_AXI_ADDR_WIDTH),
       .C_S_AXI_DATA_WIDTH          (C_S_AXI_DATA_WIDTH),
       .C_M_AXI_DATA_WIDTH          (C_M_AXI_DATA_WIDTH),
       .C_AXI_CHANNEL               (1),
       .C_MAX_SPLIT_BEATS           (P_MAX_SPLIT_BEATS),
       .C_MAX_SPLIT_BEATS_LOG       (P_MAX_SPLIT_BEATS_LOG),
       .C_S_AXI_BYTES_LOG           (C_S_AXI_BYTES_LOG),
       .C_M_AXI_BYTES_LOG           (C_M_AXI_BYTES_LOG),
       .C_RATIO_LOG                 (C_RATIO_LOG)
        ) read_addr_inst
       (
        // Global Signals
        .ARESET                     (!aresetn),
        .ACLK                       (aclk),
    
        // Command Interface (R)
        .cmd_valid                  (rd_cmd_valid),
        .cmd_split                  (rd_cmd_split),
        .cmd_mirror                 (rd_cmd_mirror),
        .cmd_fix                    (rd_cmd_fix),
        .cmd_first_word             (rd_cmd_first_word),
        .cmd_offset                 (rd_cmd_offset),
        .cmd_mask                   (rd_cmd_mask),
        .cmd_step                   (rd_cmd_step),
        .cmd_size                   (rd_cmd_size),
        .cmd_length                 (rd_cmd_length),
        .cmd_ready                  (rd_cmd_ready),
        .cmd_id                     (rd_cmd_id),
       
        // Command Interface (B)
        .cmd_b_valid                (),
        .cmd_b_split                (),
        .cmd_b_repeat               (),
        .cmd_b_ready                (1'b0),
       
        // Slave Interface Write Address Ports
        .S_AXI_AID                  (s_axi_arid),
        .S_AXI_AADDR                (s_axi_araddr_i),
        .S_AXI_ALEN                 (s_axi_arlen_i),
        .S_AXI_ASIZE                (s_axi_arsize),
        .S_AXI_ABURST               (s_axi_arburst),
        .S_AXI_ALOCK                (s_axi_arlock_i),
        .S_AXI_ACACHE               (s_axi_arcache),
        .S_AXI_APROT                (s_axi_arprot),
        .S_AXI_AREGION              (s_axi_arregion),
        .S_AXI_AQOS                 (s_axi_arqos),
        .S_AXI_AVALID               (s_axi_arvalid),
        .S_AXI_AREADY               (s_axi_arready),
        
        // Master Interface Write Address Port
        .M_AXI_AADDR                (m_axi_araddr_i),
        .M_AXI_ALEN                 (m_axi_arlen),
        .M_AXI_ASIZE                (m_axi_arsize),
        .M_AXI_ABURST               (m_axi_arburst),
        .M_AXI_ALOCK                (m_axi_arlock),
        .M_AXI_ACACHE               (m_axi_arcache),
        .M_AXI_APROT                (m_axi_arprot),
        .M_AXI_AREGION              (m_axi_arregion),
        .M_AXI_AQOS                 (m_axi_arqos),
        .M_AXI_AVALID               (m_axi_arvalid),
        .M_AXI_AREADY               (m_axi_arready)
       );
       
      // Read Data channel.
      axi_dwidth_converter_v2_1_r_downsizer #
      (
       .C_FAMILY                    (C_FAMILY),
       .C_AXI_ID_WIDTH              (C_S_AXI_ID_WIDTH),
       .C_S_AXI_DATA_WIDTH          (C_S_AXI_DATA_WIDTH),
       .C_M_AXI_DATA_WIDTH          (C_M_AXI_DATA_WIDTH),
       .C_S_AXI_BYTES_LOG           (C_S_AXI_BYTES_LOG),
       .C_M_AXI_BYTES_LOG           (C_M_AXI_BYTES_LOG),
       .C_RATIO_LOG                 (C_RATIO_LOG)
        ) read_data_inst
       (
        // Global Signals
        .ARESET                     (!aresetn),
        .ACLK                       (aclk),
    
        // Command Interface
        .cmd_valid                  (rd_cmd_valid),
        .cmd_split                  (rd_cmd_split),
        .cmd_mirror                 (rd_cmd_mirror),
        .cmd_fix                    (rd_cmd_fix),
        .cmd_first_word             (rd_cmd_first_word),
        .cmd_offset                 (rd_cmd_offset),
        .cmd_mask                   (rd_cmd_mask),
        .cmd_step                   (rd_cmd_step),
        .cmd_size                   (rd_cmd_size),
        .cmd_length                 (rd_cmd_length),
        .cmd_ready                  (rd_cmd_ready),
        .cmd_id                     (rd_cmd_id),
       
        // Slave Interface Read Data Ports
        .S_AXI_RID                  (s_axi_rid),
        .S_AXI_RDATA                (s_axi_rdata),
        .S_AXI_RRESP                (s_axi_rresp),
        .S_AXI_RLAST                (s_axi_rlast),
        .S_AXI_RVALID               (s_axi_rvalid),
        .S_AXI_RREADY               (s_axi_rready),
        
        // Master Interface Read Data Ports
        .M_AXI_RDATA                (m_axi_rdata),
        .M_AXI_RRESP                (m_axi_rresp),
        .M_AXI_RLAST                (m_axi_rlast),
        .M_AXI_RVALID               (m_axi_rvalid),
        .M_AXI_RREADY               (m_axi_rready)
       );
       
    end else begin : NO_READ
      // Slave Interface Read Address Ports
      assign s_axi_arready = 1'b0;
      // Slave Interface Read Data Ports
      assign s_axi_rid     = {C_S_AXI_ID_WIDTH{1'b0}};
      assign s_axi_rdata   = {C_S_AXI_DATA_WIDTH{1'b0}};
      assign s_axi_rresp   = 2'b0;
      assign s_axi_rlast   = 1'b0;
//      assign s_axi_ruser   = {C_AXI_RUSER_WIDTH{1'b0}};
      assign s_axi_rvalid  = 1'b0;
      
      // Master Interface Read Address Port
      assign m_axi_araddr_i  = {P_AXI_ADDR_WIDTH{1'b0}};
      assign m_axi_arlen   = 8'b0;
      assign m_axi_arsize  = 3'b0;
      assign m_axi_arburst = 2'b0;
      assign m_axi_arlock  = 2'b0;
      assign m_axi_arcache = 4'b0;
      assign m_axi_arprot  = 3'b0;
      assign m_axi_arregion = 4'b0;
      assign m_axi_arqos   = 4'b0;
      assign m_axi_arvalid = 1'b0;
      // Master Interface Read Data Ports
      assign m_axi_rready  = 1'b0;
      
    end
  endgenerate
  
endmodule

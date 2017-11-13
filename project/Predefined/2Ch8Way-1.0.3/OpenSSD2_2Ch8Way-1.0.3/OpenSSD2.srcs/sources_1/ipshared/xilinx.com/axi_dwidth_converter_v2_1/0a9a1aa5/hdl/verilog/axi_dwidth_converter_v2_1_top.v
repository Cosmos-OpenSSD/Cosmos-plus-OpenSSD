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
// Description: axi_dwidth_converter
// AXI Memory-mapped data-width converter.
// This module instantiates downsizer and upsizer.
//
// Verilog-standard:  Verilog 2001
//--------------------------------------------------------------------------
//
// Structure:
//   top
//     axi_downsizer
//       a_downsizer
//         axic_fifo
//           fifo_gen
//             fifo_coregen
//       w_downsizer
//       b_downsizer
//       r_downsizer
//     axi_upsizer
//       a_upsizer
//         fifo
//           fifo_gen
//             fifo_coregen
//       w_upsizer
//       w_upsizer_pktfifo
//       r_upsizer
//       r_upsizer_pktfifo
//
//--------------------------------------------------------------------------
`timescale 1ps/1ps

(* DowngradeIPIdentifiedWarnings="yes" *) 
module axi_dwidth_converter_v2_1_top #
  (
   parameter         C_FAMILY                         = "virtex7", 
                       // FPGA Family.
   parameter integer C_AXI_PROTOCOL = 0,
                       // Protocol of SI and MI (0=AXI4, 1=AXI3, 2=AXI4LITE).
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
                       // Range (AXI4LITE): 1 - 64.
   parameter integer C_S_AXI_DATA_WIDTH               = 32,
                       // Width of s_axi_wdata and s_axi_rdata.
                       // Range (AXI4, AXI3): 32, 64, 128, 256, 512, 1024.
                       // Range (AXILITE): 32, 64.
   parameter integer C_M_AXI_DATA_WIDTH               = 64,
                       // Width of m_axi_wdata and m_axi_rdata. 
                       // Range (AXI4, AXI3): 32, 64, 128, 256, 512, 1024.
                       // Range (AXILITE): 32, 64.
                       // S_DATA_WIDTH = M_DATA_WIDTH allowed only when AXI4/AXI3 and PACKING_LEVEL=2.
   parameter integer C_AXI_SUPPORTS_WRITE             = 1,
   parameter integer C_AXI_SUPPORTS_READ              = 1,
   parameter integer C_FIFO_MODE                        = 0,
                       // 0=None, 1=Packet_FIFO, 2=Clock_conversion_Packet_FIFO, 3=Simple_FIFO (FUTURE), 4=Clock_conversion_Simple_FIFO (FUTURE)
   parameter integer C_S_AXI_ACLK_RATIO = 1,     // Clock frequency ratio of SI w.r.t. MI.
                                                 // Range = [1..16].
   parameter integer C_M_AXI_ACLK_RATIO = 2,     // Clock frequency ratio of MI w.r.t. SI.
                                                 // Range = [2..16] if C_S_AXI_ACLK_RATIO = 1; else must be 1.
   parameter integer C_AXI_IS_ACLK_ASYNC = 0,    // Indicates whether S and M clocks are asynchronous.
                                                 // FUTURE FEATURE
                                                 // Range = [0, 1].
   parameter integer C_MAX_SPLIT_BEATS              = 256,
                       // Max burst length after transaction splitting due to downsizing.
                       // Range: 0 (no splitting), 1 (convert to singles), 16, 256.
   parameter integer C_PACKING_LEVEL                    = 1,
                       // Upsizer packing mode.
                       // 0 = Never pack (expander only); packing logic is omitted.
                       // 1 = Pack only when CACHE[1] (Modifiable) is high.
                       // 2 = Always pack, regardless of sub-size transaction or Modifiable bit.
                       //     (Required when used as helper-core by mem-con. Same size AXI interfaces
                       //      should only be used when always packing)
   parameter integer C_SYNCHRONIZER_STAGE = 3
   )
  (
   // Global Signals
   (* KEEP = "TRUE" *) input  wire        s_axi_aclk,
   (* KEEP = "TRUE" *) input  wire        s_axi_aresetn,

   // Slave Interface Write Address Ports
   input  wire [C_S_AXI_ID_WIDTH-1:0]       s_axi_awid,
   input  wire [C_AXI_ADDR_WIDTH-1:0]       s_axi_awaddr,
   input  wire [((C_AXI_PROTOCOL == 1) ? 4 : 8)-1:0] s_axi_awlen,
   input  wire [3-1:0]                      s_axi_awsize,
   input  wire [2-1:0]                      s_axi_awburst,
   input  wire [((C_AXI_PROTOCOL == 1) ? 2 : 1)-1:0] s_axi_awlock,
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
   input  wire [((C_AXI_PROTOCOL == 1) ? 4 : 8)-1:0] s_axi_arlen,
   input  wire [3-1:0]                      s_axi_arsize,
   input  wire [2-1:0]                      s_axi_arburst,
   input  wire [((C_AXI_PROTOCOL == 1) ? 2 : 1)-1:0] s_axi_arlock,
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

   // Master Interface System Signals
   (* KEEP = "TRUE" *) input  wire        m_axi_aclk,
   (* KEEP = "TRUE" *) input  wire        m_axi_aresetn,

   // Master Interface Write Address Port
   output wire [C_AXI_ADDR_WIDTH-1:0]       m_axi_awaddr,
   output wire [((C_AXI_PROTOCOL == 1) ? 4 : 8)-1:0] m_axi_awlen,
   output wire [3-1:0]                      m_axi_awsize,
   output wire [2-1:0]                      m_axi_awburst,
   output wire [((C_AXI_PROTOCOL == 1) ? 2 : 1)-1:0] m_axi_awlock,
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
   output wire [((C_AXI_PROTOCOL == 1) ? 4 : 8)-1:0] m_axi_arlen,
   output wire [3-1:0]                      m_axi_arsize,
   output wire [2-1:0]                      m_axi_arburst,
   output wire [((C_AXI_PROTOCOL == 1) ? 2 : 1)-1:0] m_axi_arlock,
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



  wire aclk = s_axi_aclk;
  wire aresetn = s_axi_aresetn;

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
  localparam integer P_AXI4 = 0;
  localparam integer P_AXI3 = 1;
  localparam integer P_AXILITE = 2;
  localparam integer P_CONVERSION = 2;
  
  localparam integer P_MAX_SPLIT_BEATS = (C_MAX_SPLIT_BEATS >= 16) ? C_MAX_SPLIT_BEATS :
    (C_AXI_PROTOCOL == P_AXI4) ? 256 : 16;

  wire [8-1:0]                  s_axi_awlen_i;
  wire [2-1:0]                  s_axi_awlock_i;
  wire [8-1:0]                  s_axi_arlen_i;
  wire [2-1:0]                  s_axi_arlock_i;
  wire [8-1:0]                  m_axi_awlen_i;
  wire [2-1:0]                  m_axi_awlock_i;
  wire [8-1:0]                  m_axi_arlen_i;
  wire [2-1:0]                  m_axi_arlock_i;
  wire [4-1:0]                  s_axi_awregion_i;
  wire [4-1:0]                  s_axi_arregion_i;
  wire [4-1:0]                  m_axi_awregion_i;
  wire [4-1:0]                  m_axi_arregion_i;
  
  generate
    if (C_AXI_PROTOCOL == P_AXILITE) begin : gen_lite_tieoff
      assign s_axi_bid          = {C_S_AXI_ID_WIDTH{1'b0}} ;
      assign s_axi_rid          = {C_S_AXI_ID_WIDTH{1'b0}} ;
      assign s_axi_rlast        = 1'b0 ;
      assign m_axi_awlen        = 8'b0 ;
      assign m_axi_awsize       = 3'b0 ;
      assign m_axi_awburst      = 2'b0 ;
      assign m_axi_awlock       = 1'b0 ;
      assign m_axi_awcache      = 4'b0 ;
      assign m_axi_awregion     = 4'b0 ;
      assign m_axi_awqos        = 4'b0 ;
      assign m_axi_wlast        = 1'b0 ;
      assign m_axi_arlen        = 8'b0 ;
      assign m_axi_arsize       = 3'b0 ;
      assign m_axi_arburst      = 2'b0 ;
      assign m_axi_arlock       = 1'b0 ;
      assign m_axi_arcache      = 4'b0 ;
      assign m_axi_arregion     = 4'b0 ;
      assign m_axi_arqos        = 4'b0 ;
    end else begin : gen_full_tieoff
      assign s_axi_awlen_i = (C_AXI_PROTOCOL == P_AXI3) ? {4'b0000, s_axi_awlen}: s_axi_awlen;
      assign s_axi_awlock_i = (C_AXI_PROTOCOL == P_AXI3) ? s_axi_awlock : {1'b0, s_axi_awlock};
      assign s_axi_arlen_i = (C_AXI_PROTOCOL == P_AXI3) ? {4'b0000, s_axi_arlen}: s_axi_arlen;
      assign s_axi_arlock_i = (C_AXI_PROTOCOL == P_AXI3) ? s_axi_arlock : {1'b0, s_axi_arlock};
      assign m_axi_awlen = (C_AXI_PROTOCOL == P_AXI3) ? m_axi_awlen_i[3:0]: m_axi_awlen_i;
      assign m_axi_awlock = (C_AXI_PROTOCOL == P_AXI3) ? m_axi_awlock_i : m_axi_awlock_i[0];
      assign m_axi_arlen = (C_AXI_PROTOCOL == P_AXI3) ? m_axi_arlen_i[3:0]: m_axi_arlen_i;
      assign m_axi_arlock = (C_AXI_PROTOCOL == P_AXI3) ? m_axi_arlock_i : m_axi_arlock_i[0];
      assign s_axi_awregion_i = (C_AXI_PROTOCOL == P_AXI3) ? 4'b0 : s_axi_awregion;
      assign s_axi_arregion_i = (C_AXI_PROTOCOL == P_AXI3) ? 4'b0 : s_axi_arregion;
      assign m_axi_awregion = (C_AXI_PROTOCOL == P_AXI3) ? 4'b0 : m_axi_awregion_i;
      assign m_axi_arregion = (C_AXI_PROTOCOL == P_AXI3) ? 4'b0 : m_axi_arregion_i;
    end
    
    if (C_S_AXI_DATA_WIDTH > C_M_AXI_DATA_WIDTH) begin : gen_downsizer
      if (C_AXI_PROTOCOL == P_AXILITE) begin : gen_lite_downsizer
        
        axi_dwidth_converter_v2_1_axi4lite_downsizer #(
          .C_FAMILY                    ( C_FAMILY                    ) ,
          .C_AXI_ADDR_WIDTH            ( C_AXI_ADDR_WIDTH            ) ,
          .C_AXI_SUPPORTS_WRITE        ( C_AXI_SUPPORTS_WRITE        ) ,
          .C_AXI_SUPPORTS_READ         ( C_AXI_SUPPORTS_READ         ) 
        )
        lite_downsizer_inst
        (
          .aresetn                    ( aresetn        ) ,
          .aclk                       ( aclk          ) ,
          .s_axi_awaddr               ( s_axi_awaddr  ) ,
          .s_axi_awprot               ( s_axi_awprot  ) ,
          .s_axi_awvalid              ( s_axi_awvalid ) ,
          .s_axi_awready              ( s_axi_awready ) ,
          .s_axi_wdata                ( s_axi_wdata   ) ,
          .s_axi_wstrb                ( s_axi_wstrb   ) ,
          .s_axi_wvalid               ( s_axi_wvalid  ) ,
          .s_axi_wready               ( s_axi_wready  ) ,
          .s_axi_bresp                ( s_axi_bresp   ) ,
          .s_axi_bvalid               ( s_axi_bvalid  ) ,
          .s_axi_bready               ( s_axi_bready  ) ,
          .s_axi_araddr               ( s_axi_araddr  ) ,
          .s_axi_arprot               ( s_axi_arprot  ) ,
          .s_axi_arvalid              ( s_axi_arvalid ) ,
          .s_axi_arready              ( s_axi_arready ) ,
          .s_axi_rdata                ( s_axi_rdata   ) ,
          .s_axi_rresp                ( s_axi_rresp   ) ,
          .s_axi_rvalid               ( s_axi_rvalid  ) ,
          .s_axi_rready               ( s_axi_rready  ) ,
          .m_axi_awaddr               ( m_axi_awaddr  ) ,
          .m_axi_awprot               ( m_axi_awprot  ) ,
          .m_axi_awvalid              ( m_axi_awvalid ) ,
          .m_axi_awready              ( m_axi_awready ) ,
          .m_axi_wdata                ( m_axi_wdata   ) ,
          .m_axi_wstrb                ( m_axi_wstrb   ) ,
          .m_axi_wvalid               ( m_axi_wvalid  ) ,
          .m_axi_wready               ( m_axi_wready  ) ,
          .m_axi_bresp                ( m_axi_bresp   ) ,
          .m_axi_bvalid               ( m_axi_bvalid  ) ,
          .m_axi_bready               ( m_axi_bready  ) ,
          .m_axi_araddr               ( m_axi_araddr  ) ,
          .m_axi_arprot               ( m_axi_arprot  ) ,
          .m_axi_arvalid              ( m_axi_arvalid ) ,
          .m_axi_arready              ( m_axi_arready ) ,
          .m_axi_rdata                ( m_axi_rdata   ) ,
          .m_axi_rresp                ( m_axi_rresp   ) ,
          .m_axi_rvalid               ( m_axi_rvalid  ) ,
          .m_axi_rready               ( m_axi_rready  )
        );
        
      end else if (((C_AXI_PROTOCOL == P_AXI3) && (P_MAX_SPLIT_BEATS > 0)) || (P_MAX_SPLIT_BEATS < 256) || (C_RATIO > 16)) begin : gen_cascaded_downsizer
        
        localparam integer P_DATA_WIDTH_I = (C_RATIO > 16) ? 64 : C_M_AXI_DATA_WIDTH;
        
        wire [C_AXI_ADDR_WIDTH-1:0]       awaddr_i     ;
        wire [8-1:0]                      awlen_i     ;
        wire [3-1:0]                      awsize_i     ;
        wire [2-1:0]                      awburst_i     ;
        wire [2-1:0]                      awlock_i     ;
        wire [4-1:0]                      awcache_i     ;
        wire [3-1:0]                      awprot_i     ;
        wire [4-1:0]                      awregion_i     ;
        wire [4-1:0]                      awqos_i     ;
        wire                              awvalid_i     ;
        wire                              awready_i     ;
        wire [P_DATA_WIDTH_I-1:0]         wdata_i     ;
        wire [P_DATA_WIDTH_I/8-1:0]       wstrb_i     ;
        wire                              wlast_i     ;
        wire                              wvalid_i     ;
        wire                              wready_i     ;
        wire [2-1:0]                      bresp_i     ;
        wire                              bvalid_i     ;
        wire                              bready_i     ;
        wire [C_AXI_ADDR_WIDTH-1:0]       araddr_i     ;
        wire [8-1:0]                      arlen_i     ;
        wire [3-1:0]                      arsize_i     ;
        wire [2-1:0]                      arburst_i     ;
        wire [2-1:0]                      arlock_i     ;
        wire [4-1:0]                      arcache_i     ;
        wire [3-1:0]                      arprot_i     ;
        wire [4-1:0]                      arregion_i     ;
        wire [4-1:0]                      arqos_i     ;
        wire                              arvalid_i     ;
        wire                              arready_i     ;
        wire [P_DATA_WIDTH_I-1:0]         rdata_i     ;
        wire [2-1:0]                      rresp_i     ;
        wire                              rlast_i     ;
        wire                              rvalid_i     ;
        wire                              rready_i    ;
        wire [4-1:0]                      m_axi_awlen_ii;
        wire [4-1:0]                      m_axi_arlen_ii;
        wire [1-1:0]                      awlock_ii;
        wire [1-1:0]                      arlock_ii;
        
        axi_dwidth_converter_v2_1_axi_downsizer #(
          .C_FAMILY                    ( C_FAMILY                    ) ,
          .C_AXI_PROTOCOL              ( C_AXI_PROTOCOL              ) ,
          .C_S_AXI_ID_WIDTH            ( C_S_AXI_ID_WIDTH              ) ,
          .C_SUPPORTS_ID               ( C_SUPPORTS_ID ),
          .C_AXI_ADDR_WIDTH            ( C_AXI_ADDR_WIDTH            ) ,
          .C_S_AXI_DATA_WIDTH          ( C_S_AXI_DATA_WIDTH          ) ,
          .C_M_AXI_DATA_WIDTH          ( P_DATA_WIDTH_I          ) ,
          .C_AXI_SUPPORTS_WRITE        ( C_AXI_SUPPORTS_WRITE        ) ,
          .C_AXI_SUPPORTS_READ         ( C_AXI_SUPPORTS_READ         ) ,
          .C_MAX_SPLIT_BEATS           ( 256         ) 
        )
        first_downsizer_inst
        (
          .aresetn                    ( aresetn        ) ,
          .aclk                       ( aclk          ) ,
          .s_axi_awid                 ( s_axi_awid    ) ,
          .s_axi_awaddr               ( s_axi_awaddr  ) ,
          .s_axi_awlen                ( s_axi_awlen_i   ) ,
          .s_axi_awsize               ( s_axi_awsize  ) ,
          .s_axi_awburst              ( s_axi_awburst ) ,
          .s_axi_awlock               ( s_axi_awlock_i  ) ,
          .s_axi_awcache              ( s_axi_awcache ) ,
          .s_axi_awprot               ( s_axi_awprot  ) ,
          .s_axi_awregion             ( s_axi_awregion_i) ,
          .s_axi_awqos                ( s_axi_awqos   ) ,
          .s_axi_awvalid              ( s_axi_awvalid ) ,
          .s_axi_awready              ( s_axi_awready ) ,
          .s_axi_wdata                ( s_axi_wdata   ) ,
          .s_axi_wstrb                ( s_axi_wstrb   ) ,
          .s_axi_wlast                ( s_axi_wlast   ) ,
          .s_axi_wvalid               ( s_axi_wvalid  ) ,
          .s_axi_wready               ( s_axi_wready  ) ,
          .s_axi_bid                  ( s_axi_bid     ) ,
          .s_axi_bresp                ( s_axi_bresp   ) ,
          .s_axi_bvalid               ( s_axi_bvalid  ) ,
          .s_axi_bready               ( s_axi_bready  ) ,
          .s_axi_arid                 ( s_axi_arid    ) ,
          .s_axi_araddr               ( s_axi_araddr  ) ,
          .s_axi_arlen                ( s_axi_arlen_i   ) ,
          .s_axi_arsize               ( s_axi_arsize  ) ,
          .s_axi_arburst              ( s_axi_arburst ) ,
          .s_axi_arlock               ( s_axi_arlock_i  ) ,
          .s_axi_arcache              ( s_axi_arcache ) ,
          .s_axi_arprot               ( s_axi_arprot  ) ,
          .s_axi_arregion             ( s_axi_arregion_i) ,
          .s_axi_arqos                ( s_axi_arqos   ) ,
          .s_axi_arvalid              ( s_axi_arvalid ) ,
          .s_axi_arready              ( s_axi_arready ) ,
          .s_axi_rid                  ( s_axi_rid     ) ,
          .s_axi_rdata                ( s_axi_rdata   ) ,
          .s_axi_rresp                ( s_axi_rresp   ) ,
          .s_axi_rlast                ( s_axi_rlast   ) ,
          .s_axi_rvalid               ( s_axi_rvalid  ) ,
          .s_axi_rready               ( s_axi_rready  ) ,
          .m_axi_awaddr               ( awaddr_i      ) ,
          .m_axi_awlen                ( awlen_i       ) ,
          .m_axi_awsize               ( awsize_i      ) ,
          .m_axi_awburst              ( awburst_i     ) ,
          .m_axi_awlock               ( awlock_i      ) ,
          .m_axi_awcache              ( awcache_i     ) ,
          .m_axi_awprot               ( awprot_i      ) ,
          .m_axi_awregion             ( awregion_i    ) ,
          .m_axi_awqos                ( awqos_i       ) ,
          .m_axi_awvalid              ( awvalid_i     ) ,
          .m_axi_awready              ( awready_i     ) ,
          .m_axi_wdata                ( wdata_i       ) ,
          .m_axi_wstrb                ( wstrb_i       ) ,
          .m_axi_wlast                ( wlast_i       ) ,
          .m_axi_wvalid               ( wvalid_i      ) ,
          .m_axi_wready               ( wready_i      ) ,
          .m_axi_bresp                ( bresp_i       ) ,
          .m_axi_bvalid               ( bvalid_i      ) ,
          .m_axi_bready               ( bready_i      ) ,
          .m_axi_araddr               ( araddr_i      ) ,
          .m_axi_arlen                ( arlen_i       ) ,
          .m_axi_arsize               ( arsize_i      ) ,
          .m_axi_arburst              ( arburst_i     ) ,
          .m_axi_arlock               ( arlock_i      ) ,
          .m_axi_arcache              ( arcache_i     ) ,
          .m_axi_arprot               ( arprot_i      ) ,
          .m_axi_arregion             ( arregion_i    ) ,
          .m_axi_arqos                ( arqos_i       ) ,
          .m_axi_arvalid              ( arvalid_i     ) ,
          .m_axi_arready              ( arready_i     ) ,
          .m_axi_rdata                ( rdata_i       ) ,
          .m_axi_rresp                ( rresp_i       ) ,
          .m_axi_rlast                ( rlast_i       ) ,
          .m_axi_rvalid               ( rvalid_i      ) ,
          .m_axi_rready               ( rready_i      ) 
        );
        
        if (C_RATIO > 16) begin : gen_second_downsizer
          
          axi_dwidth_converter_v2_1_axi_downsizer #(
            .C_FAMILY                    ( C_FAMILY                    ) ,
            .C_AXI_PROTOCOL              ( C_AXI_PROTOCOL              ) ,
            .C_S_AXI_ID_WIDTH            ( 1              ) ,
            .C_SUPPORTS_ID               ( 0 ),
            .C_AXI_ADDR_WIDTH            ( C_AXI_ADDR_WIDTH            ) ,
            .C_S_AXI_DATA_WIDTH          ( P_DATA_WIDTH_I          ) ,
            .C_M_AXI_DATA_WIDTH          ( C_M_AXI_DATA_WIDTH          ) ,
            .C_AXI_SUPPORTS_WRITE        ( C_AXI_SUPPORTS_WRITE        ) ,
            .C_AXI_SUPPORTS_READ         ( C_AXI_SUPPORTS_READ         ) ,
            .C_MAX_SPLIT_BEATS           ( P_MAX_SPLIT_BEATS         ) 
          )
          second_downsizer_inst
          (
            .aresetn                    ( aresetn       ) ,
            .aclk                       ( aclk          ) ,
            .s_axi_awid                 ( 1'b0          ) ,
            .s_axi_awaddr               ( awaddr_i      ) ,  
            .s_axi_awlen                ( awlen_i       ) ,  
            .s_axi_awsize               ( awsize_i      ) ,  
            .s_axi_awburst              ( awburst_i     ) ,  
            .s_axi_awlock               ( awlock_i      ) ,  
            .s_axi_awcache              ( awcache_i     ) ,  
            .s_axi_awprot               ( awprot_i      ) ,  
            .s_axi_awregion             ( awregion_i    ) ,  
            .s_axi_awqos                ( awqos_i       ) ,  
            .s_axi_awvalid              ( awvalid_i     ) ,  
            .s_axi_awready              ( awready_i     ) ,  
            .s_axi_wdata                ( wdata_i       ) ,  
            .s_axi_wstrb                ( wstrb_i       ) ,  
            .s_axi_wlast                ( wlast_i       ) ,  
            .s_axi_wvalid               ( wvalid_i      ) ,  
            .s_axi_wready               ( wready_i      ) ,  
            .s_axi_bid                  (               ) ,
            .s_axi_bresp                ( bresp_i       ) ,   
            .s_axi_bvalid               ( bvalid_i      ) ,   
            .s_axi_bready               ( bready_i      ) ,    
            .s_axi_arid                 ( 1'b0          ) ,  
            .s_axi_araddr               ( araddr_i      ) , 
            .s_axi_arlen                ( arlen_i       ) ,  
            .s_axi_arsize               ( arsize_i      ) ,  
            .s_axi_arburst              ( arburst_i     ) ,  
            .s_axi_arlock               ( arlock_i      ) ,  
            .s_axi_arcache              ( arcache_i     ) ,  
            .s_axi_arprot               ( arprot_i      ) ,  
            .s_axi_arregion             ( arregion_i    ) , 
            .s_axi_arqos                ( arqos_i       ) ,  
            .s_axi_arvalid              ( arvalid_i     ) ,  
            .s_axi_arready              ( arready_i     ) , 
            .s_axi_rid                  (               ) ,
            .s_axi_rdata                ( rdata_i       ) ,   
            .s_axi_rresp                ( rresp_i       ) ,   
            .s_axi_rlast                ( rlast_i       ) ,   
            .s_axi_rvalid               ( rvalid_i      ) ,   
            .s_axi_rready               ( rready_i      ) ,
            .m_axi_awaddr               ( m_axi_awaddr  ) ,
            .m_axi_awlen                ( m_axi_awlen_i   ) ,
            .m_axi_awsize               ( m_axi_awsize  ) ,
            .m_axi_awburst              ( m_axi_awburst ) ,
            .m_axi_awlock               ( m_axi_awlock_i  ) ,
            .m_axi_awcache              ( m_axi_awcache ) ,
            .m_axi_awprot               ( m_axi_awprot  ) ,
            .m_axi_awregion             ( m_axi_awregion_i) ,
            .m_axi_awqos                ( m_axi_awqos   ) ,
            .m_axi_awvalid              ( m_axi_awvalid ) ,
            .m_axi_awready              ( m_axi_awready ) ,
            .m_axi_wdata                ( m_axi_wdata   ) ,
            .m_axi_wstrb                ( m_axi_wstrb   ) ,
            .m_axi_wlast                ( m_axi_wlast   ) ,
            .m_axi_wvalid               ( m_axi_wvalid  ) ,
            .m_axi_wready               ( m_axi_wready  ) ,
            .m_axi_bresp                ( m_axi_bresp   ) ,
            .m_axi_bvalid               ( m_axi_bvalid  ) ,
            .m_axi_bready               ( m_axi_bready  ) ,
            .m_axi_araddr               ( m_axi_araddr  ) ,
            .m_axi_arlen                ( m_axi_arlen_i   ) ,
            .m_axi_arsize               ( m_axi_arsize  ) ,
            .m_axi_arburst              ( m_axi_arburst ) ,
            .m_axi_arlock               ( m_axi_arlock_i  ) ,
            .m_axi_arcache              ( m_axi_arcache ) ,
            .m_axi_arprot               ( m_axi_arprot  ) ,
            .m_axi_arregion             ( m_axi_arregion_i) ,
            .m_axi_arqos                ( m_axi_arqos   ) ,
            .m_axi_arvalid              ( m_axi_arvalid ) ,
            .m_axi_arready              ( m_axi_arready ) ,
            .m_axi_rdata                ( m_axi_rdata   ) ,
            .m_axi_rresp                ( m_axi_rresp   ) ,
            .m_axi_rlast                ( m_axi_rlast   ) ,
            .m_axi_rvalid               ( m_axi_rvalid  ) ,
            .m_axi_rready               ( m_axi_rready  )
          );
          
        end else begin : gen_axi3_conv
          
          axi_protocol_converter_v2_1_axi_protocol_converter #(
            .C_FAMILY                    ( C_FAMILY                    ) ,
            .C_S_AXI_PROTOCOL            ( P_AXI4              ) ,
            .C_M_AXI_PROTOCOL            ( P_AXI3              ) ,
            .C_AXI_ID_WIDTH              ( 1              ) ,
            .C_AXI_ADDR_WIDTH            ( C_AXI_ADDR_WIDTH            ) ,
            .C_AXI_DATA_WIDTH            ( C_M_AXI_DATA_WIDTH          ) ,
            .C_AXI_SUPPORTS_WRITE        ( C_AXI_SUPPORTS_WRITE        ) ,
            .C_AXI_SUPPORTS_READ         ( C_AXI_SUPPORTS_READ         ) ,
            .C_AXI_SUPPORTS_USER_SIGNALS (0) ,
            .C_TRANSLATION_MODE          ( P_CONVERSION         ) 
          )
          axi3_conv_inst
          (
            .aresetn                    ( aresetn       ) ,
            .aclk                       ( aclk          ) ,
            .s_axi_awid                 ( 1'b0          ) ,
            .s_axi_awaddr               ( awaddr_i      ) ,  
            .s_axi_awlen                ( awlen_i       ) ,  
            .s_axi_awsize               ( awsize_i      ) ,  
            .s_axi_awburst              ( awburst_i     ) ,  
            .s_axi_awlock               ( awlock_ii      ) ,  
            .s_axi_awcache              ( awcache_i     ) ,  
            .s_axi_awprot               ( awprot_i      ) ,  
            .s_axi_awregion             ( awregion_i    ) ,  
            .s_axi_awqos                ( awqos_i       ) ,  
            .s_axi_awvalid              ( awvalid_i     ) ,  
            .s_axi_awready              ( awready_i     ) ,  
            .s_axi_wdata                ( wdata_i       ) ,  
            .s_axi_wstrb                ( wstrb_i       ) ,  
            .s_axi_wlast                ( wlast_i       ) ,  
            .s_axi_wvalid               ( wvalid_i      ) ,  
            .s_axi_wready               ( wready_i      ) ,  
            .s_axi_bid                  (               ) ,
            .s_axi_bresp                ( bresp_i       ) ,   
            .s_axi_bvalid               ( bvalid_i      ) ,   
            .s_axi_bready               ( bready_i      ) ,    
            .s_axi_arid                 ( 1'b0          ) ,  
            .s_axi_araddr               ( araddr_i      ) , 
            .s_axi_arlen                ( arlen_i       ) ,  
            .s_axi_arsize               ( arsize_i      ) ,  
            .s_axi_arburst              ( arburst_i     ) ,  
            .s_axi_arlock               ( arlock_ii      ) ,  
            .s_axi_arcache              ( arcache_i     ) ,  
            .s_axi_arprot               ( arprot_i      ) ,  
            .s_axi_arregion             ( arregion_i    ) , 
            .s_axi_arqos                ( arqos_i       ) ,  
            .s_axi_arvalid              ( arvalid_i     ) ,  
            .s_axi_arready              ( arready_i     ) , 
            .s_axi_rid                  (               ) ,
            .s_axi_rdata                ( rdata_i       ) ,   
            .s_axi_rresp                ( rresp_i       ) ,   
            .s_axi_rlast                ( rlast_i       ) ,   
            .s_axi_rvalid               ( rvalid_i      ) ,   
            .s_axi_rready               ( rready_i      ) ,
            .m_axi_awaddr               ( m_axi_awaddr  ) ,
            .m_axi_awlen                ( m_axi_awlen_ii   ) ,
            .m_axi_awsize               ( m_axi_awsize  ) ,
            .m_axi_awburst              ( m_axi_awburst ) ,
            .m_axi_awlock               ( m_axi_awlock_i  ) ,
            .m_axi_awcache              ( m_axi_awcache ) ,
            .m_axi_awprot               ( m_axi_awprot  ) ,
            .m_axi_awregion             ( m_axi_awregion_i) ,
            .m_axi_awqos                ( m_axi_awqos   ) ,
            .m_axi_awvalid              ( m_axi_awvalid ) ,
            .m_axi_awready              ( m_axi_awready ) ,
            .m_axi_wdata                ( m_axi_wdata   ) ,
            .m_axi_wstrb                ( m_axi_wstrb   ) ,
            .m_axi_wlast                ( m_axi_wlast   ) ,
            .m_axi_wvalid               ( m_axi_wvalid  ) ,
            .m_axi_wready               ( m_axi_wready  ) ,
            .m_axi_bresp                ( m_axi_bresp   ) ,
            .m_axi_bvalid               ( m_axi_bvalid  ) ,
            .m_axi_bready               ( m_axi_bready  ) ,
            .m_axi_araddr               ( m_axi_araddr  ) ,
            .m_axi_arlen                ( m_axi_arlen_ii   ) ,
            .m_axi_arsize               ( m_axi_arsize  ) ,
            .m_axi_arburst              ( m_axi_arburst ) ,
            .m_axi_arlock               ( m_axi_arlock_i  ) ,
            .m_axi_arcache              ( m_axi_arcache ) ,
            .m_axi_arprot               ( m_axi_arprot  ) ,
            .m_axi_arregion             ( m_axi_arregion_i) ,
            .m_axi_arqos                ( m_axi_arqos   ) ,
            .m_axi_arvalid              ( m_axi_arvalid ) ,
            .m_axi_arready              ( m_axi_arready ) ,
            .m_axi_rdata                ( m_axi_rdata   ) ,
            .m_axi_rresp                ( m_axi_rresp   ) ,
            .m_axi_rlast                ( m_axi_rlast   ) ,
            .m_axi_rvalid               ( m_axi_rvalid  ) ,
            .m_axi_rready               ( m_axi_rready  ) ,
            .m_axi_awid                 ( ) ,
            .m_axi_wid                  ( ) ,
            .m_axi_bid                  ( 1'b0 ) ,
            .m_axi_arid                 ( ) ,
            .m_axi_rid                  ( 1'b0 ) ,
            .s_axi_wid                  ( 1'b0 ) ,
            .s_axi_awuser               ( 1'b0 ) ,
            .s_axi_wuser                ( 1'b0 ) ,
            .s_axi_buser                ( ) ,
            .s_axi_aruser               ( 1'b0 ) ,
            .s_axi_ruser                ( ) ,
            .m_axi_awuser               ( ) ,
            .m_axi_wuser                ( ) ,
            .m_axi_buser                ( 1'b0 ) ,
            .m_axi_aruser               ( ) ,
            .m_axi_ruser                ( 1'b0 ) 
          );
          
          assign awlock_ii = awlock_i[0];
          assign arlock_ii = arlock_i[0];
          assign m_axi_awlen_i = {4'b0, m_axi_awlen_ii};
          assign m_axi_arlen_i = {4'b0, m_axi_arlen_ii};
        end
        
      end else begin : gen_simple_downsizer
        
        axi_dwidth_converter_v2_1_axi_downsizer #(
          .C_FAMILY                    ( C_FAMILY                    ) ,
          .C_AXI_PROTOCOL              ( C_AXI_PROTOCOL              ) ,
          .C_S_AXI_ID_WIDTH            ( C_S_AXI_ID_WIDTH              ) ,
          .C_SUPPORTS_ID               ( C_SUPPORTS_ID ),
          .C_AXI_ADDR_WIDTH            ( C_AXI_ADDR_WIDTH            ) ,
          .C_S_AXI_DATA_WIDTH          ( C_S_AXI_DATA_WIDTH          ) ,
          .C_M_AXI_DATA_WIDTH          ( C_M_AXI_DATA_WIDTH          ) ,
          .C_AXI_SUPPORTS_WRITE        ( C_AXI_SUPPORTS_WRITE        ) ,
          .C_AXI_SUPPORTS_READ         ( C_AXI_SUPPORTS_READ         ) ,
          .C_MAX_SPLIT_BEATS           ( P_MAX_SPLIT_BEATS         ) 
        )
        axi_downsizer_inst
        (
          .aresetn                    ( aresetn        ) ,
          .aclk                       ( aclk          ) ,
          .s_axi_awid                 ( s_axi_awid    ) ,
          .s_axi_awaddr               ( s_axi_awaddr  ) ,
          .s_axi_awlen                ( s_axi_awlen_i   ) ,
          .s_axi_awsize               ( s_axi_awsize  ) ,
          .s_axi_awburst              ( s_axi_awburst ) ,
          .s_axi_awlock               ( s_axi_awlock_i  ) ,
          .s_axi_awcache              ( s_axi_awcache ) ,
          .s_axi_awprot               ( s_axi_awprot  ) ,
          .s_axi_awregion             ( s_axi_awregion_i) ,
          .s_axi_awqos                ( s_axi_awqos   ) ,
          .s_axi_awvalid              ( s_axi_awvalid ) ,
          .s_axi_awready              ( s_axi_awready ) ,
          .s_axi_wdata                ( s_axi_wdata   ) ,
          .s_axi_wstrb                ( s_axi_wstrb   ) ,
          .s_axi_wlast                ( s_axi_wlast   ) ,
          .s_axi_wvalid               ( s_axi_wvalid  ) ,
          .s_axi_wready               ( s_axi_wready  ) ,
          .s_axi_bid                  ( s_axi_bid     ) ,
          .s_axi_bresp                ( s_axi_bresp   ) ,
          .s_axi_bvalid               ( s_axi_bvalid  ) ,
          .s_axi_bready               ( s_axi_bready  ) ,
          .s_axi_arid                 ( s_axi_arid    ) ,
          .s_axi_araddr               ( s_axi_araddr  ) ,
          .s_axi_arlen                ( s_axi_arlen_i   ) ,
          .s_axi_arsize               ( s_axi_arsize  ) ,
          .s_axi_arburst              ( s_axi_arburst ) ,
          .s_axi_arlock               ( s_axi_arlock_i  ) ,
          .s_axi_arcache              ( s_axi_arcache ) ,
          .s_axi_arprot               ( s_axi_arprot  ) ,
          .s_axi_arregion             ( s_axi_arregion_i) ,
          .s_axi_arqos                ( s_axi_arqos   ) ,
          .s_axi_arvalid              ( s_axi_arvalid ) ,
          .s_axi_arready              ( s_axi_arready ) ,
          .s_axi_rid                  ( s_axi_rid     ) ,
          .s_axi_rdata                ( s_axi_rdata   ) ,
          .s_axi_rresp                ( s_axi_rresp   ) ,
          .s_axi_rlast                ( s_axi_rlast   ) ,
          .s_axi_rvalid               ( s_axi_rvalid  ) ,
          .s_axi_rready               ( s_axi_rready  ) ,
          .m_axi_awaddr               ( m_axi_awaddr  ) ,
          .m_axi_awlen                ( m_axi_awlen_i   ) ,
          .m_axi_awsize               ( m_axi_awsize  ) ,
          .m_axi_awburst              ( m_axi_awburst ) ,
          .m_axi_awlock               ( m_axi_awlock_i  ) ,
          .m_axi_awcache              ( m_axi_awcache ) ,
          .m_axi_awprot               ( m_axi_awprot  ) ,
          .m_axi_awregion             ( m_axi_awregion_i) ,
          .m_axi_awqos                ( m_axi_awqos   ) ,
          .m_axi_awvalid              ( m_axi_awvalid ) ,
          .m_axi_awready              ( m_axi_awready ) ,
          .m_axi_wdata                ( m_axi_wdata   ) ,
          .m_axi_wstrb                ( m_axi_wstrb   ) ,
          .m_axi_wlast                ( m_axi_wlast   ) ,
          .m_axi_wvalid               ( m_axi_wvalid  ) ,
          .m_axi_wready               ( m_axi_wready  ) ,
          .m_axi_bresp                ( m_axi_bresp   ) ,
          .m_axi_bvalid               ( m_axi_bvalid  ) ,
          .m_axi_bready               ( m_axi_bready  ) ,
          .m_axi_araddr               ( m_axi_araddr  ) ,
          .m_axi_arlen                ( m_axi_arlen_i   ) ,
          .m_axi_arsize               ( m_axi_arsize  ) ,
          .m_axi_arburst              ( m_axi_arburst ) ,
          .m_axi_arlock               ( m_axi_arlock_i  ) ,
          .m_axi_arcache              ( m_axi_arcache ) ,
          .m_axi_arprot               ( m_axi_arprot  ) ,
          .m_axi_arregion             ( m_axi_arregion_i) ,
          .m_axi_arqos                ( m_axi_arqos   ) ,
          .m_axi_arvalid              ( m_axi_arvalid ) ,
          .m_axi_arready              ( m_axi_arready ) ,
          .m_axi_rdata                ( m_axi_rdata   ) ,
          .m_axi_rresp                ( m_axi_rresp   ) ,
          .m_axi_rlast                ( m_axi_rlast   ) ,
          .m_axi_rvalid               ( m_axi_rvalid  ) ,
          .m_axi_rready               ( m_axi_rready  )
        );
      end
      
    end else begin : gen_upsizer
      
      if (C_AXI_PROTOCOL == P_AXILITE) begin : gen_lite_upsizer
        
        axi_dwidth_converter_v2_1_axi4lite_upsizer #(
          .C_FAMILY                    ( C_FAMILY                    ) ,
          .C_AXI_ADDR_WIDTH            ( C_AXI_ADDR_WIDTH            ) ,
          .C_AXI_SUPPORTS_WRITE        ( C_AXI_SUPPORTS_WRITE        ) ,
          .C_AXI_SUPPORTS_READ         ( C_AXI_SUPPORTS_READ         ) 
        )
        lite_upsizer_inst
        (
          .aresetn                    ( aresetn        ) ,
          .aclk                       ( aclk          ) ,
          .s_axi_awaddr               ( s_axi_awaddr  ) ,
          .s_axi_awprot               ( s_axi_awprot  ) ,
          .s_axi_awvalid              ( s_axi_awvalid ) ,
          .s_axi_awready              ( s_axi_awready ) ,
          .s_axi_wdata                ( s_axi_wdata   ) ,
          .s_axi_wstrb                ( s_axi_wstrb   ) ,
          .s_axi_wvalid               ( s_axi_wvalid  ) ,
          .s_axi_wready               ( s_axi_wready  ) ,
          .s_axi_bresp                ( s_axi_bresp   ) ,
          .s_axi_bvalid               ( s_axi_bvalid  ) ,
          .s_axi_bready               ( s_axi_bready  ) ,
          .s_axi_araddr               ( s_axi_araddr  ) ,
          .s_axi_arprot               ( s_axi_arprot  ) ,
          .s_axi_arvalid              ( s_axi_arvalid ) ,
          .s_axi_arready              ( s_axi_arready ) ,
          .s_axi_rdata                ( s_axi_rdata   ) ,
          .s_axi_rresp                ( s_axi_rresp   ) ,
          .s_axi_rvalid               ( s_axi_rvalid  ) ,
          .s_axi_rready               ( s_axi_rready  ) ,
          .m_axi_awaddr               ( m_axi_awaddr  ) ,
          .m_axi_awprot               ( m_axi_awprot  ) ,
          .m_axi_awvalid              ( m_axi_awvalid ) ,
          .m_axi_awready              ( m_axi_awready ) ,
          .m_axi_wdata                ( m_axi_wdata   ) ,
          .m_axi_wstrb                ( m_axi_wstrb   ) ,
          .m_axi_wvalid               ( m_axi_wvalid  ) ,
          .m_axi_wready               ( m_axi_wready  ) ,
          .m_axi_bresp                ( m_axi_bresp   ) ,
          .m_axi_bvalid               ( m_axi_bvalid  ) ,
          .m_axi_bready               ( m_axi_bready  ) ,
          .m_axi_araddr               ( m_axi_araddr  ) ,
          .m_axi_arprot               ( m_axi_arprot  ) ,
          .m_axi_arvalid              ( m_axi_arvalid ) ,
          .m_axi_arready              ( m_axi_arready ) ,
          .m_axi_rdata                ( m_axi_rdata   ) ,
          .m_axi_rresp                ( m_axi_rresp   ) ,
          .m_axi_rvalid               ( m_axi_rvalid  ) ,
          .m_axi_rready               ( m_axi_rready  )
        );
        
      end else begin : gen_full_upsizer
      
        axi_dwidth_converter_v2_1_axi_upsizer #(
          .C_FAMILY                    ( C_FAMILY                    ) ,
          .C_AXI_PROTOCOL              ( C_AXI_PROTOCOL              ) ,
          .C_S_AXI_ID_WIDTH            ( C_S_AXI_ID_WIDTH              ) ,
          .C_SUPPORTS_ID               ( C_SUPPORTS_ID ),
          .C_AXI_ADDR_WIDTH            ( C_AXI_ADDR_WIDTH            ) ,
          .C_S_AXI_DATA_WIDTH          ( C_S_AXI_DATA_WIDTH          ) ,
          .C_M_AXI_DATA_WIDTH          ( C_M_AXI_DATA_WIDTH          ) ,
          .C_AXI_SUPPORTS_WRITE        ( C_AXI_SUPPORTS_WRITE        ) ,
          .C_AXI_SUPPORTS_READ         ( C_AXI_SUPPORTS_READ         ) ,
          .C_FIFO_MODE   (C_FIFO_MODE),
          .C_S_AXI_ACLK_RATIO   (C_S_AXI_ACLK_RATIO),
          .C_M_AXI_ACLK_RATIO   (C_M_AXI_ACLK_RATIO),
          .C_AXI_IS_ACLK_ASYNC   (C_AXI_IS_ACLK_ASYNC),
          .C_PACKING_LEVEL             ( C_PACKING_LEVEL         ),
          .C_SYNCHRONIZER_STAGE (C_SYNCHRONIZER_STAGE)
        )
        axi_upsizer_inst
        (
          .s_axi_aresetn              ( s_axi_aresetn        ) ,
          .s_axi_aclk                 ( s_axi_aclk          ) ,
          .s_axi_awid                 ( s_axi_awid    ) ,
          .s_axi_awaddr               ( s_axi_awaddr  ) ,
          .s_axi_awlen                ( s_axi_awlen_i   ) ,
          .s_axi_awsize               ( s_axi_awsize  ) ,
          .s_axi_awburst              ( s_axi_awburst ) ,
          .s_axi_awlock               ( s_axi_awlock_i  ) ,
          .s_axi_awcache              ( s_axi_awcache ) ,
          .s_axi_awprot               ( s_axi_awprot  ) ,
          .s_axi_awregion             ( s_axi_awregion_i) ,
          .s_axi_awqos                ( s_axi_awqos   ) ,
          .s_axi_awvalid              ( s_axi_awvalid ) ,
          .s_axi_awready              ( s_axi_awready ) ,
          .s_axi_wdata                ( s_axi_wdata   ) ,
          .s_axi_wstrb                ( s_axi_wstrb   ) ,
          .s_axi_wlast                ( s_axi_wlast   ) ,
          .s_axi_wvalid               ( s_axi_wvalid  ) ,
          .s_axi_wready               ( s_axi_wready  ) ,
          .s_axi_bid                  ( s_axi_bid     ) ,
          .s_axi_bresp                ( s_axi_bresp   ) ,
          .s_axi_bvalid               ( s_axi_bvalid  ) ,
          .s_axi_bready               ( s_axi_bready  ) ,
          .s_axi_arid                 ( s_axi_arid    ) ,
          .s_axi_araddr               ( s_axi_araddr  ) ,
          .s_axi_arlen                ( s_axi_arlen_i   ) ,
          .s_axi_arsize               ( s_axi_arsize  ) ,
          .s_axi_arburst              ( s_axi_arburst ) ,
          .s_axi_arlock               ( s_axi_arlock_i  ) ,
          .s_axi_arcache              ( s_axi_arcache ) ,
          .s_axi_arprot               ( s_axi_arprot  ) ,
          .s_axi_arregion             ( s_axi_arregion_i) ,
          .s_axi_arqos                ( s_axi_arqos   ) ,
          .s_axi_arvalid              ( s_axi_arvalid ) ,
          .s_axi_arready              ( s_axi_arready ) ,
          .s_axi_rid                  ( s_axi_rid     ) ,
          .s_axi_rdata                ( s_axi_rdata   ) ,
          .s_axi_rresp                ( s_axi_rresp   ) ,
          .s_axi_rlast                ( s_axi_rlast   ) ,
          .s_axi_rvalid               ( s_axi_rvalid  ) ,
          .s_axi_rready               ( s_axi_rready  ) ,
          .m_axi_aresetn              ( m_axi_aresetn        ) ,
          .m_axi_aclk                 ( m_axi_aclk          ) ,
          .m_axi_awaddr               ( m_axi_awaddr  ) ,
          .m_axi_awlen                ( m_axi_awlen_i   ) ,
          .m_axi_awsize               ( m_axi_awsize  ) ,
          .m_axi_awburst              ( m_axi_awburst ) ,
          .m_axi_awlock               ( m_axi_awlock_i  ) ,
          .m_axi_awcache              ( m_axi_awcache ) ,
          .m_axi_awprot               ( m_axi_awprot  ) ,
          .m_axi_awregion             ( m_axi_awregion_i) ,
          .m_axi_awqos                ( m_axi_awqos   ) ,
          .m_axi_awvalid              ( m_axi_awvalid ) ,
          .m_axi_awready              ( m_axi_awready ) ,
          .m_axi_wdata                ( m_axi_wdata   ) ,
          .m_axi_wstrb                ( m_axi_wstrb   ) ,
          .m_axi_wlast                ( m_axi_wlast   ) ,
          .m_axi_wvalid               ( m_axi_wvalid  ) ,
          .m_axi_wready               ( m_axi_wready  ) ,
          .m_axi_bresp                ( m_axi_bresp   ) ,
          .m_axi_bvalid               ( m_axi_bvalid  ) ,
          .m_axi_bready               ( m_axi_bready  ) ,
          .m_axi_araddr               ( m_axi_araddr  ) ,
          .m_axi_arlen                ( m_axi_arlen_i   ) ,
          .m_axi_arsize               ( m_axi_arsize  ) ,
          .m_axi_arburst              ( m_axi_arburst ) ,
          .m_axi_arlock               ( m_axi_arlock_i  ) ,
          .m_axi_arcache              ( m_axi_arcache ) ,
          .m_axi_arprot               ( m_axi_arprot  ) ,
          .m_axi_arregion             ( m_axi_arregion_i) ,
          .m_axi_arqos                ( m_axi_arqos   ) ,
          .m_axi_arvalid              ( m_axi_arvalid ) ,
          .m_axi_arready              ( m_axi_arready ) ,
          .m_axi_rdata                ( m_axi_rdata   ) ,
          .m_axi_rresp                ( m_axi_rresp   ) ,
          .m_axi_rlast                ( m_axi_rlast   ) ,
          .m_axi_rvalid               ( m_axi_rvalid  ) ,
          .m_axi_rready               ( m_axi_rready  )
        );
      end
    end
  endgenerate
      
endmodule

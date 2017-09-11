//-----------------------------------------------------------------------------
//-- (c) Copyright 2010 Xilinx, Inc. All rights reserved.
//--
//-- This file contains confidential and proprietary information
//-- of Xilinx, Inc. and is protected under U.S. and
//-- international copyright and other intellectual property
//-- laws.
//--
//-- DISCLAIMER
//-- This disclaimer is not a license and does not grant any
//-- rights to the materials distributed herewith. Except as
//-- otherwise provided in a valid license issued to you by
//-- Xilinx, and to the maximum extent permitted by applicable
//-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
//-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
//-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
//-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
//-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
//-- (2) Xilinx shall not be liable (whether in contract or tort,
//-- including negligence, or under any other theory of
//-- liability) for any loss or damage of any kind or nature
//-- related to, arising under or in connection with these
//-- materials, including for any direct, or any indirect,
//-- special, incidental, or consequential loss or damage
//-- (including loss of data, profits, goodwill, or any type of
//-- loss or damage suffered as a result of any action brought
//-- by a third party) even if such damage or loss was
//-- reasonably foreseeable or Xilinx had been advised of the
//-- possibility of the same.
//--
//-- CRITICAL APPLICATIONS
//-- Xilinx products are not designed or intended to be fail-
//-- safe, or for use in any application requiring fail-safe
//-- performance, such as life-support or safety devices or
//-- systems, Class III medical devices, nuclear facilities,
//-- applications related to the deployment of airbags, or any
//-- other applications that could lead to death, personal
//-- injury, or severe property or environmental damage
//-- (individually and collectively, "Critical
//-- Applications"). Customer assumes the sole risk and
//-- liability of any use of Xilinx products in Critical
//-- Applications, subject only to applicable laws and
//-- regulations governing limitations on product liability.
//--
//-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
//-- PART OF THIS FILE AT ALL TIMES.
//-----------------------------------------------------------------------------
//
// Description: Up-Sizer
// Up-Sizer for generic SI- and MI-side data widths. This module instantiates
// Address, Write Data and Read Data Up-Sizer modules, each one taking care
// of the channel specific tasks.
// The Address Up-Sizer can handle both AR and AW channels.
//
// Verilog-standard:  Verilog 2001
//--------------------------------------------------------------------------
//
// Structure:
//   axi_upsizer
//     a_upsizer
//       fifo
//         fifo_gen
//           fifo_coregen
//     w_upsizer
//     r_upsizer
//
//--------------------------------------------------------------------------
`timescale 1ps/1ps
`default_nettype none

(* DowngradeIPIdentifiedWarnings="yes" *) 
module axi_dwidth_converter_v2_1_axi_upsizer #
  (
   parameter         C_FAMILY                         = "virtex7", 
                       // FPGA Family. Current version: virtex6 or spartan6.
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
   parameter integer C_S_AXI_DATA_WIDTH               = 32,
                       // Width of s_axi_wdata and s_axi_rdata.
                       // Range: 32, 64, 128, 256, 512, 1024.
   parameter integer C_M_AXI_DATA_WIDTH               = 64,
                       // Width of m_axi_wdata and m_axi_rdata. 
                       // Assume always >= than C_S_AXI_DATA_WIDTH.
                       // Range: 32, 64, 128, 256, 512, 1024.
   parameter integer C_AXI_SUPPORTS_WRITE             = 1,
   parameter integer C_AXI_SUPPORTS_READ              = 1,
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   parameter integer C_FIFO_MODE                        = 0,
   parameter integer C_FIFO_MODE                        = 1,
                       // 0=None, 1=Packet_FIFO, 2=Clock_conversion_Packet_FIFO, 3=Simple_FIFO (FUTURE), 4=Clock_conversion_Simple_FIFO (FUTURE)
   parameter integer C_S_AXI_ACLK_RATIO = 1,     // Clock frequency ratio of SI w.r.t. MI.
                                                 // Range = [1..16].
   parameter integer C_M_AXI_ACLK_RATIO = 2,     // Clock frequency ratio of MI w.r.t. SI.
                                                 // Range = [2..16] if C_S_AXI_ACLK_RATIO = 1; else must be 1.
   parameter integer C_AXI_IS_ACLK_ASYNC = 0,    // Indicates whether S and M clocks are asynchronous.
                                                 // FUTURE FEATURE
                                                 // Range = [0, 1].
   parameter integer C_PACKING_LEVEL                    = 1,
                       // 0 = Never pack (expander only); packing logic is omitted.
                       // 1 = Pack only when CACHE[1] (Modifiable) is high.
                       // 2 = Always pack, regardless of sub-size transaction or Modifiable bit.
                       //     (Required when used as helper-core by mem-con. Same size AXI interfaces
                       //      should only be used when always packing)
   parameter integer C_SYNCHRONIZER_STAGE = 3
   )
  (

   // Slave Interface
   input  wire                                  s_axi_aresetn,
   input  wire                                  s_axi_aclk,
   
   // Slave Interface Write Address Ports
   input  wire [C_S_AXI_ID_WIDTH-1:0]             s_axi_awid,
   input  wire [C_AXI_ADDR_WIDTH-1:0]           s_axi_awaddr,
   input  wire [8-1:0]                          s_axi_awlen,
   input  wire [3-1:0]                          s_axi_awsize,
   input  wire [2-1:0]                          s_axi_awburst,
   input  wire [2-1:0]                          s_axi_awlock,
   input  wire [4-1:0]                          s_axi_awcache,
   input  wire [3-1:0]                          s_axi_awprot,
   input  wire [4-1:0]                          s_axi_awregion,
   input  wire [4-1:0]                          s_axi_awqos,
   input  wire                                  s_axi_awvalid,
   output wire                                  s_axi_awready,
   // Slave Interface Write Data Ports
   input  wire [C_S_AXI_DATA_WIDTH-1:0]         s_axi_wdata,
   input  wire [C_S_AXI_DATA_WIDTH/8-1:0]       s_axi_wstrb,
   input  wire                                  s_axi_wlast,
   input  wire                                  s_axi_wvalid,
   output wire                                  s_axi_wready,
   // Slave Interface Write Response Ports
   output wire [C_S_AXI_ID_WIDTH-1:0]             s_axi_bid,
   output wire [2-1:0]                          s_axi_bresp,
   output wire                                  s_axi_bvalid,
   input  wire                                  s_axi_bready,
   // Slave Interface Read Address Ports
   input  wire [C_S_AXI_ID_WIDTH-1:0]             s_axi_arid,
   input  wire [C_AXI_ADDR_WIDTH-1:0]           s_axi_araddr,
   input  wire [8-1:0]                          s_axi_arlen,
   input  wire [3-1:0]                          s_axi_arsize,
   input  wire [2-1:0]                          s_axi_arburst,
   input  wire [2-1:0]                          s_axi_arlock,
   input  wire [4-1:0]                          s_axi_arcache,
   input  wire [3-1:0]                          s_axi_arprot,
   input  wire [4-1:0]                          s_axi_arregion,
   input  wire [4-1:0]                          s_axi_arqos,
   input  wire                                  s_axi_arvalid,
   output wire                                  s_axi_arready,
   // Slave Interface Read Data Ports
   output wire [C_S_AXI_ID_WIDTH-1:0]             s_axi_rid,
   output wire [C_S_AXI_DATA_WIDTH-1:0]         s_axi_rdata,
   output wire [2-1:0]                          s_axi_rresp,
   output wire                                  s_axi_rlast,
   output wire                                  s_axi_rvalid,
   input  wire                                  s_axi_rready,

   // Master Interface
   input  wire                                  m_axi_aresetn,
   input  wire                                  m_axi_aclk,
   
   // Master Interface Write Address Port
   output wire [C_AXI_ADDR_WIDTH-1:0]          m_axi_awaddr,
   output wire [8-1:0]                         m_axi_awlen,
   output wire [3-1:0]                         m_axi_awsize,
   output wire [2-1:0]                         m_axi_awburst,
   output wire [2-1:0]                         m_axi_awlock,
   output wire [4-1:0]                         m_axi_awcache,
   output wire [3-1:0]                         m_axi_awprot,
   output wire [4-1:0]                         m_axi_awregion,
   output wire [4-1:0]                         m_axi_awqos,
   output wire                                 m_axi_awvalid,
   input  wire                                 m_axi_awready,
   // Master Interface Write Data Ports
   output wire [C_M_AXI_DATA_WIDTH-1:0]    m_axi_wdata,
   output wire [C_M_AXI_DATA_WIDTH/8-1:0]  m_axi_wstrb,
   output wire                                                   m_axi_wlast,
   output wire                                                   m_axi_wvalid,
   input  wire                                                   m_axi_wready,
   // Master Interface Write Response Ports
   input  wire [2-1:0]                         m_axi_bresp,
   input  wire                                                   m_axi_bvalid,
   output wire                                                   m_axi_bready,
   // Master Interface Read Address Port
   output wire [C_AXI_ADDR_WIDTH-1:0]          m_axi_araddr,
   output wire [8-1:0]                         m_axi_arlen,
   output wire [3-1:0]                         m_axi_arsize,
   output wire [2-1:0]                         m_axi_arburst,
   output wire [2-1:0]                         m_axi_arlock,
   output wire [4-1:0]                         m_axi_arcache,
   output wire [3-1:0]                         m_axi_arprot,
   output wire [4-1:0]                         m_axi_arregion,
   output wire [4-1:0]                         m_axi_arqos,
   output wire                                                   m_axi_arvalid,
   input  wire                                                   m_axi_arready,
   // Master Interface Read Data Ports
   input  wire [C_M_AXI_DATA_WIDTH-1:0]      m_axi_rdata,
   input  wire [2-1:0]                       m_axi_rresp,
   input  wire                               m_axi_rlast,
   input  wire                               m_axi_rvalid,
   output wire                               m_axi_rready
   );

  // Log2 of number of 32bit word on SI-side.
  localparam integer C_S_AXI_BYTES_LOG                = log2(C_S_AXI_DATA_WIDTH/8);
  
  // Log2 of number of 32bit word on MI-side.
  localparam integer C_M_AXI_BYTES_LOG                = log2(C_M_AXI_DATA_WIDTH/8);
  
  // Log2 of Up-Sizing ratio for data.
  localparam integer C_RATIO                          = C_M_AXI_DATA_WIDTH / C_S_AXI_DATA_WIDTH;
  localparam integer C_RATIO_LOG                      = log2(C_RATIO);
  localparam P_BYPASS = 32'h0;
  localparam P_LIGHTWT = 32'h7;
  localparam P_FWD_REV = 32'h1;
  localparam integer P_CONV_LIGHT_WT = 0;
  localparam integer P_AXI4 = 0;
  localparam integer C_FIFO_DEPTH_LOG    = 5;
  localparam  P_SI_LT_MI = (C_S_AXI_ACLK_RATIO < C_M_AXI_ACLK_RATIO);
  localparam integer P_ACLK_RATIO = P_SI_LT_MI ? (C_M_AXI_ACLK_RATIO / C_S_AXI_ACLK_RATIO) : (C_S_AXI_ACLK_RATIO / C_M_AXI_ACLK_RATIO);
   localparam integer P_NO_FIFO = 0;
   localparam integer P_PKTFIFO = 1;
   localparam integer P_PKTFIFO_CLK = 2;
   localparam integer P_DATAFIFO = 3;
   localparam integer P_DATAFIFO_CLK = 4;
   localparam         P_CLK_CONV = ((C_FIFO_MODE == P_PKTFIFO_CLK) || (C_FIFO_MODE == P_DATAFIFO_CLK));
   localparam integer C_M_AXI_AW_REGISTER              = 0;
                       // Simple register AW output.
                       // Range: 0, 1
   localparam integer C_M_AXI_W_REGISTER               = 1;  // Parameter not used; W reg always implemented.
   localparam integer C_M_AXI_AR_REGISTER              = 0;
                       // Simple register AR output.
                       // Range: 0, 1
   localparam integer C_S_AXI_R_REGISTER               = 0;
                       // Simple register R output (SI).
                       // Range: 0, 1
   localparam integer C_M_AXI_R_REGISTER               = 1;
                       // Register slice on R input (MI) side.
                       // 0 = Bypass (not recommended due to combinatorial M_RVALID -> M_RREADY path)
                       // 1 = Fully-registered (needed only when upsizer propagates bursts at 1:1 width ratio)
                       // 7 = Light-weight (safe when upsizer always packs at 1:n width ratio, as in interconnect)
   localparam integer P_RID_QUEUE = ((C_SUPPORTS_ID != 0) && !((C_FIFO_MODE == P_PKTFIFO) || (C_FIFO_MODE == P_PKTFIFO_CLK))) ? 1 : 0;
   
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
  // Internal signals
  /////////////////////////////////////////////////////////////////////////////
  
  wire aclk;
  wire m_aclk;
  wire sample_cycle;
  wire sample_cycle_early;
  wire sm_aresetn;
  wire s_aresetn_i;
  
  wire [C_S_AXI_ID_WIDTH-1:0]        sr_awid      ;   
  wire [C_AXI_ADDR_WIDTH-1:0]        sr_awaddr    ;   
  wire [8-1:0]                       sr_awlen     ;   
  wire [3-1:0]                       sr_awsize    ;   
  wire [2-1:0]                       sr_awburst   ;   
  wire [2-1:0]                       sr_awlock    ;   
  wire [4-1:0]                       sr_awcache   ;   
  wire [3-1:0]                       sr_awprot    ;   
  wire [4-1:0]                       sr_awregion  ;   
  wire [4-1:0]                       sr_awqos     ;   
  wire                               sr_awvalid   ;   
  wire                               sr_awready   ;   
  wire [C_S_AXI_ID_WIDTH-1:0]        sr_arid      ;    
  wire [C_AXI_ADDR_WIDTH-1:0]        sr_araddr    ;    
  wire [8-1:0]                       sr_arlen     ;    
  wire [3-1:0]                       sr_arsize    ;    
  wire [2-1:0]                       sr_arburst   ;    
  wire [2-1:0]                       sr_arlock    ;    
  wire [4-1:0]                       sr_arcache   ;    
  wire [3-1:0]                       sr_arprot    ;    
  wire [4-1:0]                       sr_arregion  ;    
  wire [4-1:0]                       sr_arqos     ;    
  wire                               sr_arvalid   ;    
  wire                               sr_arready   ;    
  
  wire [C_S_AXI_DATA_WIDTH-1:0]      sr_wdata     ;
  wire [(C_S_AXI_DATA_WIDTH/8)-1:0]  sr_wstrb     ;
  wire                               sr_wlast     ;
  wire                               sr_wvalid    ;
  wire                               sr_wready    ;
  
  wire [C_M_AXI_DATA_WIDTH-1:0]      mr_rdata     ;  
  wire [2-1:0]                       mr_rresp     ;  
  wire                               mr_rlast     ;  
  wire                               mr_rvalid    ;  
  wire                               mr_rready    ;   
  wire                               m_axi_rready_i;
  
  wire [((C_AXI_PROTOCOL==P_AXI4)?8:4)-1:0] s_axi_awlen_i  ;
  wire [((C_AXI_PROTOCOL==P_AXI4)?8:4)-1:0] s_axi_arlen_i  ;
  wire [((C_AXI_PROTOCOL==P_AXI4)?1:2)-1:0] s_axi_awlock_i ;
  wire [((C_AXI_PROTOCOL==P_AXI4)?1:2)-1:0] s_axi_arlock_i ;
  wire [((C_AXI_PROTOCOL==P_AXI4)?8:4)-1:0] s_axi_awlen_ii  ;
  wire [((C_AXI_PROTOCOL==P_AXI4)?8:4)-1:0] s_axi_arlen_ii  ;
  wire [((C_AXI_PROTOCOL==P_AXI4)?1:2)-1:0] s_axi_awlock_ii ;
  wire [((C_AXI_PROTOCOL==P_AXI4)?1:2)-1:0] s_axi_arlock_ii ;
  wire [3:0] s_axi_awregion_ii;
  wire [3:0] s_axi_arregion_ii;
  assign s_axi_awlen_i = (C_AXI_PROTOCOL == P_AXI4) ? s_axi_awlen : s_axi_awlen[3:0];
  assign s_axi_awlock_i = (C_AXI_PROTOCOL == P_AXI4) ? s_axi_awlock[0] : s_axi_awlock;
  assign s_axi_arlen_i = (C_AXI_PROTOCOL == P_AXI4) ? s_axi_arlen : s_axi_arlen[3:0];
  assign s_axi_arlock_i = (C_AXI_PROTOCOL == P_AXI4) ? s_axi_arlock[0] : s_axi_arlock;
  assign sr_awlen = (C_AXI_PROTOCOL == P_AXI4) ? s_axi_awlen_ii: {4'b0, s_axi_awlen_ii};
  assign sr_awlock = (C_AXI_PROTOCOL == P_AXI4) ? {1'b0, s_axi_awlock_ii} : s_axi_awlock_ii;
  assign sr_arlen = (C_AXI_PROTOCOL == P_AXI4) ? s_axi_arlen_ii: {4'b0, s_axi_arlen_ii};
  assign sr_arlock = (C_AXI_PROTOCOL == P_AXI4) ? {1'b0, s_axi_arlock_ii} : s_axi_arlock_ii;
  assign sr_awregion = (C_AXI_PROTOCOL == P_AXI4) ? s_axi_awregion_ii : 4'b0;
  assign sr_arregion = (C_AXI_PROTOCOL == P_AXI4) ? s_axi_arregion_ii : 4'b0;
  
  assign aclk = s_axi_aclk;
  assign sm_aresetn = s_axi_aresetn & m_axi_aresetn;
  
  generate

    if (P_CLK_CONV) begin : gen_clock_conv
      if (C_AXI_IS_ACLK_ASYNC) begin : gen_async_conv
        
        assign m_aclk = m_axi_aclk;
        assign s_aresetn_i = s_axi_aresetn;
        assign sample_cycle_early = 1'b1;
        assign sample_cycle = 1'b1;
        
      end else begin : gen_sync_conv

        wire fast_aclk;
        wire slow_aclk;
        reg s_aresetn_r;
        
        if (P_SI_LT_MI) begin : gen_fastclk_mi
          assign fast_aclk = m_axi_aclk;
          assign slow_aclk = s_axi_aclk;
        end else begin : gen_fastclk_si
          assign fast_aclk = s_axi_aclk;
          assign slow_aclk = m_axi_aclk;
        end
        
        assign m_aclk = m_axi_aclk;
        assign s_aresetn_i = s_aresetn_r;
    
        always @(negedge sm_aresetn, posedge fast_aclk) begin
          if (~sm_aresetn) begin
            s_aresetn_r <= 1'b0;
          end else if (s_axi_aresetn & m_axi_aresetn & sample_cycle_early) begin
            s_aresetn_r <= 1'b1;
          end
        end
        
        // Sample cycle used to determine when to assert a signal on a fast clock
        // to be flopped onto a slow clock.
        axi_clock_converter_v2_1_axic_sample_cycle_ratio #(
          .C_RATIO ( P_ACLK_RATIO )
        )
        axic_sample_cycle_inst (
          .SLOW_ACLK          ( slow_aclk               ) ,
          .FAST_ACLK          ( fast_aclk               ) ,
          .SAMPLE_CYCLE_EARLY ( sample_cycle_early ) ,
          .SAMPLE_CYCLE       ( sample_cycle       )
        );
        
      end
        
    end else begin : gen_no_clk_conv
      
      assign m_aclk = s_axi_aclk;
      assign s_aresetn_i = s_axi_aresetn;
      assign sample_cycle_early = 1'b1;
      assign sample_cycle = 1'b1;
      
    end  // gen_clock_conv

    axi_register_slice_v2_1_axi_register_slice #
      (
        .C_FAMILY                         (C_FAMILY),
        .C_AXI_PROTOCOL                   (C_AXI_PROTOCOL),
        .C_AXI_ID_WIDTH                   (C_S_AXI_ID_WIDTH),
        .C_AXI_ADDR_WIDTH                 (C_AXI_ADDR_WIDTH),
        .C_AXI_DATA_WIDTH                 (C_S_AXI_DATA_WIDTH),
        .C_AXI_SUPPORTS_USER_SIGNALS      (0),
        .C_REG_CONFIG_AW                  (C_AXI_SUPPORTS_WRITE ? P_LIGHTWT : P_BYPASS),
        .C_REG_CONFIG_AR                  (C_AXI_SUPPORTS_READ ? P_LIGHTWT : P_BYPASS)
      )
      si_register_slice_inst 
      (
        .aresetn                          (s_aresetn_i),
        .aclk                             (aclk),
        .s_axi_awid                       (s_axi_awid     ),
        .s_axi_awaddr                     (s_axi_awaddr   ),
        .s_axi_awlen                      (s_axi_awlen_i    ),
        .s_axi_awsize                     (s_axi_awsize   ),
        .s_axi_awburst                    (s_axi_awburst  ),
        .s_axi_awlock                     (s_axi_awlock_i   ),
        .s_axi_awcache                    (s_axi_awcache  ),
        .s_axi_awprot                     (s_axi_awprot   ),
        .s_axi_awregion                   (s_axi_awregion ),
        .s_axi_awqos                      (s_axi_awqos    ),
        .s_axi_awuser                     (1'b0   ),
        .s_axi_awvalid                    (s_axi_awvalid  ),
        .s_axi_awready                    (s_axi_awready  ),
        .s_axi_wid                        ( {C_S_AXI_ID_WIDTH{1'b0}}),
        .s_axi_wdata                      ( {C_S_AXI_DATA_WIDTH{1'b0}}    ),
        .s_axi_wstrb                      ( {C_S_AXI_DATA_WIDTH/8{1'b0}}  ),
        .s_axi_wlast                      ( 1'b0 ),
        .s_axi_wuser                      ( 1'b0  ),
        .s_axi_wvalid                     ( 1'b0 ),
        .s_axi_wready                     ( ),
        .s_axi_bid                        ( ),
        .s_axi_bresp                      ( ),
        .s_axi_buser                      ( ),
        .s_axi_bvalid                     ( ),
        .s_axi_bready                     ( 1'b0 ),
        .s_axi_arid                       (s_axi_arid     ),
        .s_axi_araddr                     (s_axi_araddr   ),
        .s_axi_arlen                      (s_axi_arlen_i    ),
        .s_axi_arsize                     (s_axi_arsize   ),
        .s_axi_arburst                    (s_axi_arburst  ),
        .s_axi_arlock                     (s_axi_arlock_i   ),
        .s_axi_arcache                    (s_axi_arcache  ),
        .s_axi_arprot                     (s_axi_arprot   ),
        .s_axi_arregion                   (s_axi_arregion ),
        .s_axi_arqos                      (s_axi_arqos    ),
        .s_axi_aruser                     (1'b0   ),
        .s_axi_arvalid                    (s_axi_arvalid  ),
        .s_axi_arready                    (s_axi_arready  ),
        .s_axi_rid                        ( ) ,
        .s_axi_rdata                      ( ) ,
        .s_axi_rresp                      ( ) ,
        .s_axi_rlast                      ( ) ,
        .s_axi_ruser                      ( ) ,
        .s_axi_rvalid                     ( ) ,
        .s_axi_rready                     ( 1'b0 ) ,
        .m_axi_awid                       (sr_awid     ),
        .m_axi_awaddr                     (sr_awaddr   ),
        .m_axi_awlen                      (s_axi_awlen_ii),
        .m_axi_awsize                     (sr_awsize   ),
        .m_axi_awburst                    (sr_awburst  ),
        .m_axi_awlock                     (s_axi_awlock_ii),
        .m_axi_awcache                    (sr_awcache  ),
        .m_axi_awprot                     (sr_awprot   ),
        .m_axi_awregion                   (s_axi_awregion_ii ),
        .m_axi_awqos                      (sr_awqos    ),
        .m_axi_awuser                     (),
        .m_axi_awvalid                    (sr_awvalid  ),
        .m_axi_awready                    (sr_awready  ),
        .m_axi_wid                        () ,
        .m_axi_wdata                      (),
        .m_axi_wstrb                      (),
        .m_axi_wlast                      (),
        .m_axi_wuser                      (),
        .m_axi_wvalid                     (),
        .m_axi_wready                     (1'b0),
        .m_axi_bid                        ( {C_S_AXI_ID_WIDTH{1'b0}} ) ,
        .m_axi_bresp                      ( 2'b0 ) ,
        .m_axi_buser                      ( 1'b0 ) ,
        .m_axi_bvalid                     ( 1'b0 ) ,
        .m_axi_bready                     ( ) ,
        .m_axi_arid                       (sr_arid     ),
        .m_axi_araddr                     (sr_araddr   ),
        .m_axi_arlen                      (s_axi_arlen_ii),
        .m_axi_arsize                     (sr_arsize   ),
        .m_axi_arburst                    (sr_arburst  ),
        .m_axi_arlock                     (s_axi_arlock_ii),
        .m_axi_arcache                    (sr_arcache  ),
        .m_axi_arprot                     (sr_arprot   ),
        .m_axi_arregion                   (s_axi_arregion_ii ),
        .m_axi_arqos                      (sr_arqos    ),
        .m_axi_aruser                     (),
        .m_axi_arvalid                    (sr_arvalid  ),
        .m_axi_arready                    (sr_arready  ),
        .m_axi_rid                        ( {C_S_AXI_ID_WIDTH{1'b0}}),
        .m_axi_rdata                      ( {C_S_AXI_DATA_WIDTH{1'b0}}    ),
        .m_axi_rresp                      ( 2'b00 ),
        .m_axi_rlast                      ( 1'b0  ),
        .m_axi_ruser                      ( 1'b0  ),
        .m_axi_rvalid                     ( 1'b0  ),
        .m_axi_rready                     (  )
      );
  
  /////////////////////////////////////////////////////////////////////////////
  // Handle Write Channels (AW/W/B)
  /////////////////////////////////////////////////////////////////////////////
    if (C_AXI_SUPPORTS_WRITE == 1) begin : USE_WRITE
    
      wire [C_AXI_ADDR_WIDTH-1:0]          m_axi_awaddr_i    ;
      wire [8-1:0]                         m_axi_awlen_i     ;
      wire [3-1:0]                         m_axi_awsize_i    ;
      wire [2-1:0]                         m_axi_awburst_i   ;
      wire [2-1:0]                         m_axi_awlock_i    ;
      wire [4-1:0]                         m_axi_awcache_i   ;
      wire [3-1:0]                         m_axi_awprot_i    ;
      wire [4-1:0]                         m_axi_awregion_i  ;
      wire [4-1:0]                         m_axi_awqos_i     ;
      wire                                 m_axi_awvalid_i   ;
      wire                                 m_axi_awready_i   ;
      
      wire                                 s_axi_bvalid_i   ;
      wire [2-1:0]                         s_axi_bresp_i   ;
      
      wire [C_AXI_ADDR_WIDTH-1:0]       wr_cmd_si_addr;
      wire [8-1:0]                      wr_cmd_si_len;
      wire [3-1:0]                      wr_cmd_si_size;
      wire [2-1:0]                      wr_cmd_si_burst;
  
      // Write Channel Signals for Commands Queue Interface.
      wire                              wr_cmd_valid;
      wire                              wr_cmd_fix;
      wire                              wr_cmd_modified;
      wire                              wr_cmd_complete_wrap;
      wire                              wr_cmd_packed_wrap;
      wire [C_M_AXI_BYTES_LOG-1:0]      wr_cmd_first_word;
      wire [C_M_AXI_BYTES_LOG-1:0]      wr_cmd_next_word;
      wire [C_M_AXI_BYTES_LOG-1:0]      wr_cmd_last_word;
      wire [C_M_AXI_BYTES_LOG-1:0]      wr_cmd_offset;
      wire [C_M_AXI_BYTES_LOG-1:0]      wr_cmd_mask;
      wire [C_S_AXI_BYTES_LOG:0]        wr_cmd_step;
      wire [8-1:0]                      wr_cmd_length;
      wire                              wr_cmd_ready;
      wire                              wr_cmd_id_ready;
      wire [C_S_AXI_ID_WIDTH-1:0]       wr_cmd_id;
      wire                              wpush;
      wire                              wpop;
      reg  [C_FIFO_DEPTH_LOG-1:0]       wcnt;                              
      
      // Write Address Channel.
      axi_dwidth_converter_v2_1_a_upsizer #
      (
       .C_FAMILY                    ("rtl"),
       .C_AXI_PROTOCOL              (C_AXI_PROTOCOL),
       .C_AXI_ID_WIDTH              (C_S_AXI_ID_WIDTH),
       .C_SUPPORTS_ID               (C_SUPPORTS_ID),
       .C_AXI_ADDR_WIDTH            (C_AXI_ADDR_WIDTH),
       .C_S_AXI_DATA_WIDTH          (C_S_AXI_DATA_WIDTH),
       .C_M_AXI_DATA_WIDTH          (C_M_AXI_DATA_WIDTH),
       .C_M_AXI_REGISTER            (C_M_AXI_AW_REGISTER),
       .C_AXI_CHANNEL               (0),
       .C_PACKING_LEVEL             (C_PACKING_LEVEL),
       .C_FIFO_MODE                 (C_FIFO_MODE),
       .C_ID_QUEUE                  (C_SUPPORTS_ID),
       .C_S_AXI_BYTES_LOG           (C_S_AXI_BYTES_LOG),
       .C_M_AXI_BYTES_LOG           (C_M_AXI_BYTES_LOG)
        ) write_addr_inst
       (
        // Global Signals
        .ARESET                     (~s_aresetn_i),
        .ACLK                       (aclk),
    
        // Command Interface
        .cmd_valid                  (wr_cmd_valid),
        .cmd_fix                    (wr_cmd_fix),
        .cmd_modified               (wr_cmd_modified),
        .cmd_complete_wrap          (wr_cmd_complete_wrap),
        .cmd_packed_wrap            (wr_cmd_packed_wrap),
        .cmd_first_word             (wr_cmd_first_word),
        .cmd_next_word              (wr_cmd_next_word),
        .cmd_last_word              (wr_cmd_last_word),
        .cmd_offset                 (wr_cmd_offset),
        .cmd_mask                   (wr_cmd_mask),
        .cmd_step                   (wr_cmd_step),
        .cmd_length                 (wr_cmd_length),
        .cmd_ready                  (wr_cmd_ready),
        .cmd_id                     (wr_cmd_id),
        .cmd_id_ready               (wr_cmd_id_ready),
        .cmd_si_addr                (wr_cmd_si_addr ),
        .cmd_si_id                  (),
        .cmd_si_len                 (wr_cmd_si_len  ),
        .cmd_si_size                (wr_cmd_si_size ),
        .cmd_si_burst               (wr_cmd_si_burst),
       
        // Slave Interface Write Address Ports
        .S_AXI_AID                  (sr_awid),
        .S_AXI_AADDR                (sr_awaddr),
        .S_AXI_ALEN                 (sr_awlen),
        .S_AXI_ASIZE                (sr_awsize),
        .S_AXI_ABURST               (sr_awburst),
        .S_AXI_ALOCK                (sr_awlock),
        .S_AXI_ACACHE               (sr_awcache),
        .S_AXI_APROT                (sr_awprot),
        .S_AXI_AREGION              (sr_awregion),
        .S_AXI_AQOS                 (sr_awqos),
        .S_AXI_AVALID               (sr_awvalid),
        .S_AXI_AREADY               (sr_awready),
        
        // Master Interface Write Address Port
        .M_AXI_AADDR                (m_axi_awaddr_i    ),
        .M_AXI_ALEN                 (m_axi_awlen_i     ),
        .M_AXI_ASIZE                (m_axi_awsize_i    ),
        .M_AXI_ABURST               (m_axi_awburst_i   ),
        .M_AXI_ALOCK                (m_axi_awlock_i    ),
        .M_AXI_ACACHE               (m_axi_awcache_i   ),
        .M_AXI_APROT                (m_axi_awprot_i    ),
        .M_AXI_AREGION              (m_axi_awregion_i  ),
        .M_AXI_AQOS                 (m_axi_awqos_i     ),
        .M_AXI_AVALID               (m_axi_awvalid_i   ),
        .M_AXI_AREADY               (m_axi_awready_i   )
       );
       
      if ((C_FIFO_MODE == P_PKTFIFO) || (C_FIFO_MODE == P_PKTFIFO_CLK)) begin : gen_pktfifo_w_upsizer
        // Packet FIFO Write Data channel.
        axi_dwidth_converter_v2_1_w_upsizer_pktfifo #
        (
         .C_FAMILY                    (C_FAMILY),
         .C_S_AXI_DATA_WIDTH          (C_S_AXI_DATA_WIDTH),
         .C_M_AXI_DATA_WIDTH          (C_M_AXI_DATA_WIDTH),
         .C_AXI_ADDR_WIDTH            (C_AXI_ADDR_WIDTH),
         .C_S_AXI_BYTES_LOG           (C_S_AXI_BYTES_LOG),
         .C_M_AXI_BYTES_LOG           (C_M_AXI_BYTES_LOG),
         .C_RATIO                     (C_RATIO),
         .C_RATIO_LOG                 (C_RATIO_LOG),
         .C_CLK_CONV                  (P_CLK_CONV),
         .C_S_AXI_ACLK_RATIO   (C_S_AXI_ACLK_RATIO),
         .C_M_AXI_ACLK_RATIO   (C_M_AXI_ACLK_RATIO),
         .C_AXI_IS_ACLK_ASYNC   (C_AXI_IS_ACLK_ASYNC),
         .C_SYNCHRONIZER_STAGE (C_SYNCHRONIZER_STAGE)
          ) pktfifo_write_data_inst
         (
          .S_AXI_ARESETN              ( s_axi_aresetn        ) ,
          .S_AXI_ACLK                 ( s_axi_aclk          ) ,
          .M_AXI_ARESETN              ( m_axi_aresetn        ) ,
          .M_AXI_ACLK                 ( m_axi_aclk          ) ,

          // Command Interface
          .cmd_si_addr                 (wr_cmd_si_addr ),
          .cmd_si_len                  (wr_cmd_si_len  ),
          .cmd_si_size                 (wr_cmd_si_size ),
          .cmd_si_burst                (wr_cmd_si_burst),
          .cmd_ready                   (wr_cmd_ready),

          // Slave Interface Write Address Ports
          .S_AXI_AWADDR                (m_axi_awaddr_i    ),  
          .S_AXI_AWLEN                 (m_axi_awlen_i     ),  
          .S_AXI_AWSIZE                (m_axi_awsize_i    ),  
          .S_AXI_AWBURST               (m_axi_awburst_i   ),  
          .S_AXI_AWLOCK                (m_axi_awlock_i    ),  
          .S_AXI_AWCACHE               (m_axi_awcache_i   ),  
          .S_AXI_AWPROT                (m_axi_awprot_i    ),  
          .S_AXI_AWREGION              (m_axi_awregion_i  ),  
          .S_AXI_AWQOS                 (m_axi_awqos_i     ),  
          .S_AXI_AWVALID               (m_axi_awvalid_i   ),  
          .S_AXI_AWREADY               (m_axi_awready_i   ),   
          
          // Master Interface Write Address Port
          .M_AXI_AWADDR                (m_axi_awaddr),
          .M_AXI_AWLEN                 (m_axi_awlen),
          .M_AXI_AWSIZE                (m_axi_awsize),
          .M_AXI_AWBURST               (m_axi_awburst),
          .M_AXI_AWLOCK                (m_axi_awlock),
          .M_AXI_AWCACHE               (m_axi_awcache),
          .M_AXI_AWPROT                (m_axi_awprot),
          .M_AXI_AWREGION              (m_axi_awregion),
          .M_AXI_AWQOS                 (m_axi_awqos),
          .M_AXI_AWVALID               (m_axi_awvalid),
          .M_AXI_AWREADY               (m_axi_awready),
         
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
          .M_AXI_WREADY               (m_axi_wready),
          
          .SAMPLE_CYCLE               (sample_cycle),
          .SAMPLE_CYCLE_EARLY         (sample_cycle_early)
         );
        
      end else begin : gen_non_fifo_w_upsizer
        // Write Data channel.
        axi_dwidth_converter_v2_1_w_upsizer #
        (
         .C_FAMILY                    ("rtl"),
         .C_S_AXI_DATA_WIDTH          (C_S_AXI_DATA_WIDTH),
         .C_M_AXI_DATA_WIDTH          (C_M_AXI_DATA_WIDTH),
         .C_M_AXI_REGISTER            (1),
         .C_PACKING_LEVEL             (C_PACKING_LEVEL),
         .C_S_AXI_BYTES_LOG           (C_S_AXI_BYTES_LOG),
         .C_M_AXI_BYTES_LOG           (C_M_AXI_BYTES_LOG),
         .C_RATIO                     (C_RATIO),
         .C_RATIO_LOG                 (C_RATIO_LOG)
          ) write_data_inst
         (
          // Global Signals
          .ARESET                     (~s_aresetn_i),
          .ACLK                       (aclk),
      
          // Command Interface
          .cmd_valid                  (wr_cmd_valid),
          .cmd_fix                    (wr_cmd_fix),
          .cmd_modified               (wr_cmd_modified),
          .cmd_complete_wrap          (wr_cmd_complete_wrap),
          .cmd_packed_wrap            (wr_cmd_packed_wrap),
          .cmd_first_word             (wr_cmd_first_word),
          .cmd_next_word              (wr_cmd_next_word),
          .cmd_last_word              (wr_cmd_last_word),
          .cmd_offset                 (wr_cmd_offset),
          .cmd_mask                   (wr_cmd_mask),
          .cmd_step                   (wr_cmd_step),
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
        
        assign m_axi_awaddr   = m_axi_awaddr_i   ;
        assign m_axi_awlen    = m_axi_awlen_i    ;
        assign m_axi_awsize   = m_axi_awsize_i   ;
        assign m_axi_awburst  = m_axi_awburst_i  ;
        assign m_axi_awlock   = m_axi_awlock_i   ;
        assign m_axi_awcache  = m_axi_awcache_i  ;
        assign m_axi_awprot   = m_axi_awprot_i   ;
        assign m_axi_awregion = m_axi_awregion_i ;
        assign m_axi_awqos    = m_axi_awqos_i    ;
        assign m_axi_awvalid  = m_axi_awvalid_i  ;
        assign m_axi_awready_i  = m_axi_awready  ;
        
      end // gen_w_upsizer
      
      // Write Response channel.
      assign wr_cmd_id_ready = s_axi_bvalid_i & s_axi_bready;
      assign s_axi_bid     = wr_cmd_id;
      assign s_axi_bresp   = s_axi_bresp_i;
      assign s_axi_bvalid  = s_axi_bvalid_i;
      
      if (P_CLK_CONV) begin : gen_b_clk_conv
        if (C_AXI_IS_ACLK_ASYNC == 0) begin : gen_b_sync_conv

          axi_clock_converter_v2_1_axic_sync_clock_converter #(
            .C_FAMILY         ( C_FAMILY ) ,
            .C_PAYLOAD_WIDTH ( 2 ) ,
            .C_M_ACLK_RATIO   ( P_SI_LT_MI ? 1 : P_ACLK_RATIO ) ,
            .C_S_ACLK_RATIO   ( P_SI_LT_MI ? P_ACLK_RATIO : 1 ) ,
            .C_MODE(P_CONV_LIGHT_WT)
          )
          b_sync_clock_converter (
            .SAMPLE_CYCLE (sample_cycle),
            .SAMPLE_CYCLE_EARLY (sample_cycle_early),
            .S_ACLK     ( m_axi_aclk     ) ,
            .S_ARESETN  ( m_axi_aresetn ) ,
            .S_PAYLOAD ( m_axi_bresp ) ,
            .S_VALID   ( m_axi_bvalid   ) ,
            .S_READY   ( m_axi_bready   ) ,
            .M_ACLK     ( s_axi_aclk     ) ,
            .M_ARESETN  ( s_axi_aresetn ) ,
            .M_PAYLOAD ( s_axi_bresp_i ) ,
            .M_VALID   ( s_axi_bvalid_i   ) ,
            .M_READY   ( s_axi_bready   )
          );
        
        end else begin : gen_b_async_conv
          
          fifo_generator_v12_0 #(
            .C_COMMON_CLOCK(0),
            .C_SYNCHRONIZER_STAGE(C_SYNCHRONIZER_STAGE),
            .C_INTERFACE_TYPE(2),
            .C_AXI_TYPE(1),
            .C_HAS_AXI_ID(1),
            .C_AXI_LEN_WIDTH(8),
            .C_AXI_LOCK_WIDTH(2),
            .C_DIN_WIDTH_WACH(63),
            .C_DIN_WIDTH_WDCH(38),
            .C_DIN_WIDTH_WRCH(3),
            .C_DIN_WIDTH_RACH(63),
            .C_DIN_WIDTH_RDCH(36),
            .C_COUNT_TYPE(0),
            .C_DATA_COUNT_WIDTH(10),
            .C_DEFAULT_VALUE("BlankString"),
            .C_DIN_WIDTH(18),
            .C_DOUT_RST_VAL("0"),
            .C_DOUT_WIDTH(18),
            .C_ENABLE_RLOCS(0),
            .C_FAMILY(C_FAMILY),
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
            .C_MEMORY_TYPE(1),
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
            .C_ERROR_INJECTION_TYPE(0),
            .C_HAS_AXI_WR_CHANNEL(1),
            .C_HAS_AXI_RD_CHANNEL(0),
            .C_HAS_SLAVE_CE(0),
            .C_HAS_MASTER_CE(0),
            .C_ADD_NGC_CONSTRAINT(0),
            .C_USE_COMMON_OVERFLOW(0),
            .C_USE_COMMON_UNDERFLOW(0),
            .C_USE_DEFAULT_SETTINGS(0),
            .C_AXI_ID_WIDTH(1),
            .C_AXI_ADDR_WIDTH(32),
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
            .C_WACH_TYPE(2),
            .C_WDCH_TYPE(2),
            .C_WRCH_TYPE(0),
            .C_RACH_TYPE(0),
            .C_RDCH_TYPE(0),
            .C_AXIS_TYPE(0),
            .C_IMPLEMENTATION_TYPE_WACH(12),
            .C_IMPLEMENTATION_TYPE_WDCH(11),
            .C_IMPLEMENTATION_TYPE_WRCH(12),
            .C_IMPLEMENTATION_TYPE_RACH(12),
            .C_IMPLEMENTATION_TYPE_RDCH(11),
            .C_IMPLEMENTATION_TYPE_AXIS(11),
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
            .C_DIN_WIDTH_AXIS(1),
            .C_WR_DEPTH_WACH(16),
            .C_WR_DEPTH_WDCH(1024),
            .C_WR_DEPTH_WRCH(32),
            .C_WR_DEPTH_RACH(16),
            .C_WR_DEPTH_RDCH(1024),
            .C_WR_DEPTH_AXIS(1024),
            .C_WR_PNTR_WIDTH_WACH(4),
            .C_WR_PNTR_WIDTH_WDCH(10),
            .C_WR_PNTR_WIDTH_WRCH(5),
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
            .C_PROG_FULL_THRESH_ASSERT_VAL_WACH(15),
            .C_PROG_FULL_THRESH_ASSERT_VAL_WDCH(1023),
            .C_PROG_FULL_THRESH_ASSERT_VAL_WRCH(31),
            .C_PROG_FULL_THRESH_ASSERT_VAL_RACH(15),
            .C_PROG_FULL_THRESH_ASSERT_VAL_RDCH(1023),
            .C_PROG_FULL_THRESH_ASSERT_VAL_AXIS(1023),
            .C_PROG_EMPTY_TYPE_WACH(0),
            .C_PROG_EMPTY_TYPE_WDCH(0),
            .C_PROG_EMPTY_TYPE_WRCH(0),
            .C_PROG_EMPTY_TYPE_RACH(0),
            .C_PROG_EMPTY_TYPE_RDCH(0),
            .C_PROG_EMPTY_TYPE_AXIS(0),
            .C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH(13),
            .C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH(1021),
            .C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH(29),
            .C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH(13),
            .C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH(1021),
            .C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS(1021),
            .C_REG_SLICE_MODE_WACH(0),
            .C_REG_SLICE_MODE_WDCH(0),
            .C_REG_SLICE_MODE_WRCH(0),
            .C_REG_SLICE_MODE_RACH(0),
            .C_REG_SLICE_MODE_RDCH(0),
            .C_REG_SLICE_MODE_AXIS(0)
          ) dw_fifogen_b_async (
            .m_aclk(m_axi_aclk),
            .s_aclk(s_axi_aclk),
            .s_aresetn(sm_aresetn),
            .s_axi_awid(1'b0),
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
            .s_axi_wid(1'b0),
            .s_axi_wdata(32'b0),
            .s_axi_wstrb(4'b0),
            .s_axi_wlast(1'b0),
            .s_axi_wuser(1'b0),
            .s_axi_wvalid(1'b0),
            .s_axi_wready(),
            .s_axi_bid(),
            .s_axi_bresp(s_axi_bresp_i),
            .s_axi_buser(),
            .s_axi_bvalid(s_axi_bvalid_i),
            .s_axi_bready(s_axi_bready),
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
            .m_axi_bid(1'b0),
            .m_axi_bresp(m_axi_bresp),
            .m_axi_buser(1'b0),
            .m_axi_bvalid(m_axi_bvalid),
            .m_axi_bready(m_axi_bready),
            .s_axi_arid(1'b0),
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
            .axi_b_prog_full_thresh(5'b0),
            .axi_b_prog_empty_thresh(5'b0),
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
          
        end
          
      end else begin : gen_b_passthru
        assign m_axi_bready  = s_axi_bready;
        assign s_axi_bresp_i = m_axi_bresp;
        assign s_axi_bvalid_i = m_axi_bvalid;
      end  // gen_b
    
    end else begin : NO_WRITE
      assign sr_awready = 1'b0;
      assign s_axi_wready  = 1'b0;
      assign s_axi_bid     = {C_S_AXI_ID_WIDTH{1'b0}};
      assign s_axi_bresp   = 2'b0;
      assign s_axi_bvalid  = 1'b0;
      
      assign m_axi_awaddr  = {C_AXI_ADDR_WIDTH{1'b0}};
      assign m_axi_awlen   = 8'b0;
      assign m_axi_awsize  = 3'b0;
      assign m_axi_awburst = 2'b0;
      assign m_axi_awlock  = 2'b0;
      assign m_axi_awcache = 4'b0;
      assign m_axi_awprot  = 3'b0;
      assign m_axi_awregion =  4'b0;
      assign m_axi_awqos   = 4'b0;
      assign m_axi_awvalid = 1'b0;
      assign m_axi_wdata   = {C_M_AXI_DATA_WIDTH{1'b0}};
      assign m_axi_wstrb   = {C_M_AXI_DATA_WIDTH/8{1'b0}};
      assign m_axi_wlast   = 1'b0;
      assign m_axi_wvalid  = 1'b0;
      assign m_axi_bready  = 1'b0;
      
    end
  endgenerate
  
  
  /////////////////////////////////////////////////////////////////////////////
  // Handle Read Channels (AR/R)
  /////////////////////////////////////////////////////////////////////////////
  generate
    if (C_AXI_SUPPORTS_READ == 1) begin : USE_READ
      wire [C_AXI_ADDR_WIDTH-1:0]          m_axi_araddr_i    ;
      wire [8-1:0]                         m_axi_arlen_i     ;
      wire [3-1:0]                         m_axi_arsize_i    ;
      wire [2-1:0]                         m_axi_arburst_i   ;
      wire [2-1:0]                         m_axi_arlock_i    ;
      wire [4-1:0]                         m_axi_arcache_i   ;
      wire [3-1:0]                         m_axi_arprot_i    ;
      wire [4-1:0]                         m_axi_arregion_i  ;
      wire [4-1:0]                         m_axi_arqos_i     ;
      wire                                 m_axi_arvalid_i   ;
      wire                                 m_axi_arready_i   ;
    
      // Read Channel Signals for Commands Queue Interface.
      wire                              rd_cmd_valid;
      wire                              rd_cmd_fix;
      wire                              rd_cmd_modified;
      wire                              rd_cmd_complete_wrap;
      wire                              rd_cmd_packed_wrap;
      wire [C_M_AXI_BYTES_LOG-1:0]      rd_cmd_first_word;
      wire [C_M_AXI_BYTES_LOG-1:0]      rd_cmd_next_word;
      wire [C_M_AXI_BYTES_LOG-1:0]      rd_cmd_last_word;
      wire [C_M_AXI_BYTES_LOG-1:0]      rd_cmd_offset;
      wire [C_M_AXI_BYTES_LOG-1:0]      rd_cmd_mask;
      wire [C_S_AXI_BYTES_LOG:0]        rd_cmd_step;
      wire [8-1:0]                      rd_cmd_length;
      wire                              rd_cmd_ready;
      wire [C_S_AXI_ID_WIDTH-1:0]       rd_cmd_id;
      wire [C_AXI_ADDR_WIDTH-1:0]       rd_cmd_si_addr;
      wire [C_S_AXI_ID_WIDTH-1:0]       rd_cmd_si_id;
      wire [8-1:0]                      rd_cmd_si_len;
      wire [3-1:0]                      rd_cmd_si_size;
      wire [2-1:0]                      rd_cmd_si_burst;
      
      // Read Address Channel.
      axi_dwidth_converter_v2_1_a_upsizer #
      (
       .C_FAMILY                    ("rtl"),
       .C_AXI_PROTOCOL              (C_AXI_PROTOCOL),
       .C_AXI_ID_WIDTH              (C_S_AXI_ID_WIDTH),
       .C_SUPPORTS_ID               (C_SUPPORTS_ID),
       .C_AXI_ADDR_WIDTH            (C_AXI_ADDR_WIDTH),
       .C_S_AXI_DATA_WIDTH          (C_S_AXI_DATA_WIDTH),
       .C_M_AXI_DATA_WIDTH          (C_M_AXI_DATA_WIDTH),
       .C_M_AXI_REGISTER            (C_M_AXI_AR_REGISTER),
       .C_AXI_CHANNEL               (1),
       .C_PACKING_LEVEL             (C_PACKING_LEVEL),
//       .C_FIFO_MODE                 (0),
       .C_FIFO_MODE                 (C_FIFO_MODE),
       .C_ID_QUEUE                  (P_RID_QUEUE),
       .C_S_AXI_BYTES_LOG           (C_S_AXI_BYTES_LOG),
       .C_M_AXI_BYTES_LOG           (C_M_AXI_BYTES_LOG)
        ) read_addr_inst
       (
        // Global Signals
        .ARESET                     (~s_aresetn_i),
        .ACLK                       (aclk),
    
        // Command Interface
        .cmd_valid                  (rd_cmd_valid),
        .cmd_fix                    (rd_cmd_fix),
        .cmd_modified               (rd_cmd_modified),
        .cmd_complete_wrap          (rd_cmd_complete_wrap),
        .cmd_packed_wrap            (rd_cmd_packed_wrap),
        .cmd_first_word             (rd_cmd_first_word),
        .cmd_next_word              (rd_cmd_next_word),
        .cmd_last_word              (rd_cmd_last_word),
        .cmd_offset                 (rd_cmd_offset),
        .cmd_mask                   (rd_cmd_mask),
        .cmd_step                   (rd_cmd_step),
        .cmd_length                 (rd_cmd_length),
        .cmd_ready                  (rd_cmd_ready),
        .cmd_id_ready               (rd_cmd_ready),
        .cmd_id                     (rd_cmd_id),
        .cmd_si_addr                (rd_cmd_si_addr ),
        .cmd_si_id                  (rd_cmd_si_id ),
        .cmd_si_len                 (rd_cmd_si_len  ),
        .cmd_si_size                (rd_cmd_si_size ),
        .cmd_si_burst               (rd_cmd_si_burst),
       
        // Slave Interface Write Address Ports
        .S_AXI_AID                  (sr_arid),
        .S_AXI_AADDR                (sr_araddr),
        .S_AXI_ALEN                 (sr_arlen),
        .S_AXI_ASIZE                (sr_arsize),
        .S_AXI_ABURST               (sr_arburst),
        .S_AXI_ALOCK                (sr_arlock),
        .S_AXI_ACACHE               (sr_arcache),
        .S_AXI_APROT                (sr_arprot),
        .S_AXI_AREGION              (sr_arregion),
        .S_AXI_AQOS                 (sr_arqos),
        .S_AXI_AVALID               (sr_arvalid),
        .S_AXI_AREADY               (sr_arready),
        
        // Master Interface Write Address Port
        .M_AXI_AADDR                (m_axi_araddr_i    ),
        .M_AXI_ALEN                 (m_axi_arlen_i     ),
        .M_AXI_ASIZE                (m_axi_arsize_i    ),
        .M_AXI_ABURST               (m_axi_arburst_i   ),
        .M_AXI_ALOCK                (m_axi_arlock_i    ),
        .M_AXI_ACACHE               (m_axi_arcache_i   ),
        .M_AXI_APROT                (m_axi_arprot_i    ),
        .M_AXI_AREGION              (m_axi_arregion_i  ),
        .M_AXI_AQOS                 (m_axi_arqos_i     ),
        .M_AXI_AVALID               (m_axi_arvalid_i   ),
        .M_AXI_AREADY               (m_axi_arready_i   )
       );
       
      if ((C_FIFO_MODE == P_PKTFIFO) || (C_FIFO_MODE == P_PKTFIFO_CLK)) begin : gen_pktfifo_r_upsizer
        // Packet FIFO Read Data channel.
        axi_dwidth_converter_v2_1_r_upsizer_pktfifo #
        (
         .C_FAMILY                    (C_FAMILY),
         .C_S_AXI_DATA_WIDTH          (C_S_AXI_DATA_WIDTH),
         .C_M_AXI_DATA_WIDTH          (C_M_AXI_DATA_WIDTH),
         .C_AXI_ADDR_WIDTH            (C_AXI_ADDR_WIDTH),
         .C_AXI_ID_WIDTH              (C_S_AXI_ID_WIDTH),
         .C_S_AXI_BYTES_LOG           (C_S_AXI_BYTES_LOG),
         .C_M_AXI_BYTES_LOG           (C_M_AXI_BYTES_LOG),
         .C_RATIO                     (C_RATIO),
         .C_RATIO_LOG                 (C_RATIO_LOG),
         .C_CLK_CONV                  (P_CLK_CONV),
         .C_S_AXI_ACLK_RATIO   (C_S_AXI_ACLK_RATIO),
         .C_M_AXI_ACLK_RATIO   (C_M_AXI_ACLK_RATIO),
         .C_AXI_IS_ACLK_ASYNC   (C_AXI_IS_ACLK_ASYNC),
         .C_SYNCHRONIZER_STAGE (C_SYNCHRONIZER_STAGE)
          ) pktfifo_read_data_inst
         (
          .S_AXI_ARESETN              ( s_axi_aresetn        ) ,
          .S_AXI_ACLK                 ( s_axi_aclk          ) ,
          .M_AXI_ARESETN              ( m_axi_aresetn        ) ,
          .M_AXI_ACLK                 ( m_axi_aclk          ) ,

          // Command Interface
          .cmd_si_addr                 (rd_cmd_si_addr ),
          .cmd_si_id                   (rd_cmd_si_id ),
          .cmd_si_len                  (rd_cmd_si_len  ),
          .cmd_si_size                 (rd_cmd_si_size ),
          .cmd_si_burst                (rd_cmd_si_burst),
          .cmd_ready                   (rd_cmd_ready),

          // Slave Interface Write Address Ports
          .S_AXI_ARADDR                (m_axi_araddr_i    ),  
          .S_AXI_ARLEN                 (m_axi_arlen_i     ),  
          .S_AXI_ARSIZE                (m_axi_arsize_i    ),  
          .S_AXI_ARBURST               (m_axi_arburst_i   ),  
          .S_AXI_ARLOCK                (m_axi_arlock_i    ),  
          .S_AXI_ARCACHE               (m_axi_arcache_i   ),  
          .S_AXI_ARPROT                (m_axi_arprot_i    ),  
          .S_AXI_ARREGION              (m_axi_arregion_i  ),  
          .S_AXI_ARQOS                 (m_axi_arqos_i     ),  
          .S_AXI_ARVALID               (m_axi_arvalid_i   ),  
          .S_AXI_ARREADY               (m_axi_arready_i   ),   
          
          // Master Interface Write Address Port
          .M_AXI_ARADDR                (m_axi_araddr),
          .M_AXI_ARLEN                 (m_axi_arlen),
          .M_AXI_ARSIZE                (m_axi_arsize),
          .M_AXI_ARBURST               (m_axi_arburst),
          .M_AXI_ARLOCK                (m_axi_arlock),
          .M_AXI_ARCACHE               (m_axi_arcache),
          .M_AXI_ARPROT                (m_axi_arprot),
          .M_AXI_ARREGION              (m_axi_arregion),
          .M_AXI_ARQOS                 (m_axi_arqos),
          .M_AXI_ARVALID               (m_axi_arvalid),
          .M_AXI_ARREADY               (m_axi_arready),
         
          // Slave Interface Write Data Ports
          .S_AXI_RID                  (s_axi_rid),
          .S_AXI_RDATA                (s_axi_rdata),
          .S_AXI_RRESP                (s_axi_rresp),
          .S_AXI_RLAST                (s_axi_rlast),
          .S_AXI_RVALID               (s_axi_rvalid),
          .S_AXI_RREADY               (s_axi_rready),
          
          // Master Interface Write Data Ports
          .M_AXI_RDATA                (m_axi_rdata),
          .M_AXI_RRESP                (m_axi_rresp),
          .M_AXI_RLAST                (m_axi_rlast),
          .M_AXI_RVALID               (m_axi_rvalid),
          .M_AXI_RREADY               (m_axi_rready),
          
          .SAMPLE_CYCLE               (sample_cycle),
          .SAMPLE_CYCLE_EARLY         (sample_cycle_early)
         );
        
      end else begin : gen_non_fifo_r_upsizer
        // Read Data channel.
        axi_dwidth_converter_v2_1_r_upsizer #
        (
         .C_FAMILY                    ("rtl"),
         .C_AXI_ID_WIDTH              (C_S_AXI_ID_WIDTH),
         .C_S_AXI_DATA_WIDTH          (C_S_AXI_DATA_WIDTH),
         .C_M_AXI_DATA_WIDTH          (C_M_AXI_DATA_WIDTH),
         .C_S_AXI_REGISTER            (C_S_AXI_R_REGISTER),
         .C_PACKING_LEVEL             (C_PACKING_LEVEL),
         .C_S_AXI_BYTES_LOG           (C_S_AXI_BYTES_LOG),
         .C_M_AXI_BYTES_LOG           (C_M_AXI_BYTES_LOG),
         .C_RATIO                     (C_RATIO),
         .C_RATIO_LOG                 (C_RATIO_LOG)
          ) read_data_inst
         (
          // Global Signals
          .ARESET                     (~s_aresetn_i),
          .ACLK                       (aclk),
      
          // Command Interface
          .cmd_valid                  (rd_cmd_valid),
          .cmd_fix                    (rd_cmd_fix),
          .cmd_modified               (rd_cmd_modified),
          .cmd_complete_wrap          (rd_cmd_complete_wrap),
          .cmd_packed_wrap            (rd_cmd_packed_wrap),
          .cmd_first_word             (rd_cmd_first_word),
          .cmd_next_word              (rd_cmd_next_word),
          .cmd_last_word              (rd_cmd_last_word),
          .cmd_offset                 (rd_cmd_offset),
          .cmd_mask                   (rd_cmd_mask),
          .cmd_step                   (rd_cmd_step),
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
          .M_AXI_RDATA                (mr_rdata),
          .M_AXI_RRESP                (mr_rresp),
          .M_AXI_RLAST                (mr_rlast),
          .M_AXI_RVALID               (mr_rvalid),
          .M_AXI_RREADY               (mr_rready)
         );
         
        axi_register_slice_v2_1_axi_register_slice #
          (
            .C_FAMILY                         (C_FAMILY),
            .C_AXI_PROTOCOL                   (0),
            .C_AXI_ID_WIDTH                   (1),
            .C_AXI_ADDR_WIDTH                 (C_AXI_ADDR_WIDTH),
            .C_AXI_DATA_WIDTH                 (C_M_AXI_DATA_WIDTH),
            .C_AXI_SUPPORTS_USER_SIGNALS      (0),
            .C_REG_CONFIG_R                   (C_M_AXI_R_REGISTER)
          )
          mi_register_slice_inst 
          (
            .aresetn                          (s_aresetn_i),
            .aclk                             (m_aclk),
            .s_axi_awid                       ( 1'b0     ),
            .s_axi_awaddr                     ( {C_AXI_ADDR_WIDTH{1'b0}} ),
            .s_axi_awlen                      ( 8'b0 ),
            .s_axi_awsize                     ( 3'b0 ),
            .s_axi_awburst                    ( 2'b0 ),
            .s_axi_awlock                     ( 1'b0 ),
            .s_axi_awcache                    ( 4'b0 ),
            .s_axi_awprot                     ( 3'b0 ),
            .s_axi_awregion                   ( 4'b0 ),
            .s_axi_awqos                      ( 4'b0 ),
            .s_axi_awuser                     ( 1'b0 ),
            .s_axi_awvalid                    ( 1'b0 ),
            .s_axi_awready                    (     ),
            .s_axi_wid                        ( 1'b0 ),
            .s_axi_wdata                      ( {C_M_AXI_DATA_WIDTH{1'b0}}  ),
            .s_axi_wstrb                      ( {C_M_AXI_DATA_WIDTH/8{1'b0}}  ),
            .s_axi_wlast                      ( 1'b0 ),
            .s_axi_wuser                      ( 1'b0  ),
            .s_axi_wvalid                     ( 1'b0 ),
            .s_axi_wready                     ( ),
            .s_axi_bid                        ( ),
            .s_axi_bresp                      ( ),
            .s_axi_buser                      ( ),
            .s_axi_bvalid                     ( ),
            .s_axi_bready                     ( 1'b0 ),
            .s_axi_arid                       ( 1'b0     ),
            .s_axi_araddr                     ( {C_AXI_ADDR_WIDTH{1'b0}} ),
            .s_axi_arlen                      ( 8'b0 ),
            .s_axi_arsize                     ( 3'b0 ),
            .s_axi_arburst                    ( 2'b0 ),
            .s_axi_arlock                     ( 1'b0 ),
            .s_axi_arcache                    ( 4'b0 ),
            .s_axi_arprot                     ( 3'b0 ),
            .s_axi_arregion                   ( 4'b0 ),
            .s_axi_arqos                      ( 4'b0 ),
            .s_axi_aruser                     ( 1'b0 ),
            .s_axi_arvalid                    ( 1'b0 ),
            .s_axi_arready                    (     ),
            .s_axi_rid                        (),
            .s_axi_rdata                      (mr_rdata     ),
            .s_axi_rresp                      (mr_rresp     ),
            .s_axi_rlast                      (mr_rlast     ),
            .s_axi_ruser                      (),
            .s_axi_rvalid                     (mr_rvalid    ),
            .s_axi_rready                     (mr_rready    ),
            .m_axi_awid                       (),
            .m_axi_awaddr                     (),
            .m_axi_awlen                      (),
            .m_axi_awsize                     (),
            .m_axi_awburst                    (),
            .m_axi_awlock                     (),
            .m_axi_awcache                    (),
            .m_axi_awprot                     (),
            .m_axi_awregion                   (),
            .m_axi_awqos                      (),
            .m_axi_awuser                     (),
            .m_axi_awvalid                    (),
            .m_axi_awready                    (1'b0),
            .m_axi_wid                        () ,
            .m_axi_wdata                      (),
            .m_axi_wstrb                      (),
            .m_axi_wlast                      (),
            .m_axi_wuser                      (),
            .m_axi_wvalid                     (),
            .m_axi_wready                     (1'b0),
            .m_axi_bid                        ( 1'b0 ) ,
            .m_axi_bresp                      ( 2'b0 ) ,
            .m_axi_buser                      ( 1'b0 ) ,
            .m_axi_bvalid                     ( 1'b0 ) ,
            .m_axi_bready                     ( ) ,
            .m_axi_arid                       (),
            .m_axi_araddr                     (),
            .m_axi_arlen                      (),
            .m_axi_arsize                     (),
            .m_axi_arburst                    (),
            .m_axi_arlock                     (),
            .m_axi_arcache                    (),
            .m_axi_arprot                     (),
            .m_axi_arregion                   (),
            .m_axi_arqos                      (),
            .m_axi_aruser                     (),
            .m_axi_arvalid                    (),
            .m_axi_arready                    (1'b0),
            .m_axi_rid                        (1'b0   ),
            .m_axi_rdata                      (m_axi_rdata  ),
            .m_axi_rresp                      (m_axi_rresp  ),
            .m_axi_rlast                      (m_axi_rlast  ),
            .m_axi_ruser                      (1'b0  ),
            .m_axi_rvalid                     (m_axi_rvalid ),
            .m_axi_rready                     (m_axi_rready_i )
          );
        
        assign m_axi_araddr   = m_axi_araddr_i   ;
        assign m_axi_arlen    = m_axi_arlen_i    ;
        assign m_axi_arsize   = m_axi_arsize_i   ;
        assign m_axi_arburst  = m_axi_arburst_i  ;
        assign m_axi_arlock   = m_axi_arlock_i   ;
        assign m_axi_arcache  = m_axi_arcache_i  ;
        assign m_axi_arprot   = m_axi_arprot_i   ;
        assign m_axi_arregion = m_axi_arregion_i ;
        assign m_axi_arqos    = m_axi_arqos_i    ;
        assign m_axi_arvalid  = m_axi_arvalid_i  ;
        assign m_axi_arready_i  = m_axi_arready  ;
        assign m_axi_rready = m_axi_rready_i;
        
      end // gen_r_upsizer
       
    end else begin : NO_READ
      assign sr_arready = 1'b0;
      assign s_axi_rid     = {C_S_AXI_ID_WIDTH{1'b0}};
      assign s_axi_rdata   = {C_S_AXI_DATA_WIDTH{1'b0}};
      assign s_axi_rresp   = 2'b0;
      assign s_axi_rlast   = 1'b0;
      assign s_axi_rvalid  = 1'b0;
      
      assign m_axi_araddr  = {C_AXI_ADDR_WIDTH{1'b0}};
      assign m_axi_arlen   = 8'b0;
      assign m_axi_arsize  = 3'b0;
      assign m_axi_arburst = 2'b0;
      assign m_axi_arlock  = 2'b0;
      assign m_axi_arcache = 4'b0;
      assign m_axi_arprot  = 3'b0;
      assign m_axi_arregion =  4'b0;
      assign m_axi_arqos   = 4'b0;
      assign m_axi_arvalid = 1'b0;
      assign mr_rready  = 1'b0;
      
    end
  endgenerate
  
  
endmodule
`default_nettype wire

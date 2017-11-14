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
// Description: AXI4Lite Upizer
// Converts 32-bit AXI4Lite on Slave Interface to 64-bit AXI4Lite on Master Interface.
//
// Verilog-standard:  Verilog 2001
//--------------------------------------------------------------------------
//
// Structure:
//   axi4lite_upsizer
//
//--------------------------------------------------------------------------
`timescale 1ps/1ps

(* DowngradeIPIdentifiedWarnings="yes" *) 
module axi_dwidth_converter_v2_1_axi4lite_upsizer #
  (
   parameter         C_FAMILY                         = "none", 
                       // FPGA Family.
   parameter integer C_AXI_ADDR_WIDTH                 = 32, 
                       // Width of all ADDR signals on SI and MI.
                       // Range 3 - 64.
   parameter integer C_AXI_SUPPORTS_WRITE             = 1,
   parameter integer C_AXI_SUPPORTS_READ              = 1
   )
  (
   // Global Signals
   input  wire                              aresetn,
   input  wire                              aclk,

   // Slave Interface Write Address Ports
   input  wire [C_AXI_ADDR_WIDTH-1:0]       s_axi_awaddr,
   input  wire [3-1:0]                      s_axi_awprot,
   input  wire                              s_axi_awvalid,
   output wire                              s_axi_awready,
   // Slave Interface Write Data Ports
   input  wire [32-1:0]                     s_axi_wdata,
   input  wire [32/8-1:0]                   s_axi_wstrb,
   input  wire                              s_axi_wvalid,
   output wire                              s_axi_wready,
   // Slave Interface Write Response Ports
   output wire [2-1:0]                      s_axi_bresp,
   output wire                              s_axi_bvalid,
   input  wire                              s_axi_bready,
   // Slave Interface Read Address Ports
   input  wire [C_AXI_ADDR_WIDTH-1:0]       s_axi_araddr,
   input  wire [3-1:0]                      s_axi_arprot,
   input  wire                              s_axi_arvalid,
   output wire                              s_axi_arready,
   // Slave Interface Read Data Ports
   output wire [32-1:0]                     s_axi_rdata,
   output wire [2-1:0]                      s_axi_rresp,
   output wire                              s_axi_rvalid,
   input  wire                              s_axi_rready,

   // Master Interface Write Address Port
   output wire [C_AXI_ADDR_WIDTH-1:0]       m_axi_awaddr,
   output wire [3-1:0]                      m_axi_awprot,
   output wire                              m_axi_awvalid,
   input  wire                              m_axi_awready,
   // Master Interface Write Data Ports
   output wire [64-1:0]                     m_axi_wdata,
   output wire [64/8-1:0]                   m_axi_wstrb,
   output wire                              m_axi_wvalid,
   input  wire                              m_axi_wready,
   // Master Interface Write Response Ports
   input  wire [2-1:0]                      m_axi_bresp,
   input  wire                              m_axi_bvalid,
   output wire                              m_axi_bready,
   // Master Interface Read Address Port
   output wire [C_AXI_ADDR_WIDTH-1:0]       m_axi_araddr,
   output wire [3-1:0]                      m_axi_arprot,
   output wire                              m_axi_arvalid,
   input  wire                              m_axi_arready,
   // Master Interface Read Data Ports
   input  wire [64-1:0]                     m_axi_rdata,
   input  wire [2-1:0]                      m_axi_rresp,
   input  wire                              m_axi_rvalid,
   output wire                              m_axi_rready
   );

  reg                                       s_axi_arready_i ;
  reg                                       m_axi_arvalid_i ;
  reg                                       m_axi_rready_i ;
  reg                                       s_axi_rvalid_i ;
  reg                                       ar_done         ;
  reg                                       araddr2         ;
  reg                                       s_axi_awready_i ;
  reg                                       s_axi_bvalid_i  ;
  reg                                       m_axi_awvalid_i ;
  reg                                       m_axi_wvalid_i  ;
  reg                                       m_axi_bready_i  ;
  reg                                       aw_done         ;
  reg                                       w_done          ;
  
  generate
  if (C_AXI_SUPPORTS_READ != 0) begin : gen_read
    always @(posedge aclk) begin
      if (~aresetn) begin
        s_axi_arready_i <= 1'b0 ;
        m_axi_arvalid_i <= 1'b0 ;
        s_axi_rvalid_i <= 1'b0;
        m_axi_rready_i <= 1'b1;
        ar_done         <= 1'b0 ;
        araddr2         <= 1'b0 ;
      end else begin
        s_axi_arready_i <= 1'b0 ; // end single-cycle pulse
        m_axi_rready_i <= 1'b0; // end single-cycle pulse
        if (s_axi_rvalid_i) begin
          if (s_axi_rready) begin
            s_axi_rvalid_i <= 1'b0;
            m_axi_rready_i <= 1'b1; // begin single-cycle pulse
            ar_done <= 1'b0;
          end
        end else if (m_axi_rvalid & ar_done) begin
          s_axi_rvalid_i <= 1'b1;
        end else if (m_axi_arvalid_i) begin
          if (m_axi_arready) begin
            m_axi_arvalid_i <= 1'b0;
            s_axi_arready_i <= 1'b1 ; // begin single-cycle pulse
            araddr2 <= s_axi_araddr[2];
            ar_done <= 1'b1;
          end
        end else if (s_axi_arvalid & ~ar_done) begin
          m_axi_arvalid_i <= 1'b1;
        end
      end
    end
    assign m_axi_arvalid = m_axi_arvalid_i ;
    assign s_axi_arready = s_axi_arready_i ;
    assign m_axi_araddr = s_axi_araddr;
    assign m_axi_arprot   = s_axi_arprot;
    assign s_axi_rvalid  = s_axi_rvalid_i  ;
    assign m_axi_rready  = m_axi_rready_i  ;
    assign s_axi_rdata    = araddr2 ? m_axi_rdata[63:32] : m_axi_rdata[31:0];
    assign s_axi_rresp    = m_axi_rresp;
  end else begin : gen_noread
    assign m_axi_arvalid = 1'b0 ;
    assign s_axi_arready = 1'b0 ;
    assign m_axi_araddr  = {C_AXI_ADDR_WIDTH{1'b0}} ;
    assign m_axi_arprot  = 3'b0 ;
    assign s_axi_rvalid  = 1'b0 ;
    assign m_axi_rready  = 1'b0 ;
    assign s_axi_rresp   = 2'b0 ;
    assign s_axi_rdata   = 32'b0 ;
  end
  
  if (C_AXI_SUPPORTS_WRITE != 0) begin : gen_write
    always @(posedge aclk) begin
      if (~aresetn) begin
        m_axi_awvalid_i <= 1'b0 ;
        s_axi_awready_i <= 1'b0 ;
        m_axi_wvalid_i  <= 1'b0 ;
        s_axi_bvalid_i  <= 1'b0 ;
        m_axi_bready_i  <= 1'b0 ;
        aw_done         <= 1'b0 ;
        w_done          <= 1'b0 ;
      end else begin
        m_axi_bready_i <= 1'b0; // end single-cycle pulse
        if (s_axi_bvalid_i) begin
          if (s_axi_bready) begin
            s_axi_bvalid_i <= 1'b0;
            m_axi_bready_i <= 1'b1; // begin single-cycle pulse
            aw_done <= 1'b0;
            w_done <= 1'b0;
          end
        end else if (s_axi_awready_i) begin
          s_axi_awready_i <= 1'b0; // end single-cycle pulse
          s_axi_bvalid_i <= 1'b1;
        end else if (aw_done & w_done) begin
          if (m_axi_bvalid) begin
            s_axi_awready_i <= 1'b1; // begin single-cycle pulse
          end
        end else begin
          if (m_axi_awvalid_i) begin
            if (m_axi_awready) begin
              m_axi_awvalid_i <= 1'b0;
              aw_done <= 1'b1;
            end
          end else if (s_axi_awvalid & ~aw_done) begin
            m_axi_awvalid_i <= 1'b1;
          end
          if (m_axi_wvalid_i) begin
            if (m_axi_wready) begin
              m_axi_wvalid_i <= 1'b0;
              w_done <= 1'b1;
            end
          end else if (s_axi_wvalid & (m_axi_awvalid_i | aw_done) & ~w_done) begin
            m_axi_wvalid_i <= 1'b1;
          end
        end
      end
    end
    assign m_axi_awvalid = m_axi_awvalid_i ;
    assign s_axi_awready = s_axi_awready_i ;
    assign m_axi_awaddr = s_axi_awaddr;
    assign m_axi_awprot   = s_axi_awprot;
    assign m_axi_wvalid  = m_axi_wvalid_i  ;
    assign s_axi_wready  = s_axi_awready_i ;
    assign m_axi_wdata    = {s_axi_wdata,s_axi_wdata};
    assign m_axi_wstrb    = s_axi_awaddr[2] ? {s_axi_wstrb, 4'b0} : {4'b0, s_axi_wstrb};
    assign s_axi_bvalid  = s_axi_bvalid_i  ;
    assign m_axi_bready  = m_axi_bready_i  ;
    assign s_axi_bresp    = m_axi_bresp;
  end else begin : gen_nowrite
    assign m_axi_awvalid = 1'b0 ;
    assign s_axi_awready = 1'b0 ;
    assign m_axi_awaddr  = {C_AXI_ADDR_WIDTH{1'b0}} ;
    assign m_axi_awprot  = 3'b0 ;
    assign m_axi_wvalid  = 1'b0 ;
    assign s_axi_wready  = 1'b0 ;
    assign m_axi_wdata   = 64'b0 ;
    assign m_axi_wstrb   = 8'b0 ;
    assign s_axi_bvalid  = 1'b0 ;
    assign m_axi_bready  = 1'b0 ;
    assign s_axi_bresp   = 2'b0 ;
  end

  endgenerate
endmodule

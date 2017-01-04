// (c) Copyright 1995-2017 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.

// IP VLNV: ENCLab:ip:NVMeHostController:2.0.0
// IP Revision: 1

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
OpenSSD2_NVMeHostController_0_0 your_instance_name (
  .s0_axi_aclk(s0_axi_aclk),          // input wire s0_axi_aclk
  .s0_axi_aresetn(s0_axi_aresetn),    // input wire s0_axi_aresetn
  .s0_axi_awaddr(s0_axi_awaddr),      // input wire [31 : 0] s0_axi_awaddr
  .s0_axi_awready(s0_axi_awready),    // output wire s0_axi_awready
  .s0_axi_awvalid(s0_axi_awvalid),    // input wire s0_axi_awvalid
  .s0_axi_awprot(s0_axi_awprot),      // input wire [2 : 0] s0_axi_awprot
  .s0_axi_wvalid(s0_axi_wvalid),      // input wire s0_axi_wvalid
  .s0_axi_wready(s0_axi_wready),      // output wire s0_axi_wready
  .s0_axi_wdata(s0_axi_wdata),        // input wire [31 : 0] s0_axi_wdata
  .s0_axi_wstrb(s0_axi_wstrb),        // input wire [3 : 0] s0_axi_wstrb
  .s0_axi_bvalid(s0_axi_bvalid),      // output wire s0_axi_bvalid
  .s0_axi_bready(s0_axi_bready),      // input wire s0_axi_bready
  .s0_axi_bresp(s0_axi_bresp),        // output wire [1 : 0] s0_axi_bresp
  .s0_axi_arvalid(s0_axi_arvalid),    // input wire s0_axi_arvalid
  .s0_axi_arready(s0_axi_arready),    // output wire s0_axi_arready
  .s0_axi_araddr(s0_axi_araddr),      // input wire [31 : 0] s0_axi_araddr
  .s0_axi_arprot(s0_axi_arprot),      // input wire [2 : 0] s0_axi_arprot
  .s0_axi_rvalid(s0_axi_rvalid),      // output wire s0_axi_rvalid
  .s0_axi_rready(s0_axi_rready),      // input wire s0_axi_rready
  .s0_axi_rdata(s0_axi_rdata),        // output wire [31 : 0] s0_axi_rdata
  .s0_axi_rresp(s0_axi_rresp),        // output wire [1 : 0] s0_axi_rresp
  .m0_axi_aclk(m0_axi_aclk),          // input wire m0_axi_aclk
  .m0_axi_aresetn(m0_axi_aresetn),    // input wire m0_axi_aresetn
  .m0_axi_awid(m0_axi_awid),          // output wire [0 : 0] m0_axi_awid
  .m0_axi_awaddr(m0_axi_awaddr),      // output wire [31 : 0] m0_axi_awaddr
  .m0_axi_awlen(m0_axi_awlen),        // output wire [7 : 0] m0_axi_awlen
  .m0_axi_awsize(m0_axi_awsize),      // output wire [2 : 0] m0_axi_awsize
  .m0_axi_awburst(m0_axi_awburst),    // output wire [1 : 0] m0_axi_awburst
  .m0_axi_awlock(m0_axi_awlock),      // output wire [1 : 0] m0_axi_awlock
  .m0_axi_awcache(m0_axi_awcache),    // output wire [3 : 0] m0_axi_awcache
  .m0_axi_awprot(m0_axi_awprot),      // output wire [2 : 0] m0_axi_awprot
  .m0_axi_awregion(m0_axi_awregion),  // output wire [3 : 0] m0_axi_awregion
  .m0_axi_awqos(m0_axi_awqos),        // output wire [3 : 0] m0_axi_awqos
  .m0_axi_awuser(m0_axi_awuser),      // output wire [0 : 0] m0_axi_awuser
  .m0_axi_awvalid(m0_axi_awvalid),    // output wire m0_axi_awvalid
  .m0_axi_awready(m0_axi_awready),    // input wire m0_axi_awready
  .m0_axi_wid(m0_axi_wid),            // output wire [0 : 0] m0_axi_wid
  .m0_axi_wdata(m0_axi_wdata),        // output wire [63 : 0] m0_axi_wdata
  .m0_axi_wstrb(m0_axi_wstrb),        // output wire [7 : 0] m0_axi_wstrb
  .m0_axi_wlast(m0_axi_wlast),        // output wire m0_axi_wlast
  .m0_axi_wuser(m0_axi_wuser),        // output wire [0 : 0] m0_axi_wuser
  .m0_axi_wvalid(m0_axi_wvalid),      // output wire m0_axi_wvalid
  .m0_axi_wready(m0_axi_wready),      // input wire m0_axi_wready
  .m0_axi_bid(m0_axi_bid),            // input wire [0 : 0] m0_axi_bid
  .m0_axi_bresp(m0_axi_bresp),        // input wire [1 : 0] m0_axi_bresp
  .m0_axi_bvalid(m0_axi_bvalid),      // input wire m0_axi_bvalid
  .m0_axi_buser(m0_axi_buser),        // input wire [0 : 0] m0_axi_buser
  .m0_axi_bready(m0_axi_bready),      // output wire m0_axi_bready
  .m0_axi_arid(m0_axi_arid),          // output wire [0 : 0] m0_axi_arid
  .m0_axi_araddr(m0_axi_araddr),      // output wire [31 : 0] m0_axi_araddr
  .m0_axi_arlen(m0_axi_arlen),        // output wire [7 : 0] m0_axi_arlen
  .m0_axi_arsize(m0_axi_arsize),      // output wire [2 : 0] m0_axi_arsize
  .m0_axi_arburst(m0_axi_arburst),    // output wire [1 : 0] m0_axi_arburst
  .m0_axi_arlock(m0_axi_arlock),      // output wire [1 : 0] m0_axi_arlock
  .m0_axi_arcache(m0_axi_arcache),    // output wire [3 : 0] m0_axi_arcache
  .m0_axi_arprot(m0_axi_arprot),      // output wire [2 : 0] m0_axi_arprot
  .m0_axi_arregion(m0_axi_arregion),  // output wire [3 : 0] m0_axi_arregion
  .m0_axi_arqos(m0_axi_arqos),        // output wire [3 : 0] m0_axi_arqos
  .m0_axi_aruser(m0_axi_aruser),      // output wire [0 : 0] m0_axi_aruser
  .m0_axi_arvalid(m0_axi_arvalid),    // output wire m0_axi_arvalid
  .m0_axi_arready(m0_axi_arready),    // input wire m0_axi_arready
  .m0_axi_rid(m0_axi_rid),            // input wire [0 : 0] m0_axi_rid
  .m0_axi_rdata(m0_axi_rdata),        // input wire [63 : 0] m0_axi_rdata
  .m0_axi_rresp(m0_axi_rresp),        // input wire [1 : 0] m0_axi_rresp
  .m0_axi_rlast(m0_axi_rlast),        // input wire m0_axi_rlast
  .m0_axi_ruser(m0_axi_ruser),        // input wire [0 : 0] m0_axi_ruser
  .m0_axi_rvalid(m0_axi_rvalid),      // input wire m0_axi_rvalid
  .m0_axi_rready(m0_axi_rready),      // output wire m0_axi_rready
  .dev_irq_assert(dev_irq_assert),    // output wire dev_irq_assert
  .pcie_ref_clk_p(pcie_ref_clk_p),    // input wire pcie_ref_clk_p
  .pcie_ref_clk_n(pcie_ref_clk_n),    // input wire pcie_ref_clk_n
  .pcie_perst_n(pcie_perst_n),        // input wire pcie_perst_n
  .pcie_tx_p(pcie_tx_p),              // output wire [7 : 0] pcie_tx_p
  .pcie_tx_n(pcie_tx_n),              // output wire [7 : 0] pcie_tx_n
  .pcie_rx_p(pcie_rx_p),              // input wire [7 : 0] pcie_rx_p
  .pcie_rx_n(pcie_rx_n)              // input wire [7 : 0] pcie_rx_n
);
// INST_TAG_END ------ End INSTANTIATION Template ---------


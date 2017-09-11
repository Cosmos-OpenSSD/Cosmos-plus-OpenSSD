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

// IP VLNV: xilinx.com:ip:processing_system7:5.5
// IP Revision: 0

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
OpenSSD2_processing_system7_0_0 your_instance_name (
  .ENET0_PTP_DELAY_REQ_RX(ENET0_PTP_DELAY_REQ_RX),      // output wire ENET0_PTP_DELAY_REQ_RX
  .ENET0_PTP_DELAY_REQ_TX(ENET0_PTP_DELAY_REQ_TX),      // output wire ENET0_PTP_DELAY_REQ_TX
  .ENET0_PTP_PDELAY_REQ_RX(ENET0_PTP_PDELAY_REQ_RX),    // output wire ENET0_PTP_PDELAY_REQ_RX
  .ENET0_PTP_PDELAY_REQ_TX(ENET0_PTP_PDELAY_REQ_TX),    // output wire ENET0_PTP_PDELAY_REQ_TX
  .ENET0_PTP_PDELAY_RESP_RX(ENET0_PTP_PDELAY_RESP_RX),  // output wire ENET0_PTP_PDELAY_RESP_RX
  .ENET0_PTP_PDELAY_RESP_TX(ENET0_PTP_PDELAY_RESP_TX),  // output wire ENET0_PTP_PDELAY_RESP_TX
  .ENET0_PTP_SYNC_FRAME_RX(ENET0_PTP_SYNC_FRAME_RX),    // output wire ENET0_PTP_SYNC_FRAME_RX
  .ENET0_PTP_SYNC_FRAME_TX(ENET0_PTP_SYNC_FRAME_TX),    // output wire ENET0_PTP_SYNC_FRAME_TX
  .ENET0_SOF_RX(ENET0_SOF_RX),                          // output wire ENET0_SOF_RX
  .ENET0_SOF_TX(ENET0_SOF_TX),                          // output wire ENET0_SOF_TX
  .USB0_PORT_INDCTL(USB0_PORT_INDCTL),                  // output wire [1 : 0] USB0_PORT_INDCTL
  .USB0_VBUS_PWRSELECT(USB0_VBUS_PWRSELECT),            // output wire USB0_VBUS_PWRSELECT
  .USB0_VBUS_PWRFAULT(USB0_VBUS_PWRFAULT),              // input wire USB0_VBUS_PWRFAULT
  .M_AXI_GP0_ARVALID(M_AXI_GP0_ARVALID),                // output wire M_AXI_GP0_ARVALID
  .M_AXI_GP0_AWVALID(M_AXI_GP0_AWVALID),                // output wire M_AXI_GP0_AWVALID
  .M_AXI_GP0_BREADY(M_AXI_GP0_BREADY),                  // output wire M_AXI_GP0_BREADY
  .M_AXI_GP0_RREADY(M_AXI_GP0_RREADY),                  // output wire M_AXI_GP0_RREADY
  .M_AXI_GP0_WLAST(M_AXI_GP0_WLAST),                    // output wire M_AXI_GP0_WLAST
  .M_AXI_GP0_WVALID(M_AXI_GP0_WVALID),                  // output wire M_AXI_GP0_WVALID
  .M_AXI_GP0_ARID(M_AXI_GP0_ARID),                      // output wire [11 : 0] M_AXI_GP0_ARID
  .M_AXI_GP0_AWID(M_AXI_GP0_AWID),                      // output wire [11 : 0] M_AXI_GP0_AWID
  .M_AXI_GP0_WID(M_AXI_GP0_WID),                        // output wire [11 : 0] M_AXI_GP0_WID
  .M_AXI_GP0_ARBURST(M_AXI_GP0_ARBURST),                // output wire [1 : 0] M_AXI_GP0_ARBURST
  .M_AXI_GP0_ARLOCK(M_AXI_GP0_ARLOCK),                  // output wire [1 : 0] M_AXI_GP0_ARLOCK
  .M_AXI_GP0_ARSIZE(M_AXI_GP0_ARSIZE),                  // output wire [2 : 0] M_AXI_GP0_ARSIZE
  .M_AXI_GP0_AWBURST(M_AXI_GP0_AWBURST),                // output wire [1 : 0] M_AXI_GP0_AWBURST
  .M_AXI_GP0_AWLOCK(M_AXI_GP0_AWLOCK),                  // output wire [1 : 0] M_AXI_GP0_AWLOCK
  .M_AXI_GP0_AWSIZE(M_AXI_GP0_AWSIZE),                  // output wire [2 : 0] M_AXI_GP0_AWSIZE
  .M_AXI_GP0_ARPROT(M_AXI_GP0_ARPROT),                  // output wire [2 : 0] M_AXI_GP0_ARPROT
  .M_AXI_GP0_AWPROT(M_AXI_GP0_AWPROT),                  // output wire [2 : 0] M_AXI_GP0_AWPROT
  .M_AXI_GP0_ARADDR(M_AXI_GP0_ARADDR),                  // output wire [31 : 0] M_AXI_GP0_ARADDR
  .M_AXI_GP0_AWADDR(M_AXI_GP0_AWADDR),                  // output wire [31 : 0] M_AXI_GP0_AWADDR
  .M_AXI_GP0_WDATA(M_AXI_GP0_WDATA),                    // output wire [31 : 0] M_AXI_GP0_WDATA
  .M_AXI_GP0_ARCACHE(M_AXI_GP0_ARCACHE),                // output wire [3 : 0] M_AXI_GP0_ARCACHE
  .M_AXI_GP0_ARLEN(M_AXI_GP0_ARLEN),                    // output wire [3 : 0] M_AXI_GP0_ARLEN
  .M_AXI_GP0_ARQOS(M_AXI_GP0_ARQOS),                    // output wire [3 : 0] M_AXI_GP0_ARQOS
  .M_AXI_GP0_AWCACHE(M_AXI_GP0_AWCACHE),                // output wire [3 : 0] M_AXI_GP0_AWCACHE
  .M_AXI_GP0_AWLEN(M_AXI_GP0_AWLEN),                    // output wire [3 : 0] M_AXI_GP0_AWLEN
  .M_AXI_GP0_AWQOS(M_AXI_GP0_AWQOS),                    // output wire [3 : 0] M_AXI_GP0_AWQOS
  .M_AXI_GP0_WSTRB(M_AXI_GP0_WSTRB),                    // output wire [3 : 0] M_AXI_GP0_WSTRB
  .M_AXI_GP0_ACLK(M_AXI_GP0_ACLK),                      // input wire M_AXI_GP0_ACLK
  .M_AXI_GP0_ARREADY(M_AXI_GP0_ARREADY),                // input wire M_AXI_GP0_ARREADY
  .M_AXI_GP0_AWREADY(M_AXI_GP0_AWREADY),                // input wire M_AXI_GP0_AWREADY
  .M_AXI_GP0_BVALID(M_AXI_GP0_BVALID),                  // input wire M_AXI_GP0_BVALID
  .M_AXI_GP0_RLAST(M_AXI_GP0_RLAST),                    // input wire M_AXI_GP0_RLAST
  .M_AXI_GP0_RVALID(M_AXI_GP0_RVALID),                  // input wire M_AXI_GP0_RVALID
  .M_AXI_GP0_WREADY(M_AXI_GP0_WREADY),                  // input wire M_AXI_GP0_WREADY
  .M_AXI_GP0_BID(M_AXI_GP0_BID),                        // input wire [11 : 0] M_AXI_GP0_BID
  .M_AXI_GP0_RID(M_AXI_GP0_RID),                        // input wire [11 : 0] M_AXI_GP0_RID
  .M_AXI_GP0_BRESP(M_AXI_GP0_BRESP),                    // input wire [1 : 0] M_AXI_GP0_BRESP
  .M_AXI_GP0_RRESP(M_AXI_GP0_RRESP),                    // input wire [1 : 0] M_AXI_GP0_RRESP
  .M_AXI_GP0_RDATA(M_AXI_GP0_RDATA),                    // input wire [31 : 0] M_AXI_GP0_RDATA
  .M_AXI_GP1_ARVALID(M_AXI_GP1_ARVALID),                // output wire M_AXI_GP1_ARVALID
  .M_AXI_GP1_AWVALID(M_AXI_GP1_AWVALID),                // output wire M_AXI_GP1_AWVALID
  .M_AXI_GP1_BREADY(M_AXI_GP1_BREADY),                  // output wire M_AXI_GP1_BREADY
  .M_AXI_GP1_RREADY(M_AXI_GP1_RREADY),                  // output wire M_AXI_GP1_RREADY
  .M_AXI_GP1_WLAST(M_AXI_GP1_WLAST),                    // output wire M_AXI_GP1_WLAST
  .M_AXI_GP1_WVALID(M_AXI_GP1_WVALID),                  // output wire M_AXI_GP1_WVALID
  .M_AXI_GP1_ARID(M_AXI_GP1_ARID),                      // output wire [11 : 0] M_AXI_GP1_ARID
  .M_AXI_GP1_AWID(M_AXI_GP1_AWID),                      // output wire [11 : 0] M_AXI_GP1_AWID
  .M_AXI_GP1_WID(M_AXI_GP1_WID),                        // output wire [11 : 0] M_AXI_GP1_WID
  .M_AXI_GP1_ARBURST(M_AXI_GP1_ARBURST),                // output wire [1 : 0] M_AXI_GP1_ARBURST
  .M_AXI_GP1_ARLOCK(M_AXI_GP1_ARLOCK),                  // output wire [1 : 0] M_AXI_GP1_ARLOCK
  .M_AXI_GP1_ARSIZE(M_AXI_GP1_ARSIZE),                  // output wire [2 : 0] M_AXI_GP1_ARSIZE
  .M_AXI_GP1_AWBURST(M_AXI_GP1_AWBURST),                // output wire [1 : 0] M_AXI_GP1_AWBURST
  .M_AXI_GP1_AWLOCK(M_AXI_GP1_AWLOCK),                  // output wire [1 : 0] M_AXI_GP1_AWLOCK
  .M_AXI_GP1_AWSIZE(M_AXI_GP1_AWSIZE),                  // output wire [2 : 0] M_AXI_GP1_AWSIZE
  .M_AXI_GP1_ARPROT(M_AXI_GP1_ARPROT),                  // output wire [2 : 0] M_AXI_GP1_ARPROT
  .M_AXI_GP1_AWPROT(M_AXI_GP1_AWPROT),                  // output wire [2 : 0] M_AXI_GP1_AWPROT
  .M_AXI_GP1_ARADDR(M_AXI_GP1_ARADDR),                  // output wire [31 : 0] M_AXI_GP1_ARADDR
  .M_AXI_GP1_AWADDR(M_AXI_GP1_AWADDR),                  // output wire [31 : 0] M_AXI_GP1_AWADDR
  .M_AXI_GP1_WDATA(M_AXI_GP1_WDATA),                    // output wire [31 : 0] M_AXI_GP1_WDATA
  .M_AXI_GP1_ARCACHE(M_AXI_GP1_ARCACHE),                // output wire [3 : 0] M_AXI_GP1_ARCACHE
  .M_AXI_GP1_ARLEN(M_AXI_GP1_ARLEN),                    // output wire [3 : 0] M_AXI_GP1_ARLEN
  .M_AXI_GP1_ARQOS(M_AXI_GP1_ARQOS),                    // output wire [3 : 0] M_AXI_GP1_ARQOS
  .M_AXI_GP1_AWCACHE(M_AXI_GP1_AWCACHE),                // output wire [3 : 0] M_AXI_GP1_AWCACHE
  .M_AXI_GP1_AWLEN(M_AXI_GP1_AWLEN),                    // output wire [3 : 0] M_AXI_GP1_AWLEN
  .M_AXI_GP1_AWQOS(M_AXI_GP1_AWQOS),                    // output wire [3 : 0] M_AXI_GP1_AWQOS
  .M_AXI_GP1_WSTRB(M_AXI_GP1_WSTRB),                    // output wire [3 : 0] M_AXI_GP1_WSTRB
  .M_AXI_GP1_ACLK(M_AXI_GP1_ACLK),                      // input wire M_AXI_GP1_ACLK
  .M_AXI_GP1_ARREADY(M_AXI_GP1_ARREADY),                // input wire M_AXI_GP1_ARREADY
  .M_AXI_GP1_AWREADY(M_AXI_GP1_AWREADY),                // input wire M_AXI_GP1_AWREADY
  .M_AXI_GP1_BVALID(M_AXI_GP1_BVALID),                  // input wire M_AXI_GP1_BVALID
  .M_AXI_GP1_RLAST(M_AXI_GP1_RLAST),                    // input wire M_AXI_GP1_RLAST
  .M_AXI_GP1_RVALID(M_AXI_GP1_RVALID),                  // input wire M_AXI_GP1_RVALID
  .M_AXI_GP1_WREADY(M_AXI_GP1_WREADY),                  // input wire M_AXI_GP1_WREADY
  .M_AXI_GP1_BID(M_AXI_GP1_BID),                        // input wire [11 : 0] M_AXI_GP1_BID
  .M_AXI_GP1_RID(M_AXI_GP1_RID),                        // input wire [11 : 0] M_AXI_GP1_RID
  .M_AXI_GP1_BRESP(M_AXI_GP1_BRESP),                    // input wire [1 : 0] M_AXI_GP1_BRESP
  .M_AXI_GP1_RRESP(M_AXI_GP1_RRESP),                    // input wire [1 : 0] M_AXI_GP1_RRESP
  .M_AXI_GP1_RDATA(M_AXI_GP1_RDATA),                    // input wire [31 : 0] M_AXI_GP1_RDATA
  .S_AXI_HP0_ARREADY(S_AXI_HP0_ARREADY),                // output wire S_AXI_HP0_ARREADY
  .S_AXI_HP0_AWREADY(S_AXI_HP0_AWREADY),                // output wire S_AXI_HP0_AWREADY
  .S_AXI_HP0_BVALID(S_AXI_HP0_BVALID),                  // output wire S_AXI_HP0_BVALID
  .S_AXI_HP0_RLAST(S_AXI_HP0_RLAST),                    // output wire S_AXI_HP0_RLAST
  .S_AXI_HP0_RVALID(S_AXI_HP0_RVALID),                  // output wire S_AXI_HP0_RVALID
  .S_AXI_HP0_WREADY(S_AXI_HP0_WREADY),                  // output wire S_AXI_HP0_WREADY
  .S_AXI_HP0_BRESP(S_AXI_HP0_BRESP),                    // output wire [1 : 0] S_AXI_HP0_BRESP
  .S_AXI_HP0_RRESP(S_AXI_HP0_RRESP),                    // output wire [1 : 0] S_AXI_HP0_RRESP
  .S_AXI_HP0_BID(S_AXI_HP0_BID),                        // output wire [5 : 0] S_AXI_HP0_BID
  .S_AXI_HP0_RID(S_AXI_HP0_RID),                        // output wire [5 : 0] S_AXI_HP0_RID
  .S_AXI_HP0_RDATA(S_AXI_HP0_RDATA),                    // output wire [63 : 0] S_AXI_HP0_RDATA
  .S_AXI_HP0_RCOUNT(S_AXI_HP0_RCOUNT),                  // output wire [7 : 0] S_AXI_HP0_RCOUNT
  .S_AXI_HP0_WCOUNT(S_AXI_HP0_WCOUNT),                  // output wire [7 : 0] S_AXI_HP0_WCOUNT
  .S_AXI_HP0_RACOUNT(S_AXI_HP0_RACOUNT),                // output wire [2 : 0] S_AXI_HP0_RACOUNT
  .S_AXI_HP0_WACOUNT(S_AXI_HP0_WACOUNT),                // output wire [5 : 0] S_AXI_HP0_WACOUNT
  .S_AXI_HP0_ACLK(S_AXI_HP0_ACLK),                      // input wire S_AXI_HP0_ACLK
  .S_AXI_HP0_ARVALID(S_AXI_HP0_ARVALID),                // input wire S_AXI_HP0_ARVALID
  .S_AXI_HP0_AWVALID(S_AXI_HP0_AWVALID),                // input wire S_AXI_HP0_AWVALID
  .S_AXI_HP0_BREADY(S_AXI_HP0_BREADY),                  // input wire S_AXI_HP0_BREADY
  .S_AXI_HP0_RDISSUECAP1_EN(S_AXI_HP0_RDISSUECAP1_EN),  // input wire S_AXI_HP0_RDISSUECAP1_EN
  .S_AXI_HP0_RREADY(S_AXI_HP0_RREADY),                  // input wire S_AXI_HP0_RREADY
  .S_AXI_HP0_WLAST(S_AXI_HP0_WLAST),                    // input wire S_AXI_HP0_WLAST
  .S_AXI_HP0_WRISSUECAP1_EN(S_AXI_HP0_WRISSUECAP1_EN),  // input wire S_AXI_HP0_WRISSUECAP1_EN
  .S_AXI_HP0_WVALID(S_AXI_HP0_WVALID),                  // input wire S_AXI_HP0_WVALID
  .S_AXI_HP0_ARBURST(S_AXI_HP0_ARBURST),                // input wire [1 : 0] S_AXI_HP0_ARBURST
  .S_AXI_HP0_ARLOCK(S_AXI_HP0_ARLOCK),                  // input wire [1 : 0] S_AXI_HP0_ARLOCK
  .S_AXI_HP0_ARSIZE(S_AXI_HP0_ARSIZE),                  // input wire [2 : 0] S_AXI_HP0_ARSIZE
  .S_AXI_HP0_AWBURST(S_AXI_HP0_AWBURST),                // input wire [1 : 0] S_AXI_HP0_AWBURST
  .S_AXI_HP0_AWLOCK(S_AXI_HP0_AWLOCK),                  // input wire [1 : 0] S_AXI_HP0_AWLOCK
  .S_AXI_HP0_AWSIZE(S_AXI_HP0_AWSIZE),                  // input wire [2 : 0] S_AXI_HP0_AWSIZE
  .S_AXI_HP0_ARPROT(S_AXI_HP0_ARPROT),                  // input wire [2 : 0] S_AXI_HP0_ARPROT
  .S_AXI_HP0_AWPROT(S_AXI_HP0_AWPROT),                  // input wire [2 : 0] S_AXI_HP0_AWPROT
  .S_AXI_HP0_ARADDR(S_AXI_HP0_ARADDR),                  // input wire [31 : 0] S_AXI_HP0_ARADDR
  .S_AXI_HP0_AWADDR(S_AXI_HP0_AWADDR),                  // input wire [31 : 0] S_AXI_HP0_AWADDR
  .S_AXI_HP0_ARCACHE(S_AXI_HP0_ARCACHE),                // input wire [3 : 0] S_AXI_HP0_ARCACHE
  .S_AXI_HP0_ARLEN(S_AXI_HP0_ARLEN),                    // input wire [3 : 0] S_AXI_HP0_ARLEN
  .S_AXI_HP0_ARQOS(S_AXI_HP0_ARQOS),                    // input wire [3 : 0] S_AXI_HP0_ARQOS
  .S_AXI_HP0_AWCACHE(S_AXI_HP0_AWCACHE),                // input wire [3 : 0] S_AXI_HP0_AWCACHE
  .S_AXI_HP0_AWLEN(S_AXI_HP0_AWLEN),                    // input wire [3 : 0] S_AXI_HP0_AWLEN
  .S_AXI_HP0_AWQOS(S_AXI_HP0_AWQOS),                    // input wire [3 : 0] S_AXI_HP0_AWQOS
  .S_AXI_HP0_ARID(S_AXI_HP0_ARID),                      // input wire [5 : 0] S_AXI_HP0_ARID
  .S_AXI_HP0_AWID(S_AXI_HP0_AWID),                      // input wire [5 : 0] S_AXI_HP0_AWID
  .S_AXI_HP0_WID(S_AXI_HP0_WID),                        // input wire [5 : 0] S_AXI_HP0_WID
  .S_AXI_HP0_WDATA(S_AXI_HP0_WDATA),                    // input wire [63 : 0] S_AXI_HP0_WDATA
  .S_AXI_HP0_WSTRB(S_AXI_HP0_WSTRB),                    // input wire [7 : 0] S_AXI_HP0_WSTRB
  .S_AXI_HP3_ARREADY(S_AXI_HP3_ARREADY),                // output wire S_AXI_HP3_ARREADY
  .S_AXI_HP3_AWREADY(S_AXI_HP3_AWREADY),                // output wire S_AXI_HP3_AWREADY
  .S_AXI_HP3_BVALID(S_AXI_HP3_BVALID),                  // output wire S_AXI_HP3_BVALID
  .S_AXI_HP3_RLAST(S_AXI_HP3_RLAST),                    // output wire S_AXI_HP3_RLAST
  .S_AXI_HP3_RVALID(S_AXI_HP3_RVALID),                  // output wire S_AXI_HP3_RVALID
  .S_AXI_HP3_WREADY(S_AXI_HP3_WREADY),                  // output wire S_AXI_HP3_WREADY
  .S_AXI_HP3_BRESP(S_AXI_HP3_BRESP),                    // output wire [1 : 0] S_AXI_HP3_BRESP
  .S_AXI_HP3_RRESP(S_AXI_HP3_RRESP),                    // output wire [1 : 0] S_AXI_HP3_RRESP
  .S_AXI_HP3_BID(S_AXI_HP3_BID),                        // output wire [5 : 0] S_AXI_HP3_BID
  .S_AXI_HP3_RID(S_AXI_HP3_RID),                        // output wire [5 : 0] S_AXI_HP3_RID
  .S_AXI_HP3_RDATA(S_AXI_HP3_RDATA),                    // output wire [63 : 0] S_AXI_HP3_RDATA
  .S_AXI_HP3_RCOUNT(S_AXI_HP3_RCOUNT),                  // output wire [7 : 0] S_AXI_HP3_RCOUNT
  .S_AXI_HP3_WCOUNT(S_AXI_HP3_WCOUNT),                  // output wire [7 : 0] S_AXI_HP3_WCOUNT
  .S_AXI_HP3_RACOUNT(S_AXI_HP3_RACOUNT),                // output wire [2 : 0] S_AXI_HP3_RACOUNT
  .S_AXI_HP3_WACOUNT(S_AXI_HP3_WACOUNT),                // output wire [5 : 0] S_AXI_HP3_WACOUNT
  .S_AXI_HP3_ACLK(S_AXI_HP3_ACLK),                      // input wire S_AXI_HP3_ACLK
  .S_AXI_HP3_ARVALID(S_AXI_HP3_ARVALID),                // input wire S_AXI_HP3_ARVALID
  .S_AXI_HP3_AWVALID(S_AXI_HP3_AWVALID),                // input wire S_AXI_HP3_AWVALID
  .S_AXI_HP3_BREADY(S_AXI_HP3_BREADY),                  // input wire S_AXI_HP3_BREADY
  .S_AXI_HP3_RDISSUECAP1_EN(S_AXI_HP3_RDISSUECAP1_EN),  // input wire S_AXI_HP3_RDISSUECAP1_EN
  .S_AXI_HP3_RREADY(S_AXI_HP3_RREADY),                  // input wire S_AXI_HP3_RREADY
  .S_AXI_HP3_WLAST(S_AXI_HP3_WLAST),                    // input wire S_AXI_HP3_WLAST
  .S_AXI_HP3_WRISSUECAP1_EN(S_AXI_HP3_WRISSUECAP1_EN),  // input wire S_AXI_HP3_WRISSUECAP1_EN
  .S_AXI_HP3_WVALID(S_AXI_HP3_WVALID),                  // input wire S_AXI_HP3_WVALID
  .S_AXI_HP3_ARBURST(S_AXI_HP3_ARBURST),                // input wire [1 : 0] S_AXI_HP3_ARBURST
  .S_AXI_HP3_ARLOCK(S_AXI_HP3_ARLOCK),                  // input wire [1 : 0] S_AXI_HP3_ARLOCK
  .S_AXI_HP3_ARSIZE(S_AXI_HP3_ARSIZE),                  // input wire [2 : 0] S_AXI_HP3_ARSIZE
  .S_AXI_HP3_AWBURST(S_AXI_HP3_AWBURST),                // input wire [1 : 0] S_AXI_HP3_AWBURST
  .S_AXI_HP3_AWLOCK(S_AXI_HP3_AWLOCK),                  // input wire [1 : 0] S_AXI_HP3_AWLOCK
  .S_AXI_HP3_AWSIZE(S_AXI_HP3_AWSIZE),                  // input wire [2 : 0] S_AXI_HP3_AWSIZE
  .S_AXI_HP3_ARPROT(S_AXI_HP3_ARPROT),                  // input wire [2 : 0] S_AXI_HP3_ARPROT
  .S_AXI_HP3_AWPROT(S_AXI_HP3_AWPROT),                  // input wire [2 : 0] S_AXI_HP3_AWPROT
  .S_AXI_HP3_ARADDR(S_AXI_HP3_ARADDR),                  // input wire [31 : 0] S_AXI_HP3_ARADDR
  .S_AXI_HP3_AWADDR(S_AXI_HP3_AWADDR),                  // input wire [31 : 0] S_AXI_HP3_AWADDR
  .S_AXI_HP3_ARCACHE(S_AXI_HP3_ARCACHE),                // input wire [3 : 0] S_AXI_HP3_ARCACHE
  .S_AXI_HP3_ARLEN(S_AXI_HP3_ARLEN),                    // input wire [3 : 0] S_AXI_HP3_ARLEN
  .S_AXI_HP3_ARQOS(S_AXI_HP3_ARQOS),                    // input wire [3 : 0] S_AXI_HP3_ARQOS
  .S_AXI_HP3_AWCACHE(S_AXI_HP3_AWCACHE),                // input wire [3 : 0] S_AXI_HP3_AWCACHE
  .S_AXI_HP3_AWLEN(S_AXI_HP3_AWLEN),                    // input wire [3 : 0] S_AXI_HP3_AWLEN
  .S_AXI_HP3_AWQOS(S_AXI_HP3_AWQOS),                    // input wire [3 : 0] S_AXI_HP3_AWQOS
  .S_AXI_HP3_ARID(S_AXI_HP3_ARID),                      // input wire [5 : 0] S_AXI_HP3_ARID
  .S_AXI_HP3_AWID(S_AXI_HP3_AWID),                      // input wire [5 : 0] S_AXI_HP3_AWID
  .S_AXI_HP3_WID(S_AXI_HP3_WID),                        // input wire [5 : 0] S_AXI_HP3_WID
  .S_AXI_HP3_WDATA(S_AXI_HP3_WDATA),                    // input wire [63 : 0] S_AXI_HP3_WDATA
  .S_AXI_HP3_WSTRB(S_AXI_HP3_WSTRB),                    // input wire [7 : 0] S_AXI_HP3_WSTRB
  .IRQ_F2P(IRQ_F2P),                                    // input wire [0 : 0] IRQ_F2P
  .FCLK_CLK0(FCLK_CLK0),                                // output wire FCLK_CLK0
  .FCLK_CLK2(FCLK_CLK2),                                // output wire FCLK_CLK2
  .FCLK_CLK3(FCLK_CLK3),                                // output wire FCLK_CLK3
  .FCLK_RESET0_N(FCLK_RESET0_N),                        // output wire FCLK_RESET0_N
  .FCLK_RESET2_N(FCLK_RESET2_N),                        // output wire FCLK_RESET2_N
  .FCLK_RESET3_N(FCLK_RESET3_N),                        // output wire FCLK_RESET3_N
  .MIO(MIO),                                            // inout wire [53 : 0] MIO
  .DDR_CAS_n(DDR_CAS_n),                                // inout wire DDR_CAS_n
  .DDR_CKE(DDR_CKE),                                    // inout wire DDR_CKE
  .DDR_Clk_n(DDR_Clk_n),                                // inout wire DDR_Clk_n
  .DDR_Clk(DDR_Clk),                                    // inout wire DDR_Clk
  .DDR_CS_n(DDR_CS_n),                                  // inout wire DDR_CS_n
  .DDR_DRSTB(DDR_DRSTB),                                // inout wire DDR_DRSTB
  .DDR_ODT(DDR_ODT),                                    // inout wire DDR_ODT
  .DDR_RAS_n(DDR_RAS_n),                                // inout wire DDR_RAS_n
  .DDR_WEB(DDR_WEB),                                    // inout wire DDR_WEB
  .DDR_BankAddr(DDR_BankAddr),                          // inout wire [2 : 0] DDR_BankAddr
  .DDR_Addr(DDR_Addr),                                  // inout wire [14 : 0] DDR_Addr
  .DDR_VRN(DDR_VRN),                                    // inout wire DDR_VRN
  .DDR_VRP(DDR_VRP),                                    // inout wire DDR_VRP
  .DDR_DM(DDR_DM),                                      // inout wire [3 : 0] DDR_DM
  .DDR_DQ(DDR_DQ),                                      // inout wire [31 : 0] DDR_DQ
  .DDR_DQS_n(DDR_DQS_n),                                // inout wire [3 : 0] DDR_DQS_n
  .DDR_DQS(DDR_DQS),                                    // inout wire [3 : 0] DDR_DQS
  .PS_SRSTB(PS_SRSTB),                                  // inout wire PS_SRSTB
  .PS_CLK(PS_CLK),                                      // inout wire PS_CLK
  .PS_PORB(PS_PORB)                                    // inout wire PS_PORB
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

// You must compile the wrapper file OpenSSD2_processing_system7_0_0.v when simulating
// the core, OpenSSD2_processing_system7_0_0. When compiling the wrapper file, be sure to
// reference the Verilog simulation library.


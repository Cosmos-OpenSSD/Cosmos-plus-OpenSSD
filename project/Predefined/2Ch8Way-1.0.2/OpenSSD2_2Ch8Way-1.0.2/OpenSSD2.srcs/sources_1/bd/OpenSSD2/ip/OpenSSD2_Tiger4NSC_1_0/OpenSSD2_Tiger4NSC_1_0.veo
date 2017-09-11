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

// IP VLNV: ENCLab:ip:Tiger4NSC:1.2.3-1
// IP Revision: 11

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
OpenSSD2_Tiger4NSC_1_0 your_instance_name (
  .iClock(iClock),                          // input wire iClock
  .iReset(iReset),                          // input wire iReset
  .C_AWVALID(C_AWVALID),                    // input wire C_AWVALID
  .C_AWREADY(C_AWREADY),                    // output wire C_AWREADY
  .C_AWADDR(C_AWADDR),                      // input wire [31 : 0] C_AWADDR
  .C_AWPROT(C_AWPROT),                      // input wire [2 : 0] C_AWPROT
  .C_WVALID(C_WVALID),                      // input wire C_WVALID
  .C_WREADY(C_WREADY),                      // output wire C_WREADY
  .C_WDATA(C_WDATA),                        // input wire [31 : 0] C_WDATA
  .C_WSTRB(C_WSTRB),                        // input wire [3 : 0] C_WSTRB
  .C_BVALID(C_BVALID),                      // output wire C_BVALID
  .C_BREADY(C_BREADY),                      // input wire C_BREADY
  .C_BRESP(C_BRESP),                        // output wire [1 : 0] C_BRESP
  .C_ARVALID(C_ARVALID),                    // input wire C_ARVALID
  .C_ARREADY(C_ARREADY),                    // output wire C_ARREADY
  .C_ARADDR(C_ARADDR),                      // input wire [31 : 0] C_ARADDR
  .C_ARPROT(C_ARPROT),                      // input wire [2 : 0] C_ARPROT
  .C_RVALID(C_RVALID),                      // output wire C_RVALID
  .C_RREADY(C_RREADY),                      // input wire C_RREADY
  .C_RDATA(C_RDATA),                        // output wire [31 : 0] C_RDATA
  .C_RRESP(C_RRESP),                        // output wire [1 : 0] C_RRESP
  .D_AWADDR(D_AWADDR),                      // output wire [31 : 0] D_AWADDR
  .D_AWLEN(D_AWLEN),                        // output wire [7 : 0] D_AWLEN
  .D_AWSIZE(D_AWSIZE),                      // output wire [2 : 0] D_AWSIZE
  .D_AWBURST(D_AWBURST),                    // output wire [1 : 0] D_AWBURST
  .D_AWCACHE(D_AWCACHE),                    // output wire [3 : 0] D_AWCACHE
  .D_AWPROT(D_AWPROT),                      // output wire [2 : 0] D_AWPROT
  .D_AWVALID(D_AWVALID),                    // output wire D_AWVALID
  .D_AWREADY(D_AWREADY),                    // input wire D_AWREADY
  .D_WDATA(D_WDATA),                        // output wire [31 : 0] D_WDATA
  .D_WSTRB(D_WSTRB),                        // output wire [3 : 0] D_WSTRB
  .D_WLAST(D_WLAST),                        // output wire D_WLAST
  .D_WVALID(D_WVALID),                      // output wire D_WVALID
  .D_WREADY(D_WREADY),                      // input wire D_WREADY
  .D_BRESP(D_BRESP),                        // input wire [1 : 0] D_BRESP
  .D_BVALID(D_BVALID),                      // input wire D_BVALID
  .D_BREADY(D_BREADY),                      // output wire D_BREADY
  .D_ARADDR(D_ARADDR),                      // output wire [31 : 0] D_ARADDR
  .D_ARLEN(D_ARLEN),                        // output wire [7 : 0] D_ARLEN
  .D_ARSIZE(D_ARSIZE),                      // output wire [2 : 0] D_ARSIZE
  .D_ARBURST(D_ARBURST),                    // output wire [1 : 0] D_ARBURST
  .D_ARCACHE(D_ARCACHE),                    // output wire [3 : 0] D_ARCACHE
  .D_ARPROT(D_ARPROT),                      // output wire [2 : 0] D_ARPROT
  .D_ARVALID(D_ARVALID),                    // output wire D_ARVALID
  .D_ARREADY(D_ARREADY),                    // input wire D_ARREADY
  .D_RDATA(D_RDATA),                        // input wire [31 : 0] D_RDATA
  .D_RRESP(D_RRESP),                        // input wire [1 : 0] D_RRESP
  .D_RLAST(D_RLAST),                        // input wire D_RLAST
  .D_RVALID(D_RVALID),                      // input wire D_RVALID
  .D_RREADY(D_RREADY),                      // output wire D_RREADY
  .oOpcode(oOpcode),                        // output wire [5 : 0] oOpcode
  .oTargetID(oTargetID),                    // output wire [4 : 0] oTargetID
  .oSourceID(oSourceID),                    // output wire [4 : 0] oSourceID
  .oAddress(oAddress),                      // output wire [31 : 0] oAddress
  .oLength(oLength),                        // output wire [15 : 0] oLength
  .oCMDValid(oCMDValid),                    // output wire oCMDValid
  .iCMDReady(iCMDReady),                    // input wire iCMDReady
  .oWriteData(oWriteData),                  // output wire [31 : 0] oWriteData
  .oWriteLast(oWriteLast),                  // output wire oWriteLast
  .oWriteValid(oWriteValid),                // output wire oWriteValid
  .iWriteReady(iWriteReady),                // input wire iWriteReady
  .iReadData(iReadData),                    // input wire [31 : 0] iReadData
  .iReadLast(iReadLast),                    // input wire iReadLast
  .iReadValid(iReadValid),                  // input wire iReadValid
  .oReadReady(oReadReady),                  // output wire oReadReady
  .iReadyBusy(iReadyBusy),                  // input wire [7 : 0] iReadyBusy
  .oROMClock(oROMClock),                    // output wire oROMClock
  .oROMReset(oROMReset),                    // output wire oROMReset
  .oROMAddr(oROMAddr),                      // output wire [255 : 0] oROMAddr
  .oROMRW(oROMRW),                          // output wire oROMRW
  .oROMEnable(oROMEnable),                  // output wire oROMEnable
  .oROMWData(oROMWData),                    // output wire [63 : 0] oROMWData
  .iROMRData(iROMRData),                    // input wire [63 : 0] iROMRData
  .iSharedKESReady(iSharedKESReady),        // input wire iSharedKESReady
  .oErrorDetectionEnd(oErrorDetectionEnd),  // output wire [1 : 0] oErrorDetectionEnd
  .oDecodeNeeded(oDecodeNeeded),            // output wire [1 : 0] oDecodeNeeded
  .oSyndromes(oSyndromes),                  // output wire [647 : 0] oSyndromes
  .iIntraSharedKESEnd(iIntraSharedKESEnd),  // input wire iIntraSharedKESEnd
  .iErroredChunk(iErroredChunk),            // input wire [1 : 0] iErroredChunk
  .iCorrectionFail(iCorrectionFail),        // input wire [1 : 0] iCorrectionFail
  .iErrorCount(iErrorCount),                // input wire [17 : 0] iErrorCount
  .iELPCoefficients(iELPCoefficients),      // input wire [359 : 0] iELPCoefficients
  .oCSAvailable(oCSAvailable),              // output wire oCSAvailable
  .O_DEBUG(O_DEBUG)                        // output wire [31 : 0] O_DEBUG
);
// INST_TAG_END ------ End INSTANTIATION Template ---------


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

// IP VLNV: ENCLab:ip:Tiger4SharedKES:1.0.0
// IP Revision: 2

// The following must be inserted into your Verilog file for this
// core to be instantiated. Change the instance name and port connections
// (in parentheses) to your own signal names.

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
OpenSSD2_Tiger4SharedKES_0_0 your_instance_name (
  .iClock(iClock),                              // input wire iClock
  .iReset(iReset),                              // input wire iReset
  .oSharedKESReady_0(oSharedKESReady_0),        // output wire oSharedKESReady_0
  .iErrorDetectionEnd_0(iErrorDetectionEnd_0),  // input wire [1 : 0] iErrorDetectionEnd_0
  .iDecodeNeeded_0(iDecodeNeeded_0),            // input wire [1 : 0] iDecodeNeeded_0
  .iSyndromes_0(iSyndromes_0),                  // input wire [647 : 0] iSyndromes_0
  .iCSAvailable_0(iCSAvailable_0),              // input wire iCSAvailable_0
  .oIntraSharedKESEnd_0(oIntraSharedKESEnd_0),  // output wire oIntraSharedKESEnd_0
  .oErroredChunk_0(oErroredChunk_0),            // output wire [1 : 0] oErroredChunk_0
  .oCorrectionFail_0(oCorrectionFail_0),        // output wire [1 : 0] oCorrectionFail_0
  .oClusterErrorCount_0(oClusterErrorCount_0),  // output wire [17 : 0] oClusterErrorCount_0
  .oELPCoefficients_0(oELPCoefficients_0),      // output wire [359 : 0] oELPCoefficients_0
  .oSharedKESReady_1(oSharedKESReady_1),        // output wire oSharedKESReady_1
  .iErrorDetectionEnd_1(iErrorDetectionEnd_1),  // input wire [1 : 0] iErrorDetectionEnd_1
  .iDecodeNeeded_1(iDecodeNeeded_1),            // input wire [1 : 0] iDecodeNeeded_1
  .iSyndromes_1(iSyndromes_1),                  // input wire [647 : 0] iSyndromes_1
  .iCSAvailable_1(iCSAvailable_1),              // input wire iCSAvailable_1
  .oIntraSharedKESEnd_1(oIntraSharedKESEnd_1),  // output wire oIntraSharedKESEnd_1
  .oErroredChunk_1(oErroredChunk_1),            // output wire [1 : 0] oErroredChunk_1
  .oCorrectionFail_1(oCorrectionFail_1),        // output wire [1 : 0] oCorrectionFail_1
  .oClusterErrorCount_1(oClusterErrorCount_1),  // output wire [17 : 0] oClusterErrorCount_1
  .oELPCoefficients_1(oELPCoefficients_1),      // output wire [359 : 0] oELPCoefficients_1
  .oSharedKESReady_2(oSharedKESReady_2),        // output wire oSharedKESReady_2
  .iErrorDetectionEnd_2(iErrorDetectionEnd_2),  // input wire [1 : 0] iErrorDetectionEnd_2
  .iDecodeNeeded_2(iDecodeNeeded_2),            // input wire [1 : 0] iDecodeNeeded_2
  .iSyndromes_2(iSyndromes_2),                  // input wire [647 : 0] iSyndromes_2
  .iCSAvailable_2(iCSAvailable_2),              // input wire iCSAvailable_2
  .oIntraSharedKESEnd_2(oIntraSharedKESEnd_2),  // output wire oIntraSharedKESEnd_2
  .oErroredChunk_2(oErroredChunk_2),            // output wire [1 : 0] oErroredChunk_2
  .oCorrectionFail_2(oCorrectionFail_2),        // output wire [1 : 0] oCorrectionFail_2
  .oClusterErrorCount_2(oClusterErrorCount_2),  // output wire [17 : 0] oClusterErrorCount_2
  .oELPCoefficients_2(oELPCoefficients_2),      // output wire [359 : 0] oELPCoefficients_2
  .oSharedKESReady_3(oSharedKESReady_3),        // output wire oSharedKESReady_3
  .iErrorDetectionEnd_3(iErrorDetectionEnd_3),  // input wire [1 : 0] iErrorDetectionEnd_3
  .iDecodeNeeded_3(iDecodeNeeded_3),            // input wire [1 : 0] iDecodeNeeded_3
  .iSyndromes_3(iSyndromes_3),                  // input wire [647 : 0] iSyndromes_3
  .iCSAvailable_3(iCSAvailable_3),              // input wire iCSAvailable_3
  .oIntraSharedKESEnd_3(oIntraSharedKESEnd_3),  // output wire oIntraSharedKESEnd_3
  .oErroredChunk_3(oErroredChunk_3),            // output wire [1 : 0] oErroredChunk_3
  .oCorrectionFail_3(oCorrectionFail_3),        // output wire [1 : 0] oCorrectionFail_3
  .oClusterErrorCount_3(oClusterErrorCount_3),  // output wire [17 : 0] oClusterErrorCount_3
  .oELPCoefficients_3(oELPCoefficients_3)      // output wire [359 : 0] oELPCoefficients_3
);
// INST_TAG_END ------ End INSTANTIATION Template ---------


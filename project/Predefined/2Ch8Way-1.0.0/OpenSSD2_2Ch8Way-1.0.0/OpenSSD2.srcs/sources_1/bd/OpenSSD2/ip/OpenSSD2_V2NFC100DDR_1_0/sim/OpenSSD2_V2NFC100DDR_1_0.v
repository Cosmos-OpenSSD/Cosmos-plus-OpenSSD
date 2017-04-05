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


// IP VLNV: ENCLab:ip:V2NFC100DDR:1.0.0
// IP Revision: 2

`timescale 1ns/1ps

(* DowngradeIPIdentifiedWarnings = "yes" *)
module OpenSSD2_V2NFC100DDR_1_0 (
  iSystemClock,
  iDelayRefClock,
  iOutputDrivingClock,
  iReset,
  iOpcode,
  iTargetID,
  iSourceID,
  iAddress,
  iLength,
  iCMDValid,
  oCMDReady,
  iWriteData,
  iWriteLast,
  iWriteValid,
  oWriteReady,
  oReadData,
  oReadLast,
  oReadValid,
  iReadReady,
  oReadyBusy,
  IO_NAND_DQS_P,
  IO_NAND_DQS_N,
  IO_NAND_DQ,
  O_NAND_CE,
  O_NAND_WE,
  O_NAND_RE_P,
  O_NAND_RE_N,
  O_NAND_ALE,
  O_NAND_CLE,
  I_NAND_RB,
  O_NAND_WP
);

(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 signal_clock CLK" *)
input wire iSystemClock;
input wire iDelayRefClock;
input wire iOutputDrivingClock;
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 signal_reset RST" *)
input wire iReset;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface Opcode" *)
input wire [5 : 0] iOpcode;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface TargetID" *)
input wire [4 : 0] iTargetID;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface SourceID" *)
input wire [4 : 0] iSourceID;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface Address" *)
input wire [31 : 0] iAddress;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface Length" *)
input wire [15 : 0] iLength;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface CMDValid" *)
input wire iCMDValid;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface CMDReady" *)
output wire oCMDReady;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface WriteData" *)
input wire [31 : 0] iWriteData;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface WriteLast" *)
input wire iWriteLast;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface WriteValid" *)
input wire iWriteValid;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface WriteReady" *)
output wire oWriteReady;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface ReadData" *)
output wire [31 : 0] oReadData;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface ReadLast" *)
output wire oReadLast;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface ReadValid" *)
output wire oReadValid;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface ReadReady" *)
input wire iReadReady;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface ReadyBusy" *)
output wire [7 : 0] oReadyBusy;
inout wire IO_NAND_DQS_P;
inout wire IO_NAND_DQS_N;
inout wire [7 : 0] IO_NAND_DQ;
output wire [7 : 0] O_NAND_CE;
output wire O_NAND_WE;
output wire O_NAND_RE_P;
output wire O_NAND_RE_N;
output wire O_NAND_ALE;
output wire O_NAND_CLE;
input wire [7 : 0] I_NAND_RB;
output wire O_NAND_WP;

  NFC_Toggle_Top_DDR100 #(
    .NumberOfWays(8),
    .IDelayValue(13),
    .InputClockBufferType(0)
  ) inst (
    .iSystemClock(iSystemClock),
    .iDelayRefClock(iDelayRefClock),
    .iOutputDrivingClock(iOutputDrivingClock),
    .iReset(iReset),
    .iOpcode(iOpcode),
    .iTargetID(iTargetID),
    .iSourceID(iSourceID),
    .iAddress(iAddress),
    .iLength(iLength),
    .iCMDValid(iCMDValid),
    .oCMDReady(oCMDReady),
    .iWriteData(iWriteData),
    .iWriteLast(iWriteLast),
    .iWriteValid(iWriteValid),
    .oWriteReady(oWriteReady),
    .oReadData(oReadData),
    .oReadLast(oReadLast),
    .oReadValid(oReadValid),
    .iReadReady(iReadReady),
    .oReadyBusy(oReadyBusy),
    .IO_NAND_DQS_P(IO_NAND_DQS_P),
    .IO_NAND_DQS_N(IO_NAND_DQS_N),
    .IO_NAND_DQ(IO_NAND_DQ),
    .O_NAND_CE(O_NAND_CE),
    .O_NAND_WE(O_NAND_WE),
    .O_NAND_RE_P(O_NAND_RE_P),
    .O_NAND_RE_N(O_NAND_RE_N),
    .O_NAND_ALE(O_NAND_ALE),
    .O_NAND_CLE(O_NAND_CLE),
    .I_NAND_RB(I_NAND_RB),
    .O_NAND_WP(O_NAND_WP)
  );
endmodule

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


// IP VLNV: ENCLab:ip:Tiger4NSC:1.2.3
// IP Revision: 1

(* X_CORE_INFO = "FMCTop,Vivado 2014.4.1" *)
(* CHECK_LICENSE_TYPE = "OpenSSD2_Tiger4NSC_1_0,FMCTop,{}" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module OpenSSD2_Tiger4NSC_1_0 (
  iClock,
  iReset,
  C_AWVALID,
  C_AWREADY,
  C_AWADDR,
  C_AWPROT,
  C_WVALID,
  C_WREADY,
  C_WDATA,
  C_WSTRB,
  C_BVALID,
  C_BREADY,
  C_BRESP,
  C_ARVALID,
  C_ARREADY,
  C_ARADDR,
  C_ARPROT,
  C_RVALID,
  C_RREADY,
  C_RDATA,
  C_RRESP,
  D_AWADDR,
  D_AWLEN,
  D_AWSIZE,
  D_AWBURST,
  D_AWCACHE,
  D_AWPROT,
  D_AWVALID,
  D_AWREADY,
  D_WDATA,
  D_WSTRB,
  D_WLAST,
  D_WVALID,
  D_WREADY,
  D_BRESP,
  D_BVALID,
  D_BREADY,
  D_ARADDR,
  D_ARLEN,
  D_ARSIZE,
  D_ARBURST,
  D_ARCACHE,
  D_ARPROT,
  D_ARVALID,
  D_ARREADY,
  D_RDATA,
  D_RRESP,
  D_RLAST,
  D_RVALID,
  D_RREADY,
  oOpcode,
  oTargetID,
  oSourceID,
  oAddress,
  oLength,
  oCMDValid,
  iCMDReady,
  oWriteData,
  oWriteLast,
  oWriteValid,
  iWriteReady,
  iReadData,
  iReadLast,
  iReadValid,
  oReadReady,
  iReadyBusy,
  oROMClock,
  oROMReset,
  oROMAddr,
  oROMRW,
  oROMEnable,
  oROMWData,
  iROMRData,
  iSharedKESReady,
  oErrorDetectionEnd,
  oDecodeNeeded,
  oSyndromes,
  iIntraSharedKESEnd,
  iErroredChunk,
  iCorrectionFail,
  iErrorCount,
  iELPCoefficients,
  oCSAvailable,
  O_DEBUG
);

(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 signal_clock CLK" *)
input wire iClock;
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 signal_reset RST" *)
input wire iReset;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C_AXI AWVALID" *)
input wire C_AWVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C_AXI AWREADY" *)
output wire C_AWREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C_AXI AWADDR" *)
input wire [31 : 0] C_AWADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C_AXI AWPROT" *)
input wire [2 : 0] C_AWPROT;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C_AXI WVALID" *)
input wire C_WVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C_AXI WREADY" *)
output wire C_WREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C_AXI WDATA" *)
input wire [31 : 0] C_WDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C_AXI WSTRB" *)
input wire [3 : 0] C_WSTRB;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C_AXI BVALID" *)
output wire C_BVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C_AXI BREADY" *)
input wire C_BREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C_AXI BRESP" *)
output wire [1 : 0] C_BRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C_AXI ARVALID" *)
input wire C_ARVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C_AXI ARREADY" *)
output wire C_ARREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C_AXI ARADDR" *)
input wire [31 : 0] C_ARADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C_AXI ARPROT" *)
input wire [2 : 0] C_ARPROT;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C_AXI RVALID" *)
output wire C_RVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C_AXI RREADY" *)
input wire C_RREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C_AXI RDATA" *)
output wire [31 : 0] C_RDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 C_AXI RRESP" *)
output wire [1 : 0] C_RRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI AWADDR" *)
output wire [31 : 0] D_AWADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI AWLEN" *)
output wire [7 : 0] D_AWLEN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI AWSIZE" *)
output wire [2 : 0] D_AWSIZE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI AWBURST" *)
output wire [1 : 0] D_AWBURST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI AWCACHE" *)
output wire [3 : 0] D_AWCACHE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI AWPROT" *)
output wire [2 : 0] D_AWPROT;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI AWVALID" *)
output wire D_AWVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI AWREADY" *)
input wire D_AWREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI WDATA" *)
output wire [31 : 0] D_WDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI WSTRB" *)
output wire [3 : 0] D_WSTRB;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI WLAST" *)
output wire D_WLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI WVALID" *)
output wire D_WVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI WREADY" *)
input wire D_WREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI BRESP" *)
input wire [1 : 0] D_BRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI BVALID" *)
input wire D_BVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI BREADY" *)
output wire D_BREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI ARADDR" *)
output wire [31 : 0] D_ARADDR;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI ARLEN" *)
output wire [7 : 0] D_ARLEN;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI ARSIZE" *)
output wire [2 : 0] D_ARSIZE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI ARBURST" *)
output wire [1 : 0] D_ARBURST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI ARCACHE" *)
output wire [3 : 0] D_ARCACHE;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI ARPROT" *)
output wire [2 : 0] D_ARPROT;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI ARVALID" *)
output wire D_ARVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI ARREADY" *)
input wire D_ARREADY;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI RDATA" *)
input wire [31 : 0] D_RDATA;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI RRESP" *)
input wire [1 : 0] D_RRESP;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI RLAST" *)
input wire D_RLAST;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI RVALID" *)
input wire D_RVALID;
(* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 D_AXI RREADY" *)
output wire D_RREADY;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface Opcode" *)
output wire [5 : 0] oOpcode;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface TargetID" *)
output wire [4 : 0] oTargetID;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface SourceID" *)
output wire [4 : 0] oSourceID;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface Address" *)
output wire [31 : 0] oAddress;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface Length" *)
output wire [15 : 0] oLength;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface CMDValid" *)
output wire oCMDValid;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface CMDReady" *)
input wire iCMDReady;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface WriteData" *)
output wire [31 : 0] oWriteData;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface WriteLast" *)
output wire oWriteLast;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface WriteValid" *)
output wire oWriteValid;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface WriteReady" *)
input wire iWriteReady;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface ReadData" *)
input wire [31 : 0] iReadData;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface ReadLast" *)
input wire iReadLast;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface ReadValid" *)
input wire iReadValid;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface ReadReady" *)
output wire oReadReady;
(* X_INTERFACE_INFO = "ENCLab:user:V2FMCDCLW:1.0 NFCInterface ReadyBusy" *)
input wire [7 : 0] iReadyBusy;
(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 uROMInterface CLK" *)
output wire oROMClock;
(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 uROMInterface RST" *)
output wire oROMReset;
(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 uROMInterface ADDR" *)
output wire [255 : 0] oROMAddr;
(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 uROMInterface WE" *)
output wire oROMRW;
(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 uROMInterface EN" *)
output wire oROMEnable;
(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 uROMInterface DIN" *)
output wire [63 : 0] oROMWData;
(* X_INTERFACE_INFO = "xilinx.com:interface:bram:1.0 uROMInterface DOUT" *)
input wire [63 : 0] iROMRData;
(* X_INTERFACE_INFO = "ENCLab:user:SharedKESInterface:1.0 SharedKESInterface SharedKESReady" *)
input wire iSharedKESReady;
(* X_INTERFACE_INFO = "ENCLab:user:SharedKESInterface:1.0 SharedKESInterface ErrorDetectionEnd" *)
output wire [1 : 0] oErrorDetectionEnd;
(* X_INTERFACE_INFO = "ENCLab:user:SharedKESInterface:1.0 SharedKESInterface DecodeNeeded" *)
output wire [1 : 0] oDecodeNeeded;
(* X_INTERFACE_INFO = "ENCLab:user:SharedKESInterface:1.0 SharedKESInterface Syndromes" *)
output wire [647 : 0] oSyndromes;
(* X_INTERFACE_INFO = "ENCLab:user:SharedKESInterface:1.0 SharedKESInterface IntraSharedKESEnd" *)
input wire iIntraSharedKESEnd;
(* X_INTERFACE_INFO = "ENCLab:user:SharedKESInterface:1.0 SharedKESInterface ErroredChunk" *)
input wire [1 : 0] iErroredChunk;
(* X_INTERFACE_INFO = "ENCLab:user:SharedKESInterface:1.0 SharedKESInterface CorrectionFail" *)
input wire [1 : 0] iCorrectionFail;
(* X_INTERFACE_INFO = "ENCLab:user:SharedKESInterface:1.0 SharedKESInterface ErrorCount" *)
input wire [17 : 0] iErrorCount;
(* X_INTERFACE_INFO = "ENCLab:user:SharedKESInterface:1.0 SharedKESInterface ELPCoefficients" *)
input wire [359 : 0] iELPCoefficients;
(* X_INTERFACE_INFO = "ENCLab:user:SharedKESInterface:1.0 SharedKESInterface CSAvailable" *)
output wire oCSAvailable;
output wire [31 : 0] O_DEBUG;

  FMCTop #(
    .NumberOfWays(8),
    .ProgWordWidth(64),
    .UProgSize(256),
    .BCHDecMulti(2),
    .GaloisFieldDegree(12),
    .MaxErrorCountBits(9),
    .Syndromes(27),
    .ELPCoefficients(15)
  ) inst (
    .iClock(iClock),
    .iReset(iReset),
    .C_AWVALID(C_AWVALID),
    .C_AWREADY(C_AWREADY),
    .C_AWADDR(C_AWADDR),
    .C_AWPROT(C_AWPROT),
    .C_WVALID(C_WVALID),
    .C_WREADY(C_WREADY),
    .C_WDATA(C_WDATA),
    .C_WSTRB(C_WSTRB),
    .C_BVALID(C_BVALID),
    .C_BREADY(C_BREADY),
    .C_BRESP(C_BRESP),
    .C_ARVALID(C_ARVALID),
    .C_ARREADY(C_ARREADY),
    .C_ARADDR(C_ARADDR),
    .C_ARPROT(C_ARPROT),
    .C_RVALID(C_RVALID),
    .C_RREADY(C_RREADY),
    .C_RDATA(C_RDATA),
    .C_RRESP(C_RRESP),
    .D_AWADDR(D_AWADDR),
    .D_AWLEN(D_AWLEN),
    .D_AWSIZE(D_AWSIZE),
    .D_AWBURST(D_AWBURST),
    .D_AWCACHE(D_AWCACHE),
    .D_AWPROT(D_AWPROT),
    .D_AWVALID(D_AWVALID),
    .D_AWREADY(D_AWREADY),
    .D_WDATA(D_WDATA),
    .D_WSTRB(D_WSTRB),
    .D_WLAST(D_WLAST),
    .D_WVALID(D_WVALID),
    .D_WREADY(D_WREADY),
    .D_BRESP(D_BRESP),
    .D_BVALID(D_BVALID),
    .D_BREADY(D_BREADY),
    .D_ARADDR(D_ARADDR),
    .D_ARLEN(D_ARLEN),
    .D_ARSIZE(D_ARSIZE),
    .D_ARBURST(D_ARBURST),
    .D_ARCACHE(D_ARCACHE),
    .D_ARPROT(D_ARPROT),
    .D_ARVALID(D_ARVALID),
    .D_ARREADY(D_ARREADY),
    .D_RDATA(D_RDATA),
    .D_RRESP(D_RRESP),
    .D_RLAST(D_RLAST),
    .D_RVALID(D_RVALID),
    .D_RREADY(D_RREADY),
    .oOpcode(oOpcode),
    .oTargetID(oTargetID),
    .oSourceID(oSourceID),
    .oAddress(oAddress),
    .oLength(oLength),
    .oCMDValid(oCMDValid),
    .iCMDReady(iCMDReady),
    .oWriteData(oWriteData),
    .oWriteLast(oWriteLast),
    .oWriteValid(oWriteValid),
    .iWriteReady(iWriteReady),
    .iReadData(iReadData),
    .iReadLast(iReadLast),
    .iReadValid(iReadValid),
    .oReadReady(oReadReady),
    .iReadyBusy(iReadyBusy),
    .oROMClock(oROMClock),
    .oROMReset(oROMReset),
    .oROMAddr(oROMAddr),
    .oROMRW(oROMRW),
    .oROMEnable(oROMEnable),
    .oROMWData(oROMWData),
    .iROMRData(iROMRData),
    .iSharedKESReady(iSharedKESReady),
    .oErrorDetectionEnd(oErrorDetectionEnd),
    .oDecodeNeeded(oDecodeNeeded),
    .oSyndromes(oSyndromes),
    .iIntraSharedKESEnd(iIntraSharedKESEnd),
    .iErroredChunk(iErroredChunk),
    .iCorrectionFail(iCorrectionFail),
    .iErrorCount(iErrorCount),
    .iELPCoefficients(iELPCoefficients),
    .oCSAvailable(oCSAvailable),
    .O_DEBUG(O_DEBUG)
  );
endmodule

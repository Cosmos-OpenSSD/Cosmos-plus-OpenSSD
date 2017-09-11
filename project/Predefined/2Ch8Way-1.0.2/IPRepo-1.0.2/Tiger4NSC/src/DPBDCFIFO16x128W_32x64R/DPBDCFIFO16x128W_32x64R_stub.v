// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2014.4 (win64) Build 1071353 Tue Nov 18 18:29:27 MST 2014
// Date        : Wed Apr 05 15:09:04 2017
// Host        : DESKTOP-24JKT5C running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Cosmos-plus-OpenSSD-master/Cosmos-plus-OpenSSD-master/Source/IPRepo/IPRepo-1.0.0/Tiger4NSC/src/DPBDCFIFO16x128W_32x64R/DPBDCFIFO16x128W_32x64R_stub.v
// Design      : DPBDCFIFO16x128W_32x64R
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z045ffg900-3
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v12_0,Vivado 2014.4" *)
module DPBDCFIFO16x128W_32x64R(rst, wr_clk, rd_clk, din, wr_en, rd_en, dout, full, empty, wr_data_count)
/* synthesis syn_black_box black_box_pad_pin="rst,wr_clk,rd_clk,din[15:0],wr_en,rd_en,dout[31:0],full,empty,wr_data_count[6:0]" */;
  input rst;
  input wr_clk;
  input rd_clk;
  input [15:0]din;
  input wr_en;
  input rd_en;
  output [31:0]dout;
  output full;
  output empty;
  output [6:0]wr_data_count;
endmodule

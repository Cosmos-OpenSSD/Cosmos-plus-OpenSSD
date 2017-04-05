
/*
----------------------------------------------------------------------------------
Copyright (c) 2013-2014

  Embedded and Network Computing Lab.
  Open SSD Project
  Hanyang University

All rights reserved.

----------------------------------------------------------------------------------

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

  1. Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in the
     documentation and/or other materials provided with the distribution.

  3. All advertising materials mentioning features or use of this source code
     must display the following acknowledgement:
     This product includes source code developed 
     by the Embedded and Network Computing Lab. and the Open SSD Project.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

----------------------------------------------------------------------------------

http://enclab.hanyang.ac.kr/
http://www.openssd-project.org/
http://www.hanyang.ac.kr/

----------------------------------------------------------------------------------
*/


`timescale 1ns / 1ps


module pcie_rx # (
	parameter	C_PCIE_DATA_WIDTH			= 128
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,

//pcie rx signal
	input	[C_PCIE_DATA_WIDTH-1:0]			s_axis_rx_tdata,
	input	[(C_PCIE_DATA_WIDTH/8)-1:0]		s_axis_rx_tkeep,
	input									s_axis_rx_tlast,
	input									s_axis_rx_tvalid,
	output									s_axis_rx_tready,
	input	[21:0]							s_axis_rx_tuser,

	output									pcie_mreq_err,
	output									pcie_cpld_err,
	output									pcie_cpld_len_err,

	output									mreq_fifo_wr_en,
	output	[C_PCIE_DATA_WIDTH-1:0]			mreq_fifo_wr_data,

	output	[7:0]							cpld0_fifo_tag,
	output									cpld0_fifo_tag_last,
	output									cpld0_fifo_wr_en,
	output	[C_PCIE_DATA_WIDTH-1:0]			cpld0_fifo_wr_data,

	output	[7:0]							cpld1_fifo_tag,
	output									cpld1_fifo_tag_last,
	output									cpld1_fifo_wr_en,
	output	[C_PCIE_DATA_WIDTH-1:0]			cpld1_fifo_wr_data,

	output	[7:0]							cpld2_fifo_tag,
	output									cpld2_fifo_tag_last,
	output									cpld2_fifo_wr_en,
	output	[C_PCIE_DATA_WIDTH-1:0]			cpld2_fifo_wr_data
);


wire	[7:0]								w_cpld_fifo_tag;
wire										w_cpld_fifo_tag_last;
wire										w_cpld_fifo_wr_en;
wire	[C_PCIE_DATA_WIDTH-1:0]				w_cpld_fifo_wr_data;



pcie_rx_recv # (
	.C_PCIE_DATA_WIDTH						(C_PCIE_DATA_WIDTH)
)
pcie_rx_recv_inst0(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

//pcie rx signal
	.s_axis_rx_tdata						(s_axis_rx_tdata),
	.s_axis_rx_tkeep						(s_axis_rx_tkeep),
	.s_axis_rx_tlast						(s_axis_rx_tlast),
	.s_axis_rx_tvalid						(s_axis_rx_tvalid),
	.s_axis_rx_tready						(s_axis_rx_tready),
	.s_axis_rx_tuser						(s_axis_rx_tuser),

	.pcie_mreq_err							(pcie_mreq_err),
	.pcie_cpld_err							(pcie_cpld_err),
	.pcie_cpld_len_err						(pcie_cpld_len_err),

	.mreq_fifo_wr_en						(mreq_fifo_wr_en),
	.mreq_fifo_wr_data						(mreq_fifo_wr_data),

	.cpld_fifo_tag							(w_cpld_fifo_tag),
	.cpld_fifo_tag_last						(w_cpld_fifo_tag_last),
	.cpld_fifo_wr_en						(w_cpld_fifo_wr_en),
	.cpld_fifo_wr_data						(w_cpld_fifo_wr_data)

);

pcie_rx_cpld_sel 
pcie_rx_cpld_sel_inst0(
	.pcie_user_clk							(pcie_user_clk),

	.cpld_fifo_tag							(w_cpld_fifo_tag),
	.cpld_fifo_tag_last						(w_cpld_fifo_tag_last),
	.cpld_fifo_wr_en						(w_cpld_fifo_wr_en),
	.cpld_fifo_wr_data						(w_cpld_fifo_wr_data),

	.cpld0_fifo_tag							(cpld0_fifo_tag),
	.cpld0_fifo_tag_last					(cpld0_fifo_tag_last),
	.cpld0_fifo_wr_en						(cpld0_fifo_wr_en),
	.cpld0_fifo_wr_data						(cpld0_fifo_wr_data),

	.cpld1_fifo_tag							(cpld1_fifo_tag),
	.cpld1_fifo_tag_last					(cpld1_fifo_tag_last),
	.cpld1_fifo_wr_en						(cpld1_fifo_wr_en),
	.cpld1_fifo_wr_data						(cpld1_fifo_wr_data),

	.cpld2_fifo_tag							(cpld2_fifo_tag),
	.cpld2_fifo_tag_last					(cpld2_fifo_tag_last),
	.cpld2_fifo_wr_en						(cpld2_fifo_wr_en),
	.cpld2_fifo_wr_data						(cpld2_fifo_wr_data)
);

endmodule
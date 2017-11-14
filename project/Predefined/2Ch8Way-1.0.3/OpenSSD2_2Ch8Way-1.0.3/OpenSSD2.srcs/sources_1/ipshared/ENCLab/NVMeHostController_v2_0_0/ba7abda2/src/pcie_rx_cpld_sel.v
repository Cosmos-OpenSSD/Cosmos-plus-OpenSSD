
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


module pcie_rx_cpld_sel# (
	parameter	C_PCIE_DATA_WIDTH			= 128
)
(
	input									pcie_user_clk,

	input									cpld_fifo_wr_en,
	input	[C_PCIE_DATA_WIDTH-1:0]			cpld_fifo_wr_data,
	input	[7:0]							cpld_fifo_tag,
	input									cpld_fifo_tag_last,

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

reg		[7:0]								r_cpld_fifo_tag;
reg		[C_PCIE_DATA_WIDTH-1:0]				r_cpld_fifo_wr_data;

reg											r_cpld0_fifo_tag_last;
reg											r_cpld0_fifo_wr_en;

reg											r_cpld1_fifo_tag_last;
reg											r_cpld1_fifo_wr_en;

reg											r_cpld2_fifo_tag_last;
reg											r_cpld2_fifo_wr_en;

wire	[2:0]								w_cpld_prefix_tag_hit;


assign w_cpld_prefix_tag_hit[0] = (cpld_fifo_tag[7:3] == 5'b00000);
assign w_cpld_prefix_tag_hit[1] = (cpld_fifo_tag[7:3] == 5'b00001);
assign w_cpld_prefix_tag_hit[2] = (cpld_fifo_tag[7:4] == 4'b0001);

assign cpld0_fifo_tag = r_cpld_fifo_tag;
assign cpld0_fifo_tag_last = r_cpld0_fifo_tag_last;
assign cpld0_fifo_wr_en = r_cpld0_fifo_wr_en;
assign cpld0_fifo_wr_data = r_cpld_fifo_wr_data;

assign cpld1_fifo_tag = r_cpld_fifo_tag;
assign cpld1_fifo_tag_last = r_cpld1_fifo_tag_last;
assign cpld1_fifo_wr_en = r_cpld1_fifo_wr_en;
assign cpld1_fifo_wr_data = r_cpld_fifo_wr_data;

assign cpld2_fifo_tag = r_cpld_fifo_tag;
assign cpld2_fifo_tag_last = r_cpld2_fifo_tag_last;
assign cpld2_fifo_wr_en = r_cpld2_fifo_wr_en;
assign cpld2_fifo_wr_data = r_cpld_fifo_wr_data;

always @(posedge pcie_user_clk)
begin
	r_cpld_fifo_tag <= cpld_fifo_tag;
	r_cpld_fifo_wr_data <= cpld_fifo_wr_data;

	r_cpld0_fifo_tag_last = cpld_fifo_tag_last & w_cpld_prefix_tag_hit[0];
	r_cpld0_fifo_wr_en <= cpld_fifo_wr_en & w_cpld_prefix_tag_hit[0];

	r_cpld1_fifo_tag_last = cpld_fifo_tag_last & w_cpld_prefix_tag_hit[1];
	r_cpld1_fifo_wr_en <= cpld_fifo_wr_en & w_cpld_prefix_tag_hit[1];

	r_cpld2_fifo_tag_last = cpld_fifo_tag_last & w_cpld_prefix_tag_hit[2];
	r_cpld2_fifo_wr_en <= cpld_fifo_wr_en & w_cpld_prefix_tag_hit[2];
end


endmodule
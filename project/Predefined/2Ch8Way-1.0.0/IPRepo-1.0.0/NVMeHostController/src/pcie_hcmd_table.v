
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

module pcie_hcmd_table # (
	parameter	P_DATA_WIDTH				= 128,
	parameter	P_ADDR_WIDTH				= 9
)
(
	input									wr_clk,

	input									wr_en,
	input	[P_ADDR_WIDTH-1:0]				wr_addr,
	input	[P_DATA_WIDTH-1:0]				wr_data,

	input									rd_clk,
	input	[P_ADDR_WIDTH+1:0]				rd_addr,
	output	[31:0]							rd_data
);

wire	[P_DATA_WIDTH-1:0]					w_rd_data;
reg		[31:0]								r_rd_data;

assign rd_data = r_rd_data;

always @ (*)
begin
	case(rd_addr[1:0]) // synthesis parallel_case full_case
		2'b00: r_rd_data <= w_rd_data[31:0];
		2'b01: r_rd_data <= w_rd_data[63:32];
		2'b10: r_rd_data <= w_rd_data[95:64];
		2'b11: r_rd_data <= w_rd_data[127:96];
	endcase
end

localparam LP_DEVICE = "7SERIES";
localparam LP_BRAM_SIZE = "36Kb";
localparam LP_DOB_REG = 0;
localparam LP_READ_WIDTH = P_DATA_WIDTH/2;
localparam LP_WRITE_WIDTH = P_DATA_WIDTH/2;
localparam LP_WRITE_MODE = "WRITE_FIRST";
localparam LP_WE_WIDTH = 8;
localparam LP_ADDR_TOTAL_WITDH = 9;
localparam LP_ADDR_ZERO_PAD_WITDH = LP_ADDR_TOTAL_WITDH - P_ADDR_WIDTH;

generate
	wire	[LP_ADDR_TOTAL_WITDH-1:0]			rdaddr;
	wire	[LP_ADDR_TOTAL_WITDH-1:0]			wraddr;
	wire	[LP_ADDR_ZERO_PAD_WITDH-1:0]		zero_padding = 0;

	if(LP_ADDR_ZERO_PAD_WITDH == 0) begin : CALC_ADDR
		assign rdaddr = rd_addr[P_ADDR_WIDTH+1:2];
		assign wraddr = wr_addr[P_ADDR_WIDTH-1:0];
	end
	else begin
		wire	[LP_ADDR_ZERO_PAD_WITDH-1:0]	zero_padding = 0;
		assign rdaddr = {zero_padding, rd_addr[P_ADDR_WIDTH+1:2]};
		assign wraddr = {zero_padding, wr_addr[P_ADDR_WIDTH-1:0]};
	end
endgenerate


BRAM_SDP_MACRO #(
	.DEVICE									(LP_DEVICE),
	.BRAM_SIZE								(LP_BRAM_SIZE),
	.DO_REG									(LP_DOB_REG),
	.READ_WIDTH								(LP_READ_WIDTH),
	.WRITE_WIDTH							(LP_WRITE_WIDTH),
	.WRITE_MODE								(LP_WRITE_MODE)
)
ramb36sdp_0(
	.DO										(w_rd_data[LP_READ_WIDTH-1:0]),
	.DI										(wr_data[LP_WRITE_WIDTH-1:0]),
	.RDADDR									(rdaddr),
	.RDCLK									(rd_clk),
	.RDEN									(1'b1),
	.REGCE									(1'b1),
	.RST									(1'b0),
	.WE										({LP_WE_WIDTH{1'b1}}),
	.WRADDR									(wraddr),
	.WRCLK									(wr_clk),
	.WREN									(wr_en)
);

BRAM_SDP_MACRO #(
	.DEVICE									(LP_DEVICE),
	.BRAM_SIZE								(LP_BRAM_SIZE),
	.DO_REG									(LP_DOB_REG),
	.READ_WIDTH								(LP_READ_WIDTH),
	.WRITE_WIDTH							(LP_WRITE_WIDTH),
	.WRITE_MODE								(LP_WRITE_MODE)
)
ramb36sdp_1(
	.DO										(w_rd_data[P_DATA_WIDTH-1:LP_READ_WIDTH]),
	.DI										(wr_data[P_DATA_WIDTH-1:LP_WRITE_WIDTH]),
	.RDADDR									(rdaddr),
	.RDCLK									(rd_clk),
	.RDEN									(1'b1),
	.REGCE									(1'b1),
	.RST									(1'b0),
	.WE										({LP_WE_WIDTH{1'b1}}),
	.WRADDR									(wraddr),
	.WRCLK									(wr_clk),
	.WREN									(wr_en)
);

endmodule

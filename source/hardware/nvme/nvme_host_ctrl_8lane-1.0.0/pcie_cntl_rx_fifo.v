
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

module pcie_cntl_rx_fifo # (
	parameter	P_FIFO_DATA_WIDTH			= 128,
	parameter	P_FIFO_DEPTH_WIDTH			= 5
)
(
	input									clk,
	input									rst_n,

	input									wr_en,
	input	[P_FIFO_DATA_WIDTH-1:0]			wr_data,
	output									full_n,
	output									almost_full_n,

	input									rd_en,
	output	[P_FIFO_DATA_WIDTH-1:0]			rd_data,
	output									empty_n
);

localparam P_FIFO_ALLOC_WIDTH				= 0;			//128 bits

reg		[P_FIFO_DEPTH_WIDTH:0]				r_front_addr;
reg		[P_FIFO_DEPTH_WIDTH:0]				r_front_addr_p1;
wire	[P_FIFO_DEPTH_WIDTH-1:0]			w_front_addr;

reg		[P_FIFO_DEPTH_WIDTH:0]				r_rear_addr;

reg											r_almost_full_n;
wire										w_almost_full_n;
wire	[P_FIFO_DEPTH_WIDTH:0]				w_invalid_space;
wire	[P_FIFO_DEPTH_WIDTH:0]				w_invalid_front_addr;

assign full_n = ~(( r_rear_addr[P_FIFO_DEPTH_WIDTH] ^ r_front_addr[P_FIFO_DEPTH_WIDTH])
					& (r_rear_addr[P_FIFO_DEPTH_WIDTH-1:P_FIFO_ALLOC_WIDTH] 
					== r_front_addr[P_FIFO_DEPTH_WIDTH-1:P_FIFO_ALLOC_WIDTH]));
assign almost_full_n = r_almost_full_n;

assign w_invalid_front_addr = {~r_front_addr[P_FIFO_DEPTH_WIDTH], r_front_addr[P_FIFO_DEPTH_WIDTH-1:P_FIFO_ALLOC_WIDTH]};
assign w_invalid_space = w_invalid_front_addr - r_rear_addr;
assign w_almost_full_n = (w_invalid_space > 8);

always @(posedge clk)
begin
	r_almost_full_n <= w_almost_full_n;
end

assign empty_n = ~(r_front_addr[P_FIFO_DEPTH_WIDTH:P_FIFO_ALLOC_WIDTH] 
				== r_rear_addr[P_FIFO_DEPTH_WIDTH:P_FIFO_ALLOC_WIDTH]);

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 0) begin
		r_front_addr <= 0;
		r_front_addr_p1 <= 1;
		r_rear_addr <= 0;
	end
	else begin
		if (rd_en == 1) begin
			r_front_addr <= r_front_addr_p1;
			r_front_addr_p1 <= r_front_addr_p1 + 1;
		end

		if (wr_en == 1) begin
			r_rear_addr  <= r_rear_addr + 1;
		end
	end
end

assign w_front_addr = (rd_en == 1) ? r_front_addr_p1[P_FIFO_DEPTH_WIDTH-1:0] 
								: r_front_addr[P_FIFO_DEPTH_WIDTH-1:0];


localparam LP_DEVICE = "7SERIES";
localparam LP_BRAM_SIZE = "36Kb";
localparam LP_DOB_REG = 0;
localparam LP_READ_WIDTH = P_FIFO_DATA_WIDTH/2;
localparam LP_WRITE_WIDTH = P_FIFO_DATA_WIDTH/2;
localparam LP_WRITE_MODE = "READ_FIRST";
localparam LP_WE_WIDTH = 8;
localparam LP_ADDR_TOTAL_WITDH = 9;
localparam LP_ADDR_ZERO_PAD_WITDH = LP_ADDR_TOTAL_WITDH - P_FIFO_DEPTH_WIDTH;


generate
	wire	[LP_ADDR_TOTAL_WITDH-1:0]			rdaddr;
	wire	[LP_ADDR_TOTAL_WITDH-1:0]			wraddr;
	wire	[LP_ADDR_ZERO_PAD_WITDH-1:0]		zero_padding = 0;

	if(LP_ADDR_ZERO_PAD_WITDH == 0) begin : calc_addr
		assign rdaddr = w_front_addr[P_FIFO_DEPTH_WIDTH-1:0];
		assign wraddr = r_rear_addr[P_FIFO_DEPTH_WIDTH-1:0];
	end
	else begin
		assign rdaddr = {zero_padding[LP_ADDR_ZERO_PAD_WITDH-1:0], w_front_addr[P_FIFO_DEPTH_WIDTH-1:0]};
		assign wraddr = {zero_padding[LP_ADDR_ZERO_PAD_WITDH-1:0], r_rear_addr[P_FIFO_DEPTH_WIDTH-1:0]};
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
	.DO										(rd_data[LP_READ_WIDTH-1:0]),
	.DI										(wr_data[LP_WRITE_WIDTH-1:0]),
	.RDADDR									(rdaddr),
	.RDCLK									(clk),
	.RDEN									(1'b1),
	.REGCE									(1'b1),
	.RST									(1'b0),
	.WE										({LP_WE_WIDTH{1'b1}}),
	.WRADDR									(wraddr),
	.WRCLK									(clk),
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
	.DO										(rd_data[P_FIFO_DATA_WIDTH-1:LP_READ_WIDTH]),
	.DI										(wr_data[P_FIFO_DATA_WIDTH-1:LP_WRITE_WIDTH]),
	.RDADDR									(rdaddr),
	.RDCLK									(clk),
	.RDEN									(1'b1),
	.REGCE									(1'b1),
	.RST									(1'b0),
	.WE										({LP_WE_WIDTH{1'b1}}),
	.WRADDR									(wraddr),
	.WRCLK									(clk),
	.WREN									(wr_en)
);

endmodule


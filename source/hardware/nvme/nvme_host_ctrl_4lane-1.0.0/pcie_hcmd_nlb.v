
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

module pcie_hcmd_nlb # (
	parameter	P_DATA_WIDTH				= 19,
	parameter	P_ADDR_WIDTH				= 7
)
(
	input									clk,
	input									rst_n,

	input									wr0_en,
	input	[P_ADDR_WIDTH-1:0]				wr0_addr,
	input	[P_DATA_WIDTH-1:0]				wr0_data,
	output									wr0_rdy_n,

	input									wr1_en,
	input	[P_ADDR_WIDTH-1:0]				wr1_addr,
	input	[P_DATA_WIDTH-1:0]				wr1_data,
	output									wr1_rdy_n,

	input	[P_ADDR_WIDTH-1:0]				rd_addr,
	output	[P_DATA_WIDTH-1:0]				rd_data
);


localparam	S_IDLE							= 2'b01;
localparam	S_WRITE							= 2'b10;

reg		[1:0]								cur_state;
reg		[1:0]								next_state;

reg											r_wr0_req;
reg											r_wr1_req;
reg											r_wr0_req_ack;
reg											r_wr1_req_ack;
reg		[1:0]								r_wr_gnt;
reg											r_wr_en;

reg		[P_ADDR_WIDTH-1:0]					r_wr_addr;
reg		[P_DATA_WIDTH-1:0]					r_wr_data;

reg		[P_ADDR_WIDTH-1:0]					r_wr0_addr;
reg		[P_DATA_WIDTH-1:0]					r_wr0_data;

reg		[P_ADDR_WIDTH-1:0]					r_wr1_addr;
reg		[P_DATA_WIDTH-1:0]					r_wr1_data;

assign wr0_rdy_n = r_wr0_req;
assign wr1_rdy_n = r_wr1_req | r_wr0_req;

always @(posedge clk)
begin
	if(wr0_en == 1) begin
		r_wr0_addr <= wr0_addr;
		r_wr0_data <= wr0_data;
	end

	if(wr1_en == 1) begin
		r_wr1_addr <= wr1_addr;
		r_wr1_data <= wr1_data;
	end
end

always @(posedge clk or negedge rst_n)
begin
	if (rst_n == 0) begin
		r_wr0_req <= 0;
		r_wr1_req <= 0;
	end
	else begin
		if(r_wr0_req_ack == 1)
			r_wr0_req <= 0;
		else if(wr0_en == 1)
			r_wr0_req <= 1;

		if(r_wr1_req_ack == 1)
			r_wr1_req <= 0;
		else if(wr1_en == 1)
			r_wr1_req <= 1;
	end
end


always @ (posedge clk or negedge rst_n)
begin
	if(rst_n == 0)
		cur_state <= S_IDLE;
	else
		cur_state <= next_state;
end

always @ (*)
begin
	case(cur_state)
		S_IDLE: begin
			if(r_wr0_req == 1 || r_wr1_req == 1)
				next_state <= S_WRITE;
			else
				next_state <= S_IDLE;
		end
		S_WRITE: begin
			next_state <= S_IDLE;
		end
		default: begin
			next_state <= S_IDLE;
		end
	endcase
end


always @ (posedge clk)
begin
	case(cur_state)
		S_IDLE: begin
			if(r_wr1_req == 1)
				r_wr_gnt <= 2'b10;
			else if(r_wr0_req == 1)
				r_wr_gnt <= 2'b01;
		end
		S_WRITE: begin

		end
		default: begin

		end
	endcase
end

always @ (*)
begin
	case(cur_state)
		S_IDLE: begin
			r_wr_en <= 0;
			r_wr0_req_ack <= 0;
			r_wr1_req_ack <= 0;
		end
		S_WRITE: begin
			r_wr_en <= 1;
			r_wr0_req_ack <= r_wr_gnt[0];
			r_wr1_req_ack <= r_wr_gnt[1];
		end
		default: begin
			r_wr_en <= 0;
			r_wr0_req_ack <= 0;
			r_wr1_req_ack <= 0;
		end
	endcase
end

always @ (*)
begin
	case(r_wr_gnt) // synthesis parallel_case full_case
		2'b01: begin
			r_wr_addr <= r_wr0_addr;
			r_wr_data <= r_wr0_data;
		end
		2'b10: begin
			r_wr_addr <= r_wr1_addr;
			r_wr_data <= r_wr1_data;
		end
	endcase
end


localparam LP_DEVICE = "7SERIES";
localparam LP_BRAM_SIZE = "18Kb";
localparam LP_DOB_REG = 0;
localparam LP_READ_WIDTH = P_DATA_WIDTH;
localparam LP_WRITE_WIDTH = P_DATA_WIDTH;
localparam LP_WRITE_MODE = "READ_FIRST";
localparam LP_WE_WIDTH = 4;
localparam LP_ADDR_TOTAL_WITDH = 9;
localparam LP_ADDR_ZERO_PAD_WITDH = LP_ADDR_TOTAL_WITDH - P_ADDR_WIDTH;


generate
	wire	[LP_ADDR_TOTAL_WITDH-1:0]			rdaddr;
	wire	[LP_ADDR_TOTAL_WITDH-1:0]			wraddr;
	wire	[LP_ADDR_ZERO_PAD_WITDH-1:0]		zero_padding = 0;

	if(LP_ADDR_ZERO_PAD_WITDH == 0) begin : calc_addr
		assign rdaddr = rd_addr[P_ADDR_WIDTH-1:0];
		assign wraddr = r_wr_addr[P_ADDR_WIDTH-1:0];
	end
	else begin
		assign rdaddr = {zero_padding[LP_ADDR_ZERO_PAD_WITDH-1:0], rd_addr[P_ADDR_WIDTH-1:0]};
		assign wraddr = {zero_padding[LP_ADDR_ZERO_PAD_WITDH-1:0], r_wr_addr[P_ADDR_WIDTH-1:0]};
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
ramb18sdp_0(
	.DO										(rd_data[LP_READ_WIDTH-1:0]),
	.DI										(r_wr_data[LP_WRITE_WIDTH-1:0]),
	.RDADDR									(rdaddr),
	.RDCLK									(clk),
	.RDEN									(1'b1),
	.REGCE									(1'b1),
	.RST									(1'b0),
	.WE										({LP_WE_WIDTH{1'b1}}),
	.WRADDR									(wraddr),
	.WRCLK									(clk),
	.WREN									(r_wr_en)
);


endmodule
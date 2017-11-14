
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

module dma_done_fifo # (
	parameter	P_FIFO_DATA_WIDTH			= 21,
	parameter	P_FIFO_DEPTH_WIDTH			= 4
)
(
	input									clk,
	input									rst_n,

	input									wr0_en,
	input	[P_FIFO_DATA_WIDTH-1:0]			wr0_data,
	output									wr0_rdy_n,

	output									full_n,

	input									rd_en,
	output	[P_FIFO_DATA_WIDTH-1:0]			rd_data,
	output									empty_n,

	input									wr1_clk,
	input									wr1_rst_n,

	input									wr1_en,
	input	[P_FIFO_DATA_WIDTH-1:0]			wr1_data,
	output									wr1_rdy_n
);

localparam P_FIFO_ALLOC_WIDTH				= 0;			//128 bits

localparam	S_IDLE							= 2'b01;
localparam	S_WRITE							= 2'b10;

reg		[1:0]								cur_state;
reg		[1:0]								next_state;

reg		[P_FIFO_DEPTH_WIDTH:0]				r_front_addr;
reg		[P_FIFO_DEPTH_WIDTH:0]				r_front_addr_p1;
wire	[P_FIFO_DEPTH_WIDTH-1:0]			w_front_addr;

reg		[P_FIFO_DEPTH_WIDTH:0]				r_rear_addr;

reg											r_wr0_req;
reg											r_wr1_req;
reg											r_wr0_req_ack;
reg											r_wr1_req_ack;
reg		[1:0]								r_wr_gnt;

wire										w_wr1_en;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_wr1_en;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_wr1_en_d1;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_wr1_en_d2;

reg											r_wr1_en_sync;
reg											r_wr1_en_sync_d1;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_wr1_rdy_n_sync;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_wr1_rdy_n_sync_d1;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_wr1_rdy_n_sync_d2;
reg											r_wr1_rdy_n;
reg		[P_FIFO_DATA_WIDTH-1:0]				r_wr1_data_sync;


reg											r_wr_en;
reg		[P_FIFO_DATA_WIDTH-1:0]				r_wr_data;
reg		[P_FIFO_DATA_WIDTH-1:0]				r_wr0_data;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[P_FIFO_DATA_WIDTH-1:0]				r_wr1_data;



assign wr0_rdy_n = r_wr0_req;
assign wr1_rdy_n = r_wr1_rdy_n;

always @(posedge wr1_clk)
begin
	r_wr1_en_sync_d1 <= wr1_en;
	r_wr1_en_sync <= r_wr1_en_sync_d1 | wr1_en;

	if(wr1_en == 1) begin
		r_wr1_data_sync <= wr1_data;
	end

	r_wr1_rdy_n_sync <= r_wr1_req;
	r_wr1_rdy_n_sync_d1 <= r_wr1_rdy_n_sync;
	r_wr1_rdy_n_sync_d2 <= r_wr1_rdy_n_sync_d1;
end

always @(posedge wr1_clk or negedge wr1_rst_n)
begin
	if(wr1_rst_n == 0) begin
		r_wr1_rdy_n <= 0;
	end
	else begin
		if(wr1_en == 1)
			r_wr1_rdy_n <= 1;
		else if(r_wr1_rdy_n_sync_d1 == 0 && r_wr1_rdy_n_sync_d2 == 1)
			r_wr1_rdy_n <= 0;
	end
end

assign w_wr1_en = r_wr1_en_d1 & ~r_wr1_en_d2;
always @(posedge clk)
begin
	if(wr0_en == 1) begin
		r_wr0_data <= wr0_data;
	end

	r_wr1_en <= r_wr1_en_sync;
	r_wr1_en_d1 <= r_wr1_en;
	r_wr1_en_d2 <= r_wr1_en_d1;

	if(w_wr1_en == 1) begin
		r_wr1_data <= r_wr1_data_sync;
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
		else if(w_wr1_en == 1)
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
			if((r_wr0_req == 1 || r_wr1_req == 1) && (full_n == 1))
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
			if(r_wr0_req == 1)
				r_wr_gnt <= 2'b01;
			else if(r_wr1_req == 1)
				r_wr_gnt <= 2'b10;
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
		2'b01: r_wr_data <= r_wr0_data;
		2'b10: r_wr_data <= r_wr1_data;
	endcase
end

assign full_n = ~((r_rear_addr[P_FIFO_DEPTH_WIDTH] ^ r_front_addr[P_FIFO_DEPTH_WIDTH])
					& (r_rear_addr[P_FIFO_DEPTH_WIDTH-1:P_FIFO_ALLOC_WIDTH] 
					== r_front_addr[P_FIFO_DEPTH_WIDTH-1:P_FIFO_ALLOC_WIDTH]));

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

		if (r_wr_en == 1) begin
			r_rear_addr  <= r_rear_addr + 1;
		end
	end
end

assign w_front_addr = (rd_en == 1) ? r_front_addr_p1[P_FIFO_DEPTH_WIDTH-1:0] 
								: r_front_addr[P_FIFO_DEPTH_WIDTH-1:0];


localparam LP_DEVICE = "7SERIES";
localparam LP_BRAM_SIZE = "18Kb";
localparam LP_DOB_REG = 0;
localparam LP_READ_WIDTH = P_FIFO_DATA_WIDTH;
localparam LP_WRITE_WIDTH = P_FIFO_DATA_WIDTH;
localparam LP_WRITE_MODE = "READ_FIRST";
localparam LP_WE_WIDTH = 4;
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

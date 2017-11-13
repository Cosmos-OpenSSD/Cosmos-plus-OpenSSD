
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

module pcie_rx_fifo # (
	parameter	P_FIFO_WR_DATA_WIDTH		= 128,
	parameter	P_FIFO_RD_DATA_WIDTH		= 64,
	parameter	P_FIFO_DEPTH_WIDTH			= 9
)
(
	input									wr_clk,
	input									wr_rst_n,

	input									wr_en,
	input	[P_FIFO_DEPTH_WIDTH-1:0]		wr_addr,
	input	[P_FIFO_WR_DATA_WIDTH-1:0]		wr_data,
	input	[P_FIFO_DEPTH_WIDTH:0]			rear_full_addr,
	input	[P_FIFO_DEPTH_WIDTH:0]			rear_addr,
	input	[9:4]							alloc_len,
	output									full_n,

	input									rd_clk,
	input									rd_rst_n,

	input									rd_en,
	output	[P_FIFO_RD_DATA_WIDTH-1:0]		rd_data,
	input									free_en,
	input	[9:4]							free_len,
	output									empty_n
);


localparam P_FIFO_RD_DEPTH_WIDTH = P_FIFO_DEPTH_WIDTH + 1;

localparam	S_SYNC_STAGE0					= 3'b001;
localparam	S_SYNC_STAGE1					= 3'b010;
localparam	S_SYNC_STAGE2					= 3'b100;

reg		[2:0]								cur_wr_state;
reg		[2:0]								next_wr_state;

reg		[2:0]								cur_rd_state;
reg		[2:0]								next_rd_state;

(* KEEP = "TRUE", EQUIVALENT_REGISTER_REMOVAL = "NO" *)	reg											r_rear_sync;
(* KEEP = "TRUE", EQUIVALENT_REGISTER_REMOVAL = "NO" *)	reg											r_rear_sync_en;
reg		[P_FIFO_DEPTH_WIDTH:0]				r_rear_sync_data;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_front_sync_en_d1;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_front_sync_en_d2;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[P_FIFO_DEPTH_WIDTH:0]				r_front_sync_addr;

reg		[P_FIFO_RD_DEPTH_WIDTH:0]			r_front_addr;
reg		[P_FIFO_RD_DEPTH_WIDTH:0]			r_front_addr_p1;
reg		[P_FIFO_DEPTH_WIDTH:0]				r_front_empty_addr;
(* KEEP = "TRUE", EQUIVALENT_REGISTER_REMOVAL = "NO" *)	reg											r_front_sync;
(* KEEP = "TRUE", EQUIVALENT_REGISTER_REMOVAL = "NO" *)	reg											r_front_sync_en	;
reg		[P_FIFO_DEPTH_WIDTH:0]				r_front_sync_data;

(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_rear_sync_en_d1;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_rear_sync_en_d2;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[P_FIFO_DEPTH_WIDTH:0]				r_rear_sync_addr;

wire	[(P_FIFO_RD_DATA_WIDTH*2)-1:0]		w_bram_rd_data;
wire	[P_FIFO_RD_DATA_WIDTH-1:0]			w_rd_data;
wire	[P_FIFO_DEPTH_WIDTH-1:0]			w_front_addr;

wire	[P_FIFO_DEPTH_WIDTH:0]				w_valid_space;
wire	[P_FIFO_DEPTH_WIDTH:0]				w_invalid_space;

assign rd_data = w_rd_data;

assign w_invalid_space = r_front_sync_addr - rear_full_addr;
assign full_n = (w_invalid_space >= alloc_len);

assign w_valid_space = r_rear_sync_addr - r_front_empty_addr;
assign empty_n = (w_valid_space >= free_len);

always @(posedge rd_clk or negedge rd_rst_n)
begin
	if (rd_rst_n == 0) begin
		r_front_addr <= 0;
		r_front_addr_p1 <= 1;
		r_front_empty_addr <= 0;
	end
	else begin
		if (rd_en == 1) begin
			r_front_addr <= r_front_addr_p1;
			r_front_addr_p1 <= r_front_addr_p1 + 1;
		end
		if (free_en == 1)
			r_front_empty_addr <= r_front_empty_addr + free_len;
	end
end

assign w_front_addr = (rd_en == 1) ? r_front_addr_p1[P_FIFO_RD_DEPTH_WIDTH-1:1] 
								: r_front_addr[P_FIFO_RD_DEPTH_WIDTH-1:1];

assign w_rd_data = (r_front_addr[0] == 0) ? w_bram_rd_data[P_FIFO_RD_DATA_WIDTH-1:0] 
								: w_bram_rd_data[(P_FIFO_RD_DATA_WIDTH*2)-1:P_FIFO_RD_DATA_WIDTH];

/////////////////////////////////////////////////////////////////////////////////////////////



always @ (posedge wr_clk or negedge wr_rst_n)
begin
	if(wr_rst_n == 0)
		cur_wr_state <= S_SYNC_STAGE0;
	else
		cur_wr_state <= next_wr_state;
end

always @(posedge wr_clk or negedge wr_rst_n)
begin
	if(wr_rst_n == 0)
		r_rear_sync_en <= 0;
	else
		r_rear_sync_en <= r_rear_sync;
end

always @(posedge wr_clk)
begin
	r_front_sync_en_d1 <= r_front_sync_en;
	r_front_sync_en_d2 <= r_front_sync_en_d1;
end

always @ (*)
begin
	case(cur_wr_state)
		S_SYNC_STAGE0: begin
			if(r_front_sync_en_d2 == 1)
				next_wr_state <= S_SYNC_STAGE1;
			else
				next_wr_state <= S_SYNC_STAGE0;
		end
		S_SYNC_STAGE1: begin
			next_wr_state <= S_SYNC_STAGE2;
		end
		S_SYNC_STAGE2: begin
			if(r_front_sync_en_d2 == 0)
				next_wr_state <= S_SYNC_STAGE0;
			else
				next_wr_state <= S_SYNC_STAGE2;
		end
		default: begin
			next_wr_state <= S_SYNC_STAGE0;
		end
	endcase
end

always @ (posedge wr_clk or negedge wr_rst_n)
begin
	if(wr_rst_n == 0) begin
		r_rear_sync_data <= 0;
		r_front_sync_addr[P_FIFO_DEPTH_WIDTH] <= 1;
		r_front_sync_addr[P_FIFO_DEPTH_WIDTH-1:0] <= 0;
	end
	else begin
		case(cur_wr_state)
			S_SYNC_STAGE0: begin

			end
			S_SYNC_STAGE1: begin
				r_rear_sync_data <= rear_addr;
				r_front_sync_addr <= r_front_sync_data;
			end
			S_SYNC_STAGE2: begin

			end
			default: begin

			end
		endcase
	end
end

always @ (*)
begin
	case(cur_wr_state)
		S_SYNC_STAGE0: begin
			r_rear_sync <= 0;
		end
		S_SYNC_STAGE1: begin
			r_rear_sync <= 0;
		end
		S_SYNC_STAGE2: begin
			r_rear_sync <= 1;
		end
		default: begin
			r_rear_sync <= 0;
		end
	endcase
end


always @ (posedge rd_clk or negedge rd_rst_n)
begin
	if(rd_rst_n == 0)
		cur_rd_state <= S_SYNC_STAGE0;
	else
		cur_rd_state <= next_rd_state;
end

always @(posedge rd_clk or negedge rd_rst_n)
begin
	if(rd_rst_n == 0)
		r_front_sync_en <= 0;
	else
		r_front_sync_en <= r_front_sync;
end

always @(posedge rd_clk)
begin
	r_rear_sync_en_d1 <= r_rear_sync_en;
	r_rear_sync_en_d2 <= r_rear_sync_en_d1;
end

always @ (*)
begin
	case(cur_rd_state)
		S_SYNC_STAGE0: begin
			if(r_rear_sync_en_d2 == 1)
				next_rd_state <= S_SYNC_STAGE1;
			else
				next_rd_state <= S_SYNC_STAGE0;
		end
		S_SYNC_STAGE1: begin
			next_rd_state <= S_SYNC_STAGE2;
		end
		S_SYNC_STAGE2: begin
			if(r_rear_sync_en_d2 == 0)
				next_rd_state <= S_SYNC_STAGE0;
			else
				next_rd_state <= S_SYNC_STAGE2;
		end
		default: begin
			next_rd_state <= S_SYNC_STAGE0;
		end
	endcase
end

always @ (posedge rd_clk or negedge rd_rst_n)
begin
	if(rd_rst_n == 0) begin
		r_front_sync_data[P_FIFO_DEPTH_WIDTH] <= 1;
		r_front_sync_data[P_FIFO_DEPTH_WIDTH-1:0] <= 0;
		r_rear_sync_addr <= 0;
	end
	else begin
		case(cur_rd_state)
			S_SYNC_STAGE0: begin

			end
			S_SYNC_STAGE1: begin
				r_front_sync_data[P_FIFO_DEPTH_WIDTH] <= ~r_front_addr[P_FIFO_RD_DEPTH_WIDTH];
				r_front_sync_data[P_FIFO_DEPTH_WIDTH-1:0] <= r_front_addr[P_FIFO_RD_DEPTH_WIDTH-1:1];
				r_rear_sync_addr <= r_rear_sync_data;
			end
			S_SYNC_STAGE2: begin

			end
			default: begin

			end
		endcase
	end
end

always @ (*)
begin
	case(cur_rd_state)
		S_SYNC_STAGE0: begin
			r_front_sync <= 1;
		end
		S_SYNC_STAGE1: begin
			r_front_sync <= 1;
		end
		S_SYNC_STAGE2: begin
			r_front_sync <= 0;
		end
		default: begin
			r_front_sync <= 0;
		end
	endcase
end


/////////////////////////////////////////////////////////////////////////////////////////////

localparam LP_DEVICE = "7SERIES";
localparam LP_BRAM_SIZE = "36Kb";
localparam LP_DOB_REG = 0;
localparam LP_READ_WIDTH = P_FIFO_RD_DATA_WIDTH;
localparam LP_WRITE_WIDTH = P_FIFO_WR_DATA_WIDTH/2;
localparam LP_WRITE_MODE = "WRITE_FIRST";
localparam LP_WE_WIDTH = 8;
localparam LP_ADDR_TOTAL_WITDH = 9;
localparam LP_ADDR_ZERO_PAD_WITDH = LP_ADDR_TOTAL_WITDH - P_FIFO_DEPTH_WIDTH;


generate
	wire	[LP_ADDR_TOTAL_WITDH-1:0]			rdaddr;
	wire	[LP_ADDR_TOTAL_WITDH-1:0]			wraddr;
	wire	[LP_ADDR_ZERO_PAD_WITDH-1:0]		zero_padding = 0;

	if(LP_ADDR_ZERO_PAD_WITDH == 0) begin : calc_addr
		assign rdaddr = w_front_addr[P_FIFO_DEPTH_WIDTH-1:0];
		assign wraddr = wr_addr[P_FIFO_DEPTH_WIDTH-1:0];
	end
	else begin
		assign rdaddr = {zero_padding[LP_ADDR_ZERO_PAD_WITDH-1:0], w_front_addr[P_FIFO_DEPTH_WIDTH-1:0]};
		assign wraddr = {zero_padding[LP_ADDR_ZERO_PAD_WITDH-1:0], wr_addr[P_FIFO_DEPTH_WIDTH-1:0]};
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
	.DO										(w_bram_rd_data[LP_READ_WIDTH-1:0]),
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
	.DO										(w_bram_rd_data[(P_FIFO_RD_DATA_WIDTH*2)-1:LP_READ_WIDTH]),
	.DI										(wr_data[P_FIFO_WR_DATA_WIDTH-1:LP_WRITE_WIDTH]),
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

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

module pcie_rx_req # (
	parameter	P_PCIE_DATA_WIDTH			= 128,
	parameter	C_PCIE_ADDR_WIDTH			= 36
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,

	input	[2:0]							pcie_max_read_req_size,

	output									pcie_rx_cmd_rd_en,
	input	[33:0]							pcie_rx_cmd_rd_data,
	input									pcie_rx_cmd_empty_n,

	output									pcie_tag_alloc,
	output	[7:0]							pcie_alloc_tag,
	output	[9:4]							pcie_tag_alloc_len,
	input									pcie_tag_full_n,
	input									pcie_rx_fifo_full_n,

	output									tx_dma_mrd_req,
	output	[7:0]							tx_dma_mrd_tag,
	output	[11:2]							tx_dma_mrd_len,
	output	[C_PCIE_ADDR_WIDTH-1:2]			tx_dma_mrd_addr,
	input									tx_dma_mrd_req_ack
);

localparam	LP_PCIE_TAG_PREFIX				= 4'b0001;
localparam	LP_PCIE_MRD_DELAY				= 8;

localparam	S_IDLE							= 9'b000000001;
localparam	S_PCIE_RX_CMD_0					= 9'b000000010;
localparam	S_PCIE_RX_CMD_1					= 9'b000000100;
localparam	S_PCIE_CHK_NUM_MRD				= 9'b000001000;
localparam	S_PCIE_MRD_REQ					= 9'b000010000;
localparam	S_PCIE_MRD_ACK					= 9'b000100000;
localparam	S_PCIE_MRD_DONE					= 9'b001000000;
localparam	S_PCIE_MRD_DELAY				= 9'b010000000;
localparam	S_PCIE_MRD_NEXT					= 9'b100000000;


reg		[8:0]								cur_state;
reg		[8:0]								next_state;

reg		[2:0]								r_pcie_max_read_req_size;

reg											r_pcie_rx_cmd_rd_en;

reg		[12:2]								r_pcie_rx_len;
reg		[9:2]								r_pcie_rx_cur_len;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_pcie_addr;
reg		[3:0]								r_pcie_rx_tag;
reg											r_pcie_rx_tag_update;
reg		[5:0]								r_pcie_mrd_delay;

reg											r_pcie_tag_alloc;
reg											r_tx_dma_mrd_req;

assign pcie_rx_cmd_rd_en = r_pcie_rx_cmd_rd_en;

assign pcie_tag_alloc = r_pcie_tag_alloc;
assign pcie_alloc_tag = {LP_PCIE_TAG_PREFIX, r_pcie_rx_tag};
assign pcie_tag_alloc_len = r_pcie_rx_cur_len[9:4];

assign tx_dma_mrd_req = r_tx_dma_mrd_req;
assign tx_dma_mrd_tag = {LP_PCIE_TAG_PREFIX, r_pcie_rx_tag};
assign tx_dma_mrd_len = {2'b0, r_pcie_rx_cur_len};
assign tx_dma_mrd_addr = r_pcie_addr;

always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0)
		cur_state <= S_IDLE;
	else
		cur_state <= next_state;
end

always @ (*)
begin
	case(cur_state)
		S_IDLE: begin
			if(pcie_rx_cmd_empty_n == 1)
				next_state <= S_PCIE_RX_CMD_0;
			else
				next_state <= S_IDLE;
		end
		S_PCIE_RX_CMD_0: begin
			next_state <= S_PCIE_RX_CMD_1;
		end
		S_PCIE_RX_CMD_1: begin
			next_state <= S_PCIE_CHK_NUM_MRD;
		end
		S_PCIE_CHK_NUM_MRD: begin
			if(pcie_rx_fifo_full_n == 1 && pcie_tag_full_n == 1)
				next_state <= S_PCIE_MRD_REQ;
			else
				next_state <= S_PCIE_CHK_NUM_MRD;
		end
		S_PCIE_MRD_REQ: begin
			next_state <= S_PCIE_MRD_ACK;
		end
		S_PCIE_MRD_ACK: begin
			if(tx_dma_mrd_req_ack == 1)
				next_state <= S_PCIE_MRD_DONE;
			else
				next_state <= S_PCIE_MRD_ACK;
		end
		S_PCIE_MRD_DONE: begin
			next_state <= S_PCIE_MRD_DELAY;
		end
		S_PCIE_MRD_DELAY: begin
			if(r_pcie_mrd_delay == 0)
				next_state <= S_PCIE_MRD_NEXT;
			else
				next_state <= S_PCIE_MRD_DELAY;
		end
		S_PCIE_MRD_NEXT: begin
			if(r_pcie_rx_len == 0)
				next_state <= S_IDLE;
			else
				next_state <= S_PCIE_CHK_NUM_MRD;
		end
		default: begin
			next_state <= S_IDLE;
		end
	endcase
end


always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0) begin
		r_pcie_rx_tag <= 0;
	end
	else begin
		if(r_pcie_rx_tag_update == 1)
			r_pcie_rx_tag <= r_pcie_rx_tag + 1;
	end
end

always @ (posedge pcie_user_clk)
begin
	r_pcie_max_read_req_size <= pcie_max_read_req_size;
end

always @ (posedge pcie_user_clk)
begin
	case(cur_state)
		S_IDLE: begin

		end
		S_PCIE_RX_CMD_0: begin
			r_pcie_rx_len <= {pcie_rx_cmd_rd_data[10:2], 2'b0};
		end
		S_PCIE_RX_CMD_1: begin
			case(r_pcie_max_read_req_size)
				3'b010: begin
					if(r_pcie_rx_len[8:7] == 0 && r_pcie_rx_len[6:2] == 0)
						r_pcie_rx_cur_len[9:7] <= 3'b100;
					else
						r_pcie_rx_cur_len[9:7] <= {1'b0, r_pcie_rx_len[8:7]};
				end
				3'b001: begin
					if(r_pcie_rx_len[7] == 0 && r_pcie_rx_len[6:2] == 0)
						r_pcie_rx_cur_len[9:7] <= 3'b010;
					else
						r_pcie_rx_cur_len[9:7] <= {2'b0, r_pcie_rx_len[7]};
				end
				default: begin
					if(r_pcie_rx_len[6:2] == 0)
						r_pcie_rx_cur_len[9:7] <= 3'b001;
					else
						r_pcie_rx_cur_len[9:7] <= 3'b000;
				end
			endcase

			r_pcie_rx_cur_len[6:2] <= r_pcie_rx_len[6:2];
			r_pcie_addr <= {pcie_rx_cmd_rd_data[33:2], 2'b0};
		end
		S_PCIE_CHK_NUM_MRD: begin

		end
		S_PCIE_MRD_REQ: begin

		end
		S_PCIE_MRD_ACK: begin

		end
		S_PCIE_MRD_DONE: begin
			r_pcie_addr <= r_pcie_addr + r_pcie_rx_cur_len;
			r_pcie_rx_len <= r_pcie_rx_len - r_pcie_rx_cur_len;

			case(r_pcie_max_read_req_size)
				3'b010: r_pcie_rx_cur_len <= 8'h80;
				3'b001: r_pcie_rx_cur_len <= 8'h40;
				default: r_pcie_rx_cur_len <= 8'h20;
			endcase
			
			r_pcie_mrd_delay <= LP_PCIE_MRD_DELAY;
		end
		S_PCIE_MRD_DELAY: begin
			r_pcie_mrd_delay <= r_pcie_mrd_delay - 1'b1;
		end
		S_PCIE_MRD_NEXT: begin

		end
		default: begin

		end
	endcase
end

always @ (*)
begin
	case(cur_state)
		S_IDLE: begin
			r_pcie_rx_cmd_rd_en <= 0;
			r_pcie_tag_alloc <= 0;
			r_tx_dma_mrd_req <= 0;
			r_pcie_rx_tag_update <= 0;
		end
		S_PCIE_RX_CMD_0: begin
			r_pcie_rx_cmd_rd_en <= 1;
			r_pcie_tag_alloc <= 0;
			r_tx_dma_mrd_req <= 0;
			r_pcie_rx_tag_update <= 0;
		end
		S_PCIE_RX_CMD_1: begin
			r_pcie_rx_cmd_rd_en <= 1;
			r_pcie_tag_alloc <= 0;
			r_tx_dma_mrd_req <= 0;
			r_pcie_rx_tag_update <= 0;
		end
		S_PCIE_CHK_NUM_MRD: begin
			r_pcie_rx_cmd_rd_en <= 0;
			r_pcie_tag_alloc <= 0;
			r_tx_dma_mrd_req <= 0;
			r_pcie_rx_tag_update <= 0;
		end
		S_PCIE_MRD_REQ: begin
			r_pcie_rx_cmd_rd_en <= 0;
			r_pcie_tag_alloc <= 1;
			r_tx_dma_mrd_req <= 1;
			r_pcie_rx_tag_update <= 0;
		end
		S_PCIE_MRD_ACK: begin
			r_pcie_rx_cmd_rd_en <= 0;
			r_pcie_tag_alloc <= 0;
			r_tx_dma_mrd_req <= 0;
			r_pcie_rx_tag_update <= 0;
		end
		S_PCIE_MRD_DONE: begin
			r_pcie_rx_cmd_rd_en <= 0;
			r_pcie_tag_alloc <= 0;
			r_tx_dma_mrd_req <= 0;
			r_pcie_rx_tag_update <= 1;
		end
		S_PCIE_MRD_DELAY: begin
			r_pcie_rx_cmd_rd_en <= 0;
			r_pcie_tag_alloc <= 0;
			r_tx_dma_mrd_req <= 0;
			r_pcie_rx_tag_update <= 0;
		end
		S_PCIE_MRD_NEXT: begin
			r_pcie_rx_cmd_rd_en <= 0;
			r_pcie_tag_alloc <= 0;
			r_tx_dma_mrd_req <= 0;
			r_pcie_rx_tag_update <= 0;
		end
		default: begin
			r_pcie_rx_cmd_rd_en <= 0;
			r_pcie_tag_alloc <= 0;
			r_tx_dma_mrd_req <= 0;
			r_pcie_rx_tag_update <= 0;
		end
	endcase
end

endmodule

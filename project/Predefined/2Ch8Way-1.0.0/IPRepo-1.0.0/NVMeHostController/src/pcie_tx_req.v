
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

module pcie_tx_req # (
	parameter	C_PCIE_DATA_WIDTH			= 128,
	parameter	C_PCIE_ADDR_WIDTH			= 36
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,

	input	[2:0]							pcie_max_payload_size,

	output									pcie_tx_cmd_rd_en,
	input	[33:0]							pcie_tx_cmd_rd_data,
	input									pcie_tx_cmd_empty_n,

	output									pcie_tx_fifo_free_en,
	output	[9:4]							pcie_tx_fifo_free_len,
	input									pcie_tx_fifo_empty_n,

	output									tx_dma_mwr_req,
	output	[7:0]							tx_dma_mwr_tag,
	output	[11:2]							tx_dma_mwr_len,
	output	[C_PCIE_ADDR_WIDTH-1:2]			tx_dma_mwr_addr,
	input									tx_dma_mwr_req_ack,
	input									tx_dma_mwr_data_last,

	output									dma_tx_done_wr_en,
	output	[20:0]							dma_tx_done_wr_data,
	input									dma_tx_done_wr_rdy_n
);

localparam	S_IDLE							= 10'b0000000001;
localparam	S_PCIE_TX_CMD_0					= 10'b0000000010;
localparam	S_PCIE_TX_CMD_1					= 10'b0000000100;
localparam	S_PCIE_CHK_FIFO					= 10'b0000001000;
localparam	S_PCIE_MWR_REQ					= 10'b0000010000;
localparam	S_PCIE_MWR_ACK					= 10'b0000100000;
localparam	S_PCIE_MWR_DONE					= 10'b0001000000;
localparam	S_PCIE_MWR_NEXT					= 10'b0010000000;
localparam	S_PCIE_DMA_DONE_WR_WAIT			= 10'b0100000000;
localparam	S_PCIE_DMA_DONE_WR				= 10'b1000000000;


reg		[9:0]								cur_state;
reg		[9:0]								next_state;

reg		[2:0]								r_pcie_max_payload_size;
reg											r_pcie_tx_cmd_rd_en;
reg											r_pcie_tx_fifo_free_en;
reg											r_tx_dma_mwr_req;

reg											r_dma_cmd_type;
reg											r_dma_done_check;
reg		[6:0]								r_hcmd_slot_tag;
reg		[12:2]								r_pcie_tx_len;
reg		[12:2]								r_pcie_orig_len;
reg		[9:2]								r_pcie_tx_cur_len;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_pcie_addr;

reg											r_dma_tx_done_wr_en;

assign pcie_tx_cmd_rd_en = r_pcie_tx_cmd_rd_en;

assign pcie_tx_fifo_free_en = r_pcie_tx_fifo_free_en;
assign pcie_tx_fifo_free_len = r_pcie_tx_cur_len[9:4];

assign tx_dma_mwr_req = r_tx_dma_mwr_req;
assign tx_dma_mwr_tag = 8'b0;
assign tx_dma_mwr_len = {2'b0, r_pcie_tx_cur_len};
assign tx_dma_mwr_addr = r_pcie_addr;

assign dma_tx_done_wr_en = r_dma_tx_done_wr_en;
assign dma_tx_done_wr_data = {r_dma_cmd_type, r_dma_done_check, 1'b1, r_hcmd_slot_tag, r_pcie_orig_len};

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
			if(pcie_tx_cmd_empty_n == 1)
				next_state <= S_PCIE_TX_CMD_0;
			else
				next_state <= S_IDLE;
		end
		S_PCIE_TX_CMD_0: begin
			next_state <= S_PCIE_TX_CMD_1;
		end
		S_PCIE_TX_CMD_1: begin
			next_state <= S_PCIE_CHK_FIFO;
		end
		S_PCIE_CHK_FIFO: begin
			if(pcie_tx_fifo_empty_n == 1)
				next_state <= S_PCIE_MWR_REQ;
			else
				next_state <= S_PCIE_CHK_FIFO;
		end
		S_PCIE_MWR_REQ: begin
			next_state <= S_PCIE_MWR_ACK;
		end
		S_PCIE_MWR_ACK: begin
			if(tx_dma_mwr_req_ack == 1)
				next_state <= S_PCIE_MWR_DONE;
			else
				next_state <= S_PCIE_MWR_ACK;
		end
		S_PCIE_MWR_DONE: begin
			next_state <= S_PCIE_MWR_NEXT;
		end
		S_PCIE_MWR_NEXT: begin
			if(r_pcie_tx_len == 0)
				next_state <= S_PCIE_DMA_DONE_WR_WAIT;
			else
				next_state <= S_PCIE_CHK_FIFO;
		end
		S_PCIE_DMA_DONE_WR_WAIT: begin
			if(dma_tx_done_wr_rdy_n == 1)
				next_state <= S_PCIE_DMA_DONE_WR_WAIT;
			else
				next_state <= S_PCIE_DMA_DONE_WR;
		end
		S_PCIE_DMA_DONE_WR: begin
			next_state <= S_IDLE;
		end
		default: begin
			next_state <= S_IDLE;
		end
	endcase
end

always @ (posedge pcie_user_clk)
begin
	r_pcie_max_payload_size <= pcie_max_payload_size;
end

always @ (posedge pcie_user_clk)
begin
	case(cur_state)
		S_IDLE: begin

		end
		S_PCIE_TX_CMD_0: begin
			r_dma_cmd_type <= pcie_tx_cmd_rd_data[19];
			r_dma_done_check <= pcie_tx_cmd_rd_data[18];
			r_hcmd_slot_tag <= pcie_tx_cmd_rd_data[17:11];
			r_pcie_tx_len <= {pcie_tx_cmd_rd_data[10:2], 2'b0};
		end
		S_PCIE_TX_CMD_1: begin
			r_pcie_orig_len <= r_pcie_tx_len;
			case(r_pcie_max_payload_size)
				3'b010: begin
					if(r_pcie_tx_len[8:7] == 0 && r_pcie_tx_len[6:2] == 0)
						r_pcie_tx_cur_len[9:7] <= 3'b100;
					else
						r_pcie_tx_cur_len[9:7] <= {1'b0, r_pcie_tx_len[8:7]};
				end
				3'b001: begin
					if(r_pcie_tx_len[7] == 0 && r_pcie_tx_len[6:2] == 0)
						r_pcie_tx_cur_len[9:7] <= 3'b010;
					else
						r_pcie_tx_cur_len[9:7] <= {2'b0, r_pcie_tx_len[7]};
				end
				default: begin
					if(r_pcie_tx_len[6:2] == 0)
						r_pcie_tx_cur_len[9:7] <= 3'b001;
					else
						r_pcie_tx_cur_len[9:7] <= 3'b000;
				end
			endcase

			r_pcie_tx_cur_len[6:2] <= r_pcie_tx_len[6:2];
			r_pcie_addr <= {pcie_tx_cmd_rd_data[33:2], 2'b0};
		end
		S_PCIE_CHK_FIFO: begin

		end
		S_PCIE_MWR_REQ: begin

		end
		S_PCIE_MWR_ACK: begin

		end
		S_PCIE_MWR_DONE: begin
			r_pcie_addr <= r_pcie_addr + r_pcie_tx_cur_len;
			r_pcie_tx_len <= r_pcie_tx_len - r_pcie_tx_cur_len;

			case(r_pcie_max_payload_size)
				3'b010: r_pcie_tx_cur_len <= 8'h80;
				3'b001: r_pcie_tx_cur_len <= 8'h40;
				default: r_pcie_tx_cur_len <= 8'h20;
			endcase
		end
		S_PCIE_MWR_NEXT: begin

		end
		S_PCIE_DMA_DONE_WR_WAIT: begin

		end
		S_PCIE_DMA_DONE_WR: begin

		end
		default: begin

		end
	endcase
end

always @ (*)
begin
	case(cur_state)
		S_IDLE: begin
			r_pcie_tx_cmd_rd_en <= 0;
			r_pcie_tx_fifo_free_en <= 0;
			r_tx_dma_mwr_req <= 0;
			r_dma_tx_done_wr_en <= 0;
		end
		S_PCIE_TX_CMD_0: begin
			r_pcie_tx_cmd_rd_en <= 1;
			r_pcie_tx_fifo_free_en <= 0;
			r_tx_dma_mwr_req <= 0;
			r_dma_tx_done_wr_en <= 0;
		end
		S_PCIE_TX_CMD_1: begin
			r_pcie_tx_cmd_rd_en <= 1;
			r_pcie_tx_fifo_free_en <= 0;
			r_tx_dma_mwr_req <= 0;
			r_dma_tx_done_wr_en <= 0;
		end
		S_PCIE_CHK_FIFO: begin
			r_pcie_tx_cmd_rd_en <= 0;
			r_pcie_tx_fifo_free_en <= 0;
			r_tx_dma_mwr_req <= 0;
			r_dma_tx_done_wr_en <= 0;
		end
		S_PCIE_MWR_REQ: begin
			r_pcie_tx_cmd_rd_en <= 0;
			r_pcie_tx_fifo_free_en <= 1;
			r_tx_dma_mwr_req <= 1;
			r_dma_tx_done_wr_en <= 0;
		end
		S_PCIE_MWR_ACK: begin
			r_pcie_tx_cmd_rd_en <= 0;
			r_pcie_tx_fifo_free_en <= 0;
			r_tx_dma_mwr_req <= 0;
			r_dma_tx_done_wr_en <= 0;
		end
		S_PCIE_MWR_DONE: begin
			r_pcie_tx_cmd_rd_en <= 0;
			r_pcie_tx_fifo_free_en <= 0;
			r_tx_dma_mwr_req <= 0;
			r_dma_tx_done_wr_en <= 0;
		end
		S_PCIE_MWR_NEXT: begin
			r_pcie_tx_cmd_rd_en <= 0;
			r_pcie_tx_fifo_free_en <= 0;
			r_tx_dma_mwr_req <= 0;
			r_dma_tx_done_wr_en <= 0;
		end
		S_PCIE_DMA_DONE_WR_WAIT: begin
			r_pcie_tx_cmd_rd_en <= 0;
			r_pcie_tx_fifo_free_en <= 0;
			r_tx_dma_mwr_req <= 0;
			r_dma_tx_done_wr_en <= 0;
		end
		S_PCIE_DMA_DONE_WR: begin
			r_pcie_tx_cmd_rd_en <= 0;
			r_pcie_tx_fifo_free_en <= 0;
			r_tx_dma_mwr_req <= 0;
			r_dma_tx_done_wr_en <= 1;
		end
		default: begin
			r_pcie_tx_cmd_rd_en <= 0;
			r_pcie_tx_fifo_free_en <= 0;
			r_tx_dma_mwr_req <= 0;
			r_dma_tx_done_wr_en <= 0;
		end
	endcase
end

endmodule

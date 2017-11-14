
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

module dma_cmd_gen # (
	parameter	P_PCIE_DATA_WIDTH			= 128,
	parameter	C_PCIE_ADDR_WIDTH			= 36
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,

	input									pcie_rcb,

	output									dma_cmd_rd_en,
	input	[49:0]							dma_cmd_rd_data,
	input									dma_cmd_empty_n,

	output	[7:0]							hcmd_prp_rd_addr,
	input	[44:0]							hcmd_prp_rd_data,

	output									dev_rx_cmd_wr_en,
	output	[29:0]							dev_rx_cmd_wr_data,
	input									dev_rx_cmd_full_n,

	output									dev_tx_cmd_wr_en,
	output	[29:0]							dev_tx_cmd_wr_data,
	input									dev_tx_cmd_full_n,

	output									pcie_cmd_wr_en,
	output	[33:0]							pcie_cmd_wr_data,
	input									pcie_cmd_full_n,

	output									prp_pcie_alloc,
	output	[7:0]							prp_pcie_alloc_tag,
	output	[5:4]							prp_pcie_tag_alloc_len,
	input									pcie_tag_full_n,
	input									prp_fifo_full_n,

	output									tx_prp_mrd_req,
	output	[7:0]							tx_prp_mrd_tag,
	output	[11:2]							tx_prp_mrd_len,
	output	[C_PCIE_ADDR_WIDTH-1:2]			tx_prp_mrd_addr,
	input									tx_prp_mrd_req_ack
);

localparam	LP_PRP_PCIE_TAG_PREFIX			= 5'b00001;

localparam	S_IDLE							= 17'b00000000000000001;
localparam	S_DMA_CMD0						= 17'b00000000000000010;
localparam	S_DMA_CMD1						= 17'b00000000000000100;
localparam	S_PRP_INFO0						= 17'b00000000000001000;
localparam	S_PRP_INFO1						= 17'b00000000000010000;
localparam	S_CALC_LEN0						= 17'b00000000000100000;
localparam	S_CALC_LEN1						= 17'b00000000001000000;
localparam	S_CALC_LEN2						= 17'b00000000010000000;
localparam	S_CHECK_FIFO					= 17'b00000000100000000;
localparam	S_CMD0							= 17'b00000001000000000;
localparam	S_CMD1							= 17'b00000010000000000;
localparam	S_CMD2							= 17'b00000100000000000;
localparam	S_CMD3							= 17'b00001000000000000;
localparam	S_PCIE_MRD_CHECK				= 17'b00010000000000000;
localparam	S_PCIE_MRD_REQ					= 17'b00100000000000000;
localparam	S_PCIE_MRD_ACK					= 17'b01000000000000000;
localparam	S_PCIE_MRD_REQ_DONE				= 17'b10000000000000000;

reg		[16:0]								cur_state;
reg		[16:0]								next_state;

reg											r_pcie_rcb;
reg											r_pcie_rcb_cross;

reg											r_dma_cmd_type;
reg											r_dma_cmd_dir;
reg		[6:0]								r_hcmd_slot_tag;
reg		[31:2]								r_dev_addr;
reg		[12:2]								r_dev_dma_len;
reg		[8:0]								r_4k_offset;

reg		[C_PCIE_ADDR_WIDTH-1:2]				r_hcmd_prp_1;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_hcmd_prp_2;
reg		[8:0]								r_hcmd_nlb;

reg											r_prp2_type;
reg		[8:0]								r_prp_offset;
reg											r_prp_offset_is_0;
reg		[11:2]								r_prp_4b_offset;
reg		[12:2]								r_1st_prp_4b_len;

reg		[12:2]								r_1st_4b_len;
reg		[12:2]								r_2st_4b_len;

reg											r_2st_valid;
reg											r_1st_mrd_need;
reg											r_2st_mrd_need;
wire										w_2st_mrd_need;

reg		[2:0]								r_tx_prp_mrd_tag;
reg		[4:3]								r_pcie_mrd_len;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_tx_prp_mrd_addr;

wire	[20:2]								w_4b_offset;
wire										w_dev_cmd_full_n;

reg											r_dma_cmd_rd_en;
reg											r_hcmd_prp_rd_sel;
reg											r_dev_rx_cmd_wr_en;
reg											r_dev_tx_cmd_wr_en;
reg											r_dev_cmd_wr_data_sel;
reg											r_pcie_cmd_wr_en;
reg		[3:0]								r_pcie_cmd_wr_data_sel;
reg											r_prp_pcie_alloc;
reg											r_tx_prp_mrd_req;
reg											r_mrd_tag_update;

reg		[29:0]								r_dev_cmd_wr_data;
reg		[33:0]								r_pcie_cmd_wr_data;

assign dma_cmd_rd_en = r_dma_cmd_rd_en;

assign hcmd_prp_rd_addr = {r_hcmd_slot_tag, r_hcmd_prp_rd_sel};

assign dev_rx_cmd_wr_en = r_dev_rx_cmd_wr_en;
assign dev_rx_cmd_wr_data = r_dev_cmd_wr_data;

assign dev_tx_cmd_wr_en = r_dev_tx_cmd_wr_en;
assign dev_tx_cmd_wr_data = r_dev_cmd_wr_data;

assign pcie_cmd_wr_en = r_pcie_cmd_wr_en;
assign pcie_cmd_wr_data = r_pcie_cmd_wr_data;

assign prp_pcie_alloc = r_prp_pcie_alloc;
assign prp_pcie_alloc_tag = {LP_PRP_PCIE_TAG_PREFIX, r_tx_prp_mrd_tag};
assign prp_pcie_tag_alloc_len = (r_pcie_rcb_cross == 0) ? 2'b01 : 2'b10;

assign tx_prp_mrd_req = r_tx_prp_mrd_req;
assign tx_prp_mrd_tag = {LP_PRP_PCIE_TAG_PREFIX, r_tx_prp_mrd_tag};
assign tx_prp_mrd_len = {7'b0, r_pcie_mrd_len, 1'b0};
assign tx_prp_mrd_addr = r_tx_prp_mrd_addr;

always @ (posedge pcie_user_clk)
begin
	r_pcie_rcb <= pcie_rcb;
end

always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0)
		cur_state <= S_IDLE;
	else
		cur_state <= next_state;
end

assign w_dev_cmd_full_n = (r_dma_cmd_dir == 1'b1) ? dev_tx_cmd_full_n : dev_rx_cmd_full_n;

always @ (*)
begin
	case(cur_state)
		S_IDLE: begin
			if(dma_cmd_empty_n == 1'b1)
				next_state <= S_DMA_CMD0;
			else
				next_state <= S_IDLE;
		end
		S_DMA_CMD0: begin
			next_state <= S_DMA_CMD1;
		end
		S_DMA_CMD1: begin
			if(r_dma_cmd_type == 1'b1)
				next_state <= S_CHECK_FIFO;
			else
				next_state <= S_PRP_INFO0;
		end
		S_PRP_INFO0: begin
			next_state <= S_PRP_INFO1;
		end
		S_PRP_INFO1: begin
			next_state <= S_CALC_LEN0;
		end
		S_CALC_LEN0: begin
			next_state <= S_CALC_LEN1;
		end
		S_CALC_LEN1: begin
			next_state <= S_CALC_LEN2;
		end
		S_CALC_LEN2: begin
			next_state <= S_CHECK_FIFO;
		end
		S_CHECK_FIFO: begin
			if(w_dev_cmd_full_n == 1'b1 && pcie_cmd_full_n == 1'b1)
				next_state <= S_CMD0;
			else
				next_state <= S_CHECK_FIFO;
		end
		S_CMD0: begin
			next_state <= S_CMD1;
		end
		S_CMD1: begin
			next_state <= S_CMD2;
		end
		S_CMD2: begin
			next_state <= S_CMD3;
		end
		S_CMD3: begin
			if((r_1st_mrd_need | (r_2st_valid & r_2st_mrd_need)) == 1'b1)
				next_state <= S_PCIE_MRD_CHECK;
			else
				next_state <= S_IDLE;
		end
		S_PCIE_MRD_CHECK: begin
			if(pcie_tag_full_n == 1 && prp_fifo_full_n == 1)
				next_state <= S_PCIE_MRD_REQ;
			else
				next_state <= S_PCIE_MRD_CHECK;
		end
		S_PCIE_MRD_REQ: begin
			next_state <= S_PCIE_MRD_ACK;
		end
		S_PCIE_MRD_ACK: begin
			if(tx_prp_mrd_req_ack == 1'b1)
				next_state <= S_PCIE_MRD_REQ_DONE;
			else
				next_state <= S_PCIE_MRD_ACK;
		end
		S_PCIE_MRD_REQ_DONE: begin
			next_state <= S_IDLE;
		end
		default: begin
			next_state <= S_IDLE;
		end
	endcase
end

always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0) begin
		r_tx_prp_mrd_tag <= 0;
	end
	else begin
		if(r_mrd_tag_update == 1)
			r_tx_prp_mrd_tag <= r_tx_prp_mrd_tag + 1;
	end
end

assign w_4b_offset[20:2] = {r_4k_offset, 10'b0} + r_hcmd_prp_1[11:2];
assign w_2st_mrd_need = r_2st_valid & r_2st_mrd_need;

always @ (posedge pcie_user_clk)
begin
	case(cur_state)
		S_IDLE: begin
			r_2st_valid <= 0;
			r_1st_mrd_need <= 0;
			r_2st_mrd_need <= 0;
			r_pcie_rcb_cross <= 0;
		end
		S_DMA_CMD0: begin
			r_dev_addr <= dma_cmd_rd_data[29:0];
			r_dev_dma_len <= dma_cmd_rd_data[40:30];
			r_hcmd_slot_tag <= dma_cmd_rd_data[47:41];
			r_dma_cmd_dir <= dma_cmd_rd_data[48];
			r_dma_cmd_type <= dma_cmd_rd_data[49];
		end
		S_DMA_CMD1: begin
			r_hcmd_prp_1 <= dma_cmd_rd_data[33:0];
			r_4k_offset <= dma_cmd_rd_data[42:34];
			r_1st_4b_len <= r_dev_dma_len;
		end
		S_PRP_INFO0: begin
			r_hcmd_prp_1 <= hcmd_prp_rd_data[33:0];
		end
		S_PRP_INFO1: begin
			r_hcmd_nlb <= {1'b0, hcmd_prp_rd_data[41:34]};
			r_hcmd_prp_2 <= hcmd_prp_rd_data[33:0];
		end
		S_CALC_LEN0: begin
			r_prp_offset <= w_4b_offset[20:12];
			r_prp_4b_offset <= w_4b_offset[11:2];
			r_hcmd_nlb <= r_hcmd_nlb + 1;
		end
		S_CALC_LEN1: begin
			r_dev_addr[11:2] <= 0;
			r_dev_dma_len <= 11'h400;

			r_prp_offset_is_0 <= (r_prp_offset == 0);
			r_1st_prp_4b_len <= 11'h400 - r_prp_4b_offset;

			if((12'h800 - r_hcmd_prp_1[11:2]) >= {r_hcmd_nlb, 10'b0})
				r_prp2_type <= 0;
			else
				r_prp2_type <= 1;
		end
		S_CALC_LEN2: begin
			if(r_dev_dma_len > r_1st_prp_4b_len) begin
				r_1st_4b_len <= r_1st_prp_4b_len;
				r_2st_4b_len <= r_dev_dma_len - r_1st_prp_4b_len;
				r_2st_valid <= 1;
			end
			else begin
				r_1st_4b_len <= r_dev_dma_len;
				r_2st_valid <= 0;
			end

			if(r_prp_offset_is_0 == 1) begin
				r_1st_mrd_need <= 0;
				r_2st_mrd_need <= r_prp2_type;
			end
			else begin
				r_hcmd_prp_1[C_PCIE_ADDR_WIDTH-1:12] <= r_hcmd_prp_2[C_PCIE_ADDR_WIDTH-1:12];
				r_1st_mrd_need <= r_prp2_type;
				r_2st_mrd_need <= r_prp2_type;
				r_prp_offset <= r_prp_offset - 1'b1;
			end
			r_hcmd_prp_1[11:2] <= r_prp_4b_offset;
		end
		S_CHECK_FIFO: begin
			r_tx_prp_mrd_addr <= r_hcmd_prp_2 + {r_prp_offset, 1'b0};
			r_pcie_mrd_len <= r_1st_mrd_need + w_2st_mrd_need;
		end
		S_CMD0: begin
			if(r_pcie_mrd_len == 2 && r_tx_prp_mrd_addr[5:2] == 4'b1110) begin
				if(r_pcie_rcb == 1)
					r_pcie_rcb_cross <= r_tx_prp_mrd_addr[6];
				else
					r_pcie_rcb_cross <= 1;
			end
			else
				r_pcie_rcb_cross <= 0;
		end
		S_CMD1: begin

		end
		S_CMD2: begin

		end
		S_CMD3: begin

		end
		S_PCIE_MRD_CHECK: begin

		end
		S_PCIE_MRD_REQ: begin

		end
		S_PCIE_MRD_ACK: begin

		end
		S_PCIE_MRD_REQ_DONE: begin

		end
		default: begin

		end
	endcase
end

always @ (*)
begin
	if(r_dev_cmd_wr_data_sel == 0)
		r_dev_cmd_wr_data <= {10'b0, r_dma_cmd_type, 1'b0, r_hcmd_slot_tag, r_dev_dma_len};
	else
		r_dev_cmd_wr_data <= r_dev_addr;

	case(r_pcie_cmd_wr_data_sel)  // synthesis parallel_case full_case
		4'b0001: r_pcie_cmd_wr_data <= {22'b0, r_dma_cmd_type, r_dma_cmd_dir, r_2st_valid, r_1st_mrd_need, r_2st_mrd_need, r_hcmd_slot_tag};
		4'b0010: r_pcie_cmd_wr_data <= {11'b0, r_pcie_rcb_cross, r_1st_4b_len, r_2st_4b_len};
		4'b0100: r_pcie_cmd_wr_data <= r_hcmd_prp_1;
		4'b1000: r_pcie_cmd_wr_data <= {r_hcmd_prp_2[C_PCIE_ADDR_WIDTH-1:12], 10'b0};
	endcase
end

always @ (*)
begin
	case(cur_state)
		S_IDLE: begin
			r_dma_cmd_rd_en <= 0;
			r_hcmd_prp_rd_sel <= 0;
			r_dev_rx_cmd_wr_en <= 0;
			r_dev_tx_cmd_wr_en <= 0;
			r_dev_cmd_wr_data_sel <= 0;
			r_pcie_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0;
			r_prp_pcie_alloc <= 0;
			r_tx_prp_mrd_req <= 0;
			r_mrd_tag_update <= 0;
		end
		S_DMA_CMD0: begin
			r_dma_cmd_rd_en <= 1;
			r_hcmd_prp_rd_sel <= 0;
			r_dev_rx_cmd_wr_en <= 0;
			r_dev_tx_cmd_wr_en <= 0;
			r_dev_cmd_wr_data_sel <= 0;
			r_pcie_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0;
			r_prp_pcie_alloc <= 0;
			r_tx_prp_mrd_req <= 0;
			r_mrd_tag_update <= 0;
		end
		S_DMA_CMD1: begin
			r_dma_cmd_rd_en <= 1;
			r_hcmd_prp_rd_sel <= 0;
			r_dev_rx_cmd_wr_en <= 0;
			r_dev_tx_cmd_wr_en <= 0;
			r_dev_cmd_wr_data_sel <= 0;
			r_pcie_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0;
			r_prp_pcie_alloc <= 0;
			r_tx_prp_mrd_req <= 0;
			r_mrd_tag_update <= 0;
		end
		S_PRP_INFO0: begin
			r_dma_cmd_rd_en <= 0;
			r_hcmd_prp_rd_sel <= 1;
			r_dev_rx_cmd_wr_en <= 0;
			r_dev_tx_cmd_wr_en <= 0;
			r_dev_cmd_wr_data_sel <= 0;
			r_pcie_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0;
			r_prp_pcie_alloc <= 0;
			r_tx_prp_mrd_req <= 0;
			r_mrd_tag_update <= 0;
		end
		S_PRP_INFO1: begin
			r_dma_cmd_rd_en <= 0;
			r_hcmd_prp_rd_sel <= 0;
			r_dev_rx_cmd_wr_en <= 0;
			r_dev_tx_cmd_wr_en <= 0;
			r_dev_cmd_wr_data_sel <= 0;
			r_pcie_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0;
			r_prp_pcie_alloc <= 0;
			r_tx_prp_mrd_req <= 0;
			r_mrd_tag_update <= 0;
		end
		S_CALC_LEN0: begin
			r_dma_cmd_rd_en <= 0;
			r_hcmd_prp_rd_sel <= 0;
			r_dev_rx_cmd_wr_en <= 0;
			r_dev_tx_cmd_wr_en <= 0;
			r_dev_cmd_wr_data_sel <= 0;
			r_pcie_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0;
			r_prp_pcie_alloc <= 0;
			r_tx_prp_mrd_req <= 0;
			r_mrd_tag_update <= 0;
		end
		S_CALC_LEN1: begin
			r_dma_cmd_rd_en <= 0;
			r_hcmd_prp_rd_sel <= 0;
			r_dev_rx_cmd_wr_en <= 0;
			r_dev_tx_cmd_wr_en <= 0;
			r_dev_cmd_wr_data_sel <= 0;
			r_pcie_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0;
			r_prp_pcie_alloc <= 0;
			r_tx_prp_mrd_req <= 0;
			r_mrd_tag_update <= 0;
		end
		S_CALC_LEN2: begin
			r_dma_cmd_rd_en <= 0;
			r_hcmd_prp_rd_sel <= 0;
			r_dev_rx_cmd_wr_en <= 0;
			r_dev_tx_cmd_wr_en <= 0;
			r_dev_cmd_wr_data_sel <= 0;
			r_pcie_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0;
			r_prp_pcie_alloc <= 0;
			r_tx_prp_mrd_req <= 0;
			r_mrd_tag_update <= 0;
		end
		S_CHECK_FIFO: begin
			r_dma_cmd_rd_en <= 0;
			r_hcmd_prp_rd_sel <= 0;
			r_dev_rx_cmd_wr_en <= 0;
			r_dev_tx_cmd_wr_en <= 0;
			r_dev_cmd_wr_data_sel <= 0;
			r_pcie_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0;
			r_prp_pcie_alloc <= 0;
			r_tx_prp_mrd_req <= 0;
			r_mrd_tag_update <= 0;
		end
		S_CMD0: begin
			r_dma_cmd_rd_en <= 0;
			r_hcmd_prp_rd_sel <= 0;
			r_dev_rx_cmd_wr_en <= ~r_dma_cmd_dir;
			r_dev_tx_cmd_wr_en <= r_dma_cmd_dir;
			r_dev_cmd_wr_data_sel <= 0;
			r_pcie_cmd_wr_en <= 1;
			r_pcie_cmd_wr_data_sel <= 4'b0001;
			r_prp_pcie_alloc <= 0;
			r_tx_prp_mrd_req <= 0;
			r_mrd_tag_update <= 0;
		end
		S_CMD1: begin
			r_dma_cmd_rd_en <= 0;
			r_hcmd_prp_rd_sel <= 0;
			r_dev_rx_cmd_wr_en <= ~r_dma_cmd_dir;
			r_dev_tx_cmd_wr_en <= r_dma_cmd_dir;
			r_dev_cmd_wr_data_sel <= 1;
			r_pcie_cmd_wr_en <= 1;
			r_pcie_cmd_wr_data_sel <= 4'b0010;
			r_prp_pcie_alloc <= 0;
			r_tx_prp_mrd_req <= 0;
			r_mrd_tag_update <= 0;
		end
		S_CMD2: begin
			r_dma_cmd_rd_en <= 0;
			r_hcmd_prp_rd_sel <= 0;
			r_dev_rx_cmd_wr_en <= 0;
			r_dev_tx_cmd_wr_en <= 0;
			r_dev_cmd_wr_data_sel <= 0;
			r_pcie_cmd_wr_en <= 1;
			r_pcie_cmd_wr_data_sel <= 4'b0100;
			r_prp_pcie_alloc <= 0;
			r_tx_prp_mrd_req <= 0;
			r_mrd_tag_update <= 0;
		end
		S_CMD3: begin
			r_dma_cmd_rd_en <= 0;
			r_hcmd_prp_rd_sel <= 0;
			r_dev_rx_cmd_wr_en <= 0;
			r_dev_tx_cmd_wr_en <= 0;
			r_dev_cmd_wr_data_sel <= 0;
			r_pcie_cmd_wr_en <= 1;
			r_pcie_cmd_wr_data_sel <= 4'b1000;
			r_prp_pcie_alloc <= 0;
			r_tx_prp_mrd_req <= 0;
			r_mrd_tag_update <= 0;
		end
		S_PCIE_MRD_CHECK: begin
			r_dma_cmd_rd_en <= 0;
			r_hcmd_prp_rd_sel <= 0;
			r_dev_rx_cmd_wr_en <= 0;
			r_dev_tx_cmd_wr_en <= 0;
			r_dev_cmd_wr_data_sel <= 0;
			r_pcie_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0;
			r_prp_pcie_alloc <= 0;
			r_tx_prp_mrd_req <= 0;
			r_mrd_tag_update <= 0;
		end
		S_PCIE_MRD_REQ: begin
			r_dma_cmd_rd_en <= 0;
			r_hcmd_prp_rd_sel <= 0;
			r_dev_rx_cmd_wr_en <= 0;
			r_dev_tx_cmd_wr_en <= 0;
			r_dev_cmd_wr_data_sel <= 0;
			r_pcie_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0;
			r_prp_pcie_alloc <= 1;
			r_tx_prp_mrd_req <= 1;
			r_mrd_tag_update <= 0;
		end
		S_PCIE_MRD_ACK: begin
			r_dma_cmd_rd_en <= 0;
			r_hcmd_prp_rd_sel <= 0;
			r_dev_rx_cmd_wr_en <= 0;
			r_dev_tx_cmd_wr_en <= 0;
			r_dev_cmd_wr_data_sel <= 0;
			r_pcie_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0;
			r_prp_pcie_alloc <= 0;
			r_tx_prp_mrd_req <= 0;
			r_mrd_tag_update <= 0;
		end
		S_PCIE_MRD_REQ_DONE: begin
			r_dma_cmd_rd_en <= 0;
			r_hcmd_prp_rd_sel <= 0;
			r_dev_rx_cmd_wr_en <= 0;
			r_dev_tx_cmd_wr_en <= 0;
			r_dev_cmd_wr_data_sel <= 0;
			r_pcie_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0;
			r_prp_pcie_alloc <= 0;
			r_tx_prp_mrd_req <= 0;
			r_mrd_tag_update <= 1;
		end
		default: begin
			r_dma_cmd_rd_en <= 0;
			r_hcmd_prp_rd_sel <= 0;
			r_dev_rx_cmd_wr_en <= 0;
			r_dev_tx_cmd_wr_en <= 0;
			r_dev_cmd_wr_data_sel <= 0;
			r_pcie_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0;
			r_prp_pcie_alloc <= 0;
			r_tx_prp_mrd_req <= 0;
			r_mrd_tag_update <= 0;
		end
	endcase
end

endmodule
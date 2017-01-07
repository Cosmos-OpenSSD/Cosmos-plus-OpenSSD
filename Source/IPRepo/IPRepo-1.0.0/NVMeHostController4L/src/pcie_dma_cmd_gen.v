
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

module pcie_dma_cmd_gen # (
	parameter	C_PCIE_DATA_WIDTH			= 128,
	parameter	C_PCIE_ADDR_WIDTH			= 36
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,

	output									pcie_cmd_rd_en,
	input	[33:0]							pcie_cmd_rd_data,
	input									pcie_cmd_empty_n,

	output									prp_fifo_rd_en,
	input	[C_PCIE_DATA_WIDTH-1:0]			prp_fifo_rd_data,
	output									prp_fifo_free_en,
	output	[5:4]							prp_fifo_free_len,
	input									prp_fifo_empty_n,

	output									pcie_rx_cmd_wr_en,
	output	[33:0]							pcie_rx_cmd_wr_data,
	input									pcie_rx_cmd_full_n,

	output									pcie_tx_cmd_wr_en,
	output	[33:0]							pcie_tx_cmd_wr_data,
	input									pcie_tx_cmd_full_n
);

localparam	S_IDLE							= 15'b000000000000001;
localparam	S_CMD0							= 15'b000000000000010;
localparam	S_CMD1							= 15'b000000000000100;
localparam	S_CMD2							= 15'b000000000001000;
localparam	S_CMD3							= 15'b000000000010000;
localparam	S_CHECK_PRP_FIFO				= 15'b000000000100000;
localparam	S_RD_PRP0						= 15'b000000001000000;
localparam	S_RD_PRP1						= 15'b000000010000000;
localparam	S_PCIE_PRP						= 15'b000000100000000;
localparam	S_CHECK_PCIE_CMD_FIFO0			= 15'b000001000000000;
localparam	S_PCIE_CMD0						= 15'b000010000000000;
localparam	S_PCIE_CMD1						= 15'b000100000000000;
localparam	S_CHECK_PCIE_CMD_FIFO1			= 15'b001000000000000;
localparam	S_PCIE_CMD2						= 15'b010000000000000;
localparam	S_PCIE_CMD3						= 15'b100000000000000;

reg		[14:0]								cur_state;
reg		[14:0]								next_state;

reg											r_dma_cmd_type;
reg											r_dma_cmd_dir;
reg											r_2st_valid;
reg											r_1st_mrd_need;
reg											r_2st_mrd_need;
reg		[6:0]								r_hcmd_slot_tag;
reg											r_pcie_rcb_cross;
reg		[12:2]								r_1st_4b_len;
reg		[12:2]								r_2st_4b_len;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_hcmd_prp_1;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_hcmd_prp_2;
reg		[63:2]								r_prp_1;
reg		[63:2]								r_prp_2;

reg											r_pcie_cmd_rd_en;

reg											r_prp_fifo_rd_en;
reg											r_prp_fifo_free_en;

reg											r_pcie_rx_cmd_wr_en;
reg											r_pcie_tx_cmd_wr_en;
reg		[3:0]								r_pcie_cmd_wr_data_sel;
reg		[33:0]								r_pcie_cmd_wr_data;

wire										w_pcie_cmd_full_n;

assign pcie_cmd_rd_en = r_pcie_cmd_rd_en;

assign prp_fifo_rd_en = r_prp_fifo_rd_en;
assign prp_fifo_free_en = r_prp_fifo_free_en;
assign prp_fifo_free_len = (r_pcie_rcb_cross == 0) ? 2'b01 : 2'b10;

assign pcie_rx_cmd_wr_en = r_pcie_rx_cmd_wr_en;
assign pcie_rx_cmd_wr_data = r_pcie_cmd_wr_data;
assign pcie_tx_cmd_wr_en = r_pcie_tx_cmd_wr_en;
assign pcie_tx_cmd_wr_data = r_pcie_cmd_wr_data;

always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0)
		cur_state <= S_IDLE;
	else
		cur_state <= next_state;
end

assign w_pcie_cmd_full_n = (r_dma_cmd_dir == 1'b1) ? pcie_tx_cmd_full_n : pcie_rx_cmd_full_n;

always @ (*)
begin
	case(cur_state)
		S_IDLE: begin
			if(pcie_cmd_empty_n == 1'b1)
				next_state <= S_CMD0;
			else
				next_state <= S_IDLE;
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
				next_state <= S_CHECK_PRP_FIFO;
			else
				next_state <= S_CHECK_PCIE_CMD_FIFO0;
		end
		S_CHECK_PRP_FIFO: begin
			if(prp_fifo_empty_n == 1)
				next_state <= S_RD_PRP0;
			else
				next_state <= S_CHECK_PRP_FIFO;
		end
		S_RD_PRP0: begin
			if(r_pcie_rcb_cross == 1)
				next_state <= S_RD_PRP1;
			else
				next_state <= S_PCIE_PRP;
		end
		S_RD_PRP1: begin
			next_state <= S_PCIE_PRP;
		end
		S_PCIE_PRP: begin
			next_state <= S_CHECK_PCIE_CMD_FIFO0;
		end
		S_CHECK_PCIE_CMD_FIFO0: begin
			if(w_pcie_cmd_full_n == 1'b1)
				next_state <= S_PCIE_CMD0;
			else
				next_state <= S_CHECK_PCIE_CMD_FIFO0;
		end
		S_PCIE_CMD0: begin
			next_state <= S_PCIE_CMD1;
		end
		S_PCIE_CMD1: begin
			if(r_2st_valid == 1'b1)
				next_state <= S_CHECK_PCIE_CMD_FIFO1;
			else
				next_state <= S_IDLE;
		end
		S_CHECK_PCIE_CMD_FIFO1: begin
			if(w_pcie_cmd_full_n == 1'b1)
				next_state <= S_PCIE_CMD2;
			else
				next_state <= S_CHECK_PCIE_CMD_FIFO1;
		end
		S_PCIE_CMD2: begin
			next_state <= S_PCIE_CMD3;
		end
		S_PCIE_CMD3: begin
			next_state <= S_IDLE;
		end
		default: begin
			next_state <= S_IDLE;
		end
	endcase
end

always @ (posedge pcie_user_clk)
begin
	case(cur_state)
		S_IDLE: begin

		end
		S_CMD0: begin
			r_dma_cmd_type <= pcie_cmd_rd_data[11];
			r_dma_cmd_dir <= pcie_cmd_rd_data[10];
			r_2st_valid <= pcie_cmd_rd_data[9];
			r_1st_mrd_need <= pcie_cmd_rd_data[8];
			r_2st_mrd_need <= pcie_cmd_rd_data[7];
			r_hcmd_slot_tag <= pcie_cmd_rd_data[6:0];
		end
		S_CMD1: begin
			r_pcie_rcb_cross <= pcie_cmd_rd_data[22];
			r_1st_4b_len <= pcie_cmd_rd_data[21:11];
			r_2st_4b_len <= pcie_cmd_rd_data[10:0];
		end
		S_CMD2: begin
			r_hcmd_prp_1 <= pcie_cmd_rd_data[33:0];
		end
		S_CMD3: begin
			r_hcmd_prp_2 <= {pcie_cmd_rd_data[33:10], 10'b0};
		end
		S_CHECK_PRP_FIFO: begin

		end
		S_RD_PRP0: begin
			r_prp_1 <= prp_fifo_rd_data[63:2];
			r_prp_2 <= prp_fifo_rd_data[127:66];
		end
		S_RD_PRP1: begin
			r_prp_2 <= prp_fifo_rd_data[63:2];
		end
		S_PCIE_PRP: begin
			if(r_1st_mrd_need == 1) begin
				r_hcmd_prp_1[C_PCIE_ADDR_WIDTH-1:12] <= r_prp_1[C_PCIE_ADDR_WIDTH-1:12];
				r_hcmd_prp_2[C_PCIE_ADDR_WIDTH-1:12] <= r_prp_2[C_PCIE_ADDR_WIDTH-1:12];
			end
			else begin
				r_hcmd_prp_2[C_PCIE_ADDR_WIDTH-1:12] <= r_prp_1[C_PCIE_ADDR_WIDTH-1:12];
			end
		end
		S_CHECK_PCIE_CMD_FIFO0: begin

		end
		S_PCIE_CMD0: begin

		end
		S_PCIE_CMD1: begin

		end
		S_CHECK_PCIE_CMD_FIFO1: begin

		end
		S_PCIE_CMD2: begin

		end
		S_PCIE_CMD3: begin

		end
		default: begin

		end
	endcase
end

always @ (*)
begin
	case(r_pcie_cmd_wr_data_sel)  // synthesis parallel_case full_case
		4'b0001: r_pcie_cmd_wr_data <= {14'b0, r_dma_cmd_type, ~r_2st_valid, r_hcmd_slot_tag, r_1st_4b_len};
		4'b0010: r_pcie_cmd_wr_data <= r_hcmd_prp_1;
		4'b0100: r_pcie_cmd_wr_data <= {14'b0, r_dma_cmd_type, 1'b1, r_hcmd_slot_tag, r_2st_4b_len};
		4'b1000: r_pcie_cmd_wr_data <= {r_hcmd_prp_2[C_PCIE_ADDR_WIDTH-1:12], 10'b0};
	endcase
end

always @ (*)
begin
	case(cur_state)
		S_IDLE: begin
			r_pcie_cmd_rd_en <= 0;
			r_prp_fifo_rd_en <= 0;
			r_prp_fifo_free_en <= 0;
			r_pcie_rx_cmd_wr_en <= 0;
			r_pcie_tx_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0000;
		end
		S_CMD0: begin
			r_pcie_cmd_rd_en <= 1;
			r_prp_fifo_rd_en <= 0;
			r_prp_fifo_free_en <= 0;
			r_pcie_rx_cmd_wr_en <= 0;
			r_pcie_tx_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0000;
		end
		S_CMD1: begin
			r_pcie_cmd_rd_en <= 1;
			r_prp_fifo_rd_en <= 0;
			r_prp_fifo_free_en <= 0;
			r_pcie_rx_cmd_wr_en <= 0;
			r_pcie_tx_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0000;
		end
		S_CMD2: begin
			r_pcie_cmd_rd_en <= 1;
			r_prp_fifo_rd_en <= 0;
			r_prp_fifo_free_en <= 0;
			r_pcie_rx_cmd_wr_en <= 0;
			r_pcie_tx_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0000;
		end
		S_CMD3: begin
			r_pcie_cmd_rd_en <= 1;
			r_prp_fifo_rd_en <= 0;
			r_prp_fifo_free_en <= 0;
			r_pcie_rx_cmd_wr_en <= 0;
			r_pcie_tx_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0000;
		end
		S_CHECK_PRP_FIFO: begin
			r_pcie_cmd_rd_en <= 0;
			r_prp_fifo_rd_en <= 0;
			r_prp_fifo_free_en <= 0;
			r_pcie_rx_cmd_wr_en <= 0;
			r_pcie_tx_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0000;
		end
		S_RD_PRP0: begin
			r_pcie_cmd_rd_en <= 0;
			r_prp_fifo_rd_en <= 1;
			r_prp_fifo_free_en <= 1;
			r_pcie_rx_cmd_wr_en <= 0;
			r_pcie_tx_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0000;
		end
		S_RD_PRP1: begin
			r_pcie_cmd_rd_en <= 0;
			r_prp_fifo_rd_en <= 1;
			r_prp_fifo_free_en <= 0;
			r_pcie_rx_cmd_wr_en <= 0;
			r_pcie_tx_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0000;
		end
		S_PCIE_PRP: begin
			r_pcie_cmd_rd_en <= 0;
			r_prp_fifo_rd_en <= 0;
			r_prp_fifo_free_en <= 0;
			r_pcie_rx_cmd_wr_en <= 0;
			r_pcie_tx_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0000;
		end
		S_CHECK_PCIE_CMD_FIFO0: begin
			r_pcie_cmd_rd_en <= 0;
			r_prp_fifo_rd_en <= 0;
			r_prp_fifo_free_en <= 0;
			r_pcie_rx_cmd_wr_en <= 0;
			r_pcie_tx_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0000;
		end
		S_PCIE_CMD0: begin
			r_pcie_cmd_rd_en <= 0;
			r_prp_fifo_rd_en <= 0;
			r_prp_fifo_free_en <= 0;
			r_pcie_rx_cmd_wr_en <= ~r_dma_cmd_dir;
			r_pcie_tx_cmd_wr_en <= r_dma_cmd_dir;
			r_pcie_cmd_wr_data_sel <= 4'b0001;
		end
		S_PCIE_CMD1: begin
			r_pcie_cmd_rd_en <= 0;
			r_prp_fifo_rd_en <= 0;
			r_prp_fifo_free_en <= 0;
			r_pcie_rx_cmd_wr_en <= ~r_dma_cmd_dir;
			r_pcie_tx_cmd_wr_en <= r_dma_cmd_dir;
			r_pcie_cmd_wr_data_sel <= 4'b0010;
		end
		S_CHECK_PCIE_CMD_FIFO1: begin
			r_pcie_cmd_rd_en <= 0;
			r_prp_fifo_rd_en <= 0;
			r_prp_fifo_free_en <= 0;
			r_pcie_rx_cmd_wr_en <= 0;
			r_pcie_tx_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0000;
		end
		S_PCIE_CMD2: begin
			r_pcie_cmd_rd_en <= 0;
			r_prp_fifo_rd_en <= 0;
			r_prp_fifo_free_en <= 0;
			r_pcie_rx_cmd_wr_en <= ~r_dma_cmd_dir;
			r_pcie_tx_cmd_wr_en <= r_dma_cmd_dir;
			r_pcie_cmd_wr_data_sel <= 4'b0100;
		end
		S_PCIE_CMD3: begin
			r_pcie_cmd_rd_en <= 0;
			r_prp_fifo_rd_en <= 0;
			r_prp_fifo_free_en <= 0;
			r_pcie_rx_cmd_wr_en <= ~r_dma_cmd_dir;
			r_pcie_tx_cmd_wr_en <= r_dma_cmd_dir;
			r_pcie_cmd_wr_data_sel <= 4'b1000;
		end
		default: begin
			r_pcie_cmd_rd_en <= 0;
			r_prp_fifo_rd_en <= 0;
			r_prp_fifo_free_en <= 0;
			r_pcie_rx_cmd_wr_en <= 0;
			r_pcie_tx_cmd_wr_en <= 0;
			r_pcie_cmd_wr_data_sel <= 4'b0000;
		end
	endcase
end

endmodule
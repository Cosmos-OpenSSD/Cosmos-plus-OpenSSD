
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

module dma_done # (
	parameter	C_PCIE_DATA_WIDTH			= 128,
	parameter	C_PCIE_ADDR_WIDTH			= 36
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,

	output									dma_done_rd_en,
	input	[20:0]							dma_done_rd_data,
	input									dma_done_empty_n,

	output	[6:0]							hcmd_nlb_rd_addr,
	input	[18:0]							hcmd_nlb_rd_data,

	output									hcmd_nlb_wr1_en,
	output	[6:0]							hcmd_nlb_wr1_addr,
	output	[18:0]							hcmd_nlb_wr1_data,
	input									hcmd_nlb_wr1_rdy_n,

	output									hcmd_cq_wr0_en,
	output	[34:0]							hcmd_cq_wr0_data0,
	output	[34:0]							hcmd_cq_wr0_data1,
	input									hcmd_cq_wr0_rdy_n,

	input									cpu_bus_clk,
	input									cpu_bus_rst_n,

	output	[7:0]							dma_rx_direct_done_cnt,
	output	[7:0]							dma_tx_direct_done_cnt,
	output	[7:0]							dma_rx_done_cnt,
	output	[7:0]							dma_tx_done_cnt

);

localparam	LP_NLB_WR_DELAY					= 1;

localparam	S_IDLE							= 11'b00000000001;
localparam	S_DMA_INFO						= 11'b00000000010;
localparam	S_NLB_RD_WAIT					= 11'b00000000100;
localparam	S_NLB_INFO						= 11'b00000001000;
localparam	S_NLB_CALC						= 11'b00000010000;
localparam	S_NLB_WR_WAIT					= 11'b00000100000;
localparam	S_NLB_WR						= 11'b00001000000;
localparam	S_NLB_WR_DELAY					= 11'b00010000000;
localparam	S_CQ_WR_WAIT					= 11'b00100000000;
localparam	S_CQ_WR							= 11'b01000000000;
localparam	S_NLB_DONE						= 11'b10000000000;

reg		[10:0]								cur_state;
reg		[10:0]								next_state;

reg											r_dma_cmd_type;
reg											r_dma_done_check;
reg											r_dma_dir;
reg		[6:0]								r_hcmd_slot_tag;
reg		[12:2]								r_dma_len;
reg		[20:2]								r_hcmd_data_len;

reg											r_dma_done_rd_en;
reg											r_hcmd_nlb_wr1_en;
reg											r_hcmd_cq_wr0_en;

reg											r_dma_rx_direct_done_en;
reg											r_dma_tx_direct_done_en;
reg											r_dma_rx_done_en;
reg											r_dma_tx_done_en;

reg											r_dma_rx_direct_done_en_d1;
reg											r_dma_tx_direct_done_en_d1;
reg											r_dma_rx_done_en_d1;
reg											r_dma_tx_done_en_d1;

reg											r_dma_rx_direct_done_en_sync;
reg											r_dma_tx_direct_done_en_sync;
reg											r_dma_rx_done_en_sync;
reg											r_dma_tx_done_en_sync;

reg		[3:0]								r_nlb_wr_delay;

(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_dma_rx_direct_done;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_dma_tx_direct_done;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_dma_rx_done;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_dma_tx_done;

(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_dma_rx_direct_done_d1;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_dma_tx_direct_done_d1;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_dma_rx_done_d1;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_dma_tx_done_d1;

(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_dma_rx_direct_done_d2;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_dma_tx_direct_done_d2;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_dma_rx_done_d2;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_dma_tx_done_d2;

reg		[7:0]								r_dma_rx_direct_done_cnt;
reg		[7:0]								r_dma_tx_direct_done_cnt;
reg		[7:0]								r_dma_rx_done_cnt;
reg		[7:0]								r_dma_tx_done_cnt;

assign dma_done_rd_en = r_dma_done_rd_en;

assign hcmd_nlb_rd_addr = r_hcmd_slot_tag;

assign hcmd_nlb_wr1_en = r_hcmd_nlb_wr1_en;
assign hcmd_nlb_wr1_addr = r_hcmd_slot_tag;
assign hcmd_nlb_wr1_data = r_hcmd_data_len;

assign hcmd_cq_wr0_en = r_hcmd_cq_wr0_en;
assign hcmd_cq_wr0_data0 = {26'b0, r_hcmd_slot_tag, 1'b0, 1'b1};
assign hcmd_cq_wr0_data1 = 35'b0;

assign dma_rx_direct_done_cnt = r_dma_rx_direct_done_cnt;
assign dma_tx_direct_done_cnt = r_dma_tx_direct_done_cnt;
assign dma_rx_done_cnt = r_dma_rx_done_cnt;
assign dma_tx_done_cnt = r_dma_tx_done_cnt;

always @ (posedge cpu_bus_clk or negedge cpu_bus_rst_n)
begin
	if(cpu_bus_rst_n == 0) begin
		r_dma_rx_direct_done_cnt <= 0;
		r_dma_tx_direct_done_cnt <= 0;
		r_dma_rx_done_cnt <= 0;
		r_dma_tx_done_cnt <= 0;
	end
	else begin
		if(r_dma_rx_direct_done_d1 == 1 && r_dma_rx_direct_done_d2 == 0)
			r_dma_rx_direct_done_cnt <= r_dma_rx_direct_done_cnt + 1;
		
		if(r_dma_tx_direct_done_d1 == 1 && r_dma_tx_direct_done_d2 == 0)
			r_dma_tx_direct_done_cnt <= r_dma_tx_direct_done_cnt + 1;

		if(r_dma_rx_done_d1 == 1 && r_dma_rx_done_d2 == 0)
			r_dma_rx_done_cnt <= r_dma_rx_done_cnt + 1;

		if(r_dma_tx_done_d1 == 1 && r_dma_tx_done_d2 == 0)
			r_dma_tx_done_cnt <= r_dma_tx_done_cnt + 1;
	end
end

always @ (posedge cpu_bus_clk)
begin
	r_dma_rx_direct_done <= r_dma_rx_direct_done_en_sync;
	r_dma_tx_direct_done <= r_dma_tx_direct_done_en_sync;
	r_dma_rx_done <= r_dma_rx_done_en_sync;
	r_dma_tx_done <= r_dma_tx_done_en_sync;

	r_dma_rx_direct_done_d1 <= r_dma_rx_direct_done;
	r_dma_tx_direct_done_d1 <= r_dma_tx_direct_done;
	r_dma_rx_done_d1 <= r_dma_rx_done;
	r_dma_tx_done_d1 <= r_dma_tx_done;

	r_dma_rx_direct_done_d2 <= r_dma_rx_direct_done_d1;
	r_dma_tx_direct_done_d2 <= r_dma_tx_direct_done_d1;
	r_dma_rx_done_d2 <= r_dma_rx_done_d1;
	r_dma_tx_done_d2 <= r_dma_tx_done_d1;
end

always @ (posedge pcie_user_clk)
begin
	r_dma_rx_direct_done_en_d1 <= r_dma_rx_direct_done_en;
	r_dma_tx_direct_done_en_d1 <= r_dma_tx_direct_done_en;
	r_dma_rx_done_en_d1 <= r_dma_rx_done_en;
	r_dma_tx_done_en_d1 <= r_dma_tx_done_en;

	r_dma_rx_direct_done_en_sync <= r_dma_rx_direct_done_en | r_dma_rx_direct_done_en_d1;
	r_dma_tx_direct_done_en_sync <= r_dma_tx_direct_done_en | r_dma_tx_direct_done_en_d1;
	r_dma_rx_done_en_sync <= r_dma_rx_done_en | r_dma_rx_done_en_d1;
	r_dma_tx_done_en_sync <= r_dma_tx_done_en | r_dma_tx_done_en_d1;
end

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
			if(dma_done_empty_n == 1'b1)
				next_state <= S_DMA_INFO;
			else
				next_state <= S_IDLE;
		end
		S_DMA_INFO: begin
			next_state <= S_NLB_RD_WAIT;
		end
		S_NLB_RD_WAIT: begin
			if(r_dma_cmd_type == 1)
				next_state <= S_NLB_DONE;
			else
				next_state <= S_NLB_INFO;
		end
		S_NLB_INFO: begin
			next_state <= S_NLB_CALC;
		end
		S_NLB_CALC: begin
			if(r_hcmd_data_len == r_dma_len)
				next_state <= S_CQ_WR_WAIT;
			else
				next_state <= S_NLB_WR_WAIT;
		end
		S_NLB_WR_WAIT: begin
			if(hcmd_nlb_wr1_rdy_n == 1)
				next_state <= S_NLB_WR_WAIT;
			else
				next_state <= S_NLB_WR;
		end
		S_NLB_WR: begin
			next_state <= S_NLB_WR_DELAY;
		end
		S_NLB_WR_DELAY: begin
			if(r_nlb_wr_delay == 0)
				next_state <= S_NLB_DONE;
			else
				next_state <= S_NLB_WR_DELAY;
		end
		S_CQ_WR_WAIT: begin
			if(hcmd_cq_wr0_rdy_n == 1)
				next_state <= S_CQ_WR_WAIT;
			else
				next_state <= S_CQ_WR;
		end
		S_CQ_WR: begin
			next_state <= S_NLB_DONE;
		end
		S_NLB_DONE: begin
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
		S_DMA_INFO: begin
			r_dma_cmd_type <= dma_done_rd_data[20];
			r_dma_done_check <= dma_done_rd_data[19];
			r_dma_dir <= dma_done_rd_data[18];
			r_hcmd_slot_tag <= dma_done_rd_data[17:11];
			r_dma_len <= dma_done_rd_data[10:0];
		end
		S_NLB_RD_WAIT: begin

		end
		S_NLB_INFO: begin
			r_hcmd_data_len <= hcmd_nlb_rd_data;
		end
		S_NLB_CALC: begin
			r_hcmd_data_len <= r_hcmd_data_len - r_dma_len;
		end
		S_NLB_WR_WAIT: begin

		end
		S_NLB_WR: begin
			r_nlb_wr_delay <= LP_NLB_WR_DELAY;
		end
		S_NLB_WR_DELAY: begin
			r_nlb_wr_delay <= r_nlb_wr_delay - 1;
		end
		S_CQ_WR_WAIT: begin

		end
		S_CQ_WR: begin

		end
		S_NLB_DONE: begin

		end
		default: begin

		end
	endcase
end

always @ (*)
begin
	case(cur_state)
		S_IDLE: begin
			r_dma_done_rd_en <= 0;
			r_hcmd_nlb_wr1_en <= 0;
			r_hcmd_cq_wr0_en <= 0;
			r_dma_rx_direct_done_en <= 0;
			r_dma_tx_direct_done_en <= 0;
			r_dma_rx_done_en <= 0;
			r_dma_tx_done_en <= 0;
		end
		S_DMA_INFO: begin
			r_dma_done_rd_en <= 1;
			r_hcmd_nlb_wr1_en <= 0;
			r_hcmd_cq_wr0_en <= 0;
			r_dma_rx_direct_done_en <= 0;
			r_dma_tx_direct_done_en <= 0;
			r_dma_rx_done_en <= 0;
			r_dma_tx_done_en <= 0;
		end
		S_NLB_RD_WAIT: begin
			r_dma_done_rd_en <= 0;
			r_hcmd_nlb_wr1_en <= 0;
			r_hcmd_cq_wr0_en <= 0;
			r_dma_rx_direct_done_en <= 0;
			r_dma_tx_direct_done_en <= 0;
			r_dma_rx_done_en <= 0;
			r_dma_tx_done_en <= 0;
		end
		S_NLB_INFO: begin
			r_dma_done_rd_en <= 0;
			r_hcmd_nlb_wr1_en <= 0;
			r_hcmd_cq_wr0_en <= 0;
			r_dma_rx_direct_done_en <= 0;
			r_dma_tx_direct_done_en <= 0;
			r_dma_rx_done_en <= 0;
			r_dma_tx_done_en <= 0;
		end
		S_NLB_CALC: begin
			r_dma_done_rd_en <= 0;
			r_hcmd_nlb_wr1_en <= 0;
			r_hcmd_cq_wr0_en <= 0;
			r_dma_rx_direct_done_en <= 0;
			r_dma_tx_direct_done_en <= 0;
			r_dma_rx_done_en <= 0;
			r_dma_tx_done_en <= 0;
		end
		S_NLB_WR_WAIT: begin
			r_dma_done_rd_en <= 0;
			r_hcmd_nlb_wr1_en <= 0;
			r_hcmd_cq_wr0_en <= 0;
			r_dma_rx_direct_done_en <= 0;
			r_dma_tx_direct_done_en <= 0;
			r_dma_rx_done_en <= 0;
			r_dma_tx_done_en <= 0;
		end
		S_NLB_WR: begin
			r_dma_done_rd_en <= 0;
			r_hcmd_nlb_wr1_en <= 1;
			r_hcmd_cq_wr0_en <= 0;
			r_dma_rx_direct_done_en <= 0;
			r_dma_tx_direct_done_en <= 0;
			r_dma_rx_done_en <= 0;
			r_dma_tx_done_en <= 0;
		end
		S_NLB_WR_DELAY: begin
			r_dma_done_rd_en <= 0;
			r_hcmd_nlb_wr1_en <= 0;
			r_hcmd_cq_wr0_en <= 0;
			r_dma_rx_direct_done_en <= 0;
			r_dma_tx_direct_done_en <= 0;
			r_dma_rx_done_en <= 0;
			r_dma_tx_done_en <= 0;
		end
		S_CQ_WR_WAIT: begin
			r_dma_done_rd_en <= 0;
			r_hcmd_nlb_wr1_en <= 0;
			r_hcmd_cq_wr0_en <= 0;
			r_dma_rx_direct_done_en <= 0;
			r_dma_tx_direct_done_en <= 0;
			r_dma_rx_done_en <= 0;
			r_dma_tx_done_en <= 0;
		end
		S_CQ_WR: begin
			r_dma_done_rd_en <= 0;
			r_hcmd_nlb_wr1_en <= 0;
			r_hcmd_cq_wr0_en <= 1;
			r_dma_rx_direct_done_en <= 0;
			r_dma_tx_direct_done_en <= 0;
			r_dma_rx_done_en <= 0;
			r_dma_tx_done_en <= 0;
		end
		S_NLB_DONE: begin
			r_dma_done_rd_en <= 0;
			r_hcmd_nlb_wr1_en <= 0;
			r_hcmd_cq_wr0_en <= 0;
			r_dma_rx_direct_done_en <= r_dma_cmd_type & r_dma_done_check & ~r_dma_dir;
			r_dma_tx_direct_done_en <= r_dma_cmd_type & r_dma_done_check & r_dma_dir;
			r_dma_rx_done_en <= ~r_dma_cmd_type & r_dma_done_check & ~r_dma_dir;
			r_dma_tx_done_en <= ~r_dma_cmd_type & r_dma_done_check & r_dma_dir;
		end
		default: begin
			r_dma_done_rd_en <= 0;
			r_hcmd_nlb_wr1_en <= 0;
			r_hcmd_cq_wr0_en <= 0;
			r_dma_rx_direct_done_en <= 0;
			r_dma_tx_direct_done_en <= 0;
			r_dma_rx_done_en <= 0;
			r_dma_tx_done_en <= 0;
		end
	endcase
end

endmodule

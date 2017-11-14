
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


module pcie_hcmd_sq_req # (
	parameter	C_PCIE_DATA_WIDTH			= 128,
	parameter	C_PCIE_ADDR_WIDTH			= 36
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,
	
	input									arb_sq_rdy,
	input	[3:0]							sq_qid,
	input	[C_PCIE_ADDR_WIDTH-1:2]			hcmd_pcie_addr,
	output									sq_hcmd_ack,

	input									hcmd_slot_rdy,
	input	[6:0]							hcmd_slot_tag,
	output									hcmd_slot_alloc_en,

	output									pcie_sq_cmd_fifo_wr_en,
	output	[10:0]							pcie_sq_cmd_fifo_wr_data,
	input									pcie_sq_cmd_fifo_full_n,

	output									pcie_sq_rx_tag_alloc,
	output	[7:0]							pcie_sq_rx_alloc_tag,
	output	[6:4]							pcie_sq_rx_tag_alloc_len,
	input									pcie_sq_rx_tag_full_n,
	input									pcie_sq_rx_fifo_full_n,

	output									tx_mrd_req,
	output	[7:0]							tx_mrd_tag,
	output	[11:2]							tx_mrd_len,
	output	[C_PCIE_ADDR_WIDTH-1:2]			tx_mrd_addr,
	input									tx_mrd_req_ack
);

localparam	LP_HCMD_PCIE_TAG_PREFIX			= 5'b00000;
localparam	LP_HCMD_PCIE_SIZE				= 10'h10;


localparam	S_IDLE							= 6'b000001;
localparam	S_CMD_INFO						= 6'b000010;
localparam	S_CHECK_FIFO					= 6'b000100;
localparam	S_PCIE_MRD_REQ					= 6'b001000;
localparam	S_PCIE_MRD_ACK					= 6'b010000;
localparam	S_PCIE_MRD_DONE					= 6'b100000;


reg		[5:0]								cur_state;
reg		[5:0]								next_state;

reg											r_sq_hcmd_ack;
reg											r_hcmd_slot_alloc_en;

reg											r_tx_mrd_req;
reg		[2:0]								r_hcmd_pcie_tag;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_hcmd_pcie_addr;
reg											r_hcmd_pcie_tag_update;

reg		[3:0]								r_sq_qid;
reg		[6:0]								r_hcmd_slot_tag;

reg											r_pcie_sq_cmd_fifo_wr_en;
reg											r_pcie_sq_rx_tag_alloc;

assign sq_hcmd_ack = r_sq_hcmd_ack;
assign hcmd_slot_alloc_en = r_hcmd_slot_alloc_en;

assign pcie_sq_cmd_fifo_wr_en = r_pcie_sq_cmd_fifo_wr_en;
assign pcie_sq_cmd_fifo_wr_data = {r_sq_qid, r_hcmd_slot_tag};

assign pcie_sq_rx_tag_alloc = r_pcie_sq_rx_tag_alloc;
assign pcie_sq_rx_alloc_tag = {LP_HCMD_PCIE_TAG_PREFIX, r_hcmd_pcie_tag};
assign pcie_sq_rx_tag_alloc_len = 3'b100;

assign tx_mrd_req = r_tx_mrd_req;
assign tx_mrd_tag = {LP_HCMD_PCIE_TAG_PREFIX, r_hcmd_pcie_tag};
assign tx_mrd_len = LP_HCMD_PCIE_SIZE;
assign tx_mrd_addr = r_hcmd_pcie_addr;

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
			if(arb_sq_rdy == 1 && hcmd_slot_rdy == 1)
				next_state <= S_CMD_INFO;
			else
				next_state <= S_IDLE;
		end
		S_CMD_INFO: begin
			next_state <= S_CHECK_FIFO;
		end
		S_CHECK_FIFO: begin
			if(pcie_sq_cmd_fifo_full_n == 1 && pcie_sq_rx_tag_full_n == 1 && pcie_sq_rx_fifo_full_n == 1)
				next_state <= S_PCIE_MRD_REQ;
			else
				next_state <= S_CHECK_FIFO;
		end
		S_PCIE_MRD_REQ: begin
			next_state <= S_PCIE_MRD_ACK;
		end
		S_PCIE_MRD_ACK: begin
			if(tx_mrd_req_ack == 1)
				next_state <= S_PCIE_MRD_DONE;
			else
				next_state <= S_PCIE_MRD_ACK;
		end
		S_PCIE_MRD_DONE: begin
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
		r_hcmd_pcie_tag <= 0;
	end
	else begin
		if(r_hcmd_pcie_tag_update == 1)
			r_hcmd_pcie_tag <= r_hcmd_pcie_tag + 1;
	end
end

always @ (posedge pcie_user_clk)
begin
	case(cur_state)
		S_IDLE: begin

		end
		S_CMD_INFO: begin
			r_sq_qid <= sq_qid;
			r_hcmd_pcie_addr <= hcmd_pcie_addr;
			r_hcmd_slot_tag <= hcmd_slot_tag;
		end
		S_CHECK_FIFO: begin

		end
		S_PCIE_MRD_REQ: begin

		end
		S_PCIE_MRD_ACK: begin

		end
		S_PCIE_MRD_DONE: begin

		end
		default: begin

		end
	endcase
end


always @ (*)
begin
	case(cur_state)
		S_IDLE: begin
			r_sq_hcmd_ack <= 0;
			r_hcmd_slot_alloc_en <= 0;
			r_pcie_sq_cmd_fifo_wr_en <= 0;
			r_pcie_sq_rx_tag_alloc <= 0;
			r_tx_mrd_req <= 0;
			r_hcmd_pcie_tag_update <= 0;
		end
		S_CMD_INFO: begin
			r_sq_hcmd_ack <= 1;
			r_hcmd_slot_alloc_en <= 1;
			r_pcie_sq_cmd_fifo_wr_en <= 0;
			r_pcie_sq_rx_tag_alloc <= 0;
			r_tx_mrd_req <= 0;
			r_hcmd_pcie_tag_update <= 0;
		end
		S_CHECK_FIFO: begin
			r_sq_hcmd_ack <= 0;
			r_hcmd_slot_alloc_en <= 0;
			r_pcie_sq_cmd_fifo_wr_en <= 0;
			r_pcie_sq_rx_tag_alloc <= 0;
			r_tx_mrd_req <= 0;
			r_hcmd_pcie_tag_update <= 0;
		end
		S_PCIE_MRD_REQ: begin
			r_sq_hcmd_ack <= 0;
			r_hcmd_slot_alloc_en <= 0;
			r_pcie_sq_cmd_fifo_wr_en <= 1;
			r_pcie_sq_rx_tag_alloc <= 1;
			r_tx_mrd_req <= 1;
			r_hcmd_pcie_tag_update <= 0;
		end
		S_PCIE_MRD_ACK: begin
			r_sq_hcmd_ack <= 0;
			r_hcmd_slot_alloc_en <= 0;
			r_pcie_sq_cmd_fifo_wr_en <= 0;
			r_pcie_sq_rx_tag_alloc <= 0;
			r_tx_mrd_req <= 0;
			r_hcmd_pcie_tag_update <= 0;
		end
		S_PCIE_MRD_DONE: begin
			r_sq_hcmd_ack <= 0;
			r_hcmd_slot_alloc_en <= 0;
			r_pcie_sq_cmd_fifo_wr_en <= 0;
			r_pcie_sq_rx_tag_alloc <= 0;
			r_tx_mrd_req <= 0;
			r_hcmd_pcie_tag_update <= 1;
		end
		default: begin
			r_sq_hcmd_ack <= 0;
			r_hcmd_slot_alloc_en <= 0;
			r_pcie_sq_cmd_fifo_wr_en <= 0;
			r_pcie_sq_rx_tag_alloc <= 0;
			r_tx_mrd_req <= 0;
			r_hcmd_pcie_tag_update <= 0;
		end
	endcase
end

endmodule

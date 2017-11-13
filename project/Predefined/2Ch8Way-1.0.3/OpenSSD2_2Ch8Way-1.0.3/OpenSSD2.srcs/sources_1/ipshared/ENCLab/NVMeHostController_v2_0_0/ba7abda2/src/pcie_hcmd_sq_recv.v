
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


module pcie_hcmd_sq_recv # (
	parameter	C_PCIE_DATA_WIDTH			= 128,
	parameter	C_PCIE_ADDR_WIDTH			= 36
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,
	
	output									pcie_sq_cmd_fifo_rd_en,
	input	[10:0]							pcie_sq_cmd_fifo_rd_data,
	input									pcie_sq_cmd_fifo_empty_n,

	output									pcie_sq_rx_fifo_rd_en,
	input	[C_PCIE_DATA_WIDTH-1:0]			pcie_sq_rx_fifo_rd_data,
	output									pcie_sq_rx_fifo_free_en,
	output	[6:4]							pcie_sq_rx_fifo_free_len,
	input									pcie_sq_rx_fifo_empty_n,

	output									hcmd_table_wr_en,
	output	[8:0]							hcmd_table_wr_addr,
	output	[C_PCIE_DATA_WIDTH-1:0]			hcmd_table_wr_data,

	output									hcmd_cid_wr_en,
	output	[6:0]							hcmd_cid_wr_addr,
	output	[19:0]							hcmd_cid_wr_data,

	output									hcmd_prp_wr_en,
	output	[7:0]							hcmd_prp_wr_addr,
	output	[44:0]							hcmd_prp_wr_data,

	output									hcmd_nlb_wr0_en,
	output	[6:0]							hcmd_nlb_wr0_addr,
	output	[18:0]							hcmd_nlb_wr0_data,
	input									hcmd_nlb_wr0_rdy_n,

	output									hcmd_sq_wr_en,
	output	[18:0]							hcmd_sq_wr_data,
	input									hcmd_sq_full_n,

	input	[8:0]							sq_rst_n,
	input	[7:0]							admin_sq_size,
	input	[7:0]							io_sq1_size,
	input	[7:0]							io_sq2_size,
	input	[7:0]							io_sq3_size,
	input	[7:0]							io_sq4_size,
	input	[7:0]							io_sq5_size,
	input	[7:0]							io_sq6_size,
	input	[7:0]							io_sq7_size,
	input	[7:0]							io_sq8_size,

	output	[7:0]							admin_sq_head_ptr,
	output	[7:0]							io_sq1_head_ptr,
	output	[7:0]							io_sq2_head_ptr,
	output	[7:0]							io_sq3_head_ptr,
	output	[7:0]							io_sq4_head_ptr,
	output	[7:0]							io_sq5_head_ptr,
	output	[7:0]							io_sq6_head_ptr,
	output	[7:0]							io_sq7_head_ptr,
	output	[7:0]							io_sq8_head_ptr
);


localparam	S_IDLE							= 10'b0000000001;
localparam	S_SQ_CMD						= 10'b0000000010;
localparam	S_CHECK_FIFO					= 10'b0000000100;
localparam	S_PCIE_HCMD_0					= 10'b0000001000;
localparam	S_PCIE_HCMD_1					= 10'b0000010000;
localparam	S_PCIE_HCMD_2					= 10'b0000100000;
localparam	S_PCIE_HCMD_3					= 10'b0001000000;
localparam	S_PCIE_NLB						= 10'b0010000000;
localparam	S_PCIE_NLB_WAIT					= 10'b0100000000;
localparam	S_PCIE_HCMD_DONE				= 10'b1000000000;


reg		[9:0]								cur_state;
reg		[9:0]								next_state;


reg		[3:0]								r_sq_qid;
reg		[6:0]								r_hcmd_slot_tag;
reg		[7:0]								r_hcmd_num;

reg											r_pcie_sq_cmd_fifo_rd_en;

reg											r_pcie_sq_rx_fifo_rd_en;
reg		[C_PCIE_DATA_WIDTH-1:0]				r_pcie_sq_rx_fifo_rd_data;
reg											r_pcie_sq_rx_fifo_free_en;

reg		[63:2]								r_hcmd_prp1;
reg		[63:2]								r_hcmd_prp2;

reg		[8:0]								r_hcmd_nlb;
reg		[2:0]								r_hcmd_slba;

reg											r_hcmd_table_wr_en;
reg		[1:0]								r_hcmd_table_addr;
reg											r_hcmd_cid_wr_en;
reg											r_hcmd_prp_wr_en;
reg											r_hcmd_prp_sel;
reg											r_hcmd_sq_wr_en;

reg											r_hcmd_nlb_wr0_en;

reg		[8:0]								r_sq_valid_entry;
reg		[8:0]								r_sq_update_entry;
wire	[8:0]								w_sq_rst_n;
reg		[7:0]								r_admin_sq_head_ptr;
reg		[7:0]								r_io_sq1_head_ptr;
reg		[7:0]								r_io_sq2_head_ptr;
reg		[7:0]								r_io_sq3_head_ptr;
reg		[7:0]								r_io_sq4_head_ptr;
reg		[7:0]								r_io_sq5_head_ptr;
reg		[7:0]								r_io_sq6_head_ptr;
reg		[7:0]								r_io_sq7_head_ptr;
reg		[7:0]								r_io_sq8_head_ptr;

assign pcie_sq_cmd_fifo_rd_en = r_pcie_sq_cmd_fifo_rd_en;

assign pcie_sq_rx_fifo_rd_en = r_pcie_sq_rx_fifo_rd_en;
assign pcie_sq_rx_fifo_free_en = r_pcie_sq_rx_fifo_free_en;
assign pcie_sq_rx_fifo_free_len = 3'b100;

//assign hcmd_table_wr_en = cpld_fifo_wr_en;
assign hcmd_table_wr_en = r_hcmd_table_wr_en;
assign hcmd_table_wr_addr = {r_hcmd_slot_tag, r_hcmd_table_addr};
assign hcmd_table_wr_data = r_pcie_sq_rx_fifo_rd_data;

assign hcmd_sq_wr_en = r_hcmd_sq_wr_en;
assign hcmd_sq_wr_data = {r_hcmd_num, r_hcmd_slot_tag, r_sq_qid};

assign hcmd_cid_wr_en = r_hcmd_cid_wr_en;
assign hcmd_cid_wr_addr = r_hcmd_slot_tag;
assign hcmd_cid_wr_data = {r_sq_qid, r_pcie_sq_rx_fifo_rd_data[31:16]};

assign hcmd_nlb_wr0_en = r_hcmd_nlb_wr0_en;
assign hcmd_nlb_wr0_addr = r_hcmd_slot_tag;
assign hcmd_nlb_wr0_data = {r_hcmd_nlb, 10'b0};

assign hcmd_prp_wr_en = r_hcmd_prp_wr_en;
assign hcmd_prp_wr_addr = {r_hcmd_slot_tag, r_hcmd_prp_sel};
assign hcmd_prp_wr_data = (r_hcmd_prp_sel == 0) ? {8'b0, r_hcmd_slba, r_hcmd_prp1[C_PCIE_ADDR_WIDTH-1:2]} 
												: {3'b0, r_hcmd_nlb[7:0], r_hcmd_prp2[C_PCIE_ADDR_WIDTH-1:2]};


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
			if(pcie_sq_cmd_fifo_empty_n == 1)
				next_state <= S_SQ_CMD;
			else
				next_state <= S_IDLE;
		end
		S_SQ_CMD: begin
			next_state <= S_CHECK_FIFO;
		end
		S_CHECK_FIFO: begin
			if(pcie_sq_rx_fifo_empty_n == 1)
				next_state <= S_PCIE_HCMD_0;
			else
				next_state <= S_CHECK_FIFO;
		end
		S_PCIE_HCMD_0: begin
			next_state <= S_PCIE_HCMD_1;
		end
		S_PCIE_HCMD_1: begin
			next_state <= S_PCIE_HCMD_2;
		end
		S_PCIE_HCMD_2: begin
			next_state <= S_PCIE_HCMD_3;
		end
		S_PCIE_HCMD_3: begin
			next_state <= S_PCIE_NLB;
		end
		S_PCIE_NLB: begin
			next_state <= S_PCIE_NLB_WAIT;
		end
		S_PCIE_NLB_WAIT: begin
			if(hcmd_nlb_wr0_rdy_n == 1 || hcmd_sq_full_n == 0)
				next_state <= S_PCIE_NLB_WAIT;
			else
				next_state <= S_PCIE_HCMD_DONE;
		end
		S_PCIE_HCMD_DONE: begin
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
		r_hcmd_num <= 0;
	end
	else begin
		case(cur_state)
			S_IDLE: begin

			end
			S_SQ_CMD: begin

			end
			S_CHECK_FIFO: begin

			end
			S_PCIE_HCMD_0: begin

			end
			S_PCIE_HCMD_1: begin

			end
			S_PCIE_HCMD_2: begin

			end
			S_PCIE_HCMD_3: begin

			end
			S_PCIE_NLB: begin

			end
			S_PCIE_NLB_WAIT: begin

			end
			S_PCIE_HCMD_DONE: begin
				r_hcmd_num <= r_hcmd_num + 1;
			end
			default: begin

			end
		endcase
	end
end

always @ (posedge pcie_user_clk)
begin
	case(cur_state)
		S_IDLE: begin

		end
		S_SQ_CMD: begin
			r_sq_qid <= pcie_sq_cmd_fifo_rd_data[10:7];
			r_hcmd_slot_tag <= pcie_sq_cmd_fifo_rd_data[6:0];
		end
		S_CHECK_FIFO: begin

		end
		S_PCIE_HCMD_0: begin

		end
		S_PCIE_HCMD_1: begin
			r_hcmd_prp1[63:2] <= pcie_sq_rx_fifo_rd_data[127:66];
		end
		S_PCIE_HCMD_2: begin
			r_hcmd_prp2[63:2] <= pcie_sq_rx_fifo_rd_data[63:2];
			r_hcmd_slba <= pcie_sq_rx_fifo_rd_data[66:64];
		end
		S_PCIE_HCMD_3: begin
			r_hcmd_nlb <= {1'b0, pcie_sq_rx_fifo_rd_data[7:0]};
		end
		S_PCIE_NLB: begin
			r_hcmd_nlb <= r_hcmd_nlb + 1;
		end
		S_PCIE_NLB_WAIT: begin
			case(r_sq_qid) // synthesis parallel_case full_case
				4'h0: r_sq_valid_entry <= 9'b000000001;
				4'h1: r_sq_valid_entry <= 9'b000000010;
				4'h2: r_sq_valid_entry <= 9'b000000100;
				4'h3: r_sq_valid_entry <= 9'b000001000;
				4'h4: r_sq_valid_entry <= 9'b000010000;
				4'h5: r_sq_valid_entry <= 9'b000100000;
				4'h6: r_sq_valid_entry <= 9'b001000000;
				4'h7: r_sq_valid_entry <= 9'b010000000;
				4'h8: r_sq_valid_entry <= 9'b100000000;
			endcase
		end
		S_PCIE_HCMD_DONE: begin

		end
		default: begin

		end
	endcase
end

always @ (posedge pcie_user_clk)
begin
	r_pcie_sq_rx_fifo_rd_data <= pcie_sq_rx_fifo_rd_data;
end

always @ (*)
begin
	case(cur_state)
		S_IDLE: begin
			r_pcie_sq_cmd_fifo_rd_en <= 0;
			r_pcie_sq_rx_fifo_rd_en <= 0;
			r_pcie_sq_rx_fifo_free_en <= 0;
			r_hcmd_table_wr_en <= 0;
			r_hcmd_table_addr <= 2'b00;
			r_hcmd_cid_wr_en <= 0;
			r_hcmd_prp_wr_en <= 0;
			r_hcmd_prp_sel <= 0;
			r_hcmd_nlb_wr0_en <= 0;
			r_hcmd_sq_wr_en <= 0;
			r_sq_update_entry <= 0;
		end
		S_SQ_CMD: begin
			r_pcie_sq_cmd_fifo_rd_en <= 1;
			r_pcie_sq_rx_fifo_rd_en <= 0;
			r_pcie_sq_rx_fifo_free_en <= 0;
			r_hcmd_table_wr_en <= 0;
			r_hcmd_table_addr <= 2'b00;
			r_hcmd_cid_wr_en <= 0;
			r_hcmd_prp_wr_en <= 0;
			r_hcmd_prp_sel <= 0;
			r_hcmd_nlb_wr0_en <= 0;
			r_hcmd_sq_wr_en <= 0;
			r_sq_update_entry <= 0;
		end
		S_CHECK_FIFO: begin
			r_pcie_sq_cmd_fifo_rd_en <= 0;
			r_pcie_sq_rx_fifo_rd_en <= 0;
			r_pcie_sq_rx_fifo_free_en <= 0;
			r_hcmd_table_wr_en <= 0;
			r_hcmd_table_addr <= 2'b00;
			r_hcmd_cid_wr_en <= 0;
			r_hcmd_prp_wr_en <= 0;
			r_hcmd_prp_sel <= 0;
			r_hcmd_nlb_wr0_en <= 0;
			r_hcmd_sq_wr_en <= 0;
			r_sq_update_entry <= 0;
		end
		S_PCIE_HCMD_0: begin
			r_pcie_sq_cmd_fifo_rd_en <= 0;
			r_pcie_sq_rx_fifo_rd_en <= 1;
			r_pcie_sq_rx_fifo_free_en <= 1;
			r_hcmd_table_wr_en <= 0;
			r_hcmd_table_addr <= 2'b00;
			r_hcmd_cid_wr_en <= 0;
			r_hcmd_prp_wr_en <= 0;
			r_hcmd_prp_sel <= 0;
			r_hcmd_nlb_wr0_en <= 0;
			r_hcmd_sq_wr_en <= 0;
			r_sq_update_entry <= 0;
		end
		S_PCIE_HCMD_1: begin
			r_pcie_sq_cmd_fifo_rd_en <= 0;
			r_pcie_sq_rx_fifo_rd_en <= 1;
			r_pcie_sq_rx_fifo_free_en <= 0;
			r_hcmd_table_wr_en <= 1;
			r_hcmd_table_addr <= 2'b00;
			r_hcmd_cid_wr_en <= 1;
			r_hcmd_prp_wr_en <= 0;
			r_hcmd_prp_sel <= 0;
			r_hcmd_nlb_wr0_en <= 0;
			r_hcmd_sq_wr_en <= 0;
			r_sq_update_entry <= 0;
		end
		S_PCIE_HCMD_2: begin
			r_pcie_sq_cmd_fifo_rd_en <= 0;
			r_pcie_sq_rx_fifo_rd_en <= 1;
			r_pcie_sq_rx_fifo_free_en <= 0;
			r_hcmd_table_wr_en <= 1;
			r_hcmd_table_addr <= 2'b01;
			r_hcmd_cid_wr_en <= 0;
			r_hcmd_prp_wr_en <= 0;
			r_hcmd_prp_sel <= 0;
			r_hcmd_nlb_wr0_en <= 0;
			r_hcmd_sq_wr_en <= 0;
			r_sq_update_entry <= 0;
		end
		S_PCIE_HCMD_3: begin
			r_pcie_sq_cmd_fifo_rd_en <= 0;
			r_pcie_sq_rx_fifo_rd_en <= 1;
			r_pcie_sq_rx_fifo_free_en <= 0;
			r_hcmd_table_wr_en <= 1;
			r_hcmd_table_addr <= 2'b10;
			r_hcmd_cid_wr_en <= 0;
			r_hcmd_prp_wr_en <= 1;
			r_hcmd_prp_sel <= 0;
			r_hcmd_nlb_wr0_en <= 0;
			r_hcmd_sq_wr_en <= 0;
			r_sq_update_entry <= 0;
		end
		S_PCIE_NLB: begin
			r_pcie_sq_cmd_fifo_rd_en <= 0;
			r_pcie_sq_rx_fifo_rd_en <= 0;
			r_pcie_sq_rx_fifo_free_en <= 0;
			r_hcmd_table_wr_en <= 1;
			r_hcmd_table_addr <= 2'b11;
			r_hcmd_cid_wr_en <= 0;
			r_hcmd_nlb_wr0_en <= 0;
			r_hcmd_prp_wr_en <= 1;
			r_hcmd_prp_sel <= 1;
			r_hcmd_sq_wr_en <= 0;
			r_sq_update_entry <= 0;
		end
		S_PCIE_NLB_WAIT: begin
			r_pcie_sq_cmd_fifo_rd_en <= 0;
			r_pcie_sq_rx_fifo_rd_en <= 0;
			r_pcie_sq_rx_fifo_free_en <= 0;
			r_hcmd_table_wr_en <= 0;
			r_hcmd_table_addr <= 2'b00;
			r_hcmd_cid_wr_en <= 0;
			r_hcmd_nlb_wr0_en <= 0;
			r_hcmd_prp_wr_en <= 0;
			r_hcmd_prp_sel <= 0;
			r_hcmd_sq_wr_en <= 0;
			r_sq_update_entry <= 0;
		end
		S_PCIE_HCMD_DONE: begin
			r_pcie_sq_cmd_fifo_rd_en <= 0;
			r_pcie_sq_rx_fifo_rd_en <= 0;
			r_pcie_sq_rx_fifo_free_en <= 0;
			r_hcmd_table_wr_en <= 0;
			r_hcmd_table_addr <= 2'b00;
			r_hcmd_cid_wr_en <= 0;
			r_hcmd_prp_wr_en <= 0;
			r_hcmd_prp_sel <= 0;
			r_hcmd_nlb_wr0_en <= 1;
			r_hcmd_sq_wr_en <= 1;
			r_sq_update_entry <= r_sq_valid_entry;
		end
		default: begin
			r_pcie_sq_cmd_fifo_rd_en <= 0;
			r_pcie_sq_rx_fifo_rd_en <= 0;
			r_pcie_sq_rx_fifo_free_en <= 0;
			r_hcmd_table_wr_en <= 0;
			r_hcmd_table_addr <= 2'b00;
			r_hcmd_cid_wr_en <= 0;
			r_hcmd_prp_wr_en <= 0;
			r_hcmd_prp_sel <= 0;
			r_hcmd_nlb_wr0_en <= 0;
			r_hcmd_sq_wr_en <= 0;
			r_sq_update_entry <= 0;
		end
	endcase
end


assign admin_sq_head_ptr = r_admin_sq_head_ptr;
assign io_sq1_head_ptr = r_io_sq1_head_ptr;
assign io_sq2_head_ptr = r_io_sq2_head_ptr;
assign io_sq3_head_ptr = r_io_sq3_head_ptr;
assign io_sq4_head_ptr = r_io_sq4_head_ptr;
assign io_sq5_head_ptr = r_io_sq5_head_ptr;
assign io_sq6_head_ptr = r_io_sq6_head_ptr;
assign io_sq7_head_ptr = r_io_sq7_head_ptr;
assign io_sq8_head_ptr = r_io_sq8_head_ptr;

assign w_sq_rst_n[0] = pcie_user_rst_n & sq_rst_n[0];
assign w_sq_rst_n[1] = pcie_user_rst_n & sq_rst_n[1];
assign w_sq_rst_n[2] = pcie_user_rst_n & sq_rst_n[2];
assign w_sq_rst_n[3] = pcie_user_rst_n & sq_rst_n[3];
assign w_sq_rst_n[4] = pcie_user_rst_n & sq_rst_n[4];
assign w_sq_rst_n[5] = pcie_user_rst_n & sq_rst_n[5];
assign w_sq_rst_n[6] = pcie_user_rst_n & sq_rst_n[6];
assign w_sq_rst_n[7] = pcie_user_rst_n & sq_rst_n[7];
assign w_sq_rst_n[8] = pcie_user_rst_n & sq_rst_n[8];

always @ (posedge pcie_user_clk or negedge w_sq_rst_n[0])
begin
	if(w_sq_rst_n[0] == 0) begin
		r_admin_sq_head_ptr <= 0;
	end
	else begin
		if(r_sq_update_entry[0] == 1) begin
			if(r_admin_sq_head_ptr == admin_sq_size) begin
				r_admin_sq_head_ptr <= 0;
			end
			else begin
				r_admin_sq_head_ptr <= r_admin_sq_head_ptr + 1;
			end
		end
	end
end

always @ (posedge pcie_user_clk or negedge w_sq_rst_n[1])
begin
	if(w_sq_rst_n[1] == 0) begin
		r_io_sq1_head_ptr <= 0;
	end
	else begin
		if(r_sq_update_entry[1] == 1) begin
			if(r_io_sq1_head_ptr == io_sq1_size) begin
				r_io_sq1_head_ptr <= 0;
			end
			else begin
				r_io_sq1_head_ptr <= r_io_sq1_head_ptr + 1;
			end
		end
	end
end

always @ (posedge pcie_user_clk or negedge w_sq_rst_n[2])
begin
	if(w_sq_rst_n[2] == 0) begin
		r_io_sq2_head_ptr <= 0;
	end
	else begin
		if(r_sq_update_entry[2] == 1) begin
			if(r_io_sq2_head_ptr == io_sq2_size) begin
				r_io_sq2_head_ptr <= 0;
			end
			else begin
				r_io_sq2_head_ptr <= r_io_sq2_head_ptr + 1;
			end
		end
	end
end

always @ (posedge pcie_user_clk or negedge w_sq_rst_n[3])
begin
	if(w_sq_rst_n[3] == 0) begin
		r_io_sq3_head_ptr <= 0;
	end
	else begin
		if(r_sq_update_entry[3] == 1) begin
			if(r_io_sq3_head_ptr == io_sq3_size) begin
				r_io_sq3_head_ptr <= 0;
			end
			else begin
				r_io_sq3_head_ptr <= r_io_sq3_head_ptr + 1;
			end
		end
	end
end

always @ (posedge pcie_user_clk or negedge w_sq_rst_n[4])
begin
	if(w_sq_rst_n[4] == 0) begin
		r_io_sq4_head_ptr <= 0;
	end
	else begin
		if(r_sq_update_entry[4] == 1) begin
			if(r_io_sq4_head_ptr == io_sq4_size) begin
				r_io_sq4_head_ptr <= 0;
			end
			else begin
				r_io_sq4_head_ptr <= r_io_sq4_head_ptr + 1;
			end
		end
	end
end

always @ (posedge pcie_user_clk or negedge w_sq_rst_n[5])
begin
	if(w_sq_rst_n[5] == 0) begin
		r_io_sq5_head_ptr <= 0;
	end
	else begin
		if(r_sq_update_entry[5] == 1) begin
			if(r_io_sq5_head_ptr == io_sq5_size) begin
				r_io_sq5_head_ptr <= 0;
			end
			else begin
				r_io_sq5_head_ptr <= r_io_sq5_head_ptr + 1;
			end
		end
	end
end

always @ (posedge pcie_user_clk or negedge w_sq_rst_n[6])
begin
	if(w_sq_rst_n[6] == 0) begin
		r_io_sq6_head_ptr <= 0;
	end
	else begin
		if(r_sq_update_entry[6] == 1) begin
			if(r_io_sq6_head_ptr == io_sq6_size) begin
				r_io_sq6_head_ptr <= 0;
			end
			else begin
				r_io_sq6_head_ptr <= r_io_sq6_head_ptr + 1;
			end
		end
	end
end

always @ (posedge pcie_user_clk or negedge w_sq_rst_n[7])
begin
	if(w_sq_rst_n[7] == 0) begin
		r_io_sq7_head_ptr <= 0;
	end
	else begin
		if(r_sq_update_entry[7] == 1) begin
			if(r_io_sq7_head_ptr == io_sq7_size) begin
				r_io_sq7_head_ptr <= 0;
			end
			else begin
				r_io_sq7_head_ptr <= r_io_sq7_head_ptr + 1;
			end
		end
	end
end

always @ (posedge pcie_user_clk or negedge w_sq_rst_n[8])
begin
	if(w_sq_rst_n[8] == 0) begin
		r_io_sq8_head_ptr <= 0;
	end
	else begin
		if(r_sq_update_entry[8] == 1) begin
			if(r_io_sq8_head_ptr == io_sq8_size) begin
				r_io_sq8_head_ptr <= 0;
			end
			else begin
				r_io_sq8_head_ptr <= r_io_sq8_head_ptr + 1;
			end
		end
	end
end


endmodule
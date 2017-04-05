
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


module pcie_hcmd_cq_req # (
	parameter	C_PCIE_DATA_WIDTH			= 128,
	parameter	C_PCIE_ADDR_WIDTH			= 36
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,

	output									hcmd_cq_rd_en,
	input	[34:0]							hcmd_cq_rd_data,
	input									hcmd_cq_empty_n,

	output	[6:0]							hcmd_cid_rd_addr,
	input	[19:0]							hcmd_cid_rd_data,

	input	[3:0]							io_sq1_cq_vec,
	input	[3:0]							io_sq2_cq_vec,
	input	[3:0]							io_sq3_cq_vec,
	input	[3:0]							io_sq4_cq_vec,
	input	[3:0]							io_sq5_cq_vec,
	input	[3:0]							io_sq6_cq_vec,
	input	[3:0]							io_sq7_cq_vec,
	input	[3:0]							io_sq8_cq_vec,

	input	[8:0]							sq_valid,
	input	[8:0]							cq_rst_n,
	input	[8:0]							cq_valid,
	input	[7:0]							admin_cq_size,
	input	[7:0]							io_cq1_size,
	input	[7:0]							io_cq2_size,
	input	[7:0]							io_cq3_size,
	input	[7:0]							io_cq4_size,
	input	[7:0]							io_cq5_size,
	input	[7:0]							io_cq6_size,
	input	[7:0]							io_cq7_size,
	input	[7:0]							io_cq8_size,
	input	[C_PCIE_ADDR_WIDTH-1:2]			admin_cq_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_cq1_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_cq2_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_cq3_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_cq4_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_cq5_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_cq6_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_cq7_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_cq8_bs_addr,

	output	[7:0]							admin_cq_tail_ptr,
	output	[7:0]							io_cq1_tail_ptr,
	output	[7:0]							io_cq2_tail_ptr,
	output	[7:0]							io_cq3_tail_ptr,
	output	[7:0]							io_cq4_tail_ptr,
	output	[7:0]							io_cq5_tail_ptr,
	output	[7:0]							io_cq6_tail_ptr,
	output	[7:0]							io_cq7_tail_ptr,
	output	[7:0]							io_cq8_tail_ptr,

	input	[7:0]							admin_sq_head_ptr,
	input	[7:0]							io_sq1_head_ptr,
	input	[7:0]							io_sq2_head_ptr,
	input	[7:0]							io_sq3_head_ptr,
	input	[7:0]							io_sq4_head_ptr,
	input	[7:0]							io_sq5_head_ptr,
	input	[7:0]							io_sq6_head_ptr,
	input	[7:0]							io_sq7_head_ptr,
	input	[7:0]							io_sq8_head_ptr,

	output									hcmd_slot_free_en,
	output	[6:0]							hcmd_slot_invalid_tag,

	output									tx_cq_mwr_req,
	output	[7:0]							tx_cq_mwr_tag,
	output	[11:2]							tx_cq_mwr_len,
	output	[C_PCIE_ADDR_WIDTH-1:2]			tx_cq_mwr_addr,
	input									tx_cq_mwr_req_ack,
	input									tx_cq_mwr_rd_en,
	output	[C_PCIE_DATA_WIDTH-1:0]			tx_cq_mwr_rd_data,
	input									tx_cq_mwr_data_last
);

localparam	LP_CPL_PCIE_TAG_PREFIX			= 8'b00000000;
localparam	LP_CPL_SIZE						= 10'h04;


localparam	S_IDLE							= 11'b00000000001;
localparam	S_CPL_STATUS0					= 11'b00000000010;
localparam	S_CPL_STATUS1					= 11'b00000000100;
localparam	S_CPL_STATUS2					= 11'b00000001000;
localparam	S_CPL_STATUS3					= 11'b00000010000;
localparam	S_HEAD_PTR						= 11'b00000100000;
localparam	S_PCIE_ADDR						= 11'b00001000000;
localparam	S_PCIE_MWR_REQ					= 11'b00010000000;
localparam	S_PCIE_MWR_DATA_LAST			= 11'b00100000000;
localparam	S_PCIE_MWR_DONE					= 11'b01000000000;
localparam	S_PCIE_SLOT_RELEASE				= 11'b10000000000;

reg		[10:0]								cur_state;
reg		[10:0]								next_state;

reg											r_sq_is_valid;
reg											r_cq_is_valid;

reg		[7:0]								r_admin_cq_tail_ptr;
reg		[7:0]								r_io_cq1_tail_ptr;
reg		[7:0]								r_io_cq2_tail_ptr;
reg		[7:0]								r_io_cq3_tail_ptr;
reg		[7:0]								r_io_cq4_tail_ptr;
reg		[7:0]								r_io_cq5_tail_ptr;
reg		[7:0]								r_io_cq6_tail_ptr;
reg		[7:0]								r_io_cq7_tail_ptr;
reg		[7:0]								r_io_cq8_tail_ptr;
reg		[8:0]								r_cq_phase_tag;

reg		[3:0]								r_sq_cq_vec;
reg		[8:0]								r_cq_valid_entry;
reg		[8:0]								r_cq_update_entry;

reg											r_hcmd_cq_rd_en;
wire	[6:0]								w_hcmd_slot_tag;
reg											r_hcmd_slot_free_en;

reg		[1:0]								r_cql_type;
reg		[19:0]								r_cql_info;
reg		[3:0]								r_cpl_sq_qid;
reg		[15:0]								r_cpl_cid;
reg		[14:0]								r_cpl_status;
reg		[31:0]								r_cpl_specific;
reg		[7:0]								r_cq_tail_ptr;
reg		[7:0]								r_sq_head_ptr;
reg											r_phase_tag;

reg											r_tx_cq_mwr_req;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_tx_cq_mwr_addr;
wire	[31:0]								w_cpl_dw0;
wire	[31:0]								w_cpl_dw1;
wire	[31:0]								w_cpl_dw2;
wire	[31:0]								w_cpl_dw3;

wire	[8:0]								w_cq_rst_n;

assign admin_cq_tail_ptr = r_admin_cq_tail_ptr;
assign io_cq1_tail_ptr = r_io_cq1_tail_ptr;
assign io_cq2_tail_ptr = r_io_cq2_tail_ptr;
assign io_cq3_tail_ptr = r_io_cq3_tail_ptr;
assign io_cq4_tail_ptr = r_io_cq4_tail_ptr;
assign io_cq5_tail_ptr = r_io_cq5_tail_ptr;
assign io_cq6_tail_ptr = r_io_cq6_tail_ptr;
assign io_cq7_tail_ptr = r_io_cq7_tail_ptr;
assign io_cq8_tail_ptr = r_io_cq8_tail_ptr;

assign hcmd_cq_rd_en = r_hcmd_cq_rd_en;
assign hcmd_cid_rd_addr = w_hcmd_slot_tag;
assign hcmd_slot_free_en = r_hcmd_slot_free_en;
assign hcmd_slot_invalid_tag = w_hcmd_slot_tag;

assign w_cpl_dw0 = r_cpl_specific;
assign w_cpl_dw1 = 0;
assign w_cpl_dw2 = {12'b0, r_cpl_sq_qid, 8'b0, r_sq_head_ptr};
assign w_cpl_dw3 = {r_cpl_status, r_phase_tag, r_cpl_cid};

assign tx_cq_mwr_req = r_tx_cq_mwr_req;
assign tx_cq_mwr_tag = LP_CPL_PCIE_TAG_PREFIX;
assign tx_cq_mwr_len = LP_CPL_SIZE;
assign tx_cq_mwr_addr = r_tx_cq_mwr_addr;
assign tx_cq_mwr_rd_data = {w_cpl_dw3, w_cpl_dw2, w_cpl_dw1, w_cpl_dw0};

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
			if(hcmd_cq_empty_n == 1)
				next_state <= S_CPL_STATUS0;
			else
				next_state <= S_IDLE;
		end
		S_CPL_STATUS0: begin
			next_state <= S_CPL_STATUS1;
		end
		S_CPL_STATUS1: begin
			if(r_cql_type[0] == 1)
				next_state <= S_CPL_STATUS2;
			else if(r_cql_type[1] == 1)
				next_state <= S_PCIE_SLOT_RELEASE;
			else
				next_state <= S_CPL_STATUS3;
		end
		S_CPL_STATUS2: begin
			next_state <= S_CPL_STATUS3;
		end
		S_CPL_STATUS3: begin
			next_state <= S_HEAD_PTR;
		end
		S_HEAD_PTR: begin
			if(r_sq_is_valid == 1)
				next_state <= S_PCIE_ADDR;
			else
				next_state <= S_IDLE;
		end
		S_PCIE_ADDR: begin
			if(r_cq_is_valid == 1)
				next_state <= S_PCIE_MWR_REQ;
			else
				next_state <= S_IDLE;
		end
		S_PCIE_MWR_REQ: begin
			next_state <= S_PCIE_MWR_DATA_LAST;
		end
		S_PCIE_MWR_DATA_LAST: begin
			if(tx_cq_mwr_data_last == 1)
				next_state <= S_PCIE_MWR_DONE;
			else
				next_state <= S_PCIE_MWR_DATA_LAST;
		end
		S_PCIE_MWR_DONE: begin
			if(r_cql_type[0] == 1)
				next_state <= S_PCIE_SLOT_RELEASE;
			else
				next_state <= S_IDLE;
		end
		S_PCIE_SLOT_RELEASE: begin
			next_state <= S_IDLE;
		end
		default: begin
			next_state <= S_IDLE;
		end
	endcase
end

assign w_hcmd_slot_tag = r_cql_info[6:0];

always @ (posedge pcie_user_clk)
begin
	case(cur_state)
		S_IDLE: begin

		end
		S_CPL_STATUS0: begin
			r_cql_type <= hcmd_cq_rd_data[1:0];
			r_cql_info <= hcmd_cq_rd_data[21:2];
			r_cpl_status[12:0] <= hcmd_cq_rd_data[34:22];
		end
		S_CPL_STATUS1: begin
			r_cpl_cid <= r_cql_info[15:0];
			r_cpl_sq_qid <= r_cql_info[19:16];
			r_cpl_status[14:13] <= hcmd_cq_rd_data[1:0];
			r_cpl_specific[31:0] <= hcmd_cq_rd_data[33:2];
		end
		S_CPL_STATUS2: begin
			r_cpl_cid <= hcmd_cid_rd_data[15:0];
			r_cpl_sq_qid <= hcmd_cid_rd_data[19:16];
		end
		S_CPL_STATUS3: begin
			case(r_cpl_sq_qid) // synthesis parallel_case full_case
				4'h0: begin
					r_sq_is_valid <= sq_valid[0];
					r_sq_cq_vec <= 4'h0;
					r_sq_head_ptr <= admin_sq_head_ptr;
				end
				4'h1: begin
					r_sq_is_valid <= sq_valid[1];
					r_sq_cq_vec <= io_sq1_cq_vec;
					r_sq_head_ptr <= io_sq1_head_ptr;
				end
				4'h2: begin
					r_sq_is_valid <= sq_valid[2];
					r_sq_cq_vec <= io_sq2_cq_vec;
					r_sq_head_ptr <= io_sq2_head_ptr;
				end
				4'h3: begin
					r_sq_is_valid <= sq_valid[3];
					r_sq_cq_vec <= io_sq3_cq_vec;
					r_sq_head_ptr <= io_sq3_head_ptr;
				end
				4'h4: begin
					r_sq_is_valid <= sq_valid[4];
					r_sq_cq_vec <= io_sq4_cq_vec;
					r_sq_head_ptr <= io_sq4_head_ptr;
				end
				4'h5: begin
					r_sq_is_valid <= sq_valid[5];
					r_sq_cq_vec <= io_sq5_cq_vec;
					r_sq_head_ptr <= io_sq5_head_ptr;
				end
				4'h6: begin
					r_sq_is_valid <= sq_valid[6];
					r_sq_cq_vec <= io_sq6_cq_vec;
					r_sq_head_ptr <= io_sq6_head_ptr;
				end
				4'h7: begin
					r_sq_is_valid <= sq_valid[7];
					r_sq_cq_vec <= io_sq7_cq_vec;
					r_sq_head_ptr <= io_sq7_head_ptr;
				end
				4'h8: begin
					r_sq_is_valid <= sq_valid[8];
					r_sq_cq_vec <= io_sq8_cq_vec;
					r_sq_head_ptr <= io_sq8_head_ptr;
				end
			endcase
		end
		S_HEAD_PTR: begin
			case(r_sq_cq_vec) // synthesis parallel_case full_case
				4'h0: begin
					r_cq_is_valid <= cq_valid[0];
					r_tx_cq_mwr_addr <= admin_cq_bs_addr;
					r_cq_tail_ptr <= r_admin_cq_tail_ptr;
					r_phase_tag <= r_cq_phase_tag[0];
					r_cq_valid_entry <= 9'b000000001;
				end
				4'h1: begin
					r_cq_is_valid <= cq_valid[1];
					r_tx_cq_mwr_addr <= io_cq1_bs_addr;
					r_cq_tail_ptr <= r_io_cq1_tail_ptr;
					r_phase_tag <= r_cq_phase_tag[1];
					r_cq_valid_entry <= 9'b000000010;
				end
				4'h2: begin
					r_cq_is_valid <= cq_valid[2];
					r_tx_cq_mwr_addr <= io_cq2_bs_addr;
					r_cq_tail_ptr <= r_io_cq2_tail_ptr;
					r_phase_tag <= r_cq_phase_tag[2];
					r_sq_head_ptr <= io_sq2_head_ptr;
					r_cq_valid_entry <= 9'b000000100;
				end
				4'h3: begin
					r_cq_is_valid <= cq_valid[3];
					r_tx_cq_mwr_addr <= io_cq3_bs_addr;
					r_cq_tail_ptr <= r_io_cq3_tail_ptr;
					r_phase_tag <= r_cq_phase_tag[3];
					r_sq_head_ptr <= io_sq3_head_ptr;
					r_cq_valid_entry <= 9'b000001000;
				end
				4'h4: begin
					r_cq_is_valid <= cq_valid[4];
					r_tx_cq_mwr_addr <= io_cq4_bs_addr;
					r_cq_tail_ptr <= r_io_cq4_tail_ptr;
					r_phase_tag <= r_cq_phase_tag[4];
					r_sq_head_ptr <= io_sq4_head_ptr;
					r_cq_valid_entry <= 9'b000010000;
				end
				4'h5: begin
					r_cq_is_valid <= cq_valid[5];
					r_tx_cq_mwr_addr <= io_cq5_bs_addr;
					r_cq_tail_ptr <= r_io_cq5_tail_ptr;
					r_phase_tag <= r_cq_phase_tag[5];
					r_sq_head_ptr <= io_sq5_head_ptr;
					r_cq_valid_entry <= 9'b000100000;
				end
				4'h6: begin
					r_cq_is_valid <= cq_valid[6];
					r_tx_cq_mwr_addr <= io_cq6_bs_addr;
					r_cq_tail_ptr <= r_io_cq6_tail_ptr;
					r_phase_tag <= r_cq_phase_tag[6];
					r_sq_head_ptr <= io_sq6_head_ptr;
					r_cq_valid_entry <= 9'b001000000;
				end
				4'h7: begin
					r_cq_is_valid <= cq_valid[7];
					r_tx_cq_mwr_addr <= io_cq7_bs_addr;
					r_cq_tail_ptr <= r_io_cq7_tail_ptr;
					r_phase_tag <= r_cq_phase_tag[7];
					r_sq_head_ptr <= io_sq7_head_ptr;
					r_cq_valid_entry <= 9'b010000000;
				end
				4'h8: begin
					r_cq_is_valid <= cq_valid[8];
					r_tx_cq_mwr_addr <= io_cq8_bs_addr;
					r_cq_tail_ptr <= r_io_cq8_tail_ptr;
					r_phase_tag <= r_cq_phase_tag[8];
					r_sq_head_ptr <= io_sq8_head_ptr;
					r_cq_valid_entry <= 9'b100000000;
				end
			endcase
		end
		S_PCIE_ADDR: begin
			r_tx_cq_mwr_addr <= r_tx_cq_mwr_addr + {r_cq_tail_ptr, 2'b0};
			r_cq_tail_ptr <= r_cq_tail_ptr + 1;
		end
		S_PCIE_MWR_REQ: begin

		end
		S_PCIE_MWR_DATA_LAST: begin

		end
		S_PCIE_MWR_DONE: begin

		end
		S_PCIE_SLOT_RELEASE: begin
			
		end
		default: begin

		end
	endcase
end



always @ (*)
begin
	case(cur_state)
		S_IDLE: begin
			r_hcmd_cq_rd_en <= 0;
			r_tx_cq_mwr_req <= 0;
			r_cq_update_entry <= 0;
			r_hcmd_slot_free_en <= 0;
		end
		S_CPL_STATUS0: begin
			r_hcmd_cq_rd_en <= 1;
			r_tx_cq_mwr_req <= 0;
			r_cq_update_entry <= 0;
			r_hcmd_slot_free_en <= 0;
		end
		S_CPL_STATUS1: begin
			r_hcmd_cq_rd_en <= 1;
			r_tx_cq_mwr_req <= 0;
			r_cq_update_entry <= 0;
			r_hcmd_slot_free_en <= 0;
		end
		S_CPL_STATUS2: begin
			r_hcmd_cq_rd_en <= 0;
			r_tx_cq_mwr_req <= 0;
			r_cq_update_entry <= 0;
			r_hcmd_slot_free_en <= 0;
		end
		S_CPL_STATUS3: begin
			r_hcmd_cq_rd_en <= 0;
			r_tx_cq_mwr_req <= 0;
			r_cq_update_entry <= 0;
			r_hcmd_slot_free_en <= 0;
		end
		S_HEAD_PTR: begin
			r_hcmd_cq_rd_en <= 0;
			r_tx_cq_mwr_req <= 0;
			r_cq_update_entry <= 0;
			r_hcmd_slot_free_en <= 0;
		end
		S_PCIE_ADDR: begin
			r_hcmd_cq_rd_en <= 0;
			r_tx_cq_mwr_req <= 0;
			r_cq_update_entry <= 0;
			r_hcmd_slot_free_en <= 0;
		end
		S_PCIE_MWR_REQ: begin
			r_hcmd_cq_rd_en <= 0;
			r_tx_cq_mwr_req <= 1;
			r_cq_update_entry <= 0;
			r_hcmd_slot_free_en <= 0;
		end
		S_PCIE_MWR_DATA_LAST: begin
			r_hcmd_cq_rd_en <= 0;
			r_tx_cq_mwr_req <= 0;
			r_cq_update_entry <= 0;
			r_hcmd_slot_free_en <= 0;
		end
		S_PCIE_MWR_DONE: begin
			r_hcmd_cq_rd_en <= 0;
			r_tx_cq_mwr_req <= 0;
			r_cq_update_entry <= r_cq_valid_entry;
			r_hcmd_slot_free_en <= 0;
		end
		S_PCIE_SLOT_RELEASE: begin
			r_hcmd_cq_rd_en <= 0;
			r_tx_cq_mwr_req <= 0;
			r_cq_update_entry <= 0;
			r_hcmd_slot_free_en <= 1;
		end
		default: begin
			r_hcmd_cq_rd_en <= 0;
			r_tx_cq_mwr_req <= 0;
			r_cq_update_entry <= 0;
			r_hcmd_slot_free_en <= 0;
		end
	endcase
end


assign w_cq_rst_n[0] = pcie_user_rst_n & cq_rst_n[0];
assign w_cq_rst_n[1] = pcie_user_rst_n & cq_rst_n[1];
assign w_cq_rst_n[2] = pcie_user_rst_n & cq_rst_n[2];
assign w_cq_rst_n[3] = pcie_user_rst_n & cq_rst_n[3];
assign w_cq_rst_n[4] = pcie_user_rst_n & cq_rst_n[4];
assign w_cq_rst_n[5] = pcie_user_rst_n & cq_rst_n[5];
assign w_cq_rst_n[6] = pcie_user_rst_n & cq_rst_n[6];
assign w_cq_rst_n[7] = pcie_user_rst_n & cq_rst_n[7];
assign w_cq_rst_n[8] = pcie_user_rst_n & cq_rst_n[8];

always @ (posedge pcie_user_clk or negedge w_cq_rst_n[0])
begin
	if(w_cq_rst_n[0] == 0) begin
		r_admin_cq_tail_ptr <= 0;
		r_cq_phase_tag[0] <= 1;
	end
	else begin
		if(r_cq_update_entry[0] == 1) begin
			if(r_admin_cq_tail_ptr == admin_cq_size) begin
				r_admin_cq_tail_ptr <= 0;
				r_cq_phase_tag[0] <= ~r_cq_phase_tag[0];
			end
			else begin
				r_admin_cq_tail_ptr <= r_cq_tail_ptr;
			end
		end
	end
end

always @ (posedge pcie_user_clk or negedge w_cq_rst_n[1])
begin
	if(w_cq_rst_n[1] == 0) begin
		r_io_cq1_tail_ptr <= 0;
		r_cq_phase_tag[1] <= 1;
	end
	else begin
		if(r_cq_update_entry[1] == 1) begin
			if(r_io_cq1_tail_ptr == io_cq1_size) begin
				r_io_cq1_tail_ptr <= 0;
				r_cq_phase_tag[1] <= ~r_cq_phase_tag[1];
			end
			else begin
				r_io_cq1_tail_ptr <= r_cq_tail_ptr;
			end
		end
	end
end

always @ (posedge pcie_user_clk or negedge w_cq_rst_n[2])
begin
	if(w_cq_rst_n[2] == 0) begin
		r_io_cq2_tail_ptr <= 0;
		r_cq_phase_tag[2] <= 1;
	end
	else begin
		if(r_cq_update_entry[2] == 1) begin
			if(r_io_cq2_tail_ptr == io_cq2_size) begin
				r_io_cq2_tail_ptr <= 0;
				r_cq_phase_tag[2] <= ~r_cq_phase_tag[2];
			end
			else begin
				r_io_cq2_tail_ptr <= r_cq_tail_ptr;
			end
		end
	end
end

always @ (posedge pcie_user_clk or negedge w_cq_rst_n[3])
begin
	if(w_cq_rst_n[3] == 0) begin
		r_io_cq3_tail_ptr <= 0;
		r_cq_phase_tag[3] <= 1;
	end
	else begin
		if(r_cq_update_entry[3] == 1) begin
			if(r_io_cq3_tail_ptr == io_cq3_size) begin
				r_io_cq3_tail_ptr <= 0;
				r_cq_phase_tag[3] <= ~r_cq_phase_tag[3];
			end
			else begin
				r_io_cq3_tail_ptr <= r_cq_tail_ptr;
			end
		end
	end
end

always @ (posedge pcie_user_clk or negedge w_cq_rst_n[4])
begin
	if(w_cq_rst_n[4] == 0) begin
		r_io_cq4_tail_ptr <= 0;
		r_cq_phase_tag[4] <= 1;
	end
	else begin
		if(r_cq_update_entry[4] == 1) begin
			if(r_io_cq4_tail_ptr == io_cq4_size) begin
				r_io_cq4_tail_ptr <= 0;
				r_cq_phase_tag[4] <= ~r_cq_phase_tag[4];
			end
			else begin
				r_io_cq4_tail_ptr <= r_cq_tail_ptr;
			end
		end
	end
end

always @ (posedge pcie_user_clk or negedge w_cq_rst_n[5])
begin
	if(w_cq_rst_n[5] == 0) begin
		r_io_cq5_tail_ptr <= 0;
		r_cq_phase_tag[5] <= 1;
	end
	else begin
		if(r_cq_update_entry[5] == 1) begin
			if(r_io_cq5_tail_ptr == io_cq5_size) begin
				r_io_cq5_tail_ptr <= 0;
				r_cq_phase_tag[5] <= ~r_cq_phase_tag[5];
			end
			else begin
				r_io_cq5_tail_ptr <= r_cq_tail_ptr;
			end
		end
	end
end

always @ (posedge pcie_user_clk or negedge w_cq_rst_n[6])
begin
	if(w_cq_rst_n[6] == 0) begin
		r_io_cq6_tail_ptr <= 0;
		r_cq_phase_tag[6] <= 1;
	end
	else begin
		if(r_cq_update_entry[6] == 1) begin
			if(r_io_cq6_tail_ptr == io_cq6_size) begin
				r_io_cq6_tail_ptr <= 0;
				r_cq_phase_tag[6] <= ~r_cq_phase_tag[6];
			end
			else begin
				r_io_cq6_tail_ptr <= r_cq_tail_ptr;
			end
		end
	end
end

always @ (posedge pcie_user_clk or negedge w_cq_rst_n[7])
begin
	if(w_cq_rst_n[7] == 0) begin
		r_io_cq7_tail_ptr <= 0;
		r_cq_phase_tag[7] <= 1;
	end
	else begin
		if(r_cq_update_entry[7] == 1) begin
			if(r_io_cq7_tail_ptr == io_cq7_size) begin
				r_io_cq7_tail_ptr <= 0;
				r_cq_phase_tag[7] <= ~r_cq_phase_tag[7];
			end
			else begin
				r_io_cq7_tail_ptr <= r_cq_tail_ptr;
			end
		end
	end
end

always @ (posedge pcie_user_clk or negedge w_cq_rst_n[8])
begin
	if(w_cq_rst_n[8] == 0) begin
		r_io_cq8_tail_ptr <= 0;
		r_cq_phase_tag[8] <= 1;
	end
	else begin
		if(r_cq_update_entry[8] == 1) begin
			if(r_io_cq8_tail_ptr == io_cq8_size) begin
				r_io_cq8_tail_ptr <= 0;
				r_cq_phase_tag[8] <= ~r_cq_phase_tag[8];
			end
			else begin
				r_io_cq8_tail_ptr <= r_cq_tail_ptr;
			end
		end
	end
end

endmodule

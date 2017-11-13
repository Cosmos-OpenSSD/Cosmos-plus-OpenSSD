
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


module pcie_hcmd_sq_arb # (
	parameter	C_PCIE_DATA_WIDTH			= 128,
	parameter	C_PCIE_ADDR_WIDTH			= 36
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,

	input	[8:0]							sq_rst_n,
	input	[8:0]							sq_valid,

	input	[7:0]							admin_sq_size,
	input	[7:0]							io_sq1_size,
	input	[7:0]							io_sq2_size,
	input	[7:0]							io_sq3_size,
	input	[7:0]							io_sq4_size,
	input	[7:0]							io_sq5_size,
	input	[7:0]							io_sq6_size,
	input	[7:0]							io_sq7_size,
	input	[7:0]							io_sq8_size,

	input	[C_PCIE_ADDR_WIDTH-1:2]			admin_sq_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_sq1_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_sq2_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_sq3_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_sq4_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_sq5_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_sq6_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_sq7_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_sq8_bs_addr,

	input	[7:0]							admin_sq_tail_ptr,
	input	[7:0]							io_sq1_tail_ptr,
	input	[7:0]							io_sq2_tail_ptr,
	input	[7:0]							io_sq3_tail_ptr,
	input	[7:0]							io_sq4_tail_ptr,
	input	[7:0]							io_sq5_tail_ptr,
	input	[7:0]							io_sq6_tail_ptr,
	input	[7:0]							io_sq7_tail_ptr,
	input	[7:0]							io_sq8_tail_ptr,

	output									arb_sq_rdy,
	output	[3:0]							sq_qid,
	output	[C_PCIE_ADDR_WIDTH-1:2]			hcmd_pcie_addr,
	input									sq_hcmd_ack

);

localparam	S_ARB_HCMD						= 5'b00001;
localparam	S_LOAD_HEAD_PTR					= 5'b00010;
localparam	S_CALC_ADDR						= 5'b00100;
localparam	S_GNT_HCMD						= 5'b01000;
localparam	S_UPDATE_HEAD_PTR				= 5'b10000;

reg		[4:0]								cur_state;
reg		[4:0]								next_state;

reg		[7:0]								r_admin_sq_head_ptr;
reg		[7:0]								r_io_sq1_head_ptr;
reg		[7:0]								r_io_sq2_head_ptr;
reg		[7:0]								r_io_sq3_head_ptr;
reg		[7:0]								r_io_sq4_head_ptr;
reg		[7:0]								r_io_sq5_head_ptr;
reg		[7:0]								r_io_sq6_head_ptr;
reg		[7:0]								r_io_sq7_head_ptr;
reg		[7:0]								r_io_sq8_head_ptr;

reg											r_arb_sq_rdy;
reg		[3:0]								r_sq_qid;
reg		[7:0]								r_sq_head_ptr;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_hcmd_pcie_addr;


wire	[8:0]								w_sq_entry_valid;
wire										w_sq_entry_valid_ok;
reg		[8:0]								r_sq_entry_valid;
wire	[8:0]								w_sq_valid_mask;
reg		[8:0]								r_sq_update_entry;

wire	[8:0]								w_sq_rst_n;

assign arb_sq_rdy = r_arb_sq_rdy;
assign sq_qid = r_sq_qid;
assign hcmd_pcie_addr = r_hcmd_pcie_addr;

assign w_sq_entry_valid[0] = (r_admin_sq_head_ptr != admin_sq_tail_ptr) & sq_valid[0];
assign w_sq_entry_valid[1] = (r_io_sq1_head_ptr != io_sq1_tail_ptr) & sq_valid[1];
assign w_sq_entry_valid[2] = (r_io_sq2_head_ptr != io_sq2_tail_ptr) & sq_valid[2];
assign w_sq_entry_valid[3] = (r_io_sq3_head_ptr != io_sq3_tail_ptr) & sq_valid[3];
assign w_sq_entry_valid[4] = (r_io_sq4_head_ptr != io_sq4_tail_ptr) & sq_valid[4];
assign w_sq_entry_valid[5] = (r_io_sq5_head_ptr != io_sq5_tail_ptr) & sq_valid[5];
assign w_sq_entry_valid[6] = (r_io_sq6_head_ptr != io_sq6_tail_ptr) & sq_valid[6];
assign w_sq_entry_valid[7] = (r_io_sq7_head_ptr != io_sq7_tail_ptr) & sq_valid[7];
assign w_sq_entry_valid[8] = (r_io_sq8_head_ptr != io_sq8_tail_ptr) & sq_valid[8];

assign w_sq_valid_mask = {r_sq_entry_valid[7:0], r_sq_entry_valid[8]};
assign w_sq_entry_valid_ok = ((w_sq_entry_valid[8:1] & w_sq_valid_mask[8:1]) != 0) | w_sq_entry_valid[0];

always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0)
		cur_state <= S_ARB_HCMD;
	else
		cur_state <= next_state;
end

always @ (*)
begin
	case(cur_state)
		S_ARB_HCMD: begin
			if(w_sq_entry_valid_ok == 1)
				next_state <= S_LOAD_HEAD_PTR;
			else
				next_state <= S_ARB_HCMD;
		end
		S_LOAD_HEAD_PTR: begin
			next_state <= S_CALC_ADDR;
		end
		S_CALC_ADDR: begin
			next_state <= S_GNT_HCMD;
		end
		S_GNT_HCMD: begin
			if(sq_hcmd_ack == 1)
				next_state <= S_UPDATE_HEAD_PTR;
			else
				next_state <= S_GNT_HCMD;
		end
		S_UPDATE_HEAD_PTR: begin
			next_state <= S_ARB_HCMD;
		end
		default: begin
			next_state <= S_ARB_HCMD;
		end
	endcase
end

always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0) begin
		r_sq_entry_valid <= 1;
	end
	else begin
		case(cur_state)
			S_ARB_HCMD: begin
				if(w_sq_entry_valid[0] == 1)
					r_sq_entry_valid <= 1;
				else
					r_sq_entry_valid <= w_sq_valid_mask;
			end
			S_LOAD_HEAD_PTR: begin

			end
			S_CALC_ADDR: begin

			end
			S_GNT_HCMD: begin

			end
			S_UPDATE_HEAD_PTR: begin

			end
			default: begin

			end
		endcase
	end
end

always @ (posedge pcie_user_clk)
begin
	case(cur_state)
		S_ARB_HCMD: begin

		end
		S_LOAD_HEAD_PTR: begin
			case(r_sq_entry_valid) // synthesis parallel_case full_case
				9'b000000001: begin
					r_hcmd_pcie_addr <= admin_sq_bs_addr;
					r_sq_head_ptr <= r_admin_sq_head_ptr;
				end
				9'b000000010: begin
					r_hcmd_pcie_addr <= io_sq1_bs_addr;
					r_sq_head_ptr <= r_io_sq1_head_ptr;
				end
				9'b000000100: begin
					r_hcmd_pcie_addr <= io_sq2_bs_addr;
					r_sq_head_ptr <= r_io_sq2_head_ptr;
				end
				9'b000001000: begin
					r_hcmd_pcie_addr <= io_sq3_bs_addr;
					r_sq_head_ptr <= r_io_sq3_head_ptr;
				end
				9'b000010000: begin
					r_hcmd_pcie_addr <= io_sq4_bs_addr;
					r_sq_head_ptr <= r_io_sq4_head_ptr;
				end
				9'b000100000: begin
					r_hcmd_pcie_addr <= io_sq5_bs_addr;
					r_sq_head_ptr <= r_io_sq5_head_ptr;
				end
				9'b001000000: begin
					r_hcmd_pcie_addr <= io_sq6_bs_addr;
					r_sq_head_ptr <= r_io_sq6_head_ptr;
				end
				9'b010000000: begin
					r_hcmd_pcie_addr <= io_sq7_bs_addr;
					r_sq_head_ptr <= r_io_sq7_head_ptr;
				end
				9'b100000000: begin
					r_hcmd_pcie_addr <= io_sq8_bs_addr;
					r_sq_head_ptr <= r_io_sq8_head_ptr;
				end
			endcase
		end
		S_CALC_ADDR: begin
			r_hcmd_pcie_addr <= r_hcmd_pcie_addr + {r_sq_head_ptr, 4'b0};
			r_sq_head_ptr <= r_sq_head_ptr + 1;
		end
		S_GNT_HCMD: begin

		end
		S_UPDATE_HEAD_PTR: begin

		end
		default: begin

		end
	endcase
end

always @ (*)
begin
	case(cur_state)
		S_ARB_HCMD: begin
			r_arb_sq_rdy <= 0;
			r_sq_update_entry <= 0;
		end
		S_LOAD_HEAD_PTR: begin
			r_arb_sq_rdy <= 0;
			r_sq_update_entry <= 0;
		end
		S_CALC_ADDR: begin
			r_arb_sq_rdy <= 0;
			r_sq_update_entry <= 0;
		end
		S_GNT_HCMD: begin
			r_arb_sq_rdy <= 1;
			r_sq_update_entry <= 0;
		end
		S_UPDATE_HEAD_PTR: begin
			r_arb_sq_rdy <= 0;
			r_sq_update_entry <= r_sq_entry_valid;
		end
		default: begin
			r_arb_sq_rdy <= 0;
			r_sq_update_entry <= 0;
		end
	endcase
end

always @ (*)
begin
	case(r_sq_entry_valid) // synthesis parallel_case full_case
		9'b000000001: r_sq_qid <= 4'h0;
		9'b000000010: r_sq_qid <= 4'h1;
		9'b000000100: r_sq_qid <= 4'h2;
		9'b000001000: r_sq_qid <= 4'h3;
		9'b000010000: r_sq_qid <= 4'h4;
		9'b000100000: r_sq_qid <= 4'h5;
		9'b001000000: r_sq_qid <= 4'h6;
		9'b010000000: r_sq_qid <= 4'h7;
		9'b100000000: r_sq_qid <= 4'h8;
	endcase
end

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
				r_admin_sq_head_ptr <= r_sq_head_ptr;
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
				r_io_sq1_head_ptr <= r_sq_head_ptr;
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
				r_io_sq2_head_ptr <= r_sq_head_ptr;
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
				r_io_sq3_head_ptr <= r_sq_head_ptr;
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
				r_io_sq4_head_ptr <= r_sq_head_ptr;
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
				r_io_sq5_head_ptr <= r_sq_head_ptr;
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
				r_io_sq6_head_ptr <= r_sq_head_ptr;
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
				r_io_sq7_head_ptr <= r_sq_head_ptr;
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
				r_io_sq8_head_ptr <= r_sq_head_ptr;
			end
		end
	end
end

endmodule


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


module pcie_hcmd_slot_mgt
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,

	output									hcmd_slot_rdy,
	output	[6:0]							hcmd_slot_tag,
	input									hcmd_slot_alloc_en,

	input									hcmd_slot_free_en,
	input	[6:0]							hcmd_slot_invalid_tag
);


localparam	S_RESET_SEARCH_SLOT				= 5'b00001;
localparam	S_SEARCH_L1_SLOT				= 5'b00010;
localparam	S_SEARCH_L2_SLOT				= 5'b00100;
localparam	S_GNT_VAILD_SLOT				= 5'b01000;
localparam	S_VAILD_SLOT					= 5'b10000;


reg		[4:0]								cur_state;
reg		[4:0]								next_state;

reg		[127:0]								r_slot_valid;
reg		[127:0]								r_slot_search_mask;
reg		[127:0]								r_slot_valid_mask;
reg		[6:0]								r_slot_tag;
reg											r_slot_rdy;

reg		[15:0]								r_slot_l1_valid;
wire	[7:0]								w_slot_l1_mask;
wire										r_slot_l1_ok;

//wire	[7:0]								w_slot_l2_valid;
wire	[127:0]								w_slot_l2_mask;
wire										w_slot_l2_ok;

reg											r_slot_free_en;
reg		[6:0]								r_slot_invalid_tag;
reg		[127:0]								r_slot_invalid_mask;
wire	[127:0]								w_slot_invalid_mask;

assign hcmd_slot_rdy = r_slot_rdy;
assign hcmd_slot_tag = r_slot_tag;

assign w_slot_l1_mask = { r_slot_search_mask[95], 
						r_slot_search_mask[79], 
						r_slot_search_mask[63], 
						r_slot_search_mask[47], 
						r_slot_search_mask[31], 
						r_slot_search_mask[15], 
						r_slot_search_mask[127],
						r_slot_search_mask[111]};

always @ (*)
begin
	case(w_slot_l1_mask) // synthesis parallel_case full_case
		8'b00000001: r_slot_l1_valid <= r_slot_valid[15:0];
		8'b00000010: r_slot_l1_valid <= r_slot_valid[31:16];
		8'b00000100: r_slot_l1_valid <= r_slot_valid[47:32];
		8'b00001000: r_slot_l1_valid <= r_slot_valid[63:48];
		8'b00010000: r_slot_l1_valid <= r_slot_valid[79:64];
		8'b00100000: r_slot_l1_valid <= r_slot_valid[95:80];
		8'b01000000: r_slot_l1_valid <= r_slot_valid[111:96];
		8'b10000000: r_slot_l1_valid <= r_slot_valid[127:112];
	endcase
end

assign r_slot_l1_ok = (r_slot_l1_valid != 16'hFFFF);

assign w_slot_l2_mask = {r_slot_search_mask[126:0], r_slot_search_mask[127]};
assign w_slot_l2_ok = ((r_slot_valid & w_slot_l2_mask) == 0);

always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0)
		cur_state <= S_RESET_SEARCH_SLOT;
	else
		cur_state <= next_state;
end

always @ (*)
begin
	case(cur_state)
		S_RESET_SEARCH_SLOT: begin
			next_state <= S_SEARCH_L1_SLOT;
		end
		S_SEARCH_L1_SLOT: begin
			if(r_slot_l1_ok == 1)
				next_state <= S_SEARCH_L2_SLOT;
			else
				next_state <= S_SEARCH_L1_SLOT;
		end
		S_SEARCH_L2_SLOT: begin
			if(w_slot_l2_ok == 1)
				next_state <= S_GNT_VAILD_SLOT;
			else
				next_state <= S_SEARCH_L2_SLOT;
		end
		S_GNT_VAILD_SLOT: begin
			if(hcmd_slot_alloc_en == 1)
				next_state <= S_VAILD_SLOT;
			else
				next_state <= S_GNT_VAILD_SLOT;
		end
		S_VAILD_SLOT: begin
			next_state <= S_RESET_SEARCH_SLOT;
		end
		default: begin
			next_state <= S_RESET_SEARCH_SLOT;
		end
	endcase
end

always @ (posedge pcie_user_clk)
begin
	case(cur_state)
		S_RESET_SEARCH_SLOT: begin
			r_slot_search_mask[127:112] <= 0;
			r_slot_search_mask[111] <= 1'b1;
			r_slot_search_mask[110:0] <= 0;
			r_slot_tag <= 7'h6F;
		end
		S_SEARCH_L1_SLOT: begin
			r_slot_search_mask[111] <= w_slot_l1_mask[7];
			r_slot_search_mask[95] <= w_slot_l1_mask[6];
			r_slot_search_mask[79] <= w_slot_l1_mask[5];
			r_slot_search_mask[63] <= w_slot_l1_mask[4];
			r_slot_search_mask[47] <= w_slot_l1_mask[3];
			r_slot_search_mask[31] <= w_slot_l1_mask[2];
			r_slot_search_mask[15] <= w_slot_l1_mask[1];
			r_slot_search_mask[127] <= w_slot_l1_mask[0];
			r_slot_tag <= r_slot_tag + 16;
		end
		S_SEARCH_L2_SLOT: begin
			r_slot_search_mask <= w_slot_l2_mask;
			r_slot_tag <= r_slot_tag + 1;
		end
		S_GNT_VAILD_SLOT: begin

		end
		S_VAILD_SLOT: begin

		end
		default: begin

		end
	endcase
end

always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0) begin
		r_slot_valid <= 0;
	end
	else begin
		r_slot_valid <= (r_slot_valid | r_slot_valid_mask) & r_slot_invalid_mask;
		//r_slot_valid <= (r_slot_valid | r_slot_valid_mask);
	end
end

always @ (*)
begin
	case(cur_state)
		S_RESET_SEARCH_SLOT: begin
			r_slot_rdy <= 0;
			r_slot_valid_mask <= 0;
		end
		S_SEARCH_L1_SLOT: begin
			r_slot_rdy <= 0;
			r_slot_valid_mask <= 0;
		end
		S_SEARCH_L2_SLOT: begin
			r_slot_rdy <= 0;
			r_slot_valid_mask <= 0;
		end
		S_GNT_VAILD_SLOT: begin
			r_slot_rdy <= 1;
			r_slot_valid_mask <= 0;
		end
		S_VAILD_SLOT: begin
			r_slot_rdy <= 0;
			r_slot_valid_mask <= r_slot_search_mask;
		end
		default: begin
			r_slot_rdy <= 0;
			r_slot_valid_mask <= 0;
		end
	endcase
end


always @ (posedge pcie_user_clk)
begin
	r_slot_free_en <= hcmd_slot_free_en;
	r_slot_invalid_tag <= hcmd_slot_invalid_tag;

	if(r_slot_free_en == 1)
		r_slot_invalid_mask <= w_slot_invalid_mask;
	else
		r_slot_invalid_mask <= {128{1'b1}};
end

genvar i;
generate
	for(i = 0; i < 128; i = i + 1)
	begin : INVALID_TAG
		assign w_slot_invalid_mask[i] = (r_slot_invalid_tag != i);
	end
endgenerate

endmodule
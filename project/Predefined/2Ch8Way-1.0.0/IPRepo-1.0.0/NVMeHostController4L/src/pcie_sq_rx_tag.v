
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


module pcie_sq_rx_tag # (
	parameter	C_PCIE_DATA_WIDTH			= 128,
	parameter	P_FIFO_DEPTH_WIDTH			= 4
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,

	input									pcie_tag_alloc,
	input	[7:0]							pcie_alloc_tag,
	input	[6:4]							pcie_tag_alloc_len,
	output									pcie_tag_full_n,

	input	[7:0]							cpld_fifo_tag,
	input	[C_PCIE_DATA_WIDTH-1:0]			cpld_fifo_wr_data,
	input									cpld_fifo_wr_en,
	input									cpld_fifo_tag_last,

	output									fifo_wr_en,
	output	[P_FIFO_DEPTH_WIDTH-1:0]		fifo_wr_addr,
	output	[C_PCIE_DATA_WIDTH-1:0]			fifo_wr_data,
	output	[P_FIFO_DEPTH_WIDTH:0]			rear_full_addr,
	output	[P_FIFO_DEPTH_WIDTH:0]			rear_addr
);

localparam	LP_PCIE_TAG_PREFIX				= 5'b00000;
localparam	LP_PCIE_TAG_WITDH				= 3;
localparam	LP_NUM_OF_PCIE_TAG				= 2;

reg		[LP_NUM_OF_PCIE_TAG:0]				r_pcie_tag_rear;
reg		[LP_NUM_OF_PCIE_TAG:0]				r_pcie_tag_front;
reg		[P_FIFO_DEPTH_WIDTH:0]				r_alloc_base_addr;

reg		[LP_PCIE_TAG_WITDH-1:0]				r_pcie_tag [LP_NUM_OF_PCIE_TAG-1:0];
reg		[P_FIFO_DEPTH_WIDTH:0]				r_pcie_tag_addr [LP_NUM_OF_PCIE_TAG-1:0];

(* KEEP = "TRUE", EQUIVALENT_REGISTER_REMOVAL = "NO" *)	reg		[C_PCIE_DATA_WIDTH-1:0]				r_cpld_fifo_wr_data;
reg											r_cpld_fifo_wr_en;
reg											r_cpld_fifo_tag_last;

wire	[LP_NUM_OF_PCIE_TAG-1:0]			w_pcie_tag_hit;
reg		[LP_NUM_OF_PCIE_TAG-1:0]			r_pcie_tag_hit;

reg		[LP_NUM_OF_PCIE_TAG-1:0]			r_pcie_tag_alloc_mask;
reg		[LP_NUM_OF_PCIE_TAG-1:0]			r_pcie_tag_update_mask;
reg		[LP_NUM_OF_PCIE_TAG-1:0]			r_pcie_tag_invalid_mask;
reg		[LP_NUM_OF_PCIE_TAG-1:0]			r_pcie_tag_free_mask;

reg		[LP_NUM_OF_PCIE_TAG-1:0]			r_pcie_tag_valid;
reg		[LP_NUM_OF_PCIE_TAG-1:0]			r_pcie_tag_invalid;

reg		[P_FIFO_DEPTH_WIDTH:0]				r_rear_addr;

reg		[P_FIFO_DEPTH_WIDTH-1:0]			r_fifo_wr_addr;

assign pcie_tag_full_n = ~((r_pcie_tag_rear[LP_NUM_OF_PCIE_TAG] ^ r_pcie_tag_front[LP_NUM_OF_PCIE_TAG])
							& (r_pcie_tag_rear[LP_NUM_OF_PCIE_TAG-1:0] == r_pcie_tag_front[LP_NUM_OF_PCIE_TAG-1:0]));

assign fifo_wr_en = r_cpld_fifo_wr_en;
assign fifo_wr_addr = r_fifo_wr_addr;
assign fifo_wr_data = r_cpld_fifo_wr_data;
assign rear_full_addr = r_alloc_base_addr;
assign rear_addr = r_rear_addr;

always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0) begin
		r_pcie_tag_rear <= 1;
		r_alloc_base_addr <= 0;
		r_pcie_tag[0] <= {LP_PCIE_TAG_WITDH{1'b1}};
		r_pcie_tag[1] <= {LP_PCIE_TAG_WITDH{1'b1}};
	end
	else begin
		if(pcie_tag_alloc == 1) begin
			r_pcie_tag_rear[LP_NUM_OF_PCIE_TAG-1:0] <= {r_pcie_tag_rear[LP_NUM_OF_PCIE_TAG-2:0], r_pcie_tag_rear[LP_NUM_OF_PCIE_TAG-1]};
			r_alloc_base_addr <= r_alloc_base_addr + pcie_tag_alloc_len;
			if(r_pcie_tag_rear[LP_NUM_OF_PCIE_TAG-1] == 1)
				r_pcie_tag_rear[LP_NUM_OF_PCIE_TAG] <= ~r_pcie_tag_rear[LP_NUM_OF_PCIE_TAG];
		end
		
		if(r_pcie_tag_alloc_mask[0])
			r_pcie_tag[0] <= pcie_alloc_tag[LP_PCIE_TAG_WITDH-1:0];
		if(r_pcie_tag_alloc_mask[1])
			r_pcie_tag[1] <= pcie_alloc_tag[LP_PCIE_TAG_WITDH-1:0];
	end
end

always @ (*)
begin
	if(pcie_tag_alloc == 1)
		r_pcie_tag_alloc_mask <= r_pcie_tag_rear[LP_NUM_OF_PCIE_TAG-1:0];
	else
		r_pcie_tag_alloc_mask <= 0;

	if(cpld_fifo_wr_en == 1)
		r_pcie_tag_update_mask <= w_pcie_tag_hit;
	else
		r_pcie_tag_update_mask <= 0;

	if(r_cpld_fifo_tag_last == 1)
		r_pcie_tag_invalid_mask <= r_pcie_tag_hit;
	else
		r_pcie_tag_invalid_mask <= 0;

	r_pcie_tag_free_mask <= r_pcie_tag_valid & r_pcie_tag_invalid & r_pcie_tag_front[LP_NUM_OF_PCIE_TAG-1:0];
end

always @ (posedge pcie_user_clk)
begin
	case({r_pcie_tag_update_mask[0], r_pcie_tag_alloc_mask[0]}) // synthesis parallel_case
		2'b01: r_pcie_tag_addr[0] <= r_alloc_base_addr;
		2'b10: r_pcie_tag_addr[0] <= r_pcie_tag_addr[0] + 1;
	endcase

	case({r_pcie_tag_update_mask[1], r_pcie_tag_alloc_mask[1]}) // synthesis parallel_case
		2'b01: r_pcie_tag_addr[1] <= r_alloc_base_addr;
		2'b10: r_pcie_tag_addr[1] <= r_pcie_tag_addr[1] + 1;
	endcase
end

assign w_pcie_tag_hit[0] = (r_pcie_tag[0] == cpld_fifo_tag[LP_PCIE_TAG_WITDH-1:0]) & r_pcie_tag_valid[0];
assign w_pcie_tag_hit[1] = (r_pcie_tag[1] == cpld_fifo_tag[LP_PCIE_TAG_WITDH-1:0]) & r_pcie_tag_valid[1];

always @ (posedge pcie_user_clk)
begin
	r_cpld_fifo_tag_last <= cpld_fifo_tag_last;
	r_cpld_fifo_wr_en <= cpld_fifo_wr_en;
	r_cpld_fifo_wr_data <= cpld_fifo_wr_data;
end

always @ (posedge pcie_user_clk)
begin
	r_pcie_tag_hit <= w_pcie_tag_hit;
	
	case(w_pcie_tag_hit) // synthesis parallel_case
		2'b01: r_fifo_wr_addr <= r_pcie_tag_addr[0][P_FIFO_DEPTH_WIDTH-1:0];
		2'b10: r_fifo_wr_addr <= r_pcie_tag_addr[1][P_FIFO_DEPTH_WIDTH-1:0];
	endcase
end


always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0) begin
		r_pcie_tag_front <= 1;
		r_rear_addr <= 0;
		r_pcie_tag_valid <= 0;
		r_pcie_tag_invalid <= 0;
	end
	else begin
		r_pcie_tag_valid <= (r_pcie_tag_valid | r_pcie_tag_alloc_mask) & ~r_pcie_tag_free_mask;
		r_pcie_tag_invalid <= (r_pcie_tag_invalid | r_pcie_tag_invalid_mask) & ~r_pcie_tag_free_mask;

		if(r_pcie_tag_free_mask != 0) begin
			r_pcie_tag_front[LP_NUM_OF_PCIE_TAG-1:0] <= {r_pcie_tag_front[LP_NUM_OF_PCIE_TAG-2:0], r_pcie_tag_front[LP_NUM_OF_PCIE_TAG-1]};
			if(r_pcie_tag_front[LP_NUM_OF_PCIE_TAG-1] == 1)
				r_pcie_tag_front[LP_NUM_OF_PCIE_TAG] <= ~r_pcie_tag_front[LP_NUM_OF_PCIE_TAG];
		end
		
		case(r_pcie_tag_free_mask) // synthesis parallel_case
			2'b01: r_rear_addr <= r_pcie_tag_addr[0];
			2'b10: r_rear_addr <= r_pcie_tag_addr[1];
		endcase	
	end
end

endmodule

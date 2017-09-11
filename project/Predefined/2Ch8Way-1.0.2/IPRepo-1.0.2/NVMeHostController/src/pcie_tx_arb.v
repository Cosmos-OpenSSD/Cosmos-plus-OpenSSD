
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

`include	"def_pcie.vh"

module pcie_tx_arb # (
	parameter	C_PCIE_DATA_WIDTH			= 128,
	parameter	C_PCIE_ADDR_WIDTH			= 36
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,

	input	[15:0]							pcie_dev_id,

	input									tx_cpld_gnt,
	input									tx_mrd_gnt,
	input									tx_mwr_gnt,

	input									tx_cpld_req,
	input	[7:0]							tx_cpld_tag,
	input	[15:0]							tx_cpld_req_id,
	input	[11:2]							tx_cpld_len,
	input	[11:0]							tx_cpld_bc,
	input	[6:0]							tx_cpld_laddr,
	input	[63:0]							tx_cpld_data,
	output									tx_cpld_req_ack,

	input									tx_mrd0_req,
	input	[7:0]							tx_mrd0_tag,
	input	[11:2]							tx_mrd0_len,
	input	[C_PCIE_ADDR_WIDTH-1:2]			tx_mrd0_addr,
	output									tx_mrd0_req_ack,

	input									tx_mrd1_req,
	input	[7:0]							tx_mrd1_tag,
	input	[11:2]							tx_mrd1_len,
	input	[C_PCIE_ADDR_WIDTH-1:2]			tx_mrd1_addr,
	output									tx_mrd1_req_ack,

	input									tx_mrd2_req,
	input	[7:0]							tx_mrd2_tag,
	input	[11:2]							tx_mrd2_len,
	input	[C_PCIE_ADDR_WIDTH-1:2]			tx_mrd2_addr,
	output									tx_mrd2_req_ack,

	input									tx_mwr0_req,
	input	[7:0]							tx_mwr0_tag,
	input	[11:2]							tx_mwr0_len,
	input	[C_PCIE_ADDR_WIDTH-1:2]			tx_mwr0_addr,
	output									tx_mwr0_req_ack,

	input									tx_mwr1_req,
	input	[7:0]							tx_mwr1_tag,
	input	[11:2]							tx_mwr1_len,
	input	[C_PCIE_ADDR_WIDTH-1:2]			tx_mwr1_addr,
	output									tx_mwr1_req_ack,

	output									tx_arb_valid,
	output	[5:0]							tx_arb_gnt,
	output	[2:0]							tx_arb_type,
	output	[11:2]							tx_pcie_len,
	output	[127:0]							tx_pcie_head,
	output	[31:0]							tx_cpld_udata,
	input									tx_arb_rdy

);

reg		[5:0]								r_tx_req;
reg		[5:0]								r_tx_req_en;
wire	[5:0]								w_tx_req_en;
wire	[5:0]								w_tx_req_gnt;
reg		[5:0]								r_tx_req_ack;
wire	[5:0]								w_tx_req_ack;

reg		[2:0]								r_tx_type;
reg		[5:0]								r_tx_arb;
reg		[5:0]								r_tx_arb_cur;
reg		[2:0]								r_tx_arb_type;

reg		[31:0]								r_tx_pcie_head0;
reg		[31:0]								r_tx_pcie_head1;
reg		[31:0]								r_tx_pcie_head2;
reg		[31:0]								r_tx_pcie_head3;

assign tx_arb_valid = (r_tx_arb_cur[5] | r_tx_arb_cur[4]) | (r_tx_arb_cur[3] | r_tx_arb_cur[2]) | (r_tx_arb_cur[1] | r_tx_arb_cur[0]);
assign tx_arb_gnt = r_tx_arb_cur;
assign tx_arb_type = r_tx_arb_type;
assign tx_pcie_len = r_tx_pcie_head0[9:0];
assign tx_pcie_head = {r_tx_pcie_head3, r_tx_pcie_head2, r_tx_pcie_head1, r_tx_pcie_head0};
assign tx_cpld_udata = tx_cpld_data[63:32];

assign tx_cpld_req_ack = r_tx_req_ack[0];
assign tx_mrd0_req_ack = r_tx_req_ack[1];
assign tx_mrd1_req_ack = r_tx_req_ack[2];
assign tx_mrd2_req_ack = r_tx_req_ack[3];
assign tx_mwr0_req_ack = r_tx_req_ack[4];
assign tx_mwr1_req_ack = r_tx_req_ack[5];

assign w_tx_req_ack[0] = tx_arb_rdy & r_tx_arb_cur[0];
assign w_tx_req_ack[1] = tx_arb_rdy & r_tx_arb_cur[1];
assign w_tx_req_ack[2] = tx_arb_rdy & r_tx_arb_cur[2];
assign w_tx_req_ack[3] = tx_arb_rdy & r_tx_arb_cur[3];
assign w_tx_req_ack[4] = tx_arb_rdy & r_tx_arb_cur[4];
assign w_tx_req_ack[5] = tx_arb_rdy & r_tx_arb_cur[5];

always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0) begin
		r_tx_req <= 0;
	end
	else begin
		if(tx_cpld_req == 1)
			r_tx_req[0] <= 1;
		else if(w_tx_req_ack[0] == 1)
			r_tx_req[0] <= 0;

		if(tx_mrd0_req == 1)
			r_tx_req[1] <= 1;
		else if(w_tx_req_ack[1] == 1)
			r_tx_req[1] <= 0;

		if(tx_mrd1_req == 1)
			r_tx_req[2] <= 1;
		else if(w_tx_req_ack[2] == 1)
			r_tx_req[2] <= 0;

		if(tx_mrd2_req == 1)
			r_tx_req[3] <= 1;
		else if(w_tx_req_ack[3] == 1)
			r_tx_req[3] <= 0;

		if(tx_mwr0_req == 1)
			r_tx_req[4] <= 1;
		else if(w_tx_req_ack[4] == 1)
			r_tx_req[4] <= 0;

		if(tx_mwr1_req == 1)
			r_tx_req[5] <= 1;
		else if(w_tx_req_ack[5] == 1)
			r_tx_req[5] <= 0;
	end
end


always @ (*)
begin
	if(tx_arb_rdy == 1)
		r_tx_req_en <= r_tx_req & ~r_tx_arb_cur;
	else
		r_tx_req_en <= r_tx_req;
end

assign w_tx_req_gnt[0] = tx_cpld_gnt;
assign w_tx_req_gnt[1] = tx_mrd_gnt;
assign w_tx_req_gnt[2] = tx_mrd_gnt;
assign w_tx_req_gnt[3] = tx_mrd_gnt;
assign w_tx_req_gnt[4] = tx_mwr_gnt;
assign w_tx_req_gnt[5] = tx_mwr_gnt;

assign w_tx_req_en = r_tx_req_en & w_tx_req_gnt;

always @ (*)
begin
	if(w_tx_req_en[0] == 1) begin
		r_tx_type <= 3'b001;
		r_tx_arb <= 6'b000001;
	end
	else if(w_tx_req_en[1] == 1) begin
		r_tx_type <= 3'b010;
		r_tx_arb <= 6'b000010;
	end
	else if(w_tx_req_en[2] == 1) begin
		r_tx_type <= 3'b010;
		r_tx_arb <= 6'b000100;
	end
	else if(w_tx_req_en[4] == 1) begin
		r_tx_type <= 3'b100;
		r_tx_arb <= 6'b010000;
	end
	else if(w_tx_req_en[3] == 1) begin
		r_tx_type <= 3'b010;
		r_tx_arb <= 6'b001000;
	end
	else if(w_tx_req_en[5] == 1) begin
		r_tx_type <= 3'b100;
		r_tx_arb <= 6'b100000;
	end
	else begin
		r_tx_type <= 3'b000;
		r_tx_arb <= 6'b000000;
	end
end

always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0)
		r_tx_arb_cur <= 0;
	else
		r_tx_arb_cur <= r_tx_arb;
end

always @ (posedge pcie_user_clk)
begin
	r_tx_arb_type <= r_tx_type;
	r_tx_req_ack <= w_tx_req_ack;
end


always @ (*)
begin
	case(r_tx_arb_cur) // synthesis parallel_case full_case
		6'b000001: begin
			r_tx_pcie_head0 <= {`D_CPLD_FMT, `D_CPLD_TYPE, 1'b0, `D_CPLD_TC, 1'b0, `D_CPLD_ATTR1, 1'b0, `D_CPLD_TH, `D_CPLD_TD, `D_CPLD_EP, `D_CPLD_ATTR2, `D_CPLD_AT, tx_cpld_len};
			r_tx_pcie_head1 <= {pcie_dev_id, `D_CPLD_CS, `D_CPLD_BCM, tx_cpld_bc};
			r_tx_pcie_head2 <= {tx_cpld_req_id, tx_cpld_tag, 1'b0, tx_cpld_laddr};
			r_tx_pcie_head3 <= tx_cpld_data[31:0];
		end
		6'b000010: begin
			r_tx_pcie_head0 <= {`D_MRD_FMT, `D_MRD_TYPE, 1'b0, `D_MRD_TC, 1'b0, `D_MRD_ATTR1, 1'b0, `D_MRD_TH, `D_MRD_TD, `D_MRD_EP, `D_MRD_ATTR2, `D_MRD_AT, tx_mrd0_len};
			r_tx_pcie_head1 <= {pcie_dev_id, tx_mrd0_tag, `D_MRD_LAST_BE, `D_MRD_1ST_BE};
			r_tx_pcie_head2 <= {28'b0, tx_mrd0_addr[C_PCIE_ADDR_WIDTH-1:32]};
			r_tx_pcie_head3 <= {tx_mrd0_addr[31:2], 2'b0};
		end
		6'b000100: begin
			r_tx_pcie_head0 <= {`D_MRD_FMT, `D_MRD_TYPE, 1'b0, `D_MRD_TC, 1'b0, `D_MRD_ATTR1, 1'b0, `D_MRD_TH, `D_MRD_TD, `D_MRD_EP, `D_MRD_ATTR2, `D_MRD_AT, tx_mrd1_len};
			r_tx_pcie_head1 <= {pcie_dev_id, tx_mrd1_tag, `D_MRD_LAST_BE, `D_MRD_1ST_BE};
			r_tx_pcie_head2 <= {28'b0, tx_mrd1_addr[C_PCIE_ADDR_WIDTH-1:32]};
			r_tx_pcie_head3 <= {tx_mrd1_addr[31:2], 2'b0};
		end
		6'b001000: begin
			r_tx_pcie_head0 <= {`D_MRD_FMT, `D_MRD_TYPE, 1'b0, `D_MRD_TC, 1'b0, `D_MRD_ATTR1, 1'b0, `D_MRD_TH, `D_MRD_TD, `D_MRD_EP, `D_MRD_ATTR2, `D_MRD_AT, tx_mrd2_len};
			r_tx_pcie_head1 <= {pcie_dev_id, tx_mrd2_tag, `D_MRD_LAST_BE, `D_MRD_1ST_BE};
			r_tx_pcie_head2 <= {28'b0, tx_mrd2_addr[C_PCIE_ADDR_WIDTH-1:32]};
			r_tx_pcie_head3 <= {tx_mrd2_addr[31:2], 2'b0};
		end
		6'b010000: begin
			r_tx_pcie_head0 <= {`D_MWR_FMT, `D_MWR_TYPE, 1'b0, `D_MWR_TC, 1'b0, `D_MWR_ATTR1, 1'b0, `D_MWR_TH, `D_MWR_TD, `D_MWR_EP, `D_MWR_ATTR2, `D_MWR_AT, tx_mwr0_len};
			r_tx_pcie_head1 <= {pcie_dev_id, tx_mwr0_tag, `D_MWR_LAST_BE, `D_MWR_1ST_BE};
			r_tx_pcie_head2 <= {28'b0, tx_mwr0_addr[C_PCIE_ADDR_WIDTH-1:32]};
			r_tx_pcie_head3 <= {tx_mwr0_addr[31:2], 2'b0};
		end
		6'b100000: begin
			r_tx_pcie_head0 <= {`D_MWR_FMT, `D_MWR_TYPE, 1'b0, `D_MWR_TC, 1'b0, `D_MWR_ATTR1, 1'b0, `D_MWR_TH, `D_MWR_TD, `D_MWR_EP, `D_MWR_ATTR2, `D_MWR_AT, tx_mwr1_len};
			r_tx_pcie_head1 <= {pcie_dev_id, tx_mwr1_tag, `D_MWR_LAST_BE, `D_MWR_1ST_BE};
			r_tx_pcie_head2 <= {28'b0, tx_mwr1_addr[C_PCIE_ADDR_WIDTH-1:32]};
			r_tx_pcie_head3 <= {tx_mwr1_addr[31:2], 2'b0};
		end
	endcase
end

endmodule
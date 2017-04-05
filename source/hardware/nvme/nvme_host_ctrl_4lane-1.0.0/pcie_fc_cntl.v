
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


module pcie_fc_cntl 
(
//PCIe user clock
	input									pcie_user_clk,
	input									pcie_user_rst_n,

// Flow Control
	input	[11:0]							fc_cpld,
	input	[7:0]							fc_cplh,
	input	[11:0]							fc_npd,
	input	[7:0]							fc_nph,
	input	[11:0]							fc_pd,
	input	[7:0]							fc_ph,
	output	[2:0]							fc_sel,

	input									tx_cfg_req,
	output									tx_cfg_gnt,
	input	[5:0]							tx_buf_av,

	output									tx_cpld_gnt,
	output									tx_mrd_gnt,
	output									tx_mwr_gnt
);

parameter	P_RX_CONSTRAINT_FC_CPLD		= 32;
parameter	P_RX_CONSTRAINT_FC_CPLH		= 8;

parameter	P_TX_CONSTRAINT_FC_CPLD		= 1;
parameter	P_TX_CONSTRAINT_FC_CPLH		= 1;
parameter	P_TX_CONSTRAINT_FC_NPD		= 1;
parameter	P_TX_CONSTRAINT_FC_NPH		= 1;
parameter	P_TX_CONSTRAINT_FC_PD		= 32;
parameter	P_TX_CONSTRAINT_FC_PH		= 1;

localparam	S_RX_AVAILABLE_FC_SEL			= 2'b01;
localparam	S_TX_AVAILABLE_FC_SEL			= 2'b10;

reg		[1:0]								cur_state;
reg		[1:0]								next_state;

reg		[11:0]							r_rx_available_fc_cpld;
reg		[7:0]							r_rx_available_fc_cplh;
reg		[11:0]							r_rx_available_fc_npd;
reg		[7:0]							r_rx_available_fc_nph;
reg		[11:0]							r_rx_available_fc_pd;
reg		[7:0]							r_rx_available_fc_ph;

reg		[11:0]							r_tx_available_fc_cpld;
reg		[7:0]							r_tx_available_fc_cplh;
reg		[11:0]							r_tx_available_fc_npd;
reg		[7:0]							r_tx_available_fc_nph;
reg		[11:0]							r_tx_available_fc_pd;
reg		[7:0]							r_tx_available_fc_ph;

wire									w_rx_available_fc_cpld;
wire									w_rx_available_fc_cplh;

wire									w_tx_available_fc_cpld;
wire									w_tx_available_fc_cplh;
wire									w_tx_available_fc_npd;
wire									w_tx_available_fc_nph;
wire									w_tx_available_fc_pd;
wire									w_tx_available_fc_ph;

reg		[2:0]							r_fc_sel;
reg		[1:0]							r_rd_fc_sel;
reg		[1:0]							r_rd_fc_sel_d1;
reg		[1:0]							r_rd_fc_sel_d2;

reg										r_tx_cpld_gnt;
reg										r_tx_mrd_gnt;
reg										r_tx_mwr_gnt;

assign fc_sel = r_fc_sel;
assign tx_cfg_gnt = 1'b1;

assign tx_cpld_gnt = r_tx_cpld_gnt;
assign tx_mrd_gnt = r_tx_mrd_gnt;
assign tx_mwr_gnt = r_tx_mwr_gnt;

always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0)
		cur_state <= S_RX_AVAILABLE_FC_SEL;
	else
		cur_state <= next_state;
end

always @ (*)
begin
	case(cur_state)
		S_RX_AVAILABLE_FC_SEL: begin
			next_state <= S_TX_AVAILABLE_FC_SEL;
		end
		S_TX_AVAILABLE_FC_SEL: begin
			next_state <= S_RX_AVAILABLE_FC_SEL;
		end
		default: begin
			next_state <= S_RX_AVAILABLE_FC_SEL;
		end
	endcase
end

always @ (*)
begin
	case(cur_state)
		S_RX_AVAILABLE_FC_SEL: begin
			r_fc_sel <= 3'b000;
			r_rd_fc_sel <= 2'b01;
		end
		S_TX_AVAILABLE_FC_SEL: begin
			r_fc_sel <= 3'b100;
			r_rd_fc_sel <= 2'b10;
		end
		default: begin
			r_fc_sel <= 3'b000;
			r_rd_fc_sel <= 2'b00;
		end
	endcase
end

assign w_rx_available_fc_cpld = (r_rx_available_fc_cpld > P_RX_CONSTRAINT_FC_CPLD);
assign w_rx_available_fc_cplh = (r_rx_available_fc_cplh > P_RX_CONSTRAINT_FC_CPLH);

assign w_tx_available_fc_cpld = (r_tx_available_fc_cpld > P_TX_CONSTRAINT_FC_CPLD);
assign w_tx_available_fc_cplh = (r_tx_available_fc_cplh > P_TX_CONSTRAINT_FC_CPLH);
assign w_tx_available_fc_npd = (r_tx_available_fc_npd > P_TX_CONSTRAINT_FC_NPD);
assign w_tx_available_fc_nph = (r_tx_available_fc_nph > P_TX_CONSTRAINT_FC_NPH);
assign w_tx_available_fc_pd = (r_tx_available_fc_pd > P_TX_CONSTRAINT_FC_PD);
assign w_tx_available_fc_ph = (r_tx_available_fc_ph > P_TX_CONSTRAINT_FC_PH);

always @ (posedge pcie_user_clk)
begin
	r_tx_cpld_gnt <= w_tx_available_fc_cpld & w_tx_available_fc_cplh;
	r_tx_mrd_gnt <= (w_tx_available_fc_npd & w_tx_available_fc_nph) & (w_rx_available_fc_cpld & w_rx_available_fc_cplh);
	r_tx_mwr_gnt <= w_tx_available_fc_pd & w_tx_available_fc_ph;
end

always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0) begin
		r_rd_fc_sel_d1 <= 0;
		r_rd_fc_sel_d2 <= 0;
	end
	else begin
		r_rd_fc_sel_d1 <= r_rd_fc_sel;
		r_rd_fc_sel_d2 <= r_rd_fc_sel_d1;
	end
end

always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0) begin
		r_rx_available_fc_cpld <= 0;
		r_rx_available_fc_cplh <= 0;
		r_rx_available_fc_npd <= 0;
		r_rx_available_fc_nph <= 0;
		r_rx_available_fc_pd <= 0;
		r_rx_available_fc_ph <= 0;

		r_tx_available_fc_cpld <= 0;
		r_tx_available_fc_cplh <= 0;
		r_tx_available_fc_npd <= 0;
		r_tx_available_fc_nph <= 0;
		r_tx_available_fc_pd <= 0;
		r_tx_available_fc_ph <= 0;
	end
	else begin
		if(r_rd_fc_sel_d2[0] == 1) begin
			r_rx_available_fc_cpld <= fc_cpld;
			r_rx_available_fc_cplh <= fc_cplh;
			r_rx_available_fc_npd <= fc_npd;
			r_rx_available_fc_nph <= fc_nph;
			r_rx_available_fc_pd <= fc_pd;
			r_rx_available_fc_ph <= fc_ph;
		end
		if(r_rd_fc_sel_d2[1] == 1) begin
			r_tx_available_fc_cpld <= fc_cpld;
			r_tx_available_fc_cplh <= fc_cplh;
			r_tx_available_fc_npd <= fc_npd;
			r_tx_available_fc_nph <= fc_nph;
			r_tx_available_fc_pd <= fc_pd;
			r_tx_available_fc_ph <= fc_ph;
		end
	end
end

/*
parameter	P_RX_AVAILABLE_FC_CPLD		= 36;
parameter	P_RX_AVAILABLE_FC_CPLH		= 36;

parameter	P_TX_AVAILABLE_FC_CPLD		= 36;
parameter	P_TX_AVAILABLE_FC_CPLH		= 36;

parameter	P_TX_AVAILABLE_FC_NPD		= 36;
parameter	P_TX_AVAILABLE_FC_NPH		= 36;

parameter	P_TX_AVAILABLE_FC_PD		= 36;
parameter	P_TX_AVAILABLE_FC_PH		= 36;

reg		[11:0]							r_rx_available_fc_cpld;
reg		[7:0]							r_rx_available_fc_cplh;
reg		[11:0]							r_rx_available_fc_npd;
reg		[7:0]							r_rx_available_fc_nph;
reg		[11:0]							r_rx_available_fc_pd;
reg		[7:0]							r_rx_available_fc_ph;

reg		[11:0]							r_rx_limit_fc_cpld;
reg		[7:0]							r_rx_limit_fc_cplh;
reg		[11:0]							r_rx_limit_fc_npd;
reg		[7:0]							r_rx_limit_fc_nph;
reg		[11:0]							r_rx_limit_fc_pd;
reg		[7:0]							r_rx_limit_fc_ph;

reg		[11:0]							r_rx_consumed_fc_cpld;
reg		[7:0]							r_rx_consumed_fc_cplh;
reg		[11:0]							r_rx_consumed_fc_npd;
reg		[7:0]							r_rx_consumed_fc_nph;
reg		[11:0]							r_rx_consumed_fc_pd;
reg		[7:0]							r_rx_consumed_fc_ph;

reg		[11:0]							r_tx_available_fc_cpld;
reg		[7:0]							r_tx_available_fc_cplh;
reg		[11:0]							r_tx_available_fc_npd;
reg		[7:0]							r_tx_available_fc_nph;
reg		[11:0]							r_tx_available_fc_pd;
reg		[7:0]							r_tx_available_fc_ph;

reg		[11:0]							r_tx_limit_fc_cpld;
reg		[7:0]							r_tx_limit_fc_cplh;
reg		[11:0]							r_tx_limit_fc_npd;
reg		[7:0]							r_tx_limit_fc_nph;
reg		[11:0]							r_tx_limit_fc_pd;
reg		[7:0]							r_tx_limit_fc_ph;

reg		[11:0]							r_tx_consumed_fc_cpld;
reg		[7:0]							r_tx_consumed_fc_cplh;
reg		[11:0]							r_tx_consumed_fc_npd;
reg		[7:0]							r_tx_consumed_fc_nph;
reg		[11:0]							r_tx_consumed_fc_pd;
reg		[7:0]							r_tx_consumed_fc_ph;

reg		[2:0]							r_fc_sel;
reg		[5:0]							r_rd_fc_sel;
reg		[5:0]							r_rd_fc_sel_d1;
reg		[5:0]							r_rd_fc_sel_d2;

reg										r_tx_cpld_gnt;
reg										r_tx_mrd_gnt;
reg										r_tx_mwr_gnt;

assign tx_cfg_gnt = 1'b1;

assign tx_cpld_gnt = r_tx_cpld_gnt;
assign tx_mrd_gnt = r_tx_mrd_gnt;
assign tx_mwr_gnt = r_tx_mwr_gnt;

always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0)
		cur_state <= S_RX_AVAILABLE_FC_SEL;
	else
		cur_state <= next_state;
end

always @ (*)
begin
	case(cur_state)
		S_RX_AVAILABLE_FC_SEL: begin
			next_state <= S_RX_LITMIT_FC_SEL;
		end
		S_RX_LITMIT_FC_SEL: begin
			next_state <= S_RX_CONSUMED_FC_SEL;
		end
		S_RX_CONSUMED_FC_SEL: begin
			next_state <= S_TX_AVAILABLE_FC_SEL;
		end
		S_TX_AVAILABLE_FC_SEL: begin
			next_state <= S_TX_LITMIT_FC_SEL;
		end
		S_TX_LITMIT_FC_SEL: begin
			next_state <= S_TX_CONSUMED_FC_SEL;
		end
		S_TX_CONSUMED_FC_SEL: begin
			next_state <= S_RX_AVAILABLE_FC_SEL;
		end
		default: begin
			next_state <= S_RX_AVAILABLE_FC_SEL;
		end
	endcase
end

always @ (*)
begin
	case(cur_state)
		S_RX_AVAILABLE_FC_SEL: begin
			r_fc_sel <= 3'b000;
			r_rd_fc_sel <= 6'b000001;
		end
		S_RX_LITMIT_FC_SEL: begin
			r_fc_sel <= 3'b001;
			r_rd_fc_sel <= 6'b000010;
		end
		S_RX_CONSUMED_FC_SEL: begin
			r_fc_sel <= 3'b010;
			r_rd_fc_sel <= 6'b000100;
		end
		S_TX_AVAILABLE_FC_SEL: begi
			r_fc_sel <= 3'b100;
			r_rd_fc_sel <= 6'b001000;
		end
		S_TX_LITMIT_FC_SEL: begin
			r_fc_sel <= 3'b101;
			r_rd_fc_sel <= 6'b010000;
		end
		S_TX_CONSUMED_FC_SEL: begin
			r_fc_sel <= 3'b110;
			r_rd_fc_sel <= 6'b100000;
		end
		default: begin
			r_fc_sel <= 3'b000;
			r_rd_fc_sel <= 6'b000000;
		end
	endcase
end

always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	r_tx_cpld_gnt;
	r_tx_mrd_gnt;
	r_tx_mwr_gnt;
end

always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0) begin
		r_rd_fc_sel_d1 <= 0;
		r_rd_fc_sel_d2 <= 0;
	end
	else begin
		r_rd_fc_sel_d1 <= r_rd_fc_sel;
		r_rd_fc_sel_d2 <= r_rd_fc_sel_d1;
	end
end

always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0) begin
		r_rx_available_fc_cpld <= 0;
		r_rx_available_fc_cplh <= 0;
		r_rx_available_fc_npd <= 0;
		r_rx_available_fc_nph <= 0;
		r_rx_available_fc_pd <= 0;
		r_rx_available_fc_ph <= 0;

		r_rx_limit_fc_cpld <= 0;
		r_rx_limit_fc_cplh <= 0;
		r_rx_limit_fc_npd <= 0;
		r_rx_limit_fc_nph <= 0;
		r_rx_limit_fc_pd <= 0;
		r_rx_limit_fc_ph <= 0;

		r_rx_consumed_fc_cpld <= 0;
		r_rx_consumed_fc_cplh <= 0;
		r_rx_consumed_fc_npd <= 0;
		r_rx_consumed_fc_nph <= 0;
		r_rx_consumed_fc_pd <= 0;
		r_rx_consumed_fc_ph <= 0;

		r_tx_available_fc_cpld <= 0;
		r_tx_available_fc_cplh <= 0;
		r_tx_available_fc_npd <= 0;
		r_tx_available_fc_nph <= 0;
		r_tx_available_fc_pd <= 0;
		r_tx_available_fc_ph <= 0;

		r_tx_limit_fc_cpld <= 0;
		r_tx_limit_fc_cplh <= 0;
		r_tx_limit_fc_npd <= 0;
		r_tx_limit_fc_nph <= 0;
		r_tx_limit_fc_pd <= 0;
		r_tx_limit_fc_ph <= 0;

		r_tx_consumed_fc_cpld <= 0;
		r_tx_consumed_fc_cplh <= 0;
		r_tx_consumed_fc_npd <= 0;
		r_tx_consumed_fc_nph <= 0;
		r_tx_consumed_fc_pd <= 0;
		r_tx_consumed_fc_ph <= 0;
	end
	else begin
		if(r_rd_fc_sel_d2[0] == 1) begin
			r_rx_available_fc_cpld <= fc_cpld;
			r_rx_available_fc_cplh <= fc_cplh;
			r_rx_available_fc_npd <= fc_npd;
			r_rx_available_fc_nph <= fc_nph;
			r_rx_available_fc_pd <= fc_pd;
			r_rx_available_fc_ph <= fc_ph;
		end
		if(r_rd_fc_sel_d2[1] == 1) begin
			r_rx_limit_fc_cpld <= fc_cpld;
			r_rx_limit_fc_cplh <= fc_cplh;
			r_rx_limit_fc_npd <= fc_npd;
			r_rx_limit_fc_nph <= fc_nph;
			r_rx_limit_fc_pd <= fc_pd;
			r_rx_limit_fc_ph <= fc_ph;
		end
		if(r_rd_fc_sel_d2[2] == 1) begin
			r_rx_consumed_fc_cpld <= fc_cpld;
			r_rx_consumed_fc_cplh <= fc_cplh;
			r_rx_consumed_fc_npd <= fc_npd;
			r_rx_consumed_fc_nph <= fc_nph;
			r_rx_consumed_fc_pd <= fc_pd;
			r_rx_consumed_fc_ph <= fc_ph;
		end
		if(r_rd_fc_sel_d2[3] == 1) begin
			r_tx_available_fc_cpld <= fc_cpld;
			r_tx_available_fc_cplh <= fc_cplh;
			r_tx_available_fc_npd <= fc_npd;
			r_tx_available_fc_nph <= fc_nph;
			r_tx_available_fc_pd <= fc_pd;
			r_tx_available_fc_ph <= fc_ph;
		end
		if(r_rd_fc_sel_d2[4] == 1) begin
			r_tx_limit_fc_cpld <= fc_cpld;
			r_tx_limit_fc_cplh <= fc_cplh;
			r_tx_limit_fc_npd <= fc_npd;
			r_tx_limit_fc_nph <= fc_nph;
			r_tx_limit_fc_pd <= fc_pd;
			r_tx_limit_fc_ph <= fc_ph;
		end
		if(r_rd_fc_sel_d2[5] == 1) begin
			r_tx_consumed_fc_cpld <= fc_cpld;
			r_tx_consumed_fc_cplh <= fc_cplh;
			r_tx_consumed_fc_npd <= fc_npd;
			r_tx_consumed_fc_nph <= fc_nph;
			r_tx_consumed_fc_pd <= fc_pd;
			r_tx_consumed_fc_ph <= fc_ph;
		end
	end
end
*/

endmodule


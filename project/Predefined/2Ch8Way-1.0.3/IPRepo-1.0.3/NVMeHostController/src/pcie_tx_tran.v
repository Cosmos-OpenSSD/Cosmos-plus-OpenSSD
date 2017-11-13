
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


module pcie_tx_tran # (
	parameter	C_PCIE_DATA_WIDTH			= 128
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,

	output									tx_err_drop,

//pcie tx signal
	input									m_axis_tx_tready,
	output	[C_PCIE_DATA_WIDTH-1:0]			m_axis_tx_tdata,
	output	[(C_PCIE_DATA_WIDTH/8)-1:0]		m_axis_tx_tkeep,
	output	[3:0]							m_axis_tx_tuser,
	output									m_axis_tx_tlast,
	output									m_axis_tx_tvalid,

	input									tx_arb_valid,
	input	[5:0]							tx_arb_gnt,
	input	[2:0]							tx_arb_type,
	input	[11:2]							tx_pcie_len,
	input	[127:0]							tx_pcie_head,
	input	[31:0]							tx_cpld_udata,
	output									tx_arb_rdy,

	output									tx_mwr0_rd_en,
	input	[C_PCIE_DATA_WIDTH-1:0]			tx_mwr0_rd_data,
	output									tx_mwr0_data_last,

	output									tx_mwr1_rd_en,
	input	[C_PCIE_DATA_WIDTH-1:0]			tx_mwr1_rd_data,
	output									tx_mwr1_data_last
);

localparam	S_TX_IDLE						= 9'b000000001;
localparam	S_TX_CPLD_HEAD					= 9'b000000010;
localparam	S_TX_CPLD_DATA					= 9'b000000100;
localparam	S_TX_MRD_HEAD					= 9'b000001000;
localparam	S_TX_MWR_HEAD					= 9'b000010000;
localparam	S_TX_MWR_HEAD_WAIT				= 9'b000100000;
localparam	S_TX_MWR_DATA					= 9'b001000000;
localparam	S_TX_MWR_WAIT					= 9'b010000000;
localparam	S_TX_MWR_DATA_LAST				= 9'b100000000;

reg		[8:0]								cur_state;
reg		[8:0]								next_state;

reg		[C_PCIE_DATA_WIDTH-1:0]				r_m_axis_tx_tdata;
reg		[(C_PCIE_DATA_WIDTH/8)-1:0]			r_m_axis_tx_tkeep;
reg		[3:0]								r_m_axis_tx_tuser;
reg											r_m_axis_tx_tlast;
reg											r_m_axis_tx_tvalid;

reg		[5:0]								r_tx_arb_gnt;
reg		[11:2]								r_tx_pcie_len;
reg		[11:2]								r_tx_pcie_data_cnt;
reg		[C_PCIE_DATA_WIDTH-1:0]				r_tx_pcie_head;
reg		[31:0]								r_tx_cpld_udata;
reg											r_tx_arb_rdy;

reg		[C_PCIE_DATA_WIDTH-1:0]				r_tx_mwr_rd_data;
reg		[C_PCIE_DATA_WIDTH-1:0]				r_tx_mwr_data;
reg		[C_PCIE_DATA_WIDTH-1:0]				r_tx_mwr_data_d1;

reg											r_tx_mwr0_rd_en;
reg											r_tx_mwr0_data_last;
reg											r_tx_mwr1_rd_en;
reg											r_tx_mwr1_data_last;

assign m_axis_tx_tdata = r_m_axis_tx_tdata;
assign m_axis_tx_tkeep = r_m_axis_tx_tkeep;
assign m_axis_tx_tuser = r_m_axis_tx_tuser;
assign m_axis_tx_tlast = r_m_axis_tx_tlast;
assign m_axis_tx_tvalid = r_m_axis_tx_tvalid;

assign tx_err_drop = 1'b0;

assign tx_arb_rdy = r_tx_arb_rdy;

assign tx_mwr0_rd_en = r_tx_mwr0_rd_en;
assign tx_mwr0_data_last = r_tx_mwr0_data_last;
assign tx_mwr1_rd_en = r_tx_mwr1_rd_en;
assign tx_mwr1_data_last = r_tx_mwr1_data_last;

always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0)
		cur_state <= S_TX_IDLE;
	else
		cur_state <= next_state;
end

always @ (*)
begin
	case(cur_state)
		S_TX_IDLE: begin
			if(tx_arb_valid == 1) begin
				case(tx_arb_type) // synthesis parallel_case full_case
					3'b001: next_state <= S_TX_CPLD_HEAD;
					3'b010: next_state <= S_TX_MRD_HEAD;
					3'b100: next_state <= S_TX_MWR_HEAD;
				endcase
			end
			else
				next_state <= S_TX_IDLE;
		end
		S_TX_CPLD_HEAD: begin
			if(m_axis_tx_tready == 1) begin
				if(r_tx_pcie_len[3] == 1)
					next_state <= S_TX_CPLD_DATA;
				else if(tx_arb_valid == 1) begin
					case(tx_arb_type) // synthesis parallel_case full_case
						3'b001: next_state <= S_TX_CPLD_HEAD;
						3'b010: next_state <= S_TX_MRD_HEAD;
						3'b100: next_state <= S_TX_MWR_HEAD;
					endcase
				end
				else
					next_state <= S_TX_IDLE;
			end
			else
				next_state <= S_TX_CPLD_HEAD;
		end
		S_TX_CPLD_DATA: begin
			if(m_axis_tx_tready == 1) begin
				if(tx_arb_valid == 1) begin
					case(tx_arb_type) // synthesis parallel_case full_case
						3'b001: next_state <= S_TX_CPLD_HEAD;
						3'b010: next_state <= S_TX_MRD_HEAD;
						3'b100: next_state <= S_TX_MWR_HEAD;
					endcase
				end
				else
					next_state <= S_TX_IDLE;
			end
			else
				next_state <= S_TX_CPLD_DATA;
		end
		S_TX_MRD_HEAD: begin
			if(m_axis_tx_tready == 1) begin
				if(tx_arb_valid == 1) begin
					case(tx_arb_type) // synthesis parallel_case full_case
						3'b001: next_state <= S_TX_CPLD_HEAD;
						3'b010: next_state <= S_TX_MRD_HEAD;
						3'b100: next_state <= S_TX_MWR_HEAD;
					endcase
				end
				else
					next_state <= S_TX_IDLE;
			end
			else
				next_state <= S_TX_MRD_HEAD;
		end
		S_TX_MWR_HEAD: begin
			if(m_axis_tx_tready == 1) begin
				if(r_tx_pcie_len == 4)
					next_state <= S_TX_MWR_DATA_LAST;
				else
					next_state <= S_TX_MWR_DATA;
			end
			else
				next_state <= S_TX_MWR_HEAD_WAIT;
		end
		S_TX_MWR_HEAD_WAIT: begin
			if(m_axis_tx_tready == 1) begin
				if(r_tx_pcie_data_cnt == 4)
					next_state <= S_TX_MWR_DATA_LAST;
				else
					next_state <= S_TX_MWR_DATA;
			end
			else
				next_state <= S_TX_MWR_HEAD_WAIT;
		end
		S_TX_MWR_DATA: begin
			if(m_axis_tx_tready == 1) begin
				if(r_tx_pcie_data_cnt == 8)
					next_state <= S_TX_MWR_DATA_LAST;
				else
					next_state <= S_TX_MWR_DATA;
			end
			else
				next_state <= S_TX_MWR_WAIT;
		end
		S_TX_MWR_WAIT: begin
			if(m_axis_tx_tready == 1) begin
				if(r_tx_pcie_data_cnt == 4)
					next_state <= S_TX_MWR_DATA_LAST;
				else
					next_state <= S_TX_MWR_DATA;
			end
			else
				next_state <= S_TX_MWR_WAIT;
		end
		S_TX_MWR_DATA_LAST: begin
			if(m_axis_tx_tready == 1) begin
				if(tx_arb_valid == 1) begin
					case(tx_arb_type) // synthesis parallel_case full_case
						3'b001: next_state <= S_TX_CPLD_HEAD;
						3'b010: next_state <= S_TX_MRD_HEAD;
						3'b100: next_state <= S_TX_MWR_HEAD;
					endcase
				end
				else
					next_state <= S_TX_IDLE;
			end
			else
				next_state <= S_TX_MWR_DATA_LAST;
		end
		default: begin
			next_state <= S_TX_IDLE;
		end
	endcase
end

always @ (*)
begin
	case(r_tx_arb_gnt[5:4]) // synthesis parallel_case full_case
		2'b01: begin
			r_tx_mwr_rd_data[31:0] <= {tx_mwr0_rd_data[7:0], tx_mwr0_rd_data[15:8], tx_mwr0_rd_data[23:16], tx_mwr0_rd_data[31:24]};
			r_tx_mwr_rd_data[63:32] <= {tx_mwr0_rd_data[39:32], tx_mwr0_rd_data[47:40], tx_mwr0_rd_data[55:48], tx_mwr0_rd_data[63:56]};
			r_tx_mwr_rd_data[95:64] <= {tx_mwr0_rd_data[71:64], tx_mwr0_rd_data[79:72], tx_mwr0_rd_data[87:80], tx_mwr0_rd_data[95:88]};
			r_tx_mwr_rd_data[127:96] <= {tx_mwr0_rd_data[103:96], tx_mwr0_rd_data[111:104], tx_mwr0_rd_data[119:112], tx_mwr0_rd_data[127:120]};
		end
		2'b10: begin
			r_tx_mwr_rd_data[31:0] <= {tx_mwr1_rd_data[7:0], tx_mwr1_rd_data[15:8], tx_mwr1_rd_data[23:16], tx_mwr1_rd_data[31:24]};
			r_tx_mwr_rd_data[63:32] <= {tx_mwr1_rd_data[39:32], tx_mwr1_rd_data[47:40], tx_mwr1_rd_data[55:48], tx_mwr1_rd_data[63:56]};
			r_tx_mwr_rd_data[95:64] <= {tx_mwr1_rd_data[71:64], tx_mwr1_rd_data[79:72], tx_mwr1_rd_data[87:80], tx_mwr1_rd_data[95:88]};
			r_tx_mwr_rd_data[127:96] <= {tx_mwr1_rd_data[103:96], tx_mwr1_rd_data[111:104], tx_mwr1_rd_data[119:112], tx_mwr1_rd_data[127:120]};
		end
	endcase
end

always @ (posedge pcie_user_clk)
begin
	if(r_tx_arb_rdy == 1) begin
		r_tx_arb_gnt <= tx_arb_gnt;
		r_tx_pcie_len <= tx_pcie_len;
		r_tx_pcie_head <= tx_pcie_head;
		r_tx_cpld_udata <= tx_cpld_udata;
	end
end

always @ (posedge pcie_user_clk)
begin
	case(cur_state)
		S_TX_IDLE: begin

		end
		S_TX_CPLD_HEAD: begin

		end
		S_TX_CPLD_DATA: begin

		end
		S_TX_MRD_HEAD: begin

		end
		S_TX_MWR_HEAD: begin
			r_tx_pcie_data_cnt <= r_tx_pcie_len;
			r_tx_mwr_data <= r_tx_mwr_rd_data;
		end
		S_TX_MWR_HEAD_WAIT: begin

		end
		S_TX_MWR_DATA: begin
			r_tx_pcie_data_cnt <= r_tx_pcie_data_cnt - 4;
			r_tx_mwr_data <= r_tx_mwr_rd_data;
			r_tx_mwr_data_d1 <= r_tx_mwr_data;
		end
		S_TX_MWR_WAIT: begin

		end
		S_TX_MWR_DATA_LAST: begin

		end
		default: begin
		end
	endcase
end


always @ (*)
begin
	case(cur_state)
		S_TX_IDLE: begin
			r_m_axis_tx_tdata <= r_tx_pcie_head;
			r_m_axis_tx_tkeep <= 16'h0000;
			r_m_axis_tx_tuser <= 4'b0000;
			r_m_axis_tx_tlast <= 0;
			r_m_axis_tx_tvalid <= 0;
			r_tx_arb_rdy <= 1;
			r_tx_mwr0_rd_en <= 0;
			r_tx_mwr0_data_last <= 0;
			r_tx_mwr1_rd_en <= 0;
			r_tx_mwr1_data_last <= 0;
		end
		S_TX_CPLD_HEAD: begin
			r_m_axis_tx_tdata <= r_tx_pcie_head;
			r_m_axis_tx_tkeep <= 16'hFFFF;
			r_m_axis_tx_tuser <= 4'b0100;
			r_m_axis_tx_tlast <= r_tx_pcie_len[2];
			r_m_axis_tx_tvalid <= 1;
			r_tx_arb_rdy <= r_tx_pcie_len[2] & m_axis_tx_tready;
			r_tx_mwr0_rd_en <= 0;
			r_tx_mwr0_data_last <= 0;
			r_tx_mwr1_rd_en <= 0;
			r_tx_mwr1_data_last <= 0;
		end
		S_TX_CPLD_DATA: begin
			r_m_axis_tx_tdata <= {96'h0, r_tx_cpld_udata};
			r_m_axis_tx_tkeep <= 16'h000F;
			r_m_axis_tx_tuser <= 4'b0100;
			r_m_axis_tx_tlast <= 1;
			r_m_axis_tx_tvalid <= 1;
			r_tx_arb_rdy <= m_axis_tx_tready;
			r_tx_mwr0_rd_en <= 0;
			r_tx_mwr0_data_last <= 0;
			r_tx_mwr1_rd_en <= 0;
			r_tx_mwr1_data_last <= 0;
		end
		S_TX_MRD_HEAD: begin
			r_m_axis_tx_tdata <= r_tx_pcie_head;
			r_m_axis_tx_tkeep <= 16'hFFFF;
			r_m_axis_tx_tuser <= 4'b0100;
			r_m_axis_tx_tlast <= 1;
			r_m_axis_tx_tvalid <= 1;
			r_tx_arb_rdy <= m_axis_tx_tready;
			r_tx_mwr0_rd_en <= 0;
			r_tx_mwr0_data_last <= 0;
			r_tx_mwr1_rd_en <= 0;
			r_tx_mwr1_data_last <= 0;
		end
		S_TX_MWR_HEAD: begin
			r_m_axis_tx_tdata <= r_tx_pcie_head;
			r_m_axis_tx_tkeep <= 16'hFFFF;
			r_m_axis_tx_tuser <= 4'b0100;
			r_m_axis_tx_tlast <= 0;
			r_m_axis_tx_tvalid <= 1;
			r_tx_arb_rdy <= 0;
			r_tx_mwr0_rd_en <= r_tx_arb_gnt[4];
			r_tx_mwr0_data_last <= 0;
			r_tx_mwr1_rd_en <= r_tx_arb_gnt[5];
			r_tx_mwr1_data_last <= 0;
		end
		S_TX_MWR_HEAD_WAIT: begin
			r_m_axis_tx_tdata <= r_tx_pcie_head;
			r_m_axis_tx_tkeep <= 16'hFFFF;
			r_m_axis_tx_tuser <= 4'b0100;
			r_m_axis_tx_tlast <= 0;
			r_m_axis_tx_tvalid <= 1;
			r_tx_arb_rdy <= 0;
			r_tx_mwr0_rd_en <= 0;
			r_tx_mwr0_data_last <= 0;
			r_tx_mwr1_rd_en <= 0;
			r_tx_mwr1_data_last <= 0;
		end
		S_TX_MWR_DATA: begin
			r_m_axis_tx_tdata <= r_tx_mwr_data;
			r_m_axis_tx_tkeep <= 16'hFFFF;
			r_m_axis_tx_tuser <= 4'b0100;
			r_m_axis_tx_tlast <= 0;
			r_m_axis_tx_tvalid <= 1;
			r_tx_arb_rdy <= 0;
			r_tx_mwr0_rd_en <= r_tx_arb_gnt[4];
			r_tx_mwr0_data_last <= 0;
			r_tx_mwr1_rd_en <= r_tx_arb_gnt[5];
			r_tx_mwr1_data_last <= 0;
		end
		S_TX_MWR_WAIT: begin
			r_m_axis_tx_tdata <= r_tx_mwr_data_d1;
			r_m_axis_tx_tkeep <= 16'hFFFF;
			r_m_axis_tx_tuser <= 4'b0100;
			r_m_axis_tx_tlast <= 0;
			r_m_axis_tx_tvalid <= 1;
			r_tx_arb_rdy <= 0;
			r_tx_mwr0_rd_en <= 0;
			r_tx_mwr0_data_last <= 0;
			r_tx_mwr1_rd_en <= 0;
			r_tx_mwr1_data_last <= 0;
		end
		S_TX_MWR_DATA_LAST: begin
			r_m_axis_tx_tdata <= r_tx_mwr_data;
			r_m_axis_tx_tkeep <= 16'hFFFF;
			r_m_axis_tx_tuser <= 4'b0100;
			r_m_axis_tx_tlast <= 1;
			r_m_axis_tx_tvalid <= 1;
			r_tx_arb_rdy <= m_axis_tx_tready;
			r_tx_mwr0_rd_en <= 0;
			r_tx_mwr0_data_last <= r_tx_arb_gnt[4] & m_axis_tx_tready;
			r_tx_mwr1_rd_en <= 0;
			r_tx_mwr1_data_last <= r_tx_arb_gnt[5] & m_axis_tx_tready;
		end
		default: begin
			r_m_axis_tx_tdata <= 128'b0;
			r_m_axis_tx_tkeep <= 16'h0000;
			r_m_axis_tx_tuser <= 4'b0000;
			r_m_axis_tx_tlast <= 0;
			r_m_axis_tx_tvalid <= 0;
			r_tx_arb_rdy <= 0;
			r_tx_mwr0_rd_en <= 0;
			r_tx_mwr0_data_last <= 0;
			r_tx_mwr1_rd_en <= 0;
			r_tx_mwr1_data_last <= 0;
		end
	endcase
end

endmodule

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


module pcie_rx_recv # (
	parameter	C_PCIE_DATA_WIDTH			= 128
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,

//pcie rx signal
	input	[C_PCIE_DATA_WIDTH-1:0]			s_axis_rx_tdata,
	input	[(C_PCIE_DATA_WIDTH/8)-1:0]		s_axis_rx_tkeep,
	input									s_axis_rx_tlast,
	input									s_axis_rx_tvalid,
	output									s_axis_rx_tready,
	input	[21:0]							s_axis_rx_tuser,

	output									pcie_mreq_err,
	output									pcie_cpld_err,
	output									pcie_cpld_len_err,

	output									mreq_fifo_wr_en,
	output	[C_PCIE_DATA_WIDTH-1:0]			mreq_fifo_wr_data,

	output	[7:0]							cpld_fifo_tag,
	output	[C_PCIE_DATA_WIDTH-1:0]			cpld_fifo_wr_data,
	output									cpld_fifo_wr_en,
	output									cpld_fifo_tag_last
);


localparam	S_RX_IDLE_SOF					= 4'b0001;
localparam	S_RX_DATA						= 4'b0010;
localparam	S_RX_STRADDLED					= 4'b0100;
localparam	S_RX_STRADDLED_HOLD				= 4'b1000;

reg		[3:0]								cur_state;
reg		[3:0]								next_state;


wire	[4:0]								w_rx_is_sof;
wire	[4:0]								w_rx_is_eof;

reg		[31:0]								r_pcie_head0;
reg		[31:0]								r_pcie_head1;
reg		[31:0]								r_pcie_head2;

wire	[2:0]								w_mreq_head_fmt;
wire	[4:0]								w_mreq_head_type;
//wire	[2:0]								w_mreq_head_tc;
//wire										w_mreq_head_attr1;
//wire										w_mreq_head_th;
//wire										w_mreq_head_td;
wire										w_mreq_head_ep;
//wire	[1:0]								w_mreq_head_atqtr0;
//wire	[1:0]								w_mreq_head_at;
//wire	[9:0]								w_mreq_head_len;
//wire	[7:0]								w_mreq_head_re_bus_num;
//wire	[4:0]								w_mreq_head_req_dev_num;
//wire	[2:0]								w_mreq_head_req_func_num;
//wire	[15:0]								w_mreq_head_req_id;
//wire	[7:0]								w_mreq_head_tag;


wire	[2:0]								w_cpld_head_fmt;
wire	[4:0]								w_cpld_head_type;
//wire	[2:0]								w_cpld_head_tc;
//wire										w_cpld_head_attr1;
//wire										w_cpld_head_th;
//wire										w_cpld_head_td;
wire										w_cpld_head_ep;
//wire	[1:0]								w_cpld_head_attr0;
//wire	[1:0]								w_cpld_head_at;
wire	[9:0]								w_cpld_head_len;
//wire	[7:0]								w_cpld_head_cpl_bus_num;
//wire	[4:0]								w_cpld_head_cpl_dev_num;
//wire	[2:0]								w_cpld_head_cpl_func_num;
//wire	[15:0]								w_cpld_head_cpl_id;
wire	[2:0]								w_cpld_head_cs;
//wire										w_cpld_head_bcm;
wire	[11:0]								w_cpld_head_bc;
//wire	[7:0]								w_cpld_head_req_bus_num;
//wire	[4:0]								w_cpld_head_req_dev_num;
//wire	[2:0]								w_cpld_head_req_func_num;
//wire	[15:0]								w_cpld_head_req_id;
wire	[7:0]								w_cpld_head_tag;
//wire	[6:0]								w_cpld_head_la;


wire										w_pcie_mreq_type;
wire										w_pcie_cpld_type;
reg											r_pcie_mreq_type;
reg											r_pcie_cpld_type;

reg											r_pcie_mreq_err;
reg											r_pcie_cpld_err;
reg											r_pcie_cpld_len_err;

reg		[7:0]								r_cpld_tag;
reg		[11:2]								r_cpld_len;
reg		[11:2]								r_cpld_bc;
reg											r_cpld_lhead;

reg											r_mem_req_en;
reg											r_cpld_data_en;
reg											r_cpld_tag_last;
reg											r_rx_straddled;
reg											r_rx_straddled_hold;

reg											r_rx_data_straddled;
reg		[127:0]								r_s_axis_rx_tdata;
reg		[127:0]								r_s_axis_rx_tdata_d1;

reg											r_mreq_fifo_wr_en;
reg		[127:0]								r_mreq_fifo_wr_data;

reg											r_cpld_fifo_tag_en;
reg											r_cpld_fifo_wr_en;
reg		[127:0]								r_cpld_fifo_wr_data;
reg											r_cpld_fifo_tag_last;

assign s_axis_rx_tready = ~r_rx_straddled_hold;

assign pcie_mreq_err = r_pcie_mreq_err;
assign pcie_cpld_err = r_pcie_cpld_err;
assign pcie_cpld_len_err = r_pcie_cpld_len_err;

assign mreq_fifo_wr_en = r_mreq_fifo_wr_en;
assign mreq_fifo_wr_data = r_mreq_fifo_wr_data;

assign cpld_fifo_tag = r_cpld_tag;
assign cpld_fifo_wr_en = r_cpld_fifo_wr_en;

assign cpld_fifo_wr_data[31:0] = {r_cpld_fifo_wr_data[7:0], r_cpld_fifo_wr_data[15:8], r_cpld_fifo_wr_data[23:16], r_cpld_fifo_wr_data[31:24]};
assign cpld_fifo_wr_data[63:32] = {r_cpld_fifo_wr_data[39:32], r_cpld_fifo_wr_data[47:40], r_cpld_fifo_wr_data[55:48], r_cpld_fifo_wr_data[63:56]};
assign cpld_fifo_wr_data[95:64] = {r_cpld_fifo_wr_data[71:64], r_cpld_fifo_wr_data[79:72], r_cpld_fifo_wr_data[87:80], r_cpld_fifo_wr_data[95:88]};
assign cpld_fifo_wr_data[127:96] = {r_cpld_fifo_wr_data[103:96], r_cpld_fifo_wr_data[111:104], r_cpld_fifo_wr_data[119:112], r_cpld_fifo_wr_data[127:120]};

assign cpld_fifo_tag_last = r_cpld_fifo_tag_last;


assign w_rx_is_sof = s_axis_rx_tuser[14:10];
assign w_rx_is_eof = s_axis_rx_tuser[21:17];

always @ (*)
begin
	if(w_rx_is_sof[3] == 1) begin
		r_pcie_head0 <= s_axis_rx_tdata[95:64];
		r_pcie_head1 <= s_axis_rx_tdata[127:96];
	end
	else begin
		r_pcie_head0 <= s_axis_rx_tdata[31:0];
		r_pcie_head1 <= s_axis_rx_tdata[63:32];
	end

	if(r_rx_straddled == 1)
		r_pcie_head2 <= s_axis_rx_tdata[31:0];
	else
		r_pcie_head2 <= s_axis_rx_tdata[95:64];
end



//pcie mrd or mwr, memory rd/wr request
assign w_mreq_head_fmt = r_pcie_head0[31:29];
assign w_mreq_head_type = r_pcie_head0[28:24];
//assign w_mreq_head_tc = r_pcie_head0[22:20];
//assign w_mreq_head_attr1 = r_pcie_head0[18];
//assign w_mreq_head_th = r_pcie_head0[16];
//assign w_mreq_head_td = r_pcie_head0[15];
assign w_mreq_head_ep = r_pcie_head0[14];
//assign w_mreq_head_attr0 = r_pcie_head0[13:12];
//assign w_mreq_head_at = r_pcie_head0[11:10];
//assign w_mreq_head_len = r_pcie_head0[9:0];
//assign w_mreq_head_req_bus_num = r_pcie_head1[31:24];
//assign w_mreq_head_req_dev_num = r_pcie_head1[23:19];
//assign w_mreq_head_req_func_num = r_pcie_head1[18:16];
//assign w_mreq_head_req_id = {w_mreq_head_req_bus_num, w_mreq_head_req_dev_num, w_mreq_head_req_func_num};
//assign w_mreq_head_tag = r_pcie_head1[15:8];

//pcie cpl or cpld
assign w_cpld_head_fmt = r_pcie_head0[31:29];
assign w_cpld_head_type = r_pcie_head0[28:24];
//assign w_cpld_head_tc = r_pcie_head0[22:20];
//assign w_cpld_head_attr1 = r_pcie_head0[18];
//assign w_cpld_head_th = r_pcie_head0[16];
//assign w_cpld_head_td = r_pcie_head0[15];
assign w_cpld_head_ep = r_pcie_head0[14];
//assign w_cpld_head_attr0 = r_pcie_head0[13:12];
//assign w_cpld_head_at = r_pcie_head0[11:10];
assign w_cpld_head_len = r_pcie_head0[9:0];
//assign w_cpld_head_cpl_bus_num = r_pcie_head1[31:24];
//assign w_cpld_head_cpl_dev_num = r_pcie_head1[23:19];
//assign w_cpld_head_cpl_func_num = r_pcie_head1[18:16];
//assign w_cpld_head_cpl_id = {w_cpld_head_cpl_bus_num, w_cpld_head_cpl_dev_num, w_cpld_head_cpl_func_num};
assign w_cpld_head_cs = r_pcie_head1[15:13];
//assign w_cpld_head_bcm = r_pcie_head1[12];
assign w_cpld_head_bc = r_pcie_head1[11:0];
//assign w_cpld_head_req_bus_num = r_pcie_head2[31:24];
//assign w_cpld_head_req_dev_num = r_pcie_head2[23:19];
//assign w_cpld_head_req_func_num = r_pcie_head2[18:16];
//assign w_cpld_head_req_id = {w_cpld_head_req_bus_num, w_cpld_head_req_dev_num, w_cpld_head_req_func_num};
assign w_cpld_head_tag = r_pcie_head2[15:8];
//assign w_cpld_head_la = r_pcie_head2[6:0];


assign w_pcie_mreq_type = ({w_mreq_head_fmt[2], w_mreq_head_type} == {1'b0, 5'b00000});
assign w_pcie_cpld_type = ({w_cpld_head_fmt, w_cpld_head_type} == {3'b010, 5'b01010});

always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0)
		cur_state <= S_RX_IDLE_SOF;
	else
		cur_state <= next_state;
end

always @ (*)
begin
	case(cur_state)
		S_RX_IDLE_SOF: begin
			if(s_axis_rx_tvalid == 1 && w_rx_is_sof[4] == 1 && w_rx_is_eof[4] == 0 ) begin
				if(w_rx_is_sof[3] == 1)
					next_state <= S_RX_STRADDLED;
				else
					next_state <= S_RX_DATA;
			end
			else
				next_state <= S_RX_IDLE_SOF;
		end
		S_RX_DATA: begin
			if(s_axis_rx_tvalid == 1 && w_rx_is_eof[4] == 1) begin
				if(w_rx_is_sof[4] == 1)
					next_state <= S_RX_STRADDLED;
				else
					next_state <= S_RX_IDLE_SOF;
			end
			else
				next_state <= S_RX_DATA;
		end
		S_RX_STRADDLED: begin
			if(s_axis_rx_tvalid == 1 && w_rx_is_eof[4] == 1) begin
				if(w_rx_is_sof[4] == 1)
					next_state <= S_RX_STRADDLED;
				else if(w_rx_is_eof[3] == 1)
					next_state <= S_RX_STRADDLED_HOLD;
				else
					next_state <= S_RX_IDLE_SOF;
			end
			else
				next_state <= S_RX_STRADDLED;
		end
		S_RX_STRADDLED_HOLD: begin
			next_state <= S_RX_IDLE_SOF;
		end
		default: begin
			next_state <= S_RX_IDLE_SOF;
		end
	endcase
end

always @ (posedge pcie_user_clk)
begin
	if(s_axis_rx_tvalid == 1 && w_rx_is_sof[4] == 1) begin
		r_pcie_mreq_type <= w_pcie_mreq_type & ~w_mreq_head_ep;
		r_pcie_cpld_type <= w_pcie_cpld_type & ~w_cpld_head_ep & (w_cpld_head_cs == 0);

		r_cpld_len <= w_cpld_head_len;
		r_cpld_bc[11:2] <= w_cpld_head_bc[11:2];
	end
end


always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0) begin
		r_pcie_mreq_err <= 0;
		r_pcie_cpld_err <= 0;
		r_pcie_cpld_len_err <= 0;
	end
	else begin
		if(r_pcie_cpld_type == 1 && r_cpld_len < 2) begin
			r_pcie_cpld_len_err <= 1;
		end

		if(s_axis_rx_tvalid == 1 && w_rx_is_sof[4] == 1) begin
			r_pcie_mreq_err <= w_pcie_mreq_type & w_mreq_head_ep;
			r_pcie_cpld_err <= w_pcie_cpld_type & (w_cpld_head_ep | (w_cpld_head_cs != 0));
		end
	end
end


always @ (posedge pcie_user_clk)
begin
	case(cur_state)
		S_RX_IDLE_SOF: begin
			r_cpld_tag <= w_cpld_head_tag;
			r_cpld_lhead <= 0;
		end
		S_RX_DATA: begin

		end
		S_RX_STRADDLED: begin
			if(s_axis_rx_tvalid == 1)
				r_cpld_lhead <= ~w_rx_is_sof[4];

			if(r_cpld_lhead == 0)
				r_cpld_tag <= w_cpld_head_tag;
		end
		S_RX_STRADDLED_HOLD: begin

		end
		default: begin

		end
	endcase
end


always @ (*)
begin
	case(cur_state)
		S_RX_IDLE_SOF: begin
			r_mem_req_en <= (s_axis_rx_tvalid & w_rx_is_sof[4] & ~w_rx_is_sof[3]) & w_pcie_mreq_type;
			r_cpld_data_en <= 0;
			r_cpld_tag_last <= 0;
			r_rx_straddled <= 0;
			r_rx_straddled_hold <= 0;
		end
		S_RX_DATA: begin
			r_mem_req_en <= s_axis_rx_tvalid & r_pcie_mreq_type;
			r_cpld_data_en <= s_axis_rx_tvalid & r_pcie_cpld_type;
			r_cpld_tag_last <= (r_cpld_len == r_cpld_bc[11:2]) & (s_axis_rx_tvalid & r_pcie_cpld_type & w_rx_is_eof[4]);
			r_rx_straddled <= 0;
			r_rx_straddled_hold <= 0;
		end
		S_RX_STRADDLED: begin
			r_mem_req_en <= s_axis_rx_tvalid & r_pcie_mreq_type;
			r_cpld_data_en <= s_axis_rx_tvalid & r_pcie_cpld_type & r_cpld_lhead;
			r_cpld_tag_last <= (r_cpld_len == r_cpld_bc[11:2]) & (s_axis_rx_tvalid & r_pcie_cpld_type & w_rx_is_eof[4] & ~w_rx_is_eof[3]);
			r_rx_straddled <= 1;
			r_rx_straddled_hold <= 0;
		end
		S_RX_STRADDLED_HOLD: begin
			r_mem_req_en <= r_pcie_mreq_type;
			r_cpld_data_en <= r_pcie_cpld_type;
			r_cpld_tag_last <= (r_cpld_len == r_cpld_bc[11:2]) & r_pcie_cpld_type;
			r_rx_straddled <= 1;
			r_rx_straddled_hold <= 1;
		end
		default: begin
			r_mem_req_en <= 0;
			r_cpld_data_en <= 0;
			r_cpld_tag_last <= 0;
			r_rx_straddled <= 0;
			r_rx_straddled_hold <= 0;
		end
	endcase
end

always @ (posedge pcie_user_clk)
begin
	r_mreq_fifo_wr_en <= r_mem_req_en;
	r_cpld_fifo_wr_en <= r_cpld_data_en;
	r_cpld_fifo_tag_last <= r_cpld_tag_last;
	r_rx_data_straddled <= r_rx_straddled;

	if(s_axis_rx_tvalid == 1 || r_rx_straddled_hold == 1) begin
		r_s_axis_rx_tdata <= s_axis_rx_tdata;
		r_s_axis_rx_tdata_d1 <= r_s_axis_rx_tdata;
	end
end

always @ (*)
begin
	if(r_rx_data_straddled == 1)
		r_mreq_fifo_wr_data <= {r_s_axis_rx_tdata[63:0], r_s_axis_rx_tdata_d1[127:64]};
	else
		r_mreq_fifo_wr_data <= r_s_axis_rx_tdata;

	if(r_rx_data_straddled == 1)
		r_cpld_fifo_wr_data <= {r_s_axis_rx_tdata[31:0], r_s_axis_rx_tdata_d1[127:32]};
	else
		r_cpld_fifo_wr_data <= {r_s_axis_rx_tdata[95:0], r_s_axis_rx_tdata_d1[127:96]};
end


endmodule
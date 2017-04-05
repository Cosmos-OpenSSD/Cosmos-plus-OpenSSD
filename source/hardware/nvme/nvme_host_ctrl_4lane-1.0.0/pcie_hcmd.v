
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

module pcie_hcmd # (
	parameter	C_PCIE_DATA_WIDTH			= 128,
	parameter	C_PCIE_ADDR_WIDTH			= 36
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,

	input	[C_PCIE_ADDR_WIDTH-1:2]			admin_sq_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			admin_cq_bs_addr,
	input	[7:0]							admin_sq_size,
	input	[7:0]							admin_cq_size,

	input	[7:0]							admin_sq_tail_ptr,
	input	[7:0]							io_sq1_tail_ptr,
	input	[7:0]							io_sq2_tail_ptr,
	input	[7:0]							io_sq3_tail_ptr,
	input	[7:0]							io_sq4_tail_ptr,
	input	[7:0]							io_sq5_tail_ptr,
	input	[7:0]							io_sq6_tail_ptr,
	input	[7:0]							io_sq7_tail_ptr,
	input	[7:0]							io_sq8_tail_ptr,

	input	[7:0]							cpld_sq_fifo_tag,
	input	[C_PCIE_DATA_WIDTH-1:0]			cpld_sq_fifo_wr_data,
	input									cpld_sq_fifo_wr_en,
	input									cpld_sq_fifo_tag_last,

	output									tx_mrd_req,
	output	[7:0]							tx_mrd_tag,
	output	[11:2]							tx_mrd_len,
	output	[C_PCIE_ADDR_WIDTH-1:2]			tx_mrd_addr,
	input									tx_mrd_req_ack,

	output	[7:0]							admin_cq_tail_ptr,
	output	[7:0]							io_cq1_tail_ptr,
	output	[7:0]							io_cq2_tail_ptr,
	output	[7:0]							io_cq3_tail_ptr,
	output	[7:0]							io_cq4_tail_ptr,
	output	[7:0]							io_cq5_tail_ptr,
	output	[7:0]							io_cq6_tail_ptr,
	output	[7:0]							io_cq7_tail_ptr,
	output	[7:0]							io_cq8_tail_ptr,

	output									tx_cq_mwr_req,
	output	[7:0]							tx_cq_mwr_tag,
	output	[11:2]							tx_cq_mwr_len,
	output	[C_PCIE_ADDR_WIDTH-1:2]			tx_cq_mwr_addr,
	input									tx_cq_mwr_req_ack,
	input									tx_cq_mwr_rd_en,
	output	[C_PCIE_DATA_WIDTH-1:0]			tx_cq_mwr_rd_data,
	input									tx_cq_mwr_data_last,

	input	[7:0]							hcmd_prp_rd_addr,
	output	[44:0]							hcmd_prp_rd_data,

	input									hcmd_nlb_wr1_en,
	input	[6:0]							hcmd_nlb_wr1_addr,
	input	[18:0]							hcmd_nlb_wr1_data,
	output									hcmd_nlb_wr1_rdy_n,

	input	[6:0]							hcmd_nlb_rd_addr,
	output	[18:0]							hcmd_nlb_rd_data,

	input									hcmd_cq_wr0_en,
	input	[34:0]							hcmd_cq_wr0_data0,
	input	[34:0]							hcmd_cq_wr0_data1,
	output									hcmd_cq_wr0_rdy_n,
	
	input									cpu_bus_clk,
	input									cpu_bus_rst_n,

	input	[8:0]							sq_rst_n,
	input	[8:0]							sq_valid,
	input	[7:0]							io_sq1_size,
	input	[7:0]							io_sq2_size,
	input	[7:0]							io_sq3_size,
	input	[7:0]							io_sq4_size,
	input	[7:0]							io_sq5_size,
	input	[7:0]							io_sq6_size,
	input	[7:0]							io_sq7_size,
	input	[7:0]							io_sq8_size,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_sq1_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_sq2_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_sq3_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_sq4_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_sq5_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_sq6_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_sq7_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_sq8_bs_addr,
	input	[3:0]							io_sq1_cq_vec,
	input	[3:0]							io_sq2_cq_vec,
	input	[3:0]							io_sq3_cq_vec,
	input	[3:0]							io_sq4_cq_vec,
	input	[3:0]							io_sq5_cq_vec,
	input	[3:0]							io_sq6_cq_vec,
	input	[3:0]							io_sq7_cq_vec,
	input	[3:0]							io_sq8_cq_vec,

	input	[8:0]							cq_rst_n,
	input	[8:0]							cq_valid,
	input	[7:0]							io_cq1_size,
	input	[7:0]							io_cq2_size,
	input	[7:0]							io_cq3_size,
	input	[7:0]							io_cq4_size,
	input	[7:0]							io_cq5_size,
	input	[7:0]							io_cq6_size,
	input	[7:0]							io_cq7_size,
	input	[7:0]							io_cq8_size,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_cq1_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_cq2_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_cq3_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_cq4_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_cq5_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_cq6_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_cq7_bs_addr,
	input	[C_PCIE_ADDR_WIDTH-1:2]			io_cq8_bs_addr,

	input									hcmd_sq_rd_en,
	output	[18:0]							hcmd_sq_rd_data,
	output									hcmd_sq_empty_n,

	input	[10:0]							hcmd_table_rd_addr,
	output	[31:0]							hcmd_table_rd_data,

	input									hcmd_cq_wr1_en,
	input	[34:0]							hcmd_cq_wr1_data0,
	input	[34:0]							hcmd_cq_wr1_data1,
	output									hcmd_cq_wr1_rdy_n
);

wire										w_hcmd_table_wr_en;
wire	[8:0]								w_hcmd_table_wr_addr;
wire	[127:0]								w_hcmd_table_wr_data;

wire										w_hcmd_cid_wr_en;
wire	[6:0]								w_hcmd_cid_wr_addr;
wire	[19:0]								w_hcmd_cid_wr_data;

wire	[6:0]								w_hcmd_cid_rd_addr;
wire	[19:0]								w_hcmd_cid_rd_data;

wire										w_hcmd_prp_wr_en;
wire	[7:0]								w_hcmd_prp_wr_addr;
wire	[44:0]								w_hcmd_prp_wr_data;

wire										w_hcmd_nlb_wr0_en;
wire	[6:0]								w_hcmd_nlb_wr0_addr;
wire	[18:0]								w_hcmd_nlb_wr0_data;
wire										w_hcmd_nlb_wr0_rdy_n;

wire										w_hcmd_slot_rdy;
wire	[6:0]								w_hcmd_slot_tag;
wire										w_hcmd_slot_alloc_en;

wire										w_hcmd_slot_free_en;
wire	[6:0]								w_hcmd_slot_invalid_tag;

wire	[7:0]								w_admin_sq_head_ptr;
wire	[7:0]								w_io_sq1_head_ptr;
wire	[7:0]								w_io_sq2_head_ptr;
wire	[7:0]								w_io_sq3_head_ptr;
wire	[7:0]								w_io_sq4_head_ptr;
wire	[7:0]								w_io_sq5_head_ptr;
wire	[7:0]								w_io_sq6_head_ptr;
wire	[7:0]								w_io_sq7_head_ptr;
wire	[7:0]								w_io_sq8_head_ptr;


pcie_hcmd_table 
pcie_hcmd_table_inst0(
	.wr_clk									(pcie_user_clk),

	.wr_en									(w_hcmd_table_wr_en),
	.wr_addr								(w_hcmd_table_wr_addr),
	.wr_data								(w_hcmd_table_wr_data),

	.rd_clk									(cpu_bus_clk),

	.rd_addr								(hcmd_table_rd_addr),
	.rd_data								(hcmd_table_rd_data)
);

pcie_hcmd_table_cid 
pcie_hcmd_table_cid_isnt0(
	.clk									(pcie_user_clk),

	.wr_en									(w_hcmd_cid_wr_en),
	.wr_addr								(w_hcmd_cid_wr_addr),
	.wr_data								(w_hcmd_cid_wr_data),

	.rd_addr								(w_hcmd_cid_rd_addr),
	.rd_data								(w_hcmd_cid_rd_data)
);

pcie_hcmd_table_prp 
pcie_hcmd_table_prp_isnt0(
	.clk									(pcie_user_clk),

	.wr_en									(w_hcmd_prp_wr_en),
	.wr_addr								(w_hcmd_prp_wr_addr),
	.wr_data								(w_hcmd_prp_wr_data),

	.rd_addr								(hcmd_prp_rd_addr),
	.rd_data								(hcmd_prp_rd_data)
);

pcie_hcmd_nlb
pcie_hcmd_nlb_inst0
(
	.clk									(pcie_user_clk),
	.rst_n									(pcie_user_rst_n),

	.wr0_en									(w_hcmd_nlb_wr0_en),
	.wr0_addr								(w_hcmd_nlb_wr0_addr),
	.wr0_data								(w_hcmd_nlb_wr0_data),
	.wr0_rdy_n								(w_hcmd_nlb_wr0_rdy_n),

	.wr1_en									(hcmd_nlb_wr1_en),
	.wr1_addr								(hcmd_nlb_wr1_addr),
	.wr1_data								(hcmd_nlb_wr1_data),
	.wr1_rdy_n								(hcmd_nlb_wr1_rdy_n),

	.rd_addr								(hcmd_nlb_rd_addr),
	.rd_data								(hcmd_nlb_rd_data)
);

pcie_hcmd_slot_mgt
pcie_hcmd_slot_mgt_inst0
(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.hcmd_slot_rdy							(w_hcmd_slot_rdy),
	.hcmd_slot_tag							(w_hcmd_slot_tag),
	.hcmd_slot_alloc_en						(w_hcmd_slot_alloc_en),

	.hcmd_slot_free_en						(w_hcmd_slot_free_en),
	.hcmd_slot_invalid_tag					(w_hcmd_slot_invalid_tag)
);

pcie_hcmd_sq # (
	.C_PCIE_DATA_WIDTH						(C_PCIE_DATA_WIDTH)
)
pcie_hcmd_sq_inst0(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.admin_sq_bs_addr						(admin_sq_bs_addr),
	.admin_sq_size							(admin_sq_size),

	.admin_sq_tail_ptr						(admin_sq_tail_ptr),
	.io_sq1_tail_ptr						(io_sq1_tail_ptr),
	.io_sq2_tail_ptr						(io_sq2_tail_ptr),
	.io_sq3_tail_ptr						(io_sq3_tail_ptr),
	.io_sq4_tail_ptr						(io_sq4_tail_ptr),
	.io_sq5_tail_ptr						(io_sq5_tail_ptr),
	.io_sq6_tail_ptr						(io_sq6_tail_ptr),
	.io_sq7_tail_ptr						(io_sq7_tail_ptr),
	.io_sq8_tail_ptr						(io_sq8_tail_ptr),

	.admin_sq_head_ptr						(w_admin_sq_head_ptr),
	.io_sq1_head_ptr						(w_io_sq1_head_ptr),
	.io_sq2_head_ptr						(w_io_sq2_head_ptr),
	.io_sq3_head_ptr						(w_io_sq3_head_ptr),
	.io_sq4_head_ptr						(w_io_sq4_head_ptr),
	.io_sq5_head_ptr						(w_io_sq5_head_ptr),
	.io_sq6_head_ptr						(w_io_sq6_head_ptr),
	.io_sq7_head_ptr						(w_io_sq7_head_ptr),
	.io_sq8_head_ptr						(w_io_sq8_head_ptr),

	.hcmd_slot_rdy							(w_hcmd_slot_rdy),
	.hcmd_slot_tag							(w_hcmd_slot_tag),
	.hcmd_slot_alloc_en						(w_hcmd_slot_alloc_en),

	.cpld_sq_fifo_tag						(cpld_sq_fifo_tag),
	.cpld_sq_fifo_wr_data					(cpld_sq_fifo_wr_data),
	.cpld_sq_fifo_wr_en						(cpld_sq_fifo_wr_en),
	.cpld_sq_fifo_tag_last					(cpld_sq_fifo_tag_last),

	.tx_mrd_req								(tx_mrd_req),
	.tx_mrd_tag								(tx_mrd_tag),
	.tx_mrd_len								(tx_mrd_len),
	.tx_mrd_addr							(tx_mrd_addr),
	.tx_mrd_req_ack							(tx_mrd_req_ack),

	.hcmd_table_wr_en						(w_hcmd_table_wr_en),
	.hcmd_table_wr_addr						(w_hcmd_table_wr_addr),
	.hcmd_table_wr_data						(w_hcmd_table_wr_data),

	.hcmd_cid_wr_en							(w_hcmd_cid_wr_en),
	.hcmd_cid_wr_addr						(w_hcmd_cid_wr_addr),
	.hcmd_cid_wr_data						(w_hcmd_cid_wr_data),

	.hcmd_prp_wr_en							(w_hcmd_prp_wr_en),
	.hcmd_prp_wr_addr						(w_hcmd_prp_wr_addr),
	.hcmd_prp_wr_data						(w_hcmd_prp_wr_data),

	.hcmd_nlb_wr0_en						(w_hcmd_nlb_wr0_en),
	.hcmd_nlb_wr0_addr						(w_hcmd_nlb_wr0_addr),
	.hcmd_nlb_wr0_data						(w_hcmd_nlb_wr0_data),
	.hcmd_nlb_wr0_rdy_n						(w_hcmd_nlb_wr0_rdy_n),

	.cpu_bus_clk							(cpu_bus_clk),
	.cpu_bus_rst_n							(cpu_bus_rst_n),

	.sq_rst_n								(sq_rst_n),
	.sq_valid								(sq_valid),
	.io_sq1_size							(io_sq1_size),
	.io_sq2_size							(io_sq2_size),
	.io_sq3_size							(io_sq3_size),
	.io_sq4_size							(io_sq4_size),
	.io_sq5_size							(io_sq5_size),
	.io_sq6_size							(io_sq6_size),
	.io_sq7_size							(io_sq7_size),
	.io_sq8_size							(io_sq8_size),
	.io_sq1_bs_addr							(io_sq1_bs_addr),
	.io_sq2_bs_addr							(io_sq2_bs_addr),
	.io_sq3_bs_addr							(io_sq3_bs_addr),
	.io_sq4_bs_addr							(io_sq4_bs_addr),
	.io_sq5_bs_addr							(io_sq5_bs_addr),
	.io_sq6_bs_addr							(io_sq6_bs_addr),
	.io_sq7_bs_addr							(io_sq7_bs_addr),
	.io_sq8_bs_addr							(io_sq8_bs_addr),

	.hcmd_sq_rd_en							(hcmd_sq_rd_en),
	.hcmd_sq_rd_data						(hcmd_sq_rd_data),
	.hcmd_sq_empty_n						(hcmd_sq_empty_n)
);

pcie_hcmd_cq # (
	.C_PCIE_DATA_WIDTH						(C_PCIE_DATA_WIDTH)
)
pcie_hcmd_cq_inst0(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.hcmd_cid_rd_addr						(w_hcmd_cid_rd_addr),
	.hcmd_cid_rd_data						(w_hcmd_cid_rd_data),

	.admin_cq_bs_addr						(admin_cq_bs_addr),
	.admin_cq_size							(admin_cq_size),

	.admin_cq_tail_ptr						(admin_cq_tail_ptr),
	.io_cq1_tail_ptr						(io_cq1_tail_ptr),
	.io_cq2_tail_ptr						(io_cq2_tail_ptr),
	.io_cq3_tail_ptr						(io_cq3_tail_ptr),
	.io_cq4_tail_ptr						(io_cq4_tail_ptr),
	.io_cq5_tail_ptr						(io_cq5_tail_ptr),
	.io_cq6_tail_ptr						(io_cq6_tail_ptr),
	.io_cq7_tail_ptr						(io_cq7_tail_ptr),
	.io_cq8_tail_ptr						(io_cq8_tail_ptr),

	.admin_sq_head_ptr						(w_admin_sq_head_ptr),
	.io_sq1_head_ptr						(w_io_sq1_head_ptr),
	.io_sq2_head_ptr						(w_io_sq2_head_ptr),
	.io_sq3_head_ptr						(w_io_sq3_head_ptr),
	.io_sq4_head_ptr						(w_io_sq4_head_ptr),
	.io_sq5_head_ptr						(w_io_sq5_head_ptr),
	.io_sq6_head_ptr						(w_io_sq6_head_ptr),
	.io_sq7_head_ptr						(w_io_sq7_head_ptr),
	.io_sq8_head_ptr						(w_io_sq8_head_ptr),

	.hcmd_slot_free_en						(w_hcmd_slot_free_en),
	.hcmd_slot_invalid_tag					(w_hcmd_slot_invalid_tag),

	.tx_cq_mwr_req							(tx_cq_mwr_req),
	.tx_cq_mwr_tag							(tx_cq_mwr_tag),
	.tx_cq_mwr_len							(tx_cq_mwr_len),
	.tx_cq_mwr_addr							(tx_cq_mwr_addr),
	.tx_cq_mwr_req_ack						(tx_cq_mwr_req_ack),
	.tx_cq_mwr_rd_en						(tx_cq_mwr_rd_en),
	.tx_cq_mwr_rd_data						(tx_cq_mwr_rd_data),
	.tx_cq_mwr_data_last					(tx_cq_mwr_data_last),

	.hcmd_cq_wr0_en							(hcmd_cq_wr0_en),
	.hcmd_cq_wr0_data0						(hcmd_cq_wr0_data0),
	.hcmd_cq_wr0_data1						(hcmd_cq_wr0_data1),
	.hcmd_cq_wr0_rdy_n						(hcmd_cq_wr0_rdy_n),

	.cpu_bus_clk							(cpu_bus_clk),
	.cpu_bus_rst_n							(cpu_bus_rst_n),

	.io_sq1_cq_vec							(io_sq1_cq_vec),
	.io_sq2_cq_vec							(io_sq2_cq_vec),
	.io_sq3_cq_vec							(io_sq3_cq_vec),
	.io_sq4_cq_vec							(io_sq4_cq_vec),
	.io_sq5_cq_vec							(io_sq5_cq_vec),
	.io_sq6_cq_vec							(io_sq6_cq_vec),
	.io_sq7_cq_vec							(io_sq7_cq_vec),
	.io_sq8_cq_vec							(io_sq8_cq_vec),

	.sq_valid								(sq_valid),
	.cq_rst_n								(cq_rst_n),
	.cq_valid								(cq_valid),
	.io_cq1_size							(io_cq1_size),
	.io_cq2_size							(io_cq2_size),
	.io_cq3_size							(io_cq3_size),
	.io_cq4_size							(io_cq4_size),
	.io_cq5_size							(io_cq5_size),
	.io_cq6_size							(io_cq6_size),
	.io_cq7_size							(io_cq7_size),
	.io_cq8_size							(io_cq8_size),
	.io_cq1_bs_addr							(io_cq1_bs_addr),
	.io_cq2_bs_addr							(io_cq2_bs_addr),
	.io_cq3_bs_addr							(io_cq3_bs_addr),
	.io_cq4_bs_addr							(io_cq4_bs_addr),
	.io_cq5_bs_addr							(io_cq5_bs_addr),
	.io_cq6_bs_addr							(io_cq6_bs_addr),
	.io_cq7_bs_addr							(io_cq7_bs_addr),
	.io_cq8_bs_addr							(io_cq8_bs_addr),

	.hcmd_cq_wr1_en							(hcmd_cq_wr1_en),
	.hcmd_cq_wr1_data0						(hcmd_cq_wr1_data0),
	.hcmd_cq_wr1_data1						(hcmd_cq_wr1_data1),
	.hcmd_cq_wr1_rdy_n						(hcmd_cq_wr1_rdy_n)
);

endmodule
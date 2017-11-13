
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

module pcie_hcmd_sq # (
	parameter	C_PCIE_DATA_WIDTH			= 128,
	parameter	C_PCIE_ADDR_WIDTH			= 36
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,
	
	input	[C_PCIE_ADDR_WIDTH-1:2]			admin_sq_bs_addr,
	input	[7:0]							admin_sq_size,

	input	[7:0]							admin_sq_tail_ptr,
	input	[7:0]							io_sq1_tail_ptr,
	input	[7:0]							io_sq2_tail_ptr,
	input	[7:0]							io_sq3_tail_ptr,
	input	[7:0]							io_sq4_tail_ptr,
	input	[7:0]							io_sq5_tail_ptr,
	input	[7:0]							io_sq6_tail_ptr,
	input	[7:0]							io_sq7_tail_ptr,
	input	[7:0]							io_sq8_tail_ptr,

	output	[7:0]							admin_sq_head_ptr,
	output	[7:0]							io_sq1_head_ptr,
	output	[7:0]							io_sq2_head_ptr,
	output	[7:0]							io_sq3_head_ptr,
	output	[7:0]							io_sq4_head_ptr,
	output	[7:0]							io_sq5_head_ptr,
	output	[7:0]							io_sq6_head_ptr,
	output	[7:0]							io_sq7_head_ptr,
	output	[7:0]							io_sq8_head_ptr,

	input									hcmd_slot_rdy,
	input	[6:0]							hcmd_slot_tag,
	output									hcmd_slot_alloc_en,

	input	[7:0]							cpld_sq_fifo_tag,
	input	[C_PCIE_DATA_WIDTH-1:0]			cpld_sq_fifo_wr_data,
	input									cpld_sq_fifo_wr_en,
	input									cpld_sq_fifo_tag_last,

	output									tx_mrd_req,
	output	[7:0]							tx_mrd_tag,
	output	[11:2]							tx_mrd_len,
	output	[C_PCIE_ADDR_WIDTH-1:2]			tx_mrd_addr,
	input									tx_mrd_req_ack,

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

	input									hcmd_sq_rd_en,
	output	[18:0]							hcmd_sq_rd_data,
	output									hcmd_sq_empty_n
);

wire										w_arb_sq_rdy;
wire	[3:0]								w_sq_qid;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_hcmd_pcie_addr;
wire										w_sq_hcmd_ack;

wire										w_hcmd_sq_wr_en;
wire	[18:0]								w_hcmd_sq_wr_data;
wire										w_hcmd_sq_full_n;

wire										w_pcie_sq_cmd_fifo_wr_en;
wire	[10:0]								w_pcie_sq_cmd_fifo_wr_data;
wire										w_pcie_sq_cmd_fifo_full_n;

wire										w_pcie_sq_cmd_fifo_rd_en;
wire	[10:0]								w_pcie_sq_cmd_fifo_rd_data;
wire										w_pcie_sq_cmd_fifo_empty_n;

wire										w_pcie_sq_rx_tag_alloc;
wire	[7:0]								w_pcie_sq_rx_alloc_tag;
wire	[6:4]								w_pcie_sq_rx_tag_alloc_len;
wire										w_pcie_sq_rx_tag_full_n;

wire										w_pcie_sq_rx_fifo_wr_en;
wire	[3:0]								w_pcie_sq_rx_fifo_wr_addr;
wire	[C_PCIE_DATA_WIDTH-1:0]				w_pcie_sq_rx_fifo_wr_data;
wire	[4:0]								w_pcie_sq_rx_fifo_rear_full_addr;
wire	[4:0]								w_pcie_sq_rx_fifo_rear_addr;
wire										w_pcie_sq_rx_fifo_full_n;

wire										w_pcie_sq_rx_fifo_rd_en;
wire	[C_PCIE_DATA_WIDTH-1:0]				w_pcie_sq_rx_fifo_rd_data;
wire										w_pcie_sq_rx_fifo_free_en;
wire	[6:4]								w_pcie_sq_rx_fifo_free_len;
wire										w_pcie_sq_rx_fifo_empty_n;


pcie_hcmd_sq_fifo 
pcie_hcmd_sq_fifo_inst0(
	.wr_clk									(pcie_user_clk),
	.wr_rst_n								(pcie_user_rst_n),

	.wr_en									(w_hcmd_sq_wr_en),
	.wr_data								(w_hcmd_sq_wr_data),
	.full_n									(w_hcmd_sq_full_n),

	.rd_clk									(cpu_bus_clk),
	.rd_rst_n								(pcie_user_rst_n),

	.rd_en									(hcmd_sq_rd_en),
	.rd_data								(hcmd_sq_rd_data),
	.empty_n								(hcmd_sq_empty_n)
);

pcie_sq_cmd_fifo
pcie_sq_cmd_fifo_inst0
(
	.clk									(pcie_user_clk),
	.rst_n									(pcie_user_rst_n),

	.wr_en									(w_pcie_sq_cmd_fifo_wr_en),
	.wr_data								(w_pcie_sq_cmd_fifo_wr_data),
	.full_n									(w_pcie_sq_cmd_fifo_full_n),

	.rd_en									(w_pcie_sq_cmd_fifo_rd_en),
	.rd_data								(w_pcie_sq_cmd_fifo_rd_data),
	.empty_n								(w_pcie_sq_cmd_fifo_empty_n)
);

pcie_sq_rx_fifo
pcie_sq_rx_fifo_inst0
(
	.clk									(pcie_user_clk),
	.rst_n									(pcie_user_rst_n),

	.wr_en									(w_pcie_sq_rx_fifo_wr_en),
	.wr_addr								(w_pcie_sq_rx_fifo_wr_addr),
	.wr_data								(w_pcie_sq_rx_fifo_wr_data),
	.rear_full_addr							(w_pcie_sq_rx_fifo_rear_full_addr),
	.rear_addr								(w_pcie_sq_rx_fifo_rear_addr),
	.alloc_len								(w_pcie_sq_rx_tag_alloc_len),
	.full_n									(w_pcie_sq_rx_fifo_full_n),

	.rd_en									(w_pcie_sq_rx_fifo_rd_en),
	.rd_data								(w_pcie_sq_rx_fifo_rd_data),
	.free_en								(w_pcie_sq_rx_fifo_free_en),
	.free_len								(w_pcie_sq_rx_fifo_free_len),
	.empty_n								(w_pcie_sq_rx_fifo_empty_n)
);

pcie_sq_rx_tag
pcie_sq_rx_tag_inst0
(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.pcie_tag_alloc							(w_pcie_sq_rx_tag_alloc),
	.pcie_alloc_tag							(w_pcie_sq_rx_alloc_tag),
	.pcie_tag_alloc_len						(w_pcie_sq_rx_tag_alloc_len),
	.pcie_tag_full_n						(w_pcie_sq_rx_tag_full_n),

	.cpld_fifo_tag							(cpld_sq_fifo_tag),
	.cpld_fifo_wr_data						(cpld_sq_fifo_wr_data),
	.cpld_fifo_wr_en						(cpld_sq_fifo_wr_en),
	.cpld_fifo_tag_last						(cpld_sq_fifo_tag_last),

	.fifo_wr_en								(w_pcie_sq_rx_fifo_wr_en),
	.fifo_wr_addr							(w_pcie_sq_rx_fifo_wr_addr),
	.fifo_wr_data							(w_pcie_sq_rx_fifo_wr_data),
	.rear_full_addr							(w_pcie_sq_rx_fifo_rear_full_addr),
	.rear_addr								(w_pcie_sq_rx_fifo_rear_addr)
);

pcie_hcmd_sq_arb
pcie_hcmd_sq_arb_inst0
(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.sq_rst_n								(sq_rst_n),
	.sq_valid								(sq_valid),
	.admin_sq_size							(admin_sq_size),
	.io_sq1_size							(io_sq1_size),
	.io_sq2_size							(io_sq2_size),
	.io_sq3_size							(io_sq3_size),
	.io_sq4_size							(io_sq4_size),
	.io_sq5_size							(io_sq5_size),
	.io_sq6_size							(io_sq6_size),
	.io_sq7_size							(io_sq7_size),
	.io_sq8_size							(io_sq8_size),
	.admin_sq_bs_addr						(admin_sq_bs_addr),
	.io_sq1_bs_addr							(io_sq1_bs_addr),
	.io_sq2_bs_addr							(io_sq2_bs_addr),
	.io_sq3_bs_addr							(io_sq3_bs_addr),
	.io_sq4_bs_addr							(io_sq4_bs_addr),
	.io_sq5_bs_addr							(io_sq5_bs_addr),
	.io_sq6_bs_addr							(io_sq6_bs_addr),
	.io_sq7_bs_addr							(io_sq7_bs_addr),
	.io_sq8_bs_addr							(io_sq8_bs_addr),

	.admin_sq_tail_ptr						(admin_sq_tail_ptr),
	.io_sq1_tail_ptr						(io_sq1_tail_ptr),
	.io_sq2_tail_ptr						(io_sq2_tail_ptr),
	.io_sq3_tail_ptr						(io_sq3_tail_ptr),
	.io_sq4_tail_ptr						(io_sq4_tail_ptr),
	.io_sq5_tail_ptr						(io_sq5_tail_ptr),
	.io_sq6_tail_ptr						(io_sq6_tail_ptr),
	.io_sq7_tail_ptr						(io_sq7_tail_ptr),
	.io_sq8_tail_ptr						(io_sq8_tail_ptr),

	.arb_sq_rdy								(w_arb_sq_rdy),
	.sq_qid									(w_sq_qid),
	.hcmd_pcie_addr							(w_hcmd_pcie_addr),
	.sq_hcmd_ack							(w_sq_hcmd_ack)
);

pcie_hcmd_sq_req # (
	.C_PCIE_DATA_WIDTH						(C_PCIE_DATA_WIDTH)
)
pcie_hcmd_sq_req_inst0(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.arb_sq_rdy								(w_arb_sq_rdy),
	.sq_qid									(w_sq_qid),
	.hcmd_pcie_addr							(w_hcmd_pcie_addr),
	.sq_hcmd_ack							(w_sq_hcmd_ack),

	.hcmd_slot_rdy							(hcmd_slot_rdy),
	.hcmd_slot_tag							(hcmd_slot_tag),
	.hcmd_slot_alloc_en						(hcmd_slot_alloc_en),

	.pcie_sq_cmd_fifo_wr_en					(w_pcie_sq_cmd_fifo_wr_en),
	.pcie_sq_cmd_fifo_wr_data				(w_pcie_sq_cmd_fifo_wr_data),
	.pcie_sq_cmd_fifo_full_n				(w_pcie_sq_cmd_fifo_full_n),

	.pcie_sq_rx_tag_alloc					(w_pcie_sq_rx_tag_alloc),
	.pcie_sq_rx_alloc_tag					(w_pcie_sq_rx_alloc_tag),
	.pcie_sq_rx_tag_alloc_len				(w_pcie_sq_rx_tag_alloc_len),
	.pcie_sq_rx_tag_full_n					(w_pcie_sq_rx_tag_full_n),
	.pcie_sq_rx_fifo_full_n					(w_pcie_sq_rx_fifo_full_n),

	.tx_mrd_req								(tx_mrd_req),
	.tx_mrd_tag								(tx_mrd_tag),
	.tx_mrd_len								(tx_mrd_len),
	.tx_mrd_addr							(tx_mrd_addr),
	.tx_mrd_req_ack							(tx_mrd_req_ack)
);


pcie_hcmd_sq_recv
pcie_hcmd_sq_recv_inst0
(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),
	
	.pcie_sq_cmd_fifo_rd_en					(w_pcie_sq_cmd_fifo_rd_en),
	.pcie_sq_cmd_fifo_rd_data				(w_pcie_sq_cmd_fifo_rd_data),
	.pcie_sq_cmd_fifo_empty_n				(w_pcie_sq_cmd_fifo_empty_n),

	.pcie_sq_rx_fifo_rd_en					(w_pcie_sq_rx_fifo_rd_en),
	.pcie_sq_rx_fifo_rd_data				(w_pcie_sq_rx_fifo_rd_data),
	.pcie_sq_rx_fifo_free_en				(w_pcie_sq_rx_fifo_free_en),
	.pcie_sq_rx_fifo_free_len				(w_pcie_sq_rx_fifo_free_len),
	.pcie_sq_rx_fifo_empty_n				(w_pcie_sq_rx_fifo_empty_n),

	.hcmd_table_wr_en						(hcmd_table_wr_en),
	.hcmd_table_wr_addr						(hcmd_table_wr_addr),
	.hcmd_table_wr_data						(hcmd_table_wr_data),

	.hcmd_cid_wr_en							(hcmd_cid_wr_en),
	.hcmd_cid_wr_addr						(hcmd_cid_wr_addr),
	.hcmd_cid_wr_data						(hcmd_cid_wr_data),

	.hcmd_prp_wr_en							(hcmd_prp_wr_en),
	.hcmd_prp_wr_addr						(hcmd_prp_wr_addr),
	.hcmd_prp_wr_data						(hcmd_prp_wr_data),

	.hcmd_nlb_wr0_en						(hcmd_nlb_wr0_en),
	.hcmd_nlb_wr0_addr						(hcmd_nlb_wr0_addr),
	.hcmd_nlb_wr0_data						(hcmd_nlb_wr0_data),
	.hcmd_nlb_wr0_rdy_n						(hcmd_nlb_wr0_rdy_n),

	.hcmd_sq_wr_en							(w_hcmd_sq_wr_en),
	.hcmd_sq_wr_data						(w_hcmd_sq_wr_data),
	.hcmd_sq_full_n							(w_hcmd_sq_full_n),

	.sq_rst_n								(sq_rst_n),
	.admin_sq_size							(admin_sq_size),
	.io_sq1_size							(io_sq1_size),
	.io_sq2_size							(io_sq2_size),
	.io_sq3_size							(io_sq3_size),
	.io_sq4_size							(io_sq4_size),
	.io_sq5_size							(io_sq5_size),
	.io_sq6_size							(io_sq6_size),
	.io_sq7_size							(io_sq7_size),
	.io_sq8_size							(io_sq8_size),

	.admin_sq_head_ptr						(admin_sq_head_ptr),
	.io_sq1_head_ptr						(io_sq1_head_ptr),
	.io_sq2_head_ptr						(io_sq2_head_ptr),
	.io_sq3_head_ptr						(io_sq3_head_ptr),
	.io_sq4_head_ptr						(io_sq4_head_ptr),
	.io_sq5_head_ptr						(io_sq5_head_ptr),
	.io_sq6_head_ptr						(io_sq6_head_ptr),
	.io_sq7_head_ptr						(io_sq7_head_ptr),
	.io_sq8_head_ptr						(io_sq8_head_ptr)
);

endmodule

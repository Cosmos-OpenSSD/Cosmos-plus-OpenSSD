
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

module pcie_hcmd_cq # (
	parameter	C_PCIE_DATA_WIDTH			= 128,
	parameter	C_PCIE_ADDR_WIDTH			= 36
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,

	output	[6:0]							hcmd_cid_rd_addr,
	input	[19:0]							hcmd_cid_rd_data,

	input	[C_PCIE_ADDR_WIDTH-1:2]			admin_cq_bs_addr,
	input	[7:0]							admin_cq_size,

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
	input									tx_cq_mwr_data_last,

	input									hcmd_cq_wr0_en,
	input	[34:0]							hcmd_cq_wr0_data0,
	input	[34:0]							hcmd_cq_wr0_data1,
	output									hcmd_cq_wr0_rdy_n,

	input									cpu_bus_clk,
	input									cpu_bus_rst_n,

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

	input									hcmd_cq_wr1_en,
	input	[34:0]							hcmd_cq_wr1_data0,
	input	[34:0]							hcmd_cq_wr1_data1,
	output									hcmd_cq_wr1_rdy_n
);

wire										w_hcmd_cq_rd_en;
wire	[34:0]								w_hcmd_cq_rd_data;
wire										w_hcmd_cq_empty_n;

pcie_hcmd_cq_fifo 
pcie_hcmd_cq_fifo_inst0(
	.clk									(pcie_user_clk),
	.rst_n									(pcie_user_rst_n),

	.wr0_en									(hcmd_cq_wr0_en),
	.wr0_data0								(hcmd_cq_wr0_data0),
	.wr0_data1								(hcmd_cq_wr0_data1),
	.wr0_rdy_n								(hcmd_cq_wr0_rdy_n),

	.full_n									(),

	.rd_en									(w_hcmd_cq_rd_en),
	.rd_data								(w_hcmd_cq_rd_data),
	.empty_n								(w_hcmd_cq_empty_n),

	.wr1_clk								(cpu_bus_clk),
	.wr1_rst_n								(pcie_user_rst_n),

	.wr1_en									(hcmd_cq_wr1_en),
	.wr1_data0								(hcmd_cq_wr1_data0),
	.wr1_data1								(hcmd_cq_wr1_data1),
	.wr1_rdy_n								(hcmd_cq_wr1_rdy_n)
);

pcie_hcmd_cq_req # (
	.C_PCIE_DATA_WIDTH						(C_PCIE_DATA_WIDTH)
)
pcie_hcmd_cq_req_inst0(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.hcmd_cq_rd_en							(w_hcmd_cq_rd_en),
	.hcmd_cq_rd_data						(w_hcmd_cq_rd_data),
	.hcmd_cq_empty_n						(w_hcmd_cq_empty_n),

	.hcmd_cid_rd_addr						(hcmd_cid_rd_addr),
	.hcmd_cid_rd_data						(hcmd_cid_rd_data),

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
	.admin_cq_size							(admin_cq_size),
	.io_cq1_size							(io_cq1_size),
	.io_cq2_size							(io_cq2_size),
	.io_cq3_size							(io_cq3_size),
	.io_cq4_size							(io_cq4_size),
	.io_cq5_size							(io_cq5_size),
	.io_cq6_size							(io_cq6_size),
	.io_cq7_size							(io_cq7_size),
	.io_cq8_size							(io_cq8_size),
	.admin_cq_bs_addr						(admin_cq_bs_addr),
	.io_cq1_bs_addr							(io_cq1_bs_addr),
	.io_cq2_bs_addr							(io_cq2_bs_addr),
	.io_cq3_bs_addr							(io_cq3_bs_addr),
	.io_cq4_bs_addr							(io_cq4_bs_addr),
	.io_cq5_bs_addr							(io_cq5_bs_addr),
	.io_cq6_bs_addr							(io_cq6_bs_addr),
	.io_cq7_bs_addr							(io_cq7_bs_addr),
	.io_cq8_bs_addr							(io_cq8_bs_addr),

	.admin_cq_tail_ptr						(admin_cq_tail_ptr),
	.io_cq1_tail_ptr						(io_cq1_tail_ptr),
	.io_cq2_tail_ptr						(io_cq2_tail_ptr),
	.io_cq3_tail_ptr						(io_cq3_tail_ptr),
	.io_cq4_tail_ptr						(io_cq4_tail_ptr),
	.io_cq5_tail_ptr						(io_cq5_tail_ptr),
	.io_cq6_tail_ptr						(io_cq6_tail_ptr),
	.io_cq7_tail_ptr						(io_cq7_tail_ptr),
	.io_cq8_tail_ptr						(io_cq8_tail_ptr),

	.admin_sq_head_ptr						(admin_sq_head_ptr),
	.io_sq1_head_ptr						(io_sq1_head_ptr),
	.io_sq2_head_ptr						(io_sq2_head_ptr),
	.io_sq3_head_ptr						(io_sq3_head_ptr),
	.io_sq4_head_ptr						(io_sq4_head_ptr),
	.io_sq5_head_ptr						(io_sq5_head_ptr),
	.io_sq6_head_ptr						(io_sq6_head_ptr),
	.io_sq7_head_ptr						(io_sq7_head_ptr),
	.io_sq8_head_ptr						(io_sq8_head_ptr),

	.hcmd_slot_free_en						(hcmd_slot_free_en),
	.hcmd_slot_invalid_tag					(hcmd_slot_invalid_tag),

	.tx_cq_mwr_req							(tx_cq_mwr_req),
	.tx_cq_mwr_tag							(tx_cq_mwr_tag),
	.tx_cq_mwr_len							(tx_cq_mwr_len),
	.tx_cq_mwr_addr							(tx_cq_mwr_addr),
	.tx_cq_mwr_req_ack						(tx_cq_mwr_req_ack),
	.tx_cq_mwr_rd_en						(tx_cq_mwr_rd_en),
	.tx_cq_mwr_rd_data						(tx_cq_mwr_rd_data),
	.tx_cq_mwr_data_last					(tx_cq_mwr_data_last)
);

endmodule

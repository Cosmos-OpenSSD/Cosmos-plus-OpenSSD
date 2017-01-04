
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


module pcie_cntl_slave # (
	parameter	C_PCIE_DATA_WIDTH			= 128,
	parameter	C_PCIE_ADDR_WIDTH			= 36
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,

	output									rx_np_ok,
	output									rx_np_req,

	input									mreq_fifo_wr_en,
	input	[C_PCIE_DATA_WIDTH-1:0]			mreq_fifo_wr_data,

	output									tx_cpld_req,
	output	[7:0]							tx_cpld_tag,
	output	[15:0]							tx_cpld_req_id,
	output	[11:2]							tx_cpld_len,
	output	[11:0]							tx_cpld_bc,
	output	[6:0]							tx_cpld_laddr,
	output	[63:0]							tx_cpld_data,
	input									tx_cpld_req_ack,

	output									nvme_cc_en,
	output	[1:0]							nvme_cc_shn,

	input	[1:0]							nvme_csts_shst,
	input									nvme_csts_rdy,

	output									nvme_intms_ivms,
	output									nvme_intmc_ivmc,

	input									cq_irq_status,

	input	[8:0]							sq_rst_n,
	input	[8:0]							cq_rst_n,
	output	[C_PCIE_ADDR_WIDTH-1:2]			admin_sq_bs_addr,
	output	[C_PCIE_ADDR_WIDTH-1:2]			admin_cq_bs_addr,
	output	[7:0]							admin_sq_size,
	output	[7:0]							admin_cq_size,

	output	[7:0]							admin_sq_tail_ptr,
	output	[7:0]							io_sq1_tail_ptr,
	output	[7:0]							io_sq2_tail_ptr,
	output	[7:0]							io_sq3_tail_ptr,
	output	[7:0]							io_sq4_tail_ptr,
	output	[7:0]							io_sq5_tail_ptr,
	output	[7:0]							io_sq6_tail_ptr,
	output	[7:0]							io_sq7_tail_ptr,
	output	[7:0]							io_sq8_tail_ptr,

	output	[7:0]							admin_cq_head_ptr,
	output	[7:0]							io_cq1_head_ptr,
	output	[7:0]							io_cq2_head_ptr,
	output	[7:0]							io_cq3_head_ptr,
	output	[7:0]							io_cq4_head_ptr,
	output	[7:0]							io_cq5_head_ptr,
	output	[7:0]							io_cq6_head_ptr,
	output	[7:0]							io_cq7_head_ptr,
	output	[7:0]							io_cq8_head_ptr,
	output	[8:0]							cq_head_update

);

wire										w_mreq_fifo_rd_en;
wire	[C_PCIE_DATA_WIDTH-1:0]				w_mreq_fifo_rd_data;
wire										w_mreq_fifo_empty_n;


pcie_cntl_reg # (
	.C_PCIE_DATA_WIDTH						(C_PCIE_DATA_WIDTH)
)
pcie_cntl_reg_inst0(

	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.rx_np_ok								(),
	.rx_np_req								(rx_np_req),
	
	.mreq_fifo_rd_en						(w_mreq_fifo_rd_en),
	.mreq_fifo_rd_data						(w_mreq_fifo_rd_data),
	.mreq_fifo_empty_n						(w_mreq_fifo_empty_n),

	.tx_cpld_req							(tx_cpld_req),
	.tx_cpld_tag							(tx_cpld_tag),
	.tx_cpld_req_id							(tx_cpld_req_id),
	.tx_cpld_len							(tx_cpld_len),
	.tx_cpld_bc								(tx_cpld_bc),
	.tx_cpld_laddr							(tx_cpld_laddr),
	.tx_cpld_data							(tx_cpld_data),
	.tx_cpld_req_ack						(tx_cpld_req_ack),

	.nvme_cc_en								(nvme_cc_en),
	.nvme_cc_shn							(nvme_cc_shn),

	.nvme_csts_shst							(nvme_csts_shst),
	.nvme_csts_rdy							(nvme_csts_rdy),

	.nvme_intms_ivms						(nvme_intms_ivms),
	.nvme_intmc_ivmc						(nvme_intmc_ivmc),
	.cq_irq_status							(cq_irq_status),

	.sq_rst_n								(sq_rst_n),
	.cq_rst_n								(cq_rst_n),
	.admin_sq_bs_addr						(admin_sq_bs_addr),
	.admin_cq_bs_addr						(admin_cq_bs_addr),
	.admin_sq_size							(admin_sq_size),
	.admin_cq_size							(admin_cq_size),

	.admin_sq_tail_ptr						(admin_sq_tail_ptr),
	.io_sq1_tail_ptr						(io_sq1_tail_ptr),
	.io_sq2_tail_ptr						(io_sq2_tail_ptr),
	.io_sq3_tail_ptr						(io_sq3_tail_ptr),
	.io_sq4_tail_ptr						(io_sq4_tail_ptr),
	.io_sq5_tail_ptr						(io_sq5_tail_ptr),
	.io_sq6_tail_ptr						(io_sq6_tail_ptr),
	.io_sq7_tail_ptr						(io_sq7_tail_ptr),
	.io_sq8_tail_ptr						(io_sq8_tail_ptr),

	.admin_cq_head_ptr						(admin_cq_head_ptr),
	.io_cq1_head_ptr						(io_cq1_head_ptr),
	.io_cq2_head_ptr						(io_cq2_head_ptr),
	.io_cq3_head_ptr						(io_cq3_head_ptr),
	.io_cq4_head_ptr						(io_cq4_head_ptr),
	.io_cq5_head_ptr						(io_cq5_head_ptr),
	.io_cq6_head_ptr						(io_cq6_head_ptr),
	.io_cq7_head_ptr						(io_cq7_head_ptr),
	.io_cq8_head_ptr						(io_cq8_head_ptr),
	.cq_head_update							(cq_head_update)
);

pcie_cntl_rx_fifo
pcie_cntl_rx_fifo_inst0(
	.clk									(pcie_user_clk),
	.rst_n									(pcie_user_rst_n),

////////////////////////////////////////////////////////////////
//bram fifo write signals
	.wr_en									(mreq_fifo_wr_en),
	.wr_data								(mreq_fifo_wr_data),
	.full_n									(),
	.almost_full_n							(rx_np_ok),
////////////////////////////////////////////////////////////////
//bram fifo read signals
	.rd_en									(w_mreq_fifo_rd_en),
	.rd_data								(w_mreq_fifo_rd_data),
	.empty_n								(w_mreq_fifo_empty_n)
);

endmodule
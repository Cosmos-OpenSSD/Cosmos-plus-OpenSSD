
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


module dma_if # (
	parameter	C_PCIE_DATA_WIDTH			= 128,
	parameter	C_PCIE_ADDR_WIDTH			= 36,
	parameter	C_M_AXI_DATA_WIDTH			= 64
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,

	input	[2:0]							pcie_max_payload_size,
	input	[2:0]							pcie_max_read_req_size,
	input									pcie_rcb,

	output	[7:0]							hcmd_prp_rd_addr,
	input	[44:0]							hcmd_prp_rd_data,

	output									hcmd_nlb_wr1_en,
	output	[6:0]							hcmd_nlb_wr1_addr,
	output	[18:0]							hcmd_nlb_wr1_data,
	input									hcmd_nlb_wr1_rdy_n,

	output	[6:0]							hcmd_nlb_rd_addr,
	input	[18:0]							hcmd_nlb_rd_data,

	output									dev_rx_cmd_wr_en,
	output	[29:0]							dev_rx_cmd_wr_data,
	input									dev_rx_cmd_full_n,

	output									dev_tx_cmd_wr_en,
	output	[29:0]							dev_tx_cmd_wr_data,
	input									dev_tx_cmd_full_n,

	output									tx_prp_mrd_req,
	output	[7:0]							tx_prp_mrd_tag,
	output	[11:2]							tx_prp_mrd_len,
	output	[C_PCIE_ADDR_WIDTH-1:2]			tx_prp_mrd_addr,
	input									tx_prp_mrd_req_ack,

	input	[7:0]							cpld_prp_fifo_tag,
	input	[C_PCIE_DATA_WIDTH-1:0]			cpld_prp_fifo_wr_data,
	input									cpld_prp_fifo_wr_en,
	input									cpld_prp_fifo_tag_last,

	output									tx_dma_mrd_req,
	output	[7:0]							tx_dma_mrd_tag,
	output	[11:2]							tx_dma_mrd_len,
	output	[C_PCIE_ADDR_WIDTH-1:2]			tx_dma_mrd_addr,
	input									tx_dma_mrd_req_ack,

	input	[7:0]							cpld_dma_fifo_tag,
	input	[C_PCIE_DATA_WIDTH-1:0]			cpld_dma_fifo_wr_data,
	input									cpld_dma_fifo_wr_en,
	input									cpld_dma_fifo_tag_last,

	output									tx_dma_mwr_req,
	output	[7:0]							tx_dma_mwr_tag,
	output	[11:2]							tx_dma_mwr_len,
	output	[C_PCIE_ADDR_WIDTH-1:2]			tx_dma_mwr_addr,
	input									tx_dma_mwr_req_ack,
	input									tx_dma_mwr_data_last,

	input									pcie_tx_dma_fifo_rd_en,
	output	[C_PCIE_DATA_WIDTH-1:0]			pcie_tx_dma_fifo_rd_data,

	output									hcmd_cq_wr0_en,
	output	[34:0]							hcmd_cq_wr0_data0,
	output	[34:0]							hcmd_cq_wr0_data1,
	input									hcmd_cq_wr0_rdy_n,

	input									cpu_bus_clk,
	input									cpu_bus_rst_n,

	input									dma_cmd_wr_en,
	input	[49:0]							dma_cmd_wr_data0,
	input	[49:0]							dma_cmd_wr_data1,
	output									dma_cmd_wr_rdy_n,

	output	[7:0]							dma_rx_direct_done_cnt,
	output	[7:0]							dma_tx_direct_done_cnt,
	output	[7:0]							dma_rx_done_cnt,
	output	[7:0]							dma_tx_done_cnt,

	input									dma_bus_clk,
	input									dma_bus_rst_n,

	input									pcie_rx_fifo_rd_en,
	output	[C_M_AXI_DATA_WIDTH-1:0]		pcie_rx_fifo_rd_data,
	input									pcie_rx_fifo_free_en,
	input	[9:4]							pcie_rx_fifo_free_len,
	output									pcie_rx_fifo_empty_n,

	input									pcie_tx_fifo_alloc_en,
	input	[9:4]							pcie_tx_fifo_alloc_len,
	input									pcie_tx_fifo_wr_en,
	input	[C_M_AXI_DATA_WIDTH-1:0]		pcie_tx_fifo_wr_data,
	output									pcie_tx_fifo_full_n,

	input									dma_rx_done_wr_en,
	input	[20:0]							dma_rx_done_wr_data,
	output									dma_rx_done_wr_rdy_n
);

wire										w_pcie_rx_cmd_wr_en;
wire	[33:0]								w_pcie_rx_cmd_wr_data;
wire										w_pcie_rx_cmd_full_n;

wire										w_pcie_tx_cmd_wr_en;
wire	[33:0]								w_pcie_tx_cmd_wr_data;
wire										w_pcie_tx_cmd_full_n;

wire										w_dma_tx_done_wr_en;
wire	[20:0]								w_dma_tx_done_wr_data;
wire										w_dma_tx_done_wr_rdy_n;


dma_cmd
dma_cmd_inst0
(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.pcie_rcb								(pcie_rcb),

	.hcmd_prp_rd_addr						(hcmd_prp_rd_addr),
	.hcmd_prp_rd_data						(hcmd_prp_rd_data),

	.hcmd_nlb_wr1_en						(hcmd_nlb_wr1_en),
	.hcmd_nlb_wr1_addr						(hcmd_nlb_wr1_addr),
	.hcmd_nlb_wr1_data						(hcmd_nlb_wr1_data),
	.hcmd_nlb_wr1_rdy_n						(hcmd_nlb_wr1_rdy_n),

	.hcmd_nlb_rd_addr						(hcmd_nlb_rd_addr),
	.hcmd_nlb_rd_data						(hcmd_nlb_rd_data),

	.dev_rx_cmd_wr_en						(dev_rx_cmd_wr_en),
	.dev_rx_cmd_wr_data						(dev_rx_cmd_wr_data),
	.dev_rx_cmd_full_n						(dev_rx_cmd_full_n),

	.dev_tx_cmd_wr_en						(dev_tx_cmd_wr_en),
	.dev_tx_cmd_wr_data						(dev_tx_cmd_wr_data),
	.dev_tx_cmd_full_n						(dev_tx_cmd_full_n),

	.tx_prp_mrd_req							(tx_prp_mrd_req),
	.tx_prp_mrd_tag							(tx_prp_mrd_tag),
	.tx_prp_mrd_len							(tx_prp_mrd_len),
	.tx_prp_mrd_addr						(tx_prp_mrd_addr),
	.tx_prp_mrd_req_ack						(tx_prp_mrd_req_ack),

	.cpld_prp_fifo_tag						(cpld_prp_fifo_tag),
	.cpld_prp_fifo_wr_data					(cpld_prp_fifo_wr_data),
	.cpld_prp_fifo_wr_en					(cpld_prp_fifo_wr_en),
	.cpld_prp_fifo_tag_last					(cpld_prp_fifo_tag_last),

	.pcie_rx_cmd_wr_en						(w_pcie_rx_cmd_wr_en),
	.pcie_rx_cmd_wr_data					(w_pcie_rx_cmd_wr_data),
	.pcie_rx_cmd_full_n						(w_pcie_rx_cmd_full_n),

	.pcie_tx_cmd_wr_en						(w_pcie_tx_cmd_wr_en),
	.pcie_tx_cmd_wr_data					(w_pcie_tx_cmd_wr_data),
	.pcie_tx_cmd_full_n						(w_pcie_tx_cmd_full_n),

	.dma_tx_done_wr_en						(w_dma_tx_done_wr_en),
	.dma_tx_done_wr_data					(w_dma_tx_done_wr_data),
	.dma_tx_done_wr_rdy_n					(w_dma_tx_done_wr_rdy_n),

	.hcmd_cq_wr0_en							(hcmd_cq_wr0_en),
	.hcmd_cq_wr0_data0						(hcmd_cq_wr0_data0),
	.hcmd_cq_wr0_data1						(hcmd_cq_wr0_data1),
	.hcmd_cq_wr0_rdy_n						(hcmd_cq_wr0_rdy_n),

	.cpu_bus_clk							(cpu_bus_clk),
	.cpu_bus_rst_n							(cpu_bus_rst_n),

	.dma_cmd_wr_en							(dma_cmd_wr_en),
	.dma_cmd_wr_data0						(dma_cmd_wr_data0),
	.dma_cmd_wr_data1						(dma_cmd_wr_data1),
	.dma_cmd_wr_rdy_n						(dma_cmd_wr_rdy_n),

	.dma_rx_direct_done_cnt					(dma_rx_direct_done_cnt),
	.dma_tx_direct_done_cnt					(dma_tx_direct_done_cnt),
	.dma_rx_done_cnt						(dma_rx_done_cnt),
	.dma_tx_done_cnt						(dma_tx_done_cnt),

	.dma_bus_clk							(dma_bus_clk),
	.dma_bus_rst_n							(dma_bus_rst_n),

	.dma_rx_done_wr_en						(dma_rx_done_wr_en),
	.dma_rx_done_wr_data					(dma_rx_done_wr_data),
	.dma_rx_done_wr_rdy_n					(dma_rx_done_wr_rdy_n)
);

pcie_rx_dma
pcie_rx_dma_inst0
(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.pcie_max_read_req_size					(pcie_max_read_req_size),

	.pcie_rx_cmd_wr_en						(w_pcie_rx_cmd_wr_en),
	.pcie_rx_cmd_wr_data					(w_pcie_rx_cmd_wr_data),
	.pcie_rx_cmd_full_n						(w_pcie_rx_cmd_full_n),

	.tx_dma_mrd_req							(tx_dma_mrd_req),
	.tx_dma_mrd_tag							(tx_dma_mrd_tag),
	.tx_dma_mrd_len							(tx_dma_mrd_len),
	.tx_dma_mrd_addr						(tx_dma_mrd_addr),
	.tx_dma_mrd_req_ack						(tx_dma_mrd_req_ack),

	.cpld_dma_fifo_tag						(cpld_dma_fifo_tag),
	.cpld_dma_fifo_wr_data					(cpld_dma_fifo_wr_data),
	.cpld_dma_fifo_wr_en					(cpld_dma_fifo_wr_en),
	.cpld_dma_fifo_tag_last					(cpld_dma_fifo_tag_last),

	.dma_bus_clk							(dma_bus_clk),
	.dma_bus_rst_n							(dma_bus_rst_n),

	.pcie_rx_fifo_rd_en						(pcie_rx_fifo_rd_en),
	.pcie_rx_fifo_rd_data					(pcie_rx_fifo_rd_data),
	.pcie_rx_fifo_free_en					(pcie_rx_fifo_free_en),
	.pcie_rx_fifo_free_len					(pcie_rx_fifo_free_len),
	.pcie_rx_fifo_empty_n					(pcie_rx_fifo_empty_n)
);

pcie_tx_dma
pcie_tx_dma_inst0
(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.pcie_max_payload_size					(pcie_max_payload_size),

	.pcie_tx_cmd_wr_en						(w_pcie_tx_cmd_wr_en),
	.pcie_tx_cmd_wr_data					(w_pcie_tx_cmd_wr_data),
	.pcie_tx_cmd_full_n						(w_pcie_tx_cmd_full_n),

	.tx_dma_mwr_req							(tx_dma_mwr_req),
	.tx_dma_mwr_tag							(tx_dma_mwr_tag),
	.tx_dma_mwr_len							(tx_dma_mwr_len),
	.tx_dma_mwr_addr						(tx_dma_mwr_addr),
	.tx_dma_mwr_req_ack						(tx_dma_mwr_req_ack),
	.tx_dma_mwr_data_last					(tx_dma_mwr_data_last),

	.pcie_tx_dma_fifo_rd_en					(pcie_tx_dma_fifo_rd_en),
	.pcie_tx_dma_fifo_rd_data				(pcie_tx_dma_fifo_rd_data),

	.dma_tx_done_wr_en						(w_dma_tx_done_wr_en),
	.dma_tx_done_wr_data					(w_dma_tx_done_wr_data),
	.dma_tx_done_wr_rdy_n					(w_dma_tx_done_wr_rdy_n),

	.dma_bus_clk							(dma_bus_clk),
	.dma_bus_rst_n							(dma_bus_rst_n),

	.pcie_tx_fifo_alloc_en					(pcie_tx_fifo_alloc_en),
	.pcie_tx_fifo_alloc_len					(pcie_tx_fifo_alloc_len),
	.pcie_tx_fifo_wr_en						(pcie_tx_fifo_wr_en),
	.pcie_tx_fifo_wr_data					(pcie_tx_fifo_wr_data),
	.pcie_tx_fifo_full_n					(pcie_tx_fifo_full_n)
);

endmodule
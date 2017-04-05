
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


module dma_cmd # (
	parameter	C_PCIE_DATA_WIDTH			= 128,
	parameter	C_PCIE_ADDR_WIDTH			= 36,
	parameter	C_M_AXI_DATA_WIDTH			= 64
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,

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

	output									pcie_rx_cmd_wr_en,
	output	[33:0]							pcie_rx_cmd_wr_data,
	input									pcie_rx_cmd_full_n,

	output									pcie_tx_cmd_wr_en,
	output	[33:0]							pcie_tx_cmd_wr_data,
	input									pcie_tx_cmd_full_n,

	input									dma_tx_done_wr_en,
	input	[20:0]							dma_tx_done_wr_data,
	output									dma_tx_done_wr_rdy_n,

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

	input									dma_rx_done_wr_en,
	input	[20:0]							dma_rx_done_wr_data,
	output									dma_rx_done_wr_rdy_n

);

wire										w_dma_cmd_rd_en;
wire	[49:0]								w_dma_cmd_rd_data;
wire										w_dma_cmd_empty_n;

wire										w_pcie_cmd_wr_en;
wire	[33:0]								w_pcie_cmd_wr_data;
wire										w_pcie_cmd_full_n;

wire										w_pcie_cmd_rd_en;
wire	[33:0]								w_pcie_cmd_rd_data;
wire										w_pcie_cmd_empty_n;

wire										w_dma_done_rd_en;
wire	[20:0]								w_dma_done_rd_data;
wire										w_dma_done_empty_n;

wire										w_prp_pcie_alloc;
wire	[7:0]								w_prp_pcie_alloc_tag;
wire	[5:4]								w_prp_pcie_tag_alloc_len;
wire										w_pcie_tag_full_n;

wire										w_prp_fifo_wr_en;
wire	[4:0]								w_prp_fifo_wr_addr;
wire	[C_PCIE_DATA_WIDTH-1:0]				w_prp_fifo_wr_data;
wire	[5:0]								w_prp_rear_full_addr;
wire	[5:0]								w_prp_rear_addr;
wire										w_prp_fifo_full_n;


wire										w_prp_fifo_rd_en;
wire	[C_PCIE_DATA_WIDTH-1:0]				w_prp_fifo_rd_data;
wire										w_prp_fifo_free_en;
wire	[5:4]								w_prp_fifo_free_len;
wire										w_prp_fifo_empty_n;


dma_cmd_fifo
dma_cmd_fifo_inst0
(
	.wr_clk									(cpu_bus_clk),
	.wr_rst_n								(pcie_user_rst_n),

	.dma_cmd_wr_en							(dma_cmd_wr_en),
	.dma_cmd_wr_data0						(dma_cmd_wr_data0),
	.dma_cmd_wr_data1						(dma_cmd_wr_data1),
	.dma_cmd_wr_rdy_n						(dma_cmd_wr_rdy_n),

	.rd_clk									(pcie_user_clk),
	.rd_rst_n								(pcie_user_rst_n),

	.rd_en									(w_dma_cmd_rd_en),
	.rd_data								(w_dma_cmd_rd_data),
	.empty_n								(w_dma_cmd_empty_n)
);

pcie_dma_cmd_fifo
pcie_dma_cmd_fifo_inst0
(
	.clk									(pcie_user_clk),
	.rst_n									(pcie_user_rst_n),

	.wr_en									(w_pcie_cmd_wr_en),
	.wr_data								(w_pcie_cmd_wr_data),
	.full_n									(w_pcie_cmd_full_n),

	.rd_en									(w_pcie_cmd_rd_en),
	.rd_data								(w_pcie_cmd_rd_data),
	.empty_n								(w_pcie_cmd_empty_n)
);

dma_done_fifo
dma_done_fifo_inst0
(
	.clk									(pcie_user_clk),
	.rst_n									(pcie_user_rst_n),

	.wr0_en									(dma_tx_done_wr_en),
	.wr0_data								(dma_tx_done_wr_data),
	.wr0_rdy_n								(dma_tx_done_wr_rdy_n),

	.full_n									(),

	.rd_en									(w_dma_done_rd_en),
	.rd_data								(w_dma_done_rd_data),
	.empty_n								(w_dma_done_empty_n),

	.wr1_clk								(dma_bus_clk),
	.wr1_rst_n								(pcie_user_rst_n),

	.wr1_en									(dma_rx_done_wr_en),
	.wr1_data								(dma_rx_done_wr_data),
	.wr1_rdy_n								(dma_rx_done_wr_rdy_n)
);


pcie_prp_rx_fifo
pcie_prp_rx_fifo_inst0
(
	.clk									(pcie_user_clk),
	.rst_n									(pcie_user_rst_n),

	.wr_en									(w_prp_fifo_wr_en),
	.wr_addr								(w_prp_fifo_wr_addr),
	.wr_data								(w_prp_fifo_wr_data),
	.rear_full_addr							(w_prp_rear_full_addr),
	.rear_addr								(w_prp_rear_addr),
	.alloc_len								(w_prp_pcie_tag_alloc_len),
	.full_n									(w_prp_fifo_full_n),

	.rd_en									(w_prp_fifo_rd_en),
	.rd_data								(w_prp_fifo_rd_data),
	.free_en								(w_prp_fifo_free_en),
	.free_len								(w_prp_fifo_free_len),
	.empty_n								(w_prp_fifo_empty_n)
);


pcie_prp_rx_tag
pcie_prp_rx_tag_inst0
(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.pcie_tag_alloc							(w_prp_pcie_alloc),
	.pcie_alloc_tag							(w_prp_pcie_alloc_tag),
	.pcie_tag_alloc_len						(w_prp_pcie_tag_alloc_len),
	.pcie_tag_full_n						(w_pcie_tag_full_n),

	.cpld_fifo_tag							(cpld_prp_fifo_tag),
	.cpld_fifo_wr_data						(cpld_prp_fifo_wr_data),
	.cpld_fifo_wr_en						(cpld_prp_fifo_wr_en),
	.cpld_fifo_tag_last						(cpld_prp_fifo_tag_last),

	.fifo_wr_en								(w_prp_fifo_wr_en),
	.fifo_wr_addr							(w_prp_fifo_wr_addr),
	.fifo_wr_data							(w_prp_fifo_wr_data),
	.rear_full_addr							(w_prp_rear_full_addr),
	.rear_addr								(w_prp_rear_addr)
);

dma_cmd_gen
dma_cmd_gen_inst0
(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.pcie_rcb								(pcie_rcb),

	.dma_cmd_rd_en							(w_dma_cmd_rd_en),
	.dma_cmd_rd_data						(w_dma_cmd_rd_data),
	.dma_cmd_empty_n						(w_dma_cmd_empty_n),

	.hcmd_prp_rd_addr						(hcmd_prp_rd_addr),
	.hcmd_prp_rd_data						(hcmd_prp_rd_data),

	.dev_rx_cmd_wr_en						(dev_rx_cmd_wr_en),
	.dev_rx_cmd_wr_data						(dev_rx_cmd_wr_data),
	.dev_rx_cmd_full_n						(dev_rx_cmd_full_n),

	.dev_tx_cmd_wr_en						(dev_tx_cmd_wr_en),
	.dev_tx_cmd_wr_data						(dev_tx_cmd_wr_data),
	.dev_tx_cmd_full_n						(dev_tx_cmd_full_n),

	.pcie_cmd_wr_en							(w_pcie_cmd_wr_en),
	.pcie_cmd_wr_data						(w_pcie_cmd_wr_data),
	.pcie_cmd_full_n						(w_pcie_cmd_full_n),

	.prp_pcie_alloc							(w_prp_pcie_alloc),
	.prp_pcie_alloc_tag						(w_prp_pcie_alloc_tag),
	.prp_pcie_tag_alloc_len					(w_prp_pcie_tag_alloc_len),
	.pcie_tag_full_n						(w_pcie_tag_full_n),
	.prp_fifo_full_n						(w_prp_fifo_full_n),

	.tx_prp_mrd_req							(tx_prp_mrd_req),
	.tx_prp_mrd_tag							(tx_prp_mrd_tag),
	.tx_prp_mrd_len							(tx_prp_mrd_len),
	.tx_prp_mrd_addr						(tx_prp_mrd_addr),
	.tx_prp_mrd_req_ack						(tx_prp_mrd_req_ack)
);

pcie_dma_cmd_gen
pcie_dma_cmd_gen_inst0
(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.pcie_cmd_rd_en							(w_pcie_cmd_rd_en),
	.pcie_cmd_rd_data						(w_pcie_cmd_rd_data),
	.pcie_cmd_empty_n						(w_pcie_cmd_empty_n),

	.prp_fifo_rd_en							(w_prp_fifo_rd_en),
	.prp_fifo_rd_data						(w_prp_fifo_rd_data),
	.prp_fifo_free_en						(w_prp_fifo_free_en),
	.prp_fifo_free_len						(w_prp_fifo_free_len),
	.prp_fifo_empty_n						(w_prp_fifo_empty_n),

	.pcie_rx_cmd_wr_en						(pcie_rx_cmd_wr_en),
	.pcie_rx_cmd_wr_data					(pcie_rx_cmd_wr_data),
	.pcie_rx_cmd_full_n						(pcie_rx_cmd_full_n),

	.pcie_tx_cmd_wr_en						(pcie_tx_cmd_wr_en),
	.pcie_tx_cmd_wr_data					(pcie_tx_cmd_wr_data),
	.pcie_tx_cmd_full_n						(pcie_tx_cmd_full_n)
);

dma_done
dma_done_inst0
(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.dma_done_rd_en							(w_dma_done_rd_en),
	.dma_done_rd_data						(w_dma_done_rd_data),
	.dma_done_empty_n						(w_dma_done_empty_n),

	.hcmd_nlb_rd_addr						(hcmd_nlb_rd_addr),
	.hcmd_nlb_rd_data						(hcmd_nlb_rd_data),

	.hcmd_nlb_wr1_en						(hcmd_nlb_wr1_en),
	.hcmd_nlb_wr1_addr						(hcmd_nlb_wr1_addr),
	.hcmd_nlb_wr1_data						(hcmd_nlb_wr1_data),
	.hcmd_nlb_wr1_rdy_n						(hcmd_nlb_wr1_rdy_n),

	.hcmd_cq_wr0_en							(hcmd_cq_wr0_en),
	.hcmd_cq_wr0_data0						(hcmd_cq_wr0_data0),
	.hcmd_cq_wr0_data1						(hcmd_cq_wr0_data1),
	.hcmd_cq_wr0_rdy_n						(hcmd_cq_wr0_rdy_n),

	.cpu_bus_clk							(cpu_bus_clk),
	.cpu_bus_rst_n							(cpu_bus_rst_n),

	.dma_rx_direct_done_cnt					(dma_rx_direct_done_cnt),
	.dma_tx_direct_done_cnt					(dma_tx_direct_done_cnt),
	.dma_rx_done_cnt						(dma_rx_done_cnt),
	.dma_tx_done_cnt						(dma_tx_done_cnt)
);

endmodule

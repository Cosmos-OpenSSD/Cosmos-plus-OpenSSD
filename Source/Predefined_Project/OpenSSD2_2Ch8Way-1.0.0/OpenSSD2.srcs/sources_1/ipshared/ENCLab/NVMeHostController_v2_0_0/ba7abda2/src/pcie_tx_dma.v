
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


module pcie_tx_dma # (
	parameter	C_PCIE_DATA_WIDTH			= 128,
	parameter	C_PCIE_ADDR_WIDTH			= 36,
	parameter	C_M_AXI_DATA_WIDTH			= 64
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,

	input	[2:0]							pcie_max_payload_size,

	input									pcie_tx_cmd_wr_en,
	input	[33:0]							pcie_tx_cmd_wr_data,
	output									pcie_tx_cmd_full_n,

	output									tx_dma_mwr_req,
	output	[7:0]							tx_dma_mwr_tag,
	output	[11:2]							tx_dma_mwr_len,
	output	[C_PCIE_ADDR_WIDTH-1:2]			tx_dma_mwr_addr,
	input									tx_dma_mwr_req_ack,
	input									tx_dma_mwr_data_last,

	input									pcie_tx_dma_fifo_rd_en,
	output	[C_PCIE_DATA_WIDTH-1:0]			pcie_tx_dma_fifo_rd_data,

	output									dma_tx_done_wr_en,
	output	[20:0]							dma_tx_done_wr_data,
	input									dma_tx_done_wr_rdy_n,

	input									dma_bus_clk,
	input									dma_bus_rst_n,

	input									pcie_tx_fifo_alloc_en,
	input	[9:4]							pcie_tx_fifo_alloc_len,
	input									pcie_tx_fifo_wr_en,
	input	[C_M_AXI_DATA_WIDTH-1:0]		pcie_tx_fifo_wr_data,
	output									pcie_tx_fifo_full_n
);

wire										w_pcie_tx_cmd_rd_en;
wire	[33:0]								w_pcie_tx_cmd_rd_data;
wire										w_pcie_tx_cmd_empty_n;

wire										w_pcie_tx_fifo_free_en;
wire	[9:4]								w_pcie_tx_fifo_free_len;
wire										w_pcie_tx_fifo_empty_n;


pcie_tx_cmd_fifo 
pcie_tx_cmd_fifo_inst0
(
	.clk									(pcie_user_clk),
	.rst_n									(pcie_user_rst_n),

	.wr_en									(pcie_tx_cmd_wr_en),
	.wr_data								(pcie_tx_cmd_wr_data),
	.full_n									(pcie_tx_cmd_full_n),

	.rd_en									(w_pcie_tx_cmd_rd_en),
	.rd_data								(w_pcie_tx_cmd_rd_data),
	.empty_n								(w_pcie_tx_cmd_empty_n)
);

pcie_tx_fifo
pcie_tx_fifo_inst0
(
	.wr_clk									(dma_bus_clk),
	.wr_rst_n								(pcie_user_rst_n),

	.alloc_en								(pcie_tx_fifo_alloc_en),
	.alloc_len								(pcie_tx_fifo_alloc_len),
	.wr_en									(pcie_tx_fifo_wr_en),
	.wr_data								(pcie_tx_fifo_wr_data),
	.full_n									(pcie_tx_fifo_full_n),

	.rd_clk									(pcie_user_clk),
	.rd_rst_n								(pcie_user_rst_n),

	.rd_en									(pcie_tx_dma_fifo_rd_en),
	.rd_data								(pcie_tx_dma_fifo_rd_data),
	.free_en								(w_pcie_tx_fifo_free_en),
	.free_len								(w_pcie_tx_fifo_free_len),
	.empty_n								(w_pcie_tx_fifo_empty_n)
);

pcie_tx_req # (
	.C_PCIE_DATA_WIDTH						(C_PCIE_DATA_WIDTH),
	.C_PCIE_ADDR_WIDTH						(C_PCIE_ADDR_WIDTH)
)
pcie_tx_req_inst0(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.pcie_max_payload_size					(pcie_max_payload_size),

	.pcie_tx_cmd_rd_en						(w_pcie_tx_cmd_rd_en),
	.pcie_tx_cmd_rd_data					(w_pcie_tx_cmd_rd_data),
	.pcie_tx_cmd_empty_n					(w_pcie_tx_cmd_empty_n),

	.pcie_tx_fifo_free_en					(w_pcie_tx_fifo_free_en),
	.pcie_tx_fifo_free_len					(w_pcie_tx_fifo_free_len),
	.pcie_tx_fifo_empty_n					(w_pcie_tx_fifo_empty_n),

	.tx_dma_mwr_req							(tx_dma_mwr_req),
	.tx_dma_mwr_tag							(tx_dma_mwr_tag),
	.tx_dma_mwr_len							(tx_dma_mwr_len),
	.tx_dma_mwr_addr						(tx_dma_mwr_addr),
	.tx_dma_mwr_req_ack						(tx_dma_mwr_req_ack),
	.tx_dma_mwr_data_last					(tx_dma_mwr_data_last),

	.dma_tx_done_wr_en						(dma_tx_done_wr_en),
	.dma_tx_done_wr_data					(dma_tx_done_wr_data),
	.dma_tx_done_wr_rdy_n					(dma_tx_done_wr_rdy_n)
);

endmodule
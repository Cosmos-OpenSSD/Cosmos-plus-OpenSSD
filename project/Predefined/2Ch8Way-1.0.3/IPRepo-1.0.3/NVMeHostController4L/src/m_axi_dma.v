
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

module m_axi_dma # (
	parameter	C_M_AXI_ADDR_WIDTH			= 32,
	parameter	C_M_AXI_DATA_WIDTH			= 64,
	parameter	C_M_AXI_ID_WIDTH			= 1,
	parameter	C_M_AXI_AWUSER_WIDTH		= 1,
	parameter	C_M_AXI_WUSER_WIDTH			= 1,
	parameter	C_M_AXI_BUSER_WIDTH			= 1,
	parameter	C_M_AXI_ARUSER_WIDTH		= 1,
	parameter	C_M_AXI_RUSER_WIDTH			= 1
)
(
////////////////////////////////////////////////////////////////
//AXI4 master interface signals
	input									m_axi_aclk,
	input									m_axi_aresetn,

// Write address channel
	output	[C_M_AXI_ID_WIDTH-1:0]			m_axi_awid,
	output	[C_M_AXI_ADDR_WIDTH-1:0]		m_axi_awaddr,
	output	[7:0]							m_axi_awlen,
	output	[2:0]							m_axi_awsize,
	output	[1:0]							m_axi_awburst,
	output	[1:0]							m_axi_awlock,
	output	[3:0]							m_axi_awcache,
	output	[2:0]							m_axi_awprot,
	output	[3:0]							m_axi_awregion,
	output	[3:0]							m_axi_awqos,
	output	[C_M_AXI_AWUSER_WIDTH-1:0]		m_axi_awuser,
	output									m_axi_awvalid,
	input									m_axi_awready,

// Write data channel
	output	[C_M_AXI_ID_WIDTH-1:0]			m_axi_wid,
	output	[C_M_AXI_DATA_WIDTH-1:0]		m_axi_wdata,
	output	[(C_M_AXI_DATA_WIDTH/8)-1:0]	m_axi_wstrb,
	output									m_axi_wlast,
	output	[C_M_AXI_WUSER_WIDTH-1:0]		m_axi_wuser,
	output									m_axi_wvalid,
	input									m_axi_wready,

// Write response channel
	input	[C_M_AXI_ID_WIDTH-1:0]			m_axi_bid,
	input	[1:0]							m_axi_bresp,
	input									m_axi_bvalid,
	input	[C_M_AXI_BUSER_WIDTH-1:0]		m_axi_buser,
	output									m_axi_bready,

// Read address channel
	output	[C_M_AXI_ID_WIDTH-1:0]			m_axi_arid,
	output	[C_M_AXI_ADDR_WIDTH-1:0]		m_axi_araddr,
	output	[7:0]							m_axi_arlen,
	output	[2:0]							m_axi_arsize,
	output	[1:0]							m_axi_arburst,
	output	[1:0]							m_axi_arlock,
	output	[3:0]							m_axi_arcache,
	output	[2:0]							m_axi_arprot,
	output	[3:0]							m_axi_arregion,
	output	[3:0] 							m_axi_arqos,
	output	[C_M_AXI_ARUSER_WIDTH-1:0]		m_axi_aruser,
	output									m_axi_arvalid,
	input									m_axi_arready,

// Read data channel
	input	[C_M_AXI_ID_WIDTH-1:0]			m_axi_rid,
	input	[C_M_AXI_DATA_WIDTH-1:0]		m_axi_rdata,
	input	[1:0]							m_axi_rresp,
	input									m_axi_rlast,
	input	[C_M_AXI_RUSER_WIDTH-1:0]		m_axi_ruser,
	input									m_axi_rvalid,
	output 									m_axi_rready,

	output 									m_axi_bresp_err,
	output									m_axi_rresp_err,

	output									pcie_rx_fifo_rd_en,
	input	[C_M_AXI_DATA_WIDTH-1:0]		pcie_rx_fifo_rd_data,
	output									pcie_rx_fifo_free_en,
	output	[9:4]							pcie_rx_fifo_free_len,
	input									pcie_rx_fifo_empty_n,

	output									pcie_tx_fifo_alloc_en,
	output	[9:4]							pcie_tx_fifo_alloc_len,
	output									pcie_tx_fifo_wr_en,
	output	[C_M_AXI_DATA_WIDTH-1:0]		pcie_tx_fifo_wr_data,
	input									pcie_tx_fifo_full_n,

	input									pcie_user_clk,
	input									pcie_user_rst_n,

	input									dev_rx_cmd_wr_en,
	input	[29:0]							dev_rx_cmd_wr_data,
	output									dev_rx_cmd_full_n,

	input									dev_tx_cmd_wr_en,
	input	[29:0]							dev_tx_cmd_wr_data,
	output									dev_tx_cmd_full_n,

	output									dma_rx_done_wr_en,
	output	[20:0]							dma_rx_done_wr_data,
	input									dma_rx_done_wr_rdy_n

);

wire										w_dev_rx_cmd_rd_en;
wire	[29:0]								w_dev_rx_cmd_rd_data;
wire										w_dev_rx_cmd_empty_n;

wire										w_dev_tx_cmd_rd_en;
wire	[29:0]								w_dev_tx_cmd_rd_data;
wire										w_dev_tx_cmd_empty_n;

dev_rx_cmd_fifo 
dev_rx_cmd_fifo_inst0
(
	.wr_clk									(pcie_user_clk),
	.wr_rst_n								(pcie_user_rst_n),

	.wr_en									(dev_rx_cmd_wr_en),
	.wr_data								(dev_rx_cmd_wr_data),
	.full_n									(dev_rx_cmd_full_n),

	.rd_clk									(m_axi_aclk),
	.rd_rst_n								(m_axi_aresetn & pcie_user_rst_n),

	.rd_en									(w_dev_rx_cmd_rd_en),
	.rd_data								(w_dev_rx_cmd_rd_data),
	.empty_n								(w_dev_rx_cmd_empty_n)
);

dev_tx_cmd_fifo 
dev_tx_cmd_fifo_inst0
(
	.wr_clk									(pcie_user_clk),
	.wr_rst_n								(pcie_user_rst_n),

	.wr_en									(dev_tx_cmd_wr_en),
	.wr_data								(dev_tx_cmd_wr_data),
	.full_n									(dev_tx_cmd_full_n),

	.rd_clk									(m_axi_aclk),
	.rd_rst_n								(m_axi_aresetn & pcie_user_rst_n),

	.rd_en									(w_dev_tx_cmd_rd_en),
	.rd_data								(w_dev_tx_cmd_rd_data),
	.empty_n								(w_dev_tx_cmd_empty_n)
);

m_axi_write # (
	.C_M_AXI_ADDR_WIDTH						(C_M_AXI_ADDR_WIDTH),
	.C_M_AXI_DATA_WIDTH						(C_M_AXI_DATA_WIDTH),
	.C_M_AXI_ID_WIDTH						(C_M_AXI_ID_WIDTH),
	.C_M_AXI_AWUSER_WIDTH					(C_M_AXI_AWUSER_WIDTH),
	.C_M_AXI_WUSER_WIDTH					(C_M_AXI_WUSER_WIDTH),
	.C_M_AXI_BUSER_WIDTH					(C_M_AXI_BUSER_WIDTH)
)
m_axi_write_inst0(

////////////////////////////////////////////////////////////////
//AXI4 master write channel signal
	.m_axi_aclk								(m_axi_aclk),
	.m_axi_aresetn							(m_axi_aresetn),

// Write address channel
	.m_axi_awid								(m_axi_awid),
	.m_axi_awaddr							(m_axi_awaddr),
	.m_axi_awlen							(m_axi_awlen),
	.m_axi_awsize							(m_axi_awsize),
	.m_axi_awburst							(m_axi_awburst),
	.m_axi_awlock							(m_axi_awlock),
	.m_axi_awcache							(m_axi_awcache),
	.m_axi_awprot							(m_axi_awprot),
	.m_axi_awregion							(m_axi_awregion),
	.m_axi_awqos							(m_axi_awqos),
	.m_axi_awuser							(m_axi_awuser),
	.m_axi_awvalid							(m_axi_awvalid),
	.m_axi_awready							(m_axi_awready),

// Write data channel
	.m_axi_wid								(m_axi_wid),
	.m_axi_wdata							(m_axi_wdata),
	.m_axi_wstrb							(m_axi_wstrb),
	.m_axi_wlast							(m_axi_wlast),
	.m_axi_wuser							(m_axi_wuser),
	.m_axi_wvalid							(m_axi_wvalid),
	.m_axi_wready							(m_axi_wready),

// Write response channel
	.m_axi_bid								(m_axi_bid),
	.m_axi_bresp							(m_axi_bresp),
	.m_axi_bvalid							(m_axi_bvalid),
	.m_axi_buser							(m_axi_buser),
	.m_axi_bready							(m_axi_bready),

	.m_axi_bresp_err						(m_axi_bresp_err),

	.dev_rx_cmd_rd_en						(w_dev_rx_cmd_rd_en),
	.dev_rx_cmd_rd_data						(w_dev_rx_cmd_rd_data),
	.dev_rx_cmd_empty_n						(w_dev_rx_cmd_empty_n),

	.pcie_rx_fifo_rd_en						(pcie_rx_fifo_rd_en),
	.pcie_rx_fifo_rd_data					(pcie_rx_fifo_rd_data),
	.pcie_rx_fifo_free_en					(pcie_rx_fifo_free_en),
	.pcie_rx_fifo_free_len					(pcie_rx_fifo_free_len),
	.pcie_rx_fifo_empty_n					(pcie_rx_fifo_empty_n),

	.dma_rx_done_wr_en						(dma_rx_done_wr_en),
	.dma_rx_done_wr_data					(dma_rx_done_wr_data),
	.dma_rx_done_wr_rdy_n					(dma_rx_done_wr_rdy_n)
);


m_axi_read # (
	.C_M_AXI_ADDR_WIDTH						(C_M_AXI_ADDR_WIDTH),
	.C_M_AXI_DATA_WIDTH						(C_M_AXI_DATA_WIDTH),
	.C_M_AXI_ID_WIDTH						(C_M_AXI_ID_WIDTH),
	.C_M_AXI_ARUSER_WIDTH					(C_M_AXI_ARUSER_WIDTH),
	.C_M_AXI_RUSER_WIDTH					(C_M_AXI_RUSER_WIDTH)
)
m_axi_read_inst0(
////////////////////////////////////////////////////////////////
//AXI4 master read channel signals
	.m_axi_aclk								(m_axi_aclk),
	.m_axi_aresetn							(m_axi_aresetn),

// Read address channel
	.m_axi_arid								(m_axi_arid),
	.m_axi_araddr							(m_axi_araddr),
	.m_axi_arlen							(m_axi_arlen),
	.m_axi_arsize							(m_axi_arsize),
	.m_axi_arburst							(m_axi_arburst),
	.m_axi_arlock							(m_axi_arlock),
	.m_axi_arcache							(m_axi_arcache),
	.m_axi_arprot							(m_axi_arprot),
	.m_axi_arregion							(m_axi_arregion),
	.m_axi_arqos							(m_axi_arqos),
	.m_axi_aruser							(m_axi_aruser),
	.m_axi_arvalid							(m_axi_arvalid),
	.m_axi_arready							(m_axi_arready),

// Read data channel
	.m_axi_rid								(m_axi_rid),
	.m_axi_rdata							(m_axi_rdata),
	.m_axi_rresp							(m_axi_rresp),
	.m_axi_rlast							(m_axi_rlast),
	.m_axi_ruser							(m_axi_ruser),
	.m_axi_rvalid							(m_axi_rvalid),
	.m_axi_rready							(m_axi_rready),

	.m_axi_rresp_err						(m_axi_rresp_err),

	.dev_tx_cmd_rd_en						(w_dev_tx_cmd_rd_en),
	.dev_tx_cmd_rd_data						(w_dev_tx_cmd_rd_data),
	.dev_tx_cmd_empty_n						(w_dev_tx_cmd_empty_n),

	.pcie_tx_fifo_alloc_en					(pcie_tx_fifo_alloc_en),
	.pcie_tx_fifo_alloc_len					(pcie_tx_fifo_alloc_len),
	.pcie_tx_fifo_wr_en						(pcie_tx_fifo_wr_en),
	.pcie_tx_fifo_wr_data					(pcie_tx_fifo_wr_data),
	.pcie_tx_fifo_full_n					(pcie_tx_fifo_full_n)
);



endmodule
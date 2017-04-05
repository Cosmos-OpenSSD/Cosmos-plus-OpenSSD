
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

module s_axi_top # (
	parameter	C_S0_AXI_ADDR_WIDTH			= 32,
	parameter	C_S0_AXI_DATA_WIDTH			= 32,
	parameter	C_S0_AXI_BASEADDR			= 32'h80000000,
	parameter	C_S0_AXI_HIGHADDR			= 32'h80010000,

	parameter	C_M0_AXI_ADDR_WIDTH			= 32,
	parameter	C_M0_AXI_DATA_WIDTH			= 64,
	parameter	C_M0_AXI_ID_WIDTH			= 1,
	parameter	C_M0_AXI_AWUSER_WIDTH		= 1,
	parameter	C_M0_AXI_WUSER_WIDTH		= 1,
	parameter	C_M0_AXI_BUSER_WIDTH		= 1,
	parameter	C_M0_AXI_ARUSER_WIDTH		= 1,
	parameter	C_M0_AXI_RUSER_WIDTH		= 1,
	parameter	C_PCIE_ADDR_WIDTH			= 36
)
(
////////////////////////////////////////////////////////////////
//AXI4-lite slave interface signals
	input									s0_axi_aclk,
	input									s0_axi_aresetn,

//Write address channel
	input	[C_S0_AXI_ADDR_WIDTH-1:0]		s0_axi_awaddr,
	output									s0_axi_awready,
	input									s0_axi_awvalid,
	input	[2:0]							s0_axi_awprot,

//Write data channel
	input									s0_axi_wvalid,
	output									s0_axi_wready,
	input	[C_S0_AXI_DATA_WIDTH-1 :0]		s0_axi_wdata,
	input	[(C_S0_AXI_DATA_WIDTH/8)-1:0]	s0_axi_wstrb,

//Write response channel
	output									s0_axi_bvalid,
	input									s0_axi_bready,
	output	[1:0]							s0_axi_bresp,

//Read address channel
	input									s0_axi_arvalid,
	output									s0_axi_arready,
	input	[C_S0_AXI_ADDR_WIDTH-1:0]		s0_axi_araddr,
	input	[2:0]							s0_axi_arprot,

//Read data channel
	output									s0_axi_rvalid,
	input									s0_axi_rready,
	output	[C_S0_AXI_DATA_WIDTH-1:0]		s0_axi_rdata,
	output	[1:0]							s0_axi_rresp,

	output									dev_irq_assert,

	output									pcie_user_logic_rst,

	input									nvme_cc_en,
	input	[1:0]							nvme_cc_shn,

	output	[1:0]							nvme_csts_shst,
	output									nvme_csts_rdy,

	output	[8:0]							sq_valid,
	output	[7:0]							io_sq1_size,
	output	[7:0]							io_sq2_size,
	output	[7:0]							io_sq3_size,
	output	[7:0]							io_sq4_size,
	output	[7:0]							io_sq5_size,
	output	[7:0]							io_sq6_size,
	output	[7:0]							io_sq7_size,
	output	[7:0]							io_sq8_size,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_sq1_bs_addr,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_sq2_bs_addr,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_sq3_bs_addr,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_sq4_bs_addr,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_sq5_bs_addr,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_sq6_bs_addr,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_sq7_bs_addr,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_sq8_bs_addr,
	output	[3:0]							io_sq1_cq_vec,
	output	[3:0]							io_sq2_cq_vec,
	output	[3:0]							io_sq3_cq_vec,
	output	[3:0]							io_sq4_cq_vec,
	output	[3:0]							io_sq5_cq_vec,
	output	[3:0]							io_sq6_cq_vec,
	output	[3:0]							io_sq7_cq_vec,
	output	[3:0]							io_sq8_cq_vec,

	output	[8:0]							cq_valid,
	output	[7:0]							io_cq1_size,
	output	[7:0]							io_cq2_size,
	output	[7:0]							io_cq3_size,
	output	[7:0]							io_cq4_size,
	output	[7:0]							io_cq5_size,
	output	[7:0]							io_cq6_size,
	output	[7:0]							io_cq7_size,
	output	[7:0]							io_cq8_size,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_cq1_bs_addr,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_cq2_bs_addr,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_cq3_bs_addr,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_cq4_bs_addr,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_cq5_bs_addr,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_cq6_bs_addr,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_cq7_bs_addr,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_cq8_bs_addr,
	output	[8:0]							io_cq_irq_en,
	output	[2:0]							io_cq1_iv,
	output	[2:0]							io_cq2_iv,
	output	[2:0]							io_cq3_iv,
	output	[2:0]							io_cq4_iv,
	output	[2:0]							io_cq5_iv,
	output	[2:0]							io_cq6_iv,
	output	[2:0]							io_cq7_iv,
	output	[2:0]							io_cq8_iv,

	output									hcmd_sq_rd_en,
	input	[18:0]							hcmd_sq_rd_data,
	input									hcmd_sq_empty_n,

	output	[10:0]							hcmd_table_rd_addr,
	input	[31:0]							hcmd_table_rd_data,

	output									hcmd_cq_wr1_en,
	output	[34:0]							hcmd_cq_wr1_data0,
	output	[34:0]							hcmd_cq_wr1_data1,
	input									hcmd_cq_wr1_rdy_n,

	output									dma_cmd_wr_en,
	output	[49:0]							dma_cmd_wr_data0,
	output	[49:0]							dma_cmd_wr_data1,
	input									dma_cmd_wr_rdy_n,

	input									pcie_mreq_err,
	input									pcie_cpld_err,
	input									pcie_cpld_len_err,

////////////////////////////////////////////////////////////////
//AXI4 master interface signals
	input									m0_axi_aclk,
	input									m0_axi_aresetn,

// Write address channel
	output	[C_M0_AXI_ID_WIDTH-1:0]			m0_axi_awid,
	output	[C_M0_AXI_ADDR_WIDTH-1:0]		m0_axi_awaddr,
	output	[7:0]							m0_axi_awlen,
	output	[2:0]							m0_axi_awsize,
	output	[1:0]							m0_axi_awburst,
	output	[1:0]							m0_axi_awlock,
	output	[3:0]							m0_axi_awcache,
	output	[2:0]							m0_axi_awprot,
	output	[3:0]							m0_axi_awregion,
	output	[3:0]							m0_axi_awqos,
	output	[C_M0_AXI_AWUSER_WIDTH-1:0]		m0_axi_awuser,
	output									m0_axi_awvalid,
	input									m0_axi_awready,

// Write data channel
	output	[C_M0_AXI_ID_WIDTH-1:0]			m0_axi_wid,
	output	[C_M0_AXI_DATA_WIDTH-1:0]		m0_axi_wdata,
	output	[(C_M0_AXI_DATA_WIDTH/8)-1:0]	m0_axi_wstrb,
	output									m0_axi_wlast,
	output	[C_M0_AXI_WUSER_WIDTH-1:0]		m0_axi_wuser,
	output									m0_axi_wvalid,
	input									m0_axi_wready,

// Write response channel
	input	[C_M0_AXI_ID_WIDTH-1:0]			m0_axi_bid,
	input	[1:0]							m0_axi_bresp,
	input									m0_axi_bvalid,
	input	[C_M0_AXI_BUSER_WIDTH-1:0]		m0_axi_buser,
	output									m0_axi_bready,

// Read address channel
	output	[C_M0_AXI_ID_WIDTH-1:0]			m0_axi_arid,
	output	[C_M0_AXI_ADDR_WIDTH-1:0]		m0_axi_araddr,
	output	[7:0]							m0_axi_arlen,
	output	[2:0]							m0_axi_arsize,
	output	[1:0]							m0_axi_arburst,
	output	[1:0]							m0_axi_arlock,
	output	[3:0]							m0_axi_arcache,
	output	[2:0]							m0_axi_arprot,
	output	[3:0]							m0_axi_arregion,
	output	[3:0] 							m0_axi_arqos,
	output	[C_M0_AXI_ARUSER_WIDTH-1:0]		m0_axi_aruser,
	output									m0_axi_arvalid,
	input									m0_axi_arready,

// Read data channel
	input	[C_M0_AXI_ID_WIDTH-1:0]			m0_axi_rid,
	input	[C_M0_AXI_DATA_WIDTH-1:0]		m0_axi_rdata,
	input	[1:0]							m0_axi_rresp,
	input									m0_axi_rlast,
	input	[C_M0_AXI_RUSER_WIDTH-1:0]		m0_axi_ruser,
	input									m0_axi_rvalid,
	output 									m0_axi_rready,

	output									pcie_rx_fifo_rd_en,
	input	[C_M0_AXI_DATA_WIDTH-1:0]		pcie_rx_fifo_rd_data,
	output									pcie_rx_fifo_free_en,
	output	[9:4]							pcie_rx_fifo_free_len,
	input									pcie_rx_fifo_empty_n,

	output									pcie_tx_fifo_alloc_en,
	output	[9:4]							pcie_tx_fifo_alloc_len,
	output									pcie_tx_fifo_wr_en,
	output	[C_M0_AXI_DATA_WIDTH-1:0]		pcie_tx_fifo_wr_data,
	input									pcie_tx_fifo_full_n,

	output									dma_rx_done_wr_en,
	output	[20:0]							dma_rx_done_wr_data,
	input									dma_rx_done_wr_rdy_n,

	input									pcie_user_clk,
	input									pcie_user_rst_n,

	input									dev_rx_cmd_wr_en,
	input	[29:0]							dev_rx_cmd_wr_data,
	output									dev_rx_cmd_full_n,

	input									dev_tx_cmd_wr_en,
	input	[29:0]							dev_tx_cmd_wr_data,
	output									dev_tx_cmd_full_n,

	input	[7:0]							dma_rx_direct_done_cnt,
	input	[7:0]							dma_tx_direct_done_cnt,
	input	[7:0]							dma_rx_done_cnt,
	input	[7:0]							dma_tx_done_cnt,

	input									pcie_link_up,
	input	[5:0]							pl_ltssm_state,
	input	[15:0]							cfg_command,

	input	[2:0]							cfg_interrupt_mmenable,
	input									cfg_interrupt_msienable,
	input									cfg_interrupt_msixenable
);

wire										 w_m0_axi_bresp_err;
wire										 w_m0_axi_rresp_err;

s_axi_reg # (
	.C_S_AXI_ADDR_WIDTH						(C_S0_AXI_ADDR_WIDTH),
	.C_S_AXI_DATA_WIDTH						(C_S0_AXI_DATA_WIDTH),
	.C_S_AXI_BASEADDR						(C_S0_AXI_BASEADDR),
	.C_S_AXI_HIGHADDR						(C_S0_AXI_HIGHADDR)
)
s_axi_reg_inst0 (
////////////////////////////////////////////////////////////////
//AXI4-lite slave interface signals
	.s_axi_aclk								(s0_axi_aclk),
	.s_axi_aresetn							(s0_axi_aresetn),

//Write address channel
	.s_axi_awaddr							(s0_axi_awaddr),
	.s_axi_awready							(s0_axi_awready),
	.s_axi_awvalid							(s0_axi_awvalid),
	.s_axi_awprot							(s0_axi_awprot),

//Write data channel
	.s_axi_wvalid							(s0_axi_wvalid),
	.s_axi_wready							(s0_axi_wready),
	.s_axi_wdata							(s0_axi_wdata),
	.s_axi_wstrb							(s0_axi_wstrb),

//Write response channel
	.s_axi_bvalid							(s0_axi_bvalid),
	.s_axi_bready							(s0_axi_bready),
	.s_axi_bresp							(s0_axi_bresp),

//Read address channel
	.s_axi_arvalid							(s0_axi_arvalid),
	.s_axi_arready							(s0_axi_arready),
	.s_axi_araddr							(s0_axi_araddr),
	.s_axi_arprot							(s0_axi_arprot),

//Read data channel
	.s_axi_rvalid							(s0_axi_rvalid),
	.s_axi_rready							(s0_axi_rready),
	.s_axi_rdata							(s0_axi_rdata),
	.s_axi_rresp							(s0_axi_rresp),

	.pcie_mreq_err							(pcie_mreq_err),
	.pcie_cpld_err							(pcie_cpld_err),
	.pcie_cpld_len_err						(pcie_cpld_len_err),

	.m0_axi_bresp_err						(w_m0_axi_bresp_err),
	.m0_axi_rresp_err						(w_m0_axi_rresp_err),

	.dev_irq_assert							(dev_irq_assert),
	.pcie_user_logic_rst					(pcie_user_logic_rst),
	.nvme_cc_en								(nvme_cc_en),
	.nvme_cc_shn							(nvme_cc_shn),

	.nvme_csts_shst							(nvme_csts_shst),
	.nvme_csts_rdy							(nvme_csts_rdy),

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
	.io_sq1_cq_vec							(io_sq1_cq_vec),
	.io_sq2_cq_vec							(io_sq2_cq_vec),
	.io_sq3_cq_vec							(io_sq3_cq_vec),
	.io_sq4_cq_vec							(io_sq4_cq_vec),
	.io_sq5_cq_vec							(io_sq5_cq_vec),
	.io_sq6_cq_vec							(io_sq6_cq_vec),
	.io_sq7_cq_vec							(io_sq7_cq_vec),
	.io_sq8_cq_vec							(io_sq8_cq_vec),

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
	.io_cq_irq_en							(io_cq_irq_en),
	.io_cq1_iv								(io_cq1_iv),
	.io_cq2_iv								(io_cq2_iv),
	.io_cq3_iv								(io_cq3_iv),
	.io_cq4_iv								(io_cq4_iv),
	.io_cq5_iv								(io_cq5_iv),
	.io_cq6_iv								(io_cq6_iv),
	.io_cq7_iv								(io_cq7_iv),
	.io_cq8_iv								(io_cq8_iv),

	.hcmd_sq_rd_en							(hcmd_sq_rd_en),
	.hcmd_sq_rd_data						(hcmd_sq_rd_data),
	.hcmd_sq_empty_n						(hcmd_sq_empty_n),

	.hcmd_table_rd_addr						(hcmd_table_rd_addr),
	.hcmd_table_rd_data						(hcmd_table_rd_data),

	.hcmd_cq_wr1_en							(hcmd_cq_wr1_en),
	.hcmd_cq_wr1_data0						(hcmd_cq_wr1_data0),
	.hcmd_cq_wr1_data1						(hcmd_cq_wr1_data1),
	.hcmd_cq_wr1_rdy_n						(hcmd_cq_wr1_rdy_n),

	.dma_cmd_wr_en							(dma_cmd_wr_en),
	.dma_cmd_wr_data0						(dma_cmd_wr_data0),
	.dma_cmd_wr_data1						(dma_cmd_wr_data1),
	.dma_cmd_wr_rdy_n						(dma_cmd_wr_rdy_n),

	.dma_rx_direct_done_cnt					(dma_rx_direct_done_cnt),
	.dma_tx_direct_done_cnt					(dma_tx_direct_done_cnt),
	.dma_rx_done_cnt						(dma_rx_done_cnt),
	.dma_tx_done_cnt						(dma_tx_done_cnt),

	.pcie_link_up							(pcie_link_up),
	.pl_ltssm_state							(pl_ltssm_state),
	.cfg_command							(cfg_command),

	.cfg_interrupt_mmenable					(cfg_interrupt_mmenable),
	.cfg_interrupt_msienable				(cfg_interrupt_msienable),
	.cfg_interrupt_msixenable				(cfg_interrupt_msixenable)
);

m_axi_dma # (
	.C_M_AXI_ADDR_WIDTH						(C_M0_AXI_ADDR_WIDTH),
	.C_M_AXI_DATA_WIDTH						(C_M0_AXI_DATA_WIDTH),
	.C_M_AXI_ID_WIDTH						(C_M0_AXI_ID_WIDTH),
	.C_M_AXI_AWUSER_WIDTH					(C_M0_AXI_AWUSER_WIDTH),
	.C_M_AXI_WUSER_WIDTH					(C_M0_AXI_WUSER_WIDTH),
	.C_M_AXI_BUSER_WIDTH					(C_M0_AXI_BUSER_WIDTH),
	.C_M_AXI_ARUSER_WIDTH					(C_M0_AXI_ARUSER_WIDTH),
	.C_M_AXI_RUSER_WIDTH					(C_M0_AXI_RUSER_WIDTH)
)
m_axi_dma_inst0(
////////////////////////////////////////////////////////////////
//AXI4 master interface signals
	.m_axi_aclk								(m0_axi_aclk),
	.m_axi_aresetn							(m0_axi_aresetn),

// Write address channel
	.m_axi_awid								(m0_axi_awid),
	.m_axi_awaddr							(m0_axi_awaddr),
	.m_axi_awlen							(m0_axi_awlen),
	.m_axi_awsize							(m0_axi_awsize),
	.m_axi_awburst							(m0_axi_awburst),
	.m_axi_awlock							(m0_axi_awlock),
	.m_axi_awcache							(m0_axi_awcache),
	.m_axi_awprot							(m0_axi_awprot),
	.m_axi_awregion							(m0_axi_awregion),
	.m_axi_awqos							(m0_axi_awqos),
	.m_axi_awuser							(m0_axi_awuser),
	.m_axi_awvalid							(m0_axi_awvalid),
	.m_axi_awready							(m0_axi_awready),

// Write data channel
	.m_axi_wid								(m0_axi_wid),
	.m_axi_wdata							(m0_axi_wdata),
	.m_axi_wstrb							(m0_axi_wstrb),
	.m_axi_wlast							(m0_axi_wlast),
	.m_axi_wuser							(m0_axi_wuser),
	.m_axi_wvalid							(m0_axi_wvalid),
	.m_axi_wready							(m0_axi_wready),

// Write response channel
	.m_axi_bid								(m0_axi_bid),
	.m_axi_bresp							(m0_axi_bresp),
	.m_axi_bvalid							(m0_axi_bvalid),
	.m_axi_buser							(m0_axi_buser),
	.m_axi_bready							(m0_axi_bready),

// Read address channel
	.m_axi_arid								(m0_axi_arid),
	.m_axi_araddr							(m0_axi_araddr),
	.m_axi_arlen							(m0_axi_arlen),
	.m_axi_arsize							(m0_axi_arsize),
	.m_axi_arburst							(m0_axi_arburst),
	.m_axi_arlock							(m0_axi_arlock),
	.m_axi_arcache							(m0_axi_arcache),
	.m_axi_arprot							(m0_axi_arprot),
	.m_axi_arregion							(m0_axi_arregion),
	.m_axi_arqos							(m0_axi_arqos),
	.m_axi_aruser							(m0_axi_aruser),
	.m_axi_arvalid							(m0_axi_arvalid),
	.m_axi_arready							(m0_axi_arready),

// Read data channel
	.m_axi_rid								(m0_axi_rid),
	.m_axi_rdata							(m0_axi_rdata),
	.m_axi_rresp							(m0_axi_rresp),
	.m_axi_rlast							(m0_axi_rlast),
	.m_axi_ruser							(m0_axi_ruser),
	.m_axi_rvalid							(m0_axi_rvalid),
	.m_axi_rready							(m0_axi_rready),

	.m_axi_bresp_err						(w_m0_axi_bresp_err),
	.m_axi_rresp_err						(w_m0_axi_rresp_err),

	.pcie_rx_fifo_rd_en						(pcie_rx_fifo_rd_en),
	.pcie_rx_fifo_rd_data					(pcie_rx_fifo_rd_data),
	.pcie_rx_fifo_free_en					(pcie_rx_fifo_free_en),
	.pcie_rx_fifo_free_len					(pcie_rx_fifo_free_len),
	.pcie_rx_fifo_empty_n					(pcie_rx_fifo_empty_n),

	.pcie_tx_fifo_alloc_en					(pcie_tx_fifo_alloc_en),
	.pcie_tx_fifo_alloc_len					(pcie_tx_fifo_alloc_len),
	.pcie_tx_fifo_wr_en						(pcie_tx_fifo_wr_en),
	.pcie_tx_fifo_wr_data					(pcie_tx_fifo_wr_data),
	.pcie_tx_fifo_full_n					(pcie_tx_fifo_full_n),

	.dma_rx_done_wr_en						(dma_rx_done_wr_en),
	.dma_rx_done_wr_data					(dma_rx_done_wr_data),
	.dma_rx_done_wr_rdy_n					(dma_rx_done_wr_rdy_n),

	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.dev_rx_cmd_wr_en						(dev_rx_cmd_wr_en),
	.dev_rx_cmd_wr_data						(dev_rx_cmd_wr_data),
	.dev_rx_cmd_full_n						(dev_rx_cmd_full_n),

	.dev_tx_cmd_wr_en						(dev_tx_cmd_wr_en),
	.dev_tx_cmd_wr_data						(dev_tx_cmd_wr_data),
	.dev_tx_cmd_full_n						(dev_tx_cmd_full_n)
);


endmodule
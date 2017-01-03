
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

module user_top # (
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

	parameter	C_PCIE_DATA_WIDTH			= 128
)
(
////////////////////////////////////////////////////////////////
//AXI4-lite slave interface signals
	input									s0_axi_aclk,
	input									s0_axi_aresetn,

//Write address channel
	input	[C_S0_AXI_ADDR_WIDTH-1 : 0]		s0_axi_awaddr,
	output									s0_axi_awready,
	input									s0_axi_awvalid,
	input	[2 : 0]							s0_axi_awprot,

//Write data channel
	input									s0_axi_wvalid,
	output									s0_axi_wready,
	input	[C_S0_AXI_DATA_WIDTH-1 : 0]		s0_axi_wdata,
	input	[(C_S0_AXI_DATA_WIDTH/8)-1 : 0]	s0_axi_wstrb,

//Write response channel
	output									s0_axi_bvalid,
	input									s0_axi_bready,
	output	[1 : 0]							s0_axi_bresp,

//Read address channel
	input									s0_axi_arvalid,
	output									s0_axi_arready,
	input	[C_S0_AXI_ADDR_WIDTH-1 : 0]		s0_axi_araddr,
	input	[2 : 0]							s0_axi_arprot,

//Read data channel
	output									s0_axi_rvalid,
	input									s0_axi_rready,
	output	[C_S0_AXI_DATA_WIDTH-1 : 0]		s0_axi_rdata,
	output	[1 : 0]							s0_axi_rresp,

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


	input									pcie_ref_clk_p,
	input									pcie_ref_clk_n,
	input									pcie_perst_n,

	output									dev_irq_assert,

//PCIe Integrated Block Interface
	input									user_clk_out,
	input									user_reset_out,
	input									user_lnk_up,

	input	[5:0]							tx_buf_av,
	input									tx_err_drop,
	input									tx_cfg_req,
	input									s_axis_tx_tready,
	output	[C_PCIE_DATA_WIDTH-1:0]			s_axis_tx_tdata,
	output	[(C_PCIE_DATA_WIDTH/8)-1:0]		s_axis_tx_tkeep,
	output	[3:0]							s_axis_tx_tuser,
	output									s_axis_tx_tlast,
	output									s_axis_tx_tvalid,
	output									tx_cfg_gnt,

	input	[C_PCIE_DATA_WIDTH-1:0]			m_axis_rx_tdata,
	input	[(C_PCIE_DATA_WIDTH/8)-1:0]		m_axis_rx_tkeep,
	input									m_axis_rx_tlast,
	input									m_axis_rx_tvalid,
	output									m_axis_rx_tready,
	input	[21:0]							m_axis_rx_tuser,
	output									rx_np_ok,
	output									rx_np_req,

	input	[11:0]							fc_cpld,
	input	[7:0]							fc_cplh,
	input	[11:0]							fc_npd,
	input	[7:0]							fc_nph,
	input	[11:0]							fc_pd,
	input	[7:0]							fc_ph,
	output	[2:0]							fc_sel,

	input	[7:0]							cfg_bus_number,
	input	[4:0]							cfg_device_number,
	input	[2:0]							cfg_function_number,

	output									cfg_interrupt,
	input									cfg_interrupt_rdy,
	output									cfg_interrupt_assert,
	output	[7:0]							cfg_interrupt_di,
	input	[7:0]							cfg_interrupt_do,
	input	[2:0]							cfg_interrupt_mmenable,
	input									cfg_interrupt_msienable,
	input									cfg_interrupt_msixenable,
	input									cfg_interrupt_msixfm,
	output									cfg_interrupt_stat,
	output	[4:0]							cfg_pciecap_interrupt_msgnum,

	input									cfg_to_turnoff,
	output									cfg_turnoff_ok,

	input	[15:0]							cfg_command,
	input	[15:0]							cfg_dcommand,
	input	[15:0]							cfg_lcommand,

	input	[5:0]							pl_ltssm_state,
	input									pl_received_hot_rst,

	output									sys_clk,
	output									sys_rst_n

);

parameter	C_PCIE_ADDR_WIDTH				= 36;


wire										pcie_user_rst_n;

wire										w_pcie_user_logic_rst;

wire										w_pcie_link_up_sync;
wire	[5:0]								w_pl_ltssm_state_sync;
wire	[15:0]								w_cfg_command_sync;
wire	[2:0]								w_cfg_interrupt_mmenable_sync;
wire										w_cfg_interrupt_msienable_sync;
wire										w_cfg_interrupt_msixenable_sync;

wire										w_pcie_mreq_err_sync;
wire										w_pcie_cpld_err_sync;
wire										w_pcie_cpld_len_err_sync;

wire										w_nvme_cc_en_sync;
wire	[1:0]								w_nvme_cc_shn_sync;

wire	[1:0]								w_nvme_csts_shst;
wire										w_nvme_csts_rdy;

wire	[8:0]								w_sq_valid;
wire	[7:0]								w_io_sq1_size;
wire	[7:0]								w_io_sq2_size;
wire	[7:0]								w_io_sq3_size;
wire	[7:0]								w_io_sq4_size;
wire	[7:0]								w_io_sq5_size;
wire	[7:0]								w_io_sq6_size;
wire	[7:0]								w_io_sq7_size;
wire	[7:0]								w_io_sq8_size;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_sq1_bs_addr;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_sq2_bs_addr;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_sq3_bs_addr;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_sq4_bs_addr;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_sq5_bs_addr;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_sq6_bs_addr;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_sq7_bs_addr;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_sq8_bs_addr;
wire	[3:0]								w_io_sq1_cq_vec;
wire	[3:0]								w_io_sq2_cq_vec;
wire	[3:0]								w_io_sq3_cq_vec;
wire	[3:0]								w_io_sq4_cq_vec;
wire	[3:0]								w_io_sq5_cq_vec;
wire	[3:0]								w_io_sq6_cq_vec;
wire	[3:0]								w_io_sq7_cq_vec;
wire	[3:0]								w_io_sq8_cq_vec;

wire	[8:0]								w_cq_valid;
wire	[7:0]								w_io_cq1_size;
wire	[7:0]								w_io_cq2_size;
wire	[7:0]								w_io_cq3_size;
wire	[7:0]								w_io_cq4_size;
wire	[7:0]								w_io_cq5_size;
wire	[7:0]								w_io_cq6_size;
wire	[7:0]								w_io_cq7_size;
wire	[7:0]								w_io_cq8_size;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_cq1_bs_addr;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_cq2_bs_addr;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_cq3_bs_addr;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_cq4_bs_addr;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_cq5_bs_addr;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_cq6_bs_addr;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_cq7_bs_addr;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_cq8_bs_addr;
wire	[8:0]								w_io_cq_irq_en;
wire	[2:0]								w_io_cq1_iv;
wire	[2:0]								w_io_cq2_iv;
wire	[2:0]								w_io_cq3_iv;
wire	[2:0]								w_io_cq4_iv;
wire	[2:0]								w_io_cq5_iv;
wire	[2:0]								w_io_cq6_iv;
wire	[2:0]								w_io_cq7_iv;
wire	[2:0]								w_io_cq8_iv;


wire										w_nvme_cc_en;
wire	[1:0]								w_nvme_cc_shn;

wire										w_pcie_mreq_err;
wire										w_pcie_cpld_err;
wire										w_pcie_cpld_len_err;

wire	[1:0]								w_nvme_csts_shst_sync;
wire										w_nvme_csts_rdy_sync;

wire	[8:0]								w_sq_rst_n_sync;
wire	[8:0]								w_sq_valid_sync;
wire	[7:0]								w_io_sq1_size_sync;
wire	[7:0]								w_io_sq2_size_sync;
wire	[7:0]								w_io_sq3_size_sync;
wire	[7:0]								w_io_sq4_size_sync;
wire	[7:0]								w_io_sq5_size_sync;
wire	[7:0]								w_io_sq6_size_sync;
wire	[7:0]								w_io_sq7_size_sync;
wire	[7:0]								w_io_sq8_size_sync;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_sq1_bs_addr_sync;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_sq2_bs_addr_sync;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_sq3_bs_addr_sync;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_sq4_bs_addr_sync;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_sq5_bs_addr_sync;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_sq6_bs_addr_sync;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_sq7_bs_addr_sync;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_sq8_bs_addr_sync;
wire	[3:0]								w_io_sq1_cq_vec_sync;
wire	[3:0]								w_io_sq2_cq_vec_sync;
wire	[3:0]								w_io_sq3_cq_vec_sync;
wire	[3:0]								w_io_sq4_cq_vec_sync;
wire	[3:0]								w_io_sq5_cq_vec_sync;
wire	[3:0]								w_io_sq6_cq_vec_sync;
wire	[3:0]								w_io_sq7_cq_vec_sync;
wire	[3:0]								w_io_sq8_cq_vec_sync;

wire	[8:0]								w_cq_rst_n_sync;
wire	[8:0]								w_cq_valid_sync;
wire	[7:0]								w_io_cq1_size_sync;
wire	[7:0]								w_io_cq2_size_sync;
wire	[7:0]								w_io_cq3_size_sync;
wire	[7:0]								w_io_cq4_size_sync;
wire	[7:0]								w_io_cq5_size_sync;
wire	[7:0]								w_io_cq6_size_sync;
wire	[7:0]								w_io_cq7_size_sync;
wire	[7:0]								w_io_cq8_size_sync;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_cq1_bs_addr_sync;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_cq2_bs_addr_sync;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_cq3_bs_addr_sync;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_cq4_bs_addr_sync;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_cq5_bs_addr_sync;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_cq6_bs_addr_sync;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_cq7_bs_addr_sync;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_io_cq8_bs_addr_sync;
wire	[8:0]								w_io_cq_irq_en_sync;
wire	[2:0]								w_io_cq1_iv_sync;
wire	[2:0]								w_io_cq2_iv_sync;
wire	[2:0]								w_io_cq3_iv_sync;
wire	[2:0]								w_io_cq4_iv_sync;
wire	[2:0]								w_io_cq5_iv_sync;
wire	[2:0]								w_io_cq6_iv_sync;
wire	[2:0]								w_io_cq7_iv_sync;
wire	[2:0]								w_io_cq8_iv_sync;

wire	[10:0]								w_hcmd_table_rd_addr;
wire	[31:0]								w_hcmd_table_rd_data;

wire										w_hcmd_sq_rd_en;
wire	[18:0]								w_hcmd_sq_rd_data;
wire										w_hcmd_sq_empty_n;

wire										w_hcmd_cq_wr1_en;
wire	[34:0]								w_hcmd_cq_wr1_data0;
wire	[34:0]								w_hcmd_cq_wr1_data1;
wire										w_hcmd_cq_wr1_rdy_n;

wire										w_dma_cmd_wr_en;
wire	[49:0]								w_dma_cmd_wr_data0;
wire	[49:0]								w_dma_cmd_wr_data1;
wire										w_dma_cmd_wr_rdy_n;

wire	[7:0]								w_dma_rx_direct_done_cnt;
wire	[7:0]								w_dma_tx_direct_done_cnt;
wire	[7:0]								w_dma_rx_done_cnt;
wire	[7:0]								w_dma_tx_done_cnt;

wire										w_pcie_rx_fifo_rd_en;
wire	[C_M0_AXI_DATA_WIDTH-1:0]			w_pcie_rx_fifo_rd_data;
wire										w_pcie_rx_fifo_free_en;
wire	[9:4]								w_pcie_rx_fifo_free_len;
wire										w_pcie_rx_fifo_empty_n;

wire										w_pcie_tx_fifo_alloc_en;
wire	[9:4]								w_pcie_tx_fifo_alloc_len;
wire										w_pcie_tx_fifo_wr_en;
wire	[C_M0_AXI_DATA_WIDTH-1:0]			w_pcie_tx_fifo_wr_data;
wire										w_pcie_tx_fifo_full_n;

wire										w_dma_rx_done_wr_en;
wire	[20:0]								w_dma_rx_done_wr_data;
wire										w_dma_rx_done_wr_rdy_n;

wire										w_dev_rx_cmd_wr_en;
wire	[29:0]								w_dev_rx_cmd_wr_data;
wire										w_dev_rx_cmd_full_n;

wire										w_dev_tx_cmd_wr_en;
wire	[29:0]								w_dev_tx_cmd_wr_data;
wire										w_dev_tx_cmd_full_n;

sys_rst
sys_rst_inst0(
	.cpu_bus_clk							(s0_axi_aclk),
	.cpu_bus_rst_n							(s0_axi_aresetn),

	.pcie_perst_n							(pcie_perst_n),
	.user_reset_out							(user_reset_out),
	.pcie_pl_hot_rst						(pl_received_hot_rst),
	.pcie_user_logic_rst					(w_pcie_user_logic_rst),

	.pcie_sys_rst_n							(sys_rst_n),
	.pcie_user_rst_n						(pcie_user_rst_n)

);

s_axi_top # (
	.C_S0_AXI_ADDR_WIDTH					(C_S0_AXI_ADDR_WIDTH),
	.C_S0_AXI_DATA_WIDTH					(C_S0_AXI_DATA_WIDTH),
	.C_S0_AXI_BASEADDR						(C_S0_AXI_BASEADDR),
	.C_S0_AXI_HIGHADDR						(C_S0_AXI_HIGHADDR),

	.C_M0_AXI_ADDR_WIDTH					(C_M0_AXI_ADDR_WIDTH),
	.C_M0_AXI_DATA_WIDTH					(C_M0_AXI_DATA_WIDTH),
	.C_M0_AXI_ID_WIDTH						(C_M0_AXI_ID_WIDTH),
	.C_M0_AXI_AWUSER_WIDTH					(C_M0_AXI_AWUSER_WIDTH),
	.C_M0_AXI_WUSER_WIDTH					(C_M0_AXI_WUSER_WIDTH),
	.C_M0_AXI_BUSER_WIDTH					(C_M0_AXI_BUSER_WIDTH),
	.C_M0_AXI_ARUSER_WIDTH					(C_M0_AXI_ARUSER_WIDTH),
	.C_M0_AXI_RUSER_WIDTH					(C_M0_AXI_RUSER_WIDTH)
)
s_axi_top_inst0 (

////////////////////////////////////////////////////////////////
//AXI4-lite slave interface signals
	.s0_axi_aclk							(s0_axi_aclk),
	.s0_axi_aresetn							(s0_axi_aresetn),

//Write address channel
	.s0_axi_awaddr							(s0_axi_awaddr),
	.s0_axi_awready							(s0_axi_awready),
	.s0_axi_awvalid							(s0_axi_awvalid),
	.s0_axi_awprot							(s0_axi_awprot),

//Write data channel
	.s0_axi_wvalid							(s0_axi_wvalid),
	.s0_axi_wready							(s0_axi_wready),
	.s0_axi_wdata							(s0_axi_wdata),
	.s0_axi_wstrb							(s0_axi_wstrb),

//Write response channel
	.s0_axi_bvalid							(s0_axi_bvalid),
	.s0_axi_bready							(s0_axi_bready),
	.s0_axi_bresp							(s0_axi_bresp),

//Read address channel
	.s0_axi_arvalid							(s0_axi_arvalid),
	.s0_axi_arready							(s0_axi_arready),
	.s0_axi_araddr							(s0_axi_araddr),
	.s0_axi_arprot							(s0_axi_arprot),

//Read data channel
	.s0_axi_rvalid							(s0_axi_rvalid),
	.s0_axi_rready							(s0_axi_rready),
	.s0_axi_rdata							(s0_axi_rdata),
	.s0_axi_rresp							(s0_axi_rresp),

	.pcie_mreq_err							(w_pcie_mreq_err_sync),
	.pcie_cpld_err							(w_pcie_cpld_err_sync),
	.pcie_cpld_len_err						(w_pcie_cpld_len_err_sync),

	.dev_irq_assert							(dev_irq_assert),

	.pcie_user_logic_rst					(w_pcie_user_logic_rst),
	.nvme_cc_en								(w_nvme_cc_en_sync),
	.nvme_cc_shn							(w_nvme_cc_shn_sync),

	.nvme_csts_shst							(w_nvme_csts_shst),
	.nvme_csts_rdy							(w_nvme_csts_rdy),

	.sq_valid								(w_sq_valid),
	.io_sq1_size							(w_io_sq1_size),
	.io_sq2_size							(w_io_sq2_size),
	.io_sq3_size							(w_io_sq3_size),
	.io_sq4_size							(w_io_sq4_size),
	.io_sq5_size							(w_io_sq5_size),
	.io_sq6_size							(w_io_sq6_size),
	.io_sq7_size							(w_io_sq7_size),
	.io_sq8_size							(w_io_sq8_size),
	.io_sq1_bs_addr							(w_io_sq1_bs_addr),
	.io_sq2_bs_addr							(w_io_sq2_bs_addr),
	.io_sq3_bs_addr							(w_io_sq3_bs_addr),
	.io_sq4_bs_addr							(w_io_sq4_bs_addr),
	.io_sq5_bs_addr							(w_io_sq5_bs_addr),
	.io_sq6_bs_addr							(w_io_sq6_bs_addr),
	.io_sq7_bs_addr							(w_io_sq7_bs_addr),
	.io_sq8_bs_addr							(w_io_sq8_bs_addr),
	.io_sq1_cq_vec							(w_io_sq1_cq_vec),
	.io_sq2_cq_vec							(w_io_sq2_cq_vec),
	.io_sq3_cq_vec							(w_io_sq3_cq_vec),
	.io_sq4_cq_vec							(w_io_sq4_cq_vec),
	.io_sq5_cq_vec							(w_io_sq5_cq_vec),
	.io_sq6_cq_vec							(w_io_sq6_cq_vec),
	.io_sq7_cq_vec							(w_io_sq7_cq_vec),
	.io_sq8_cq_vec							(w_io_sq8_cq_vec),

	.cq_valid								(w_cq_valid),
	.io_cq1_size							(w_io_cq1_size),
	.io_cq2_size							(w_io_cq2_size),
	.io_cq3_size							(w_io_cq3_size),
	.io_cq4_size							(w_io_cq4_size),
	.io_cq5_size							(w_io_cq5_size),
	.io_cq6_size							(w_io_cq6_size),
	.io_cq7_size							(w_io_cq7_size),
	.io_cq8_size							(w_io_cq8_size),
	.io_cq1_bs_addr							(w_io_cq1_bs_addr),
	.io_cq2_bs_addr							(w_io_cq2_bs_addr),
	.io_cq3_bs_addr							(w_io_cq3_bs_addr),
	.io_cq4_bs_addr							(w_io_cq4_bs_addr),
	.io_cq5_bs_addr							(w_io_cq5_bs_addr),
	.io_cq6_bs_addr							(w_io_cq6_bs_addr),
	.io_cq7_bs_addr							(w_io_cq7_bs_addr),
	.io_cq8_bs_addr							(w_io_cq8_bs_addr),
	.io_cq_irq_en							(w_io_cq_irq_en),
	.io_cq1_iv								(w_io_cq1_iv),
	.io_cq2_iv								(w_io_cq2_iv),
	.io_cq3_iv								(w_io_cq3_iv),
	.io_cq4_iv								(w_io_cq4_iv),
	.io_cq5_iv								(w_io_cq5_iv),
	.io_cq6_iv								(w_io_cq6_iv),
	.io_cq7_iv								(w_io_cq7_iv),
	.io_cq8_iv								(w_io_cq8_iv),

	.hcmd_sq_rd_en							(w_hcmd_sq_rd_en),
	.hcmd_sq_rd_data						(w_hcmd_sq_rd_data),
	.hcmd_sq_empty_n						(w_hcmd_sq_empty_n),

	.hcmd_table_rd_addr						(w_hcmd_table_rd_addr),
	.hcmd_table_rd_data						(w_hcmd_table_rd_data),

	.hcmd_cq_wr1_en							(w_hcmd_cq_wr1_en),
	.hcmd_cq_wr1_data0						(w_hcmd_cq_wr1_data0),
	.hcmd_cq_wr1_data1						(w_hcmd_cq_wr1_data1),
	.hcmd_cq_wr1_rdy_n						(w_hcmd_cq_wr1_rdy_n),

	.dma_cmd_wr_en							(w_dma_cmd_wr_en),
	.dma_cmd_wr_data0						(w_dma_cmd_wr_data0),
	.dma_cmd_wr_data1						(w_dma_cmd_wr_data1),
	.dma_cmd_wr_rdy_n						(w_dma_cmd_wr_rdy_n),

////////////////////////////////////////////////////////////////
//AXI4 master interface signals
	.m0_axi_aclk							(m0_axi_aclk),
	.m0_axi_aresetn							(m0_axi_aresetn),

// Write address channel
	.m0_axi_awid							(m0_axi_awid),
	.m0_axi_awaddr							(m0_axi_awaddr),
	.m0_axi_awlen							(m0_axi_awlen),
	.m0_axi_awsize							(m0_axi_awsize),
	.m0_axi_awburst							(m0_axi_awburst),
	.m0_axi_awlock							(m0_axi_awlock),
	.m0_axi_awcache							(m0_axi_awcache),
	.m0_axi_awprot							(m0_axi_awprot),
	.m0_axi_awregion						(m0_axi_awregion),
	.m0_axi_awqos							(m0_axi_awqos),
	.m0_axi_awuser							(m0_axi_awuser),
	.m0_axi_awvalid							(m0_axi_awvalid),
	.m0_axi_awready							(m0_axi_awready),

// Write data channel
	.m0_axi_wid								(m0_axi_wid),
	.m0_axi_wdata							(m0_axi_wdata),
	.m0_axi_wstrb							(m0_axi_wstrb),
	.m0_axi_wlast							(m0_axi_wlast),
	.m0_axi_wuser							(m0_axi_wuser),
	.m0_axi_wvalid							(m0_axi_wvalid),
	.m0_axi_wready							(m0_axi_wready),

// Write response channel
	.m0_axi_bid								(m0_axi_bid),
	.m0_axi_bresp							(m0_axi_bresp),
	.m0_axi_bvalid							(m0_axi_bvalid),
	.m0_axi_buser							(m0_axi_buser),
	.m0_axi_bready							(m0_axi_bready),

// Read address channel
	.m0_axi_arid							(m0_axi_arid),
	.m0_axi_araddr							(m0_axi_araddr),
	.m0_axi_arlen							(m0_axi_arlen),
	.m0_axi_arsize							(m0_axi_arsize),
	.m0_axi_arburst							(m0_axi_arburst),
	.m0_axi_arlock							(m0_axi_arlock),
	.m0_axi_arcache							(m0_axi_arcache),
	.m0_axi_arprot							(m0_axi_arprot),
	.m0_axi_arregion						(m0_axi_arregion),
	.m0_axi_arqos							(m0_axi_arqos),
	.m0_axi_aruser							(m0_axi_aruser),
	.m0_axi_arvalid							(m0_axi_arvalid),
	.m0_axi_arready							(m0_axi_arready),

// Read data channel
	.m0_axi_rid								(m0_axi_rid),
	.m0_axi_rdata							(m0_axi_rdata),
	.m0_axi_rresp							(m0_axi_rresp),
	.m0_axi_rlast							(m0_axi_rlast),
	.m0_axi_ruser							(m0_axi_ruser),
	.m0_axi_rvalid							(m0_axi_rvalid),
	.m0_axi_rready							(m0_axi_rready),

	.pcie_rx_fifo_rd_en						(w_pcie_rx_fifo_rd_en),
	.pcie_rx_fifo_rd_data					(w_pcie_rx_fifo_rd_data),
	.pcie_rx_fifo_free_en					(w_pcie_rx_fifo_free_en),
	.pcie_rx_fifo_free_len					(w_pcie_rx_fifo_free_len),
	.pcie_rx_fifo_empty_n					(w_pcie_rx_fifo_empty_n),

	.pcie_tx_fifo_alloc_en					(w_pcie_tx_fifo_alloc_en),
	.pcie_tx_fifo_alloc_len					(w_pcie_tx_fifo_alloc_len),
	.pcie_tx_fifo_wr_en						(w_pcie_tx_fifo_wr_en),
	.pcie_tx_fifo_wr_data					(w_pcie_tx_fifo_wr_data),
	.pcie_tx_fifo_full_n					(w_pcie_tx_fifo_full_n),

	.dma_rx_done_wr_en						(w_dma_rx_done_wr_en),
	.dma_rx_done_wr_data					(w_dma_rx_done_wr_data),
	.dma_rx_done_wr_rdy_n					(w_dma_rx_done_wr_rdy_n),

	.pcie_user_clk							(user_clk_out),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.dev_rx_cmd_wr_en						(w_dev_rx_cmd_wr_en),
	.dev_rx_cmd_wr_data						(w_dev_rx_cmd_wr_data),
	.dev_rx_cmd_full_n						(w_dev_rx_cmd_full_n),

	.dev_tx_cmd_wr_en						(w_dev_tx_cmd_wr_en),
	.dev_tx_cmd_wr_data						(w_dev_tx_cmd_wr_data),
	.dev_tx_cmd_full_n						(w_dev_tx_cmd_full_n),

	.dma_rx_direct_done_cnt					(w_dma_rx_direct_done_cnt),
	.dma_tx_direct_done_cnt					(w_dma_tx_direct_done_cnt),
	.dma_rx_done_cnt						(w_dma_rx_done_cnt),
	.dma_tx_done_cnt						(w_dma_tx_done_cnt),

	.pcie_link_up							(w_pcie_link_up_sync),
	.pl_ltssm_state							(w_pl_ltssm_state_sync),
	.cfg_command							(w_cfg_command_sync),

	.cfg_interrupt_mmenable					(w_cfg_interrupt_mmenable_sync),
	.cfg_interrupt_msienable				(w_cfg_interrupt_msienable_sync),
	.cfg_interrupt_msixenable				(w_cfg_interrupt_msixenable_sync)
);


reg_cpu_pcie_sync
reg_cpu_pcie_sync_isnt0
(
	.cpu_bus_clk						(s0_axi_aclk),

	.nvme_csts_shst						(w_nvme_csts_shst),
	.nvme_csts_rdy						(w_nvme_csts_rdy),

	.sq_valid							(w_sq_valid),
	.io_sq1_size						(w_io_sq1_size),
	.io_sq2_size						(w_io_sq2_size),
	.io_sq3_size						(w_io_sq3_size),
	.io_sq4_size						(w_io_sq4_size),
	.io_sq5_size						(w_io_sq5_size),
	.io_sq6_size						(w_io_sq6_size),
	.io_sq7_size						(w_io_sq7_size),
	.io_sq8_size						(w_io_sq8_size),
	.io_sq1_bs_addr						(w_io_sq1_bs_addr),
	.io_sq2_bs_addr						(w_io_sq2_bs_addr),
	.io_sq3_bs_addr						(w_io_sq3_bs_addr),
	.io_sq4_bs_addr						(w_io_sq4_bs_addr),
	.io_sq5_bs_addr						(w_io_sq5_bs_addr),
	.io_sq6_bs_addr						(w_io_sq6_bs_addr),
	.io_sq7_bs_addr						(w_io_sq7_bs_addr),
	.io_sq8_bs_addr						(w_io_sq8_bs_addr),
	.io_sq1_cq_vec						(w_io_sq1_cq_vec),
	.io_sq2_cq_vec						(w_io_sq2_cq_vec),
	.io_sq3_cq_vec						(w_io_sq3_cq_vec),
	.io_sq4_cq_vec						(w_io_sq4_cq_vec),
	.io_sq5_cq_vec						(w_io_sq5_cq_vec),
	.io_sq6_cq_vec						(w_io_sq6_cq_vec),
	.io_sq7_cq_vec						(w_io_sq7_cq_vec),
	.io_sq8_cq_vec						(w_io_sq8_cq_vec),

	.cq_valid							(w_cq_valid),
	.io_cq1_size						(w_io_cq1_size),
	.io_cq2_size						(w_io_cq2_size),
	.io_cq3_size						(w_io_cq3_size),
	.io_cq4_size						(w_io_cq4_size),
	.io_cq5_size						(w_io_cq5_size),
	.io_cq6_size						(w_io_cq6_size),
	.io_cq7_size						(w_io_cq7_size),
	.io_cq8_size						(w_io_cq8_size),
	.io_cq1_bs_addr						(w_io_cq1_bs_addr),
	.io_cq2_bs_addr						(w_io_cq2_bs_addr),
	.io_cq3_bs_addr						(w_io_cq3_bs_addr),
	.io_cq4_bs_addr						(w_io_cq4_bs_addr),
	.io_cq5_bs_addr						(w_io_cq5_bs_addr),
	.io_cq6_bs_addr						(w_io_cq6_bs_addr),
	.io_cq7_bs_addr						(w_io_cq7_bs_addr),
	.io_cq8_bs_addr						(w_io_cq8_bs_addr),
	.io_cq_irq_en						(w_io_cq_irq_en),
	.io_cq1_iv							(w_io_cq1_iv),
	.io_cq2_iv							(w_io_cq2_iv),
	.io_cq3_iv							(w_io_cq3_iv),
	.io_cq4_iv							(w_io_cq4_iv),
	.io_cq5_iv							(w_io_cq5_iv),
	.io_cq6_iv							(w_io_cq6_iv),
	.io_cq7_iv							(w_io_cq7_iv),
	.io_cq8_iv							(w_io_cq8_iv),

	.pcie_link_up_sync					(w_pcie_link_up_sync),
	.pl_ltssm_state_sync				(w_pl_ltssm_state_sync),
	.cfg_command_sync					(w_cfg_command_sync),
	.cfg_interrupt_mmenable_sync		(w_cfg_interrupt_mmenable_sync),
	.cfg_interrupt_msienable_sync		(w_cfg_interrupt_msienable_sync),
	.cfg_interrupt_msixenable_sync		(w_cfg_interrupt_msixenable_sync),

	.pcie_mreq_err_sync					(w_pcie_mreq_err_sync),
	.pcie_cpld_err_sync					(w_pcie_cpld_err_sync),
	.pcie_cpld_len_err_sync				(w_pcie_cpld_len_err_sync),

	.nvme_cc_en_sync					(w_nvme_cc_en_sync),
	.nvme_cc_shn_sync					(w_nvme_cc_shn_sync),

	.pcie_user_clk						(user_clk_out),

	.pcie_link_up						(user_lnk_up),
	.pl_ltssm_state						(pl_ltssm_state),
	.cfg_command						(cfg_command),
	.cfg_interrupt_mmenable				(cfg_interrupt_mmenable),
	.cfg_interrupt_msienable			(cfg_interrupt_msienable),
	.cfg_interrupt_msixenable			(cfg_interrupt_msixenable),

	.pcie_mreq_err						(w_pcie_mreq_err),
	.pcie_cpld_err						(w_pcie_cpld_err),
	.pcie_cpld_len_err					(w_pcie_cpld_len_err),

	.nvme_cc_en							(w_nvme_cc_en),
	.nvme_cc_shn						(w_nvme_cc_shn),

	.nvme_csts_shst_sync				(w_nvme_csts_shst_sync),
	.nvme_csts_rdy_sync					(w_nvme_csts_rdy_sync),

	.sq_rst_n_sync						(w_sq_rst_n_sync),
	.sq_valid_sync						(w_sq_valid_sync),
	.io_sq1_size_sync					(w_io_sq1_size_sync),
	.io_sq2_size_sync					(w_io_sq2_size_sync),
	.io_sq3_size_sync					(w_io_sq3_size_sync),
	.io_sq4_size_sync					(w_io_sq4_size_sync),
	.io_sq5_size_sync					(w_io_sq5_size_sync),
	.io_sq6_size_sync					(w_io_sq6_size_sync),
	.io_sq7_size_sync					(w_io_sq7_size_sync),
	.io_sq8_size_sync					(w_io_sq8_size_sync),
	.io_sq1_bs_addr_sync				(w_io_sq1_bs_addr_sync),
	.io_sq2_bs_addr_sync				(w_io_sq2_bs_addr_sync),
	.io_sq3_bs_addr_sync				(w_io_sq3_bs_addr_sync),
	.io_sq4_bs_addr_sync				(w_io_sq4_bs_addr_sync),
	.io_sq5_bs_addr_sync				(w_io_sq5_bs_addr_sync),
	.io_sq6_bs_addr_sync				(w_io_sq6_bs_addr_sync),
	.io_sq7_bs_addr_sync				(w_io_sq7_bs_addr_sync),
	.io_sq8_bs_addr_sync				(w_io_sq8_bs_addr_sync),
	.io_sq1_cq_vec_sync					(w_io_sq1_cq_vec_sync),
	.io_sq2_cq_vec_sync					(w_io_sq2_cq_vec_sync),
	.io_sq3_cq_vec_sync					(w_io_sq3_cq_vec_sync),
	.io_sq4_cq_vec_sync					(w_io_sq4_cq_vec_sync),
	.io_sq5_cq_vec_sync					(w_io_sq5_cq_vec_sync),
	.io_sq6_cq_vec_sync					(w_io_sq6_cq_vec_sync),
	.io_sq7_cq_vec_sync					(w_io_sq7_cq_vec_sync),
	.io_sq8_cq_vec_sync					(w_io_sq8_cq_vec_sync),

	.cq_rst_n_sync						(w_cq_rst_n_sync),
	.cq_valid_sync						(w_cq_valid_sync),
	.io_cq1_size_sync					(w_io_cq1_size_sync),
	.io_cq2_size_sync					(w_io_cq2_size_sync),
	.io_cq3_size_sync					(w_io_cq3_size_sync),
	.io_cq4_size_sync					(w_io_cq4_size_sync),
	.io_cq5_size_sync					(w_io_cq5_size_sync),
	.io_cq6_size_sync					(w_io_cq6_size_sync),
	.io_cq7_size_sync					(w_io_cq7_size_sync),
	.io_cq8_size_sync					(w_io_cq8_size_sync),
	.io_cq1_bs_addr_sync				(w_io_cq1_bs_addr_sync),
	.io_cq2_bs_addr_sync				(w_io_cq2_bs_addr_sync),
	.io_cq3_bs_addr_sync				(w_io_cq3_bs_addr_sync),
	.io_cq4_bs_addr_sync				(w_io_cq4_bs_addr_sync),
	.io_cq5_bs_addr_sync				(w_io_cq5_bs_addr_sync),
	.io_cq6_bs_addr_sync				(w_io_cq6_bs_addr_sync),
	.io_cq7_bs_addr_sync				(w_io_cq7_bs_addr_sync),
	.io_cq8_bs_addr_sync				(w_io_cq8_bs_addr_sync),
	.io_cq_irq_en_sync					(w_io_cq_irq_en_sync),
	.io_cq1_iv_sync						(w_io_cq1_iv_sync),
	.io_cq2_iv_sync						(w_io_cq2_iv_sync),
	.io_cq3_iv_sync						(w_io_cq3_iv_sync),
	.io_cq4_iv_sync						(w_io_cq4_iv_sync),
	.io_cq5_iv_sync						(w_io_cq5_iv_sync),
	.io_cq6_iv_sync						(w_io_cq6_iv_sync),
	.io_cq7_iv_sync						(w_io_cq7_iv_sync),
	.io_cq8_iv_sync						(w_io_cq8_iv_sync)
);


nvme_pcie # (
	.C_PCIE_DATA_WIDTH						(128)
)
nvme_pcie_inst0(
	.pcie_ref_clk_p							(pcie_ref_clk_p),
	.pcie_ref_clk_n							(pcie_ref_clk_n),

//PCIe user clock
	.pcie_user_clk							(user_clk_out),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.dev_rx_cmd_wr_en						(w_dev_rx_cmd_wr_en),
	.dev_rx_cmd_wr_data						(w_dev_rx_cmd_wr_data),
	.dev_rx_cmd_full_n						(w_dev_rx_cmd_full_n),

	.dev_tx_cmd_wr_en						(w_dev_tx_cmd_wr_en),
	.dev_tx_cmd_wr_data						(w_dev_tx_cmd_wr_data),
	.dev_tx_cmd_full_n						(w_dev_tx_cmd_full_n),

	.cpu_bus_clk							(s0_axi_aclk),
	.cpu_bus_rst_n							(s0_axi_aresetn),

	.nvme_cc_en								(w_nvme_cc_en),
	.nvme_cc_shn							(w_nvme_cc_shn),

	.nvme_csts_shst							(w_nvme_csts_shst_sync),
	.nvme_csts_rdy							(w_nvme_csts_rdy_sync),

	.sq_rst_n								(w_sq_rst_n_sync),
	.sq_valid								(w_sq_valid_sync),
	.io_sq1_size							(w_io_sq1_size_sync),
	.io_sq2_size							(w_io_sq2_size_sync),
	.io_sq3_size							(w_io_sq3_size_sync),
	.io_sq4_size							(w_io_sq4_size_sync),
	.io_sq5_size							(w_io_sq5_size_sync),
	.io_sq6_size							(w_io_sq6_size_sync),
	.io_sq7_size							(w_io_sq7_size_sync),
	.io_sq8_size							(w_io_sq8_size_sync),
	.io_sq1_bs_addr							(w_io_sq1_bs_addr_sync),
	.io_sq2_bs_addr							(w_io_sq2_bs_addr_sync),
	.io_sq3_bs_addr							(w_io_sq3_bs_addr_sync),
	.io_sq4_bs_addr							(w_io_sq4_bs_addr_sync),
	.io_sq5_bs_addr							(w_io_sq5_bs_addr_sync),
	.io_sq6_bs_addr							(w_io_sq6_bs_addr_sync),
	.io_sq7_bs_addr							(w_io_sq7_bs_addr_sync),
	.io_sq8_bs_addr							(w_io_sq8_bs_addr_sync),
	.io_sq1_cq_vec							(w_io_sq1_cq_vec_sync),
	.io_sq2_cq_vec							(w_io_sq2_cq_vec_sync),
	.io_sq3_cq_vec							(w_io_sq3_cq_vec_sync),
	.io_sq4_cq_vec							(w_io_sq4_cq_vec_sync),
	.io_sq5_cq_vec							(w_io_sq5_cq_vec_sync),
	.io_sq6_cq_vec							(w_io_sq6_cq_vec_sync),
	.io_sq7_cq_vec							(w_io_sq7_cq_vec_sync),
	.io_sq8_cq_vec							(w_io_sq8_cq_vec_sync),

	.cq_rst_n								(w_cq_rst_n_sync),
	.cq_valid								(w_cq_valid_sync),
	.io_cq1_size							(w_io_cq1_size_sync),
	.io_cq2_size							(w_io_cq2_size_sync),
	.io_cq3_size							(w_io_cq3_size_sync),
	.io_cq4_size							(w_io_cq4_size_sync),
	.io_cq5_size							(w_io_cq5_size_sync),
	.io_cq6_size							(w_io_cq6_size_sync),
	.io_cq7_size							(w_io_cq7_size_sync),
	.io_cq8_size							(w_io_cq8_size_sync),
	.io_cq1_bs_addr							(w_io_cq1_bs_addr_sync),
	.io_cq2_bs_addr							(w_io_cq2_bs_addr_sync),
	.io_cq3_bs_addr							(w_io_cq3_bs_addr_sync),
	.io_cq4_bs_addr							(w_io_cq4_bs_addr_sync),
	.io_cq5_bs_addr							(w_io_cq5_bs_addr_sync),
	.io_cq6_bs_addr							(w_io_cq6_bs_addr_sync),
	.io_cq7_bs_addr							(w_io_cq7_bs_addr_sync),
	.io_cq8_bs_addr							(w_io_cq8_bs_addr_sync),
	.io_cq_irq_en							(w_io_cq_irq_en_sync),
	.io_cq1_iv								(w_io_cq1_iv_sync),
	.io_cq2_iv								(w_io_cq2_iv_sync),
	.io_cq3_iv								(w_io_cq3_iv_sync),
	.io_cq4_iv								(w_io_cq4_iv_sync),
	.io_cq5_iv								(w_io_cq5_iv_sync),
	.io_cq6_iv								(w_io_cq6_iv_sync),
	.io_cq7_iv								(w_io_cq7_iv_sync),
	.io_cq8_iv								(w_io_cq8_iv_sync),

	.hcmd_sq_rd_en							(w_hcmd_sq_rd_en),
	.hcmd_sq_rd_data						(w_hcmd_sq_rd_data),
	.hcmd_sq_empty_n						(w_hcmd_sq_empty_n),

	.hcmd_table_rd_addr						(w_hcmd_table_rd_addr),
	.hcmd_table_rd_data						(w_hcmd_table_rd_data),

	.hcmd_cq_wr1_en							(w_hcmd_cq_wr1_en),
	.hcmd_cq_wr1_data0						(w_hcmd_cq_wr1_data0),
	.hcmd_cq_wr1_data1						(w_hcmd_cq_wr1_data1),
	.hcmd_cq_wr1_rdy_n						(w_hcmd_cq_wr1_rdy_n),

	.dma_cmd_wr_en							(w_dma_cmd_wr_en),
	.dma_cmd_wr_data0						(w_dma_cmd_wr_data0),
	.dma_cmd_wr_data1						(w_dma_cmd_wr_data1),
	.dma_cmd_wr_rdy_n						(w_dma_cmd_wr_rdy_n),

	.dma_rx_direct_done_cnt					(w_dma_rx_direct_done_cnt),
	.dma_tx_direct_done_cnt					(w_dma_tx_direct_done_cnt),
	.dma_rx_done_cnt						(w_dma_rx_done_cnt),
	.dma_tx_done_cnt						(w_dma_tx_done_cnt),

	.dma_bus_clk							(m0_axi_aclk),
	.dma_bus_rst_n							(m0_axi_aresetn),

	.pcie_rx_fifo_rd_en						(w_pcie_rx_fifo_rd_en),
	.pcie_rx_fifo_rd_data					(w_pcie_rx_fifo_rd_data),
	.pcie_rx_fifo_free_en					(w_pcie_rx_fifo_free_en),
	.pcie_rx_fifo_free_len					(w_pcie_rx_fifo_free_len),
	.pcie_rx_fifo_empty_n					(w_pcie_rx_fifo_empty_n),

	.pcie_tx_fifo_alloc_en					(w_pcie_tx_fifo_alloc_en),
	.pcie_tx_fifo_alloc_len					(w_pcie_tx_fifo_alloc_len),
	.pcie_tx_fifo_wr_en						(w_pcie_tx_fifo_wr_en),
	.pcie_tx_fifo_wr_data					(w_pcie_tx_fifo_wr_data),
	.pcie_tx_fifo_full_n					(w_pcie_tx_fifo_full_n),

	.dma_rx_done_wr_en						(w_dma_rx_done_wr_en),
	.dma_rx_done_wr_data					(w_dma_rx_done_wr_data),
	.dma_rx_done_wr_rdy_n					(w_dma_rx_done_wr_rdy_n),

	.pcie_mreq_err							(w_pcie_mreq_err),
	.pcie_cpld_err							(w_pcie_cpld_err),
	.pcie_cpld_len_err						(w_pcie_cpld_len_err),

	.tx_buf_av								(tx_buf_av),
	.tx_err_drop							(tx_err_drop),
	.tx_cfg_req								(tx_cfg_req),
	.s_axis_tx_tready						(s_axis_tx_tready),
	.s_axis_tx_tdata						(s_axis_tx_tdata),
	.s_axis_tx_tkeep						(s_axis_tx_tkeep),
	.s_axis_tx_tuser						(s_axis_tx_tuser),
	.s_axis_tx_tlast						(s_axis_tx_tlast),
	.s_axis_tx_tvalid						(s_axis_tx_tvalid),
	.tx_cfg_gnt								(tx_cfg_gnt),

	.m_axis_rx_tdata						(m_axis_rx_tdata),
	.m_axis_rx_tkeep						(m_axis_rx_tkeep),
	.m_axis_rx_tlast						(m_axis_rx_tlast),
	.m_axis_rx_tvalid						(m_axis_rx_tvalid),
	.m_axis_rx_tready						(m_axis_rx_tready),
	.m_axis_rx_tuser						(m_axis_rx_tuser),
	.rx_np_ok								(rx_np_ok),
	.rx_np_req								(rx_np_req),

	.fc_cpld								(fc_cpld),
	.fc_cplh								(fc_cplh),
	.fc_npd									(fc_npd),
	.fc_nph									(fc_nph),
	.fc_pd									(fc_pd),
	.fc_ph									(fc_ph),
	.fc_sel									(fc_sel),

	.cfg_interrupt							(cfg_interrupt),
	.cfg_interrupt_rdy						(cfg_interrupt_rdy),
	.cfg_interrupt_assert					(cfg_interrupt_assert),
	.cfg_interrupt_di						(cfg_interrupt_di),
	.cfg_interrupt_do						(cfg_interrupt_do),
	.cfg_interrupt_mmenable					(cfg_interrupt_mmenable),
	.cfg_interrupt_msienable				(cfg_interrupt_msienable),
	.cfg_interrupt_msixenable				(cfg_interrupt_msixenable),
	.cfg_interrupt_msixfm					(cfg_interrupt_msixfm),
	.cfg_interrupt_stat						(cfg_interrupt_stat),
	.cfg_pciecap_interrupt_msgnum			(cfg_pciecap_interrupt_msgnum),

	.cfg_bus_number							(cfg_bus_number),
	.cfg_device_number						(cfg_device_number),
	.cfg_function_number					(cfg_function_number),

	.cfg_to_turnoff							(cfg_to_turnoff),
	.cfg_turnoff_ok							(cfg_turnoff_ok),

	.cfg_command							(cfg_command),
	.cfg_dcommand							(cfg_dcommand),
	.cfg_lcommand							(cfg_lcommand),

	.sys_clk								(sys_clk)

);


endmodule
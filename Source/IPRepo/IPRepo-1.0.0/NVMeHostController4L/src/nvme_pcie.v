
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


module nvme_pcie # (
	parameter	C_PCIE_DATA_WIDTH			= 128,
	parameter	C_PCIE_ADDR_WIDTH			= 36,
	parameter	C_M_AXI_DATA_WIDTH			= 64
)
(
	input									pcie_ref_clk_p,
	input									pcie_ref_clk_n,

//PCIe user clock
	input									pcie_user_clk,
	input									pcie_user_rst_n,

	output									dev_rx_cmd_wr_en,
	output	[29:0]							dev_rx_cmd_wr_data,
	input									dev_rx_cmd_full_n,

	output									dev_tx_cmd_wr_en,
	output	[29:0]							dev_tx_cmd_wr_data,
	input									dev_tx_cmd_full_n,

	input									cpu_bus_clk,
	input									cpu_bus_rst_n,

	output									nvme_cc_en,
	output	[1:0]							nvme_cc_shn,

	input	[1:0]							nvme_csts_shst,
	input									nvme_csts_rdy,

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
	input	[8:0]							io_cq_irq_en,
	input	[2:0]							io_cq1_iv,
	input	[2:0]							io_cq2_iv,
	input	[2:0]							io_cq3_iv,
	input	[2:0]							io_cq4_iv,
	input	[2:0]							io_cq5_iv,
	input	[2:0]							io_cq6_iv,
	input	[2:0]							io_cq7_iv,
	input	[2:0]							io_cq8_iv,

	input									hcmd_sq_rd_en,
	output	[18:0]							hcmd_sq_rd_data,
	output									hcmd_sq_empty_n,

	input	[10:0]							hcmd_table_rd_addr,
	output	[31:0]							hcmd_table_rd_data,

	input									hcmd_cq_wr1_en,
	input	[34:0]							hcmd_cq_wr1_data0,
	input	[34:0]							hcmd_cq_wr1_data1,
	output									hcmd_cq_wr1_rdy_n,

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
	output									dma_rx_done_wr_rdy_n,

	output									pcie_mreq_err,
	output									pcie_cpld_err,
	output									pcie_cpld_len_err,

//PCIe Integrated Block Interface
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

	input	[7:0]							cfg_bus_number,
	input	[4:0]							cfg_device_number,
	input	[2:0]							cfg_function_number,

	input									cfg_to_turnoff,
	output									cfg_turnoff_ok,

	input	[15:0]							cfg_command,
	input	[15:0]							cfg_dcommand,
	input	[15:0]							cfg_lcommand,

	output									sys_clk

);

wire										w_nvme_intms_ivms;
wire										w_nvme_intmc_ivmc;
wire										w_cq_irq_status;

wire	[7:0]								w_hcmd_prp_rd_addr;
wire	[44:0]								w_hcmd_prp_rd_data;

wire										w_hcmd_nlb_wr1_en;
wire	[6:0]								w_hcmd_nlb_wr1_addr;
wire	[18:0]								w_hcmd_nlb_wr1_data;
wire										w_hcmd_nlb_wr1_rdy_n;

wire	[6:0]								w_hcmd_nlb_rd_addr;
wire	[18:0]								w_hcmd_nlb_rd_data;

wire										w_hcmd_cq_wr0_en;
wire	[34:0]								w_hcmd_cq_wr0_data0;
wire	[34:0]								w_hcmd_cq_wr0_data1;
wire										w_hcmd_cq_wr0_rdy_n;

wire										w_mreq_fifo_wr_en;
wire	[C_PCIE_DATA_WIDTH-1:0]				w_mreq_fifo_wr_data;

wire	[7:0]								w_cpld0_fifo_tag;
wire										w_cpld0_fifo_tag_last;
wire										w_cpld0_fifo_wr_en;
wire	[C_PCIE_DATA_WIDTH-1:0]				w_cpld0_fifo_wr_data;

wire	[7:0]								w_cpld1_fifo_tag;
wire										w_cpld1_fifo_tag_last;
wire										w_cpld1_fifo_wr_en;
wire	[C_PCIE_DATA_WIDTH-1:0]				w_cpld1_fifo_wr_data;

wire	[7:0]								w_cpld2_fifo_tag;
wire										w_cpld2_fifo_tag_last;
wire										w_cpld2_fifo_wr_en;
wire	[C_PCIE_DATA_WIDTH-1:0]				w_cpld2_fifo_wr_data;

wire										w_tx_cpld_req;
wire	[7:0]								w_tx_cpld_tag;
wire	[15:0]								w_tx_cpld_req_id;
wire	[11:2]								w_tx_cpld_len;
wire	[11:0]								w_tx_cpld_bc;
wire	[6:0]								w_tx_cpld_laddr;
wire	[63:0]								w_tx_cpld_data;
wire										w_tx_cpld_req_ack;

wire										w_tx_mrd0_req;
wire	[7:0]								w_tx_mrd0_tag;
wire	[11:2]								w_tx_mrd0_len;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_tx_mrd0_addr;
wire										w_tx_mrd0_req_ack;

wire										w_tx_mrd1_req;
wire	[7:0]								w_tx_mrd1_tag;
wire	[11:2]								w_tx_mrd1_len;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_tx_mrd1_addr;
wire										w_tx_mrd1_req_ack;

wire										w_tx_mrd2_req;
wire	[7:0]								w_tx_mrd2_tag;
wire	[11:2]								w_tx_mrd2_len;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_tx_mrd2_addr;
wire										w_tx_mrd2_req_ack;

wire										w_tx_mwr0_req;
wire	[7:0]								w_tx_mwr0_tag;
wire	[11:2]								w_tx_mwr0_len;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_tx_mwr0_addr;
wire										w_tx_mwr0_req_ack;
wire										w_tx_mwr0_rd_en;
wire	[C_PCIE_DATA_WIDTH-1 : 0]			w_tx_mwr0_rd_data;
wire										w_tx_mwr0_data_last;

wire										w_tx_mwr1_req;
wire	[7:0]								w_tx_mwr1_tag;
wire	[11:2]								w_tx_mwr1_len;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_tx_mwr1_addr;
wire										w_tx_mwr1_req_ack;
wire										w_tx_mwr1_rd_en;
wire	[C_PCIE_DATA_WIDTH-1:0]				w_tx_mwr1_rd_data;
wire										w_tx_mwr1_data_last;

wire	[C_PCIE_ADDR_WIDTH-1:2]				w_admin_sq_bs_addr;
wire	[C_PCIE_ADDR_WIDTH-1:2]				w_admin_cq_bs_addr;
wire	[7:0]								w_admin_sq_size;
wire	[7:0]								w_admin_cq_size;

wire	[7:0]								w_admin_sq_tail_ptr;
wire	[7:0]								w_io_sq1_tail_ptr;
wire	[7:0]								w_io_sq2_tail_ptr;
wire	[7:0]								w_io_sq3_tail_ptr;
wire	[7:0]								w_io_sq4_tail_ptr;
wire	[7:0]								w_io_sq5_tail_ptr;
wire	[7:0]								w_io_sq6_tail_ptr;
wire	[7:0]								w_io_sq7_tail_ptr;
wire	[7:0]								w_io_sq8_tail_ptr;

wire	[7:0]								w_admin_cq_tail_ptr;
wire	[7:0]								w_io_cq1_tail_ptr;
wire	[7:0]								w_io_cq2_tail_ptr;
wire	[7:0]								w_io_cq3_tail_ptr;
wire	[7:0]								w_io_cq4_tail_ptr;
wire	[7:0]								w_io_cq5_tail_ptr;
wire	[7:0]								w_io_cq6_tail_ptr;
wire	[7:0]								w_io_cq7_tail_ptr;
wire	[7:0]								w_io_cq8_tail_ptr;

wire	[7:0]								w_admin_cq_head_ptr;
wire	[7:0]								w_io_cq1_head_ptr;
wire	[7:0]								w_io_cq2_head_ptr;
wire	[7:0]								w_io_cq3_head_ptr;
wire	[7:0]								w_io_cq4_head_ptr;
wire	[7:0]								w_io_cq5_head_ptr;
wire	[7:0]								w_io_cq6_head_ptr;
wire	[7:0]								w_io_cq7_head_ptr;
wire	[7:0]								w_io_cq8_head_ptr;
wire	[8:0]								w_cq_head_update;

reg											r_cfg_turnoff_ok;


IBUFDS_GTE2 pcie_ref_clk_ibuf (.O(sys_clk), .ODIV2(), .I(pcie_ref_clk_p), .CEB(1'b0), .IB(pcie_ref_clk_n));

assign cfg_turnoff_ok = r_cfg_turnoff_ok;

always @(posedge pcie_user_clk) begin
	r_cfg_turnoff_ok <= cfg_to_turnoff;
end

pcie_cntl_slave # (
	.C_PCIE_DATA_WIDTH						(C_PCIE_DATA_WIDTH)
)
pcie_cntl_slave_inst0(

	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.rx_np_ok								(rx_np_ok),
	.rx_np_req								(rx_np_req),

	.mreq_fifo_wr_en						(w_mreq_fifo_wr_en),
	.mreq_fifo_wr_data						(w_mreq_fifo_wr_data),

	.tx_cpld_req							(w_tx_cpld_req),
	.tx_cpld_tag							(w_tx_cpld_tag),
	.tx_cpld_req_id							(w_tx_cpld_req_id),
	.tx_cpld_len							(w_tx_cpld_len),
	.tx_cpld_bc								(w_tx_cpld_bc),
	.tx_cpld_laddr							(w_tx_cpld_laddr),
	.tx_cpld_data							(w_tx_cpld_data),
	.tx_cpld_req_ack						(w_tx_cpld_req_ack),

	.nvme_cc_en								(nvme_cc_en),
	.nvme_cc_shn							(nvme_cc_shn),

	.nvme_csts_shst							(nvme_csts_shst),
	.nvme_csts_rdy							(nvme_csts_rdy),

	.nvme_intms_ivms						(w_nvme_intms_ivms),
	.nvme_intmc_ivmc						(w_nvme_intmc_ivmc),
	.cq_irq_status							(w_cq_irq_status),

	.sq_rst_n								(sq_rst_n),
	.cq_rst_n								(cq_rst_n),
	.admin_sq_bs_addr						(w_admin_sq_bs_addr),
	.admin_cq_bs_addr						(w_admin_cq_bs_addr),
	.admin_sq_size							(w_admin_sq_size),
	.admin_cq_size							(w_admin_cq_size),

	.admin_sq_tail_ptr						(w_admin_sq_tail_ptr),
	.io_sq1_tail_ptr						(w_io_sq1_tail_ptr),
	.io_sq2_tail_ptr						(w_io_sq2_tail_ptr),
	.io_sq3_tail_ptr						(w_io_sq3_tail_ptr),
	.io_sq4_tail_ptr						(w_io_sq4_tail_ptr),
	.io_sq5_tail_ptr						(w_io_sq5_tail_ptr),
	.io_sq6_tail_ptr						(w_io_sq6_tail_ptr),
	.io_sq7_tail_ptr						(w_io_sq7_tail_ptr),
	.io_sq8_tail_ptr						(w_io_sq8_tail_ptr),

	.admin_cq_head_ptr						(w_admin_cq_head_ptr),
	.io_cq1_head_ptr						(w_io_cq1_head_ptr),
	.io_cq2_head_ptr						(w_io_cq2_head_ptr),
	.io_cq3_head_ptr						(w_io_cq3_head_ptr),
	.io_cq4_head_ptr						(w_io_cq4_head_ptr),
	.io_cq5_head_ptr						(w_io_cq5_head_ptr),
	.io_cq6_head_ptr						(w_io_cq6_head_ptr),
	.io_cq7_head_ptr						(w_io_cq7_head_ptr),
	.io_cq8_head_ptr						(w_io_cq8_head_ptr),
	.cq_head_update							(w_cq_head_update)
);

pcie_hcmd # (
	.C_PCIE_DATA_WIDTH						(C_PCIE_DATA_WIDTH)
)
pcie_hcmd_inst0(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.admin_sq_bs_addr						(w_admin_sq_bs_addr),
	.admin_cq_bs_addr						(w_admin_cq_bs_addr),
	.admin_sq_size							(w_admin_sq_size),
	.admin_cq_size							(w_admin_cq_size),

	.admin_sq_tail_ptr						(w_admin_sq_tail_ptr),
	.io_sq1_tail_ptr						(w_io_sq1_tail_ptr),
	.io_sq2_tail_ptr						(w_io_sq2_tail_ptr),
	.io_sq3_tail_ptr						(w_io_sq3_tail_ptr),
	.io_sq4_tail_ptr						(w_io_sq4_tail_ptr),
	.io_sq5_tail_ptr						(w_io_sq5_tail_ptr),
	.io_sq6_tail_ptr						(w_io_sq6_tail_ptr),
	.io_sq7_tail_ptr						(w_io_sq7_tail_ptr),
	.io_sq8_tail_ptr						(w_io_sq8_tail_ptr),

	.cpld_sq_fifo_tag						(w_cpld0_fifo_tag),
	.cpld_sq_fifo_wr_data					(w_cpld0_fifo_wr_data),
	.cpld_sq_fifo_wr_en						(w_cpld0_fifo_wr_en),
	.cpld_sq_fifo_tag_last					(w_cpld0_fifo_tag_last),


	.tx_mrd_req								(w_tx_mrd0_req),
	.tx_mrd_tag								(w_tx_mrd0_tag),
	.tx_mrd_len								(w_tx_mrd0_len),
	.tx_mrd_addr							(w_tx_mrd0_addr),
	.tx_mrd_req_ack							(w_tx_mrd0_req_ack),

	.admin_cq_tail_ptr						(w_admin_cq_tail_ptr),
	.io_cq1_tail_ptr						(w_io_cq1_tail_ptr),
	.io_cq2_tail_ptr						(w_io_cq2_tail_ptr),
	.io_cq3_tail_ptr						(w_io_cq3_tail_ptr),
	.io_cq4_tail_ptr						(w_io_cq4_tail_ptr),
	.io_cq5_tail_ptr						(w_io_cq5_tail_ptr),
	.io_cq6_tail_ptr						(w_io_cq6_tail_ptr),
	.io_cq7_tail_ptr						(w_io_cq7_tail_ptr),
	.io_cq8_tail_ptr						(w_io_cq8_tail_ptr),

	.tx_cq_mwr_req							(w_tx_mwr0_req),
	.tx_cq_mwr_tag							(w_tx_mwr0_tag),
	.tx_cq_mwr_len							(w_tx_mwr0_len),
	.tx_cq_mwr_addr							(w_tx_mwr0_addr),
	.tx_cq_mwr_req_ack						(w_tx_mwr0_req_ack),
	.tx_cq_mwr_rd_en						(w_tx_mwr0_rd_en),
	.tx_cq_mwr_rd_data						(w_tx_mwr0_rd_data),
	.tx_cq_mwr_data_last					(w_tx_mwr0_data_last),

	.hcmd_prp_rd_addr						(w_hcmd_prp_rd_addr),
	.hcmd_prp_rd_data						(w_hcmd_prp_rd_data),

	.hcmd_nlb_wr1_en						(w_hcmd_nlb_wr1_en),
	.hcmd_nlb_wr1_addr						(w_hcmd_nlb_wr1_addr),
	.hcmd_nlb_wr1_data						(w_hcmd_nlb_wr1_data),
	.hcmd_nlb_wr1_rdy_n						(w_hcmd_nlb_wr1_rdy_n),

	.hcmd_nlb_rd_addr						(w_hcmd_nlb_rd_addr),
	.hcmd_nlb_rd_data						(w_hcmd_nlb_rd_data),

	.hcmd_cq_wr0_en							(w_hcmd_cq_wr0_en),
	.hcmd_cq_wr0_data0						(w_hcmd_cq_wr0_data0),
	.hcmd_cq_wr0_data1						(w_hcmd_cq_wr0_data1),
	.hcmd_cq_wr0_rdy_n						(w_hcmd_cq_wr0_rdy_n),

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
	.io_sq1_cq_vec							(io_sq1_cq_vec),
	.io_sq2_cq_vec							(io_sq2_cq_vec),
	.io_sq3_cq_vec							(io_sq3_cq_vec),
	.io_sq4_cq_vec							(io_sq4_cq_vec),
	.io_sq5_cq_vec							(io_sq5_cq_vec),
	.io_sq6_cq_vec							(io_sq6_cq_vec),
	.io_sq7_cq_vec							(io_sq7_cq_vec),
	.io_sq8_cq_vec							(io_sq8_cq_vec),

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

	.hcmd_sq_rd_en							(hcmd_sq_rd_en),
	.hcmd_sq_rd_data						(hcmd_sq_rd_data),
	.hcmd_sq_empty_n						(hcmd_sq_empty_n),

	.hcmd_table_rd_addr						(hcmd_table_rd_addr),
	.hcmd_table_rd_data						(hcmd_table_rd_data),

	.hcmd_cq_wr1_en							(hcmd_cq_wr1_en),
	.hcmd_cq_wr1_data0						(hcmd_cq_wr1_data0),
	.hcmd_cq_wr1_data1						(hcmd_cq_wr1_data1),
	.hcmd_cq_wr1_rdy_n						(hcmd_cq_wr1_rdy_n)
);


dma_if
dma_if_inst0
(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.pcie_max_payload_size					(cfg_dcommand[7:5]),
	.pcie_max_read_req_size					(cfg_dcommand[14:12]),
	.pcie_rcb								(cfg_lcommand[3]),

	.hcmd_prp_rd_addr						(w_hcmd_prp_rd_addr),
	.hcmd_prp_rd_data						(w_hcmd_prp_rd_data),

	.hcmd_nlb_wr1_en						(w_hcmd_nlb_wr1_en),
	.hcmd_nlb_wr1_addr						(w_hcmd_nlb_wr1_addr),
	.hcmd_nlb_wr1_data						(w_hcmd_nlb_wr1_data),
	.hcmd_nlb_wr1_rdy_n						(w_hcmd_nlb_wr1_rdy_n),

	.hcmd_nlb_rd_addr						(w_hcmd_nlb_rd_addr),
	.hcmd_nlb_rd_data						(w_hcmd_nlb_rd_data),

	.dev_rx_cmd_wr_en						(dev_rx_cmd_wr_en),
	.dev_rx_cmd_wr_data						(dev_rx_cmd_wr_data),
	.dev_rx_cmd_full_n						(dev_rx_cmd_full_n),

	.dev_tx_cmd_wr_en						(dev_tx_cmd_wr_en),
	.dev_tx_cmd_wr_data						(dev_tx_cmd_wr_data),
	.dev_tx_cmd_full_n						(dev_tx_cmd_full_n),

	.tx_prp_mrd_req							(w_tx_mrd1_req),
	.tx_prp_mrd_tag							(w_tx_mrd1_tag),
	.tx_prp_mrd_len							(w_tx_mrd1_len),
	.tx_prp_mrd_addr						(w_tx_mrd1_addr),
	.tx_prp_mrd_req_ack						(w_tx_mrd1_req_ack),

	.cpld_prp_fifo_tag						(w_cpld1_fifo_tag),
	.cpld_prp_fifo_wr_data					(w_cpld1_fifo_wr_data),
	.cpld_prp_fifo_wr_en					(w_cpld1_fifo_wr_en),
	.cpld_prp_fifo_tag_last					(w_cpld1_fifo_tag_last),

	.tx_dma_mrd_req							(w_tx_mrd2_req),
	.tx_dma_mrd_tag							(w_tx_mrd2_tag),
	.tx_dma_mrd_len							(w_tx_mrd2_len),
	.tx_dma_mrd_addr						(w_tx_mrd2_addr),
	.tx_dma_mrd_req_ack						(w_tx_mrd2_req_ack),

	.cpld_dma_fifo_tag						(w_cpld2_fifo_tag),
	.cpld_dma_fifo_wr_data					(w_cpld2_fifo_wr_data),
	.cpld_dma_fifo_wr_en					(w_cpld2_fifo_wr_en),
	.cpld_dma_fifo_tag_last					(w_cpld2_fifo_tag_last),

	.tx_dma_mwr_req							(w_tx_mwr1_req),
	.tx_dma_mwr_tag							(w_tx_mwr1_tag),
	.tx_dma_mwr_len							(w_tx_mwr1_len),
	.tx_dma_mwr_addr						(w_tx_mwr1_addr),
	.tx_dma_mwr_req_ack						(w_tx_mwr1_req_ack),
	.tx_dma_mwr_data_last					(w_tx_mwr1_data_last),

	.pcie_tx_dma_fifo_rd_en					(w_tx_mwr1_rd_en),
	.pcie_tx_dma_fifo_rd_data				(w_tx_mwr1_rd_data),

	.hcmd_cq_wr0_en							(w_hcmd_cq_wr0_en),
	.hcmd_cq_wr0_data0						(w_hcmd_cq_wr0_data0),
	.hcmd_cq_wr0_data1						(w_hcmd_cq_wr0_data1),
	.hcmd_cq_wr0_rdy_n						(w_hcmd_cq_wr0_rdy_n),


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
	.dma_rx_done_wr_rdy_n					(dma_rx_done_wr_rdy_n)
);

pcie_tans_if # (
	.C_PCIE_DATA_WIDTH						(C_PCIE_DATA_WIDTH)
)
pcie_tans_if_inst0(

//PCIe user clock
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

//pcie rx signal
	.mreq_fifo_wr_en						(w_mreq_fifo_wr_en),
	.mreq_fifo_wr_data						(w_mreq_fifo_wr_data),

	.cpld0_fifo_tag							(w_cpld0_fifo_tag),
	.cpld0_fifo_tag_last					(w_cpld0_fifo_tag_last),
	.cpld0_fifo_wr_en						(w_cpld0_fifo_wr_en),
	.cpld0_fifo_wr_data						(w_cpld0_fifo_wr_data),

	.cpld1_fifo_tag							(w_cpld1_fifo_tag),
	.cpld1_fifo_tag_last					(w_cpld1_fifo_tag_last),
	.cpld1_fifo_wr_en						(w_cpld1_fifo_wr_en),
	.cpld1_fifo_wr_data						(w_cpld1_fifo_wr_data),

	.cpld2_fifo_tag							(w_cpld2_fifo_tag),
	.cpld2_fifo_tag_last					(w_cpld2_fifo_tag_last),
	.cpld2_fifo_wr_en						(w_cpld2_fifo_wr_en),
	.cpld2_fifo_wr_data						(w_cpld2_fifo_wr_data),

	.tx_cpld_req							(w_tx_cpld_req),
	.tx_cpld_tag							(w_tx_cpld_tag),
	.tx_cpld_req_id							(w_tx_cpld_req_id),
	.tx_cpld_len							(w_tx_cpld_len),
	.tx_cpld_bc								(w_tx_cpld_bc),
	.tx_cpld_laddr							(w_tx_cpld_laddr),
	.tx_cpld_data							(w_tx_cpld_data),
	.tx_cpld_req_ack						(w_tx_cpld_req_ack),

	.tx_mrd0_req							(w_tx_mrd0_req),
	.tx_mrd0_tag							(w_tx_mrd0_tag),
	.tx_mrd0_len							(w_tx_mrd0_len),
	.tx_mrd0_addr							(w_tx_mrd0_addr),
	.tx_mrd0_req_ack						(w_tx_mrd0_req_ack),

	.tx_mrd1_req							(w_tx_mrd1_req),
	.tx_mrd1_tag							(w_tx_mrd1_tag),
	.tx_mrd1_len							(w_tx_mrd1_len),
	.tx_mrd1_addr							(w_tx_mrd1_addr),
	.tx_mrd1_req_ack						(w_tx_mrd1_req_ack),

	.tx_mrd2_req							(w_tx_mrd2_req),
	.tx_mrd2_tag							(w_tx_mrd2_tag),
	.tx_mrd2_len							(w_tx_mrd2_len),
	.tx_mrd2_addr							(w_tx_mrd2_addr),
	.tx_mrd2_req_ack						(w_tx_mrd2_req_ack),

	.tx_mwr0_req							(w_tx_mwr0_req),
	.tx_mwr0_tag							(w_tx_mwr0_tag),
	.tx_mwr0_len							(w_tx_mwr0_len),
	.tx_mwr0_addr							(w_tx_mwr0_addr),
	.tx_mwr0_req_ack						(w_tx_mwr0_req_ack),
	.tx_mwr0_rd_en							(w_tx_mwr0_rd_en),
	.tx_mwr0_rd_data						(w_tx_mwr0_rd_data),
	.tx_mwr0_data_last						(w_tx_mwr0_data_last),

	.tx_mwr1_req							(w_tx_mwr1_req),
	.tx_mwr1_tag							(w_tx_mwr1_tag),
	.tx_mwr1_len							(w_tx_mwr1_len),
	.tx_mwr1_addr							(w_tx_mwr1_addr),
	.tx_mwr1_req_ack						(w_tx_mwr1_req_ack),
	.tx_mwr1_rd_en							(w_tx_mwr1_rd_en),
	.tx_mwr1_rd_data						(w_tx_mwr1_rd_data),
	.tx_mwr1_data_last						(w_tx_mwr1_data_last),

	.pcie_mreq_err							(pcie_mreq_err),
	.pcie_cpld_err							(pcie_cpld_err),
	.pcie_cpld_len_err						(pcie_cpld_len_err),

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

	.fc_cpld								(fc_cpld),
	.fc_cplh								(fc_cplh),
	.fc_npd									(fc_npd),
	.fc_nph									(fc_nph),
	.fc_pd									(fc_pd),
	.fc_ph									(fc_ph),
	.fc_sel									(fc_sel),

	.cfg_bus_number							(cfg_bus_number),
	.cfg_device_number						(cfg_device_number),
	.cfg_function_number					(cfg_function_number)
);

nvme_irq
nvme_irq_inst0
(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.cfg_command							(cfg_command),
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

	.nvme_intms_ivms						(w_nvme_intms_ivms),
	.nvme_intmc_ivmc						(w_nvme_intmc_ivmc),
	.cq_irq_status							(w_cq_irq_status),

	.cq_rst_n								(cq_rst_n),
	.cq_valid								(cq_valid),
	.io_cq_irq_en							(io_cq_irq_en),
	.io_cq1_iv								(io_cq1_iv),
	.io_cq2_iv								(io_cq2_iv),
	.io_cq3_iv								(io_cq3_iv),
	.io_cq4_iv								(io_cq4_iv),
	.io_cq5_iv								(io_cq5_iv),
	.io_cq6_iv								(io_cq6_iv),
	.io_cq7_iv								(io_cq7_iv),
	.io_cq8_iv								(io_cq8_iv),

	.admin_cq_tail_ptr						(w_admin_cq_tail_ptr),
	.io_cq1_tail_ptr						(w_io_cq1_tail_ptr),
	.io_cq2_tail_ptr						(w_io_cq2_tail_ptr),
	.io_cq3_tail_ptr						(w_io_cq3_tail_ptr),
	.io_cq4_tail_ptr						(w_io_cq4_tail_ptr),
	.io_cq5_tail_ptr						(w_io_cq5_tail_ptr),
	.io_cq6_tail_ptr						(w_io_cq6_tail_ptr),
	.io_cq7_tail_ptr						(w_io_cq7_tail_ptr),
	.io_cq8_tail_ptr						(w_io_cq8_tail_ptr),

	.admin_cq_head_ptr						(w_admin_cq_head_ptr),
	.io_cq1_head_ptr						(w_io_cq1_head_ptr),
	.io_cq2_head_ptr						(w_io_cq2_head_ptr),
	.io_cq3_head_ptr						(w_io_cq3_head_ptr),
	.io_cq4_head_ptr						(w_io_cq4_head_ptr),
	.io_cq5_head_ptr						(w_io_cq5_head_ptr),
	.io_cq6_head_ptr						(w_io_cq6_head_ptr),
	.io_cq7_head_ptr						(w_io_cq7_head_ptr),
	.io_cq8_head_ptr						(w_io_cq8_head_ptr),
	.cq_head_update							(w_cq_head_update)
);

endmodule

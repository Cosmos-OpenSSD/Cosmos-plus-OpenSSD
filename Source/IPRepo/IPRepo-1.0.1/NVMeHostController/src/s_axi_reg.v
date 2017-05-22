
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

`include	"def_axi.vh"

module s_axi_reg # (
	parameter	C_S_AXI_ADDR_WIDTH			= 32,
	parameter	C_S_AXI_DATA_WIDTH			= 32,
	parameter	C_S_AXI_BASEADDR			= 32'h80000000,
	parameter	C_S_AXI_HIGHADDR			= 32'h80010000,
	parameter	C_PCIE_ADDR_WIDTH			= 36
)
(
////////////////////////////////////////////////////////////////
//AXI4-lite slave interface signals
	input									s_axi_aclk,
	input									s_axi_aresetn,

//Write address channel
	input									s_axi_awvalid,
	output									s_axi_awready,
	input	[C_S_AXI_ADDR_WIDTH-1:0]		s_axi_awaddr,
	input	[2:0]							s_axi_awprot,

//Write data channel
	input									s_axi_wvalid,
	output									s_axi_wready,
	input	[C_S_AXI_DATA_WIDTH-1:0]		s_axi_wdata,
	input	[(C_S_AXI_DATA_WIDTH/8)-1:0]	s_axi_wstrb,

//Write response channel
	output									s_axi_bvalid,
	input									s_axi_bready,
	output	[1:0]							s_axi_bresp,

//Read address channel
	input									s_axi_arvalid,
	output									s_axi_arready,
	input	[C_S_AXI_ADDR_WIDTH-1:0]		s_axi_araddr,
	input	[2:0]							s_axi_arprot,

//Read data channel
	output									s_axi_rvalid,
	input									s_axi_rready,
	output	[C_S_AXI_DATA_WIDTH-1:0]		s_axi_rdata,
	output	[1:0]							s_axi_rresp,

	input									pcie_mreq_err,
	input									pcie_cpld_err,
	input									pcie_cpld_len_err,

	input									m0_axi_bresp_err,
	input									m0_axi_rresp_err,

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

localparam	S_WR_IDLE						= 8'b00000001;
localparam	S_AW_VAILD						= 8'b00000010;
localparam	S_W_READY						= 8'b00000100;
localparam	S_B_VALID						= 8'b00001000;
localparam	S_WAIT_CQ_RDY					= 8'b00010000;
localparam	S_WR_CQ							= 8'b00100000;
localparam	S_WAIT_DMA_RDY					= 8'b01000000;
localparam	S_WR_DMA						= 8'b10000000;

reg		[7:0]								cur_wr_state;
reg		[7:0]								next_wr_state;

localparam	S_RD_IDLE						= 5'b00001;
localparam	S_AR_VAILD						= 5'b00010;
localparam	S_AR_REG						= 5'b00100;
localparam	S_BRAM_READ						= 5'b01000;
localparam	S_R_READY						= 5'b10000;

reg		[4:0]								cur_rd_state;
reg		[4:0]								next_rd_state;

reg											r_s_axi_awready;
reg		[15:2]								r_s_axi_awaddr;
reg											r_s_axi_wready;
reg											r_s_axi_bvalid;
reg		[1:0]								r_s_axi_bresp;
reg											r_s_axi_arready;
reg		[15:2]								r_s_axi_araddr;
reg											r_s_axi_rvalid;
reg		[C_S_AXI_DATA_WIDTH-1:0]			r_s_axi_rdata;
reg		[1:0]								r_s_axi_rresp;

reg											r_irq_assert;
reg		[11:0]								r_irq_req;
reg		[11:0]								r_irq_mask;
reg		[11:0]								r_irq_clear;
reg		[11:0]								r_irq_set;

reg											r_pcie_user_logic_rst;

reg		[1:0]								r_nvme_csts_shst;
reg											r_nvme_csts_rdy;

reg		[8:0]								r_sq_valid;
reg		[7:0]								r_io_sq1_size;
reg		[7:0]								r_io_sq2_size;
reg		[7:0]								r_io_sq3_size;
reg		[7:0]								r_io_sq4_size;
reg		[7:0]								r_io_sq5_size;
reg		[7:0]								r_io_sq6_size;
reg		[7:0]								r_io_sq7_size;
reg		[7:0]								r_io_sq8_size;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_io_sq1_bs_addr;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_io_sq2_bs_addr;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_io_sq3_bs_addr;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_io_sq4_bs_addr;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_io_sq5_bs_addr;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_io_sq6_bs_addr;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_io_sq7_bs_addr;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_io_sq8_bs_addr;
reg		[3:0]								r_io_sq1_cq_vec;
reg		[3:0]								r_io_sq2_cq_vec;
reg		[3:0]								r_io_sq3_cq_vec;
reg		[3:0]								r_io_sq4_cq_vec;
reg		[3:0]								r_io_sq5_cq_vec;
reg		[3:0]								r_io_sq6_cq_vec;
reg		[3:0]								r_io_sq7_cq_vec;
reg		[3:0]								r_io_sq8_cq_vec;

reg		[8:0]								r_cq_valid;
reg		[7:0]								r_io_cq1_size;
reg		[7:0]								r_io_cq2_size;
reg		[7:0]								r_io_cq3_size;
reg		[7:0]								r_io_cq4_size;
reg		[7:0]								r_io_cq5_size;
reg		[7:0]								r_io_cq6_size;
reg		[7:0]								r_io_cq7_size;
reg		[7:0]								r_io_cq8_size;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_io_cq1_bs_addr;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_io_cq2_bs_addr;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_io_cq3_bs_addr;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_io_cq4_bs_addr;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_io_cq5_bs_addr;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_io_cq6_bs_addr;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_io_cq7_bs_addr;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_io_cq8_bs_addr;
reg		[8:0]								r_io_cq_irq_en;
reg		[2:0]								r_io_cq1_iv;
reg		[2:0]								r_io_cq2_iv;
reg		[2:0]								r_io_cq3_iv;
reg		[2:0]								r_io_cq4_iv;
reg		[2:0]								r_io_cq5_iv;
reg		[2:0]								r_io_cq6_iv;
reg		[2:0]								r_io_cq7_iv;
reg		[2:0]								r_io_cq8_iv;

reg		[1:0]								r_cql_type;
reg		[3:0]								r_cpl_sq_qid;
reg		[15:0]								r_cpl_cid;
reg		[6:0]								r_hcmd_slot_tag;
reg		[14:0]								r_cpl_status;
reg		[31:0]								r_cpl_specific;

reg											r_dma_cmd_type;
reg											r_dma_cmd_dir;
reg		[6:0]								r_dma_cmd_hcmd_slot_tag;
reg		[31:2]								r_dma_cmd_dev_addr;
reg		[12:2]								r_dma_cmd_dev_len;
reg		[8:0]								r_dma_cmd_4k_offset;
reg		[C_PCIE_ADDR_WIDTH-1:2]				r_dma_cmd_pcie_addr;

reg											r_hcmd_cq_wr1_en;
reg											r_dma_cmd_wr_en;
reg											r_hcmd_sq_rd_en;

reg		[31:0]								r_wdata;
reg											r_awaddr_cntl_reg_en;
//reg											r_awaddr_pcie_reg_en;
reg											r_awaddr_nvme_reg_en;
reg											r_awaddr_nvme_fifo_en;
reg											r_awaddr_hcmd_cq_wr1_en;
reg											r_awaddr_dma_cmd_wr_en;
reg											r_cntl_reg_en;
//reg											r_pcie_reg_en;
reg											r_nvme_reg_en;
reg											r_nvme_fifo_en;


reg		[31:0]								r_rdata;
reg											r_araddr_cntl_reg_en;
reg											r_araddr_pcie_reg_en;
reg											r_araddr_nvme_reg_en;
reg											r_araddr_nvme_fifo_en;
reg											r_araddr_hcmd_table_rd_en;
reg											r_araddr_hcmd_sq_rd_en;
reg		[31:0]								r_cntl_reg_rdata;
reg		[31:0]								r_pcie_reg_rdata;
reg		[31:0]								r_nvme_reg_rdata;
reg		[31:0]								r_nvme_fifo_rdata;

reg											r_pcie_link_up;
reg		[15:0]								r_cfg_command;
reg		[2:0]								r_cfg_interrupt_mmenable;
reg											r_cfg_interrupt_msienable;
reg											r_cfg_interrupt_msixenable;

reg											r_nvme_cc_en;
reg		[1:0]								r_nvme_cc_shn;

(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg										r_m0_axi_bresp_err;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg										r_m0_axi_bresp_err_d1;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg										r_m0_axi_bresp_err_d2;

(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg										r_m0_axi_rresp_err;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg										r_m0_axi_rresp_err_d1;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg										r_m0_axi_rresp_err_d2;

reg											r_pcie_mreq_err;
reg											r_pcie_cpld_err;
reg											r_pcie_cpld_len_err;

assign s_axi_awready = r_s_axi_awready;
assign s_axi_wready = r_s_axi_wready;
assign s_axi_bvalid = r_s_axi_bvalid;
assign s_axi_bresp = r_s_axi_bresp;
assign s_axi_arready = r_s_axi_arready;
assign s_axi_rvalid = r_s_axi_rvalid;
assign s_axi_rdata = r_s_axi_rdata;
assign s_axi_rresp = r_s_axi_rresp;

assign dev_irq_assert = r_irq_assert;

assign sq_valid = r_sq_valid;
assign io_sq1_size = r_io_sq1_size;
assign io_sq2_size = r_io_sq2_size;
assign io_sq3_size = r_io_sq3_size;
assign io_sq4_size = r_io_sq4_size;
assign io_sq5_size = r_io_sq5_size;
assign io_sq6_size = r_io_sq6_size;
assign io_sq7_size = r_io_sq7_size;
assign io_sq8_size = r_io_sq8_size;
assign io_sq1_bs_addr = r_io_sq1_bs_addr;
assign io_sq2_bs_addr = r_io_sq2_bs_addr;
assign io_sq3_bs_addr = r_io_sq3_bs_addr;
assign io_sq4_bs_addr = r_io_sq4_bs_addr;
assign io_sq5_bs_addr = r_io_sq5_bs_addr;
assign io_sq6_bs_addr = r_io_sq6_bs_addr;
assign io_sq7_bs_addr = r_io_sq7_bs_addr;
assign io_sq8_bs_addr = r_io_sq8_bs_addr;
assign io_sq1_cq_vec = r_io_sq1_cq_vec;
assign io_sq2_cq_vec = r_io_sq2_cq_vec;
assign io_sq3_cq_vec = r_io_sq3_cq_vec;
assign io_sq4_cq_vec = r_io_sq4_cq_vec;
assign io_sq5_cq_vec = r_io_sq5_cq_vec;
assign io_sq6_cq_vec = r_io_sq6_cq_vec;
assign io_sq7_cq_vec = r_io_sq7_cq_vec;
assign io_sq8_cq_vec = r_io_sq8_cq_vec;

assign cq_valid = r_cq_valid;
assign io_cq1_size = r_io_cq1_size;
assign io_cq2_size = r_io_cq2_size;
assign io_cq3_size = r_io_cq3_size;
assign io_cq4_size = r_io_cq4_size;
assign io_cq5_size = r_io_cq5_size;
assign io_cq6_size = r_io_cq6_size;
assign io_cq7_size = r_io_cq7_size;
assign io_cq8_size = r_io_cq8_size;
assign io_cq1_bs_addr = r_io_cq1_bs_addr;
assign io_cq2_bs_addr = r_io_cq2_bs_addr;
assign io_cq3_bs_addr = r_io_cq3_bs_addr;
assign io_cq4_bs_addr = r_io_cq4_bs_addr;
assign io_cq5_bs_addr = r_io_cq5_bs_addr;
assign io_cq6_bs_addr = r_io_cq6_bs_addr;
assign io_cq7_bs_addr = r_io_cq7_bs_addr;
assign io_cq8_bs_addr = r_io_cq8_bs_addr;
assign io_cq_irq_en = r_io_cq_irq_en;
assign io_cq1_iv = r_io_cq1_iv;
assign io_cq2_iv = r_io_cq2_iv;
assign io_cq3_iv = r_io_cq3_iv;
assign io_cq4_iv = r_io_cq4_iv;
assign io_cq5_iv = r_io_cq5_iv;
assign io_cq6_iv = r_io_cq6_iv;
assign io_cq7_iv = r_io_cq7_iv;
assign io_cq8_iv = r_io_cq8_iv;

assign pcie_user_logic_rst = r_pcie_user_logic_rst;
assign nvme_csts_shst = r_nvme_csts_shst;
assign nvme_csts_rdy = r_nvme_csts_rdy;

assign hcmd_table_rd_addr = r_s_axi_araddr[12:2];
assign hcmd_sq_rd_en = r_hcmd_sq_rd_en;

assign hcmd_cq_wr1_en = r_hcmd_cq_wr1_en;
assign hcmd_cq_wr1_data0 = ((r_cql_type[1] | r_cql_type[0]) == 1) ? {r_cpl_status[12:0], r_cpl_sq_qid, r_cpl_cid[15:7], r_hcmd_slot_tag, r_cql_type}
												: {r_cpl_status[12:0], r_cpl_sq_qid, r_cpl_cid, r_cql_type};
assign hcmd_cq_wr1_data1 = {1'b0, r_cpl_specific[31:0], r_cpl_status[14:13]};


assign dma_cmd_wr_en = r_dma_cmd_wr_en;
assign dma_cmd_wr_data0 = {r_dma_cmd_type, r_dma_cmd_dir, r_dma_cmd_hcmd_slot_tag, r_dma_cmd_dev_len, r_dma_cmd_dev_addr};
assign dma_cmd_wr_data1 = {7'b0, r_dma_cmd_4k_offset, r_dma_cmd_pcie_addr};


always @ (posedge s_axi_aclk)
begin

	r_pcie_link_up <= pcie_link_up;
	r_cfg_command <= cfg_command;
	r_cfg_interrupt_mmenable <= cfg_interrupt_mmenable;
	r_cfg_interrupt_msienable <= cfg_interrupt_msienable;
	r_cfg_interrupt_msixenable <= cfg_interrupt_msixenable;

	r_nvme_cc_en <= nvme_cc_en;
	r_nvme_cc_shn <= nvme_cc_shn;

	r_m0_axi_bresp_err <= m0_axi_bresp_err;
	r_m0_axi_bresp_err_d1 <= r_m0_axi_bresp_err;
	r_m0_axi_bresp_err_d2 <= r_m0_axi_bresp_err_d1;
	r_m0_axi_rresp_err <= m0_axi_rresp_err;
	r_m0_axi_rresp_err_d1 <= r_m0_axi_rresp_err;
	r_m0_axi_rresp_err_d2 <= r_m0_axi_rresp_err_d1;

	r_pcie_mreq_err <= pcie_mreq_err;
	r_pcie_cpld_err <= pcie_cpld_err;
	r_pcie_cpld_len_err <= pcie_cpld_len_err;
end


always @ (posedge s_axi_aclk)
begin
	r_irq_req[0] <= (pcie_link_up ^ r_pcie_link_up);
	r_irq_req[1] <= (cfg_command[2] ^ r_cfg_command[2]);
	r_irq_req[2] <= (cfg_command[10] ^ r_cfg_command[10]);
	r_irq_req[3] <= (cfg_interrupt_msienable ^ r_cfg_interrupt_msienable);
	r_irq_req[4] <= (cfg_interrupt_msixenable ^ r_cfg_interrupt_msixenable);
	r_irq_req[5] <= (nvme_cc_en ^ r_nvme_cc_en);
	r_irq_req[6] <= (nvme_cc_shn != r_nvme_cc_shn);

	r_irq_req[7] <= (r_m0_axi_bresp_err_d1 ^ r_m0_axi_bresp_err_d2);
	r_irq_req[8] <= (r_m0_axi_rresp_err_d1 ^ r_m0_axi_rresp_err_d2);

	r_irq_req[9] <= (pcie_mreq_err ^ r_pcie_mreq_err);
	r_irq_req[10] <= (pcie_cpld_err ^ r_pcie_cpld_err);
	r_irq_req[11] <= (pcie_cpld_len_err ^ r_pcie_cpld_len_err);
	r_irq_assert <= (r_irq_set != 0);
end

always @ (posedge s_axi_aclk or negedge s_axi_aresetn)
begin
	if(s_axi_aresetn == 0)
		cur_wr_state <= S_WR_IDLE;
	else
		cur_wr_state <= next_wr_state;
end

always @ (*)
begin
	case(cur_wr_state)
		S_WR_IDLE: begin
			if(s_axi_awvalid == 1)
				next_wr_state <= S_AW_VAILD;
			else
				next_wr_state <= S_WR_IDLE;
		end
		S_AW_VAILD: begin
			next_wr_state <= S_W_READY;
		end
		S_W_READY: begin
			if(s_axi_wvalid == 1)
				next_wr_state <= S_B_VALID;
			else
				next_wr_state <= S_W_READY;
		end
		S_B_VALID: begin
			if(s_axi_bready == 1) begin
				if(r_awaddr_hcmd_cq_wr1_en == 1)
					next_wr_state <= S_WAIT_CQ_RDY;
				else if(r_awaddr_dma_cmd_wr_en == 1)
					next_wr_state <= S_WAIT_DMA_RDY;
				else
					next_wr_state <= S_WR_IDLE;
			end
			else
				next_wr_state <= S_B_VALID;
		end
		S_WAIT_CQ_RDY: begin
			if(hcmd_cq_wr1_rdy_n == 1)
				next_wr_state <= S_WAIT_CQ_RDY;
			else
				next_wr_state <= S_WR_CQ;
		end
		S_WR_CQ: begin
			next_wr_state <= S_WR_IDLE;
		end
		S_WAIT_DMA_RDY: begin
			if(dma_cmd_wr_rdy_n == 1)
				next_wr_state <= S_WAIT_DMA_RDY;
			else
				next_wr_state <= S_WR_DMA;
		end
		S_WR_DMA: begin
			next_wr_state <= S_WR_IDLE;
		end
		default: begin
			next_wr_state <= S_WR_IDLE;
		end
	endcase
end

always @ (posedge s_axi_aclk)
begin
	case(cur_wr_state)
		S_WR_IDLE: begin
			r_s_axi_awaddr[15:2] <= s_axi_awaddr[15:2];
		end
		S_AW_VAILD: begin
			r_awaddr_cntl_reg_en <= (r_s_axi_awaddr[15:8] == 8'h0);
//			r_awaddr_pcie_reg_en <= (r_s_axi_awaddr[15:8] == 8'h1);
			r_awaddr_nvme_reg_en <= (r_s_axi_awaddr[15:8] == 8'h2);
			r_awaddr_nvme_fifo_en <= (r_s_axi_awaddr[15:8] == 8'h3);
			r_awaddr_hcmd_cq_wr1_en <= (r_s_axi_awaddr[15:2] == 14'hC3);
			r_awaddr_dma_cmd_wr_en <= (r_s_axi_awaddr[15:2] == 14'hC7);
		end
		S_W_READY: begin
			r_wdata <= s_axi_wdata;
		end
		S_B_VALID: begin

		end
		S_WAIT_CQ_RDY: begin

		end
		S_WR_CQ: begin

		end
		S_WAIT_DMA_RDY: begin

		end
		S_WR_DMA: begin

		end
		default: begin

		end
	endcase
end

always @ (*)
begin
	case(cur_wr_state)
		S_WR_IDLE: begin
			r_s_axi_awready <= 0;
			r_s_axi_wready <= 0;
			r_s_axi_bvalid <= 0;
			r_s_axi_bresp <= 0;
			r_cntl_reg_en <= 0;
//			r_pcie_reg_en <= 0;
			r_nvme_reg_en <= 0;
			r_nvme_fifo_en <= 0;
			r_hcmd_cq_wr1_en <= 0;
			r_dma_cmd_wr_en <= 0;
		end
		S_AW_VAILD: begin
			r_s_axi_awready <= 1;
			r_s_axi_wready <= 0;
			r_s_axi_bvalid <= 0;
			r_s_axi_bresp <= 0;
			r_cntl_reg_en <= 0;
//			r_pcie_reg_en <= 0;
			r_nvme_reg_en <= 0;
			r_nvme_fifo_en <= 0;
			r_hcmd_cq_wr1_en <= 0;
			r_dma_cmd_wr_en <= 0;
		end
		S_W_READY: begin
			r_s_axi_awready <= 0;
			r_s_axi_wready <= 1;
			r_s_axi_bvalid <= 0;
			r_s_axi_bresp <= 0;
			r_cntl_reg_en <= 0;
//			r_pcie_reg_en <= 0;
			r_nvme_reg_en <= 0;
			r_nvme_fifo_en <= 0;
			r_hcmd_cq_wr1_en <= 0;
			r_dma_cmd_wr_en <= 0;
		end
		S_B_VALID: begin
			r_s_axi_awready <= 0;
			r_s_axi_wready <= 0;
			r_s_axi_bvalid <= 1;
			r_s_axi_bresp <= `D_AXI_RESP_OKAY;
			r_cntl_reg_en <= r_awaddr_cntl_reg_en;
//			r_pcie_reg_en <= r_awaddr_pcie_reg_en;
			r_nvme_reg_en <= r_awaddr_nvme_reg_en;
			r_nvme_fifo_en <= r_awaddr_nvme_fifo_en;
			r_hcmd_cq_wr1_en <= 0;
			r_dma_cmd_wr_en <= 0;
		end
		S_WAIT_CQ_RDY: begin
			r_s_axi_awready <= 0;
			r_s_axi_wready <= 0;
			r_s_axi_bvalid <= 0;
			r_s_axi_bresp <= 0;
			r_cntl_reg_en <= 0;
//			r_pcie_reg_en <= 0;
			r_nvme_reg_en <= 0;
			r_nvme_fifo_en <= 0;
			r_hcmd_cq_wr1_en <= 0;
			r_dma_cmd_wr_en <= 0;
		end
		S_WR_CQ: begin
			r_s_axi_awready <= 0;
			r_s_axi_wready <= 0;
			r_s_axi_bvalid <= 0;
			r_s_axi_bresp <= 0;
			r_cntl_reg_en <= 0;
//			r_pcie_reg_en <= 0;
			r_nvme_reg_en <= 0;
			r_nvme_fifo_en <= 0;
			r_hcmd_cq_wr1_en <= 1;
			r_dma_cmd_wr_en <= 0;
		end
		S_WAIT_DMA_RDY: begin
			r_s_axi_awready <= 0;
			r_s_axi_wready <= 0;
			r_s_axi_bvalid <= 0;
			r_s_axi_bresp <= 0;
			r_cntl_reg_en <= 0;
//			r_pcie_reg_en <= 0;
			r_nvme_reg_en <= 0;
			r_nvme_fifo_en <= 0;
			r_hcmd_cq_wr1_en <= 0;
			r_dma_cmd_wr_en <= 0;
		end
		S_WR_DMA: begin
			r_s_axi_awready <= 0;
			r_s_axi_wready <= 0;
			r_s_axi_bvalid <= 0;
			r_s_axi_bresp <= 0;
			r_cntl_reg_en <= 0;
//			r_pcie_reg_en <= 0;
			r_nvme_reg_en <= 0;
			r_nvme_fifo_en <= 0;
			r_hcmd_cq_wr1_en <= 0;
			r_dma_cmd_wr_en <= 1;
		end
		default: begin
			r_s_axi_awready <= 0;
			r_s_axi_wready <= 0;
			r_s_axi_bvalid <= 0;
			r_s_axi_bresp <= 0;
			r_cntl_reg_en <= 0;
//			r_pcie_reg_en <= 0;
			r_nvme_reg_en <= 0;
			r_nvme_fifo_en <= 0;
			r_hcmd_cq_wr1_en <= 0;
			r_dma_cmd_wr_en <= 0;
		end
	endcase
end

always @ (posedge s_axi_aclk or negedge s_axi_aresetn)
begin
	if(s_axi_aresetn == 0) begin
		r_irq_mask <= 0;
	end
	else begin
		if(r_cntl_reg_en == 1) begin
			case(r_s_axi_awaddr[7:2]) // synthesis parallel_case
				6'h01: r_irq_mask <= r_wdata[11:0];
			endcase
		end
	end
end

always @ (posedge s_axi_aclk)
begin
	if(r_cntl_reg_en == 1) begin
		case(r_s_axi_awaddr[7:2]) // synthesis parallel_case
			6'h00: begin
				r_pcie_user_logic_rst <= r_wdata[0];
				r_irq_clear <= 0;
			end
			6'h02: begin
				r_pcie_user_logic_rst <= 0;
				r_irq_clear <= r_wdata[11:0];
			end
			default: begin
				r_pcie_user_logic_rst <= 0;
				r_irq_clear <= 0;
			end
		endcase
	end
	else begin
		r_pcie_user_logic_rst <= 0;
		r_irq_clear <= 0;
	end

end

always @ (posedge s_axi_aclk or negedge s_axi_aresetn)
begin
	if(s_axi_aresetn == 0) begin
		r_irq_set <= 0;
	end
	else begin
		r_irq_set <= (r_irq_set | r_irq_req) & (~r_irq_clear & r_irq_mask);
	end
end

always @ (posedge s_axi_aclk or negedge s_axi_aresetn)
begin
	if(s_axi_aresetn == 0) begin
		r_sq_valid <= 0;
		r_cq_valid <= 0;
		r_io_cq_irq_en <= 0;
		r_nvme_csts_shst <= 0;
		r_nvme_csts_rdy <= 0;
	end
	else begin
		if(r_nvme_reg_en == 1) begin
			case(r_s_axi_awaddr[7:2]) // synthesis parallel_case
				6'h00: begin
					r_nvme_csts_shst <= r_wdata[6:5];
					r_nvme_csts_rdy <= r_wdata[4];
				end
				6'h07: begin
					r_io_cq_irq_en[0] <= r_wdata[2];
					r_sq_valid[0] <= r_wdata[1];
					r_cq_valid[0] <= r_wdata[0];
				end
				6'h09: begin
					r_sq_valid[1] <= r_wdata[15];
				end
				6'h0B: begin
					r_sq_valid[2] <= r_wdata[15];
				end
				6'h0D: begin
					r_sq_valid[3] <= r_wdata[15];
				end
				6'h0F: begin
					r_sq_valid[4] <= r_wdata[15];
				end
				6'h11: begin
					r_sq_valid[5] <= r_wdata[15];
				end
				6'h13: begin
					r_sq_valid[6] <= r_wdata[15];
				end
				6'h15: begin
					r_sq_valid[7] <= r_wdata[15];
				end
				6'h17: begin
					r_sq_valid[8] <= r_wdata[15];
				end
				6'h19: begin
					r_io_cq_irq_en[1] <= r_wdata[19];
					r_cq_valid[1] <= r_wdata[15];
				end
				6'h1B: begin
					r_io_cq_irq_en[2] <= r_wdata[19];
					r_cq_valid[2] <= r_wdata[15];
				end
				6'h1D: begin
					r_io_cq_irq_en[3] <= r_wdata[19];
					r_cq_valid[3] <= r_wdata[15];
				end
				6'h1F: begin
					r_io_cq_irq_en[4] <= r_wdata[19];
					r_cq_valid[4] <= r_wdata[15];
				end
				6'h21: begin
					r_io_cq_irq_en[5] <= r_wdata[19];
					r_cq_valid[5] <= r_wdata[15];
				end
				6'h23: begin
					r_io_cq_irq_en[6] <= r_wdata[19];
					r_cq_valid[6] <= r_wdata[15];
				end
				6'h25: begin
					r_io_cq_irq_en[7] <= r_wdata[19];
					r_cq_valid[7] <= r_wdata[15];
				end
				6'h27: begin
					r_io_cq_irq_en[8] <= r_wdata[19];
					r_cq_valid[8] <= r_wdata[15];
				end
			endcase
		end
	end
end

always @ (posedge s_axi_aclk)
begin
	if(r_nvme_reg_en == 1) begin
		case(r_s_axi_awaddr[7:2]) // synthesis parallel_case
			6'h08: begin
				r_io_sq1_bs_addr[31:2] <= r_wdata[31:2];
			end
			6'h09: begin
				r_io_sq1_size <= r_wdata[31:24];
				r_io_sq1_cq_vec <= r_wdata[19:16];
				r_io_sq1_bs_addr[C_PCIE_ADDR_WIDTH-1:32] <= r_wdata[3:0];
			end
			6'h0A: begin
				r_io_sq2_bs_addr[31:2] <= r_wdata[31:2];
			end
			6'h0B: begin
				r_io_sq2_size <= r_wdata[31:24];
				r_io_sq2_cq_vec <= r_wdata[19:16];
				r_io_sq2_bs_addr[C_PCIE_ADDR_WIDTH-1:32] <= r_wdata[3:0];
			end
			6'h0C: begin
				r_io_sq3_bs_addr[31:2] <= r_wdata[31:2];
			end
			6'h0D: begin
				r_io_sq3_size <= r_wdata[31:24];
				r_io_sq3_cq_vec <= r_wdata[19:16];
				r_io_sq3_bs_addr[C_PCIE_ADDR_WIDTH-1:32] <= r_wdata[3:0];
			end
			6'h0E: begin
				r_io_sq4_bs_addr[31:2] <= r_wdata[31:2];
			end
			6'h0F: begin
				r_io_sq4_size <= r_wdata[31:24];
				r_io_sq4_cq_vec <= r_wdata[19:16];
				r_io_sq4_bs_addr[C_PCIE_ADDR_WIDTH-1:32] <= r_wdata[3:0];
			end
			6'h10: begin
				r_io_sq5_bs_addr[31:2] <= r_wdata[31:2];
			end
			6'h11: begin
				r_io_sq5_size <= r_wdata[31:24];
				r_io_sq5_cq_vec <= r_wdata[19:16];
				r_io_sq5_bs_addr[C_PCIE_ADDR_WIDTH-1:32] <= r_wdata[3:0];
			end
			6'h12: begin
				r_io_sq6_bs_addr[31:2] <= r_wdata[31:2];
			end
			6'h13: begin
				r_io_sq6_size <= r_wdata[31:24];
				r_io_sq6_cq_vec <= r_wdata[19:16];
				r_io_sq6_bs_addr[C_PCIE_ADDR_WIDTH-1:32] <= r_wdata[3:0];
			end
			6'h14: begin
				r_io_sq7_bs_addr[31:2] <= r_wdata[31:2];
			end
			6'h15: begin
				r_io_sq7_size <= r_wdata[31:24];
				r_io_sq7_cq_vec <= r_wdata[19:16];
				r_io_sq7_bs_addr[C_PCIE_ADDR_WIDTH-1:32] <= r_wdata[3:0];
			end
			6'h16: begin
				r_io_sq8_bs_addr[31:2] <= r_wdata[31:2];
			end
			6'h17: begin
				r_io_sq8_size <= r_wdata[31:24];
				r_io_sq8_cq_vec <= r_wdata[19:16];
				r_io_sq8_bs_addr[C_PCIE_ADDR_WIDTH-1:32] <= r_wdata[3:0];
			end
			6'h18: begin
				r_io_cq1_bs_addr[31:2] <= r_wdata[31:2];
			end
			6'h19: begin
				r_io_cq1_size <= r_wdata[31:24];
				r_io_cq1_iv <= r_wdata[18:16];
				r_io_cq1_bs_addr[C_PCIE_ADDR_WIDTH-1:32] <= r_wdata[3:0];
			end
			6'h1A: begin
				r_io_cq2_bs_addr[31:2] <= r_wdata[31:2];
			end
			6'h1B: begin
				r_io_cq2_size <= r_wdata[31:24];
				r_io_cq2_iv <= r_wdata[18:16];
				r_io_cq2_bs_addr[C_PCIE_ADDR_WIDTH-1:32] <= r_wdata[3:0];
			end
			6'h1C: begin
				r_io_cq3_bs_addr[31:2] <= r_wdata[31:2];
			end
			6'h1D: begin
				r_io_cq3_size <= r_wdata[31:24];
				r_io_cq3_iv <= r_wdata[18:16];
				r_io_cq3_bs_addr[C_PCIE_ADDR_WIDTH-1:32] <= r_wdata[3:0];
			end
			6'h1E: begin
				r_io_cq4_bs_addr[31:2] <= r_wdata[31:2];
			end
			6'h1F: begin
				r_io_cq4_size <= r_wdata[31:24];
				r_io_cq4_iv <= r_wdata[18:16];
				r_io_cq4_bs_addr[C_PCIE_ADDR_WIDTH-1:32] <= r_wdata[3:0];
			end
			6'h20: begin
				r_io_cq5_bs_addr[31:2] <= r_wdata[31:2];
			end
			6'h21: begin
				r_io_cq5_size <= r_wdata[31:24];
				r_io_cq5_iv <= r_wdata[18:16];
				r_io_cq5_bs_addr[C_PCIE_ADDR_WIDTH-1:32] <= r_wdata[3:0];
			end
			6'h22: begin
				r_io_cq6_bs_addr[31:2] <= r_wdata[31:2];
			end
			6'h23: begin
				r_io_cq6_size <= r_wdata[31:24];
				r_io_cq6_iv <= r_wdata[18:16];
				r_io_cq6_bs_addr[C_PCIE_ADDR_WIDTH-1:32] <= r_wdata[3:0];
			end
			6'h24: begin
				r_io_cq7_bs_addr[31:2] <= r_wdata[31:2];
			end
			6'h25: begin
				r_io_cq7_size <= r_wdata[31:24];
				r_io_cq7_iv <= r_wdata[18:16];
				r_io_cq7_bs_addr[C_PCIE_ADDR_WIDTH-1:32] <= r_wdata[3:0];
			end
			6'h26: begin
				r_io_cq8_bs_addr[31:2] <= r_wdata[31:2];
			end
			6'h27: begin
				r_io_cq8_size <= r_wdata[31:24];
				r_io_cq8_iv <= r_wdata[18:16];
				r_io_cq8_bs_addr[C_PCIE_ADDR_WIDTH-1:32] <= r_wdata[3:0];
			end
		endcase
	end
end




always @ (posedge s_axi_aclk)
begin
	if(r_nvme_fifo_en == 1) begin
		case(r_s_axi_awaddr[7:2]) // synthesis parallel_case
			6'h01: {r_cpl_sq_qid, r_cpl_cid} <= r_wdata[19:0];
			6'h02: r_cpl_specific <= r_wdata;
			6'h03: {r_cpl_status, r_cql_type, r_hcmd_slot_tag} <= {r_wdata[31:17], r_wdata[15:14], r_wdata[6:0]};
			6'h04: r_dma_cmd_dev_addr <= r_wdata[31:2];
			6'h05: r_dma_cmd_pcie_addr[C_PCIE_ADDR_WIDTH-1:32] <= r_wdata[C_PCIE_ADDR_WIDTH-1-32:0];
			6'h06: r_dma_cmd_pcie_addr[31:2] <= r_wdata[31:2];
			6'h07: begin
				r_dma_cmd_type <= r_wdata[31];
				r_dma_cmd_dir <= r_wdata[30];
				r_dma_cmd_hcmd_slot_tag <= r_wdata[29:23];
				r_dma_cmd_4k_offset <= r_wdata[22:14];
				r_dma_cmd_dev_len <= r_wdata[12:2];
			end
		endcase
	end
end



//////////////////////////////////////////////////////////////////////////////////////

always @ (posedge s_axi_aclk or negedge s_axi_aresetn)
begin
	if(s_axi_aresetn == 0)
		cur_rd_state <= S_RD_IDLE;
	else
		cur_rd_state <= next_rd_state;
end

always @ (*)
begin
	case(cur_rd_state)
		S_RD_IDLE: begin
			if(s_axi_arvalid == 1)
				next_rd_state <= S_AR_VAILD;
			else
				next_rd_state <= S_RD_IDLE;
		end
		S_AR_VAILD: begin
			next_rd_state <= S_AR_REG;
		end
		S_AR_REG: begin
			if(r_araddr_hcmd_sq_rd_en == 1 || r_araddr_hcmd_table_rd_en == 1)
				next_rd_state <= S_BRAM_READ;
			else
				next_rd_state <= S_R_READY;
		end
		S_BRAM_READ: begin
			next_rd_state <= S_R_READY;
		end
		S_R_READY: begin
			if(s_axi_rready == 1)
				next_rd_state <= S_RD_IDLE;
			else
				next_rd_state <= S_R_READY;
		end
		default: begin
			next_rd_state <= S_RD_IDLE;
		end
	endcase
end

always @ (posedge s_axi_aclk)
begin
	case(cur_rd_state)
		S_RD_IDLE: begin
			r_s_axi_araddr <= s_axi_araddr[15:2];
		end
		S_AR_VAILD: begin
			r_araddr_cntl_reg_en <= (r_s_axi_araddr[15:8] == 8'h0);
			r_araddr_pcie_reg_en <= (r_s_axi_araddr[15:8] == 8'h1);
			r_araddr_nvme_reg_en <= (r_s_axi_araddr[15:8] == 8'h2);
			r_araddr_nvme_fifo_en <= (r_s_axi_araddr[15:8] == 8'h3);
			r_araddr_hcmd_table_rd_en <= (r_s_axi_araddr[15:13] == 3'h1);
			r_araddr_hcmd_sq_rd_en <= (r_s_axi_araddr[15:2] == 14'hC0) & hcmd_sq_empty_n;
		end
		S_AR_REG: begin
			case({r_araddr_nvme_fifo_en, r_araddr_nvme_reg_en, r_araddr_pcie_reg_en, r_araddr_cntl_reg_en}) // synthesis parallel_case full_case
				4'b0001: r_rdata <= r_cntl_reg_rdata;
				4'b0010: r_rdata <= r_pcie_reg_rdata;
				4'b0100: r_rdata <= r_nvme_reg_rdata;
				4'b1000: r_rdata <= r_nvme_fifo_rdata;
			endcase
		end
		S_BRAM_READ: begin
			case({r_araddr_hcmd_table_rd_en, r_araddr_hcmd_sq_rd_en})  // synthesis parallel_case full_case
				2'b01: r_rdata <= {1'b1, 7'b0, hcmd_sq_rd_data[18:11], 1'b0, hcmd_sq_rd_data[10:4], 4'b0, hcmd_sq_rd_data[3:0]};
				2'b10: r_rdata <= hcmd_table_rd_data;
			endcase
		end
		S_R_READY: begin

		end
		default: begin

		end
	endcase
end

always @ (*)
begin
	case(cur_rd_state)
		S_RD_IDLE: begin
			r_s_axi_arready <= 0;
			r_s_axi_rvalid <= 0;
			r_s_axi_rdata <= 0;
			r_s_axi_rresp <= 0;
			r_hcmd_sq_rd_en <= 0;
		end
		S_AR_VAILD: begin
			r_s_axi_arready <= 1;
			r_s_axi_rvalid <= 0;
			r_s_axi_rdata <= 0;
			r_s_axi_rresp <= 0;
			r_hcmd_sq_rd_en <= 0;
		end
		S_AR_REG: begin
			r_s_axi_arready <= 0;
			r_s_axi_rvalid <= 0;
			r_s_axi_rdata <= 0;
			r_s_axi_rresp <= 0;
			r_hcmd_sq_rd_en <= 0;
		end
		S_BRAM_READ: begin
			r_s_axi_arready <= 0;
			r_s_axi_rvalid <= 0;
			r_s_axi_rdata <= 0;
			r_s_axi_rresp <= 0;
			r_hcmd_sq_rd_en <= r_araddr_hcmd_sq_rd_en;
		end
		S_R_READY: begin
			r_s_axi_arready <= 0;
			r_s_axi_rvalid <= 1;
			r_s_axi_rdata <= r_rdata;
			r_s_axi_rresp <= `D_AXI_RESP_OKAY;
			r_hcmd_sq_rd_en <= 0;
		end
		default: begin
			r_s_axi_arready <= 0;
			r_s_axi_rvalid <= 0;
			r_s_axi_rdata <= 0;
			r_s_axi_rresp <= 0;
			r_hcmd_sq_rd_en <= 0;
		end
	endcase
end

always @ (*)
begin
	case(r_s_axi_araddr[7:2]) // synthesis parallel_case full_case
		6'h01: r_cntl_reg_rdata <= {20'b0, r_irq_mask};
		6'h03: r_cntl_reg_rdata <= {20'b0, r_irq_set};
	endcase
end

always @ (*)
begin
	case(r_s_axi_araddr[7:2]) // synthesis parallel_case full_case
		6'h00: r_pcie_reg_rdata <= {23'b0, r_pcie_link_up, 2'b0, pl_ltssm_state};
		6'h01: r_pcie_reg_rdata <= {25'b0, r_cfg_interrupt_mmenable, ~r_cfg_command[10], r_cfg_interrupt_msixenable, r_cfg_interrupt_msienable, r_cfg_command[2]};
	endcase
end

always @ (*)
begin
	case(r_s_axi_araddr[7:2]) // synthesis parallel_case full_case
		6'h00: r_nvme_reg_rdata <= {25'b0, r_nvme_csts_shst, r_nvme_csts_rdy, 1'b0, r_nvme_cc_shn, r_nvme_cc_en};
		6'h01: r_nvme_reg_rdata <= {dma_tx_done_cnt, dma_rx_done_cnt, dma_tx_direct_done_cnt, dma_rx_direct_done_cnt};
		6'h07: r_nvme_reg_rdata <= {19'b0, r_io_cq_irq_en[0], r_sq_valid[0], r_cq_valid[0]};
		6'h08: r_nvme_reg_rdata <= {r_io_sq1_bs_addr[31:2], 2'b0};
		6'h09: r_nvme_reg_rdata <= {r_io_sq1_size, 4'b0, r_io_sq1_cq_vec, r_sq_valid[1], 11'b0, r_io_sq1_bs_addr[C_PCIE_ADDR_WIDTH-1:32]};
		6'h0A: r_nvme_reg_rdata <= {r_io_sq2_bs_addr[31:2], 2'b0};
		6'h0B: r_nvme_reg_rdata <= {r_io_sq2_size, 4'b0, r_io_sq2_cq_vec, r_sq_valid[2], 11'b0, r_io_sq2_bs_addr[C_PCIE_ADDR_WIDTH-1:32]};
		6'h0C: r_nvme_reg_rdata <= {r_io_sq3_bs_addr[31:2], 2'b0};
		6'h0D: r_nvme_reg_rdata <= {r_io_sq3_size, 4'b0, r_io_sq3_cq_vec, r_sq_valid[3], 11'b0, r_io_sq3_bs_addr[C_PCIE_ADDR_WIDTH-1:32]};
		6'h0E: r_nvme_reg_rdata <= {r_io_sq4_bs_addr[31:2], 2'b0};
		6'h0F: r_nvme_reg_rdata <= {r_io_sq4_size, 4'b0, r_io_sq4_cq_vec, r_sq_valid[4], 11'b0,  r_io_sq4_bs_addr[C_PCIE_ADDR_WIDTH-1:32]};
		6'h10: r_nvme_reg_rdata <= {r_io_sq5_bs_addr[31:2], 2'b0};
		6'h11: r_nvme_reg_rdata <= {r_io_sq5_size, 4'b0, r_io_sq5_cq_vec, r_sq_valid[5], 11'b0, r_io_sq5_bs_addr[C_PCIE_ADDR_WIDTH-1:32]};
		6'h12: r_nvme_reg_rdata <= {r_io_sq6_bs_addr[31:2], 2'b0};
		6'h13: r_nvme_reg_rdata <= {r_io_sq6_size, 4'b0, r_io_sq6_cq_vec, r_sq_valid[6], 11'b0,  r_io_sq6_bs_addr[C_PCIE_ADDR_WIDTH-1:32]};
		6'h14: r_nvme_reg_rdata <= {r_io_sq7_bs_addr[31:2], 2'b0};
		6'h15: r_nvme_reg_rdata <= {r_io_sq7_size, 4'b0, r_io_sq7_cq_vec, r_sq_valid[7], 11'b0, r_io_sq7_bs_addr[C_PCIE_ADDR_WIDTH-1:32]};
		6'h16: r_nvme_reg_rdata <= {r_io_sq8_bs_addr[31:2], 2'b0};
		6'h17: r_nvme_reg_rdata <= {r_io_sq8_size, 4'b0, r_io_sq8_cq_vec, r_sq_valid[8], 11'b0, r_io_sq8_bs_addr[C_PCIE_ADDR_WIDTH-1:32]};
		6'h18: r_nvme_reg_rdata <= {r_io_cq1_bs_addr[31:2], 2'b0};
		6'h19: r_nvme_reg_rdata <= {r_io_cq1_size, 4'b0, r_io_cq_irq_en[1], r_io_cq1_iv, r_cq_valid[1], 11'b0, r_io_cq1_bs_addr[C_PCIE_ADDR_WIDTH-1:32]};
		6'h1A: r_nvme_reg_rdata <= {r_io_cq2_bs_addr[31:2], 2'b0};
		6'h1B: r_nvme_reg_rdata <= {r_io_cq2_size, 4'b0, r_io_cq_irq_en[2], r_io_cq2_iv, r_cq_valid[2], 11'b0, r_io_cq2_bs_addr[C_PCIE_ADDR_WIDTH-1:32]};
		6'h1C: r_nvme_reg_rdata <= {r_io_cq3_bs_addr[31:2], 2'b0};
		6'h1D: r_nvme_reg_rdata <= {r_io_cq3_size, 4'b0, r_io_cq_irq_en[3], r_io_cq3_iv, r_cq_valid[3], 11'b0, r_io_cq3_bs_addr[C_PCIE_ADDR_WIDTH-1:32]};
		6'h1E: r_nvme_reg_rdata <= {r_io_cq4_bs_addr[31:2], 2'b0};
		6'h1F: r_nvme_reg_rdata <= {r_io_cq4_size, 4'b0, r_io_cq_irq_en[4], r_io_cq4_iv, r_cq_valid[4], 11'b0, r_io_cq4_bs_addr[C_PCIE_ADDR_WIDTH-1:32]};
		6'h20: r_nvme_reg_rdata <= {r_io_cq5_bs_addr[31:2], 2'b0};
		6'h21: r_nvme_reg_rdata <= {r_io_cq5_size, 4'b0, r_io_cq_irq_en[5], r_io_cq5_iv, r_cq_valid[5], 11'b0, r_io_cq5_bs_addr[C_PCIE_ADDR_WIDTH-1:32]};
		6'h22: r_nvme_reg_rdata <= {r_io_cq6_bs_addr[31:2], 2'b0};
		6'h23: r_nvme_reg_rdata <= {r_io_cq6_size, 4'b0, r_io_cq_irq_en[6], r_io_cq6_iv, r_cq_valid[6], 11'b0, r_io_cq6_bs_addr[C_PCIE_ADDR_WIDTH-1:32]};
		6'h24: r_nvme_reg_rdata <= {r_io_cq7_bs_addr[31:2], 2'b0};
		6'h25: r_nvme_reg_rdata <= {r_io_cq7_size, 4'b0, r_io_cq_irq_en[7], r_io_cq7_iv, r_cq_valid[7], 11'b0, r_io_cq7_bs_addr[C_PCIE_ADDR_WIDTH-1:32]};
		6'h26: r_nvme_reg_rdata <= {r_io_cq8_bs_addr[31:2], 2'b0};
		6'h27: r_nvme_reg_rdata <= {r_io_cq8_size, 4'b0, r_io_cq_irq_en[8], r_io_cq8_iv, r_cq_valid[8], 11'b0, r_io_cq8_bs_addr[C_PCIE_ADDR_WIDTH-1:32]};
	endcase
end

always @ (*)
begin
	case(r_s_axi_araddr[7:2]) // synthesis parallel_case full_case
		6'h00: r_nvme_fifo_rdata <= 0;
		6'h01: r_nvme_fifo_rdata <= {12'b0, r_cpl_sq_qid, r_cpl_cid};
		6'h02: r_nvme_fifo_rdata <= r_cpl_specific;
		6'h03: r_nvme_fifo_rdata <= {r_cpl_status, 1'b0, r_cql_type, 7'b0, r_hcmd_slot_tag};
		6'h04: r_nvme_fifo_rdata <= {r_dma_cmd_dev_addr, 2'b0};
		6'h05: r_nvme_fifo_rdata <= {28'b0, r_dma_cmd_pcie_addr[C_PCIE_ADDR_WIDTH-1:32]};
		6'h06: r_nvme_fifo_rdata <= {r_dma_cmd_pcie_addr[31:2], 2'b0};
		6'h07: r_nvme_fifo_rdata <= {r_dma_cmd_type, r_dma_cmd_dir, r_dma_cmd_hcmd_slot_tag, r_dma_cmd_4k_offset, 1'b0, r_dma_cmd_dev_len, 2'b0};
	endcase
end

endmodule

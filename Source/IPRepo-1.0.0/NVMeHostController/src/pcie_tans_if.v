
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


module pcie_tans_if # (
	parameter	C_PCIE_DATA_WIDTH			= 128,
	parameter	C_PCIE_ADDR_WIDTH			= 36
)
(

//PCIe user clock
	input									pcie_user_clk,
	input									pcie_user_rst_n,

//PCIe rx interface
	output									mreq_fifo_wr_en,
	output	[C_PCIE_DATA_WIDTH-1:0]			mreq_fifo_wr_data,

	output	[7:0]							cpld0_fifo_tag,
	output									cpld0_fifo_tag_last,
	output									cpld0_fifo_wr_en,
	output	[C_PCIE_DATA_WIDTH-1:0]			cpld0_fifo_wr_data,

	output	[7:0]							cpld1_fifo_tag,
	output									cpld1_fifo_tag_last,
	output									cpld1_fifo_wr_en,
	output	[C_PCIE_DATA_WIDTH-1:0]			cpld1_fifo_wr_data,

	output	[7:0]							cpld2_fifo_tag,
	output									cpld2_fifo_tag_last,
	output									cpld2_fifo_wr_en,
	output	[C_PCIE_DATA_WIDTH-1:0]			cpld2_fifo_wr_data,

//PCIe tx interface
	input									tx_cpld_req,
	input	[7:0]							tx_cpld_tag,
	input	[15:0]							tx_cpld_req_id,
	input	[11:2]							tx_cpld_len,
	input	[11:0]							tx_cpld_bc,
	input	[6:0]							tx_cpld_laddr,
	input	[63:0]							tx_cpld_data,
	output									tx_cpld_req_ack,

	input									tx_mrd0_req,
	input	[7:0]							tx_mrd0_tag,
	input	[11:2]							tx_mrd0_len,
	input	[C_PCIE_ADDR_WIDTH-1:2]			tx_mrd0_addr,
	output									tx_mrd0_req_ack,

	input									tx_mrd1_req,
	input	[7:0]							tx_mrd1_tag,
	input	[11:2]							tx_mrd1_len,
	input	[C_PCIE_ADDR_WIDTH-1:2]			tx_mrd1_addr,
	output									tx_mrd1_req_ack,

	input									tx_mrd2_req,
	input	[7:0]							tx_mrd2_tag,
	input	[11:2]							tx_mrd2_len,
	input	[C_PCIE_ADDR_WIDTH-1:2]			tx_mrd2_addr,
	output									tx_mrd2_req_ack,

	input									tx_mwr0_req,
	input	[7:0]							tx_mwr0_tag,
	input	[11:2]							tx_mwr0_len,
	input	[C_PCIE_ADDR_WIDTH-1:2]			tx_mwr0_addr,
	output									tx_mwr0_req_ack,
	output									tx_mwr0_rd_en,
	input	[C_PCIE_DATA_WIDTH-1:0]			tx_mwr0_rd_data,
	output									tx_mwr0_data_last,

	input									tx_mwr1_req,
	input	[7:0]							tx_mwr1_tag,
	input	[11:2]							tx_mwr1_len,
	input	[C_PCIE_ADDR_WIDTH-1:2]			tx_mwr1_addr,
	output									tx_mwr1_req_ack,
	output									tx_mwr1_rd_en,
	input	[C_PCIE_DATA_WIDTH-1:0]			tx_mwr1_rd_data,
	output									tx_mwr1_data_last,

	output									pcie_mreq_err,
	output									pcie_cpld_err,
	output									pcie_cpld_len_err,

//PCIe Integrated Block Interface
	input	[5:0]								tx_buf_av,
	input										tx_err_drop,
	input										tx_cfg_req,
	input										s_axis_tx_tready,
	output	[C_PCIE_DATA_WIDTH-1:0]				s_axis_tx_tdata,
	output	[(C_PCIE_DATA_WIDTH/8)-1:0]			s_axis_tx_tkeep,
	output	[3:0]								s_axis_tx_tuser,
	output										s_axis_tx_tlast,
	output										s_axis_tx_tvalid,
	output										tx_cfg_gnt,

	input	[C_PCIE_DATA_WIDTH-1:0]				m_axis_rx_tdata,
	input	[(C_PCIE_DATA_WIDTH/8)-1:0]			m_axis_rx_tkeep,
	input										m_axis_rx_tlast,
	input										m_axis_rx_tvalid,
	output										m_axis_rx_tready,
	input	[21:0]								m_axis_rx_tuser,

	input	[11:0]								fc_cpld,
	input	[7:0]								fc_cplh,
	input	[11:0]								fc_npd,
	input	[7:0]								fc_nph,
	input	[11:0]								fc_pd,
	input	[7:0]								fc_ph,
	output	[2:0]								fc_sel,

	input	[7:0]								cfg_bus_number,
	input	[4:0]								cfg_device_number,
	input	[2:0]								cfg_function_number
);

wire										w_tx_cpld_gnt;
wire										w_tx_mrd_gnt;
wire										w_tx_mwr_gnt;

reg		[15:0]								r_pcie_dev_id;


always @(posedge pcie_user_clk) begin
	r_pcie_dev_id <= {cfg_bus_number, cfg_device_number, cfg_function_number};
end

pcie_fc_cntl
pcie_fc_cntl_inst0
(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

	.fc_cpld								(fc_cpld),
	.fc_cplh								(fc_cplh),
	.fc_npd									(fc_npd),
	.fc_nph									(fc_nph),
	.fc_pd									(fc_pd),
	.fc_ph									(fc_ph),
	.fc_sel									(fc_sel),

	.tx_buf_av								(tx_buf_av),
	.tx_cfg_req								(tx_cfg_req),
	.tx_cfg_gnt								(tx_cfg_gnt),

	.tx_cpld_gnt							(w_tx_cpld_gnt),
	.tx_mrd_gnt								(w_tx_mrd_gnt),
	.tx_mwr_gnt								(w_tx_mwr_gnt)
);

pcie_rx # (
	.C_PCIE_DATA_WIDTH						(C_PCIE_DATA_WIDTH)
)
pcie_rx_inst0(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),

//pcie rx signal
	.s_axis_rx_tdata						(m_axis_rx_tdata),
	.s_axis_rx_tkeep						(m_axis_rx_tkeep),
	.s_axis_rx_tlast						(m_axis_rx_tlast),
	.s_axis_rx_tvalid						(m_axis_rx_tvalid),
	.s_axis_rx_tready						(m_axis_rx_tready),
	.s_axis_rx_tuser						(m_axis_rx_tuser),

	.pcie_mreq_err							(pcie_mreq_err),
	.pcie_cpld_err							(pcie_cpld_err),
	.pcie_cpld_len_err						(pcie_cpld_len_err),

	.mreq_fifo_wr_en						(mreq_fifo_wr_en),
	.mreq_fifo_wr_data						(mreq_fifo_wr_data),

	.cpld0_fifo_tag							(cpld0_fifo_tag),
	.cpld0_fifo_tag_last					(cpld0_fifo_tag_last),
	.cpld0_fifo_wr_en						(cpld0_fifo_wr_en),
	.cpld0_fifo_wr_data						(cpld0_fifo_wr_data),

	.cpld1_fifo_tag							(cpld1_fifo_tag),
	.cpld1_fifo_tag_last					(cpld1_fifo_tag_last),
	.cpld1_fifo_wr_en						(cpld1_fifo_wr_en),
	.cpld1_fifo_wr_data						(cpld1_fifo_wr_data),

	.cpld2_fifo_tag							(cpld2_fifo_tag),
	.cpld2_fifo_tag_last					(cpld2_fifo_tag_last),
	.cpld2_fifo_wr_en						(cpld2_fifo_wr_en),
	.cpld2_fifo_wr_data						(cpld2_fifo_wr_data)
);

pcie_tx # (
	.C_PCIE_DATA_WIDTH						(C_PCIE_DATA_WIDTH)
)
pcie_tx_inst0(
	.pcie_user_clk							(pcie_user_clk),
	.pcie_user_rst_n						(pcie_user_rst_n),
	
	.pcie_dev_id							(r_pcie_dev_id),

	.tx_err_drop							(tx_err_drop),

	.tx_cpld_gnt							(w_tx_cpld_gnt),
	.tx_mrd_gnt								(w_tx_mrd_gnt),
	.tx_mwr_gnt								(w_tx_mwr_gnt),

//pcie tx signal
	.m_axis_tx_tready						(s_axis_tx_tready),
	.m_axis_tx_tdata						(s_axis_tx_tdata),
	.m_axis_tx_tkeep						(s_axis_tx_tkeep),
	.m_axis_tx_tuser						(s_axis_tx_tuser),
	.m_axis_tx_tlast						(s_axis_tx_tlast),
	.m_axis_tx_tvalid						(s_axis_tx_tvalid),
	
	.tx_cpld_req							(tx_cpld_req),
	.tx_cpld_tag							(tx_cpld_tag),
	.tx_cpld_req_id							(tx_cpld_req_id),
	.tx_cpld_len							(tx_cpld_len),
	.tx_cpld_bc								(tx_cpld_bc),
	.tx_cpld_laddr							(tx_cpld_laddr),
	.tx_cpld_data							(tx_cpld_data),
	.tx_cpld_req_ack						(tx_cpld_req_ack),
	
	.tx_mrd0_req							(tx_mrd0_req),
	.tx_mrd0_tag							(tx_mrd0_tag),
	.tx_mrd0_len							(tx_mrd0_len),
	.tx_mrd0_addr							(tx_mrd0_addr),
	.tx_mrd0_req_ack						(tx_mrd0_req_ack),
	
	.tx_mrd1_req							(tx_mrd1_req),
	.tx_mrd1_tag							(tx_mrd1_tag),
	.tx_mrd1_len							(tx_mrd1_len),
	.tx_mrd1_addr							(tx_mrd1_addr),
	.tx_mrd1_req_ack						(tx_mrd1_req_ack),
	
	.tx_mrd2_req							(tx_mrd2_req),
	.tx_mrd2_tag							(tx_mrd2_tag),
	.tx_mrd2_len							(tx_mrd2_len),
	.tx_mrd2_addr							(tx_mrd2_addr),
	.tx_mrd2_req_ack						(tx_mrd2_req_ack),
	
	.tx_mwr0_req							(tx_mwr0_req),
	.tx_mwr0_tag							(tx_mwr0_tag),
	.tx_mwr0_len							(tx_mwr0_len),
	.tx_mwr0_addr							(tx_mwr0_addr),
	.tx_mwr0_req_ack						(tx_mwr0_req_ack),
	.tx_mwr0_rd_en							(tx_mwr0_rd_en),
	.tx_mwr0_rd_data						(tx_mwr0_rd_data),
	.tx_mwr0_data_last						(tx_mwr0_data_last),
	
	.tx_mwr1_req							(tx_mwr1_req),
	.tx_mwr1_tag							(tx_mwr1_tag),
	.tx_mwr1_len							(tx_mwr1_len),
	.tx_mwr1_addr							(tx_mwr1_addr),
	.tx_mwr1_req_ack						(tx_mwr1_req_ack),
	.tx_mwr1_rd_en							(tx_mwr1_rd_en),
	.tx_mwr1_rd_data						(tx_mwr1_rd_data),
	.tx_mwr1_data_last						(tx_mwr1_data_last)
);


endmodule


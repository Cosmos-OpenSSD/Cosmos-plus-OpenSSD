
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

module reg_cpu_pcie_sync # (
	parameter	C_PCIE_ADDR_WIDTH			= 36
)
(
	input									cpu_bus_clk,

	input	[1:0]							nvme_csts_shst,
	input									nvme_csts_rdy,

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

	output									pcie_link_up_sync,
	output	[5:0]							pl_ltssm_state_sync,
	output	[15:0]							cfg_command_sync,
	output	[2:0]							cfg_interrupt_mmenable_sync,
	output									cfg_interrupt_msienable_sync,
	output									cfg_interrupt_msixenable_sync,

	output									pcie_mreq_err_sync,
	output									pcie_cpld_err_sync,
	output									pcie_cpld_len_err_sync,

	output									nvme_cc_en_sync,
	output	[1:0]							nvme_cc_shn_sync,

	input									pcie_user_clk,

	input									pcie_link_up,
	input	[5:0]							pl_ltssm_state,
	input	[15:0]							cfg_command,
	input	[2:0]							cfg_interrupt_mmenable,
	input									cfg_interrupt_msienable,
	input									cfg_interrupt_msixenable,

	input									pcie_mreq_err,
	input									pcie_cpld_err,
	input									pcie_cpld_len_err,

	input									nvme_cc_en,
	input	[1:0]							nvme_cc_shn,

	output	[1:0]							nvme_csts_shst_sync,
	output									nvme_csts_rdy_sync,

	output	[8:0]							sq_rst_n_sync,
	output	[8:0]							sq_valid_sync,
	output	[7:0]							io_sq1_size_sync,
	output	[7:0]							io_sq2_size_sync,
	output	[7:0]							io_sq3_size_sync,
	output	[7:0]							io_sq4_size_sync,
	output	[7:0]							io_sq5_size_sync,
	output	[7:0]							io_sq6_size_sync,
	output	[7:0]							io_sq7_size_sync,
	output	[7:0]							io_sq8_size_sync,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_sq1_bs_addr_sync,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_sq2_bs_addr_sync,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_sq3_bs_addr_sync,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_sq4_bs_addr_sync,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_sq5_bs_addr_sync,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_sq6_bs_addr_sync,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_sq7_bs_addr_sync,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_sq8_bs_addr_sync,
	output	[3:0]							io_sq1_cq_vec_sync,
	output	[3:0]							io_sq2_cq_vec_sync,
	output	[3:0]							io_sq3_cq_vec_sync,
	output	[3:0]							io_sq4_cq_vec_sync,
	output	[3:0]							io_sq5_cq_vec_sync,
	output	[3:0]							io_sq6_cq_vec_sync,
	output	[3:0]							io_sq7_cq_vec_sync,
	output	[3:0]							io_sq8_cq_vec_sync,

	output	[8:0]							cq_rst_n_sync,
	output	[8:0]							cq_valid_sync,
	output	[7:0]							io_cq1_size_sync,
	output	[7:0]							io_cq2_size_sync,
	output	[7:0]							io_cq3_size_sync,
	output	[7:0]							io_cq4_size_sync,
	output	[7:0]							io_cq5_size_sync,
	output	[7:0]							io_cq6_size_sync,
	output	[7:0]							io_cq7_size_sync,
	output	[7:0]							io_cq8_size_sync,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_cq1_bs_addr_sync,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_cq2_bs_addr_sync,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_cq3_bs_addr_sync,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_cq4_bs_addr_sync,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_cq5_bs_addr_sync,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_cq6_bs_addr_sync,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_cq7_bs_addr_sync,
	output	[C_PCIE_ADDR_WIDTH-1:2]			io_cq8_bs_addr_sync,
	output	[8:0]							io_cq_irq_en_sync,
	output	[2:0]							io_cq1_iv_sync,
	output	[2:0]							io_cq2_iv_sync,
	output	[2:0]							io_cq3_iv_sync,
	output	[2:0]							io_cq4_iv_sync,
	output	[2:0]							io_cq5_iv_sync,
	output	[2:0]							io_cq6_iv_sync,
	output	[2:0]							io_cq7_iv_sync,
	output	[2:0]							io_cq8_iv_sync
);

(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg										r_pcie_link_up;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg										r_pcie_link_up_d1;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[5:0]							r_pl_ltssm_state;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[5:0]							r_pl_ltssm_state_d1;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[15:0]							r_cfg_command;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[15:0]							r_cfg_command_d1;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[2:0]							r_cfg_interrupt_mmenable;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[2:0]							r_cfg_interrupt_mmenable_d1;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg										r_cfg_interrupt_msienable;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg										r_cfg_interrupt_msienable_d1;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg										r_cfg_interrupt_msixenable;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg										r_cfg_interrupt_msixenable_d1;

(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg										r_pcie_mreq_err;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg										r_pcie_mreq_err_d1;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg										r_pcie_cpld_err;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg										r_pcie_cpld_err_d1;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg										r_pcie_cpld_len_err;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg										r_pcie_cpld_len_err_d1;

(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg										r_nvme_cc_en;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg										r_nvme_cc_en_d1;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[1:0]							r_nvme_cc_shn;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[1:0]							r_nvme_cc_shn_d1;

(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[1:0]							r_nvme_csts_shst;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[1:0]							r_nvme_csts_shst_d1;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg										r_nvme_csts_rdy;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg										r_nvme_csts_rdy_d1;

(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[8:0]							r_sq_valid;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[8:0]							r_sq_valid_d1;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[8:0]							r_sq_valid_d2;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[8:0]							r_sq_valid_d3;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[7:0]							r_io_sq1_size;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[7:0]							r_io_sq2_size;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[7:0]							r_io_sq3_size;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[7:0]							r_io_sq4_size;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[7:0]							r_io_sq5_size;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[7:0]							r_io_sq6_size;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[7:0]							r_io_sq7_size;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[7:0]							r_io_sq8_size;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[C_PCIE_ADDR_WIDTH-1:2]			r_io_sq1_bs_addr;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[C_PCIE_ADDR_WIDTH-1:2]			r_io_sq2_bs_addr;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[C_PCIE_ADDR_WIDTH-1:2]			r_io_sq3_bs_addr;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[C_PCIE_ADDR_WIDTH-1:2]			r_io_sq4_bs_addr;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[C_PCIE_ADDR_WIDTH-1:2]			r_io_sq5_bs_addr;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[C_PCIE_ADDR_WIDTH-1:2]			r_io_sq6_bs_addr;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[C_PCIE_ADDR_WIDTH-1:2]			r_io_sq7_bs_addr;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[C_PCIE_ADDR_WIDTH-1:2]			r_io_sq8_bs_addr;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[3:0]							r_io_sq1_cq_vec;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[3:0]							r_io_sq2_cq_vec;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[3:0]							r_io_sq3_cq_vec;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[3:0]							r_io_sq4_cq_vec;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[3:0]							r_io_sq5_cq_vec;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[3:0]							r_io_sq6_cq_vec;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[3:0]							r_io_sq7_cq_vec;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[3:0]							r_io_sq8_cq_vec;

(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[8:0]							r_cq_valid;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[8:0]							r_cq_valid_d1;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[8:0]							r_cq_valid_d2;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[8:0]							r_cq_valid_d3;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[7:0]							r_io_cq1_size;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[7:0]							r_io_cq2_size;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[7:0]							r_io_cq3_size;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[7:0]							r_io_cq4_size;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[7:0]							r_io_cq5_size;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[7:0]							r_io_cq6_size;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[7:0]							r_io_cq7_size;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[7:0]							r_io_cq8_size;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[C_PCIE_ADDR_WIDTH-1:2]			r_io_cq1_bs_addr;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[C_PCIE_ADDR_WIDTH-1:2]			r_io_cq2_bs_addr;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[C_PCIE_ADDR_WIDTH-1:2]			r_io_cq3_bs_addr;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[C_PCIE_ADDR_WIDTH-1:2]			r_io_cq4_bs_addr;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[C_PCIE_ADDR_WIDTH-1:2]			r_io_cq5_bs_addr;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[C_PCIE_ADDR_WIDTH-1:2]			r_io_cq6_bs_addr;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[C_PCIE_ADDR_WIDTH-1:2]			r_io_cq7_bs_addr;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[C_PCIE_ADDR_WIDTH-1:2]			r_io_cq8_bs_addr;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[8:0]							r_io_cq_irq_en;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[8:0]							r_io_cq_irq_en_d1;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[2:0]							r_io_cq1_iv;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[2:0]							r_io_cq2_iv;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[2:0]							r_io_cq3_iv;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[2:0]							r_io_cq4_iv;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[2:0]							r_io_cq5_iv;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[2:0]							r_io_cq6_iv;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[2:0]							r_io_cq7_iv;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg		[2:0]							r_io_cq8_iv;


assign pcie_link_up_sync = r_pcie_link_up_d1;
assign pl_ltssm_state_sync = r_pl_ltssm_state_d1;
assign cfg_command_sync = r_cfg_command_d1;
assign cfg_interrupt_mmenable_sync = r_cfg_interrupt_mmenable_d1;
assign cfg_interrupt_msienable_sync = r_cfg_interrupt_msienable_d1;
assign cfg_interrupt_msixenable_sync = r_cfg_interrupt_msixenable_d1;

assign pcie_mreq_err_sync = r_pcie_mreq_err_d1;
assign pcie_cpld_err_sync = r_pcie_cpld_err_d1;
assign pcie_cpld_len_err_sync = r_pcie_cpld_len_err_d1;


assign nvme_cc_en_sync = r_nvme_cc_en_d1;
assign nvme_cc_shn_sync = r_nvme_cc_shn_d1;

assign nvme_csts_shst_sync = r_nvme_csts_shst_d1;
assign nvme_csts_rdy_sync = r_nvme_csts_rdy_d1;

assign sq_rst_n_sync = r_sq_valid_d3;
assign sq_valid_sync = r_sq_valid_d1;
assign io_sq1_size_sync = r_io_sq1_size;
assign io_sq2_size_sync = r_io_sq2_size;
assign io_sq3_size_sync = r_io_sq3_size;
assign io_sq4_size_sync = r_io_sq4_size;
assign io_sq5_size_sync = r_io_sq5_size;
assign io_sq6_size_sync = r_io_sq6_size;
assign io_sq7_size_sync = r_io_sq7_size;
assign io_sq8_size_sync = r_io_sq8_size;
assign io_sq1_bs_addr_sync = r_io_sq1_bs_addr;
assign io_sq2_bs_addr_sync = r_io_sq2_bs_addr;
assign io_sq3_bs_addr_sync = r_io_sq3_bs_addr;
assign io_sq4_bs_addr_sync = r_io_sq4_bs_addr;
assign io_sq5_bs_addr_sync = r_io_sq5_bs_addr;
assign io_sq6_bs_addr_sync = r_io_sq6_bs_addr;
assign io_sq7_bs_addr_sync = r_io_sq7_bs_addr;
assign io_sq8_bs_addr_sync = r_io_sq8_bs_addr;
assign io_sq1_cq_vec_sync = r_io_sq1_cq_vec;
assign io_sq2_cq_vec_sync = r_io_sq2_cq_vec;
assign io_sq3_cq_vec_sync = r_io_sq3_cq_vec;
assign io_sq4_cq_vec_sync = r_io_sq4_cq_vec;
assign io_sq5_cq_vec_sync = r_io_sq5_cq_vec;
assign io_sq6_cq_vec_sync = r_io_sq6_cq_vec;
assign io_sq7_cq_vec_sync = r_io_sq7_cq_vec;
assign io_sq8_cq_vec_sync = r_io_sq8_cq_vec;

assign cq_rst_n_sync = r_cq_valid_d3;
assign cq_valid_sync = r_cq_valid_d1;
assign io_cq1_size_sync = r_io_cq1_size;
assign io_cq2_size_sync = r_io_cq2_size;
assign io_cq3_size_sync = r_io_cq3_size;
assign io_cq4_size_sync = r_io_cq4_size;
assign io_cq5_size_sync = r_io_cq5_size;
assign io_cq6_size_sync = r_io_cq6_size;
assign io_cq7_size_sync = r_io_cq7_size;
assign io_cq8_size_sync = r_io_cq8_size;
assign io_cq1_bs_addr_sync = r_io_cq1_bs_addr;
assign io_cq2_bs_addr_sync = r_io_cq2_bs_addr;
assign io_cq3_bs_addr_sync = r_io_cq3_bs_addr;
assign io_cq4_bs_addr_sync = r_io_cq4_bs_addr;
assign io_cq5_bs_addr_sync = r_io_cq5_bs_addr;
assign io_cq6_bs_addr_sync = r_io_cq6_bs_addr;
assign io_cq7_bs_addr_sync = r_io_cq7_bs_addr;
assign io_cq8_bs_addr_sync = r_io_cq8_bs_addr;
assign io_cq_irq_en_sync = r_io_cq_irq_en_d1;
assign io_cq1_iv_sync = r_io_cq1_iv;
assign io_cq2_iv_sync = r_io_cq2_iv;
assign io_cq3_iv_sync = r_io_cq3_iv;
assign io_cq4_iv_sync = r_io_cq4_iv;
assign io_cq5_iv_sync = r_io_cq5_iv;
assign io_cq6_iv_sync = r_io_cq6_iv;
assign io_cq7_iv_sync = r_io_cq7_iv;
assign io_cq8_iv_sync = r_io_cq8_iv;

always @ (posedge cpu_bus_clk)
begin

	r_pcie_link_up <= pcie_link_up;
	r_pcie_link_up_d1 <= r_pcie_link_up;
	r_pl_ltssm_state <= pl_ltssm_state;
	r_pl_ltssm_state_d1 <= r_pl_ltssm_state;
	r_cfg_command <= cfg_command;
	r_cfg_command_d1 <= r_cfg_command;
	r_cfg_interrupt_mmenable <= cfg_interrupt_mmenable;
	r_cfg_interrupt_mmenable_d1 <= r_cfg_interrupt_mmenable;
	r_cfg_interrupt_msienable <= cfg_interrupt_msienable;
	r_cfg_interrupt_msienable_d1 <= r_cfg_interrupt_msienable;
	r_cfg_interrupt_msixenable <= cfg_interrupt_msixenable;
	r_cfg_interrupt_msixenable_d1 <= r_cfg_interrupt_msixenable;

	r_pcie_mreq_err <= pcie_mreq_err;
	r_pcie_mreq_err_d1 <= r_pcie_mreq_err;
	r_pcie_cpld_err <= pcie_cpld_err;
	r_pcie_cpld_err_d1 <= r_pcie_cpld_err;
	r_pcie_cpld_len_err <= pcie_cpld_len_err;
	r_pcie_cpld_len_err_d1 <= r_pcie_cpld_len_err;

	r_nvme_cc_en <= nvme_cc_en;
	r_nvme_cc_en_d1 <= r_nvme_cc_en;
	r_nvme_cc_shn <= nvme_cc_shn;
	r_nvme_cc_shn_d1 <= r_nvme_cc_shn;
end

always @ (posedge pcie_user_clk)
begin
	r_nvme_csts_shst <= nvme_csts_shst;
	r_nvme_csts_shst_d1 <= r_nvme_csts_shst;

	r_nvme_csts_rdy <= nvme_csts_rdy;
	r_nvme_csts_rdy_d1 <= r_nvme_csts_rdy;

	r_sq_valid <= sq_valid;
	r_sq_valid_d1 <= r_sq_valid;
	r_sq_valid_d2 <= r_sq_valid_d1;
	r_sq_valid_d3 <= r_sq_valid_d2;
	r_io_sq1_size <= io_sq1_size;
	r_io_sq2_size <= io_sq2_size;
	r_io_sq3_size <= io_sq3_size;
	r_io_sq4_size <= io_sq4_size;
	r_io_sq5_size <= io_sq5_size;
	r_io_sq6_size <= io_sq6_size;
	r_io_sq7_size <= io_sq7_size;
	r_io_sq8_size <= io_sq8_size;
	r_io_sq1_bs_addr <= io_sq1_bs_addr;
	r_io_sq2_bs_addr <= io_sq2_bs_addr;
	r_io_sq3_bs_addr <= io_sq3_bs_addr;
	r_io_sq4_bs_addr <= io_sq4_bs_addr;
	r_io_sq5_bs_addr <= io_sq5_bs_addr;
	r_io_sq6_bs_addr <= io_sq6_bs_addr;
	r_io_sq7_bs_addr <= io_sq7_bs_addr;
	r_io_sq8_bs_addr <= io_sq8_bs_addr;
	r_io_sq1_cq_vec <= io_sq1_cq_vec;
	r_io_sq2_cq_vec <= io_sq2_cq_vec;
	r_io_sq3_cq_vec <= io_sq3_cq_vec;
	r_io_sq4_cq_vec <= io_sq4_cq_vec;
	r_io_sq5_cq_vec <= io_sq5_cq_vec;
	r_io_sq6_cq_vec <= io_sq6_cq_vec;
	r_io_sq7_cq_vec <= io_sq7_cq_vec;
	r_io_sq8_cq_vec <= io_sq8_cq_vec;

	r_cq_valid <= cq_valid;
	r_cq_valid_d1 <= r_cq_valid;
	r_cq_valid_d2 <= r_cq_valid_d1;
	r_cq_valid_d3 <= r_cq_valid_d2;
	r_io_cq1_size <= io_cq1_size;
	r_io_cq2_size <= io_cq2_size;
	r_io_cq3_size <= io_cq3_size;
	r_io_cq4_size <= io_cq4_size;
	r_io_cq5_size <= io_cq5_size;
	r_io_cq6_size <= io_cq6_size;
	r_io_cq7_size <= io_cq7_size;
	r_io_cq8_size <= io_cq8_size;
	r_io_cq1_bs_addr <= io_cq1_bs_addr;
	r_io_cq2_bs_addr <= io_cq2_bs_addr;
	r_io_cq3_bs_addr <= io_cq3_bs_addr;
	r_io_cq4_bs_addr <= io_cq4_bs_addr;
	r_io_cq5_bs_addr <= io_cq5_bs_addr;
	r_io_cq6_bs_addr <= io_cq6_bs_addr;
	r_io_cq7_bs_addr <= io_cq7_bs_addr;
	r_io_cq8_bs_addr <= io_cq8_bs_addr;
	r_io_cq_irq_en <= io_cq_irq_en;
	r_io_cq_irq_en_d1 <= r_io_cq_irq_en;
	r_io_cq1_iv <= io_cq1_iv;
	r_io_cq2_iv <= io_cq2_iv;
	r_io_cq3_iv <= io_cq3_iv;
	r_io_cq4_iv <= io_cq4_iv;
	r_io_cq5_iv <= io_cq5_iv;
	r_io_cq6_iv <= io_cq6_iv;
	r_io_cq7_iv <= io_cq7_iv;
	r_io_cq8_iv <= io_cq8_iv;
end


endmodule



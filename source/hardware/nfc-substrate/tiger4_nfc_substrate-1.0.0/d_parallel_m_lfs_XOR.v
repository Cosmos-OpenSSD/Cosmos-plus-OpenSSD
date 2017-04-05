//////////////////////////////////////////////////////////////////////////////////
// d_parallel_m_lfs_XOR.v for Cosmos OpenSSD
// Copyright (c) 2015 Hanyang University ENC Lab.
// Contributed by Jinwoo Jeong <jwjeong@enc.hanyang.ac.kr>
//                Ilyong Jung <iyjung@enc.hanyang.ac.kr>
//                Yong Ho Song <yhsong@enc.hanyang.ac.kr>
//
// This file is part of Cosmos OpenSSD.
//
// Cosmos OpenSSD is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3, or (at your option)
// any later version.
//
// Cosmos OpenSSD is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Cosmos OpenSSD; see the file COPYING.
// If not, see <http://www.gnu.org/licenses/>. 
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Company: ENC Lab. <http://enc.hanyang.ac.kr>
// Engineer: Ilyong Jung <iyjung@enc.hanyang.ac.kr>
// 
// Project Name: Cosmos OpenSSD
// Design Name: BCH Encoder
// Module Name: d_parallel_m_lfs_XOR
// File Name: d_parallel_m_lfs_XOR.v
//
// Version: v1.0.1-256B_T14
//
// Description: 
//   - parallel modified Linear Feedback Shift XOR
//   - for data area
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.1
//   - minor modification for releasing
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////

`include "d_BCH_encoder_parameters.vh"
`timescale 1ns / 1ps

module d_parallel_m_lfs_XOR
(
    input  wire [`D_BCH_ENC_P_LVL-1:0]         i_message,
	input  wire [`D_BCH_ENC_PRT_LENGTH-1:0]    i_cur_parity,
	
	output wire [`D_BCH_ENC_PRT_LENGTH-1:0]    o_nxt_parity
);
	
	wire [`D_BCH_ENC_PRT_LENGTH*(`D_BCH_ENC_P_LVL+1)-1:0] w_parallel_wire;
	
	
	
	genvar i;
	generate
		for (i=0; i<`D_BCH_ENC_P_LVL; i=i+1)
		begin: m_lfs_XOR_blade_enclosure
			
			// modified(improved) linear feedback shift XOR blade
			// LFSR = LFSXOR + register
			d_serial_m_lfs_XOR d_mLFSXOR_blade(
			.i_message   (i_message[i]),
			.i_cur_parity(w_parallel_wire[`D_BCH_ENC_PRT_LENGTH*(i+2)-1:`D_BCH_ENC_PRT_LENGTH*(i+1)]),
			.o_nxt_parity(w_parallel_wire[`D_BCH_ENC_PRT_LENGTH*(i+1)-1:`D_BCH_ENC_PRT_LENGTH*(i)  ]));
		
		end
	endgenerate
	
	assign w_parallel_wire[`D_BCH_ENC_PRT_LENGTH*(`D_BCH_ENC_P_LVL+1)-1:`D_BCH_ENC_PRT_LENGTH*(`D_BCH_ENC_P_LVL)] = i_cur_parity[`D_BCH_ENC_PRT_LENGTH-1:0];
	assign o_nxt_parity[`D_BCH_ENC_PRT_LENGTH-1:0] = w_parallel_wire[`D_BCH_ENC_PRT_LENGTH-1:0];

	
endmodule

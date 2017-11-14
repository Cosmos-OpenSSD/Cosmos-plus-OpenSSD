//////////////////////////////////////////////////////////////////////////////////
// d_serial_m_lfs_XOR.v for Cosmos OpenSSD
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
// Module Name: d_serial_m_lfs_XOR
// File Name: d_serial_m_lfs_XOR.v
//
// Version: v1.0.1-256B_T14
//
// Description: 
//   - serial modified Linear Feedback Shift XOR
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

module d_serial_m_lfs_XOR
(
    input  wire                             i_message,
	input  wire [`D_BCH_ENC_PRT_LENGTH-1:0] i_cur_parity,
	
	output wire [`D_BCH_ENC_PRT_LENGTH-1:0] o_nxt_parity
);

	// generate polynomial
	parameter [0:168] D_BCH_ENC_G_POLY = 169'b1100011001001101001001011010010000001010100100010101010000111100111110110010110000100000001101100011000011111011010100011001110110100011110100100001001101010100010111001;
	// LSB is MAXIMUM order term, so parameter has switched order
	
	
	
	wire w_FB_term;

	
	
	assign w_FB_term = i_message ^ i_cur_parity[`D_BCH_ENC_PRT_LENGTH-1];
	
	assign o_nxt_parity[0] = w_FB_term;
	
	genvar i;
	generate
		for (i=1; i<`D_BCH_ENC_PRT_LENGTH; i=i+1)
		begin: linear_function
		
			// modified(improved) linear feedback shift XOR
		
			if (D_BCH_ENC_G_POLY[i] == 1)
			begin
				assign o_nxt_parity[i] = i_cur_parity[i-1] ^ w_FB_term;
			end
			
			else
			begin
				assign o_nxt_parity[i] = i_cur_parity[i-1];
			end
			
		end
	endgenerate
	

endmodule

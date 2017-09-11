//////////////////////////////////////////////////////////////////////////////////
// CRC_serial_m_lfs_XOR.v for Cosmos OpenSSD
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
// Engineer: Jinwoo Jeong <jwjeong@enc.hanyang.ac.kr>
//           Ilyong Jung <iyjung@enc.hanyang.ac.kr>
// 
// Project Name: Cosmos OpenSSD
// Design Name: BCH encoder/decoder
// Module Name: CRC_serial_m_lfs_XOR
// File Name: CRC_serial_m_lfs_XOR.v
//
// Version: v1.0.0
//
// Description: Serial linear feedback shift XOR for CRC code
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
module CRC_serial_m_lfs_XOR
#(
	parameter	HASH_LENGTH = 64
)
(
	i_message     ,  
	i_cur_parity  ,  
	o_next_parity
);
	input						i_message    ;
	input	[HASH_LENGTH-1:0]	i_cur_parity  ;
	output	[HASH_LENGTH-1:0]	o_next_parity ;
	
	localparam	[0:64]	HASH_VALUE	=	65'b11001001011011000101011110010101110101111000011100001111010000101;
	
	wire	w_feedback_term;
	
	assign	w_feedback_term	=	i_message ^ i_cur_parity[HASH_LENGTH-1];
	
	assign	o_next_parity[0]	=	w_feedback_term;
	
	genvar	i;
	generate
		for (i=1; i<HASH_LENGTH; i=i+1)
		begin: linear_function
			if (HASH_VALUE[i] == 1)
				assign	o_next_parity[i] = i_cur_parity[i-1] ^ w_feedback_term;
			else
				assign	o_next_parity[i] = i_cur_parity[i-1];
		end
	endgenerate
	
endmodule
//////////////////////////////////////////////////////////////////////////////////
// CRC_parallel_m_lfs_XOR.v for Cosmos OpenSSD
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
// Module Name: CRC_parallel_m_lfs_XOR
// File Name: CRC_parallel_m_lfs_XOR.v
//
// Version: v1.0.0
//
// Description: Parallel linear feedback shift XOR for CRC code
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
module CRC_parallel_m_lfs_XOR
#(
	parameter	DATA_WIDTH	=	32,
	parameter	HASH_LENGTH	=	64
)
(
	i_message		,
	i_cur_parity	,
	o_next_parity	
);
	input	[DATA_WIDTH-1:0]		i_message		;
	input	[HASH_LENGTH-1:0]		i_cur_parity	;
	output	[HASH_LENGTH-1:0]		o_next_parity	;
	
	wire	[HASH_LENGTH*(DATA_WIDTH+1)-1:0]	w_parallel_wire;
	
	genvar	i;
	generate
		for (i=0; i<DATA_WIDTH; i=i+1)
		begin: m_lfs_XOR_blade_enclosure
			CRC_serial_m_lfs_XOR
			#(
				.HASH_LENGTH(HASH_LENGTH)
			)
			CRC_mLFSXOR_blade(
			.i_message		(i_message[i]),
			.i_cur_parity	(w_parallel_wire[HASH_LENGTH*(i+2)-1:HASH_LENGTH*(i+1)]),
			.o_next_parity	(w_parallel_wire[HASH_LENGTH*(i+1)-1:HASH_LENGTH*(i)]));
		end
	endgenerate
	
	assign w_parallel_wire[HASH_LENGTH*(DATA_WIDTH+1)-1:HASH_LENGTH*(DATA_WIDTH)] = i_cur_parity[HASH_LENGTH-1:0];
	assign o_next_parity[HASH_LENGTH-1:0] = w_parallel_wire[HASH_LENGTH-1:0];
	
endmodule 
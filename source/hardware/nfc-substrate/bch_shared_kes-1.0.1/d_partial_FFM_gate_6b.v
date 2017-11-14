//////////////////////////////////////////////////////////////////////////////////
// d_partial_FFM_gate_6b.v for Cosmos OpenSSD
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
// Design Name: BCH Page Decoder
// Module Name: d_partial_FFM_gate_6b
// File Name: d_partial_FFM_gate_6b.v
//
// Version: v1.0.1-6b
//
// Description: 
//   - parallel Finite Field Multiplier (FFM) module
//   - 2 polynomial form input, 1 polynomial form output
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

`timescale 1ns / 1ps

module d_partial_FFM_gate_6b
(
	input  wire [5:0]  i_a, // input term A
	input  wire [5:0]  i_b, // input term B
	
	output wire [10:0] o_r  // output term result
);
	
	///////////////////////////////////////////////////////////
	// CAUTION! CAUTION! CAUTION! CAUTION! CAUTION! CAUTION! //
	//                                                       //
	//      ONLY FOR  6 BIT POLYNOMIAL MULTIPLICATION        //
	//                                                       //
	// CAUTION! CAUTION! CAUTION! CAUTION! CAUTION! CAUTION! //
	///////////////////////////////////////////////////////////
	
	// multiplication
	assign o_r[10] = (i_a[5]&i_b[5]);
	assign o_r[ 9] = (i_a[4]&i_b[5]) ^ (i_a[5]&i_b[4]);
	assign o_r[ 8] = (i_a[3]&i_b[5]) ^ (i_a[4]&i_b[4]) ^ (i_a[5]&i_b[3]);
	assign o_r[ 7] = (i_a[2]&i_b[5]) ^ (i_a[3]&i_b[4]) ^ (i_a[4]&i_b[3]) ^ (i_a[5]&i_b[2]);
	assign o_r[ 6] = (i_a[1]&i_b[5]) ^ (i_a[2]&i_b[4]) ^ (i_a[3]&i_b[3]) ^ (i_a[4]&i_b[2]) ^ (i_a[5]&i_b[1]);
	assign o_r[ 5] = (i_a[0]&i_b[5]) ^ (i_a[1]&i_b[4]) ^ (i_a[2]&i_b[3]) ^ (i_a[3]&i_b[2]) ^ (i_a[4]&i_b[1]) ^ (i_a[5]&i_b[0]);
	assign o_r[ 4] = (i_a[0]&i_b[4]) ^ (i_a[1]&i_b[3]) ^ (i_a[2]&i_b[2]) ^ (i_a[3]&i_b[1]) ^ (i_a[4]&i_b[0]);
	assign o_r[ 3] = (i_a[0]&i_b[3]) ^ (i_a[1]&i_b[2]) ^ (i_a[2]&i_b[1]) ^ (i_a[3]&i_b[0]);
	assign o_r[ 2] = (i_a[0]&i_b[2]) ^ (i_a[1]&i_b[1]) ^ (i_a[2]&i_b[0]);
	assign o_r[ 1] = (i_a[0]&i_b[1]) ^ (i_a[1]&i_b[0]);
	assign o_r[ 0] = (i_a[0]&i_b[0]);


endmodule

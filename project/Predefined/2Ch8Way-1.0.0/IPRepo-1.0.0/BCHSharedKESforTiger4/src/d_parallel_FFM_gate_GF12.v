//////////////////////////////////////////////////////////////////////////////////
// d_parallel_FFM_gate_GF12.v for Cosmos OpenSSD
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
// Module Name: d_parallel_FFM_gate_GF12
// File Name: d_parallel_FFM_gate_GF12.v
//
// Version: v2.0.2-GF12tB
//
// Description: 
//   - parallel Finite Field Multiplier (FFM) module
//   - 2 polynomial form input, 1 polynomial form output
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v2.0.2
//   - minor modification for releasing
//
// * v2.0.1
//   - re-factoring
//
// * v2.0.0
//   - based on partial multiplication
//   - fixed GF
//
// * v1.0.0
//   - based on LFSR
//   - variable GF by parameter setting
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module d_parallel_FFM_gate_GF12
(
	input  wire [11: 0] i_poly_form_A,     // input term A, polynomial form
	input  wire [11: 0] i_poly_form_B,     // input term B, polynomial form
	
	output wire [11: 0] o_poly_form_result // output term result, polynomial form
);

	///////////////////////////////////////////////////////////
	// CAUTION! CAUTION! CAUTION! CAUTION! CAUTION! CAUTION! //
	//                                                       //
	//      ONLY FOR 12 BIT POLYNOMIAL MULTIPLICATION        //
	//                                                       //
	// CAUTION! CAUTION! CAUTION! CAUTION! CAUTION! CAUTION! //
	///////////////////////////////////////////////////////////
	
	///////////////////////////////////////////////////////////
	// CAUTION! CAUTION! CAUTION! CAUTION! CAUTION! CAUTION! //
	//                                                       //
	// PRIMITIVE POLYNOMIAL                                  //
	//                     P(X) = X^12 + X^7 + X^4 + X^3 + 1 //
	//                                                       //
	// CAUTION! CAUTION! CAUTION! CAUTION! CAUTION! CAUTION! //
	///////////////////////////////////////////////////////////
	
	
	
	
	wire [11: 6] w_p_A1; // partial term A1
	wire [ 5: 0] w_p_A0; // partial term A0
	
	wire [11: 6] w_p_B1; // partial term B1
	wire [ 5: 0] w_p_B0; // partial term B0
	
	wire [16: 6] w_p_r_A1_B0; // partial multiplication result A1*B0
	wire [10: 0] w_p_r_A0_B0; // partial multiplication result A0*B0
	wire [22:12] w_p_r_A1_B1; // partial multiplication result A1*B1
	wire [16: 6] w_p_r_A0_B1; // partial multiplication result A0*B1
	
	wire [22: 0] w_p_r_sum; // multiplication result
	
	
	
	
	assign w_p_A1[11: 6] = i_poly_form_A[11: 6];
	assign w_p_A0[ 5: 0] = i_poly_form_A[ 5: 0];
	
	assign w_p_B1[11: 6] = i_poly_form_B[11: 6];
	assign w_p_B0[ 5: 0] = i_poly_form_B[ 5: 0];
	
	
	
	
	// multipliers for partial multiplication
	
	d_partial_FFM_gate_6b p_mul_A1_B0 (
    .i_a(w_p_A1[11: 6]), 
    .i_b(w_p_B0[ 5: 0]), 
    .o_r(w_p_r_A1_B0[16: 6]));
	
	d_partial_FFM_gate_6b p_mul_A0_B0 (
    .i_a(w_p_A0[ 5: 0]), 
    .i_b(w_p_B0[ 5: 0]), 
    .o_r(w_p_r_A0_B0[10: 0]));
	
	d_partial_FFM_gate_6b p_mul_A1_B1 (
    .i_a(w_p_A1[11: 6]), 
    .i_b(w_p_B1[11: 6]), 
    .o_r(w_p_r_A1_B1[22:12]));
	
	d_partial_FFM_gate_6b p_mul_A0_B1 (
    .i_a(w_p_A0[ 5: 0]), 
    .i_b(w_p_B1[11: 6]), 
    .o_r(w_p_r_A0_B1[16: 6]));
	
	
	
	
	// sum partial results
	
	assign w_p_r_sum[22:17] = w_p_r_A1_B1[22:17];
	assign w_p_r_sum[16:12] = w_p_r_A1_B1[16:12] ^ w_p_r_A0_B1[16:12] ^ w_p_r_A1_B0[16:12];
	assign w_p_r_sum[11]    = w_p_r_A0_B1[11]    ^ w_p_r_A1_B0[11];
	assign w_p_r_sum[10: 6] = w_p_r_A0_B1[10: 6] ^ w_p_r_A1_B0[10: 6] ^ w_p_r_A0_B0[10: 6];
	assign w_p_r_sum[ 5: 0] = w_p_r_A0_B0[ 5: 0];
	
	
	
	
	// reduce high order terms
	
	assign o_poly_form_result[11] = w_p_r_sum[11] ^ w_p_r_sum[16] ^ w_p_r_sum[19] ^ w_p_r_sum[20] ^ w_p_r_sum[21];
	assign o_poly_form_result[10] = w_p_r_sum[10] ^ w_p_r_sum[15] ^ w_p_r_sum[18] ^ w_p_r_sum[19] ^ w_p_r_sum[20] ^ w_p_r_sum[22];
	assign o_poly_form_result[ 9] = w_p_r_sum[ 9] ^ w_p_r_sum[14] ^ w_p_r_sum[17] ^ w_p_r_sum[18] ^ w_p_r_sum[19] ^ w_p_r_sum[21];
	assign o_poly_form_result[ 8] = w_p_r_sum[ 8] ^ w_p_r_sum[13] ^ w_p_r_sum[16] ^ w_p_r_sum[17] ^ w_p_r_sum[18] ^ w_p_r_sum[20];
	assign o_poly_form_result[ 7] = w_p_r_sum[ 7] ^ w_p_r_sum[12] ^ w_p_r_sum[15] ^ w_p_r_sum[16] ^ w_p_r_sum[17] ^ w_p_r_sum[19] ^ w_p_r_sum[22];
	assign o_poly_form_result[ 6] = w_p_r_sum[ 6] ^ w_p_r_sum[14] ^ w_p_r_sum[15] ^ w_p_r_sum[18] ^ w_p_r_sum[19] ^ w_p_r_sum[20] ^ w_p_r_sum[22];
	assign o_poly_form_result[ 5] = w_p_r_sum[ 5] ^ w_p_r_sum[13] ^ w_p_r_sum[14] ^ w_p_r_sum[17] ^ w_p_r_sum[18] ^ w_p_r_sum[19] ^ w_p_r_sum[21] ^ w_p_r_sum[22];
	assign o_poly_form_result[ 4] = w_p_r_sum[ 4] ^ w_p_r_sum[12] ^ w_p_r_sum[13] ^ w_p_r_sum[16] ^ w_p_r_sum[17] ^ w_p_r_sum[18] ^ w_p_r_sum[20] ^ w_p_r_sum[21];
	assign o_poly_form_result[ 3] = w_p_r_sum[ 3] ^ w_p_r_sum[12] ^ w_p_r_sum[15] ^ w_p_r_sum[17] ^ w_p_r_sum[21] ^ w_p_r_sum[22];
	assign o_poly_form_result[ 2] = w_p_r_sum[ 2] ^ w_p_r_sum[14] ^ w_p_r_sum[19] ^ w_p_r_sum[22];
	assign o_poly_form_result[ 1] = w_p_r_sum[ 1] ^ w_p_r_sum[13] ^ w_p_r_sum[18] ^ w_p_r_sum[21] ^ w_p_r_sum[22];
	assign o_poly_form_result[ 0] = w_p_r_sum[ 0] ^ w_p_r_sum[12] ^ w_p_r_sum[17] ^ w_p_r_sum[20] ^ w_p_r_sum[21] ^ w_p_r_sum[22];
	

endmodule

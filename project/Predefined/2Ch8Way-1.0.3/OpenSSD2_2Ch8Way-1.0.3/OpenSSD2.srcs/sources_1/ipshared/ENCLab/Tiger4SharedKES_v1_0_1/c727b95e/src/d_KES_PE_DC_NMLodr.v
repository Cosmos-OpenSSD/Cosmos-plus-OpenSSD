//////////////////////////////////////////////////////////////////////////////////
// d_KES_PE_DC_NMLodr.v for Cosmos OpenSSD
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
// Module Name: d_KES_PE_DC_NMLodr
// File Name: d_KES_PE_DC_NMLodr.v
//
// Version: v1.1.1-256B_T14
//
// Description: 
//   - Processing Element: Discrepancy Computation module, normal order
//   - for binary version of inversion-less Berlekamp-Massey algorithm (iBM.b)
//   - for data area
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.1.1
//   - minor modification for releasing
//
// * v1.1.0
//   - change state machine: divide states
//   - insert additional registers
//   - improve frequency characteristic
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////

`include "d_KES_parameters.vh"
`timescale 1ns / 1ps

module d_KES_PE_DC_NMLodr // discrepancy computation module: normal order
(
	input  wire                       i_clk,
	input  wire                       i_RESET_KES,
	input  wire						  i_stop_dec,
	
	input  wire                       i_EXECUTE_PE_DC,
	
	input  wire [`D_KES_GF_ORDER-1:0] i_S_in,
    input  wire [`D_KES_GF_ORDER-1:0] i_v_2i_X,
    
	output wire [`D_KES_GF_ORDER-1:0] o_S_out,
    output wire  [`D_KES_GF_ORDER-1:0] o_coef_2ip1
);
	
	parameter [11:0] D_KES_VALUE_ZERO = 12'b0000_0000_0000;
	parameter [11:0] D_KES_VALUE_ONE = 12'b0000_0000_0001;
	
	// FSM parameters
	parameter PE_DC_RST = 2'b01; // reset
	parameter PE_DC_INP = 2'b10; // input capture
	
	
	
	// variable declaration
	reg [1:0] r_cur_state;
	reg [1:0] r_nxt_state;
	
	reg  [`D_KES_GF_ORDER-1:0] r_S_in_b;
    reg  [`D_KES_GF_ORDER-1:0] r_v_2i_X_b;
	wire [`D_KES_GF_ORDER-1:0] w_coef_term;
	
	
	
	// update current state to next state
	always @ (posedge i_clk)
	begin
		if ((i_RESET_KES) || (i_stop_dec)) begin
			r_cur_state <= PE_DC_RST;
		end else begin
			r_cur_state <= r_nxt_state;
		end
	end
	
	// decide next state
	always @ ( * )
	begin
		case (r_cur_state)
		PE_DC_RST: begin
			r_nxt_state <= (i_EXECUTE_PE_DC)? (PE_DC_INP):(PE_DC_RST);
		end
		PE_DC_INP: begin
			r_nxt_state <= PE_DC_RST;
		end
		default: begin
			r_nxt_state <= PE_DC_RST;
		end
		endcase
	end

	// state behaviour
	always @ (posedge i_clk)
	begin
		if ((i_RESET_KES) || (i_stop_dec)) begin // initializing
			r_S_in_b <= 0;
			r_v_2i_X_b <= 0;
			
		end
		
		else begin		
			case (r_nxt_state)
			PE_DC_RST: begin // hold original data
				r_S_in_b <= r_S_in_b;
				r_v_2i_X_b <= r_v_2i_X_b;
				
			end
			PE_DC_INP: begin // input capture only
				r_S_in_b <= i_S_in;
				r_v_2i_X_b <= i_v_2i_X;
				
			end
			default: begin
				r_S_in_b <= r_S_in_b;
				r_v_2i_X_b <= r_v_2i_X_b;
				
			end
			endcase
		end
	end	
	
	
	
	d_parallel_FFM_gate_GF12 d_S_in_FFM_v_2i_X (
    .i_poly_form_A     (r_S_in_b[`D_KES_GF_ORDER-1:0]), 
    .i_poly_form_B     (r_v_2i_X_b[`D_KES_GF_ORDER-1:0]), 
    .o_poly_form_result(w_coef_term[`D_KES_GF_ORDER-1:0]));
	
	
	
	assign o_S_out[`D_KES_GF_ORDER-1:0] = r_S_in_b[`D_KES_GF_ORDER-1:0];
    assign o_coef_2ip1 = w_coef_term;
	
endmodule

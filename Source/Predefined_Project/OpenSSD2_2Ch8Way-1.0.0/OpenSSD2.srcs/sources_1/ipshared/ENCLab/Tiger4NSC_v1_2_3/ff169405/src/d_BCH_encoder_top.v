//////////////////////////////////////////////////////////////////////////////////
// d_BCH_encoder_top.v for Cosmos OpenSSD
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
// Module Name: d_BCH_encoder_top
// File Name: d_BCH_encoder_top.v
//
// Version: v1.0.1-256B_T14
//
// Description: 
//   - BCH encoder TOP module
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

module d_BCH_encoder_top
(
	input  wire                        i_clk,
	input  wire                        i_nRESET,
	
	input  wire                        i_exe_encoding,      // execute encoding, encoding start command signal
	input  wire                        i_message_valid,     // message BUS strobe signal
	input  wire [`D_BCH_ENC_P_LVL-1:0] i_message,           // message block data BUS
    output reg                         o_message_ready,
	
	output wire                        o_encoding_start,    // [indicate] encoding start
	output wire                        o_last_m_block_rcvd, // [indicate] last message block received
	output wire                        o_encoding_cmplt,    // [indicate] encoding complete
	
    input  wire                        i_parity_ready,
	output wire                        o_parity_valid, // [indicate] parity BUS strobe signal
	output wire                        o_parity_out_start,  // [indicate] parity block out start
	output wire                        o_parity_out_cmplt,  // [indicate] last parity block transmitted
	
	output wire [`D_BCH_ENC_P_LVL-1:0] o_parity_out         // parity block data BUS
);

	parameter D_BCH_ENC_FSM_BIT = 7;
	parameter RESET   = 7'b0000001; // RESET: encoder sequence reset
	parameter ENCD_ST = 7'b0000010; // encoder: start mode, compute parity
	parameter ENCD_FB = 7'b0000100;
    parameter P_O_STR = 7'b0001000; // encoder: feedback mode, compute parity
	parameter P_O_STBY = 7'b0010000; // parity out: first block
	parameter P_O_SHF = 7'b0100000; // parity out: shifted block
	parameter MSG_T_P = 7'b1000000; // encoder: message transmit paused (message BUS invalid)
	
	
	// registered input
	reg  [`D_BCH_ENC_P_LVL-1:0]      r_message_b;
	
	// encoder FSM state
	reg  [D_BCH_ENC_FSM_BIT-1:0]     r_cur_state;
	reg  [D_BCH_ENC_FSM_BIT-1:0]     r_nxt_state;
	
	// internal counter
	reg  [`D_BCH_ENC_I_CNT_BIT-1:0]  r_counter;
	
	// registers for parity code
	reg  [`D_BCH_ENC_PRT_LENGTH-1:0] r_parity_code;
	wire [`D_BCH_ENC_PRT_LENGTH-1:0] w_nxt_parity_code;
	wire                             w_valid_execution;
	
	
	
	////////////////////////////////////////////////////////////////////////////////
	// modified(improved) linear feedback shift XOR matrix
	// LFSR = LFSXOR + register
	d_parallel_m_lfs_XOR d_mLFSXOR_matrix (
	.i_message   (r_message_b), 
	.i_cur_parity(r_parity_code), 
	.o_nxt_parity(w_nxt_parity_code));
	////////////////////////////////////////////////////////////////////////////////
	
	
	
	// generate control/indicate signal
	assign w_valid_execution = i_exe_encoding & i_message_valid;
	
	assign o_encoding_start = (r_cur_state == ENCD_ST);
	assign o_last_m_block_rcvd = (i_message_valid == 1) & (r_counter == `D_BCH_ENC_I_CNT-1);
	assign o_encoding_cmplt = (r_counter == `D_BCH_ENC_I_CNT);
	
	assign o_parity_valid = (r_cur_state == P_O_STR) | (r_cur_state == P_O_SHF) | (r_cur_state == P_O_STBY);
	assign o_parity_out_start = (r_cur_state == P_O_STR);
	assign o_parity_out_cmplt = ((r_cur_state == P_O_SHF) | (r_cur_state == P_O_STBY)) & (r_counter == `D_BCH_ENC_O_CNT-1) & (i_parity_ready & o_parity_valid);
	
	// parity output
	assign o_parity_out = (o_parity_valid)? r_parity_code[`D_BCH_ENC_PRT_LENGTH-1 : `D_BCH_ENC_PRT_LENGTH-`D_BCH_ENC_P_LVL]:0;
	
	
	
	// update current state to next state
	always @ (posedge i_clk, negedge i_nRESET)
	begin
		if (!i_nRESET) begin
			r_cur_state <= RESET;
		end else begin
			r_cur_state <= r_nxt_state;
		end
	end	
	
	// decide next state
	always @ ( * )
	begin
		case (r_cur_state)
		RESET: begin
			r_nxt_state <= (w_valid_execution)? (ENCD_ST):(RESET);
		end
		ENCD_ST: begin
			r_nxt_state <= (i_message_valid)? (ENCD_FB):(MSG_T_P);
		end
		ENCD_FB: begin
			r_nxt_state <= (o_encoding_cmplt)? (P_O_STR):
														((i_message_valid)? (ENCD_FB):(MSG_T_P));
		end
		P_O_STR: begin
			r_nxt_state <= (!i_parity_ready) ? (P_O_STBY) : (P_O_SHF);
		end
		P_O_SHF: begin
			r_nxt_state <= (!i_parity_ready) ? (P_O_STBY):((o_parity_out_cmplt) ? (RESET) : (P_O_SHF));//((w_valid_execution)? (ENCD_ST):(RESET)):(P_O_SHF));
		end
		MSG_T_P: begin
			r_nxt_state <= (i_message_valid)? (ENCD_FB):(MSG_T_P);
		end
		P_O_STBY: begin
			r_nxt_state <= (i_parity_ready)?((o_parity_out_cmplt) ? /*((w_valid_execution)? (ENCD_ST):(RESET))*/(RESET) : (P_O_SHF)) : (P_O_STBY);  
			end
		default: begin
			r_nxt_state <= RESET;
		end
		endcase
	end
    
    always @ (posedge i_clk, negedge i_nRESET)
    begin
        if (!i_nRESET)
            o_message_ready <= 1;
        else
            case (r_nxt_state)
            RESET:
                o_message_ready <= 1;
            ENCD_FB:
                o_message_ready <= (o_last_m_block_rcvd) ? 0 : 1;
            endcase
    end
    
	// state behaviour
	always @ (posedge i_clk, negedge i_nRESET)
	begin
		if (!i_nRESET) begin
			r_counter <= 0;
			r_message_b <= 0;
			r_parity_code <= 0;
		end
		
		else begin		
			case (r_nxt_state)
			RESET: begin
				r_counter <= 0;
				r_message_b <= 0;
				r_parity_code <= 0;
			end
			ENCD_ST: begin
				r_counter <= 1;
				r_message_b <= i_message;
				r_parity_code <= 0;
			end
			ENCD_FB: begin
				r_counter <= r_counter + 1'b1;
				r_message_b <= i_message;
				r_parity_code <= w_nxt_parity_code;
			end
			P_O_STR: begin
				r_counter <= 0;
				r_message_b <= 0;
				r_parity_code <= w_nxt_parity_code;
			end
			P_O_SHF: begin
				r_counter <= r_counter + 1'b1;
				r_message_b <= 0;
				r_parity_code <= r_parity_code << `D_BCH_ENC_P_LVL;
			end
			MSG_T_P: begin
				r_counter <= r_counter;
				r_message_b <= r_message_b;
				r_parity_code <= r_parity_code;
			end
			P_O_STBY: begin
				r_counter <= r_counter;
				r_message_b <= 0;
				r_parity_code <= r_parity_code;
				end
			default: begin
				r_counter <= 0;
				r_message_b <= 0;
				r_parity_code <= 0;
			end
			endcase
		end
	end
	
endmodule

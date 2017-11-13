//////////////////////////////////////////////////////////////////////////////////
// CRC_checker.v for Cosmos OpenSSD
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
// Design Name: BCH decoder
// Module Name: CRC_checker
// File Name: CRC_checker.v
//
// Version: v1.0.0
//
// Description: Cyclic redundancy check (CRC) decoder
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
module	CRC_Checker
#(
	parameter	DATA_WIDTH			= 32,
	parameter	HASH_LENGTH			= 64,
	parameter	INPUT_COUNT_BITS	= 13,
	parameter	INPUT_COUNT			= 4352
)
(
	i_clk               ,
	i_RESET             ,
	                    
	i_execute_crc_chk   ,
	i_message_valid     ,
	i_message           ,
	                    
	o_crc_chk_start     ,
	o_last_message      ,
	o_crc_chk_complete  ,
	                    
	o_parity_chk        
);
	input						i_clk               ;
	input						i_RESET             ;
						                            
	input						i_execute_crc_chk   ;
	input						i_message_valid     ;
	input	[DATA_WIDTH-1:0]	i_message           ;
	                                                
	output						o_crc_chk_start     ;
	output						o_last_message      ;
	output						o_crc_chk_complete  ;
						                            
	output						o_parity_chk        ;
	
	localparam	CRC_CHK_FSM_BIT				= 5;
	localparam	CrcChkReset					= 5'b00001;
	localparam	CrcChkStart                 = 5'b00010;
	localparam	CrcChkFeedBack              = 5'b00100;
	localparam	CrcChkMessageTransferPause  = 5'b01000;
	localparam	CrcChkParityCheck           = 5'b10000;
	
	reg		[DATA_WIDTH-1:0]		r_message			;
	
	reg		[CRC_CHK_FSM_BIT-1:0]	r_cur_state			;
	reg		[CRC_CHK_FSM_BIT-1:0]	r_next_state		;
	
	reg		[INPUT_COUNT_BITS-1:0]	r_counter			;
	
	reg		[HASH_LENGTH-1:0]		r_parity_code		;
	wire	[HASH_LENGTH-1:0]		w_next_parity_code	;
	wire							w_valid_execution	;
	
	CRC_parallel_m_lfs_XOR
	#(
		.DATA_WIDTH		(DATA_WIDTH	),	
		.HASH_LENGTH	(HASH_LENGTH)
	)
	CRC_mLFSXOR_matrix (
	.i_message		(r_message		),
	.i_cur_parity	(r_parity_code	),
	.o_next_parity	(w_next_parity_code));
	
	assign	w_valid_execution	=	i_execute_crc_chk & i_message_valid;
	
	assign 	o_crc_chk_start		=	(r_cur_state == CrcChkStart);
	assign 	o_last_message		=	(i_message_valid == 1) & (r_counter == INPUT_COUNT-1);
	assign	o_crc_chk_complete	=	(r_counter == INPUT_COUNT);
	assign	o_parity_chk		=	(r_counter == INPUT_COUNT)? (|w_next_parity_code): 0;
	
	always @ (posedge i_clk)
	begin
		if (i_RESET)
			r_cur_state <= CrcChkReset;
		else
			r_cur_state <= r_next_state;
	end
	
	always @ (*)
	begin
		case (r_cur_state)
		CrcChkReset:
			r_next_state <= (w_valid_execution) ? (CrcChkStart) : (CrcChkReset);
		CrcChkStart:               
			r_next_state <= (i_message_valid) ? (CrcChkFeedBack) : (CrcChkMessageTransferPause);
		CrcChkFeedBack:            
			r_next_state <= (o_crc_chk_complete) ? (CrcChkParityCheck) :
							((i_message_valid) ? (CrcChkFeedBack) : (CrcChkMessageTransferPause));
	    CrcChkMessageTransferPause:
			r_next_state <= (i_message_valid) ? (CrcChkFeedBack) : (CrcChkMessageTransferPause);
        CrcChkParityCheck:
			r_next_state <= CrcChkReset;
		default:
			r_next_state <= CrcChkReset;
		endcase
	end
	
	always @ (posedge i_clk)
	begin
		if (i_RESET) begin
			r_counter <= 0;
			r_message <= 0;
			r_parity_code <= 0;
		end
		
		else begin
			case (r_next_state)
			CrcChkReset: begin
				r_counter <= 0;
				r_message <= 0;
				r_parity_code <= 0;
			end
			CrcChkStart: begin
				r_counter <= 1;
				r_message <= i_message;
				r_parity_code <= 0;
			end
			CrcChkFeedBack: begin
				r_counter <= r_counter + 1'b1;
				r_message <= i_message;
				r_parity_code <= w_next_parity_code;
			end
			CrcChkMessageTransferPause: begin
				r_counter <= r_counter;
				r_message <= r_message;
				r_parity_code <= r_parity_code;
			end
			CrcChkParityCheck: begin
				r_counter <= 0;
				r_message <= 0;
				r_parity_code <= w_next_parity_code;
			end
			default: begin
				r_counter <= 0;
				r_message <= 0;
				r_parity_code <= 0;
			end
			endcase
		end
	end
endmodule
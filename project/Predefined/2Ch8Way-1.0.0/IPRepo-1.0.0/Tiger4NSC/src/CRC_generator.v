//////////////////////////////////////////////////////////////////////////////////
// CRC_generator.v for Cosmos OpenSSD
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
// Design Name: BCH encoder
// Module Name: CRC_generator
// File Name: CRC_generator.v
//
// Version: v1.0.0
//
// Description: Cyclic redundancy check (CRC) encoder
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
module CRC_Generator
#(
	parameter	DATA_WIDTH			= 32,
	parameter	HASH_LENGTH			= 64,
	parameter	INPUT_COUNT_BITS	= 13,
	parameter	INPUT_COUNT			= 4158,
	parameter	OUTPUT_COUNT		= 2
)	
(
	i_clk         			,
	i_nRESET        		,
						
	i_execute_crc_gen 		,
	i_message_valid  		,
	i_message       		,
	i_out_pause				,
						
	o_crc_gen_start    		,
	o_last_message   		,
	o_crc_gen_complete 		,
	o_crc_spare_switch		,
						
	o_parity_out_strobe		,
	o_parity_out_start		,
	o_parity_out_complete	,
	o_parity_out            ,
    o_crc_available
);
	input						i_clk          				;
	input						i_nRESET         			;
														
	input						i_execute_crc_gen 			;
	input						i_message_valid   			;
	input	[DATA_WIDTH-1:0]	i_message        			;
	input						i_out_pause					;
														
	output						o_crc_gen_start     		;
	output						o_last_message    			;
	output						o_crc_gen_complete  		;
	output                      o_crc_spare_switch          ;
														
	output						o_parity_out_strobe			;
	output						o_parity_out_start			;
	output						o_parity_out_complete		;
	output	[DATA_WIDTH-1:0]	o_parity_out      			;
    output                      o_crc_available             ;
		
	localparam	CRC_GEN_FSM_BIT 			= 7				;
	localparam	CrcGenReset 				= 7'b0000001	;
	localparam	CrcGenStart 				= 7'b0000010	;
	localparam	CrcGenFeedBack 				= 7'b0000100	;
	localparam  CrcGenMessageTransferPause 	= 7'b0001000	;
	localparam	CrcGenParityOutStart		= 7'b0010000	;
	localparam	CrcGenParityOutShift		= 7'b0100000	;
	localparam	CrcGenParityOutPause		= 7'b1000000	;
		
	reg		[DATA_WIDTH-1:0]		r_message				;
		
	reg		[CRC_GEN_FSM_BIT-1:0]	r_cur_state				;
	reg		[CRC_GEN_FSM_BIT-1:0]	r_next_state			;
		
	reg		[INPUT_COUNT_BITS-1:0]	r_counter				;
		
	reg		[HASH_LENGTH-1:0]		r_parity_code			;
	wire	[HASH_LENGTH-1:0]		w_next_parity_code		;
	wire							w_valid_execution		;
    reg                             r_crc_available         ;
    reg                             r_parity_out_complete   ;
	
	CRC_parallel_m_lfs_XOR
	#(
		.DATA_WIDTH		(DATA_WIDTH	),	
		.HASH_LENGTH	(HASH_LENGTH)
	)
	CRC_mLFSXOR_matrix (
	.i_message		(r_message		),
	.i_cur_parity	(r_parity_code	),
	.o_next_parity	(w_next_parity_code));
	
	assign w_valid_execution 		=	i_execute_crc_gen & i_message_valid;
		
	assign o_crc_gen_start			=	(r_cur_state == CrcGenStart);
	assign o_last_message			=	(i_message_valid == 1) & (r_counter == INPUT_COUNT-1);
	assign o_crc_gen_complete		=	(r_counter == INPUT_COUNT);
    assign o_crc_spare_switch       =   (i_message_valid) & (r_counter == INPUT_COUNT-1);
    
	assign o_parity_out_strobe 		= 	(r_cur_state == CrcGenParityOutStart) |	(r_cur_state == CrcGenParityOutShift) | (r_cur_state == CrcGenParityOutPause);
	assign o_parity_out_start		=	(r_cur_state == CrcGenParityOutStart);
	assign o_parity_out_complete	=	r_parity_out_complete;
	// parity output
	assign o_parity_out 			= 	(o_parity_out_strobe)? r_parity_code[HASH_LENGTH - 1 : HASH_LENGTH - DATA_WIDTH]:0;
	assign o_crc_available          =   r_crc_available;
	
	always @ (posedge i_clk, negedge i_nRESET)
	begin
		if (!i_nRESET) 
			r_cur_state <= CrcGenReset;
		else 
			r_cur_state <= r_next_state;
	end
	
	always @ (*)
	begin
		case (r_cur_state)
		CrcGenReset:
			r_next_state <= (w_valid_execution) ? (CrcGenStart) : (CrcGenReset);
		CrcGenStart:
			r_next_state <= (i_message_valid) ? (CrcGenFeedBack) : (CrcGenMessageTransferPause);
		CrcGenFeedBack:
			r_next_state <= (o_crc_gen_complete) ? (CrcGenParityOutStart) :
							((i_message_valid) ? (CrcGenFeedBack) : (CrcGenMessageTransferPause));
		CrcGenMessageTransferPause:
			r_next_state <= (i_message_valid) ? (CrcGenFeedBack) : (CrcGenMessageTransferPause);
		CrcGenParityOutStart:
			r_next_state <= (i_out_pause) ? (CrcGenParityOutPause) : (CrcGenParityOutShift);
		CrcGenParityOutShift:
			r_next_state <= (i_out_pause) ? (CrcGenParityOutPause) :
							((o_parity_out_complete) ? (CrcGenReset) : (CrcGenParityOutShift));
		CrcGenParityOutPause:
			r_next_state <= (i_out_pause) ? (CrcGenParityOutPause) :
							((o_parity_out_complete) ? (CrcGenReset) : (CrcGenParityOutShift));
		default: 
			r_next_state <= CrcGenReset;
		endcase
	end
	
	always @ (posedge i_clk, negedge i_nRESET)
	begin
		if (!i_nRESET) begin
			r_counter <= 0;
			r_message <= 0;
			r_parity_code <= 0;
            r_crc_available <= 1;
            r_parity_out_complete <= 0;
		end
		
		else begin
			case (r_next_state)
			CrcGenReset: begin
				r_counter <= 0;
				r_message <= 0;
				r_parity_code <= 0;
                r_crc_available <= 1;
                r_parity_out_complete <= 0;
			end
			CrcGenStart: begin
				r_counter <= 1;
				r_message <= i_message;
				r_parity_code <= 0;
                r_crc_available <= 0;
                r_parity_out_complete <= 0;
			end
			CrcGenFeedBack: begin
				r_counter <= r_counter + 1'b1;
				r_message <= i_message;
				r_parity_code <= w_next_parity_code;
                r_crc_available <= 0;
                r_parity_out_complete <= 0;
			end
			CrcGenMessageTransferPause: begin
				r_counter <= r_counter;
				r_message <= r_message;
				r_parity_code <= r_parity_code;
                r_crc_available <= 0;
                r_parity_out_complete <= 0;
			end
			CrcGenParityOutStart: begin
				r_counter <= 0;
				r_message <= 0;
				r_parity_code <= w_next_parity_code;
                r_crc_available <= 0;
                r_parity_out_complete <= 0;
			end
			CrcGenParityOutShift: begin
				r_counter <= r_counter + 1'b1;
				r_message <= 0;
				r_parity_code <= r_parity_code << DATA_WIDTH;
                r_crc_available <= 0;
                r_parity_out_complete <= (r_counter == OUTPUT_COUNT-1) ? 1 : 0;
			end
			CrcGenParityOutPause: begin
				r_counter <= r_counter;
				r_message <= 0;
				r_parity_code <= r_parity_code;
                r_crc_available <= 0;
                r_parity_out_complete <= (r_counter == OUTPUT_COUNT-1) ? 1 : 0;
			end
			default: begin
				r_counter <= 0;
				r_message <= 0;
				r_parity_code <= 0;
                r_crc_available <= 0;
                r_parity_out_complete <= 0;
			end
		endcase
		end
	end
	
endmodule
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
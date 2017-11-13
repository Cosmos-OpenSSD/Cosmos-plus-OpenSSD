//////////////////////////////////////////////////////////////////////////////////
// d_BCH_SC_top.v for Cosmos OpenSSD
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
// Module Name: d_BCH_SC_top
// File Name: d_BCH_SC_top.v
//
// Version: v2.0.0-256B_T14
//
// Description: Syndrome calculator (SC) top module for data area
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
// * v2.0.0
//   - change state machine: additional signal and state for pipeline
//
// * v1.1.1
//   - minor modification for releasing
//
// * v1.1.0
//   - change state machine: buffered output
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////

`include "d_SC_parameters.vh"
`timescale 1ns / 1ps

module	d_BCH_SC_top(

	input  wire                            	i_clk,
    input  wire                            	i_RESET,
	input  wire								i_stop_dec,
    
	input  wire								i_buf_available,
	input  wire	[4:0]						i_chunk_number,
	
	output wire                            	o_sc_available,       // [indicate] syndrome calculator ready
	
	input  wire                            	i_exe_sc,             // syndrome calculation start command signal
	input  wire                            	i_code_valid,         // code BUS strobe signal
    input  wire [`D_SC_P_LVL-1:0]          	i_code,               // code block data BUS
    output reg                              o_code_ready,
	
	output wire                            	o_sc_start,           // [indicate] syndrome calculation start
    output wire                            	o_last_c_block_rcvd,  // [indicate] last code block received
	output wire                            	o_sc_cmplt,           // [indicate] syndrome calculation complete
    output reg                             	o_error_detected,     // [indicate] ERROR detected
	
	output reg                             	o_BRAM_write_enable,  // BRAM write enable
	output wire [`D_SC_I_CNT_BIT-2:0] 	    o_BRAM_write_address, // BRAM write address
	output wire [`D_SC_P_LVL-1:0]          	o_BRAM_write_data,    // BRAM write data

	output reg	[11:0]						o_chunk_number,

    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_001,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_002,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_003,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_004,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_005,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_006,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_007,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_008,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_009,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_010,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_011,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_012,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_013,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_014,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_015,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_016,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_017,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_018,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_019,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_020,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_021,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_022,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_023,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_024,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_025,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_026,
    output reg [`D_SC_GF_ORDER-1:0] 		o_sdr_027
);
	
	
	
	parameter SC_FSM_BIT = 8;
	parameter RESET_SC   = 8'b0000_0001; // RESET: syndrome calculator sequence reset
	parameter SDR_STwB   = 8'b0000_0010; // syndrome computation: start mode, BRAM write
	parameter SDR_FBwB   = 8'b0000_0100; // syndrome computation: feedback mode, BRAM write
	parameter SDR_FBwoB  = 8'b0000_1000; // syndrome computation: feedback mode
	parameter COD_T_PwB  = 8'b0001_0000; // code transmit paused, BRAM write pause
	parameter COD_T_PwoB = 8'b0010_0000; // code transmit paused
	parameter EVALUATION = 8'b0100_0000; // evaluation stage
	parameter SDR_OUT    = 8'b1000_0000; // syndrome out: finish



    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_001;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_002;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_003;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_004;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_005;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_006;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_007;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_008;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_009;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_010;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_011;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_012;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_013;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_014;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_015;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_016;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_017;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_018;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_019;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_020;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_021;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_022;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_023;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_024;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_025;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_026;
    wire [`D_SC_GF_ORDER-1:0] 	w_evaluated_remainder_027;


	// registered input
	reg  [`D_SC_P_LVL-1:0] r_code_b;
	reg	 [4:0]			   r_chunk_number;
	
	// syndrome calculator FSM state
	reg  [SC_FSM_BIT-1:0] r_cur_state;
	reg  [SC_FSM_BIT-1:0] r_nxt_state;
	
	// internal counter
	reg  [`D_SC_I_CNT_BIT-1:0] r_counter;
	reg  [2:0]                 r_output_counter;
	
	// registers for remainders
	reg  [(`D_SC_ECC_T * `D_SC_GF_ORDER)-1:0] r_remainders;
	wire [(`D_SC_ECC_T * `D_SC_GF_ORDER)-1:0] w_nxt_remainders;
	
	// internal variable
	wire w_valid_execution;
	wire w_BRAM_write_cmplt; // BRAM write complete
	wire w_division_cmplt;   // division complete
	//wire w_output_cmplt;     // output complete
	
	
	
	// generate control/indicate signal
	assign o_sc_available = (r_cur_state == RESET_SC);
	assign w_valid_execution = (i_exe_sc) & (i_code_valid);
	assign o_sc_start = (r_cur_state == SDR_STwB);
	
	assign w_BRAM_write_cmplt = (r_counter == `D_SC_MSG_LENGTH-1);
	assign o_last_c_block_rcvd = (i_code_valid == 1) & (r_counter == `D_SC_I_CNT-2);
	assign w_division_cmplt = (r_counter == `D_SC_I_CNT-1);
	assign o_sc_cmplt = (r_cur_state == SDR_OUT) && (i_buf_available);
	//assign w_output_cmplt = (r_output_counter == 3'b111);
	
	assign o_BRAM_write_address[`D_SC_MSG_LENGTH_BIT-1:0] = r_counter[`D_SC_MSG_LENGTH_BIT-1:0]; // use partial bit
	assign o_BRAM_write_data[`D_SC_P_LVL-1:0] = r_code_b[`D_SC_P_LVL-1:0];
	
	// update current state to next state
	always @ (posedge i_clk)
	begin
		if ((i_RESET) || (i_stop_dec)) begin
			r_cur_state <= RESET_SC;
		end else begin
			r_cur_state <= r_nxt_state;
		end
	end
	
	// decide next state
	always @ ( * )
	begin
		case (r_cur_state)
		RESET_SC: begin
			r_nxt_state <= (w_valid_execution)? (SDR_STwB):(RESET_SC);
		end
		SDR_STwB: begin
			r_nxt_state <= (i_code_valid)? (SDR_FBwB):(COD_T_PwB);
		end
		SDR_FBwB: begin
			r_nxt_state <= (i_code_valid)? ((w_BRAM_write_cmplt)? (SDR_FBwoB):(SDR_FBwB)):
										   ((w_BRAM_write_cmplt)? (COD_T_PwoB):(COD_T_PwB));
		end
		SDR_FBwoB: begin
			r_nxt_state <= (w_division_cmplt)? (EVALUATION):
											  ((i_code_valid)? (SDR_FBwoB):(COD_T_PwoB));
		end
		COD_T_PwB: begin
			r_nxt_state <= (i_code_valid)? (SDR_FBwB):(COD_T_PwB);
		end
		COD_T_PwoB: begin
			r_nxt_state <= (i_code_valid)? (SDR_FBwoB):(COD_T_PwoB);
		end
		EVALUATION: begin
			r_nxt_state <= SDR_OUT;
		end
		SDR_OUT: begin
			r_nxt_state <= (i_buf_available)? (RESET_SC):(SDR_OUT);
		end
		default: begin
			r_nxt_state <= RESET_SC;
		end
		endcase
	end
    
    always @ (posedge i_clk)
    begin
        if (i_RESET)
            o_code_ready <= 1;
        else
            case (r_nxt_state)
            RESET_SC:
                o_code_ready <= 1;
            SDR_FBwoB:
                o_code_ready <= (o_last_c_block_rcvd) ? 0 : 1;
            default:
                o_code_ready <= o_code_ready;
            endcase
    end
    
	// state behaviour
	always @ (posedge i_clk)
	begin
		if (i_RESET || i_stop_dec) begin
			r_code_b <= 0;
			r_remainders <= 0;
			r_counter <= 0;
			o_BRAM_write_enable <= 0;
			r_output_counter <= 0;
		end
		
		else begin		
			case (r_nxt_state)
			RESET_SC: begin
				r_code_b <= 0;
				r_remainders <= 0;
				r_counter <= 0;
				o_BRAM_write_enable <= 0;
				r_output_counter <= 0;
			end
			SDR_STwB: begin
				r_code_b <= i_code;
				r_remainders <= 0;
				r_counter <= 0;
				o_BRAM_write_enable <= 1;
				r_output_counter <= 0;
			end
			SDR_FBwB: begin
				r_code_b <= i_code;
				r_remainders <= w_nxt_remainders;
				r_counter <= r_counter + 1'b1;
				o_BRAM_write_enable <= 1;
				r_output_counter <= 0;
			end
			SDR_FBwoB: begin
				r_code_b <= i_code;
				r_remainders <= w_nxt_remainders;
				r_counter <= r_counter + 1'b1;
				o_BRAM_write_enable <= 0;
				r_output_counter <= 0;
			end
			COD_T_PwB: begin
				r_code_b <= r_code_b;
				r_remainders <= r_remainders;
				r_counter <= r_counter;
				o_BRAM_write_enable <= 0;
				r_output_counter <= 0;
			end
			COD_T_PwoB: begin
				r_code_b <= r_code_b;
				r_remainders <= r_remainders;
				r_counter <= r_counter;
				o_BRAM_write_enable <= 0;
				r_output_counter <= 0;
			end
			EVALUATION: begin
				r_code_b <= 0;
				r_remainders <= w_nxt_remainders;
				r_counter <= 0;
				o_BRAM_write_enable <= 0;
				r_output_counter <= 0;
			end
			SDR_OUT: begin
				r_code_b <= 0;
				r_remainders <= r_remainders;
				r_counter <= 0;
				o_BRAM_write_enable <= 0;
				r_output_counter <= r_output_counter + 1'b1;
			end
			default: begin
				r_code_b <= 0;
				r_remainders <= 0;
				r_counter <= 0;
				o_BRAM_write_enable <= 0;
				r_output_counter <= 0;
			end
			endcase
		end
	end
	
	always @ (posedge i_clk)
	begin
		if (i_RESET || i_stop_dec)
			r_chunk_number <= 0;
		else begin
			case (r_nxt_state)
			RESET_SC:
				r_chunk_number <= 0;
			SDR_STwB:
				r_chunk_number <= i_chunk_number;
			default:
				r_chunk_number <= r_chunk_number;
			endcase
		end
	end
			
			
	always @ (posedge i_clk)
	begin
		if (i_RESET || i_stop_dec) begin
			o_error_detected <= 0;
			o_chunk_number <= 0;

			o_sdr_001 <= 0;
			o_sdr_002 <= 0;
			o_sdr_003 <= 0;
			o_sdr_004 <= 0;
			o_sdr_005 <= 0;
			o_sdr_006 <= 0;
			o_sdr_007 <= 0;
			o_sdr_008 <= 0;
			o_sdr_009 <= 0;
			o_sdr_010 <= 0;
			o_sdr_011 <= 0;
			o_sdr_012 <= 0;
			o_sdr_013 <= 0;
			o_sdr_014 <= 0;
			o_sdr_015 <= 0;
			o_sdr_016 <= 0;
			o_sdr_017 <= 0;
			o_sdr_018 <= 0;
			o_sdr_019 <= 0;
			o_sdr_020 <= 0;
			o_sdr_021 <= 0;
			o_sdr_022 <= 0;
			o_sdr_023 <= 0;
			o_sdr_024 <= 0;
			o_sdr_025 <= 0;
			o_sdr_026 <= 0;
			o_sdr_027 <= 0;
			end
			
			else begin		
			case (r_nxt_state)
			
			SDR_OUT: begin
			o_error_detected <= (|w_evaluated_remainder_001) | (|w_evaluated_remainder_003) | (|w_evaluated_remainder_005) | (|w_evaluated_remainder_007) | (|w_evaluated_remainder_009) | (|w_evaluated_remainder_011) | (|w_evaluated_remainder_013) | (|w_evaluated_remainder_015) | (|w_evaluated_remainder_017) | (|w_evaluated_remainder_019) | (|w_evaluated_remainder_021) | (|w_evaluated_remainder_023) | (|w_evaluated_remainder_025) | (|w_evaluated_remainder_027);
			o_chunk_number <= r_chunk_number;
			
			o_sdr_001 <= w_evaluated_remainder_001;
			o_sdr_002 <= w_evaluated_remainder_002;
			o_sdr_003 <= w_evaluated_remainder_003;
			o_sdr_004 <= w_evaluated_remainder_004;
			o_sdr_005 <= w_evaluated_remainder_005;
			o_sdr_006 <= w_evaluated_remainder_006;
			o_sdr_007 <= w_evaluated_remainder_007;
			o_sdr_008 <= w_evaluated_remainder_008;
			o_sdr_009 <= w_evaluated_remainder_009;
			o_sdr_010 <= w_evaluated_remainder_010;
			o_sdr_011 <= w_evaluated_remainder_011;
			o_sdr_012 <= w_evaluated_remainder_012;
			o_sdr_013 <= w_evaluated_remainder_013;
			o_sdr_014 <= w_evaluated_remainder_014;
			o_sdr_015 <= w_evaluated_remainder_015;
			o_sdr_016 <= w_evaluated_remainder_016;
			o_sdr_017 <= w_evaluated_remainder_017;
			o_sdr_018 <= w_evaluated_remainder_018;
			o_sdr_019 <= w_evaluated_remainder_019;
			o_sdr_020 <= w_evaluated_remainder_020;
			o_sdr_021 <= w_evaluated_remainder_021;
			o_sdr_022 <= w_evaluated_remainder_022;
			o_sdr_023 <= w_evaluated_remainder_023;
			o_sdr_024 <= w_evaluated_remainder_024;
			o_sdr_025 <= w_evaluated_remainder_025;
			o_sdr_026 <= w_evaluated_remainder_026;
			o_sdr_027 <= w_evaluated_remainder_027;
			end
			
			default: begin
			o_error_detected <= 0;
			o_chunk_number <= 0;
			
			o_sdr_001 <= 0;
			o_sdr_002 <= 0;
			o_sdr_003 <= 0;
			o_sdr_004 <= 0;
			o_sdr_005 <= 0;
			o_sdr_006 <= 0;
			o_sdr_007 <= 0;
			o_sdr_008 <= 0;
			o_sdr_009 <= 0;
			o_sdr_010 <= 0;
			o_sdr_011 <= 0;
			o_sdr_012 <= 0;
			o_sdr_013 <= 0;
			o_sdr_014 <= 0;
			o_sdr_015 <= 0;
			o_sdr_016 <= 0;
			o_sdr_017 <= 0;
			o_sdr_018 <= 0;
			o_sdr_019 <= 0;
			o_sdr_020 <= 0;
			o_sdr_021 <= 0;
			o_sdr_022 <= 0;
			o_sdr_023 <= 0;
			o_sdr_024 <= 0;
			o_sdr_025 <= 0;
			o_sdr_026 <= 0;
			o_sdr_027 <= 0;
			end
		
			endcase
		end
	end
    
	
	d_SC_parallel_lfs_XOR_001 d_SC_LFSXOR_matrix_001(
        .i_message(r_code_b),
        .i_cur_remainder(r_remainders[`D_SC_GF_ORDER*(0+1)-1:`D_SC_GF_ORDER*0]),
        .o_nxt_remainder(w_nxt_remainders[`D_SC_GF_ORDER*(0+1)-1:`D_SC_GF_ORDER*0]));

    d_SC_parallel_lfs_XOR_003 d_SC_LFSXOR_matrix_003(
        .i_message(r_code_b),
        .i_cur_remainder(r_remainders[`D_SC_GF_ORDER*(1+1)-1:`D_SC_GF_ORDER*1]),
        .o_nxt_remainder(w_nxt_remainders[`D_SC_GF_ORDER*(1+1)-1:`D_SC_GF_ORDER*1]));

    d_SC_parallel_lfs_XOR_005 d_SC_LFSXOR_matrix_005(
        .i_message(r_code_b),
        .i_cur_remainder(r_remainders[`D_SC_GF_ORDER*(2+1)-1:`D_SC_GF_ORDER*2]),
        .o_nxt_remainder(w_nxt_remainders[`D_SC_GF_ORDER*(2+1)-1:`D_SC_GF_ORDER*2]));

    d_SC_parallel_lfs_XOR_007 d_SC_LFSXOR_matrix_007(
        .i_message(r_code_b),
        .i_cur_remainder(r_remainders[`D_SC_GF_ORDER*(3+1)-1:`D_SC_GF_ORDER*3]),
        .o_nxt_remainder(w_nxt_remainders[`D_SC_GF_ORDER*(3+1)-1:`D_SC_GF_ORDER*3]));

    d_SC_parallel_lfs_XOR_009 d_SC_LFSXOR_matrix_009(
        .i_message(r_code_b),
        .i_cur_remainder(r_remainders[`D_SC_GF_ORDER*(4+1)-1:`D_SC_GF_ORDER*4]),
        .o_nxt_remainder(w_nxt_remainders[`D_SC_GF_ORDER*(4+1)-1:`D_SC_GF_ORDER*4]));

    d_SC_parallel_lfs_XOR_011 d_SC_LFSXOR_matrix_011(
        .i_message(r_code_b),
        .i_cur_remainder(r_remainders[`D_SC_GF_ORDER*(5+1)-1:`D_SC_GF_ORDER*5]),
        .o_nxt_remainder(w_nxt_remainders[`D_SC_GF_ORDER*(5+1)-1:`D_SC_GF_ORDER*5]));

    d_SC_parallel_lfs_XOR_013 d_SC_LFSXOR_matrix_013(
        .i_message(r_code_b),
        .i_cur_remainder(r_remainders[`D_SC_GF_ORDER*(6+1)-1:`D_SC_GF_ORDER*6]),
        .o_nxt_remainder(w_nxt_remainders[`D_SC_GF_ORDER*(6+1)-1:`D_SC_GF_ORDER*6]));

    d_SC_parallel_lfs_XOR_015 d_SC_LFSXOR_matrix_015(
        .i_message(r_code_b),
        .i_cur_remainder(r_remainders[`D_SC_GF_ORDER*(7+1)-1:`D_SC_GF_ORDER*7]),
        .o_nxt_remainder(w_nxt_remainders[`D_SC_GF_ORDER*(7+1)-1:`D_SC_GF_ORDER*7]));

    d_SC_parallel_lfs_XOR_017 d_SC_LFSXOR_matrix_017(
        .i_message(r_code_b),
        .i_cur_remainder(r_remainders[`D_SC_GF_ORDER*(8+1)-1:`D_SC_GF_ORDER*8]),
        .o_nxt_remainder(w_nxt_remainders[`D_SC_GF_ORDER*(8+1)-1:`D_SC_GF_ORDER*8]));

    d_SC_parallel_lfs_XOR_019 d_SC_LFSXOR_matrix_019(
        .i_message(r_code_b),
        .i_cur_remainder(r_remainders[`D_SC_GF_ORDER*(9+1)-1:`D_SC_GF_ORDER*9]),
        .o_nxt_remainder(w_nxt_remainders[`D_SC_GF_ORDER*(9+1)-1:`D_SC_GF_ORDER*9]));

    d_SC_parallel_lfs_XOR_021 d_SC_LFSXOR_matrix_021(
        .i_message(r_code_b),
        .i_cur_remainder(r_remainders[`D_SC_GF_ORDER*(10+1)-1:`D_SC_GF_ORDER*10]),
        .o_nxt_remainder(w_nxt_remainders[`D_SC_GF_ORDER*(10+1)-1:`D_SC_GF_ORDER*10]));

    d_SC_parallel_lfs_XOR_023 d_SC_LFSXOR_matrix_023(
        .i_message(r_code_b),
        .i_cur_remainder(r_remainders[`D_SC_GF_ORDER*(11+1)-1:`D_SC_GF_ORDER*11]),
        .o_nxt_remainder(w_nxt_remainders[`D_SC_GF_ORDER*(11+1)-1:`D_SC_GF_ORDER*11]));

    d_SC_parallel_lfs_XOR_025 d_SC_LFSXOR_matrix_025(
        .i_message(r_code_b),
        .i_cur_remainder(r_remainders[`D_SC_GF_ORDER*(12+1)-1:`D_SC_GF_ORDER*12]),
        .o_nxt_remainder(w_nxt_remainders[`D_SC_GF_ORDER*(12+1)-1:`D_SC_GF_ORDER*12]));

    d_SC_parallel_lfs_XOR_027 d_SC_LFSXOR_matrix_027(
        .i_message(r_code_b),
        .i_cur_remainder(r_remainders[`D_SC_GF_ORDER*(13+1)-1:`D_SC_GF_ORDER*13]),
        .o_nxt_remainder(w_nxt_remainders[`D_SC_GF_ORDER*(13+1)-1:`D_SC_GF_ORDER*13]));




    d_SC_evaluation_matrix_001 d_SC_EM_001 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(0+1)-1:`D_SC_GF_ORDER*0]),
        .o_out(w_evaluated_remainder_001) );

    d_SC_evaluation_matrix_002 d_SC_EM_002 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(0+1)-1:`D_SC_GF_ORDER*0]),
        .o_out(w_evaluated_remainder_002) );

    d_SC_evaluation_matrix_003 d_SC_EM_003 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(1+1)-1:`D_SC_GF_ORDER*1]),
        .o_out(w_evaluated_remainder_003) );

    d_SC_evaluation_matrix_004 d_SC_EM_004 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(0+1)-1:`D_SC_GF_ORDER*0]),
        .o_out(w_evaluated_remainder_004) );

    d_SC_evaluation_matrix_005 d_SC_EM_005 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(2+1)-1:`D_SC_GF_ORDER*2]),
        .o_out(w_evaluated_remainder_005) );

    d_SC_evaluation_matrix_006 d_SC_EM_006 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(1+1)-1:`D_SC_GF_ORDER*1]),
        .o_out(w_evaluated_remainder_006) );

    d_SC_evaluation_matrix_007 d_SC_EM_007 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(3+1)-1:`D_SC_GF_ORDER*3]),
        .o_out(w_evaluated_remainder_007) );

    d_SC_evaluation_matrix_008 d_SC_EM_008 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(0+1)-1:`D_SC_GF_ORDER*0]),
        .o_out(w_evaluated_remainder_008) );

    d_SC_evaluation_matrix_009 d_SC_EM_009 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(4+1)-1:`D_SC_GF_ORDER*4]),
        .o_out(w_evaluated_remainder_009) );

    d_SC_evaluation_matrix_010 d_SC_EM_010 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(2+1)-1:`D_SC_GF_ORDER*2]),
        .o_out(w_evaluated_remainder_010) );

    d_SC_evaluation_matrix_011 d_SC_EM_011 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(5+1)-1:`D_SC_GF_ORDER*5]),
        .o_out(w_evaluated_remainder_011) );

    d_SC_evaluation_matrix_012 d_SC_EM_012 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(1+1)-1:`D_SC_GF_ORDER*1]),
        .o_out(w_evaluated_remainder_012) );

    d_SC_evaluation_matrix_013 d_SC_EM_013 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(6+1)-1:`D_SC_GF_ORDER*6]),
        .o_out(w_evaluated_remainder_013) );

    d_SC_evaluation_matrix_014 d_SC_EM_014 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(3+1)-1:`D_SC_GF_ORDER*3]),
        .o_out(w_evaluated_remainder_014) );

    d_SC_evaluation_matrix_015 d_SC_EM_015 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(7+1)-1:`D_SC_GF_ORDER*7]),
        .o_out(w_evaluated_remainder_015) );

    d_SC_evaluation_matrix_016 d_SC_EM_016 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(0+1)-1:`D_SC_GF_ORDER*0]),
        .o_out(w_evaluated_remainder_016) );

    d_SC_evaluation_matrix_017 d_SC_EM_017 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(8+1)-1:`D_SC_GF_ORDER*8]),
        .o_out(w_evaluated_remainder_017) );

    d_SC_evaluation_matrix_018 d_SC_EM_018 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(4+1)-1:`D_SC_GF_ORDER*4]),
        .o_out(w_evaluated_remainder_018) );

    d_SC_evaluation_matrix_019 d_SC_EM_019 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(9+1)-1:`D_SC_GF_ORDER*9]),
        .o_out(w_evaluated_remainder_019) );

    d_SC_evaluation_matrix_020 d_SC_EM_020 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(2+1)-1:`D_SC_GF_ORDER*2]),
        .o_out(w_evaluated_remainder_020) );

    d_SC_evaluation_matrix_021 d_SC_EM_021 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(10+1)-1:`D_SC_GF_ORDER*10]),
        .o_out(w_evaluated_remainder_021) );

    d_SC_evaluation_matrix_022 d_SC_EM_022 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(5+1)-1:`D_SC_GF_ORDER*5]),
        .o_out(w_evaluated_remainder_022) );

    d_SC_evaluation_matrix_023 d_SC_EM_023 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(11+1)-1:`D_SC_GF_ORDER*11]),
        .o_out(w_evaluated_remainder_023) );

    d_SC_evaluation_matrix_024 d_SC_EM_024 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(1+1)-1:`D_SC_GF_ORDER*1]),
        .o_out(w_evaluated_remainder_024) );

    d_SC_evaluation_matrix_025 d_SC_EM_025 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(12+1)-1:`D_SC_GF_ORDER*12]),
        .o_out(w_evaluated_remainder_025) );

    d_SC_evaluation_matrix_026 d_SC_EM_026 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(6+1)-1:`D_SC_GF_ORDER*6]),
        .o_out(w_evaluated_remainder_026) );

    d_SC_evaluation_matrix_027 d_SC_EM_027 (
        .i_in(r_remainders[`D_SC_GF_ORDER*(13+1)-1:`D_SC_GF_ORDER*13]),
        .o_out(w_evaluated_remainder_027) );

endmodule



//////////////////////////////////////////////////////////////////////////////////
// d_KES_CS_buffer.v for Cosmos OpenSSD
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
// Design Name: BCH decoder (page decoder) ELP buffer
// Module Name: d_KES_CS_buffer
// File Name: d_KES_CS_buffer.v
//
// Version: v1.0.0
//
// Description: Error location polynomial's coefficient buffer between KES and CS
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module d_KES_CS_buffer
#(
	parameter	Multi	            = 2,
	parameter	GaloisFieldDegree	= 12,
	parameter	MaxErrorCountBits   = 9,
    parameter   ELPCoefficients     = 15
)
(
	i_clk					,
	i_RESET 				,
	i_stop_dec				,
	
	i_exe_buf				,		
	i_kes_fail				,		
	i_buf_sequence_end		,
	i_chunk_number		    ,
	i_error_count			,
	
	i_v_000					,
	i_v_001					,
	i_v_002					,
	i_v_003					,
	i_v_004					,
	i_v_005					,
	i_v_006					,
	i_v_007					,
	i_v_008					,
	i_v_009					,
	i_v_010					,
	i_v_011					,
	i_v_012					,
	i_v_013					,
	i_v_014					,
	
	i_cs_available			,
	
	o_buf_available			,
	
    o_exe_cs                ,
	o_kes_sequence_end		,
	o_kes_fail				,
	o_error_count			,
	
	o_ELP_coef					
);
	input										                i_clk				;
	input										                i_RESET			    ;
	input										                i_stop_dec			;
    
	input										                i_exe_buf			;
	input										                i_kes_fail			;
	input										                i_buf_sequence_end	;
	input		    							                i_chunk_number	    ;
	input		[3:0]							                i_error_count		;
    
	input		[GaloisFieldDegree - 1:0]			            i_v_000				;
	input		[GaloisFieldDegree - 1:0]			            i_v_001				;
	input		[GaloisFieldDegree - 1:0]			            i_v_002				;
	input		[GaloisFieldDegree - 1:0]			            i_v_003				;
	input		[GaloisFieldDegree - 1:0]			            i_v_004				;
	input		[GaloisFieldDegree - 1:0]			            i_v_005				;
	input		[GaloisFieldDegree - 1:0]			            i_v_006				;
	input		[GaloisFieldDegree - 1:0]			            i_v_007				;
	input		[GaloisFieldDegree - 1:0]			            i_v_008				;
	input		[GaloisFieldDegree - 1:0]			            i_v_009				;
	input		[GaloisFieldDegree - 1:0]			            i_v_010				;
	input		[GaloisFieldDegree - 1:0]			            i_v_011				;
	input		[GaloisFieldDegree - 1:0]			            i_v_012				;
	input		[GaloisFieldDegree - 1:0]			            i_v_013				;
	input		[GaloisFieldDegree - 1:0]			            i_v_014				;
    
	input										                i_cs_available		;
    
	output										                o_buf_available		;
    
    output  reg                                                 o_exe_cs            ;
	output	reg	[Multi - 1:0]					                o_kes_sequence_end	;
	output	reg	[Multi - 1:0]					                o_kes_fail			;
	output	reg	[Multi*MaxErrorCountBits - 1:0]	                o_error_count		;
	
	output	reg	[Multi*GaloisFieldDegree*ELPCoefficients - 1:0]	o_ELP_coef			;
		
	reg										    r_buf_sequence_end;
	reg		[3:0]							    r_cur_state;
	reg		[3:0]							    r_nxt_state;
	reg		[Multi - 1:0]					    r_cs_enable;
	reg		[Multi - 1:0]					    r_kes_fail;
	reg		[Multi*MaxErrorCountBits - 1:0]	    r_error_count;
    
	reg		[Multi*GaloisFieldDegree - 1:0]		r_v_000;
	reg		[Multi*GaloisFieldDegree - 1:0]		r_v_001;
	reg		[Multi*GaloisFieldDegree - 1:0]		r_v_002;
	reg		[Multi*GaloisFieldDegree - 1:0]		r_v_003;
    reg		[Multi*GaloisFieldDegree - 1:0]		r_v_004;
    reg		[Multi*GaloisFieldDegree - 1:0]		r_v_005;
    reg		[Multi*GaloisFieldDegree - 1:0]		r_v_006;
    reg		[Multi*GaloisFieldDegree - 1:0]		r_v_007;
    reg		[Multi*GaloisFieldDegree - 1:0]		r_v_008;
    reg		[Multi*GaloisFieldDegree - 1:0]		r_v_009;
    reg		[Multi*GaloisFieldDegree - 1:0]		r_v_010;
    reg		[Multi*GaloisFieldDegree - 1:0]		r_v_011;
    reg		[Multi*GaloisFieldDegree - 1:0]		r_v_012;
    reg		[Multi*GaloisFieldDegree - 1:0]		r_v_013;
    reg		[Multi*GaloisFieldDegree - 1:0]		r_v_014;
	
	localparam		State_Idle		= 4'b0000;
	localparam		State_Input		= 4'b0001;
	localparam		State_Standby 	= 4'b0010;
	localparam		State_Out_Ready = 4'b0100;
	localparam		State_Output 	= 4'b1000;
	
	assign o_buf_available = !((r_cur_state == State_Out_Ready) || (r_cur_state == State_Output));
	
	
	
	always @ (posedge i_clk) begin
	if (i_RESET || i_stop_dec)
		r_cur_state <= State_Idle;
	else
		r_cur_state <= r_nxt_state;
	end
	
	always @ (*) begin
	if(i_RESET || i_stop_dec)
		r_nxt_state <= State_Idle;
	else begin
			case (r_cur_state)
				State_Idle:
					r_nxt_state <= (i_exe_buf) ? State_Input : State_Idle;
				State_Input:
					r_nxt_state <= State_Standby;
				State_Standby:
					r_nxt_state <= (i_exe_buf) ? State_Input : ( (r_buf_sequence_end) ? State_Out_Ready : State_Standby );
				State_Out_Ready:
					r_nxt_state <= (i_cs_available) ? State_Output : State_Out_Ready;
				State_Output:
					r_nxt_state <= State_Idle;
				default:
					r_nxt_state <= State_Idle;					
			endcase
		end
	end
	
	
	always @ (posedge i_clk) begin
	if (i_RESET || i_stop_dec)
		r_buf_sequence_end <= 0;
	else
		case (r_nxt_state)
			State_Idle: 
				r_buf_sequence_end <= 0;
			State_Input:
				r_buf_sequence_end <= i_buf_sequence_end;
			default:
				r_buf_sequence_end <= r_buf_sequence_end;
		
		endcase
	end
	
	always @ (posedge i_clk) begin
	if (i_RESET || i_stop_dec)
		begin
            o_exe_cs <= 0;
			o_kes_sequence_end <= 0;
			o_kes_fail <= 0;
			o_error_count <= 0;
			
            o_ELP_coef <= 0;
		end
	else begin
		case (r_nxt_state)
			State_Output: 	begin
                                o_exe_cs <= 1'b1;
								o_kes_sequence_end <= r_cs_enable;
								o_kes_fail <= r_kes_fail;
								o_error_count <= r_error_count;
                                
                                o_ELP_coef <= { r_v_000,
                                                r_v_001,
                                                r_v_002,
                                                r_v_003,
                                                r_v_004,
                                                r_v_005,
                                                r_v_006,
                                                r_v_007,
                                                r_v_008,
                                                r_v_009,
                                                r_v_010,
                                                r_v_011,
                                                r_v_012,
                                                r_v_013,
								                r_v_014 };
								
							end
			default: begin
                        o_exe_cs <= 0;
						o_kes_sequence_end <= 0;
						o_kes_fail <= 0;
						o_error_count <= 0;
						
						o_ELP_coef <= 0;
                    end
			endcase
		end
	end
	
	always @ (posedge i_clk) begin
	if (i_RESET || i_stop_dec)
		begin
			r_cs_enable <= 0;
			r_kes_fail <= 0;
			r_error_count <= 0;
			r_v_000 <= 0;
			r_v_001 <= 0;
			r_v_002 <= 0;
			r_v_003 <= 0;
			r_v_004 <= 0;
			r_v_005 <= 0;
			r_v_006 <= 0;
			r_v_007 <= 0;
			r_v_008 <= 0;
			r_v_009 <= 0;
			r_v_010 <= 0;
			r_v_011 <= 0;
			r_v_012 <= 0;
			r_v_013 <= 0;
			r_v_014 <= 0;
		end
	else begin
		case (r_nxt_state)
			State_Idle:	begin
							r_cs_enable <= 0;
							r_kes_fail <= 0;
							r_error_count <= 0;
							r_v_000 <= 0;
							r_v_001 <= 0;
							r_v_002 <= 0;
							r_v_003 <= 0;
							r_v_004 <= 0;
							r_v_005 <= 0;
							r_v_006 <= 0;
							r_v_007 <= 0;
							r_v_008 <= 0;
							r_v_009 <= 0;
							r_v_010 <= 0;
							r_v_011 <= 0;
							r_v_012 <= 0;
							r_v_013 <= 0;
							r_v_014 <= 0;
						end
			State_Input: begin
						if (i_kes_fail) begin
							case (i_chunk_number)
							1'b0: begin
								r_kes_fail[0] <= 1'b1;
                                r_cs_enable[0] <= 1'b1;
                                end
							1'b1: begin
								r_kes_fail[1] <= 1'b1;
                                r_cs_enable[1] <= 1'b1;
                                end
							endcase
							r_error_count <= r_error_count;
							r_v_000 <= r_v_000;
							r_v_001 <= r_v_001;
							r_v_002 <= r_v_002;
							r_v_003 <= r_v_003;
							r_v_004 <= r_v_004;
							r_v_005 <= r_v_005;
							r_v_006 <= r_v_006;
							r_v_007 <= r_v_007;
							r_v_008 <= r_v_008;
							r_v_009 <= r_v_009;
							r_v_010 <= r_v_010;
							r_v_011 <= r_v_011;
							r_v_012 <= r_v_012;
							r_v_013 <= r_v_013;
							r_v_014 <= r_v_014;
							end
						else begin
							r_kes_fail <= r_kes_fail;
							case (i_chunk_number)
							1'b0: begin
                                r_cs_enable[0] <= (|i_error_count) ? 1'b1 : 1'b0;
								r_error_count[MaxErrorCountBits*1 - 1:MaxErrorCountBits*(1 - 1)] <= i_error_count;
								r_v_000[GaloisFieldDegree*1 - 1:GaloisFieldDegree*(1 - 1)] <= i_v_000;
								r_v_001[GaloisFieldDegree*1 - 1:GaloisFieldDegree*(1 - 1)] <= i_v_001;
								r_v_002[GaloisFieldDegree*1 - 1:GaloisFieldDegree*(1 - 1)] <= i_v_002;
								r_v_003[GaloisFieldDegree*1 - 1:GaloisFieldDegree*(1 - 1)] <= i_v_003;
								r_v_004[GaloisFieldDegree*1 - 1:GaloisFieldDegree*(1 - 1)] <= i_v_004;
								r_v_005[GaloisFieldDegree*1 - 1:GaloisFieldDegree*(1 - 1)] <= i_v_005;
								r_v_006[GaloisFieldDegree*1 - 1:GaloisFieldDegree*(1 - 1)] <= i_v_006;
								r_v_007[GaloisFieldDegree*1 - 1:GaloisFieldDegree*(1 - 1)] <= i_v_007;
								r_v_008[GaloisFieldDegree*1 - 1:GaloisFieldDegree*(1 - 1)] <= i_v_008;
								r_v_009[GaloisFieldDegree*1 - 1:GaloisFieldDegree*(1 - 1)] <= i_v_009;
								r_v_010[GaloisFieldDegree*1 - 1:GaloisFieldDegree*(1 - 1)] <= i_v_010;
								r_v_011[GaloisFieldDegree*1 - 1:GaloisFieldDegree*(1 - 1)] <= i_v_011;
								r_v_012[GaloisFieldDegree*1 - 1:GaloisFieldDegree*(1 - 1)] <= i_v_012;
								r_v_013[GaloisFieldDegree*1 - 1:GaloisFieldDegree*(1 - 1)] <= i_v_013;
								r_v_014[GaloisFieldDegree*1 - 1:GaloisFieldDegree*(1 - 1)] <= i_v_014;
								end
							1'b1: begin
                                r_cs_enable[1] <= (|i_error_count) ? 1'b1 : 1'b0;
								r_error_count[MaxErrorCountBits*2 - 1:MaxErrorCountBits*(2 - 1)] <= i_error_count;
								r_v_000[GaloisFieldDegree*2 - 1:GaloisFieldDegree*(2 - 1)] <= i_v_000;
								r_v_001[GaloisFieldDegree*2 - 1:GaloisFieldDegree*(2 - 1)] <= i_v_001;
								r_v_002[GaloisFieldDegree*2 - 1:GaloisFieldDegree*(2 - 1)] <= i_v_002;
								r_v_003[GaloisFieldDegree*2 - 1:GaloisFieldDegree*(2 - 1)] <= i_v_003;
								r_v_004[GaloisFieldDegree*2 - 1:GaloisFieldDegree*(2 - 1)] <= i_v_004;
								r_v_005[GaloisFieldDegree*2 - 1:GaloisFieldDegree*(2 - 1)] <= i_v_005;
								r_v_006[GaloisFieldDegree*2 - 1:GaloisFieldDegree*(2 - 1)] <= i_v_006;
								r_v_007[GaloisFieldDegree*2 - 1:GaloisFieldDegree*(2 - 1)] <= i_v_007;
								r_v_008[GaloisFieldDegree*2 - 1:GaloisFieldDegree*(2 - 1)] <= i_v_008;
								r_v_009[GaloisFieldDegree*2 - 1:GaloisFieldDegree*(2 - 1)] <= i_v_009;
								r_v_010[GaloisFieldDegree*2 - 1:GaloisFieldDegree*(2 - 1)] <= i_v_010;
								r_v_011[GaloisFieldDegree*2 - 1:GaloisFieldDegree*(2 - 1)] <= i_v_011;
								r_v_012[GaloisFieldDegree*2 - 1:GaloisFieldDegree*(2 - 1)] <= i_v_012;
								r_v_013[GaloisFieldDegree*2 - 1:GaloisFieldDegree*(2 - 1)] <= i_v_013;
								r_v_014[GaloisFieldDegree*2 - 1:GaloisFieldDegree*(2 - 1)] <= i_v_014;
                                
								end
							
							default: begin
								r_cs_enable <= r_cs_enable;
								r_error_count <= r_error_count;
								r_v_000 <= r_v_000;
								r_v_001 <= r_v_001;
								r_v_002 <= r_v_002;
								r_v_003 <= r_v_003;
								r_v_004 <= r_v_004;
								r_v_005 <= r_v_005;
								r_v_006 <= r_v_006;
								r_v_007 <= r_v_007;
								r_v_008 <= r_v_008;
								r_v_009 <= r_v_009;
								r_v_010 <= r_v_010;
								r_v_011 <= r_v_011;
								r_v_012 <= r_v_012;
								r_v_013 <= r_v_013;
								r_v_014 <= r_v_014;
								end
							endcase
						end
					end
			default:	begin
							r_kes_fail <= r_kes_fail;
							r_cs_enable <= r_cs_enable;
							r_error_count <= r_error_count;
							r_v_000 <= r_v_000;
							r_v_001 <= r_v_001;
							r_v_002 <= r_v_002;
							r_v_003 <= r_v_003;
							r_v_004 <= r_v_004;
							r_v_005 <= r_v_005;
							r_v_006 <= r_v_006;
							r_v_007 <= r_v_007;
							r_v_008 <= r_v_008;
							r_v_009 <= r_v_009;
							r_v_010 <= r_v_010;
							r_v_011 <= r_v_011;
							r_v_012 <= r_v_012;
							r_v_013 <= r_v_013;
							r_v_014 <= r_v_014;
						end
			endcase
		end
	end
endmodule
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
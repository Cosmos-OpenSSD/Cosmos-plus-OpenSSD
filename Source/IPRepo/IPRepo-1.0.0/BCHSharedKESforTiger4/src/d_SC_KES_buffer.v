//////////////////////////////////////////////////////////////////////////////////
// d_SC_KES_buffer.v for Cosmos OpenSSD
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
// Design Name: BCH decoder (page decoder) syndrome buffer
// Module Name: d_SC_KES_buffer
// File Name: d_SC_KES_buffer.v
//
// Version: v1.0.0
//
// Description: Syndrome buffer between SC and KES
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module	d_SC_KES_buffer
#(
	parameter	Multi	        =	2,
	parameter	GF		        =	12,
    parameter   Syndromes       =   27
)
(
	i_clk				,
	i_RESET			    ,
	i_stop_dec			,
	
	i_kes_available		,
	
	i_exe_buf			,
	i_ELP_search_needed	,
	i_syndromes         ,
	
	o_buf_available		,
	
	o_exe_kes			,
	o_chunk_number	    ,
    o_data_fowarding    ,
	o_buf_sequence_end	,
	o_syndromes
);
	input						        i_clk				;
	input						        i_RESET			    ;
	input						        i_stop_dec			;
    
	input						        i_kes_available		;
    
	input						        i_exe_buf			;
	input	[Multi - 1:0]		        i_ELP_search_needed	;
	input	[Multi*GF*Syndromes - 1:0]	i_syndromes         ;
    
	output	reg					        o_exe_kes			;
	output						        o_buf_available		;
    
	output	reg        			        o_chunk_number	    ;
    output  reg                         o_data_fowarding    ;
	output	reg					        o_buf_sequence_end	;
	
	output	reg	[Syndromes*GF - 1:0]    o_syndromes         ;
	
	reg		[5:0]	            r_cur_state			;
	reg		[5:0]	            r_nxt_state			;
	reg		[2:0]				r_count				;
	reg		[Multi - 1:0]		r_chunk_num		    ;
    reg                         r_data_fowarding    ;
	
	reg		[Multi*GF - 1:0]	r_sdr_001			;
	reg		[Multi*GF - 1:0]	r_sdr_002			;
	reg		[Multi*GF - 1:0]	r_sdr_003			;
	reg		[Multi*GF - 1:0]	r_sdr_004			;
	reg		[Multi*GF - 1:0]	r_sdr_005			;
	reg		[Multi*GF - 1:0]	r_sdr_006			;
	reg		[Multi*GF - 1:0]	r_sdr_007			;
	reg		[Multi*GF - 1:0]	r_sdr_008			;
	reg		[Multi*GF - 1:0]	r_sdr_009			;
	reg		[Multi*GF - 1:0]	r_sdr_010			;
	reg		[Multi*GF - 1:0]	r_sdr_011			;
	reg		[Multi*GF - 1:0]	r_sdr_012			;
	reg		[Multi*GF - 1:0]	r_sdr_013			;
	reg		[Multi*GF - 1:0]	r_sdr_014			;
	reg		[Multi*GF - 1:0]	r_sdr_015			;
	reg		[Multi*GF - 1:0]	r_sdr_016			;
	reg		[Multi*GF - 1:0]	r_sdr_017			;
	reg		[Multi*GF - 1:0]	r_sdr_018			;
	reg		[Multi*GF - 1:0]	r_sdr_019			;
	reg		[Multi*GF - 1:0]	r_sdr_020			;
	reg		[Multi*GF - 1:0]	r_sdr_021			;
	reg		[Multi*GF - 1:0]	r_sdr_022			;
	reg		[Multi*GF - 1:0]	r_sdr_023			;
	reg		[Multi*GF - 1:0]	r_sdr_024			;
	reg		[Multi*GF - 1:0]	r_sdr_025			;
	reg		[Multi*GF - 1:0]	r_sdr_026			;
	reg		[Multi*GF - 1:0]	r_sdr_027			;
	
	wire						w_out_available		;
	
	localparam	State_Idle		    =	6'b000001   ;
	localparam	State_Input		    =	6'b000010   ;
	localparam	State_Shift		    =	6'b000100   ;
	localparam	State_Standby	    =	6'b001000   ;
    localparam  State_FowardStandby =   6'b010000   ;
	localparam	State_Output	    =	6'b100000   ;
	
	//assign 	o_exe_kes 		= (r_cur_state == State_Output);
	assign	o_buf_available	= (r_cur_state == State_Idle);
	
	always @ (posedge i_clk)
	if (i_RESET || i_stop_dec)
		r_cur_state <= State_Idle;
	else
		r_cur_state <= r_nxt_state;
	
	always @ (*)
	if (i_RESET || i_stop_dec)
		r_nxt_state <= State_Idle;
	else begin
		case (r_cur_state)
			State_Idle:
				r_nxt_state <= (i_exe_buf) ? State_Input : State_Idle;
			State_Input:
				r_nxt_state <= (r_chunk_num == 0)?State_FowardStandby:State_Standby;
			State_Standby:
				r_nxt_state <= (r_count == Multi) ? State_Idle :
								((r_chunk_num[0] == 0) ? State_Shift : ((i_kes_available) ? State_Output : State_Standby));
			State_FowardStandby:
                r_nxt_state <= (i_kes_available) ? State_Output : State_FowardStandby;
            State_Output:
				r_nxt_state <= ((r_count == Multi - 1) || (o_buf_sequence_end)) ? State_Idle : State_Shift;
			State_Shift:
				r_nxt_state <= State_Standby;
			default:
				r_nxt_state <= State_Idle;
			endcase
		end
	
	always @ (posedge i_clk)
	begin
		if (i_RESET || i_stop_dec) begin
			o_buf_sequence_end <= 0;
            o_exe_kes <= 0;
            end
		else begin
			case(r_nxt_state)
				State_Output: begin
					o_buf_sequence_end <= (r_count == Multi - 1) ? 1'b1 : (!(r_chunk_num[1]) ? 1'b1 : 1'b0);
                    o_exe_kes <= 1'b1;
                    end
				default: begin
					o_buf_sequence_end <= 0;
                    o_exe_kes <= 0;
                    end
			endcase
		end
	end
	
    always @ (posedge i_clk)
    begin
        if (i_RESET || i_stop_dec)
            r_data_fowarding <= 0;
        else begin
            case (r_nxt_state)
                State_Idle:
                    r_data_fowarding <= 0;
                State_FowardStandby:
                    r_data_fowarding <= 1;
                default:
                    r_data_fowarding <= r_data_fowarding;
            endcase
        end
    end
    
	always @ (posedge i_clk)
	begin
		if (i_RESET || i_stop_dec)
		begin
			o_chunk_number	    <= 0;
            o_data_fowarding    <= 0;
			o_syndromes         <= 0;
		end
		else begin
			case(r_nxt_state)
				State_Output: begin
								o_chunk_number 	                <=  r_count[0];
                                o_data_fowarding                <=  r_data_fowarding;
								
                                o_syndromes[Syndromes*GF - 1:0] <= { r_sdr_001[GF - 1:0],
                                                                     r_sdr_002[GF - 1:0],
                                                                     r_sdr_003[GF - 1:0],
                                                                     r_sdr_004[GF - 1:0],
                                                                     r_sdr_005[GF - 1:0],
                                                                     r_sdr_006[GF - 1:0],
                                                                     r_sdr_007[GF - 1:0],
                                                                     r_sdr_008[GF - 1:0],
                                                                     r_sdr_009[GF - 1:0],
                                                                     r_sdr_010[GF - 1:0],
                                                                     r_sdr_011[GF - 1:0],
                                                                     r_sdr_012[GF - 1:0],
                                                                     r_sdr_013[GF - 1:0],
                                                                     r_sdr_014[GF - 1:0],
                                                                     r_sdr_015[GF - 1:0],
                                                                     r_sdr_016[GF - 1:0],
                                                                     r_sdr_017[GF - 1:0],
                                                                     r_sdr_018[GF - 1:0],
                                                                     r_sdr_019[GF - 1:0],
                                                                     r_sdr_020[GF - 1:0],
                                                                     r_sdr_021[GF - 1:0],
                                                                     r_sdr_022[GF - 1:0],
                                                                     r_sdr_023[GF - 1:0],
                                                                     r_sdr_024[GF - 1:0],
                                                                     r_sdr_025[GF - 1:0],
                                                                     r_sdr_026[GF - 1:0],
                                                                     r_sdr_027[GF - 1:0] };
							end
				default: 	  begin
								o_chunk_number 	    <= 0;
                                o_data_fowarding    <= 0;
								o_syndromes         <= 0;
							end
				endcase
			end
	end
		
	always @ (posedge i_clk)
	begin 
		if (i_RESET || i_stop_dec)
		begin
			r_count	  		<= 0;
			r_chunk_num 	<= 0;
			r_sdr_001 		<= 0;
			r_sdr_002 		<= 0;
	        r_sdr_003 		<= 0;
	        r_sdr_004 		<= 0;
            r_sdr_005 		<= 0;
            r_sdr_006 		<= 0;
            r_sdr_007 		<= 0;
            r_sdr_008 		<= 0;
            r_sdr_009 		<= 0;
            r_sdr_010 		<= 0;
            r_sdr_011 		<= 0;
            r_sdr_012 		<= 0;
            r_sdr_013 		<= 0;
            r_sdr_014 		<= 0;
            r_sdr_015 		<= 0;
            r_sdr_016 		<= 0;
            r_sdr_017 		<= 0;
            r_sdr_018 		<= 0;
            r_sdr_019 		<= 0;
            r_sdr_020 		<= 0;
            r_sdr_021 		<= 0;
            r_sdr_022 		<= 0;
            r_sdr_023 		<= 0;
            r_sdr_024 		<= 0;
            r_sdr_025 		<= 0;
            r_sdr_026 		<= 0;
            r_sdr_027 		<= 0;
		end
		else begin
			case (r_nxt_state)
				State_Idle: begin
								r_count			<= 0;
								r_chunk_num	    <= 0;
								r_sdr_001 		<= 0;
								r_sdr_002 		<= 0;
								r_sdr_003 		<= 0;
								r_sdr_004 		<= 0;
								r_sdr_005 		<= 0;
								r_sdr_006 		<= 0;
								r_sdr_007 		<= 0;
								r_sdr_008 		<= 0;
								r_sdr_009 		<= 0;
								r_sdr_010 		<= 0;
								r_sdr_011 		<= 0;
								r_sdr_012 		<= 0;
								r_sdr_013 		<= 0;
								r_sdr_014 		<= 0;
								r_sdr_015 		<= 0;
								r_sdr_016 		<= 0;
								r_sdr_017 		<= 0;
								r_sdr_018 		<= 0;
								r_sdr_019 		<= 0;
								r_sdr_020 		<= 0;
								r_sdr_021 		<= 0;
								r_sdr_022 		<= 0;
								r_sdr_023 		<= 0;
								r_sdr_024 		<= 0;
								r_sdr_025 		<= 0;
								r_sdr_026 		<= 0;
								r_sdr_027 		<= 0;
							end
				State_Input: begin
								r_count			<= 0                    ;
								r_chunk_num	    <= i_ELP_search_needed  ;
								r_sdr_001 		<= i_syndromes[Multi * GF * (Syndromes+1 -  1) - 1 : Multi * GF * (Syndromes+1 -  2)];
								r_sdr_002 		<= i_syndromes[Multi * GF * (Syndromes+1 -  2) - 1 : Multi * GF * (Syndromes+1 -  3)];
								r_sdr_003 		<= i_syndromes[Multi * GF * (Syndromes+1 -  3) - 1 : Multi * GF * (Syndromes+1 -  4)];
								r_sdr_004 		<= i_syndromes[Multi * GF * (Syndromes+1 -  4) - 1 : Multi * GF * (Syndromes+1 -  5)];
								r_sdr_005 		<= i_syndromes[Multi * GF * (Syndromes+1 -  5) - 1 : Multi * GF * (Syndromes+1 -  6)];
								r_sdr_006 		<= i_syndromes[Multi * GF * (Syndromes+1 -  6) - 1 : Multi * GF * (Syndromes+1 -  7)];
								r_sdr_007 		<= i_syndromes[Multi * GF * (Syndromes+1 -  7) - 1 : Multi * GF * (Syndromes+1 -  8)];
								r_sdr_008 		<= i_syndromes[Multi * GF * (Syndromes+1 -  8) - 1 : Multi * GF * (Syndromes+1 -  9)];
								r_sdr_009 		<= i_syndromes[Multi * GF * (Syndromes+1 -  9) - 1 : Multi * GF * (Syndromes+1 - 10)];
								r_sdr_010 		<= i_syndromes[Multi * GF * (Syndromes+1 - 10) - 1 : Multi * GF * (Syndromes+1 - 11)];
								r_sdr_011 		<= i_syndromes[Multi * GF * (Syndromes+1 - 11) - 1 : Multi * GF * (Syndromes+1 - 12)];
								r_sdr_012 		<= i_syndromes[Multi * GF * (Syndromes+1 - 12) - 1 : Multi * GF * (Syndromes+1 - 13)];
								r_sdr_013 		<= i_syndromes[Multi * GF * (Syndromes+1 - 13) - 1 : Multi * GF * (Syndromes+1 - 14)];
								r_sdr_014 		<= i_syndromes[Multi * GF * (Syndromes+1 - 14) - 1 : Multi * GF * (Syndromes+1 - 15)];
								r_sdr_015 		<= i_syndromes[Multi * GF * (Syndromes+1 - 15) - 1 : Multi * GF * (Syndromes+1 - 16)];
								r_sdr_016 		<= i_syndromes[Multi * GF * (Syndromes+1 - 16) - 1 : Multi * GF * (Syndromes+1 - 17)];
								r_sdr_017 		<= i_syndromes[Multi * GF * (Syndromes+1 - 17) - 1 : Multi * GF * (Syndromes+1 - 18)];
								r_sdr_018 		<= i_syndromes[Multi * GF * (Syndromes+1 - 18) - 1 : Multi * GF * (Syndromes+1 - 19)];
								r_sdr_019 		<= i_syndromes[Multi * GF * (Syndromes+1 - 19) - 1 : Multi * GF * (Syndromes+1 - 20)];
								r_sdr_020 		<= i_syndromes[Multi * GF * (Syndromes+1 - 20) - 1 : Multi * GF * (Syndromes+1 - 21)];
								r_sdr_021 		<= i_syndromes[Multi * GF * (Syndromes+1 - 21) - 1 : Multi * GF * (Syndromes+1 - 22)];
								r_sdr_022 		<= i_syndromes[Multi * GF * (Syndromes+1 - 22) - 1 : Multi * GF * (Syndromes+1 - 23)];
								r_sdr_023 		<= i_syndromes[Multi * GF * (Syndromes+1 - 23) - 1 : Multi * GF * (Syndromes+1 - 24)];
								r_sdr_024 		<= i_syndromes[Multi * GF * (Syndromes+1 - 24) - 1 : Multi * GF * (Syndromes+1 - 25)];
								r_sdr_025 		<= i_syndromes[Multi * GF * (Syndromes+1 - 25) - 1 : Multi * GF * (Syndromes+1 - 26)];
								r_sdr_026 		<= i_syndromes[Multi * GF * (Syndromes+1 - 26) - 1 : Multi * GF * (Syndromes+1 - 27)];
								r_sdr_027 		<= i_syndromes[Multi * GF * (Syndromes+1 - 27) - 1 : Multi * GF * (Syndromes+1 - 28)];
							end
				State_Shift: begin
								r_count			<= r_count + 1'b1;
								r_chunk_num	    <= r_chunk_num >> 1;
								r_sdr_001 		<= r_sdr_001 >> GF;
								r_sdr_002 		<= r_sdr_002 >> GF;
								r_sdr_003 		<= r_sdr_003 >> GF;
								r_sdr_004 		<= r_sdr_004 >> GF;
								r_sdr_005 		<= r_sdr_005 >> GF;
								r_sdr_006 		<= r_sdr_006 >> GF;
								r_sdr_007 		<= r_sdr_007 >> GF;
								r_sdr_008 		<= r_sdr_008 >> GF;
								r_sdr_009 		<= r_sdr_009 >> GF;
								r_sdr_010 		<= r_sdr_010 >> GF;
								r_sdr_011 		<= r_sdr_011 >> GF;
								r_sdr_012 		<= r_sdr_012 >> GF;
								r_sdr_013 		<= r_sdr_013 >> GF;
								r_sdr_014 		<= r_sdr_014 >> GF;
								r_sdr_015 		<= r_sdr_015 >> GF;
								r_sdr_016 		<= r_sdr_016 >> GF;
								r_sdr_017 		<= r_sdr_017 >> GF;
								r_sdr_018 		<= r_sdr_018 >> GF;
								r_sdr_019 		<= r_sdr_019 >> GF;
								r_sdr_020 		<= r_sdr_020 >> GF;
								r_sdr_021 		<= r_sdr_021 >> GF;
								r_sdr_022 		<= r_sdr_022 >> GF;
								r_sdr_023 		<= r_sdr_023 >> GF;
								r_sdr_024 		<= r_sdr_024 >> GF;
								r_sdr_025 		<= r_sdr_025 >> GF;
								r_sdr_026 		<= r_sdr_026 >> GF;
								r_sdr_027 		<= r_sdr_027 >> GF;
							end
				default:	begin
								r_count			<= r_count;
								r_chunk_num	    <= r_chunk_num;
								r_sdr_001 		<= r_sdr_001;
								r_sdr_002 		<= r_sdr_002;
								r_sdr_003 		<= r_sdr_003;
								r_sdr_004 		<= r_sdr_004;
								r_sdr_005 		<= r_sdr_005;
								r_sdr_006 		<= r_sdr_006;
								r_sdr_007 		<= r_sdr_007;
								r_sdr_008 		<= r_sdr_008;
								r_sdr_009 		<= r_sdr_009;
								r_sdr_010 		<= r_sdr_010;
								r_sdr_011 		<= r_sdr_011;
								r_sdr_012 		<= r_sdr_012;
								r_sdr_013 		<= r_sdr_013;
								r_sdr_014 		<= r_sdr_014;
								r_sdr_015 		<= r_sdr_015;
								r_sdr_016 		<= r_sdr_016;
								r_sdr_017 		<= r_sdr_017;
								r_sdr_018 		<= r_sdr_018;
								r_sdr_019 		<= r_sdr_019;
								r_sdr_020 		<= r_sdr_020;
								r_sdr_021 		<= r_sdr_021;
								r_sdr_022 		<= r_sdr_022;
								r_sdr_023 		<= r_sdr_023;
								r_sdr_024 		<= r_sdr_024;
								r_sdr_025 		<= r_sdr_025;
								r_sdr_026 		<= r_sdr_026;
								r_sdr_027 		<= r_sdr_027;
							end
				endcase
			end
	end
	
endmodule				
				
				
				
				
				
				
				
				
				
				
				
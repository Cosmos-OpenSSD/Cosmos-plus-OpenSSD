//////////////////////////////////////////////////////////////////////////////////
// d_BCH_SC_X.v for Cosmos OpenSSD
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
// Module Name: d_BCH_SC_X
// File Name: d_BCH_SC_X.v
//
// Version: v1.0.0
//
// Description: Syndrome calculator (SC) (page decoder) array
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module	d_BCH_SC_X
#
(
	parameter	Multi	= 2,
	parameter	GF		= 12
)
(
	i_clk,
	i_RESET,
	
	i_buf_available,
	i_exe_sc,
	i_code_valid,
	i_code,
    o_code_ready,
	
	o_sc_available,
	
	o_last_c_block_rcvd,
	o_sc_cmplt,
	o_error_detected,
	
	o_BRAM_write_enable,
	o_BRAM_write_address,
	o_BRAM_write_data,
	
	o_sdr_001,
	o_sdr_002,
	o_sdr_003,
	o_sdr_004,
	o_sdr_005,
	o_sdr_006,
	o_sdr_007,
	o_sdr_008,
	o_sdr_009,
	o_sdr_010,
	o_sdr_011,
	o_sdr_012,
	o_sdr_013,
	o_sdr_014,
	o_sdr_015,
	o_sdr_016,
	o_sdr_017,
	o_sdr_018,
	o_sdr_019,
	o_sdr_020,
	o_sdr_021,
	o_sdr_022,
	o_sdr_023,
	o_sdr_024,
	o_sdr_025,
	o_sdr_026,
	o_sdr_027
	
	
);
	input						i_clk				;
	input						i_RESET 			;
	input						i_exe_sc			;
	input						i_buf_available		;
	input	        		    i_code_valid		;
	input	[8*Multi - 1:0]		i_code				;
    output                      o_code_ready        ;
	
	output	[Multi - 1 :0]		o_sc_available		;
	output	[Multi - 1:0]		o_last_c_block_rcvd	;
	output	[Multi - 1:0]		o_sc_cmplt			;
	output	[Multi - 1:0]		o_error_detected	;
	
	output	[Multi - 1:0]		o_BRAM_write_enable	;
	output	[8*Multi - 1:0]		o_BRAM_write_address;
	output	[8*Multi - 1:0]		o_BRAM_write_data	;
	
	output	[GF*Multi - 1:0]	o_sdr_001			;
	output	[GF*Multi - 1:0]	o_sdr_002			;
	output	[GF*Multi - 1:0]	o_sdr_003			;
	output	[GF*Multi - 1:0]	o_sdr_004			;
	output	[GF*Multi - 1:0]	o_sdr_005			;
	output	[GF*Multi - 1:0]	o_sdr_006			;
	output	[GF*Multi - 1:0]	o_sdr_007			;
	output	[GF*Multi - 1:0]	o_sdr_008			;
	output	[GF*Multi - 1:0]	o_sdr_009			;
	output	[GF*Multi - 1:0]	o_sdr_010			;
	output	[GF*Multi - 1:0]	o_sdr_011			;
	output	[GF*Multi - 1:0]	o_sdr_012			;
	output	[GF*Multi - 1:0]	o_sdr_013			;
	output	[GF*Multi - 1:0]	o_sdr_014			;
	output	[GF*Multi - 1:0]	o_sdr_015			;
	output	[GF*Multi - 1:0]	o_sdr_016			;
	output	[GF*Multi - 1:0]	o_sdr_017			;
	output	[GF*Multi - 1:0]	o_sdr_018			;
	output	[GF*Multi - 1:0]	o_sdr_019			;
	output	[GF*Multi - 1:0]	o_sdr_020			;
	output	[GF*Multi - 1:0]	o_sdr_021			;
	output	[GF*Multi - 1:0]	o_sdr_022			;
	output	[GF*Multi - 1:0]	o_sdr_023			;
	output	[GF*Multi - 1:0]	o_sdr_024			;
	output	[GF*Multi - 1:0]	o_sdr_025			;
	output	[GF*Multi - 1:0]	o_sdr_026			;
	output	[GF*Multi - 1:0]	o_sdr_027			;
	
	wire    [Multi - 1:0]       w_code_ready        ;
	
	genvar	i;
	generate
		for (i = 0; i < Multi; i = i + 1)
		begin 
			d_BCH_SC_top
			d_clustered_SC
			(
				.i_clk                  (i_clk                                  ),
				.i_RESET                (i_RESET                                ),
				.i_stop_dec             (1'b0                                   ),
				
				.i_buf_available        (i_buf_available                        ),
                
				.o_sc_available         (o_sc_available[i]                      ),
				.o_chunk_number         (                                       ),
                
				.i_exe_sc               (i_exe_sc                               ),
				.i_code_valid           (i_code_valid                           ),
				.i_code                 (i_code[(i+1)*8 - 1:i*8]                ),
                .o_code_ready           (w_code_ready[i]                        ),
				.i_chunk_number         (5'b0                                   ),
				
				.o_sc_start             (                                       ),
				.o_last_c_block_rcvd    (o_last_c_block_rcvd[i]                 ),
				.o_sc_cmplt             (o_sc_cmplt[i]                          ),
				.o_error_detected       (o_error_detected[i]                    ),
				
				.o_BRAM_write_enable    (o_BRAM_write_enable[i]                 ),
				.o_BRAM_write_address   (o_BRAM_write_address[(i+1)*8 - 1:i*8]  ),
				.o_BRAM_write_data      (o_BRAM_write_data[(i+1)*8 - 1:i*8]     ),
				
				.o_sdr_001              (o_sdr_001[(i+1)*GF - 1:i*GF]           ), 
    			.o_sdr_002              (o_sdr_002[(i+1)*GF - 1:i*GF]           ), 
    			.o_sdr_003              (o_sdr_003[(i+1)*GF - 1:i*GF]           ), 
    			.o_sdr_004              (o_sdr_004[(i+1)*GF - 1:i*GF]           ), 
    			.o_sdr_005              (o_sdr_005[(i+1)*GF - 1:i*GF]           ), 
    			.o_sdr_006              (o_sdr_006[(i+1)*GF - 1:i*GF]           ), 
    			.o_sdr_007              (o_sdr_007[(i+1)*GF - 1:i*GF]           ), 
    			.o_sdr_008              (o_sdr_008[(i+1)*GF - 1:i*GF]           ), 
    			.o_sdr_009              (o_sdr_009[(i+1)*GF - 1:i*GF]           ), 
    			.o_sdr_010              (o_sdr_010[(i+1)*GF - 1:i*GF]           ), 
    			.o_sdr_011              (o_sdr_011[(i+1)*GF - 1:i*GF]           ), 
				.o_sdr_012              (o_sdr_012[(i+1)*GF - 1:i*GF]           ), 
    			.o_sdr_013              (o_sdr_013[(i+1)*GF - 1:i*GF]           ), 
    			.o_sdr_014              (o_sdr_014[(i+1)*GF - 1:i*GF]           ), 
    			.o_sdr_015              (o_sdr_015[(i+1)*GF - 1:i*GF]           ),
				.o_sdr_016              (o_sdr_016[(i+1)*GF - 1:i*GF]           ),
				.o_sdr_017              (o_sdr_017[(i+1)*GF - 1:i*GF]           ),
				.o_sdr_018              (o_sdr_018[(i+1)*GF - 1:i*GF]           ),
				.o_sdr_019              (o_sdr_019[(i+1)*GF - 1:i*GF]           ),
				.o_sdr_020              (o_sdr_020[(i+1)*GF - 1:i*GF]           ),
				.o_sdr_021              (o_sdr_021[(i+1)*GF - 1:i*GF]           ),
				.o_sdr_022              (o_sdr_022[(i+1)*GF - 1:i*GF]           ),
				.o_sdr_023              (o_sdr_023[(i+1)*GF - 1:i*GF]           ),
				.o_sdr_024              (o_sdr_024[(i+1)*GF - 1:i*GF]           ),
				.o_sdr_025              (o_sdr_025[(i+1)*GF - 1:i*GF]           ),
				.o_sdr_026              (o_sdr_026[(i+1)*GF - 1:i*GF]           ),
				.o_sdr_027              (o_sdr_027[(i+1)*GF - 1:i*GF]           )
			);
		end
	endgenerate
	
    assign  o_code_ready = w_code_ready[0]  ;
	
endmodule



//////////////////////////////////////////////////////////////////////////////////
// d_r_message_buffer_X.v for Cosmos OpenSSD
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
// Design Name: BCH decoder (page decoder) BRAM buffer
// Module Name: d_r_message_buffer_X
// File Name: d_r_message_buffer_X.v
//
// Version: v1.0.0
//
// Description: Data buffer array for BCH decoder
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module	d_r_message_buffer_X
#(
	parameter	Multi	        =	2,
    parameter   AddressWidth   =   8,
    parameter   DataWidth       =   16
)
(
	i_clk,
	i_RESET,
	i_ena,
	i_wea,
	i_addra,
	i_dina,
	i_clkb,
	i_enb,
	i_addrb,
	o_doutb,
    i_ELP_search_stage_end,
	i_c_message_output_cmplt,
	i_error_detection_stage_end
);
	input					            i_clk;
	input					            i_RESET;
	input	[Multi-1:0]		            i_ena;
	input	[Multi-1:0]		            i_wea;
	input	[AddressWidth*Multi-1:0]    i_addra;
	input	[DataWidth-1:0] 	        i_dina;
	input					            i_clkb;
	input	[Multi-1:0]		            i_enb;
	input	[AddressWidth*Multi-1:0]	i_addrb;
	output	[DataWidth-1:0]	            o_doutb;
    input                               i_ELP_search_stage_end;
	input					            i_c_message_output_cmplt;
	input					            i_error_detection_stage_end;
    
    wire                                w_BRAM_write_enable;
    wire                                w_BRAM_read_enable;
    wire    [DataWidth-1:0]             w_BRAM_write_data;
    wire    [DataWidth-1:0]             w_BRAM_read_data;
    wire    [AddressWidth-1:0]          w_BRAM_write_address;
    wire    [AddressWidth-1:0]          w_BRAM_read_address;
    
    wire    [AddressWidth+3-1:0]        w_BRAM_write_access_address;
    wire    [AddressWidth+3-1:0]        w_BRAM_read_access_address;
     
	reg		[2:0]			            r_BRAM_write_sel;
	reg		[2:0]			            r_BRAM_read_sel;
	
    assign w_BRAM_write_enable = i_ena[0];
    assign w_BRAM_read_enable = i_enb[0];
    
    assign w_BRAM_write_data = i_dina;
    assign o_doutb = w_BRAM_read_data;
    
	assign w_BRAM_write_address = i_addra[AddressWidth-1:0];
	assign w_BRAM_read_address	= i_addrb[AddressWidth-1:0];
    
    assign w_BRAM_write_access_address = {r_BRAM_write_sel, w_BRAM_write_address};
    assign w_BRAM_read_access_address = {r_BRAM_read_sel, w_BRAM_read_address};
	
	always @ (posedge i_clk) begin
	if (i_RESET)
		r_BRAM_write_sel <= 0;
	else begin
		if (i_error_detection_stage_end)
			r_BRAM_write_sel <= (r_BRAM_write_sel == 3'b100) ? 3'b000 : r_BRAM_write_sel + 1'b1;
		else
			r_BRAM_write_sel <= r_BRAM_write_sel;
		end
	end
	
	always @ (posedge i_clk) begin
	if (i_RESET)
		r_BRAM_read_sel <= 0;
	else begin
		if (i_c_message_output_cmplt)
			r_BRAM_read_sel <= (r_BRAM_read_sel == 3'b100) ? 3'b000 : r_BRAM_read_sel + 1'b1;
		else
			r_BRAM_read_sel <= r_BRAM_read_sel;
		end
	end
	
    DCDPRAM16x1280WC
    Inst_DCDPRAM
    (
        .clka   (i_clk                          ),
        .ena    (w_BRAM_write_enable            ),
        .wea    (w_BRAM_write_enable            ),
        .addra  (w_BRAM_write_access_address    ),
        .dina   (w_BRAM_write_data              ),
        .clkb   (i_clk                          ),
        .enb    (w_BRAM_read_enable             ),
        .addrb  (w_BRAM_read_access_address     ),
        .doutb  (w_BRAM_read_data               )
    );
    
endmodule
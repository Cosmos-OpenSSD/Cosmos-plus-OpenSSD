//////////////////////////////////////////////////////////////////////////////////
// BCHEncoderX for Cosmos OpenSSD
// Copyright (c) 2015 Hanyang University ENC Lab.
// Contributed by Jinwoo Jeong <jwjeong@enc.hanyang.ac.kr>
//                Kibin Park <kbpark@enc.hanyang.ac.kr>
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
//           Kibin Park <kbpark@enc.hanyang.ac.kr>
// 
// Project Name: Cosmos OpenSSD
// Design Name: BCH encoder (page encoder) array
// Module Name: BCHEncoderX
// File Name: BCHEncoderX.v
//
// Version: v1.0.0
//
// Description: BCH encoder (page encoder) array
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module BCHEncoderX
#
(
    parameter Multi = 2
)
(
    iClock          ,
    iReset          ,
    iEnable         ,
    iData           ,
    iDataValid      ,
    oDataReady      ,
    oDataLast       ,
    oParityData     ,
    oParityValid    ,
    oParityLast     ,
    iParityReady    
);
    input                       iClock          ;
    input                       iReset          ;
    input                       iEnable         ;
    input   [8*Multi - 1:0]     iData           ;
    input                       iDataValid      ;
    output                      oDataReady      ;
    output                      oDataLast       ;
    output  [8*Multi - 1:0]     oParityData     ;
    output                      oParityValid    ;
    output                      oParityLast     ;
    input                       iParityReady    ;
    
    wire    [Multi - 1:0]       wDataReady      ;
    wire    [Multi - 1:0]       wDataLast       ;
    wire    [Multi - 1:0]       wParityStrobe   ;
    wire    [Multi - 1:0]       wParityLast     ;
    
    genvar c;
    
    generate
        for (c = 0; c < Multi; c = c + 1)
        begin
            d_BCH_encoder_top
            BCHPEncoder
            (
                .i_clk                  (iClock                             ),
                .i_nRESET               (!iReset                            ),
                .i_exe_encoding         (iEnable                            ),
                .i_message_valid        (iDataValid                         ),
                .i_message              (iData[(c + 1) * 8 - 1:c * 8]       ),
                .o_message_ready        (wDataReady[c]                      ),
                .i_parity_ready         (iParityReady                       ),
                .o_encoding_start       (                                   ),
                .o_last_m_block_rcvd    (wDataLast[c]                       ),
                .o_encoding_cmplt       (                                   ),
                .o_parity_valid         (wParityStrobe[c]                   ),
                .o_parity_out_start     (                                   ),
                .o_parity_out_cmplt     (wParityLast[c]                     ),
                .o_parity_out           (oParityData[(c + 1) * 8 - 1:c * 8] )
            );
        end
    endgenerate
    
    assign oDataLast    = wDataLast[0]      ;
    assign oParityValid = wParityStrobe[0]  ;
    assign oParityLast  = wParityLast[0]    ;
    assign oDataReady   = wDataReady[0]     ;
    
endmodule

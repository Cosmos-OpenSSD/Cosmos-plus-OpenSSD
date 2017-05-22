//////////////////////////////////////////////////////////////////////////////////
// InterChannelSyndromeBuffer.v for Cosmos OpenSSD
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
// Module Name: InterChannelSyndromeBuffer
// File Name: InterChannelSyndromeBuffer.v
//
// Version: v1.0.0
//
// Description: Syndrome buffer array
//   
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module InterChannelSyndromeBuffer
#(
    parameter   Channel             = 4,
    parameter   Multi               = 2,
    parameter   GaloisFieldDegree   = 12,
    parameter   Syndromes           = 27
)
(
    iClock              ,
    iReset              ,
    iErrorDetectionEnd  ,
    iDecodeNeeded       ,
    iSyndromes          ,
    oSharedKESReady     ,
    iKESAvailable       ,
    oExecuteKES         ,
    oErroredChunkNumber ,
    oDataFowarding      ,
    oLastChunk          ,
    oSyndromes          ,
    oChannelSel         
);

    input                                                       iClock              ;
    input                                                       iReset              ;
    input   [Channel*Multi - 1:0]                               iErrorDetectionEnd  ;
    input   [Channel*Multi - 1:0]                               iDecodeNeeded       ;
    input   [Channel*Multi*GaloisFieldDegree*Syndromes - 1:0]   iSyndromes          ;
    output  [Channel - 1:0]                                     oSharedKESReady     ;
    
    input                                                       iKESAvailable       ;
    output                                                      oExecuteKES         ;
    output                                                      oErroredChunkNumber ;
    output                                                      oDataFowarding      ;
    output                                                      oLastChunk          ;
    
    output  [GaloisFieldDegree*Syndromes - 1:0]                 oSyndromes          ;
    output  [3:0]                                               oChannelSel         ;
    
    wire    [Channel - 1:0]                                     wKESAvailable       ;
    wire    [3:0]                                               wChannelSel         ;
    reg     [3:0]                                               rChannelSel         ;
    wire    [1:0]                                               wChannelNum         ;
    wire    [Channel - 1:0]                                     wExecuteKES         ;
    wire    [Channel - 1:0]                                     wErroredChunkNumber ;
    wire    [Channel - 1:0]                                     wDataFowarding      ;
    wire    [Channel - 1:0]                                     wLastChunk          ;
    wire    [Channel*GaloisFieldDegree*Syndromes - 1:0]         wSyndromes          ;
    
    always @ (posedge iClock)
        if (iReset)
            rChannelSel <= 4'b0000;
        else
            rChannelSel <= wChannelSel;
    
    genvar c;
    generate
        for (c = 0; c < Channel; c = c + 1)    
        d_SC_KES_buffer
        #
        (
            .Multi(2),
            .GF(12)
        )
        PageDecoderSyndromeBuffer
        (
            .i_clk				(iClock),
            .i_RESET			(iReset),
            .i_stop_dec			(1'b0),
            
            .i_kes_available	(wChannelSel[c]),
            
            .i_exe_buf			(|iErrorDetectionEnd[ (c+1)*Multi - 1 : (c)*Multi ]),
            .i_ELP_search_needed(iErrorDetectionEnd[ (c+1)*Multi - 1 : (c)*Multi] & iDecodeNeeded[ (c+1)*Multi - 1 : (c)*Multi ]),
            .i_syndromes        (iSyndromes[(c+1)*Multi*GaloisFieldDegree*Syndromes - 1 : (c)*Multi*GaloisFieldDegree*Syndromes ]),
            
            .o_buf_available	(oSharedKESReady[c]),
            
            .o_exe_kes			(wExecuteKES[c]),
            .o_chunk_number	    (wErroredChunkNumber[c]),
            .o_data_fowarding   (wDataFowarding[c]),
            .o_buf_sequence_end	(wLastChunk[c]),
            .o_syndromes        (wSyndromes[ (c+1)*GaloisFieldDegree*Syndromes - 1: (c)*GaloisFieldDegree*Syndromes ])
        );
    endgenerate
    
    ChannelArbiter
    Inst_ChannelSelector
    (
        .iClock         (iClock),
        .iReset         (iReset),    
        .iRequestChannel(~oSharedKESReady),
        .iLastChunk     (wLastChunk),
        .oKESAvail      (wChannelSel),
        .oChannelNumber (wChannelNum),
        .iKESAvail      (iKESAvailable)
    );
    
    
    assign  oChannelSel         =   rChannelSel;
    assign  oExecuteKES         =   (wChannelNum == 1)  ?   wExecuteKES[1]  :
                                    (wChannelNum == 2)  ?   wExecuteKES[2]  :
                                    (wChannelNum == 3)  ?   wExecuteKES[3]  : 
                                                            wExecuteKES[0]  ;
    
    assign  oDataFowarding      =   (wChannelNum == 1)  ?   wDataFowarding[1]   :
                                    (wChannelNum == 2)  ?   wDataFowarding[2]   :
                                    (wChannelNum == 3)  ?   wDataFowarding[3]   :
                                                            wDataFowarding[0]   ;
    
    assign  oErroredChunkNumber =   (wChannelNum == 1)  ?   wErroredChunkNumber[1]    :
                                    (wChannelNum == 2)  ?   wErroredChunkNumber[2]    :
                                    (wChannelNum == 3)  ?   wErroredChunkNumber[3]    :
                                                            wErroredChunkNumber[0]    ;
    
    assign  oLastChunk          =   (wChannelNum == 1)  ?   wLastChunk[1]   :
                                    (wChannelNum == 2)  ?   wLastChunk[2]   :
                                    (wChannelNum == 3)  ?   wLastChunk[3]   :
                                                            wLastChunk[0]   ;
    
    assign  oSyndromes          =   (wChannelNum == 1)  ?   wSyndromes[2*GaloisFieldDegree*Syndromes - 1: 1*GaloisFieldDegree*Syndromes]    :
                                    (wChannelNum == 2)  ?   wSyndromes[3*GaloisFieldDegree*Syndromes - 1: 2*GaloisFieldDegree*Syndromes]    :
                                    (wChannelNum == 3)  ?   wSyndromes[4*GaloisFieldDegree*Syndromes - 1: 3*GaloisFieldDegree*Syndromes]    :
                                                            wSyndromes[GaloisFieldDegree*Syndromes - 1:0]   ;
    
endmodule
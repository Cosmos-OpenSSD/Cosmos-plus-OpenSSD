//////////////////////////////////////////////////////////////////////////////////
// InterChannelELPBuffer.v for Cosmos OpenSSD
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
// Module Name: InterChannelELPBuffer
// File Name: InterChannelELPBuffer.v
//
// Version: v1.0.0
//
// Description: Error location polynomial (ELP) coefficient buffer array
//   
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module InterChannelELPBuffer
#(
    parameter   Channel             = 4,
    parameter   Multi               = 2,
    parameter   MaxErrorCountBits   = 9,
    parameter   GaloisFieldDegree   = 12,
    parameter   ELPCoefficients     = 15
)
(
    iClock                  ,
    iReset                  ,
    iChannelSel             ,
    iKESEnd                 ,
    iKESFail                ,
    iClusterCorrectionEnd   ,
    iCorrectedChunkNumber   ,
    iChunkErrorCount        ,
    oBufferReady            ,
    
    iELPCoefficient000      ,
    iELPCoefficient001      ,
    iELPCoefficient002      ,
    iELPCoefficient003      ,
    iELPCoefficient004      ,
    iELPCoefficient005      ,
    iELPCoefficient006      ,
    iELPCoefficient007      ,
    iELPCoefficient008      ,
    iELPCoefficient009      ,
    iELPCoefficient010      ,
    iELPCoefficient011      ,
    iELPCoefficient012      ,
    iELPCoefficient013      ,
    iELPCoefficient014      ,
    
    iCSAvailable            ,
    oIntraSharedKESEnd      ,
    oErroredChunk           ,
    oCorrectionFail         ,
    oClusterErrorCount      ,
    oELPCoefficients        
);

    input                                                               iClock                  ;
    input                                                               iReset                  ;
    input   [3:0]                                                       iChannelSel             ;
    input                                                               iKESEnd                 ;
    input                                                               iKESFail                ;
    input                                                               iClusterCorrectionEnd   ;
    input                                                               iCorrectedChunkNumber   ;
    input   [3:0]                                                       iChunkErrorCount        ;
    output                                                              oBufferReady            ;
    
    input   [GaloisFieldDegree - 1:0]                                   iELPCoefficient000      ;
    input   [GaloisFieldDegree - 1:0]                                   iELPCoefficient001      ;
    input   [GaloisFieldDegree - 1:0]                                   iELPCoefficient002      ;
    input   [GaloisFieldDegree - 1:0]                                   iELPCoefficient003      ;
    input   [GaloisFieldDegree - 1:0]                                   iELPCoefficient004      ;
    input   [GaloisFieldDegree - 1:0]                                   iELPCoefficient005      ;
    input   [GaloisFieldDegree - 1:0]                                   iELPCoefficient006      ;
    input   [GaloisFieldDegree - 1:0]                                   iELPCoefficient007      ;
    input   [GaloisFieldDegree - 1:0]                                   iELPCoefficient008      ;
    input   [GaloisFieldDegree - 1:0]                                   iELPCoefficient009      ;
    input   [GaloisFieldDegree - 1:0]                                   iELPCoefficient010      ;
    input   [GaloisFieldDegree - 1:0]                                   iELPCoefficient011      ;
    input   [GaloisFieldDegree - 1:0]                                   iELPCoefficient012      ;
    input   [GaloisFieldDegree - 1:0]                                   iELPCoefficient013      ;
    input   [GaloisFieldDegree - 1:0]                                   iELPCoefficient014      ;
    
    input   [Channel - 1:0]                                             iCSAvailable            ;
    output  [Channel - 1:0]                                             oIntraSharedKESEnd      ;
    output  [Channel*Multi - 1:0]                                       oErroredChunk           ;
    output  [Channel*Multi - 1:0]                                       oCorrectionFail         ;
    output  [Channel*Multi*MaxErrorCountBits - 1:0]                     oClusterErrorCount      ;
    output  [Channel*Multi*GaloisFieldDegree*ELPCoefficients - 1:0]     oELPCoefficients        ;
    
    reg                                         rChannelSel             ;
    
    wire    [Channel - 1:0]                     wKESEnd                 ;
    wire    [Channel - 1:0]                     wBufferReady            ;
        
    assign  wKESEnd = (iKESEnd) ? iChannelSel : 0; 
    
    genvar c;
    generate
        for (c = 0; c < Channel; c = c + 1)
            d_KES_CS_buffer
            #(
                .Multi(2),
                .GaloisFieldDegree(12),
                .MaxErrorCountBits(9),
                .ELPCoefficients(15)
            )
            Inst_PageDecoderCSBuffer
            (
                .i_clk				(iClock ),
                .i_RESET		    (iReset ),
                .i_stop_dec			(1'b0   ),
                
                .i_exe_buf			(wKESEnd[c] ),
                .i_kes_fail			(iKESFail    ),
                .i_buf_sequence_end (iClusterCorrectionEnd   ),	
                .i_chunk_number		(iCorrectedChunkNumber    ),
                .i_error_count	    (iChunkErrorCount ),
                
                .i_v_000			(iELPCoefficient000 ),
                .i_v_001			(iELPCoefficient001 ),
                .i_v_002			(iELPCoefficient002 ),
                .i_v_003			(iELPCoefficient003 ),
                .i_v_004			(iELPCoefficient004 ),
                .i_v_005			(iELPCoefficient005 ),
                .i_v_006			(iELPCoefficient006 ),
                .i_v_007			(iELPCoefficient007 ),
                .i_v_008			(iELPCoefficient008 ),
                .i_v_009			(iELPCoefficient009 ),
                .i_v_010			(iELPCoefficient010 ),
                .i_v_011			(iELPCoefficient011 ),
                .i_v_012			(iELPCoefficient012 ),
                .i_v_013			(iELPCoefficient013 ),
                .i_v_014	        (iELPCoefficient014 ),
                
                .i_cs_available		(iCSAvailable[c]    ),
                
                .o_buf_available	(wBufferReady[c]   ),
                
                .o_exe_cs           (oIntraSharedKESEnd[c]  ),
                .o_kes_sequence_end	(oErroredChunk[(c+1)*Multi - 1: c*Multi]    ),
                .o_kes_fail			(oCorrectionFail[(c+1)*Multi - 1: c*Multi]  ),
                .o_error_count		(oClusterErrorCount[(c+1)*Multi*MaxErrorCountBits - 1: c*Multi*MaxErrorCountBits]   ),
                
                .o_ELP_coef		    (oELPCoefficients[(c+1)*Multi*GaloisFieldDegree*ELPCoefficients - 1: c*Multi*GaloisFieldDegree*ELPCoefficients] )
            );
    endgenerate
    
    assign  oBufferReady = (iChannelSel == 4'b0001) ? wBufferReady[0] :
                           (iChannelSel == 4'b0010) ? wBufferReady[1] :
                           (iChannelSel == 4'b0100) ? wBufferReady[2] :
                           (iChannelSel == 4'b1000) ? wBufferReady[3] : 1'b0;

endmodule
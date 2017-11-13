//////////////////////////////////////////////////////////////////////////////////
// SharedKESTop.v for Cosmos OpenSSD
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
// Module Name: SharedKESTop
// File Name: SharedKESTop.v
//
// Version: v1.0.0
//
// Description: Shared KES top module
//   
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module SharedKESTop
#(
    parameter   Channel             = 4,
    parameter   Multi               = 2,
    parameter   GaloisFieldDegree   = 12,
    parameter   MaxErrorCountBits   = 9,
    parameter   Syndromes           = 27,
    parameter   ELPCoefficients     = 15
)
(
    iClock                  ,
    iReset                  ,
    
    oSharedKESReady_0       ,
    iErrorDetectionEnd_0    ,
    iDecodeNeeded_0         ,
    iSyndromes_0            ,
    iCSAvailable_0          ,
    oIntraSharedKESEnd_0    ,
    oErroredChunk_0         ,
    oCorrectionFail_0       ,
    oClusterErrorCount_0    ,
    oELPCoefficients_0      ,
    
    oSharedKESReady_1       ,
    iErrorDetectionEnd_1    ,
    iDecodeNeeded_1         ,
    iSyndromes_1            ,
    iCSAvailable_1          ,
    oIntraSharedKESEnd_1    ,
    oErroredChunk_1         ,
    oCorrectionFail_1       ,
    oClusterErrorCount_1    ,
    oELPCoefficients_1      ,
    
    oSharedKESReady_2       ,
    iErrorDetectionEnd_2    ,
    iDecodeNeeded_2         ,
    iSyndromes_2            ,
    iCSAvailable_2          ,
    oIntraSharedKESEnd_2    ,
    oErroredChunk_2         ,
    oCorrectionFail_2       ,
    oClusterErrorCount_2    ,
    oELPCoefficients_2      ,
    
    oSharedKESReady_3       ,
    iErrorDetectionEnd_3    ,
    iDecodeNeeded_3         ,
    iSyndromes_3            ,
    iCSAvailable_3          ,
    oIntraSharedKESEnd_3    ,
    oErroredChunk_3         ,
    oCorrectionFail_3       ,
    oClusterErrorCount_3    ,
    oELPCoefficients_3      
    
); 

    input                                                             iClock                ;
    input                                                             iReset                ;
    
    output                                                            oSharedKESReady_0     ;
    input   [Multi - 1:0]                                             iErrorDetectionEnd_0  ;
    input   [Multi - 1:0]                                             iDecodeNeeded_0       ;
    input   [Multi*GaloisFieldDegree*Syndromes - 1:0]                 iSyndromes_0          ;
    input                                                             iCSAvailable_0        ;
    output                                                            oIntraSharedKESEnd_0  ;
    output  [Multi - 1:0]                                             oErroredChunk_0       ;
    output  [Multi - 1:0]                                             oCorrectionFail_0     ;
    output  [Multi*MaxErrorCountBits - 1:0]                           oClusterErrorCount_0  ;
    output  [Multi*GaloisFieldDegree*ELPCoefficients - 1:0]           oELPCoefficients_0    ;
    
    output                                                            oSharedKESReady_1     ;
    input   [Multi - 1:0]                                             iErrorDetectionEnd_1  ;
    input   [Multi - 1:0]                                             iDecodeNeeded_1       ;
    input   [Multi*GaloisFieldDegree*Syndromes - 1:0]                 iSyndromes_1          ;
    input                                                             iCSAvailable_1        ;
    output                                                            oIntraSharedKESEnd_1  ;
    output  [Multi - 1:0]                                             oErroredChunk_1       ;
    output  [Multi - 1:0]                                             oCorrectionFail_1     ;
    output  [Multi*MaxErrorCountBits - 1:0]                           oClusterErrorCount_1  ;
    output  [Multi*GaloisFieldDegree*ELPCoefficients - 1:0]           oELPCoefficients_1    ;
    
    output                                                            oSharedKESReady_2     ;
    input   [Multi - 1:0]                                             iErrorDetectionEnd_2  ;
    input   [Multi - 1:0]                                             iDecodeNeeded_2       ;
    input   [Multi*GaloisFieldDegree*Syndromes - 1:0]                 iSyndromes_2          ;
    input                                                             iCSAvailable_2        ;
    output                                                            oIntraSharedKESEnd_2  ;
    output  [Multi - 1:0]                                             oErroredChunk_2       ;
    output  [Multi - 1:0]                                             oCorrectionFail_2     ;
    output  [Multi*MaxErrorCountBits - 1:0]                           oClusterErrorCount_2  ;
    output  [Multi*GaloisFieldDegree*ELPCoefficients - 1:0]           oELPCoefficients_2    ;
    
    output                                                            oSharedKESReady_3     ;
    input   [Multi - 1:0]                                             iErrorDetectionEnd_3  ;
    input   [Multi - 1:0]                                             iDecodeNeeded_3       ;
    input   [Multi*GaloisFieldDegree*Syndromes - 1:0]                 iSyndromes_3          ;
    input                                                             iCSAvailable_3        ;
    output                                                            oIntraSharedKESEnd_3  ;
    output  [Multi - 1:0]                                             oErroredChunk_3       ;
    output  [Multi - 1:0]                                             oCorrectionFail_3     ;
    output  [Multi*MaxErrorCountBits - 1:0]                           oClusterErrorCount_3  ;
    output  [Multi*GaloisFieldDegree*ELPCoefficients - 1:0]           oELPCoefficients_3    ;
    
    wire                                            wKESAvailable           ;
    wire                                            wExecuteKES             ;
    wire                                            wErroredChunkNumber     ;
    wire                                            wDataFowarding          ;
    wire                                            wLastChunk              ;
    wire                                            wOutBufferReady         ;
    wire                                            wKESEnd                 ;
    wire                                            wKESFail                ;
    wire                                            wCorrectedChunkNumber   ;
    wire                                            wClusterCorrectionEnd   ;
    wire    [3:0]                                   wChunkErrorCount        ;
    wire    [Channel - 1:0]                         wChannelSelIn           ;
    wire    [Channel - 1:0]                         wChannelSelOut          ;
    
    wire    [GaloisFieldDegree*Syndromes - 1:0]     wSyndromes              ;
    
    wire    [GaloisFieldDegree - 1:0]               wELPCoefficient000      ;
    wire    [GaloisFieldDegree - 1:0]               wELPCoefficient001      ;
    wire    [GaloisFieldDegree - 1:0]               wELPCoefficient002      ;
    wire    [GaloisFieldDegree - 1:0]               wELPCoefficient003      ;
    wire    [GaloisFieldDegree - 1:0]               wELPCoefficient004      ;
    wire    [GaloisFieldDegree - 1:0]               wELPCoefficient005      ;
    wire    [GaloisFieldDegree - 1:0]               wELPCoefficient006      ;
    wire    [GaloisFieldDegree - 1:0]               wELPCoefficient007      ;
    wire    [GaloisFieldDegree - 1:0]               wELPCoefficient008      ;
    wire    [GaloisFieldDegree - 1:0]               wELPCoefficient009      ;
    wire    [GaloisFieldDegree - 1:0]               wELPCoefficient010      ;
    wire    [GaloisFieldDegree - 1:0]               wELPCoefficient011      ;
    wire    [GaloisFieldDegree - 1:0]               wELPCoefficient012      ;
    wire    [GaloisFieldDegree - 1:0]               wELPCoefficient013      ;
    wire    [GaloisFieldDegree - 1:0]               wELPCoefficient014      ;
    
    InterChannelSyndromeBuffer
    #(
        .Channel(4),
        .Multi(2),
        .GaloisFieldDegree(12),
        .Syndromes(27)
    )
    PageDecoderSyndromeBuffer
    (
        .iClock                 (iClock                                                                                     ),
        .iReset                 (iReset                                                                                     ),
        .iErrorDetectionEnd     ({iErrorDetectionEnd_3, iErrorDetectionEnd_2, iErrorDetectionEnd_1, iErrorDetectionEnd_0}   ),
        .iDecodeNeeded          ({iDecodeNeeded_3, iDecodeNeeded_2, iDecodeNeeded_1, iDecodeNeeded_0}                       ),
        .iSyndromes             ({iSyndromes_3, iSyndromes_2, iSyndromes_1, iSyndromes_0}                                   ),
        .oSharedKESReady        ({oSharedKESReady_3, oSharedKESReady_2, oSharedKESReady_1, oSharedKESReady_0}               ),
        .iKESAvailable          (wKESAvailable                                                                              ),
        .oExecuteKES            (wExecuteKES                                                                                ),
        .oErroredChunkNumber    (wErroredChunkNumber                                                                        ),
        .oDataFowarding         (wDataFowarding                                                                             ),
        .oLastChunk             (wLastChunk                                                                                 ),
        .oSyndromes             (wSyndromes                                                                                 ),
        .oChannelSel            (wChannelSelIn                                                                              )
    );
      
    d_BCH_KES_top
	PageDecoderKES
	(
		.i_clk				(iClock),
		.i_RESET			(iReset),
		.i_stop_dec			(1'b0),
		
        .i_channel_sel      (wChannelSelIn),
		.i_execute_kes		(wExecuteKES),
        .i_data_fowarding   (wDataFowarding),
		.i_buf_available	(wOutBufferReady),
		
		.i_chunk_number	    (wErroredChunkNumber),
		.i_buf_sequence_end	(wLastChunk),
		
		.o_kes_sequence_end	(wKESEnd),
		.o_kes_fail			(wKESFail),
		.o_kes_available	(wKESAvailable),
		.o_chunk_number	    (wCorrectedChunkNumber),
		.o_buf_sequence_end	(wClusterCorrectionEnd),
		.o_channel_sel      (wChannelSelOut),
		.o_error_count		(wChunkErrorCount),
		
		.i_syndromes        (wSyndromes),
		
		.o_v_2i_000			(wELPCoefficient000),
		.o_v_2i_001			(wELPCoefficient001),
		.o_v_2i_002			(wELPCoefficient002),
		.o_v_2i_003			(wELPCoefficient003),
		.o_v_2i_004			(wELPCoefficient004),
		.o_v_2i_005			(wELPCoefficient005),
		.o_v_2i_006			(wELPCoefficient006),
		.o_v_2i_007			(wELPCoefficient007),
		.o_v_2i_008			(wELPCoefficient008),
		.o_v_2i_009			(wELPCoefficient009),
		.o_v_2i_010			(wELPCoefficient010),
		.o_v_2i_011			(wELPCoefficient011),
		.o_v_2i_012			(wELPCoefficient012),
		.o_v_2i_013			(wELPCoefficient013),
		.o_v_2i_014			(wELPCoefficient014)
	);
    
    InterChannelELPBuffer 
	#(
        .Channel(4),
		.Multi(2),
		.GaloisFieldDegree(12),
        .ELPCoefficients(15)
	)
	PageDecoderELPBuffer
	(
        .iClock                 (iClock                                                                                     ),
        .iReset                 (iReset                                                                                     ),
        .iChannelSel            (wChannelSelOut                                                                             ),
        .iKESEnd                (wKESEnd                                                                                    ),
        .iKESFail               (wKESFail                                                                                   ),
        .iClusterCorrectionEnd  (wClusterCorrectionEnd                                                                      ),
        .iCorrectedChunkNumber  (wCorrectedChunkNumber                                                                      ),
        .iChunkErrorCount       (wChunkErrorCount                                                                           ),
        .oBufferReady           (wOutBufferReady                                                                            ),
        
        .iELPCoefficient000     (wELPCoefficient000                                                                         ),
        .iELPCoefficient001     (wELPCoefficient001                                                                         ),
        .iELPCoefficient002     (wELPCoefficient002                                                                         ),
        .iELPCoefficient003     (wELPCoefficient003                                                                         ),
        .iELPCoefficient004     (wELPCoefficient004                                                                         ),
        .iELPCoefficient005     (wELPCoefficient005                                                                         ),
        .iELPCoefficient006     (wELPCoefficient006                                                                         ),
        .iELPCoefficient007     (wELPCoefficient007                                                                         ),
        .iELPCoefficient008     (wELPCoefficient008                                                                         ),
        .iELPCoefficient009     (wELPCoefficient009                                                                         ),
        .iELPCoefficient010     (wELPCoefficient010                                                                         ),
        .iELPCoefficient011     (wELPCoefficient011                                                                         ),
        .iELPCoefficient012     (wELPCoefficient012                                                                         ),
        .iELPCoefficient013     (wELPCoefficient013                                                                         ),
        .iELPCoefficient014     (wELPCoefficient014                                                                         ),
        
        .iCSAvailable           ({iCSAvailable_3, iCSAvailable_2, iCSAvailable_1, iCSAvailable_0}                           ),
        .oIntraSharedKESEnd     ({oIntraSharedKESEnd_3, oIntraSharedKESEnd_2, oIntraSharedKESEnd_1, oIntraSharedKESEnd_0}   ),
        .oErroredChunk          ({oErroredChunk_3, oErroredChunk_2, oErroredChunk_1, oErroredChunk_0}                       ),
        .oCorrectionFail        ({oCorrectionFail_3, oCorrectionFail_2, oCorrectionFail_1, oCorrectionFail_0}               ),
        .oClusterErrorCount     ({oClusterErrorCount_3, oClusterErrorCount_2, oClusterErrorCount_1, oClusterErrorCount_0}   ),
        .oELPCoefficients       ({oELPCoefficients_3, oELPCoefficients_2, oELPCoefficients_1, oELPCoefficients_0}           )
    );
    
endmodule
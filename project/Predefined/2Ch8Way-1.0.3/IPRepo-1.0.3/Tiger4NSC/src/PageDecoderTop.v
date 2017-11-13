//////////////////////////////////////////////////////////////////////////////////
// PageDecoderTop.v for Cosmos OpenSSD
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
// Design Name: BCH Decoder array
// Module Name: PageDecoderTop
// File Name: PageDecoderTop.v
//
// Version: v2.0.0
//
// Description: BCH decoder excluding KES. The decoder is constructed by 
//              data width converters, SC, CS, and BRAM
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v2.0.0
//   - apply KES sharing and pipelining
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module PageDecoderTop
#(
    parameter   Multi               = 2,
    parameter   GaloisFieldDegree   = 12,
    parameter   MaxErrorCountBits   = 9,
    parameter   DataWidth           = 32,
    parameter   Syndromes           = 27,
    parameter   ELPCoefficients     = 15
)
(
    iClock              ,
    iReset              ,
    iExecuteDecoding    ,
    iDataValid          ,
    iData               ,
    oDataReady          ,
    oDecoderReady       ,
    oInDataLast         ,
    
    oDecoderFinished    ,
    oErrorCountOut      ,
    oDecodeEnd          ,
    oErroredChunk       ,
    oDecodeFailed       ,
    iMuxDataReady       ,
    oDecOutDataStrobe   ,
    oDecOutDataLast     ,
    oDecOutData         ,
    
    iSharedKESReady     ,
    oErrorDetectionEnd  ,
    oDecodeNeeded       ,
    oSyndromes          ,
    
    iIntraSharedKESEnd  ,
    iErroredChunk       ,
    iCorrectionFail     ,
    iErrorCount         ,
    iELPCoefficients    ,
    oCSAvailable
);

    input                                                           iClock              ;              
    input                                                           iReset              ;
    input                                                           iExecuteDecoding    ;
    input   [Multi - 1:0]                                           iDataValid          ;
    input   [DataWidth - 1:0]                                       iData               ;
    output                                                          oDataReady          ;
    output  [Multi - 1:0]                                           oDecoderReady       ;
    output  [Multi - 1:0]                                           oInDataLast         ;
    output  [Multi - 1:0]                                           oDecoderFinished    ;
    input   [Multi - 1:0]                                           iMuxDataReady       ;
    output                                                          oDecOutDataStrobe   ;
    output                                                          oDecOutDataLast     ;
    output  [DataWidth - 1:0]                                       oDecOutData         ;
    
    input                                                           iSharedKESReady     ;
    output  [Multi - 1:0]                                           oErrorDetectionEnd  ;
    output  [Multi - 1:0]                                           oDecodeNeeded       ;
    output  [Multi*GaloisFieldDegree*Syndromes - 1:0]               oSyndromes          ;
    output                                                          oCSAvailable        ;
    input                                                           iIntraSharedKESEnd  ;
    input   [Multi - 1:0]                                           iErroredChunk       ;
    input   [Multi - 1:0]                                           iCorrectionFail     ;
    input   [Multi*MaxErrorCountBits - 1:0]                         iErrorCount         ;
    input   [Multi*GaloisFieldDegree*ELPCoefficients - 1:0]         iELPCoefficients    ;
    
    output  [Multi*MaxErrorCountBits - 1:0]                         oErrorCountOut      ;
    output                                                          oDecodeEnd          ;
    output  [Multi - 1:0]                                           oErroredChunk       ;
    output  [Multi - 1:0]                                           oDecodeFailed       ;
    
    
    wire    [Multi - 1:0]                                           wBRAMWriteValid     ;
    wire    [Multi*8 - 1:0]                                         wBRAMWriteAddress   ;
    wire    [DataWidth/2 - 1:0]                                     wBRAMWriteData      ;
    wire    [Multi - 1:0]                                           wBRAMReadValid      ;
    wire    [Multi*8 - 1:0]                                         wBRAMReadAddress    ;
    wire    [DataWidth/2 - 1:0]                                     wBRAMReadData       ;
    wire                                                            wConvertedDataValid ;
    wire    [DataWidth/2 - 1:0]                                     wConvertedData      ;
    wire                                                            wConvertedDataReady ;
    wire    [DataWidth/2 - 1:0]                                     wDecOutData         ;
    wire    [Multi - 1:0]                                           wDecOutDataStrobe   ;
    wire    [Multi - 1:0]                                           wDecOutDataLast     ;
    wire                                                            wConverterReady     ;
    
    assign  oErrorCountOut = iErrorCount;
    assign  oDecodeEnd = iIntraSharedKESEnd;
    assign  oErroredChunk = iErroredChunk;
    assign  oDecodeFailed = iCorrectionFail;
    
    DecWidthConverter32to16
    #(
        .InputDataWidth         (DataWidth                      ),
        .OutputDataWidth        (DataWidth/2                    )
    )
    Inst_DownConverter
    (
        .iClock                 (iClock                         ),    
        .iReset                 (iReset                         ),
        .iSrcDataValid          (iDataValid[0]                  ),
        .iSrcData               (iData                          ),
        .oConverterReady        (oDataReady                     ),
        .oConvertedDataValid    (wConvertedDataValid            ),
        .oConvertedData         (wConvertedData                 ),
        .iDstReady              (wConvertedDataReady            )
    );
    
    d_BCH_SC_X	
	#(
		.Multi                  (Multi                          ),
		.GF                     (GaloisFieldDegree              )
	)
	PageDecoderSC_X
	(
		.i_clk                  (iClock                         ),
		.i_RESET                (iReset                         ),
        
		.i_buf_available        (iSharedKESReady                ),
		.i_exe_sc               (iExecuteDecoding               ),
		.i_code_valid           (wConvertedDataValid            ),
		.i_code                 (wConvertedData                 ),
        .o_code_ready           (wConvertedDataReady            ),
	
		.o_sc_available         (oDecoderReady                  ),
	
		.o_last_c_block_rcvd    (oInDataLast                    ),
		.o_sc_cmplt             (oErrorDetectionEnd             ),
		.o_error_detected       (oDecodeNeeded                  ),
	
		.o_BRAM_write_enable    (wBRAMWriteValid                ),
		.o_BRAM_write_address   (wBRAMWriteAddress              ),
		.o_BRAM_write_data      (wBRAMWriteData                 ),
	
		.o_sdr_001              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes -  0) - 1 : Multi * GaloisFieldDegree * (Syndromes -  1)]),
		.o_sdr_002              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes -  1) - 1 : Multi * GaloisFieldDegree * (Syndromes -  2)]),
		.o_sdr_003              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes -  2) - 1 : Multi * GaloisFieldDegree * (Syndromes -  3)]),
		.o_sdr_004              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes -  3) - 1 : Multi * GaloisFieldDegree * (Syndromes -  4)]),
		.o_sdr_005              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes -  4) - 1 : Multi * GaloisFieldDegree * (Syndromes -  5)]),
		.o_sdr_006              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes -  5) - 1 : Multi * GaloisFieldDegree * (Syndromes -  6)]),
		.o_sdr_007              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes -  6) - 1 : Multi * GaloisFieldDegree * (Syndromes -  7)]),
		.o_sdr_008              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes -  7) - 1 : Multi * GaloisFieldDegree * (Syndromes -  8)]),
		.o_sdr_009              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes -  8) - 1 : Multi * GaloisFieldDegree * (Syndromes -  9)]),
		.o_sdr_010              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes -  9) - 1 : Multi * GaloisFieldDegree * (Syndromes - 10)]),
		.o_sdr_011              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes - 10) - 1 : Multi * GaloisFieldDegree * (Syndromes - 11)]),
		.o_sdr_012              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes - 11) - 1 : Multi * GaloisFieldDegree * (Syndromes - 12)]),
		.o_sdr_013              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes - 12) - 1 : Multi * GaloisFieldDegree * (Syndromes - 13)]),
		.o_sdr_014              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes - 13) - 1 : Multi * GaloisFieldDegree * (Syndromes - 14)]),
		.o_sdr_015              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes - 14) - 1 : Multi * GaloisFieldDegree * (Syndromes - 15)]),
		.o_sdr_016              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes - 15) - 1 : Multi * GaloisFieldDegree * (Syndromes - 16)]),
		.o_sdr_017              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes - 16) - 1 : Multi * GaloisFieldDegree * (Syndromes - 17)]),
		.o_sdr_018              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes - 17) - 1 : Multi * GaloisFieldDegree * (Syndromes - 18)]),
		.o_sdr_019              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes - 18) - 1 : Multi * GaloisFieldDegree * (Syndromes - 19)]),
		.o_sdr_020              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes - 19) - 1 : Multi * GaloisFieldDegree * (Syndromes - 20)]),
		.o_sdr_021              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes - 20) - 1 : Multi * GaloisFieldDegree * (Syndromes - 21)]),
		.o_sdr_022              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes - 21) - 1 : Multi * GaloisFieldDegree * (Syndromes - 22)]),
		.o_sdr_023              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes - 22) - 1 : Multi * GaloisFieldDegree * (Syndromes - 23)]),
		.o_sdr_024              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes - 23) - 1 : Multi * GaloisFieldDegree * (Syndromes - 24)]),
		.o_sdr_025              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes - 24) - 1 : Multi * GaloisFieldDegree * (Syndromes - 25)]),
		.o_sdr_026              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes - 25) - 1 : Multi * GaloisFieldDegree * (Syndromes - 26)]),
		.o_sdr_027              (oSyndromes [ Multi * GaloisFieldDegree * (Syndromes - 26) - 1 : Multi * GaloisFieldDegree * (Syndromes - 27)])
	);
    
    d_r_message_buffer_X
	#(
		.Multi                          (Multi                          ),
        .AddressWidth                   (8                              ),
        .DataWidth                      (DataWidth/2                    )
	)
	PageDecoderBRAM_X
	(
		.i_clk                          (iClock                         ),
		.i_RESET                        (iReset                         ),
		.i_ena                          (wBRAMWriteValid                ),
		.i_wea                          (wBRAMWriteValid                ),
		.i_addra                        (wBRAMWriteAddress              ),
		.i_dina                         (wBRAMWriteData                 ),
		.i_clkb                         (iClock                         ),
		.i_enb                          (wBRAMReadValid                 ),
		.i_addrb                        (wBRAMReadAddress               ),
		.o_doutb                        (wBRAMReadData                  ),
        .i_ELP_search_stage_end         (iIntraSharedKESEnd             ),
		.i_c_message_output_cmplt       (wDecOutDataLast                ),
		.i_error_detection_stage_end    (|oErrorDetectionEnd            )
	);
    
    d_BCH_CS_X 
	#(
		.Multi                          (Multi                          ),
		.GF                             (GaloisFieldDegree              )
	)
	PageDecoderCS_X
	(
		.i_clk                      (iClock                             ),
		.i_RESET                    (iReset                             ),
		.i_exe_cs                   (iIntraSharedKESEnd                 ),
        .i_data_fowarding           (~iErroredChunk | iCorrectionFail   ),
		.i_MUX_data_ready           (wConverterReady                    ),
		.i_BRAM_read_data           (wBRAMReadData                      ),
	
		.i_v_000                    (iELPCoefficients [ Multi * GaloisFieldDegree * (ELPCoefficients -  0) - 1 : Multi * GaloisFieldDegree * (ELPCoefficients -  1)] ),
		.i_v_001                    (iELPCoefficients [ Multi * GaloisFieldDegree * (ELPCoefficients -  1) - 1 : Multi * GaloisFieldDegree * (ELPCoefficients -  2)] ),	
		.i_v_002                    (iELPCoefficients [ Multi * GaloisFieldDegree * (ELPCoefficients -  2) - 1 : Multi * GaloisFieldDegree * (ELPCoefficients -  3)] ),
		.i_v_003                    (iELPCoefficients [ Multi * GaloisFieldDegree * (ELPCoefficients -  3) - 1 : Multi * GaloisFieldDegree * (ELPCoefficients -  4)] ),
		.i_v_004                    (iELPCoefficients [ Multi * GaloisFieldDegree * (ELPCoefficients -  4) - 1 : Multi * GaloisFieldDegree * (ELPCoefficients -  5)] ),
		.i_v_005                    (iELPCoefficients [ Multi * GaloisFieldDegree * (ELPCoefficients -  5) - 1 : Multi * GaloisFieldDegree * (ELPCoefficients -  6)] ),
		.i_v_006                    (iELPCoefficients [ Multi * GaloisFieldDegree * (ELPCoefficients -  6) - 1 : Multi * GaloisFieldDegree * (ELPCoefficients -  7)] ),
		.i_v_007                    (iELPCoefficients [ Multi * GaloisFieldDegree * (ELPCoefficients -  7) - 1 : Multi * GaloisFieldDegree * (ELPCoefficients -  8)] ),
		.i_v_008                    (iELPCoefficients [ Multi * GaloisFieldDegree * (ELPCoefficients -  8) - 1 : Multi * GaloisFieldDegree * (ELPCoefficients -  9)] ),
		.i_v_009                    (iELPCoefficients [ Multi * GaloisFieldDegree * (ELPCoefficients -  9) - 1 : Multi * GaloisFieldDegree * (ELPCoefficients - 10)] ),
		.i_v_010                    (iELPCoefficients [ Multi * GaloisFieldDegree * (ELPCoefficients - 10) - 1 : Multi * GaloisFieldDegree * (ELPCoefficients - 11)] ),
		.i_v_011                    (iELPCoefficients [ Multi * GaloisFieldDegree * (ELPCoefficients - 11) - 1 : Multi * GaloisFieldDegree * (ELPCoefficients - 12)] ),
		.i_v_012                    (iELPCoefficients [ Multi * GaloisFieldDegree * (ELPCoefficients - 12) - 1 : Multi * GaloisFieldDegree * (ELPCoefficients - 13)] ),
		.i_v_013                    (iELPCoefficients [ Multi * GaloisFieldDegree * (ELPCoefficients - 13) - 1 : Multi * GaloisFieldDegree * (ELPCoefficients - 14)] ),
		.i_v_014                    (iELPCoefficients [ Multi * GaloisFieldDegree * (ELPCoefficients - 14) - 1 : Multi * GaloisFieldDegree * (ELPCoefficients - 15)] ),
	
		.o_cs_available             (oCSAvailable                       ),
		.o_cs_cmplt                 (oDecoderFinished                   ),
		.o_BRAM_read_enable         (wBRAMReadValid                     ),
		.o_BRAM_read_address        (wBRAMReadAddress                   ),
		.o_c_message_valid          (wDecOutDataStrobe                  ),
		.o_c_message_output_cmplt   (wDecOutDataLast                    ),
		.o_c_message                (wDecOutData                        )
	);
    
    
    DecWidthConverter16to32
    #(
        .InputDataWidth         (DataWidth/2            ),
        .OutputDataWidth        (DataWidth              )
    )
    Inst_UpConverter
    (
        .iClock                 (iClock                 ),
        .iReset                 (iReset                 ),
        .iSrcDataValid          (wDecOutDataStrobe[0]   ),
        .iSrcData               (wDecOutData            ),
        .iSrcDataLast           (wDecOutDataLast[0]     ),
        .oConverterReady        (wConverterReady        ),
        .oConvertedDataValid    (oDecOutDataStrobe      ),
        .oConvertedData         (oDecOutData            ),
        .oConvertedDataLast     (oDecOutDataLast        ),
        .iDstReady              (iMuxDataReady[0]       )
    );
    
endmodule
//////////////////////////////////////////////////////////////////////////////////
// BCHDecoderX for Cosmos OpenSSD
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
// Design Name: BCH decoder array
// Module Name: BCHDecoderX
// File Name: BCHDecoderX.v
//
// Version: v1.0.0
//
// Description: BCH decoder array
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module BCHDecoderX
#
(
    parameter   DataWidth           = 32,
    parameter   Multi               = 2,
    parameter   MaxErrorCountBits   = 9,
    parameter   GaloisFieldDegree   = 12,
    parameter   Syndromes           = 27,
    parameter   ELPCoefficients     = 15
)
(
    iClock              ,
    iReset              ,
    iData               ,
    iDataValid          ,
    oDataReady          ,
    oDataLast           ,
    oDecoderReady       ,
    oDecodeFinished     ,
    oDecodeSuccess      ,
    oErrorSum           ,
    oErrorCountOut      ,
    oCorrectedData      ,
    oCorrectedDataValid ,
    oCorrectedDataLast  ,
    iCorrectedDataReady ,
    
    iSharedKESReady     ,
    oErrorDetectionEnd  ,
    oDecodeNeeded       ,
    oSyndromes          ,
    iIntraSharedKESEnd  ,
    iErroredChunk       ,
    iCorrectionFail     ,
    iErrorCount         ,
    iELPCoefficients    ,
    oCSAvailable        ,
    iCSReset
);
    input                                                   iClock              ;
    input                                                   iReset              ;
    input   [DataWidth - 1:0]                               iData               ;
    input                                                   iDataValid          ;
    output                                                  oDataReady          ;
    output                                                  oDecoderReady       ;
    output                                                  oDecodeFinished     ;
    output                                                  oDecodeSuccess      ;
    output  [MaxErrorCountBits - 1:0]                       oErrorSum           ;
    output  [4*Multi - 1:0]                                 oErrorCountOut      ;
    output                                                  oDataLast           ;
    output  [DataWidth - 1:0]                               oCorrectedData      ;
    output                                                  oCorrectedDataValid ;
    output                                                  oCorrectedDataLast  ;
    input                                                   iCorrectedDataReady ;
        
    input                                                   iSharedKESReady     ;
    output  [Multi - 1:0]                                   oErrorDetectionEnd  ;
    output  [Multi - 1:0]                                   oDecodeNeeded       ;
    output  [Multi*GaloisFieldDegree*Syndromes - 1:0]       oSyndromes          ;
    input                                                   iIntraSharedKESEnd  ;
    input   [Multi - 1:0]                                   iErroredChunk       ;
    input   [Multi - 1:0]                                   iCorrectionFail     ;
    input   [Multi*MaxErrorCountBits - 1:0]                 iErrorCount         ;
    input   [Multi*GaloisFieldDegree*ELPCoefficients - 1:0] iELPCoefficients    ;
    output                                                  oCSAvailable        ;
    input                                                   iCSReset            ;
    
    wire    [Multi - 1:0]                   wDecoderReady       ;
    wire    [Multi - 1:0]                   wDataValid          ;
    
    wire    [Multi - 1:0]                   wInDataLast         ;
    wire    [DataWidth - 1:0]               wDecOutData         ;
    wire                                    wDecOutDataStrobe   ;
    wire                                    wDecOutDataLast     ;
    
    wire                                    wDecodeEnd          ;
    wire    [Multi - 1:0]                   wErroredData        ;
    wire    [Multi - 1:0]                   wDecodeFailed       ;
    wire    [Multi - 1:0]                   wDecoderFinished    ;
    
    reg     [DataWidth - 1:0]               rDecOutData         ;
    reg                                     rDecOutDataValid    ;
    reg                                     rDecOutDataLast     ;
    wire    [Multi - 1:0]                   wMuxDataReady       ;
    
    reg     [Multi - 1:0]                   rDecoderStatus      ;
    reg     [Multi - 1:0]                   rSuccessStatus      ;
    wire                                    wAllDecoderFinished ;
    wire                                    wAllDecoderSucceeded;
    
    wire    [MaxErrorCountBits*Multi - 1:0] wErrorCountOut      ;
    reg     [MaxErrorCountBits*Multi - 1:0] rErrorCountOut      ;
    reg     [MaxErrorCountBits - 1:0]       rSumOfErrorCount    ;
    wire                                    wReset              ;
    
    localparam  ChunkSize       = 256;
    localparam  ChunkSizeBits   = 8;
    
    genvar c;
    
    generate
        for (c = 0; c < Multi; c = c + 1)
        begin
            always @ (posedge iClock)
            if (iReset)
                rDecoderStatus[c]   <= 1'b0;
            else
                if (wDecodeEnd)
                    rDecoderStatus[c]  <= 1'b1;
                else if (wAllDecoderFinished)
                    rDecoderStatus[c]  <= 1'b0;
                    
            always @ (posedge iClock)
            if (iReset)
                rSuccessStatus[c]   <= 1'b0;
            else
                if (wDecodeEnd)
                    rSuccessStatus[c]  <= (wDecodeFailed) ? 1'b0 : 1'b1;
                else if (wAllDecoderFinished)
                    rSuccessStatus[c]  <= 1'b0;
            
            /*always @ (*)
                begin
                    rDecOutData[(c + 1) * 8 - 1:c * 8]  <= wDecOutData[(c + 1) * 8 - 1:c * 8];
                    rDecOutDataValid[c]                 <= wDecOutDataStrobe[c];
                    rDecOutDataLast[c]                  <= wDecOutDataLast[c];
                end
            */
            assign wMuxDataReady[c] = iCorrectedDataReady && oCorrectedDataValid;
            assign wDataValid[c]    = iDataValid;
        end
    endgenerate
    
    PageDecoderTop
    #
    (
        .Multi              (Multi              ),
        .GaloisFieldDegree  (GaloisFieldDegree  ),
        .MaxErrorCountBits  (MaxErrorCountBits  ),
        .DataWidth          (32                 ),
        .Syndromes          (Syndromes          ),
        .ELPCoefficients    (ELPCoefficients    )
    )
    Inst_BCHPDecoder
    (
        .iClock             (iClock             ),
        .iReset             (wReset             ),
        .iExecuteDecoding   (1'b1               ),
        .iDataValid         (wDataValid         ),
        .iData              (iData              ),
        .oDataReady         (oDataReady         ),
        .oDecoderReady      (wDecoderReady      ),
        .oInDataLast        (wInDataLast        ),
        .oDecoderFinished   (wDecoderFinished   ),
        .oErrorCountOut     (wErrorCountOut     ),
        .oDecodeEnd         (wDecodeEnd         ),
        .oErroredChunk      (wErroredData       ),
        .oDecodeFailed      (wDecodeFailed      ),
        .iMuxDataReady      (wMuxDataReady      ),
        .oDecOutDataStrobe  (wDecOutDataStrobe  ),
        .oDecOutDataLast    (wDecOutDataLast    ),
        .oDecOutData        (wDecOutData        ),
        .iSharedKESReady    (iSharedKESReady    ),
        .oErrorDetectionEnd (oErrorDetectionEnd ),
        .oDecodeNeeded      (oDecodeNeeded      ),
        .oSyndromes         (oSyndromes         ),
        .iIntraSharedKESEnd (iIntraSharedKESEnd ),
        .iErroredChunk      (iErroredChunk      ),
        .iCorrectionFail    (iCorrectionFail    ),
        .iErrorCount        (iErrorCount        ),
        .iELPCoefficients   (iELPCoefficients   ),
        .oCSAvailable       (oCSAvailable       )
    );
    
    assign oDecoderReady = &(wDecoderReady);
    assign wReset = iReset | iCSReset;
    
    initial begin
    if (Multi != 2 || MaxErrorCountBits != 9)
    begin
        $display ("Modify <rSumOfErrorCount> in BCHDecoderX to continue.");
        $finish;
    end
    end
    always @ (posedge iClock)
        if (iReset) begin
            rSumOfErrorCount <= {(MaxErrorCountBits){1'b0}};
			rErrorCountOut	 <= {(MaxErrorCountBits*Multi){1'b0}};
			end
        else
			if (wAllDecoderFinished) begin
				rSumOfErrorCount <= {(MaxErrorCountBits){1'b0}};
				rErrorCountOut	 <= {(MaxErrorCountBits*Multi){1'b0}};
				end
            else if (wDecodeEnd) begin
                rSumOfErrorCount <= (wErrorCountOut[17:9] + wErrorCountOut[8:0]);
				rErrorCountOut 	 <= wErrorCountOut;
				end
	
    always @ (*)
        begin
            rDecOutData         <=  wDecOutData         ;
            rDecOutDataLast     <=  wDecOutDataLast     ;
            rDecOutDataValid    <=  wDecOutDataStrobe   ;
        end
        
    assign wAllDecoderFinished  = &(rDecoderStatus);
    assign wAllDecoderSucceeded = &(rSuccessStatus);
    
    assign oDecodeFinished  = wAllDecoderFinished   ;
    assign oDecodeSuccess   = wAllDecoderSucceeded  ;
    assign oErrorSum        = rSumOfErrorCount      ;
	assign oErrorCountOut	= { rErrorCountOut[12:9 ],
								rErrorCountOut[3 :0 ] };
    
    assign oCorrectedData       = rDecOutData           ;
    assign oCorrectedDataLast   = &rDecOutDataLast      ;
    assign oCorrectedDataValid  = &rDecOutDataValid     ;
    
    assign oDataLast = wInDataLast[0];
    
endmodule
//////////////////////////////////////////////////////////////////////////////////
// CompletionDataChannel for Cosmos OpenSSD
// Copyright (c) 2015 Hanyang University ENC Lab.
// Contributed by Kibin Park <kbpark@enc.hanyang.ac.kr>
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
// Engineer: Kibin Park <kbpark@enc.hanyang.ac.kr>
// 
// Project Name: Cosmos OpenSSD
// Design Name: Completion data channel
// Module Name: CompletionDataChannel
// File Name: CompletionDataChannel.v
//
// Version: v1.0.0
//
// Description: Reports completion of an operation
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module CompletionDataChannel
#
(
    parameter DataWidth             = 32    ,
    parameter InnerIFLengthWidth    = 16    ,
    parameter ThisID                = 1
)
(
    iClock          ,
    iReset          ,
    iSrcLength      ,
    iSrcTargetID    ,
    iSrcValid       ,
    oSrcReady       ,
    iSrcWriteData   ,
    iSrcWriteValid  ,
    iSrcWriteLast   ,
    oSrcWriteReady  ,
    oDstWriteData   ,
    oDstWriteValid  ,
    oDstWriteLast   ,
    iDstWriteReady
);

    input                               iClock          ;
    input                               iReset          ;
    
    // Master side
    input   [4:0]                       iSrcTargetID    ;
    input   [InnerIFLengthWidth - 1:0]  iSrcLength      ;
    input                               iSrcValid       ;
    output                              oSrcReady       ;
    
    input   [DataWidth - 1:0]           iSrcWriteData   ;
    input                               iSrcWriteValid  ;
    input                               iSrcWriteLast   ;
    output                              oSrcWriteReady  ;
    
    output  [DataWidth - 1:0]           oDstWriteData   ;
    output                              oDstWriteValid  ;
    output                              oDstWriteLast   ;
    input                               iDstWriteReady  ;
    
    reg                                 rSrcWReady      ;
    reg                                 rDstWValid      ;
    reg                                 rDstWLast       ;
    
    wire                                wFLenQPushSig   ;
    wire                                wFLenQPopSig    ;
    wire                                wIsFLenQFull    ;
    wire                                wIsFLenQEmpty   ;
    wire                                wFLenQDValid    ;
    wire                                wFLenQDReady    ;
    wire    [InnerIFLengthWidth - 1:0]  wFLenLength     ;
    wire    [4:0]                       wFTargetID      ;
    reg     [DataWidth - 1:0]           rOutData        ;
    
    assign wFLenQPushSig    = iSrcValid & oSrcReady     ;
    
    assign oSrcWriteReady   = rSrcWReady    ;
    
    assign oDstWriteData    = rOutData      ;
    assign oDstWriteValid   = rDstWValid    ;
    assign oDstWriteLast    = rDstWLast     ;
    
    assign oSrcReady        = !wIsFLenQFull ;
    
    localparam  State_Idle              = 2'b00;
    localparam  State_ReportCmplt       = 2'b01;
    localparam  State_Forward           = 2'b11;
    reg [1:0]   rDataChCurState ;
    reg [1:0]   rDataChNextState;
    
    always @ (posedge iClock)
        if (iReset)
            rDataChCurState <= State_Idle;
        else
            rDataChCurState <= rDataChNextState;
    
    always @ (*)
        case (rDataChCurState)
        State_Idle:
            if (wFLenQDValid)
            begin
                if (wFTargetID == ThisID)
                    rDataChNextState <= State_ReportCmplt;
                else if (wFLenLength == 0)
                    rDataChNextState <= State_Idle;
                else
                    rDataChNextState <= State_Forward;
            end
            else
                rDataChNextState <= State_Idle;
        State_ReportCmplt:
            rDataChNextState <= (iDstWriteReady)?State_Idle:State_ReportCmplt;
        State_Forward:
            rDataChNextState <= (oDstWriteValid && oDstWriteLast && iDstWriteReady)?State_Idle:State_Forward;
        default:
            rDataChNextState <= State_Idle;
        endcase
    
    assign wFLenQDReady = (rDataChCurState == State_Idle);
    
    SCFIFO_64x64_withCount
    Inst_ForwardedDataQ
    (
        .iClock         (iClock                     ),
        .iReset         (iReset                     ),
        .iPushData      ({iSrcLength, iSrcTargetID} ),
        .iPushEnable    (wFLenQPushSig              ),
        .oIsFull        (wIsFLenQFull               ),
        .oPopData       ({wFLenLength, wFTargetID}  ),
        .iPopEnable     (wFLenQPopSig               ),
        .oIsEmpty       (wIsFLenQEmpty              ),
        .oDataCount     (                           )
    );
    
    AutoFIFOPopControl
    Inst_ForwardedDataQPopControl
    (
        .iClock         (iClock         ),
        .iReset         (iReset         ),
        .oPopSignal     (wFLenQPopSig   ),
        .iEmpty         (wIsFLenQEmpty  ),
        .oValid         (wFLenQDValid   ),
        .iReady         (wFLenQDReady   )
    );
    
    always @ (*)
        case (rDataChCurState)
        State_ReportCmplt:
            rOutData <= 32'hA5000001;
        State_Forward:
            rOutData <= iSrcWriteData;
        default:
            rOutData <= 1'b0;
        endcase
    
    always @ (*)
        case (rDataChCurState)
        State_Forward:
            rSrcWReady <= iDstWriteReady;
        default:
            rSrcWReady <= 1'b0;
        endcase

    always @ (*)
        case (rDataChCurState)
        State_ReportCmplt:
            rDstWValid <= 1'b1;
        State_Forward:
            rDstWValid <= iSrcWriteValid;
        default:
            rDstWValid <= 1'b0;
        endcase

    always @ (*)
        case (rDataChCurState)
        State_ReportCmplt:
            rDstWLast <= 1'b1;
        default:
            rDstWLast <= iSrcWriteLast;
        endcase
    
endmodule
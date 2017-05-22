//////////////////////////////////////////////////////////////////////////////////
// BCHDecoderControlCore for Cosmos OpenSSD
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
// Design Name: BCH decoder output controller core
// Module Name: BCHDecoderOutputControl
// File Name: BCHDecoderOutputControl.v
//
// Version: v1.0.0
//
// Description: BCH decoder output controller core
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module BCHDecoderOutputControl
#
(
    parameter   AddressWidth        = 32    ,
    parameter   DataWidth           = 32    ,
    parameter   InnerIFLengthWidth  = 16    ,
    parameter   ThisID              = 2     ,
    parameter   Multi               = 4     ,
    parameter   MaxErrorCountBits   = 9
)
(
    iClock              ,
    iReset              ,
    oDstSourceID        ,
    oDstTargetID        ,
    oDstOpcode          ,
    oDstAddress         ,
    oDstLength          ,
    oDstCmdValid        ,
    iDstCmdReady        ,
    iCmdSourceID        ,
    iCmdTargetID        ,
    iCmdOpcode          ,
    iCmdType            ,
    iCmdAddress         ,
    iCmdLength          ,
    iCmdValid           ,
    oCmdReady           ,
    iBypassWriteData    ,
    iBypassWriteLast    ,
    iBypassWriteValid   ,
    oBypassWriteReady   ,
    iDecWriteData       ,
    iDecWriteValid      ,
    iDecWriteLast       ,
    oDecWriteReady      ,
    oDstWriteData       ,
    oDstWriteValid      ,
    oDstWriteLast       ,
    iDstWriteReady      ,
    iDecodeFinished     ,
    iDecodeSuccess      ,
    iErrorSum           ,
    iErrorCountOut      ,
    oCSReset            ,
    oDecStandby
);

    input                               iClock              ;
    input                               iReset              ;
    
    output  [4:0]                       oDstTargetID        ;
    output  [4:0]                       oDstSourceID        ;
    output  [5:0]                       oDstOpcode          ;
    output  [AddressWidth - 1:0]        oDstAddress         ;
    output  [InnerIFLengthWidth - 1:0]  oDstLength          ;
    output                              oDstCmdValid        ;
    input                               iDstCmdReady        ;
    
    input   [4:0]                       iCmdSourceID        ;
    input   [4:0]                       iCmdTargetID        ;
    input   [5:0]                       iCmdOpcode          ;
    input   [1:0]                       iCmdType            ;
    input   [AddressWidth - 1:0]        iCmdAddress         ;
    input   [InnerIFLengthWidth - 1:0]  iCmdLength          ;
    input                               iCmdValid           ;
    output                              oCmdReady           ;
    
    input   [DataWidth - 1:0]           iBypassWriteData    ;
    input                               iBypassWriteValid   ;
    input                               iBypassWriteLast    ;
    output                              oBypassWriteReady   ;
    
    input   [DataWidth - 1:0]           iDecWriteData       ;
    input                               iDecWriteValid      ;
    input                               iDecWriteLast       ;
    output                              oDecWriteReady      ;
    
    output  [DataWidth - 1:0]           oDstWriteData       ;
    output                              oDstWriteValid      ;
    output                              oDstWriteLast       ;
    input                               iDstWriteReady      ;
    
    input                               iDecodeFinished     ;
    input                               iDecodeSuccess      ;
    input   [MaxErrorCountBits - 1:0]   iErrorSum           ;
    input   [4*Multi - 1:0]             iErrorCountOut      ;
    output                              oCSReset            ;
    output                              oDecStandby         ;
    
    reg     [2:0]                       rOutMuxSelect       ;
    
    reg     [4:0]                       rCmdSourceID        ;
    reg     [4:0]                       rCmdTargetID        ;
    reg     [5:0]                       rCmdOpcode          ;
    reg     [1:0]                       rCmdType            ;
    reg     [AddressWidth - 1:0]        rCmdAddress         ;
    reg     [InnerIFLengthWidth - 1:0]  rCmdLength          ;
    
    reg     [DataWidth - 1:0]           rBypassWriteData    ;
    reg                                 rBypassWriteValid   ;
    reg                                 rBypassWriteLast    ;
    reg                                 rBypassWriteReady   ;
    wire    [DataWidth - 1:0]           wBypassWriteData    ;
    wire                                wBypassWriteValid   ;
    wire                                wBypassWriteLast    ;
    
    reg     [DataWidth - 1:0]           rDecWriteData       ;
    reg                                 rDecWriteValid      ;
    reg                                 rDecWriteLast       ;
    reg                                 rDecWriteReady      ;
    wire    [DataWidth - 1:0]           wDecWriteData       ;
    wire                                wDecWriteValid      ;
    wire                                wDecWriteLast       ;
    
    reg     [4:0]                       rDstTargetID        ;
    reg     [4:0]                       rDstSourceID        ;
    reg     [5:0]                       rDstOpcode          ;
    reg     [AddressWidth - 1:0]        rDstAddress         ;
    reg     [InnerIFLengthWidth - 1:0]  rDstLength          ;
    reg                                 rDstCmdValid        ;
    
    reg     [DataWidth - 1:0]           rDstWriteData       ;
    reg                                 rDstWriteValid      ;
    reg                                 rDstWriteLast       ;
    
    wire    [DataWidth - 1:0]           wErrorCountRegister ;
    reg     [31:0]                      rPageDecodeSuccess  ;
    reg                                 rSpareDecodeSuccess ;
    reg     [5:0]                       rWorstCaseErrorCount;
    reg     [9:0]                       rTotalErrorCount    ;
    reg     [327:0]                     rPageErrorInfo      ;
    reg     [4*Multi*33 - 1:0]          rChunkErrorCount    ;
    
    reg                                 rCrcCheckBit        ;
    reg                                 rCrcEnable          ;
    wire    [DataWidth - 1:0]           wCrcInData          ;
    wire                                wCrcInDataValid     ;
    wire                                wCrcInDataLast      ;
    wire                                wCrcComplete        ;
    wire                                wCrcError           ;
    
    reg                                 rZeroPadding        ;
    reg     [5:0]                       rCounter            ;
    
    localparam   ChunkIteration         =   31              ;
    localparam   ChunkIterationBits     =   7               ;
    localparam   ErrorInfoSize          =   10              ;
    localparam   PageChunkSize          =   128             ;
    localparam   SpareChunkSize         =   64              ;    
    parameter   DataWidthDiv           = $clog2(DataWidth/8);
    
    reg     [ChunkIterationBits - 1:0]  rCurLoopCount       ;
    reg     [ChunkIterationBits - 1:0]  rGoalLoopCount      ;
    
    localparam   ECCCtrlCmdType_Bypass       =   2'b00           ;
    localparam   ECCCtrlCmdType_PageDecode   =   2'b01           ;
    localparam   ECCCtrlCmdType_SpareDecode  =   2'b10           ;
    localparam   ECCCtrlCmdType_ErrCntReport =   2'b11           ;
    
    localparam  State_Idle                  =   9'b000000001    ;
    localparam  State_BypassCmd             =   9'b000000010    ;
    localparam  State_BypassTrf             =   9'b000000100    ;
    localparam  State_ErrCntCmd             =   9'b000001000    ;
    localparam  State_ErrCntTrf             =   9'b000010000    ;
    localparam  State_DecStandby            =   9'b000100000    ;
    localparam  State_DecTrfCmd             =   9'b001000000    ;
    localparam  State_DecTrf                =   9'b010000000    ;
    localparam  State_DecLoop               =   9'b100000000    ;
    
    reg     [8:0]                      rCurState           ;
    reg     [8:0]                      rNextState          ;
        
    always @ (posedge iClock)
        if (iReset)
            rCurState <= State_Idle ;
        else
            rCurState <= rNextState ;
    
    always @ (*)
        case (rCurState)
        State_Idle:
            if (iCmdValid)
                case (iCmdType)
                ECCCtrlCmdType_PageDecode:
                    rNextState <= State_DecStandby;
                ECCCtrlCmdType_SpareDecode:
                    rNextState <= State_DecStandby;
                ECCCtrlCmdType_ErrCntReport:
                    rNextState <= State_ErrCntCmd;
                default:
                    rNextState <= State_BypassCmd;
                endcase
            else
                rNextState <= State_Idle;
        State_BypassCmd:
            if (iDstCmdReady)
            begin
                if (rCmdLength == 0)
                    rNextState <= State_Idle        ;
                else
                    rNextState <= State_BypassTrf   ;
            end
            else
                rNextState <= State_BypassCmd   ;
        State_BypassTrf:
            rNextState <= (rDstWriteValid && rDstWriteLast && iDstWriteReady) ? State_Idle : State_BypassTrf;
        State_ErrCntCmd:
            rNextState <= (iDstCmdReady) ? State_ErrCntTrf : State_ErrCntCmd;
        State_ErrCntTrf:
            rNextState <= (rDstWriteValid && rDstWriteLast && iDstWriteReady) ? State_Idle : State_ErrCntTrf;
        State_DecStandby:
            rNextState <= (iDecodeFinished) ? State_DecTrfCmd : State_DecStandby;
        State_DecTrfCmd:
            rNextState <= (iDstCmdReady) ? State_DecTrf : State_DecTrfCmd;
        State_DecTrf:
            rNextState <= (rDstWriteValid && rDstWriteLast && iDstWriteReady) ? State_DecLoop : State_DecTrf;
        State_DecLoop:
            rNextState <= (rCurLoopCount == rGoalLoopCount) ? State_Idle : State_DecStandby;
        default:
            rNextState <= State_Idle;
        endcase
    
    always @ (posedge iClock)
        if (iReset)
            rCounter <= 6'b0;
        else
            case (rCurState)
            State_DecTrf:
                if (iDstWriteReady && rDstWriteValid && (rCmdType == ECCCtrlCmdType_SpareDecode))
                    rCounter <= rCounter + 1'b1;
            State_Idle:
                rCounter <= 6'b0;
            endcase
    
    always @ (posedge iClock)
        if (iReset)
            rZeroPadding <= 1'b0;
        else
            case (rCurState)
            State_DecTrf:
                if ((rCounter == 6'b111110) && iDstWriteReady && rDstWriteValid)
                    rZeroPadding <= ~rZeroPadding;
            State_Idle:
                rZeroPadding <= 1'b0;
            endcase
    
    always @ (posedge iClock)
        if (iReset)
            rCurLoopCount <= {(ChunkIterationBits){1'b0}};
        else
            case (rCurState)
            State_DecLoop:
                rCurLoopCount <= rCurLoopCount + 1'b1;
            State_ErrCntTrf:
                rCurLoopCount <= (iDstWriteReady && rDstWriteValid) ? rCurLoopCount + 1'b1 : rCurLoopCount;
            State_Idle:
                rCurLoopCount <= {(ChunkIterationBits){1'b0}};
            endcase
    
    always @ (posedge iClock)
        if (iReset)
            rGoalLoopCount <= {(ChunkIterationBits){1'b0}};
        else
            case (rCurState)
            State_DecStandby:
                if (rCmdType == ECCCtrlCmdType_PageDecode)
                    rGoalLoopCount <= ChunkIteration;
                else
                    rGoalLoopCount <= {(ChunkIterationBits){1'b0}};
            State_ErrCntCmd:
                rGoalLoopCount <= ErrorInfoSize;
            State_Idle:
                rGoalLoopCount <= {(ChunkIterationBits){1'b0}};
            endcase
    
    always @ (posedge iClock)
        if (iReset)
        begin
            rCmdSourceID    <=  5'b0                            ;
            rCmdTargetID    <=  5'b0                            ;
            rCmdOpcode      <=  6'b0                            ;
            rCmdType        <=  2'b0                            ;
            rCmdAddress     <=  {(AddressWidth){1'b0}}          ;
            rCmdLength      <=  {(InnerIFLengthWidth){1'b0}}    ;
        end
        else
            if (iCmdValid && oCmdReady)
            begin
                rCmdSourceID    <=  iCmdSourceID    ;
                rCmdTargetID    <=  iCmdTargetID    ;
                rCmdOpcode      <=  iCmdOpcode      ;
                rCmdType        <=  iCmdType        ;
                rCmdAddress     <=  iCmdAddress     ;
                rCmdLength      <=  iCmdLength      ;
            end    
    
    always @ (posedge iClock)
        if (iReset)
        begin
            rDstSourceID    <=  5'b0                            ;
            rDstTargetID    <=  5'b0                            ;
            rDstOpcode      <=  6'b0                            ;
            rDstAddress     <=  {(AddressWidth){1'b0}}          ;
            rDstLength      <=  {(InnerIFLengthWidth){1'b0}}    ;
        end
        else
            case (rNextState)
            State_BypassCmd:
                if (rCurState == State_Idle)
                begin
                    rDstSourceID    <=  iCmdSourceID                ;
                    rDstTargetID    <=  iCmdTargetID                ;
                    rDstOpcode      <=  iCmdOpcode                  ;
                    rDstAddress     <=  iCmdAddress                 ;
                    rDstLength      <=  iCmdLength                  ;
                end
            State_ErrCntCmd:
                if (rCurState == State_Idle)
                begin
                    rDstSourceID    <=  ThisID                      ;
                    rDstTargetID    <=  5'b0                        ;
                    rDstOpcode      <=  6'b0                        ;
                    rDstAddress     <=  iCmdAddress                 ;
                    rDstLength      <=  ErrorInfoSize+1             ;
                end
            State_DecTrfCmd:
                if (rCurLoopCount == 0)
                begin
                    rDstSourceID    <=  ThisID                      ;
                    rDstTargetID    <=  5'b0                        ;
                    rDstOpcode      <=  rCmdOpcode                  ;
                    rDstAddress     <=  rCmdAddress                 ;
                    if (rCmdType == ECCCtrlCmdType_PageDecode)
                        rDstLength  <=  PageChunkSize               ;
                    else
                        rDstLength  <=  SpareChunkSize              ;
                end
            State_DecLoop:
                if (rCmdType == ECCCtrlCmdType_PageDecode)
                    rDstAddress <= rDstAddress + (PageChunkSize << DataWidthDiv);
                else
                    rDstAddress <= rDstAddress + (SpareChunkSize << DataWidthDiv);
            endcase
    
    always @ (*)
        if ((rCurState == State_BypassCmd) || (rCurState == State_ErrCntCmd) || (rCurState == State_DecTrfCmd))
            rDstCmdValid <= 1'b1;
        else
            rDstCmdValid <= 1'b0;
    
    always @ (posedge iClock)
        if (iReset)
            rCrcCheckBit                <= 1'b1;
        else 
            case (rCurState)
            State_ErrCntTrf:
                if (rNextState == State_Idle)
                    rCrcCheckBit        <= 1'b1;
            State_DecLoop:
                if (wCrcComplete && wCrcError)
                    rCrcCheckBit        <= 1'b0;
            endcase
    
    assign  oDstOpcode      =   rDstOpcode      ;
    assign  oDstTargetID    =   rDstTargetID    ;
    assign  oDstSourceID    =   rDstSourceID    ;
    assign  oDstAddress     =   rDstAddress     ;
    assign  oDstLength      =   rDstLength      ;
    assign  oDstCmdValid    =   rDstCmdValid    ;
    assign  oCSReset        =   (rCmdType == ECCCtrlCmdType_SpareDecode) && (rCurState == State_DecLoop);
    assign  oDecStandby     =   (rCurState == State_DecStandby);
    
    always @ (posedge iClock)
        if (iReset)
            rSpareDecodeSuccess <=  1'b1;
        else
            if (rCmdType == ECCCtrlCmdType_SpareDecode)
                case (rNextState)
                State_DecTrfCmd:
                    if (iDecodeFinished)
                    begin
                        if (iDecodeSuccess)
                            rSpareDecodeSuccess <= 1'b1;
                        else
                            rSpareDecodeSuccess <= 1'b0;
                    end
                endcase
    
    always @ (posedge iClock)
        if (iReset)
            rPageDecodeSuccess <= 32'h0000_0000;
        else
            if (rCmdType == ECCCtrlCmdType_PageDecode)
                case (rNextState)
                State_DecTrfCmd:
                    if (iDecodeFinished)
                    begin
                        if (iDecodeSuccess)
                            rPageDecodeSuccess[rCurLoopCount] <= 1'b1;
                        else
                            rPageDecodeSuccess[rCurLoopCount] <= 1'b0;
                    end
                endcase
                
    always @ (posedge iClock)
        if (iReset)
            rChunkErrorCount <= {(4*Multi*33){1'b0}};
        else
            case (rNextState)
            State_Idle:
                if (rCurState == State_ErrCntTrf)
                    rChunkErrorCount <= {(4*Multi*33){1'b0}};
            State_DecTrfCmd:
                if (iDecodeFinished)
                    rChunkErrorCount[4*Multi - 1:0] <= iErrorCountOut;
            State_DecLoop:
                if (rCmdType == ECCCtrlCmdType_PageDecode)
                    rChunkErrorCount <= rChunkErrorCount << 4*Multi;
            endcase
    
    always @ (posedge iClock)
        if (iReset)
            rWorstCaseErrorCount                <= 6'b0;
        else
            case (rNextState)
            State_Idle:
                if (rCurState == State_ErrCntTrf)
                    rWorstCaseErrorCount <= 6'b0;
            State_DecTrfCmd:
                if (iDecodeFinished && iDecodeSuccess && (iErrorSum > rWorstCaseErrorCount))
                    rWorstCaseErrorCount <= iErrorSum;
            endcase
    always @ (posedge iClock)
        if (iReset)
            rTotalErrorCount                <= 10'b0;
        else
            case (rNextState)
            State_Idle:
                if (rCurState == State_ErrCntTrf)
                    rTotalErrorCount <= 10'b0;
            State_DecTrfCmd:
                if (iDecodeFinished && iDecodeSuccess)
                    rTotalErrorCount <= rTotalErrorCount + iErrorSum;
            endcase
    always @ (posedge iClock)
        if (iReset)
            rPageErrorInfo                  <= {(328){1'b0}};
        else
            case (rCurState)
            State_ErrCntCmd: 
                begin
                    rPageErrorInfo[324]     <= rCrcCheckBit             ;
                    rPageErrorInfo[320]     <= rSpareDecodeSuccess      ;
                    rPageErrorInfo[317:312] <= rWorstCaseErrorCount     ;
                    rPageErrorInfo[305:296] <= rTotalErrorCount         ;
                    rPageErrorInfo[295:264] <= rPageDecodeSuccess       ;
                    rPageErrorInfo[263:0]   <= rChunkErrorCount         ;
                end
            State_ErrCntTrf:
                if (rDstWriteValid && iDstWriteReady)
                    rPageErrorInfo          <= rPageErrorInfo << DataWidth;
            endcase
    
    assign wErrorCountRegister[DataWidth - 1:0] = rPageErrorInfo[327:296];
    
    assign  wErrCntWriteValid   =   (rCurState == State_ErrCntTrf);
    assign  wErrCntWriteLast    =   (rCurState == State_ErrCntTrf) && (rCurLoopCount == rGoalLoopCount);       
    assign  wCrcInData          =   rDecWriteData   ;
    assign  wCrcInDataValid     =   rDecWriteValid && iDstWriteReady ;
    
    CRC_Checker
    #
    (
        .DATA_WIDTH(DataWidth),
        .HASH_LENGTH(64),
        .INPUT_COUNT_BITS(13),
        .INPUT_COUNT(4160)
    )
    Inst_CrcChencker
    (
        .i_clk              (iClock             ),
        .i_RESET            (iReset             ),
        .i_execute_crc_chk  (1'b1               ),
        .i_message_valid    (wCrcInDataValid    ),
        .i_message          (wCrcInData         ),
        .o_crc_chk_start    (                   ),
        .o_last_message     (wCrcInDataLast     ),
        .o_crc_chk_complete (wCrcComplete       ),
        .o_parity_chk       (wCrcError          )
    );
    
    always @ (posedge iClock)
        if (iReset)
            rOutMuxSelect   <=  3'b000  ;
        else
            case (rNextState)
            State_BypassTrf:
                rOutMuxSelect   <= 3'b001;
            State_ErrCntTrf:
                rOutMuxSelect   <= 3'b100;
            State_DecTrf:
                rOutMuxSelect   <= 3'b010;
            default:
                rOutMuxSelect   <= 3'b000;
            endcase
    
    assign  wBypassWriteData    = rBypassWriteData  ;
    assign  wBypassWriteLast    = rBypassWriteLast  ;
    assign  wBypassWriteValid   = rBypassWriteValid ;
    assign  wDecWriteData       = rDecWriteData     ;
    assign  wDecWriteLast       = rDecWriteLast     ;
    assign  wDecWriteValid      = rDecWriteValid    ;
    
    always @ (*)
        case (rOutMuxSelect)
        3'b001:
        begin
            rDstWriteData   <=  wBypassWriteData    ;
            rDstWriteLast   <=  wBypassWriteLast    ;
            rDstWriteValid  <=  wBypassWriteValid   ;
        end
        3'b010:
        if (rCmdType == ECCCtrlCmdType_SpareDecode)
        begin
            rDstWriteData   <=  wDecWriteData       ;
            rDstWriteLast   <=  rZeroPadding        ;
            rDstWriteValid  <=  wDecWriteValid      ;
        end
        else
        begin
            rDstWriteData   <=  wDecWriteData       ;
            rDstWriteLast   <=  wDecWriteLast       ;
            rDstWriteValid  <=  wDecWriteValid      ;
        end
        3'b100:
        begin
            rDstWriteData   <=  wErrorCountRegister ;
            rDstWriteLast   <=  wErrCntWriteLast    ;
            rDstWriteValid  <=  wErrCntWriteValid   ;
        end
        default:
        begin
            rDstWriteData   <=  {(DataWidth){1'b0}} ;
            rDstWriteLast   <=  1'b0                ;
            rDstWriteValid  <=  1'b0                ;
        end
        endcase
            
    always @ (*)
        case (rCurState)
        State_BypassTrf:
            begin
                rBypassWriteData    <=  iBypassWriteData    ;    
                rBypassWriteLast    <=  iBypassWriteLast    ;
                rBypassWriteValid   <=  iBypassWriteValid   ;
            end
        default:
            begin
                rBypassWriteData    <=  {(DataWidth){1'b0}} ;    
                rBypassWriteLast    <=  1'b0                ;
                rBypassWriteValid   <=  1'b0                ;
            end
        endcase
    
    always @ (*)
        case (rCurState)
        State_DecTrf:
            begin
                rDecWriteData   <=  iDecWriteData       ;
                rDecWriteLast   <=  iDecWriteLast       ;
                rDecWriteValid  <=  iDecWriteValid      ;
            end
        default:
            begin
                rDecWriteData   <=  {(DataWidth){1'b0}} ;
                rDecWriteLast   <=  1'b0                ;
                rDecWriteValid  <=  1'b0                ;
            end
        endcase
            
    always @ (*)
        case (rCurState)
        State_BypassTrf:
            rBypassWriteReady <= iDstWriteReady;
        default:
            rBypassWriteReady <= 1'b0;
        endcase
        
    always @ (*)
        case (rCurState)
        State_DecTrf:
            rDecWriteReady <= iDstWriteReady;
        default:
            rDecWriteReady <= 1'b0;
        endcase
    
    assign  oCmdReady           =   (rCurState == State_Idle)   ;
    assign  oBypassWriteReady   =   rBypassWriteReady           ;
    assign  oDecWriteReady      =   rDecWriteReady              ;
    assign  oDstWriteData       =   rDstWriteData               ;
    assign  oDstWriteValid      =   rDstWriteValid              ;
    assign  oDstWriteLast       =   rDstWriteLast               ;
            
endmodule
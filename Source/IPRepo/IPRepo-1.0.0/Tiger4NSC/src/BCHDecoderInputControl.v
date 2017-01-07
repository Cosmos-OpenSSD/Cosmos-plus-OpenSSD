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
// Design Name: BCH decoder input controller core
// Module Name: BCHDecoderInputControl
// File Name: BCHDecoderInputControl.v
//
// Version: v1.0.0
//
// Description: BCH decoder input controller core
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module BCHDecoderInputControl
#
(
    parameter   AddressWidth        = 32    ,
    parameter   DataWidth           = 32    ,
    parameter   InnerIFLengthWidth  = 16    ,
    parameter   ThisID              = 2
)
(
    iClock              ,
    iReset              ,
    oDstSourceID        ,
    oDstTargetID        ,
    oDstOpcode          ,
    oDstCmdType         ,
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
    iSrcWriteData       ,
    iSrcWriteValid      ,
    iSrcWriteLast       ,
    oSrcWriteReady      ,
    oBypassWriteData    ,
    oBypassWriteLast    ,
    oBypassWriteValid   ,
    iBypassWriteReady   ,
    oDecWriteData       ,
    oDecWriteValid      ,
    iDecWriteReady      ,
    iDecInDataLast      ,
    iDecAvailable       
    
);

    input                               iClock              ;
    input                               iReset              ;
    
    output  [4:0]                       oDstTargetID        ;
    output  [4:0]                       oDstSourceID        ;
    output  [5:0]                       oDstOpcode          ;
    output  [1:0]                       oDstCmdType         ;
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
    
    input   [DataWidth - 1:0]           iSrcWriteData       ;
    input                               iSrcWriteValid      ;
    input                               iSrcWriteLast       ;
    output                              oSrcWriteReady      ;
    
    output  [DataWidth - 1:0]           oBypassWriteData    ;
    output                              oBypassWriteValid   ;
    output                              oBypassWriteLast    ;
    input                               iBypassWriteReady   ;
    
    output  [DataWidth - 1:0]           oDecWriteData       ;
    output                              oDecWriteValid      ;
    input                               iDecWriteReady      ;
    input                               iDecInDataLast      ;
    input                               iDecAvailable       ;
    
    // Command Register /////////////////////////////////////
    reg     [4:0]                       rSourceID           ;
    reg     [4:0]                       rTargetID           ;
    reg     [5:0]                       rOpcode             ;
    reg     [1:0]                       rCmdType            ;
    reg     [AddressWidth - 1:0]        rCmdAddress         ;
    reg     [InnerIFLengthWidth - 1:0]  rCmdLength          ;
    
    // Output Command ///////////////////////////////////////
    reg                                 rCmdValid        ;
    
    // Input Register ///////////////////////////////////////
    reg                                 rSrcWriteReady      ;    
    
    reg     [1:0]                       rIndeMuxSelect      ;
    
    reg     [DataWidth - 1:0]           rInBypassWriteData  ;
    reg                                 rInBypassWriteValid ;
    reg                                 rInBypassWriteLast  ;
        
    reg     [DataWidth - 1:0]           rInDecWriteData     ;
    reg                                 rInDecWriteValid    ;
    reg                                 rInDecWriteLast     ;
        
    // Parameters ///////////////////////////////////////////////
    parameter                 DataWidthDiv = $clog2(DataWidth/8);
    parameter                           PageChunkSize       =256;
    parameter                           SpareChunkSize      = 64;
    parameter                           ErrorInfoSize       = 10;
    parameter                           ChunkIteration      = 31; // 32 - 1
    parameter                           ChunkIterationBits  =  7;
    parameter                           MaxErrorCountBits   =  9;

    parameter   ECCCtrlCmdType_Bypass       = 2'b00             ;
    parameter   ECCCtrlCmdType_PageDecode   = 2'b01             ;
    parameter   ECCCtrlCmdType_SpareDecode  = 2'b10             ;
    parameter   ECCCtrlCmdType_ErrcntReport = 2'b11             ;
    
    localparam  State_Idle                  = 11'b00000000001   ;
    localparam  State_BypassCmd             = 11'b00000000010   ;
    localparam  State_BypassTrf             = 11'b00000000100   ;
    localparam  State_ErrcntCmd             = 11'b00000001000   ;
    localparam  State_PageDecCmd            = 11'b00000010000   ;
    localparam  State_PageDecStandby        = 11'b00000100000   ;
    localparam  State_PageDecDataIn         = 11'b00001000000   ;
    localparam  State_PageDecLoop           = 11'b00010000000   ;
    localparam  State_SpareDecStandby       = 11'b00100000000   ;
    localparam  State_SpareDecDataIn        = 11'b01000000000   ;
    localparam  State_SpareDecCmd           = 11'b10000000000   ;
    
    
    // State Register ////////////////////////////////////////////
    reg     [10:0]                          rCurState           ;
    reg     [10:0]                          rNextState          ;
    
    reg     [ChunkIterationBits - 1:0]      rCurLoopCount       ;
    reg     [ChunkIterationBits - 1:0]      rGoalLoopCount      ;
    
    reg                                     rZeroPadding        ;
    reg     [5:0]                           rCounter            ;
    
    assign  oBypassWriteData        =   rInBypassWriteData          ;
    assign  oBypassWriteLast        =   rInBypassWriteLast          ;
    assign  oBypassWriteValid       =   rInBypassWriteValid         ;
    
    assign  oDecWriteData           =   rInDecWriteData             ;
    assign  oDecWriteValid          =   rInDecWriteValid            ;
    
    assign  oSrcWriteReady          =   rSrcWriteReady              ;
    
    assign  oDstSourceID            =   rSourceID                   ;
    assign  oDstTargetID            =   rTargetID                   ;
    assign  oDstOpcode              =   rOpcode                     ;
    assign  oDstCmdType             =   rCmdType                    ;
    assign  oDstAddress             =   rCmdAddress                 ;
    assign  oDstLength              =   rCmdLength                  ;
    assign  oDstCmdValid            =   rCmdValid                   ;
    
    assign  oCmdReady               =   (rCurState == State_Idle)   ;
    
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
                    rNextState <= State_PageDecCmd      ;
                ECCCtrlCmdType_SpareDecode:
                    rNextState <= State_SpareDecStandby ;
                ECCCtrlCmdType_ErrcntReport:
                    rNextState <= State_ErrcntCmd       ;
                default:
                    rNextState <= State_BypassCmd       ;
                endcase
            else
                rNextState <= State_Idle    ;
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
            rNextState <= (rInBypassWriteValid && rInBypassWriteLast && iBypassWriteReady) ? State_Idle : State_BypassTrf    ;
        State_ErrcntCmd:
            rNextState <= (iDstCmdReady) ? State_Idle : State_ErrcntCmd    ;
        State_PageDecCmd:
            rNextState <= (iDstCmdReady) ? State_PageDecStandby : State_PageDecCmd  ;
        State_PageDecStandby:
            rNextState <= (iDecAvailable) ? State_PageDecDataIn : State_PageDecStandby    ;
        State_PageDecDataIn:
            rNextState <= (iDecInDataLast) ? State_PageDecLoop : State_PageDecDataIn   ;
        State_PageDecLoop:
            rNextState <= (rCurLoopCount == rGoalLoopCount) ? State_Idle : State_PageDecStandby  ;
        State_SpareDecStandby:
            rNextState <= (iDecAvailable) ? State_SpareDecDataIn : State_SpareDecStandby ;
        State_SpareDecDataIn:
            rNextState <= (iDecInDataLast) ? State_SpareDecCmd : State_SpareDecDataIn  ;
        State_SpareDecCmd:
            rNextState <= (iDstCmdReady) ? State_Idle : State_SpareDecCmd    ;
        default:
            rNextState <= State_Idle    ;
        endcase
    
    // command Register
    always @ (posedge iClock)
        if (iReset)
        begin
            rSourceID   <=  5'b0                        ;
            rTargetID   <=  5'b0                        ;
            rOpcode     <=  6'b0                        ;
            rCmdType    <=  2'b0                        ;
            rCmdAddress <=  {(AddressWidth){1'b0}}      ;
            rCmdLength  <=  {(InnerIFLengthWidth){1'b0}};
        end
        else
            if (iCmdValid && oCmdReady)
            begin
                rSourceID   <=  iCmdSourceID            ;
                rTargetID   <=  iCmdTargetID            ;
                rOpcode     <=  iCmdOpcode              ;
                rCmdType    <=  iCmdType                ;
                rCmdAddress <=  iCmdAddress             ;
                rCmdLength  <=  iCmdLength              ;
            end
    always @ (posedge iClock)
        if (iReset)
            rCounter <= 6'b0;
        else
            case (rCurState)
            State_SpareDecDataIn:
                if (iDecWriteReady && rInDecWriteValid)
                    rCounter <= rCounter + 1'b1;
            State_Idle:
                rCounter <= 6'b0;
            endcase
    
    always @ (posedge iClock)
        if (iReset)
            rZeroPadding <= 1'b0;
        else
            case (rCurState)
            State_SpareDecDataIn:
                if ((rCounter == 6'b111111) && iDecWriteReady && rInDecWriteValid)
                    rZeroPadding <= ~rZeroPadding;
            State_Idle:
                rZeroPadding <= 1'b0;
            endcase
        
    
    always @ (posedge iClock)
        if (iReset)
            rCurLoopCount <= {(ChunkIterationBits){1'b0}};
        else
            case (rCurState)
            State_Idle:
                rCurLoopCount <= {(ChunkIterationBits){1'b0}};
            State_PageDecLoop:
                rCurLoopCount <= rCurLoopCount + 1'b1;
            endcase
    
    always @ (posedge iClock)
        if (iReset)
            rGoalLoopCount <= {(ChunkIterationBits){1'b0}};
        else
            case (rCurState)
            State_PageDecCmd:
                rGoalLoopCount <= ChunkIteration;
            State_SpareDecStandby:
                rGoalLoopCount <= {(ChunkIterationBits){1'b0}};
            endcase
                
    always @ (*)
        if ((rCurState == State_BypassCmd) || (rCurState == State_ErrcntCmd) || (rCurState == State_SpareDecCmd) || (rCurState == State_PageDecCmd))
            rCmdValid <= 1'b1;
        else
            rCmdValid <= 1'b0;
            
    // IndeMux Select Register
    always @ (posedge iClock)
        if (iReset)
            rIndeMuxSelect  <=  2'b00       ;
        else
            case (rNextState)
            State_BypassTrf:
                rIndeMuxSelect  <=  2'b01   ;
            State_PageDecDataIn:
                rIndeMuxSelect  <=  2'b10   ;
            State_SpareDecDataIn:
                rIndeMuxSelect  <=  2'b10   ;
            default:
                rIndeMuxSelect  <=  2'b00   ;
            endcase
    
    // Bypass Input Register
    always @ (*)
        case (rIndeMuxSelect)
        2'b01: // Bypass
            begin
                rInBypassWriteData  <=  iSrcWriteData       ;
                rInBypassWriteLast  <=  iSrcWriteLast       ;
                rInBypassWriteValid <=  iSrcWriteValid      ;
            end
        default:
            begin
                rInBypassWriteData  <=  {(DataWidth){1'b0}} ;
                rInBypassWriteLast  <=  1'b0                ;
                rInBypassWriteValid <=  1'b0                ;
            end
        endcase
    // Decode Input Register
    always @ (*)
        case (rIndeMuxSelect)
        2'b10: // Page, Spare
            if (rCmdType == ECCCtrlCmdType_PageDecode)
            begin
                rInDecWriteData     <=  iSrcWriteData       ;
                rInDecWriteLast     <=  iSrcWriteLast       ;
                rInDecWriteValid    <=  iSrcWriteValid      ;
            end
            else
                if (rZeroPadding)
                begin
                    rInDecWriteData     <=  {(DataWidth){1'b0}} ;
                    rInDecWriteLast     <=  iSrcWriteLast       ;
                    rInDecWriteValid    <=  iSrcWriteValid      ;
                end
                else
                begin
                    rInDecWriteData     <=  iSrcWriteData       ;
                    rInDecWriteLast     <=  iSrcWriteLast       ;
                    rInDecWriteValid    <=  iSrcWriteValid      ;
                end
        default:
            begin
                rInDecWriteData     <=  {(DataWidth){1'b0}} ;
                rInDecWriteLast     <=  1'b0                ;
                rInDecWriteValid    <=  1'b0                ;
            end
        endcase
        
    always @ (*)
        case (rIndeMuxSelect)
        2'b01:  // Bypass
            rSrcWriteReady          <=  iBypassWriteReady   ;
        2'b10:  // Decode
            if (rCmdType == ECCCtrlCmdType_PageDecode)
                rSrcWriteReady          <=  iDecWriteReady  ;
            else
                if (rZeroPadding)
                    rSrcWriteReady      <=  1'b0            ;
                else
                    rSrcWriteReady      <=  iDecWriteReady  ;
        default:
            rSrcWriteReady          <=  1'b0                ;
        endcase
    

endmodule
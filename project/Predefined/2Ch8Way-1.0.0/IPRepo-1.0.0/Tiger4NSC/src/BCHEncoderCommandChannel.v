//////////////////////////////////////////////////////////////////////////////////
// BCHEncoderCommandChannel for Cosmos OpenSSD
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
// Design Name: BCH encoder controller command channel
// Module Name: BCHEncoderCommandChannel
// File Name: BCHEncoderCommandChannel.v
//
// Version: v1.0.0
//
// Description: BCH encoder controller command channel
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module BCHEncoderCommandChannel
#
(
    parameter AddressWidth          = 32    ,
    parameter DataWidth             = 32    ,
    parameter InnerIFLengthWidth    = 16    ,
    parameter ThisID                = 2
)
(
    iClock          ,
    iReset          ,
    iSrcOpcode      ,
    iSrcTargetID    ,
    iSrcSourceID    ,
    iSrcAddress     ,
    iSrcLength      ,
    iSrcCmdValid    ,
    oSrcCmdReady    ,
    oOpQPushSignal  ,
    oOpQPushData    ,
    oDstOpcode      ,
    oDstTargetID    ,
    oDstSourceID    ,
    oDstAddress     ,
    oDstLength      ,
    oDstCmdValid    ,
    iDstCmdReady    ,
    iSrcValidCond
);

    input                               iClock          ;
    input                               iReset          ;
    
    // Master side
    input   [5:0]                       iSrcOpcode      ;
    input   [4:0]                       iSrcTargetID    ;
    input   [4:0]                       iSrcSourceID    ;
    input   [AddressWidth - 1:0]        iSrcAddress     ;
    input   [InnerIFLengthWidth - 1:0]  iSrcLength      ;
    input                               iSrcCmdValid    ;
    output                              oSrcCmdReady    ;
    
    output                              oOpQPushSignal  ;
    output  [InnerIFLengthWidth+2-1:0]  oOpQPushData    ;
    
    // Slave side
    output  [5:0]                       oDstOpcode      ;
    output  [4:0]                       oDstTargetID    ;
    output  [4:0]                       oDstSourceID    ;
    output  [AddressWidth - 1:0]        oDstAddress     ;
    output  [InnerIFLengthWidth - 1:0]  oDstLength      ;
    output                              oDstCmdValid    ;
    input                               iDstCmdReady    ;
    
    input                               iSrcValidCond   ;
    
    reg     [5:0]                       rOpcode         ;
    reg     [4:0]                       rTargetID       ;
    reg     [4:0]                       rSourceID       ;
    reg     [AddressWidth - 1:0]        rAddress        ;
    reg     [InnerIFLengthWidth - 1:0]  rLength         ;
    reg                                 rDstCValid      ;
    
    reg     [1:0]                       rOpType         ;
    
    assign oDstOpcode       = rOpcode       ;
    assign oDstTargetID     = rTargetID     ;
    assign oDstSourceID     = rSourceID     ;
    assign oDstAddress      = rAddress      ;
    assign oDstLength       = rLength       ;
    assign oDstCmdValid     = rDstCValid    ;
    
    parameter   DispatchCmd_PageReadFromRAM     = 6'b000001 ;
    parameter   DispatchCmd_SpareReadFromRAM    = 6'b000010 ;
    
    localparam  PageSize    =   4096;
    localparam  SpareSize   =   64;
    
    localparam  State_Idle              = 2'b00;
    localparam  State_EncodeReq         = 2'b01;
    localparam  State_ForwardReq        = 2'b11;
    reg [1:0]   rCmdChCurState  ;
    reg [1:0]   rCmdChNextState ;
    
    always @ (posedge iClock)
        if (iReset)
            rCmdChCurState <= State_Idle;
        else
            rCmdChCurState <= rCmdChNextState;
    
    always @ (*)
        case (rCmdChCurState)
        State_Idle:
            if (iSrcCmdValid && iSrcValidCond)
            begin
                if (
                (iSrcTargetID == 0) &&
                ((iSrcOpcode == DispatchCmd_PageReadFromRAM) || (iSrcOpcode == DispatchCmd_SpareReadFromRAM))
                )
                    rCmdChNextState <= State_EncodeReq;
                else
                    rCmdChNextState <= State_ForwardReq;
            end
            else
                rCmdChNextState <= State_Idle;
        State_EncodeReq:
            rCmdChNextState <= (iDstCmdReady)?State_Idle:State_EncodeReq;
        State_ForwardReq:
            rCmdChNextState <= (iDstCmdReady)?State_Idle:State_ForwardReq;
        default:
            rCmdChNextState <= State_Idle;
        endcase
    
    assign oSrcCmdReady     = (rCmdChCurState == State_Idle) && (iSrcValidCond);
    
    assign oOpQPushData     = {rLength, rOpType};
    assign oOpQPushSignal   = oDstCmdValid && iDstCmdReady && (rLength != 0);
    
    always @ (posedge iClock)
        if (iReset)
        begin
            rOpcode     <= 6'b0;
            rTargetID   <= 5'b0;
            rSourceID   <= 5'b0;
            rAddress    <= {(AddressWidth){1'b0}};
            rLength     <= {(InnerIFLengthWidth){1'b0}};
            rOpType     <= 2'b0;
        end
        else
        begin
            if (rCmdChCurState == State_Idle && iSrcCmdValid)
            begin
                rOpcode     <= iSrcOpcode   ;
                rTargetID   <= iSrcTargetID ;
                rSourceID   <= iSrcSourceID ;
                rAddress    <= iSrcAddress  ;
                rLength     <= iSrcLength   ;
                rOpType     <= 2'b0         ;
                
                if (iSrcTargetID == 0)
                begin
                    if (iSrcOpcode == DispatchCmd_PageReadFromRAM)
                    begin
                        rOpcode     <= iSrcOpcode   ;
                        rTargetID   <= 5'b0         ;
                        rSourceID   <= ThisID       ;
                        rAddress    <= iSrcAddress  ;
                        rLength     <= PageSize     ;
                        rOpType     <= 2'b01        ;
                    end
                    else if (iSrcOpcode == DispatchCmd_SpareReadFromRAM)
                    begin
                        rOpcode     <= iSrcOpcode   ;
                        rTargetID   <= 5'b0         ;
                        rSourceID   <= ThisID       ;
                        rAddress    <= iSrcAddress  ;
                        rLength     <= SpareSize    ;
                        rOpType     <= 2'b10        ;
                    end
                end
            end
        end
    
    always @ (*)
        case (rCmdChCurState)
        State_EncodeReq:
            rDstCValid <= 1'b1;
        State_ForwardReq:
            rDstCValid <= 1'b1;
        default:
            rDstCValid <= 1'b0;
        endcase

endmodule
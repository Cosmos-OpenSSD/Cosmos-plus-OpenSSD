//////////////////////////////////////////////////////////////////////////////////
// AXI4CommandDivider for Cosmos OpenSSD
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
// Design Name: AXI4 command divider
// Module Name: AXI4CommandDivider
// File Name: AXI4CommandDivider.v
//
// Version: v1.0.0
//
// Description: Divides a long burst into multiple smaller bursts
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module AXI4CommandDivider
#
(
    parameter AddressWidth          = 32    ,
    parameter DataWidth             = 32    ,
    parameter InnerIFLengthWidth    = 16    ,
    parameter MaxDivider            = 16
)
(
    ACLK        ,
    ARESETN     ,
    SRCADDR     ,
    SRCLEN      ,
    SRCVALID    ,
    SRCREADY    ,
    SRCREADYCOND,
    DIVADDR     ,
    DIVLEN      ,
    DIVVALID    ,
    DIVREADY    ,
    DIVFLUSH
);
    input                               ACLK        ;
    input                               ARESETN     ;
    input   [AddressWidth - 1:0]        SRCADDR     ;
    input   [InnerIFLengthWidth - 1:0]  SRCLEN      ;
    input                               SRCVALID    ;
    output                              SRCREADY    ;
    input                               SRCREADYCOND;
    output  [AddressWidth - 1:0]        DIVADDR     ;
    output  [7:0]                       DIVLEN      ;
    output                              DIVVALID    ;
    input                               DIVREADY    ;
    output                              DIVFLUSH    ;
    
    reg     [7:0]                       rDivLen     ;
    reg                                 rDivValid   ;
    reg                                 rDivFlush   ;
    
    localparam  State_Idle      = 2'b00 ;
    localparam  State_Dividing  = 2'b01 ;
    localparam  State_Request   = 2'b11 ;
    reg [1:0]   rCurState               ;
    reg [1:0]   rNextState              ;
    
    reg [AddressWidth - 1:0]    rAddress            ;
    reg [InnerIFLengthWidth:0]  rLength             ;
    reg [$clog2(MaxDivider):0]  rDivider            ;
    
    wire                        wDivisionNotNeeded  ;
    wire                        wDivisionNeeded     ;
    
    always @ (posedge ACLK)
        if (!ARESETN)
            rCurState <= State_Idle;
        else
            rCurState <= rNextState;
    
    assign wDivisionNotNeeded   = (rLength >= rDivider) ;
    assign wDivisionNeeded      = (rLength < rDivider)  ;
    
    always @ (*)
        case (rCurState)
        State_Idle:
            if (SRCVALID && (SRCLEN != {(InnerIFLengthWidth){1'b0}}))
                rNextState <= State_Dividing;
            else
                rNextState <= State_Idle;
        State_Dividing:
            rNextState <= (wDivisionNotNeeded)?State_Request:State_Dividing;
        State_Request:
            if (DIVREADY)
            begin
                if (rLength == 0)
                    rNextState <= State_Idle;
                else
                    rNextState <= State_Dividing;
            end
            else
                rNextState <= State_Request;
        default:
            rNextState <= State_Idle;
        endcase
    
    assign SRCREADY = (rCurState == State_Idle) && SRCREADYCOND;
    assign DIVADDR  = rAddress;
    assign DIVLEN   = rDivLen;
    
    always @ (posedge ACLK)
        if (!ARESETN)
            rAddress <= 8'b0;
        else
            case (rCurState)
            State_Idle:
                if (SRCVALID)
                    rAddress <= SRCADDR;
            State_Request:
                if (DIVREADY)
                    rAddress <= rAddress + (rDivider << ($clog2(DataWidth/8 - 1)));
            endcase
    
    always @ (posedge ACLK)
        if (!ARESETN)
            rLength <= 8'b0;
        else
            case (rCurState)
            State_Idle:
                if (SRCVALID)
                    rLength <= SRCLEN;
            State_Dividing:
                if (wDivisionNotNeeded)
                    rLength <= rLength - rDivider;
            endcase

    always @ (posedge ACLK)
        case (rCurState)
        State_Idle:
            rDivider <= MaxDivider;
        State_Dividing:
            if (wDivisionNeeded)
                rDivider <= rDivider >> 1'b1;
        endcase
    
    always @ (posedge ACLK)
        if (!ARESETN)
            rDivLen <= 8'b0;
        else
            case (rCurState)
            State_Dividing:
                if (wDivisionNotNeeded)
                    rDivLen <= rDivider - 1'b1;
            endcase
    
    assign DIVVALID = rDivValid;
    
    always @ (posedge ACLK)
        if (!ARESETN)
            rDivValid <= 1'b0;
        else
            if (!rDivValid && (rCurState == State_Dividing) && wDivisionNotNeeded)
                rDivValid <= 1'b1;
            else if (rDivValid && DIVREADY)
                rDivValid <= 1'b0;
    
    always @ (*)
        case (rCurState)
        State_Idle:
            rDivFlush <= 1'b1;
        State_Request:
            if (!DIVREADY) // WCmdQ is Full
                rDivFlush <= 1'b1;
            else
                rDivFlush <= 1'b0;
        default:
            rDivFlush <= 1'b0;
        endcase
    assign DIVFLUSH = rDivFlush;
    
endmodule

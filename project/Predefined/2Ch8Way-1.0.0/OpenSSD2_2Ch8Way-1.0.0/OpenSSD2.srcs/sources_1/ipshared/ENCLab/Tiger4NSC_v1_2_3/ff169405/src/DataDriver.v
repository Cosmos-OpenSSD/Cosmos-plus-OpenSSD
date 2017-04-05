//////////////////////////////////////////////////////////////////////////////////
// DataDriver for Cosmos OpenSSD
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
// Design Name: Data driver
// Module Name: DataDriver
// File Name: DataDriver.v
//
// Version: v1.0.0
//
// Description: Drives a AXI-like data channel
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module DataDriver
#
(
    parameter DataWidth         = 32    ,
    parameter LengthWidth       = 16
)
(
    CLK         ,
    RESET       ,
    SRCLEN      ,
    SRCVALID    ,
    SRCREADY    ,
    DATA        ,
    DVALID      ,
    DREADY      ,
    XDATA       ,
    XDVALID     ,
    XDREADY     ,
    XDLAST
);
    input                           CLK         ;
    input                           RESET       ;
    input   [LengthWidth - 1:0]     SRCLEN      ;
    input                           SRCVALID    ;
    output                          SRCREADY    ;
    input   [DataWidth - 1:0]       DATA        ;
    input                           DVALID      ;
    output                          DREADY      ;
    output  [DataWidth - 1:0]       XDATA       ;
    output                          XDVALID     ;
    input                           XDREADY     ;
    output                          XDLAST      ;

    localparam  State_Idle          = 1'b0      ;
    localparam  State_Requesting    = 1'b1      ;
    reg         rCurState                       ;
    reg         rNextState                      ;
    
    reg [LengthWidth - 1:0]         rLength     ;
    reg [LengthWidth - 1:0]         rCount      ;                      
    
    always @ (posedge CLK)
        if (RESET)
            rCurState <= State_Idle;
        else
            rCurState <= rNextState;

    always @ (*)
        case (rCurState)
        State_Idle:
            if (SRCVALID && (SRCLEN != 0))
                rNextState <= State_Requesting;
            else
                rNextState <= State_Idle;
        State_Requesting:
            rNextState <= (rCount == rLength && DVALID && XDREADY)?State_Idle:State_Requesting;
        endcase
    
    assign SRCREADY = (rCurState == State_Idle);
    
    always @ (posedge CLK)
        if (RESET)
            rLength <= {(LengthWidth){1'b0}};
        else
            case (rCurState)
            State_Idle:
                if (SRCVALID)
                    rLength <= SRCLEN - 1'b1;
            endcase
    
    always @ (posedge CLK)
        if (RESET)
            rCount <= {(LengthWidth){1'b0}};
        else
            case (rCurState)
            State_Idle:
                if (SRCVALID)
                    rCount <= {(LengthWidth){1'b0}};
            State_Requesting:
                if (DVALID && XDREADY)
                    rCount <= rCount + 1'b1;
            endcase
    
    assign XDATA   = DATA;
    assign XDVALID = (rCurState == State_Requesting) && DVALID  ;
    assign DREADY  = (rCurState == State_Requesting) && XDREADY ;
    assign XDLAST  = (rCount == rLength);
    
endmodule

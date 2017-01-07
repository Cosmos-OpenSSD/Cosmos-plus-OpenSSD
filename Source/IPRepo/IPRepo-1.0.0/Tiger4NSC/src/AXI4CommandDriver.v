//////////////////////////////////////////////////////////////////////////////////
// AXI4CommandDriver for Cosmos OpenSSD
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
// Design Name: AXI4 command driver
// Module Name: AXI4CommandDriver
// File Name: AXI4CommandDriver.v
//
// Version: v1.0.0
//
// Description: Drives AXI4 compliant address (command) channel at a signal
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module AXI4CommandDriver
#
(
    parameter AddressWidth      = 32    ,
    parameter DataWidth         = 32
)
(
    ACLK        ,
    ARESETN     ,
    AXADDR      ,
    AXLEN       ,
    AXSIZE      ,
    AXBURST     ,
    AXCACHE     ,
    AXPROT      ,
    AXVALID     ,
    AXREADY     ,
    SRCADDR     ,
    SRCLEN      ,
    SRCVALID    ,
    SRCREADY    ,
    SRCFLUSH    ,
    SRCREADYCOND
);
    input                           ACLK        ;
    input                           ARESETN     ;
    output  [AddressWidth - 1:0]    AXADDR      ;
    output  [7:0]                   AXLEN       ;
    output  [2:0]                   AXSIZE      ;
    output  [1:0]                   AXBURST     ;
    output  [3:0]                   AXCACHE     ;
    output  [2:0]                   AXPROT      ;
    output                          AXVALID     ;
    input                           AXREADY     ;
    input   [AddressWidth - 1:0]    SRCADDR     ;
    input   [7:0]                   SRCLEN      ;
    input                           SRCVALID    ;
    output                          SRCREADY    ;
    input                           SRCFLUSH    ;
    input                           SRCREADYCOND;

    localparam  State_Idle       = 1'b0 ;
    localparam  State_Requesting = 1'b1 ;
    reg         rCurState               ;
    reg         rNextState              ;
    
    always @ (posedge ACLK)
        if (!ARESETN)
            rCurState <= State_Idle;
        else
            rCurState <= rNextState;

    always @ (*)
        case (rCurState)
        State_Idle:
            rNextState <= (SRCFLUSH)?State_Requesting:State_Idle;
        State_Requesting:
            rNextState <= (!SRCVALID)?State_Idle:State_Requesting;
        endcase
    
    assign AXADDR   = SRCADDR                   ;
    assign AXLEN    = SRCLEN                    ;
    assign AXSIZE   = $clog2(DataWidth / 8 - 1) ;
    assign AXBURST  = 2'b01                     ;
    assign AXCACHE  = 4'b0010                   ;
    assign AXPROT   = 3'b0                      ;
    
    assign AXVALID  = (rCurState == State_Requesting) && SRCVALID && SRCREADYCOND;
    assign SRCREADY = (rCurState == State_Requesting) && AXREADY && SRCREADYCOND;
    
endmodule

//////////////////////////////////////////////////////////////////////////////////
// AXI4LiteSlaveInterfaceWriteChannel for Cosmos OpenSSD
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
// Design Name: AXI4Lite slave interface write channel
// Module Name: AXI4LiteSlaveInterfaceWriteChannel
// File Name: AXI4LiteSlaveInterfaceWriteChannel.v
//
// Version: v1.0.0
//
// Description: Write channel control for AXI4-Lite compliant slave interface
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module AXI4LiteSlaveInterfaceWriteChannel
#
(
    parameter AddressWidth = 32,
    parameter DataWidth = 32
)
(
    ACLK            ,
    ARESETN         ,
    AWVALID         ,
    AWREADY         ,
    AWADDR          ,
    AWPROT          ,
    WVALID          ,
    WREADY          ,
    WDATA           ,
    WSTRB           ,
    BVALID          ,
    BREADY          ,
    BRESP           ,
    oWriteAddress   ,
    oWriteData      ,
    oWriteValid     ,
    iWriteAck
);

    input                           ACLK            ;
    input                           ARESETN         ;
    input                           AWVALID         ;
    output                          AWREADY         ;
    input   [AddressWidth - 1:0]    AWADDR          ;
    input   [2:0]                   AWPROT          ;
    input                           WVALID          ;
    output                          WREADY          ;
    input   [DataWidth - 1:0]       WDATA           ;
    input   [DataWidth/8 - 1:0]     WSTRB           ;
    output                          BVALID          ;
    input                           BREADY          ;
    output  [1:0]                   BRESP           ;
                                    
    output  [AddressWidth - 1:0]    oWriteAddress   ;
    output  [DataWidth - 1:0]       oWriteData      ;
    output                          oWriteValid     ;
    input                           iWriteAck       ;
    
    reg     [AddressWidth - 1:0]    rWriteAddress   ;
    reg     [DataWidth - 1:0]       rWriteData      ;
    
    localparam  State_Idle          = 2'b00; 
    localparam  State_INCMDREQ      = 2'b01;
    localparam  State_AXIWRESP      = 2'b11;
    
    reg [1:0]   rCurState   ;
    reg [1:0]   rNextState  ;
    
    always @ (posedge ACLK)
        if (!ARESETN)
            rCurState <= State_Idle;
        else
            rCurState <= rNextState;
    
    always @ (*)
        case (rCurState)
        State_Idle:
            rNextState <= (AWVALID && WVALID)?State_INCMDREQ:State_Idle;        
        State_INCMDREQ:
            rNextState <= (iWriteAck)?State_AXIWRESP:State_INCMDREQ;
        State_AXIWRESP:
            rNextState <= (BREADY)?State_Idle:State_AXIWRESP;
        default:
            rNextState <= State_Idle;
        endcase
    
    assign AWREADY      = ((rCurState == State_INCMDREQ) && iWriteAck);
    assign WREADY       = ((rCurState == State_INCMDREQ) && iWriteAck);
    assign oWriteValid  = (rCurState == State_INCMDREQ);
    
    always @ (posedge ACLK)
        if (!ARESETN)
            rWriteAddress <= {(AddressWidth){1'b0}};
        else
            if (AWVALID)
                rWriteAddress <= AWADDR;
    
    always @ (posedge ACLK)
        if (!ARESETN)
            rWriteData <= {(DataWidth){1'b0}};
        else
            if (WVALID)
                rWriteData <= WDATA;
    
    assign oWriteAddress = rWriteAddress;
    assign oWriteData = rWriteData;
    
    assign BVALID = (rCurState == State_AXIWRESP);
    assign BRESP = 2'b0;
    
endmodule

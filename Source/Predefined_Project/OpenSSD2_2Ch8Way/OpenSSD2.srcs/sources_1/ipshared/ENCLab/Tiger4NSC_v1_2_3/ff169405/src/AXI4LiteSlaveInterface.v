//////////////////////////////////////////////////////////////////////////////////
// AXI4LiteSlaveInterface for Cosmos OpenSSD
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
// Design Name: AXI4Lite slave interface
// Module Name: AXI4LiteSlaveInterface
// File Name: AXI4LiteSlaveInterface.v
//
// Version: v1.0.0
//
// Description: AXI4-Lite compliant slave interface for AXI-related IPs
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module AXI4LiteSlaveInterface
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
    ARVALID         ,
    ARREADY         ,
    ARADDR          ,
    ARPROT          ,
    RVALID          ,
    RREADY          ,
    RDATA           ,
    RRESP           ,
    oWriteAddress   ,
    oReadAddress    ,
    oWriteData      ,
    iReadData       ,
    oWriteValid     ,
    oReadValid      ,
    iWriteAck       ,
    iReadAck
);
    // AXI4 Lite Interface
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
    input                           ARVALID         ;
    output                          ARREADY         ;
    input   [AddressWidth - 1:0]    ARADDR          ;
    input   [2:0]                   ARPROT          ;
    output                          RVALID          ;
    input                           RREADY          ;
    output  [DataWidth - 1:0]       RDATA           ;
    output  [1:0]                   RRESP           ;
        
    // Inner AXI-like Interface
    output  [AddressWidth - 1:0]    oWriteAddress   ;
    output  [AddressWidth - 1:0]    oReadAddress    ;
    output  [DataWidth - 1:0]       oWriteData      ;
    input   [DataWidth - 1:0]       iReadData       ;
    output                          oWriteValid     ;
    output                          oReadValid      ;
    input                           iWriteAck       ;
    input                           iReadAck        ;

    AXI4LiteSlaveInterfaceWriteChannel
    #
    (
        .AddressWidth   (AddressWidth   ),
        .DataWidth      (DataWidth      )
    )
    Inst_AXI4LiteSlaveInterfaceWriteChannel
    (
        .ACLK           (ACLK           ),
        .ARESETN        (ARESETN        ),
        .AWVALID        (AWVALID        ),
        .AWREADY        (AWREADY        ),
        .AWADDR         (AWADDR         ),
        .AWPROT         (AWPROT         ),
        .WVALID         (WVALID         ),
        .WREADY         (WREADY         ),
        .WDATA          (WDATA          ),
        .WSTRB          (WSTRB          ),
        .BVALID         (BVALID         ),
        .BREADY         (BREADY         ),
        .BRESP          (BRESP          ),
        .oWriteAddress  (oWriteAddress  ),
        .oWriteData     (oWriteData     ),
        .oWriteValid    (oWriteValid    ),
        .iWriteAck      (iWriteAck      )
    );
    
    AXI4LiteSlaveInterfaceReadChannel
    #
    (
        .AddressWidth   (AddressWidth   ),
        .DataWidth      (DataWidth      )
    )
    Inst_AXI4LiteSlaveInterfaceReadChannel
    (
        .ACLK           (ACLK           ),
        .ARESETN        (ARESETN        ),
        .ARVALID        (ARVALID        ),
        .ARREADY        (ARREADY        ),
        .ARADDR         (ARADDR         ),
        .ARPROT         (ARPROT         ),
        .RVALID         (RVALID         ),
        .RREADY         (RREADY         ),
        .RDATA          (RDATA          ),
        .RRESP          (RRESP          ),
        .oReadAddress   (oReadAddress   ),
        .iReadData      (iReadData      ),
        .oReadValid     (oReadValid     ),
        .iReadAck       (iReadAck       )
    );
    
endmodule

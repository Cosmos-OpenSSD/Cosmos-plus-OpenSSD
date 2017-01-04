//////////////////////////////////////////////////////////////////////////////////
// AXI4MasterInterface for Cosmos OpenSSD
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
// Design Name: AXI4 master interface
// Module Name: AXI4MasterInterface
// File Name: AXI4MasterInterface.v
//
// Version: v1.0.0
//
// Description: AXI4 compliant master interface supporting transaction division 
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module AXI4MasterInterface
#
(
	parameter AddressWidth          = 32    ,
	parameter DataWidth             = 32    ,
    parameter InnerIFLengthWidth    = 16    ,
    parameter MaxDivider            = 16
)
(
    ACLK                ,
    ARESETN             ,
    
    M_AWADDR            ,
    M_AWLEN             ,
    M_AWSIZE            ,
    M_AWBURST           ,
    M_AWCACHE           ,
    M_AWPROT            ,
    M_AWVALID           ,
    M_AWREADY           ,
    M_WDATA             ,
    M_WSTRB             ,
    M_WLAST             ,
    M_WVALID            ,
    M_WREADY            ,
    M_BRESP             ,
    M_BVALID            ,
    M_BREADY            ,
    M_ARADDR            ,
    M_ARLEN             ,
    M_ARSIZE            ,
    M_ARBURST           ,
    M_ARCACHE           ,
    M_ARPROT            ,
    M_ARVALID           ,
    M_ARREADY           ,
    M_RDATA             ,
    M_RRESP             ,
    M_RLAST             ,
    M_RVALID            ,
    M_RREADY            ,
    
    iWriteAddress       ,
    iWriteBeats         ,
    iWriteCommandReq    ,
    oWriteCommandAck    ,
    iWriteData          ,
    iWriteLast          ,
    iWriteValid         ,
    oWriteReady         ,
    iReadAddress        ,
    iReadBeats          ,
    iReadCommandReq     ,
    oReadCommandAck     ,
    oReadData           ,
    oReadLast           ,
    oReadValid          ,
    iReadReady
);
    input                               ACLK            ;
    input                               ARESETN         ;
    
    // AXI4 Interface
    output  [AddressWidth - 1:0]        M_AWADDR        ;
    output  [7:0]                       M_AWLEN         ;
    output  [2:0]                       M_AWSIZE        ;
    output  [1:0]                       M_AWBURST       ;
    output  [3:0]                       M_AWCACHE       ;
    output  [2:0]                       M_AWPROT        ;
    output                              M_AWVALID       ;
    input                               M_AWREADY       ;
    output  [DataWidth - 1:0]           M_WDATA         ;
    output  [(DataWidth/8) - 1:0]       M_WSTRB         ;
    output                              M_WLAST         ;
    output                              M_WVALID        ;
    input                               M_WREADY        ;
    input   [1:0]                       M_BRESP         ;
    input                               M_BVALID        ;
    output                              M_BREADY        ;
    
    output  [AddressWidth - 1:0]        M_ARADDR        ;
    output  [7:0]                       M_ARLEN         ;
    output  [2:0]                       M_ARSIZE        ;
    output  [1:0]                       M_ARBURST       ;
    output  [3:0]                       M_ARCACHE       ;
    output  [2:0]                       M_ARPROT        ;
    output                              M_ARVALID       ;
    input                               M_ARREADY       ;
    input   [DataWidth - 1:0]           M_RDATA         ;
    input   [1:0]                       M_RRESP         ;
    input                               M_RLAST         ;
    input                               M_RVALID        ;
    output                              M_RREADY        ;

    // Inner AXI-like Interface
    input   [AddressWidth - 1:0]        iWriteAddress   ;
    input   [InnerIFLengthWidth - 1:0]  iWriteBeats     ;
    input                               iWriteCommandReq;
    output                              oWriteCommandAck;
    input   [DataWidth - 1:0]           iWriteData      ;
    input                               iWriteLast      ;
    input                               iWriteValid     ;
    output                              oWriteReady     ;
                                                        ;
    input   [AddressWidth - 1:0]        iReadAddress    ;
    input   [InnerIFLengthWidth - 1:0]  iReadBeats      ;
    input                               iReadCommandReq ;
    output                              oReadCommandAck ;
    output  [DataWidth - 1:0]           oReadData       ;
    output                              oReadLast       ;
    output                              oReadValid      ;
    input                               iReadReady      ;

    AXI4MasterInterfaceWriteChannel
    #
    (
        .AddressWidth       (AddressWidth       ),
        .DataWidth          (DataWidth          ),
        .InnerIFLengthWidth (InnerIFLengthWidth ),
        .MaxDivider         (MaxDivider         )
    )
    Inst_AXI4MasterInterfaceWriteChannel
    (
        .ACLK           (ACLK               ),
        .ARESETN        (ARESETN            ),
        .OUTER_AWADDR   (M_AWADDR           ),
        .OUTER_AWLEN    (M_AWLEN            ),
        .OUTER_AWSIZE   (M_AWSIZE           ),
        .OUTER_AWBURST  (M_AWBURST          ),
        .OUTER_AWCACHE  (M_AWCACHE          ),
        .OUTER_AWPROT   (M_AWPROT           ),
        .OUTER_AWVALID  (M_AWVALID          ),
        .OUTER_AWREADY  (M_AWREADY          ),
        .OUTER_WDATA    (M_WDATA            ),
        .OUTER_WSTRB    (M_WSTRB            ),
        .OUTER_WLAST    (M_WLAST            ),
        .OUTER_WVALID   (M_WVALID           ),
        .OUTER_WREADY   (M_WREADY           ),
        .OUTER_BRESP    (M_BRESP            ),
        .OUTER_BVALID   (M_BVALID           ),
        .OUTER_BREADY   (M_BREADY           ),
        .INNER_AWADDR   (iWriteAddress      ),
        .INNER_AWLEN    (iWriteBeats        ),
        .INNER_AWVALID  (iWriteCommandReq   ),
        .INNER_AWREADY  (oWriteCommandAck   ),
        .INNER_WDATA    (iWriteData         ),
        .INNER_WLAST    (iWriteLast         ),
        .INNER_WVALID   (iWriteValid        ),
        .INNER_WREADY   (oWriteReady        )
    );

    AXI4MasterInterfaceReadChannel
    #
    (
        .AddressWidth       (AddressWidth       ),
        .DataWidth          (DataWidth          ),
        .InnerIFLengthWidth (InnerIFLengthWidth ),
        .MaxDivider         (MaxDivider         )
    )
    Inst_AXI4MasterInterfaceReadChannel
    (
        .ACLK           (ACLK           ),
        .ARESETN        (ARESETN        ),
        .OUTER_ARADDR   (M_ARADDR       ),
        .OUTER_ARLEN    (M_ARLEN        ),
        .OUTER_ARSIZE   (M_ARSIZE       ),
        .OUTER_ARBURST  (M_ARBURST      ),
        .OUTER_ARCACHE  (M_ARCACHE      ),
        .OUTER_ARPROT   (M_ARPROT       ),
        .OUTER_ARVALID  (M_ARVALID      ),
        .OUTER_ARREADY  (M_ARREADY      ),
        .OUTER_RDATA    (M_RDATA        ),
        .OUTER_RRESP    (M_RRESP        ),
        .OUTER_RLAST    (M_RLAST        ),
        .OUTER_RVALID   (M_RVALID       ),
        .OUTER_RREADY   (M_RREADY       ),
        .INNER_ARADDR   (iReadAddress   ),
        .INNER_ARLEN    (iReadBeats     ),
        .INNER_ARVALID  (iReadCommandReq),
        .INNER_ARREADY  (oReadCommandAck),
        .INNER_RDATA    (oReadData      ),
        .INNER_RLAST    (oReadLast      ),
        .INNER_RVALID   (oReadValid     ),
        .INNER_RREADY   (iReadReady     )
    );


endmodule

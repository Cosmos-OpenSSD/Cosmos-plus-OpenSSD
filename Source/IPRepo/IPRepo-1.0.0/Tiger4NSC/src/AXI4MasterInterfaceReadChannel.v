//////////////////////////////////////////////////////////////////////////////////
// AXI4MasterInterfaceReadChannel for Cosmos OpenSSD
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
// Design Name: AXI4 master interface read channel
// Module Name: AXI4MasterInterfaceReadChannel
// File Name: AXI4MasterInterfaceReadChannel.v
//
// Version: v1.0.0
//
// Description: AXI4 compliant read channel control for master interface 
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module AXI4MasterInterfaceReadChannel
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
    
    OUTER_ARADDR        ,
    OUTER_ARLEN         ,
    OUTER_ARSIZE        ,
    OUTER_ARBURST       ,
    OUTER_ARCACHE       ,
    OUTER_ARPROT        ,
    OUTER_ARVALID       ,
    OUTER_ARREADY       ,
    OUTER_RDATA         ,
    OUTER_RRESP         ,
    OUTER_RLAST         ,
    OUTER_RVALID        ,
    OUTER_RREADY        ,
    
    INNER_ARADDR        ,
    INNER_ARLEN         ,
    INNER_ARVALID       ,
    INNER_ARREADY       ,
    INNER_RDATA         ,
    INNER_RLAST         ,
    INNER_RVALID        ,
    INNER_RREADY
);
    input                               ACLK            ;
    input                               ARESETN         ;
    
    output  [AddressWidth - 1:0]        OUTER_ARADDR    ;
    output  [7:0]                       OUTER_ARLEN     ;
    output  [2:0]                       OUTER_ARSIZE    ;
    output  [1:0]                       OUTER_ARBURST   ;
    output  [3:0]                       OUTER_ARCACHE   ;
    output  [2:0]                       OUTER_ARPROT    ;
    output                              OUTER_ARVALID   ;
    input                               OUTER_ARREADY   ;
    input   [DataWidth - 1:0]           OUTER_RDATA     ;
    input   [1:0]                       OUTER_RRESP     ;
    input                               OUTER_RLAST     ;
    input                               OUTER_RVALID    ;
    output                              OUTER_RREADY    ;

    input   [AddressWidth - 1:0]        INNER_ARADDR    ;
    input   [InnerIFLengthWidth - 1:0]  INNER_ARLEN     ;
    input                               INNER_ARVALID   ;
    output                              INNER_ARREADY   ;
    output  [DataWidth - 1:0]           INNER_RDATA     ;
    output                              INNER_RLAST     ;
    output                              INNER_RVALID    ;
    input                               INNER_RREADY    ;

    wire    [AddressWidth - 1:0]        wDivAddress     ;
    wire    [7:0]                       wDivLength      ;
    wire                                wDivValid       ;
    wire                                wDivReady       ;
    wire                                wDivFlush       ;
    
    wire                                wRCmdQPopSignal ;
    wire                                wIsRCmdQFull    ;
    wire                                wIsRCmdQEmpty   ;
    
    wire    [AddressWidth - 1:0]        wQdDivAddress   ;
    wire    [7:0]                       wQdDivLength    ;
    wire                                wQdDivValid     ;
    wire                                wQdDivReady     ;
    wire                                wDivReadyCond   ;
    
    wire                                wIsRLenQFull    ;
    wire                                wIsRLenQEmpty   ;
    
    AXI4CommandDivider
    #
    (
        .AddressWidth       (AddressWidth       ),
        .DataWidth          (DataWidth          ),
        .InnerIFLengthWidth (InnerIFLengthWidth ),
        .MaxDivider         (MaxDivider         )
    )
    Inst_AXI4ReadCommandDivider
    (
        .ACLK           (ACLK           ),
        .ARESETN        (ARESETN        ),
        .SRCADDR        (INNER_ARADDR   ),
        .SRCLEN         (INNER_ARLEN    ),
        .SRCVALID       (INNER_ARVALID  ),
        .SRCREADY       (INNER_ARREADY  ),
        .SRCREADYCOND   (!wIsRLenQFull  ),
        .DIVADDR        (wDivAddress    ),
        .DIVLEN         (wDivLength     ),
        .DIVVALID       (wDivValid      ),
        .DIVREADY       (wDivReady      ),
        .DIVFLUSH       (wDivFlush      )
    );
    
    assign wDivReady = !wIsRCmdQFull;

    SCFIFO_80x64_withCount
    Inst_AXI4ReadCommandQ
    (
        .iClock         (ACLK                           ),
        .iReset         (!ARESETN                       ),
        .iPushData      ({wDivAddress, wDivLength}      ),
        .iPushEnable    (wDivValid & wDivReady          ),
        .oIsFull        (wIsRCmdQFull                   ),
        .oPopData       ({wQdDivAddress, wQdDivLength}  ),
        .iPopEnable     (wRCmdQPopSignal                ),
        .oIsEmpty       (wIsRCmdQEmpty                  ),
        .oDataCount     (                               )
    );
    
    AutoFIFOPopControl
    Inst_AXI4ReadCommandQPopControl
    (
        .iClock         (ACLK           ),
        .iReset         (!ARESETN       ),
        .oPopSignal     (wRCmdQPopSignal),
        .iEmpty         (wIsRCmdQEmpty  ),
        .oValid         (wQdDivValid    ),
        .iReady         (wQdDivReady    )
    );
    
    AXI4CommandDriver
    #
    (
        .AddressWidth   (AddressWidth   ),
        .DataWidth      (DataWidth      )
    )
    Inst_AXI4ReadCommandDriver
    (
        .ACLK           (ACLK           ),
        .ARESETN        (ARESETN        ),
        .AXADDR         (OUTER_ARADDR   ),
        .AXLEN          (OUTER_ARLEN    ),
        .AXSIZE         (OUTER_ARSIZE   ),
        .AXBURST        (OUTER_ARBURST  ),
        .AXCACHE        (OUTER_ARCACHE  ),
        .AXPROT         (OUTER_ARPROT   ),
        .AXVALID        (OUTER_ARVALID  ),
        .AXREADY        (OUTER_ARREADY  ),
        .SRCADDR        (wQdDivAddress  ),
        .SRCLEN         (wQdDivLength   ),
        .SRCVALID       (wQdDivValid    ),
        .SRCREADY       (wQdDivReady    ),
        .SRCFLUSH       (wDivFlush      ),
        .SRCREADYCOND   (1'b1           )
    );
    
    wire    [InnerIFLengthWidth - 1:0]  wQdRLen         ;
    wire                                wRLenQPopSignal ;
    wire                                wQdRLenValid    ;
    wire                                wQdRLenReady    ;
    
    assign  wDivReadyCond = !wIsRLenQFull;
    
    SCFIFO_40x64_withCount
    Inst_AXI4ReadLengthQ
    (
        .iClock         (ACLK                                                   ),
        .iReset         (!ARESETN                                               ),
        .iPushData      (INNER_ARLEN - 1                                        ),
        .iPushEnable    (INNER_ARVALID && INNER_ARREADY && (INNER_ARLEN != 0)   ),
        .oIsFull        (wIsRLenQFull                                           ),
        .oPopData       (wQdRLen                                                ),
        .iPopEnable     (wRLenQPopSignal                                        ),
        .oIsEmpty       (wIsRLenQEmpty                                          ),
        .oDataCount     (                                                       )
    );
    
    AutoFIFOPopControl
    Inst_AXI4ReadLengthQPopControl
    (
        .iClock         (ACLK           ),
        .iReset         (!ARESETN       ),
        .oPopSignal     (wRLenQPopSignal),
        .iEmpty         (wIsRLenQEmpty  ),
        .oValid         (wQdRLenValid   ),
        .iReady         (wQdRLenReady   )
    );
    
    wire    [DataWidth - 1:0]           wQdRData        ;
    wire                                wIsRDataQFull   ;
    wire                                wIsRDataQEmpty  ;
    wire                                wRDataQPopSignal;
    wire                                wQdRDataValid   ;
    wire                                wQdRDataReady   ;
    
    assign OUTER_RREADY = !wIsRDataQFull;
    
    SCFIFO_64x64_withCount
    Inst_AXI4ReadDataQ
    (
        .iClock         (ACLK                           ),
        .iReset         (!ARESETN                       ),
        .iPushData      (OUTER_RDATA                    ),
        .iPushEnable    (OUTER_RVALID && OUTER_RREADY   ),
        .oIsFull        (wIsRDataQFull                  ),
        .oPopData       (wQdRData                       ),
        .iPopEnable     (wRDataQPopSignal               ),
        .oIsEmpty       (wIsRDataQEmpty                 ),
        .oDataCount     (                               )
    );
    
    AutoFIFOPopControl
    Inst_AXI4ReadDataQPopControl
    (
        .iClock         (ACLK               ),
        .iReset         (!ARESETN           ),
        .oPopSignal     (wRDataQPopSignal   ),
        .iEmpty         (wIsRDataQEmpty     ),
        .oValid         (wQdRDataValid      ),
        .iReady         (wQdRDataReady      )
    );
    
    AXI4DataDriver
    #
    (
        .AddressWidth   (AddressWidth       ),
        .DataWidth      (DataWidth          ),
        .LengthWidth    (InnerIFLengthWidth )
    )
    Inst_AXI4ReadDataDriver
    (
        .ACLK       (ACLK           ),
        .ARESETN    (ARESETN        ),
        .SRCLEN     (wQdRLen        ),
        .SRCVALID   (wQdRLenValid   ),
        .SRCREADY   (wQdRLenReady   ),
        .DATA       (wQdRData       ),
        .DVALID     (wQdRDataValid  ),
        .DREADY     (wQdRDataReady  ),
        .XDATA      (INNER_RDATA    ),
        .XDVALID    (INNER_RVALID   ),
        .XDREADY    (INNER_RREADY   ),
        .XDLAST     (INNER_RLAST    )
    );
    
    assign OUTER_WSTRB = {(DataWidth/8){1'b1}};

endmodule

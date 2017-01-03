//////////////////////////////////////////////////////////////////////////////////
// BCHEncoderControl for Cosmos OpenSSD
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
// Module Name: BCHEncoderControl
// File Name: BCHEncoderControl.v
//
// Version: v1.0.0
//
// Description: Controls BCH encoder
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module BCHEncoderControl
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
    oSrcReadData    ,
    oSrcReadValid   ,
    oSrcReadLast    ,
    iSrcReadReady   ,
    oDstOpcode      ,
    oDstTargetID    ,
    oDstSourceID    ,
    oDstAddress     ,
    oDstLength      ,
    oDstCmdValid    ,
    iDstCmdReady    ,
    iDstReadData    ,
    iDstReadValid   ,
    iDstReadLast    ,
    oDstReadReady
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
    
    output  [DataWidth - 1:0]           oSrcReadData    ;
    output                              oSrcReadValid   ;
    output                              oSrcReadLast    ;
    input                               iSrcReadReady   ;
    
    // Slave side
    output  [5:0]                       oDstOpcode      ;
    output  [4:0]                       oDstTargetID    ;
    output  [4:0]                       oDstSourceID    ;
    output  [AddressWidth - 1:0]        oDstAddress     ;
    output  [InnerIFLengthWidth - 1:0]  oDstLength      ;
    output                              oDstCmdValid    ;
    input                               iDstCmdReady    ;
    
    input   [DataWidth - 1:0]           iDstReadData    ;
    input                               iDstReadValid   ;
    input                               iDstReadLast    ;
    output                              oDstReadReady   ;
    
    wire                                wOpQPushSignal  ;
    wire    [InnerIFLengthWidth+2-1:0]  wOpQPushData    ;
    wire    [InnerIFLengthWidth+2-1:0]  wOpQPopData     ;
    wire                                wOpQIsFull      ;
    wire                                wOpQIsEmpty     ;
    wire                                wOpQOpValid     ;
    wire                                wOpQOpReady     ;
    wire    [InnerIFLengthWidth - 1:0]  wOpQOpLength    ;
    wire    [1:0]                       wOpQOpType      ;
    
    wire    wOpQPopSignal   ;
    SCFIFO_64x64_withCount
    DataBuffer
    (
        .iClock         (iClock                         ),
        .iReset         (iReset                         ),
        .iPushData      (wOpQPushData                   ),
        .iPushEnable    (wOpQPushSignal                 ),
        .oIsFull        (wOpQIsFull                     ),
        .oPopData       (wOpQPopData                    ),
        .iPopEnable     (wOpQPopSignal                  ),
        .oIsEmpty       (wOpQIsEmpty                    ),
        .oDataCount     (                               )
    );
    AutoFIFOPopControl
    DataBufferControl
    (
        .iClock         (iClock                         ),
        .iReset         (iReset                         ),
        .oPopSignal     (wOpQPopSignal                  ),
        .iEmpty         (wOpQIsEmpty                    ),
        .oValid         (wOpQOpValid                    ),
        .iReady         (wOpQOpReady                    )
    );
    
    BCHEncoderCommandChannel
    #
    (
        .AddressWidth          (AddressWidth        ),
        .DataWidth             (DataWidth           ),
        .InnerIFLengthWidth    (InnerIFLengthWidth  ),
        .ThisID                (ThisID              )
    )
    Inst_BCHEncoderCommandChannel
    (
        .iClock         (iClock         ),
        .iReset         (iReset         ),
        .iSrcOpcode     (iSrcOpcode     ),
        .iSrcTargetID   (iSrcTargetID   ),
        .iSrcSourceID   (iSrcSourceID   ),
        .iSrcAddress    (iSrcAddress    ),
        .iSrcLength     (iSrcLength     ),
        .iSrcCmdValid   (iSrcCmdValid   ),
        .oSrcCmdReady   (oSrcCmdReady   ),
        .oOpQPushSignal (wOpQPushSignal ),
        .oOpQPushData   (wOpQPushData   ),
        .oDstOpcode     (oDstOpcode     ),
        .oDstTargetID   (oDstTargetID   ),
        .oDstSourceID   (oDstSourceID   ),
        .oDstAddress    (oDstAddress    ),
        .oDstLength     (oDstLength     ),
        .oDstCmdValid   (oDstCmdValid   ),
        .iDstCmdReady   (iDstCmdReady   ),
        .iSrcValidCond  (!wOpQIsFull    )
    );
    
    assign {wOpQOpLength, wOpQOpType} = wOpQPopData;
    
    BCHEncoderDataChannel
    #
    (
        .DataWidth              (DataWidth          ),
        .InnerIFLengthWidth     (InnerIFLengthWidth )
    )
    Inst_BCHEncoderDataChannel
    (
        .iClock         (iClock         ),
        .iReset         (iReset         ),
        .iLength        (wOpQOpLength   ),
        .iCmdType       (wOpQOpType     ),
        .iCmdValid      (wOpQOpValid    ),
        .oCmdReady      (wOpQOpReady    ),
        .oSrcReadData   (oSrcReadData   ),
        .oSrcReadValid  (oSrcReadValid  ),
        .oSrcReadLast   (oSrcReadLast   ),
        .iSrcReadReady  (iSrcReadReady  ),
        .iDstReadData   (iDstReadData   ),
        .iDstReadValid  (iDstReadValid  ),
        .iDstReadLast   (iDstReadLast   ),
        .oDstReadReady  (oDstReadReady  )
    );

endmodule

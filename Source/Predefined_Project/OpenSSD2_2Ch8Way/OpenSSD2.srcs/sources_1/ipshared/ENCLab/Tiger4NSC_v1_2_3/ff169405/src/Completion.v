//////////////////////////////////////////////////////////////////////////////////
// Completion for Cosmos OpenSSD
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
// Design Name: Completion
// Module Name: Completion
// File Name: Completion.v
//
// Version: v1.0.0
//
// Description: Reports completion of an operation
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module Completion
#
(
    parameter AddressWidth          = 32    ,
    parameter DataWidth             = 32    ,
    parameter InnerIFLengthWidth    = 16    ,
    parameter ThisID                = 1
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
    iSrcWriteData   ,
    iSrcWriteValid  ,
    iSrcWriteLast   ,
    oSrcWriteReady  ,
    oDstOpcode      ,
    oDstTargetID    ,
    oDstSourceID    ,
    oDstAddress     ,
    oDstLength      ,
    oDstCmdValid    ,
    iDstCmdReady    ,
    oDstWriteData   ,
    oDstWriteValid  ,
    oDstWriteLast   ,
    iDstWriteReady
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
    
    input   [DataWidth - 1:0]           iSrcWriteData   ;
    input                               iSrcWriteValid  ;
    input                               iSrcWriteLast   ;
    output                              oSrcWriteReady  ;
    
    // Slave side
    output  [5:0]                       oDstOpcode      ;
    output  [4:0]                       oDstTargetID    ;
    output  [4:0]                       oDstSourceID    ;
    output  [AddressWidth - 1:0]        oDstAddress     ;
    output  [InnerIFLengthWidth - 1:0]  oDstLength      ;
    output                              oDstCmdValid    ;
    input                               iDstCmdReady    ;
    
    output  [DataWidth - 1:0]           oDstWriteData   ;
    output                              oDstWriteValid  ;
    output                              oDstWriteLast   ;
    input                               iDstWriteReady  ;
    
    wire                                wDataChReady    ;
    
    CompletionCommandChannel
    #
    (
        .AddressWidth       (AddressWidth       ),
        .DataWidth          (DataWidth          ),
        .InnerIFLengthWidth (InnerIFLengthWidth ),
        .ThisID             (ThisID             )
    )
    Inst_CompletionCommandChannel
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
        .oDstOpcode     (oDstOpcode     ),
        .oDstTargetID   (oDstTargetID   ),
        .oDstSourceID   (oDstSourceID   ),
        .oDstAddress    (oDstAddress    ),
        .oDstLength     (oDstLength     ),
        .oDstCmdValid   (oDstCmdValid   ),
        .iDstCmdReady   (iDstCmdReady   ),
        .iSrcValidCond  (wDataChReady   )
    );
    
    CompletionDataChannel
    #
    (
        .DataWidth          (DataWidth          ),
        .InnerIFLengthWidth (InnerIFLengthWidth ),
        .ThisID             (ThisID             )
    )
    Inst_CompletionDataChannel
    (
        .iClock         (iClock                         ),
        .iReset         (iReset                         ),
        .iSrcLength     (iSrcLength                     ),
        .iSrcTargetID   (iSrcTargetID                   ),
        .iSrcValid      (iSrcCmdValid && oSrcCmdReady   ),
        .oSrcReady      (wDataChReady                   ),
        .iSrcWriteData  (iSrcWriteData                  ),
        .iSrcWriteValid (iSrcWriteValid                 ),
        .iSrcWriteLast  (iSrcWriteLast                  ),
        .oSrcWriteReady (oSrcWriteReady                 ),
        .oDstWriteData  (oDstWriteData                  ),
        .oDstWriteValid (oDstWriteValid                 ),
        .oDstWriteLast  (oDstWriteLast                  ),
        .iDstWriteReady (iDstWriteReady                 )
    );
    
endmodule
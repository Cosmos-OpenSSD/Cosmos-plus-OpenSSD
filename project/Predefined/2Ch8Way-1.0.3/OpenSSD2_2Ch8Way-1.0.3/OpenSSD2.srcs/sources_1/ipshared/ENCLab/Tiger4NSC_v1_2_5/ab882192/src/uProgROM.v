//////////////////////////////////////////////////////////////////////////////////
// uProgROM for Cosmos OpenSSD
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
// Design Name: uProgROM
// Module Name: uProgROM
// File Name: uProgROM.v
//
// Version: v1.0.0
//
// Description: Dispatcher micro code ROM controller
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
// * v1.1.0
//   - external brom interface
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module uProgROM
#
(
    parameter ProgWordWidth         = 64    ,
    parameter UProgSize             = 256
)
(
    iClock                  ,
    iReset                  ,
    iNewProgCursor          ,
    iNewProgCursorValid     ,
    oProgData               ,
    oProgDataValid          ,
    iProgDataReady          ,
    oROMClock               ,
    oROMReset               ,
    oROMAddr                ,
    oROMRW                  ,
    oROMEnable              ,
    oROMWData               ,
    iROMRData
);
    input                               iClock              ;
    input                               iReset              ;
    input   [$clog2(UProgSize) - 1:0]   iNewProgCursor      ;
    input                               iNewProgCursorValid ;
    output  [ProgWordWidth - 1:0]       oProgData           ;
    output                              oProgDataValid      ;
    input                               iProgDataReady      ;
    output                              oROMClock           ;
    output                              oROMReset           ;
    output  [$clog2(UProgSize) - 1:0]   oROMAddr            ;
    output                              oROMRW              ;
    output                              oROMEnable          ;
    output  [ProgWordWidth - 1:0]       oROMWData           ;
    input   [ProgWordWidth - 1:0]       iROMRData           ;

    wire    [$clog2(UProgSize) - 1:0]   wUProgReadAddr      ;
    wire    [ProgWordWidth - 1:0]       wUProgReadData      ;
    wire                                wUProgReadSig       ;

    BRAMPopControl
    #
    (
        .BRAMAddressWidth   ($clog2(UProgSize)  ),
        .DataWidth          (ProgWordWidth      )
    )
    Inst_BRAMPopControl
    (
        .iClock             (iClock             ),
        .iReset             (iReset             ),
        .iAddressInput      (iNewProgCursor     ),
        .iAddressValid      (iNewProgCursorValid),
        .oDataOut           (oProgData          ),
        .oDataValid         (oProgDataValid     ),
        .iDataReady         (iProgDataReady     ),
        .oMemReadAddress    (wUProgReadAddr     ),
        .iMemReadData       (wUProgReadData     ),
        .oMemDataReadSig    (wUProgReadSig      )
    );
    
    assign oROMClock        = iClock                    ;
    assign oROMReset        = iReset                    ;
    assign oROMAddr         = wUProgReadAddr            ;
    assign oROMRW           = 1'b0                      ;
    assign oROMEnable       = wUProgReadSig             ;
    assign oROMWData        = {(ProgWordWidth){1'b0}}   ;
    assign wUProgReadData   = iROMRData                 ;
    
endmodule
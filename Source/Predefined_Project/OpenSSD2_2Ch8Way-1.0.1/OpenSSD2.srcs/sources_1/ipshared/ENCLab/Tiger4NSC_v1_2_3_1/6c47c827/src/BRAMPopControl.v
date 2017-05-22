//////////////////////////////////////////////////////////////////////////////////
// BRAMPopControl for Cosmos OpenSSD
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
// Design Name: BRAM pop controller
// Module Name: BRAMPopControl
// File Name: BRAMPopControl.v
//
// Version: v1.0.0
//
// Description: Automatically pops next data from the BRAM
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module BRAMPopControl
#
(
    parameter BRAMAddressWidth  =   8   ,
    parameter DataWidth         =   32
)
(
    iClock          ,
    iReset          ,
    iAddressInput   ,
    iAddressValid   ,
    oDataOut        ,
    oDataValid      ,
    iDataReady      ,
    oMemReadAddress ,
    iMemReadData    ,
    oMemDataReadSig
);

    input                               iClock          ;
    input                               iReset          ;
    input   [BRAMAddressWidth - 1:0]    iAddressInput   ;
    input                               iAddressValid   ;
    output  [DataWidth - 1:0]           oDataOut        ;
    output                              oDataValid      ;
    input                               iDataReady      ;
    output  [BRAMAddressWidth - 1:0]    oMemReadAddress ;
    input   [DataWidth - 1:0]           iMemReadData    ;
    output                              oMemDataReadSig ;
    
    reg     [BRAMAddressWidth - 1:0]    rReadAddress    ;
    reg                                 rValidSigOut    ;
    reg                                 rValidSigNextOut;
    
    assign oMemReadAddress  = rReadAddress;
    assign oMemDataReadSig  = (!rValidSigOut || iDataReady);
    
    always @ (posedge iClock)
        if (iReset)
            rReadAddress <= {(BRAMAddressWidth){1'b0}};
        else
            if (iAddressValid)
                rReadAddress <= iAddressInput;
            else if (oMemDataReadSig)
                rReadAddress <= rReadAddress + 1'b1;
    
    always @ (posedge iClock)
        if (iReset || iAddressValid)
        begin
            rValidSigOut        <= 1'b0;
            rValidSigNextOut    <= 1'b0;
        end
        else
        begin
            if (!rValidSigOut || iDataReady)
            begin
                rValidSigOut        <= rValidSigNextOut;
                rValidSigNextOut    <= oMemDataReadSig;
            end
        end
    
    assign oDataOut     = iMemReadData;
    assign oDataValid   = rValidSigOut;

endmodule

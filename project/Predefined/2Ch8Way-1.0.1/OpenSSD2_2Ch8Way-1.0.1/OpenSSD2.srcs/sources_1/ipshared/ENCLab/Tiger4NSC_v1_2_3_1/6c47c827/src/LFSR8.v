//////////////////////////////////////////////////////////////////////////////////
// LFSR8 for Cosmos OpenSSD
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
// Design Name: LFSR8
// Module Name: LFSR8
// File Name: LFSR8.v
//
// Version: v1.0.0
//
// Description: LFSR8 for scrambler
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module LFSR8
(
    iClock          ,
    iReset          ,
    iSeed           ,
    iSeedEnable     ,
    iShiftEnable    ,
    oData
);

    input           iClock      ;
    input           iReset      ;
    input   [7:0]   iSeed       ;
    input           iSeedEnable ;
    input           iShiftEnable;
    output  [7:0]   oData       ;
    
    reg     [8:0]   rShiftReg   ;
    wire            wInfeed     ;
    
    always @ (posedge iClock)
        if (iReset)
            rShiftReg <= 9'b0;
        else if (iSeedEnable)
            rShiftReg <= {iSeed[7:0], wInfeed};
        else if (iShiftEnable)
            rShiftReg <= {rShiftReg[7:0], wFeedback};
    
    assign wFeedback = rShiftReg[0] ^ rShiftReg[4] ^ rShiftReg[5] ^ rShiftReg[6] ^ rShiftReg[8];
    assign wInfeed = iSeed[0] ^ iSeed[4] ^ iSeed[5] ^ iSeed[6];
    
    assign oData = rShiftReg[7:0];

endmodule

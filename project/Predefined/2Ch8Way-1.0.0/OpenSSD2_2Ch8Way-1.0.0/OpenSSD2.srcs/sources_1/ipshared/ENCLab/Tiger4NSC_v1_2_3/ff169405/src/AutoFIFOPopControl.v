//////////////////////////////////////////////////////////////////////////////////
// AutoFIFOPopControl for Cosmos OpenSSD
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
// Design Name: Auto FIFO pop controller
// Module Name: AutoFIFOPopControl
// File Name: AutoFIFOPopControl.v
//
// Version: v1.0.0
//
// Description: Automatical FIFO data pop control
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module AutoFIFOPopControl
(
    iClock      ,
    iReset      ,
    oPopSignal  ,
    iEmpty      ,
    oValid      ,
    iReady
);
    input   iClock      ;
    input   iReset      ;
    output  oPopSignal  ;
    input   iEmpty      ;
    output  oValid      ;
    input   iReady      ;

    reg     rValid      ;
    
    assign  oPopSignal  = (!iEmpty && (!rValid || iReady));
    assign  oValid      = rValid;
    
    always @ (posedge iClock)
        if (iReset)
            rValid <= 1'b0;
        else
            if ((!rValid || iReady))
                rValid <= oPopSignal;

endmodule

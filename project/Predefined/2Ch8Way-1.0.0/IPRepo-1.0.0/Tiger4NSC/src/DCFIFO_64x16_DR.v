//////////////////////////////////////////////////////////////////////////////////
// DCFIFO_64x16_DR for Cosmos OpenSSD
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
// Design Name: Dual clock distributed ram FIFO (64 width, 16 depth) wrapper
// Module Name: DCFIFO_64x16_DR
// File Name: DCFIFO_64x16_DR.v
//
// Version: v1.0.0
//
// Description: Standard FIFO, 1 cycle data out latency
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module DCFIFO_64x16_DR
(
    input           iWClock         ,
    input           iWReset         ,

    input   [63:0]  iPushData       ,
    input           iPushEnable     ,
    output          oIsFull         ,
    
    input           iRClock         ,
    input           iRReset         ,
    
    output  [63:0]  oPopData        ,
    input           iPopEnable      ,
    output          oIsEmpty
);

    DPBDCFIFO64x16DR
    Inst_DPBDCFIFO64x16DR
    (
        .wr_clk         (iWClock        ),
        .wr_rst         (iWReset        ),
        .din            (iPushData      ),
        .wr_en          (iPushEnable    ),
        .full           (oIsFull        ),
        .rd_clk         (iRClock        ),
        .rd_rst         (iRReset        ),
        .dout           (oPopData       ),
        .rd_en          (iPopEnable     ),
        .empty          (oIsEmpty       )
    );

endmodule

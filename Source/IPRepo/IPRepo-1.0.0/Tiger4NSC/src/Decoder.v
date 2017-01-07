//////////////////////////////////////////////////////////////////////////////////
// Decoder for Cosmos OpenSSD
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
// Design Name: Decoder
// Module Name: Decoder
// File Name: Decoder.v
//
// Version: v1.0.0
//
// Description: General purpose decoder
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module Decoder
#
(
    parameter OutputWidth = 4
)
(
    I,
    O
);

    input   [$clog2(OutputWidth) - 1:0] I;
    output  [OutputWidth - 1:0]         O;
    
    reg     [OutputWidth - 1:0]         rO;
    
    genvar c;
    
    generate
        for (c = 0; c < OutputWidth; c = c + 1)
        begin: DecodeBits
            always @ (*)
            begin
                if (I == c)
                    rO[c] <= 1'b1;
                else
                    rO[c] <= 1'b0;
            end
        end
    endgenerate
    
    assign O = rO;

endmodule
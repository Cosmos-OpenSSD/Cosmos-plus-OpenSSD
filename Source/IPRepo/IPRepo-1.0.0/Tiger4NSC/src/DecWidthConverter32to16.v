//////////////////////////////////////////////////////////////////////////////////
// DecWidthConverter32to16.v for Cosmos OpenSSD
// Copyright (c) 2015 Hanyang University ENC Lab.
// Contributed by Jinwoo Jeong <jwjeong@enc.hanyang.ac.kr>
//                Ilyong Jung <iyjung@enc.hanyang.ac.kr>
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
//           Ilyong Jung <iyjung@enc.hanyang.ac.kr>
// 
// Project Name: Cosmos OpenSSD
// Design Name: Data width down converter
// Module Name: DecWidthConverter32to16
// File Name: DecWidthConverter32to16.v
//
// Version: v1.0.0
//
// Description: Data width down converting unit for decoder
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module DecWidthConverter32to16
#
(
    parameter   InputDataWidth  = 32,
    parameter   OutputDataWidth = 16
)
(
    iClock              ,
    iReset              ,
    iSrcDataValid       ,
    iSrcData            ,
    oConverterReady     ,
    oConvertedDataValid ,
    oConvertedData      ,
    iDstReady
);

    input                           iClock              ;
    input                           iReset              ;
    input                           iSrcDataValid       ;
    input   [InputDataWidth - 1:0]  iSrcData            ;
    output                          oConverterReady     ;
    output                          oConvertedDataValid ;
    output  [OutputDataWidth - 1:0] oConvertedData      ;
    input                           iDstReady           ;
    
    reg     [InputDataWidth - 1:0]  rShiftRegister      ;
    reg                             rConvertedDataValid ;
    reg                             rConverterReady     ;
    
    localparam  State_Idle      = 5'b00001; 
    localparam  State_Input     = 5'b00010;
    localparam  State_Shift     = 5'b00100;
    localparam  State_InPause   = 5'b01000;
    localparam  State_OutPause  = 5'b10000;
    
    reg     [4:0]   rCurState;
    reg     [4:0]   rNextState;
    
    always @ (posedge iClock)
        if (iReset)
            rCurState <= State_Idle;
        else
            rCurState <= rNextState;
    
   always @ (*)
        case (rCurState)
        State_Idle:
            rNextState <= (iSrcDataValid) ? State_Input : State_Idle;
        State_Input:
            rNextState <= (iDstReady) ? State_Shift : State_InPause;
        State_Shift:
            if (iDstReady)
            begin
                if (iSrcDataValid)
                    rNextState <= State_Input;
                else
                    rNextState <= State_Idle;
            end
            else
                rNextState <= State_OutPause;
        State_InPause:
            rNextState <= (iDstReady) ? State_Shift : State_InPause;
        State_OutPause:
            if (iDstReady)
            begin
                if (iSrcDataValid)
                    rNextState <= State_Input;
                else
                    rNextState <= State_Idle;
            end
            else
                rNextState <= State_OutPause;
        default:
            rNextState <= State_Idle;
        endcase
       
    always @ (posedge iClock)
        if (iReset)
            rShiftRegister  <= 0;
        else
            case (rNextState)
            State_Idle:
                rShiftRegister <= 0;
            State_Input:
                rShiftRegister <= iSrcData;
            State_Shift:
                rShiftRegister <= rShiftRegister << OutputDataWidth;
            default:
                rShiftRegister <= rShiftRegister;
            endcase
            
    always @ (posedge iClock)
        if (iReset)
            rConvertedDataValid <= 0;
        else
            case (rNextState)
            State_Idle:
                rConvertedDataValid <= 0;
            default:
                rConvertedDataValid <= 1'b1;
            endcase
    
    always @ (*)
        case (rNextState)
        State_Input:
            rConverterReady <= 1'b1;
        default:
            rConverterReady <= 1'b0;
        endcase
    
    assign oConvertedData = rShiftRegister[InputDataWidth - 1:InputDataWidth-OutputDataWidth];
    assign oConvertedDataValid = rConvertedDataValid;
    assign oConverterReady = rConverterReady;

endmodule
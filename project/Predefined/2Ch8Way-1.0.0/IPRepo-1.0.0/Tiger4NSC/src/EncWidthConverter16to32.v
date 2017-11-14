//////////////////////////////////////////////////////////////////////////////////
// EncWidthConverter16to32.v for Cosmos OpenSSD
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
// Design Name: Data width up converter
// Module Name: EncWidthConverter16to32
// File Name: EncWidthConverter16to32.v
//
// Version: v1.0.0
//
// Description: Data width up converting unit for encoder
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module EncWidthConverter16to32
#
(
    parameter   InputDataWidth  = 16,
    parameter   OutputDataWidth = 32
)
(
    iClock              ,
    iReset              ,
    iCurLoopCount       ,
    iCmdType            ,
    iSrcDataValid       ,
    iSrcDataLast        ,
    iSrcParityLast      ,
    iSrcData            ,
    oConverterReady     ,
    oConvertedDataValid ,
    oConvertedDataLast  ,
    oConvertedParityLast,
    oConvertedData      ,
    iDstReady       
);

    input                           iClock              ;
    input                           iReset              ;
    input                           iCurLoopCount       ;
    input   [1:0]                   iCmdType            ;
    input                           iSrcDataValid       ;
    input                           iSrcDataLast        ;
    input                           iSrcParityLast      ;
    input   [InputDataWidth - 1:0]  iSrcData            ;
    output                          oConverterReady     ;
    output                          oConvertedDataValid ;
    output                          oConvertedDataLast  ;
    output                          oConvertedParityLast;
    output  [OutputDataWidth - 1:0] oConvertedData      ;
    input                           iDstReady           ;
    
    reg     [InputDataWidth - 1:0]  rShiftRegister      ;
    reg     [InputDataWidth - 1:0]  rInputRegister      ;
    reg                             rConvertedDataValid ;
    reg                             rConvertedDataLast  ;
    reg                             rConvertedParityLast;
    
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
            rNextState <= (iSrcDataValid) || ((iCmdType == 2'b10) && (rConvertedParityLast)) ? State_Shift : State_InPause;
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
            rNextState <= (iSrcDataValid) ? State_Shift : State_InPause;
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
            
        endcase
       
    always @ (posedge iClock)
        if (iReset)
            begin
                rInputRegister <= 0;
                rShiftRegister <= 0;
            end
        else
            case (rNextState)
            State_Input:
                begin
                    rInputRegister <= iSrcData;
                    rShiftRegister <= 0;
                end
            State_Shift:
                begin
                    rInputRegister <= iSrcData;
                    rShiftRegister <= rInputRegister;
                end
            State_InPause:
                begin
                    rInputRegister <= rInputRegister;
                    rShiftRegister <= rShiftRegister;
                end
            State_OutPause:
                begin
                    rInputRegister <= rInputRegister;
                    rShiftRegister <= rShiftRegister;
                end
            default:
                begin
                    rInputRegister <= 0;
                    rShiftRegister <= 0;
                end
            endcase
        
    always @ (posedge iClock)
        if (iReset)
            rConvertedDataValid <= 0;
        else
            case (rNextState)
            State_Shift:
                rConvertedDataValid <= 1'b1;
            State_OutPause:
                rConvertedDataValid <= 1'b1;
            default:
                rConvertedDataValid <= 1'b0;
            endcase            
    
    always @ (posedge iClock)
        if (iReset)
            rConvertedParityLast <= 0;
        else
            if (iSrcParityLast)
                rConvertedParityLast <= 1'b1;
            else if (rConvertedParityLast & iDstReady & oConvertedDataValid)
                rConvertedParityLast <= 1'b0;
    
    always @ (posedge iClock)
        if (iReset)
            rConvertedDataLast <= 0;
        else
            rConvertedDataLast <= iSrcDataLast;
    
    assign oConvertedData = {rShiftRegister, rInputRegister};
    assign oConvertedDataValid = rConvertedDataValid;
    assign oConverterReady = !(rNextState == State_OutPause);
    assign oConvertedParityLast =   (iCmdType == 2'b10) ? rConvertedParityLast & iDstReady & oConvertedDataValid : 
                                    (iCurLoopCount)     ? rConvertedParityLast : iSrcParityLast;
    assign oConvertedDataLast = rConvertedDataLast;

endmodule
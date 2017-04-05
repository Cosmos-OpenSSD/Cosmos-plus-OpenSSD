//////////////////////////////////////////////////////////////////////////////////
// NPCG_Toggle_bCMD_IDLE for Cosmos OpenSSD
// Copyright (c) 2015 Hanyang University ENC Lab.
// Contributed by Ilyong Jung <iyjung@enc.hanyang.ac.kr>
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
// Engineer: Ilyong Jung <iyjung@enc.hanyang.ac.kr>
// 
// Project Name: Cosmos OpenSSD
// Design Name: NPCG_Toggle_bCMD_IDLE
// Module Name: NPCG_Toggle_bCMD_IDLE
// File Name: NPCG_Toggle_bCMD_IDLE.v
//
// Version: v1.0.0
//
// Description: Idle execution FSM
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module NPCG_Toggle_bCMD_IDLE
#
(
    parameter NumberOfWays    =   4
)
(
    oWriteReady             ,
    oReadData               ,
    oReadLast               ,
    oReadValid              ,
    oPM_PCommand            ,
    oPM_PCommandOption      ,
    oPM_TargetWay           ,
    oPM_NumOfData           ,
    oPM_CASelect            ,
    oPM_CAData              ,
    oPM_WriteData           ,
    oPM_WriteLast           ,
    oPM_WriteValid          ,
    oPM_ReadReady           
);
    output                          oWriteReady             ;
    output  [31:0]                  oReadData               ;
    output                          oReadLast               ;
    output                          oReadValid              ;
    output  [7:0]                   oPM_PCommand            ;
    output  [2:0]                   oPM_PCommandOption      ;
    output  [NumberOfWays - 1:0]    oPM_TargetWay           ;
    output  [15:0]                  oPM_NumOfData           ;
    output                          oPM_CASelect            ;
    output  [7:0]                   oPM_CAData              ;
    output  [31:0]                  oPM_WriteData           ;
    output                          oPM_WriteLast           ;
    output                          oPM_WriteValid          ;
    output                          oPM_ReadReady           ;
    
    // Output
    // Dispatcher Interface
    //  - Data Write Channel
    assign oWriteReady = 1'b0;
    
    //  - Data Read Channel
    assign oReadData[31:0] = 32'h6789_ABCD;
    assign oReadLast = 1'b0;
    assign oReadValid = 1'b0;
    
    // NPCG_Toggle Interface
    assign oPM_PCommand[7:0] = 8'b0000_0000;
    assign oPM_PCommandOption[2:0] = 3'b000;
    assign oPM_TargetWay[NumberOfWays - 1:0] = 4'b0000;
    assign oPM_NumOfData[15:0] = 16'h1234;
    
    assign oPM_CASelect = 1'b0;
    assign oPM_CAData[7:0] = 8'hCC;
    
    assign oPM_WriteData[31:0] = 32'h6789_ABCD;
    assign oPM_WriteLast = 1'b0;
    assign oPM_WriteValid = 1'b0;
    
    assign oPM_ReadReady = 1'b0;
    
endmodule

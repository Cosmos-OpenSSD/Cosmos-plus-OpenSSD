//////////////////////////////////////////////////////////////////////////////////
// NPCG_Toggle_SCC_PI_reset for Cosmos OpenSSD
// Copyright (c) 2015 Hanyang University ENC Lab.
// Contributed by Kibin Park <kbpark@enc.hanyang.ac.kr>
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
// Engineer: Kibin Park <kbpark@enc.hanyang.ac.kr>
// 
// Project Name: Cosmos OpenSSD
// Design Name: NPCG_Toggle_SCC_PI_reset
// Module Name: NPCG_Toggle_SCC_PI_reset
// File Name: NPCG_Toggle_SCC_PI_reset.v
//
// Version: v1.0.0
//
// Description: NFC phy input module reset
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module NPCG_Toggle_SCC_PI_reset
#
(
    parameter NumberOfWays    =   4
)
(
    iSystemClock,
    iReset      ,
    iOpcode     ,
    iTargetID   ,
    iSourceID   ,
    iCMDValid   ,
    oCMDReady   ,
    oStart      ,
    oLastStep   ,
    iPM_Ready   ,
    iPM_LastStep,
    oPM_PCommand
);
    input           iSystemClock    ;
    input           iReset          ;
    input   [5:0]   iOpcode         ;
    input   [4:0]   iTargetID       ;
    input   [4:0]   iSourceID       ;
    input           iCMDValid       ;
    output          oCMDReady       ;
    output          oStart          ;
    output          oLastStep       ;
    input   [7:0]   iPM_Ready       ;
    input   [7:0]   iPM_LastStep    ;
    output  [7:0]   oPM_PCommand    ;

    wire            wModuleTriggered;

    localparam  State_Idle          = 3'b000;
    localparam  State_PIResetIssue  = 3'b001;
    localparam  State_PIWait        = 3'b011;
    reg [2:0]   rCurState   ;
    reg [2:0]   rNextState  ;
    
    wire wPIResetTrig;

    always @ (posedge iSystemClock)
        if (iReset)
            rCurState <= State_Idle;
        else
            rCurState <= rNextState;

    always @ (*)
        case (rCurState)
        State_Idle:
            rNextState <= (wModuleTriggered)?State_PIResetIssue:State_Idle;
        State_PIResetIssue:
            rNextState <= (iPM_Ready)?State_PIWait:State_PIResetIssue;
        State_PIWait:
            rNextState <= (oLastStep)?State_Idle:State_PIWait;
        default:
            rNextState <= State_Idle;
        endcase
    
    assign wModuleTriggered     = (iCMDValid && iTargetID == 5'b00101 && iOpcode == 6'b110010);
    assign oCMDReady            = (rCurState == State_Idle);
    
    assign wPIResetTrig         = (rCurState == State_PIResetIssue);
    
    assign oStart               = wModuleTriggered;
    assign oLastStep            = (rCurState == State_PIWait) & iPM_LastStep[4];
    
    assign oPM_PCommand[7:0]    = {1'b0, 1'b0, 1'b0, wPIResetTrig, 1'b0, 1'b0, 1'b0, 1'b0};


endmodule

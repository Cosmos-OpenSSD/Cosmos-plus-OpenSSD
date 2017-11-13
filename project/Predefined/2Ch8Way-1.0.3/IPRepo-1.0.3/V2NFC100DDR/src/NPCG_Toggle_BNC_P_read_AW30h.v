//////////////////////////////////////////////////////////////////////////////////
// NPCG_Toggle_BNC_P_read_AW30h for Cosmos OpenSSD
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
// Design Name: NPCG_Toggle_BNC_P_read_AW30h
// Module Name: NPCG_Toggle_BNC_P_read_AW30h
// File Name: NPCG_Toggle_BNC_P_read_AW30h.v
//
// Version: v1.0.0
//
// Description: Page read trigger FSM
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module NPCG_Toggle_BNC_P_read_AW30h
#
(
    parameter NumberOfWays    =   4
)
(
    iSystemClock        ,
    iReset              ,
    iOpcode             ,
    iTargetID           ,
    iSourceID           ,
    iCMDValid           ,
    oCMDReady           ,
    iWaySelect          ,
    iColAddress         ,
    iRowAddress         ,
    oStart              ,
    oLastStep           ,
    iPM_Ready           ,
    iPM_LastStep        ,
    oPM_PCommand        ,
    oPM_PCommandOption  ,
    oPM_TargetWay       ,
    oPM_NumOfData       ,
    oPM_CASelect        ,
    oPM_CAData       
);
    input                           iSystemClock            ;
    input                           iReset                  ;
    input   [5:0]                   iOpcode                 ;
    input   [4:0]                   iTargetID               ;
    input   [4:0]                   iSourceID               ;
    input                           iCMDValid               ;
    output                          oCMDReady               ;
    input   [NumberOfWays - 1:0]    iWaySelect              ;
    input   [15:0]                  iColAddress             ;
    input   [23:0]                  iRowAddress             ;
    output                          oStart                  ;
    output                          oLastStep               ;
    input   [7:0]                   iPM_Ready               ;
    input   [7:0]                   iPM_LastStep            ;
    output  [7:0]                   oPM_PCommand            ;
    output  [2:0]                   oPM_PCommandOption      ;
    output  [NumberOfWays - 1:0]    oPM_TargetWay           ;
    output  [15:0]                  oPM_NumOfData           ;
    output                          oPM_CASelect            ;
    output  [7:0]                   oPM_CAData              ;

    reg [NumberOfWays - 1:0]    rTargetWay  ;
    reg [15:0]                  rColAddress ;
    reg [23:0]                  rRowAddress ;
    wire                        wModuleTriggered;
    wire                        wTMStart    ;
    
    reg [7:0]                   rPMTrigger  ;
    reg [2:0]                   rPCommandOption ;
    reg [15:0]                  rNumOfData  ;
    
    reg [7:0]                   rCAData     ;
    reg                         rPMCommandOrAddress ;

    localparam  State_Idle          = 4'b0000   ;
    localparam  State_NCALIssue     = 4'b0001   ;
    localparam  State_NCmdWrite0    = 4'b0011   ;
    localparam  State_NAddrWrite0   = 4'b0010   ;
    localparam  State_NAddrWrite1   = 4'b0110   ;
    localparam  State_NAddrWrite2   = 4'b0111   ;
    localparam  State_NAddrWrite3   = 4'b0101   ;
    localparam  State_NAddrWrite4   = 4'b0100   ;
    localparam  State_NCmdWrite1    = 4'b1100   ;
    localparam  State_NTMIssue      = 4'b1101   ;
    localparam  State_WaitDone      = 4'b1111   ;
    reg [3:0]   rCurState   ;
    reg [3:0]   rNextState  ;

    always @ (posedge iSystemClock)
        if (iReset)
            rCurState <= State_Idle;
        else
            rCurState <= rNextState;

    always @ (*)
        case (rCurState)
        State_Idle:
            rNextState <= (wModuleTriggered)?State_NCALIssue:State_Idle;
        State_NCALIssue:
            rNextState <= (iPM_Ready)?State_NCmdWrite0:State_NCALIssue;
        State_NCmdWrite0:
            rNextState <= State_NAddrWrite0;
        State_NAddrWrite0:
            rNextState <= State_NAddrWrite1;
        State_NAddrWrite1:
            rNextState <= State_NAddrWrite2;
        State_NAddrWrite2:
            rNextState <= State_NAddrWrite3;
        State_NAddrWrite3:
            rNextState <= State_NAddrWrite4;
        State_NAddrWrite4:
            rNextState <= State_NCmdWrite1;
        State_NCmdWrite1:
            rNextState <= State_NTMIssue;
        State_NTMIssue:
            rNextState <= (wTMStart)?State_WaitDone:State_NTMIssue;
        State_WaitDone:
            rNextState <= (oLastStep)?State_Idle:State_WaitDone;
        default:
            rNextState <= State_Idle;
        endcase
    
    assign wModuleTriggered = (iCMDValid && iTargetID == 5'b00101 && iOpcode == 6'b000000);
    assign wTMStart = (rCurState == State_NTMIssue) & iPM_LastStep[3];
    assign oCMDReady = (rCurState == State_Idle);
    
    always @ (posedge iSystemClock)
        if (iReset)
        begin
            rTargetWay <= {(NumberOfWays){1'b0}};
            rColAddress <= 16'b0;
            rRowAddress <= 24'b0;
        end
        else
            if (wModuleTriggered && (rCurState == State_Idle))
            begin
                rTargetWay  <= iWaySelect   ;
                rColAddress <= iColAddress  ;
                rRowAddress <= iRowAddress  ;
            end
    
    always @ (*)
        case (rCurState)
        State_NCALIssue:
            rPMTrigger <= 8'b00001000;
        State_NTMIssue:
            rPMTrigger <= 8'b00000001;
        default:
            rPMTrigger <= 0;
        endcase
    
    always @ (*)
        case (rCurState)
        State_NTMIssue:
            rPCommandOption[2:0] <= 3'b110;
        default:
            rPCommandOption[2:0] <= 0;
        endcase
    
    always @ (*)
        case (rCurState)
        State_NCALIssue:
            rNumOfData[15:0] <= 16'd6; // 1 cmd + 5 addr + 1 cmd = 7 (=> 6)
        State_NTMIssue:
            rNumOfData[15:0] <= 16'd3; // 40 ns
        default:
            rNumOfData[15:0] <= 0;
        endcase
    
    always @ (*)
        case (rCurState)
        State_NCmdWrite0:
            rPMCommandOrAddress <= 1'b0;
        State_NCmdWrite1:
            rPMCommandOrAddress <= 1'b0;
        State_NAddrWrite0:
            rPMCommandOrAddress <= 1'b1;
        State_NAddrWrite1:
            rPMCommandOrAddress <= 1'b1;
        State_NAddrWrite2:
            rPMCommandOrAddress <= 1'b1;
        State_NAddrWrite3:
            rPMCommandOrAddress <= 1'b1;
        State_NAddrWrite4:
            rPMCommandOrAddress <= 1'b1;
        default:
            rPMCommandOrAddress <= 1'b0;
        endcase
    
    always @ (posedge iSystemClock)
        if (iReset)
            rCAData <= 0;
        else
            case (rNextState)
            State_NCmdWrite0:
                rCAData <= 8'h00;
            State_NAddrWrite0:
                rCAData <= rColAddress[7:0];
            State_NAddrWrite1:
                rCAData <= rColAddress[15:8];
            State_NAddrWrite2:
                rCAData <= rRowAddress[7:0];
            State_NAddrWrite3:
                rCAData <= rRowAddress[15:8];
            State_NAddrWrite4:
                rCAData <= rRowAddress[23:16];
            State_NCmdWrite1:
                rCAData <= 8'h30;
            default:
                rCAData <= 0;
            endcase
    
    assign oStart = wModuleTriggered;
    assign oLastStep            = (rCurState == State_WaitDone) & iPM_LastStep[0];

    assign oPM_PCommand         = rPMTrigger;
    assign oPM_PCommandOption   = rPCommandOption;//1'b0;
    assign oPM_TargetWay        = rTargetWay;
    assign oPM_NumOfData        = rNumOfData; //16'd6;
    assign oPM_CASelect         = rPMCommandOrAddress;
    assign oPM_CAData           = rCAData;

endmodule

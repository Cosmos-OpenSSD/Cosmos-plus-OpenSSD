//////////////////////////////////////////////////////////////////////////////////
// NPCG_Toggle_bCMD_manager for Cosmos OpenSSD
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
// Design Name: NPCG_Toggle_bCMD_manager
// Module Name: NPCG_Toggle_bCMD_manager
// File Name: NPCG_Toggle_bCMD_manager.v
//
// Version: v1.0.0
//
// Description: NFC PCG layer command manager
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module NPCG_Toggle_bCMD_manager
#
(
    parameter NumberOfWays    =   4
)
(
    iSystemClock        ,
    iReset              ,
    iTargetWay          ,
    ibCMDStart          ,
    ibCMDLast           ,
    ibCMDLast_SCC       ,
    iNANDPOE            ,
    iCMDHold            ,
    iOpcode             ,
    iTargetID           ,
    iSourceID           ,
    oOpcode_out         ,
    oTargetID_out       ,
    oSourceID_out       ,
    iCMDValid_in        ,
    oCMDValid_out_NPOE  ,
    oCMDValid_out       ,
    oCMDReady_out       ,
    iCMDReady_in        ,
    oWorkingWay    
);
    input                           iSystemClock            ;
    input                           iReset                  ;
    input   [NumberOfWays - 1:0]    iTargetWay              ;
    input                           ibCMDStart              ;
    input                           ibCMDLast               ;
    input                           ibCMDLast_SCC           ;
    input                           iNANDPOE                ;
    input                           iCMDHold                ;
    input   [5:0]                   iOpcode                 ;
    input   [4:0]                   iTargetID               ;
    input   [4:0]                   iSourceID               ;
    output  [5:0]                   oOpcode_out             ;
    output  [4:0]                   oTargetID_out           ;
    output  [4:0]                   oSourceID_out           ;
    input                           iCMDValid_in            ;
    output                          oCMDValid_out_NPOE      ;
    output                          oCMDValid_out           ;
    output                          oCMDReady_out           ;
    input                           iCMDReady_in            ;
    output  [NumberOfWays - 1:0]    oWorkingWay             ;
    
    // FSM Parameters/Wires/Regs
    parameter MNG_FSM_BIT = 5; // MaNaGer
    parameter MNG_RESET = 5'b00001;
    parameter MNG_READY = 5'b00010; // Ready
    parameter MNG_START = 5'b00100; // Blocking command start
    parameter MNG_RUNNG = 5'b01000; // Blocking command running
    parameter MNG_bH_Zd = 5'b10000; // Bus high-Z delay
    
    reg     [MNG_FSM_BIT-1:0]       rMNG_cur_state          ;
    reg     [MNG_FSM_BIT-1:0]       rMNG_nxt_state          ;
    
    
    
    // Internal Wires/Regs
    reg     [3:0]                   rbH_ZdCounter           ;
    wire                            wbH_ZdDone              ;
    
    reg     [NumberOfWays - 1:0]    rWorkingWay             ;
    reg                             rCMDBlocking            ;
    
    
    
    // Control Signals
    assign wbH_ZdDone = (rbH_ZdCounter[3:0] == 4'b0100);
    
    
    
    // FSM: MaNaGer (MNG)
    // update current state to next state
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rMNG_cur_state <= MNG_RESET;
        end else begin
            rMNG_cur_state <= rMNG_nxt_state;
        end
    end
    
    // deside next state
    always @ ( * ) begin
        case (rMNG_cur_state)
            MNG_RESET: begin
                rMNG_nxt_state <= MNG_READY;
            end
            MNG_READY: begin
                rMNG_nxt_state <= (ibCMDStart)? MNG_START:MNG_READY;
            end
            MNG_START: begin
                rMNG_nxt_state <= (ibCMDLast)? ((ibCMDLast_SCC)? MNG_READY:MNG_bH_Zd):MNG_RUNNG;
            end
            MNG_RUNNG: begin
                rMNG_nxt_state <= (ibCMDLast)? ((ibCMDLast_SCC)? MNG_READY:MNG_bH_Zd):MNG_RUNNG;
            end
            MNG_bH_Zd: begin
                rMNG_nxt_state <= (wbH_ZdDone)? MNG_READY:MNG_bH_Zd;
            end
            default:
                rMNG_nxt_state <= MNG_READY;
        endcase
    end
    
    // state behaviour
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rWorkingWay[NumberOfWays - 1:0] <= 0;
            rCMDBlocking                    <= 0;
            
            rbH_ZdCounter[3:0]              <= 0;
        end else begin
            case (rMNG_nxt_state)
                MNG_RESET: begin
                    rWorkingWay[NumberOfWays - 1:0] <= 0;
                    rCMDBlocking                    <= 0;
                    
                    rbH_ZdCounter[3:0]              <= 0;
                end
                MNG_READY: begin
                    rWorkingWay[NumberOfWays - 1:0] <= 0;
                    rCMDBlocking                    <= 0;
                    
                    rbH_ZdCounter[3:0]              <= 0;
                end
                MNG_START: begin
                    rWorkingWay[NumberOfWays - 1:0] <= iTargetWay[NumberOfWays - 1:0];
                    rCMDBlocking                    <= 1'b1;
                    
                    rbH_ZdCounter[3:0]              <= 4'b0000;
                end
                MNG_RUNNG: begin
                    rWorkingWay[NumberOfWays - 1:0] <= rWorkingWay[NumberOfWays - 1:0];
                    rCMDBlocking                    <= 1'b1;
                    
                    rbH_ZdCounter[3:0]              <= 4'b0000;
                end
                MNG_bH_Zd: begin
                    rWorkingWay[NumberOfWays - 1:0] <= rWorkingWay[NumberOfWays - 1:0];
                    rCMDBlocking                    <= 1'b1;
                    
                    rbH_ZdCounter[3:0]              <= rbH_ZdCounter[3:0] + 1'b1;
                end
            endcase
        end
    end
    
    
    
    // Output
    
    assign oCMDValid_out_NPOE   = (~rCMDBlocking) & (iNANDPOE | (iCMDValid_in & (~iNANDPOE)));
    assign oCMDValid_out        = (~rCMDBlocking) & (~iCMDHold) & (iCMDValid_in) & (~iNANDPOE);
    assign oCMDReady_out        = (~rCMDBlocking) & (~iCMDHold) & (iCMDReady_in) & (~iNANDPOE);
    
    assign oOpcode_out[5:0] = (iNANDPOE)? (6'b111110):(iOpcode[5:0]);
    assign oTargetID_out[4:0] = (iNANDPOE)? (5'b00101):(iTargetID[4:0]);
    assign oSourceID_out[4:0] = (iNANDPOE)? (5'b00101):(iSourceID[4:0]);
    
    assign oWorkingWay[NumberOfWays - 1:0] = rWorkingWay[NumberOfWays - 1:0];
    
endmodule

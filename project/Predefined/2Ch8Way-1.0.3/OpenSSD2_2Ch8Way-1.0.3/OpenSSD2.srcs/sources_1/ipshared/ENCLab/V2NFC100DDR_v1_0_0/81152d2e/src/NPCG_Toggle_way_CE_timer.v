//////////////////////////////////////////////////////////////////////////////////
// NPCG_Toggle_way_CE_timer for Cosmos OpenSSD
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
// Design Name: NPCG_Toggle_way_CE_timer
// Module Name: NPCG_Toggle_way_CE_timer
// File Name: NPCG_Toggle_way_CE_timer.v
//
// Version: v1.0.0
//
// Description: Way chip enable timer
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module NPCG_Toggle_way_CE_timer
#
(
    parameter NumberOfWays    =   8
)
(
    iSystemClock    ,
    iReset          ,
    iWorkingWay     ,
    ibCMDLast       ,
    ibCMDLast_SCC   ,
    iTargetWay      ,
    oCMDHold       
);
    input                           iSystemClock            ;
    input                           iReset                  ;
    input   [NumberOfWays - 1:0]    iWorkingWay             ;
    input                           ibCMDLast               ;
    input                           ibCMDLast_SCC           ;
    input   [NumberOfWays - 1:0]    iTargetWay              ;
    output                          oCMDHold                ;
    
    wire                            wWay0_Deasserted        ;
    wire                            wWay1_Deasserted        ;
    wire                            wWay2_Deasserted        ;
    wire                            wWay3_Deasserted        ;
    
    wire                            wWay4_Deasserted        ;
    wire                            wWay5_Deasserted        ;
    wire                            wWay6_Deasserted        ;
    wire                            wWay7_Deasserted        ;
    
    reg     [3:0]                   rWay0_Timer             ;
    reg     [3:0]                   rWay1_Timer             ;
    reg     [3:0]                   rWay2_Timer             ;
    reg     [3:0]                   rWay3_Timer             ;
    
    reg     [3:0]                   rWay4_Timer             ;
    reg     [3:0]                   rWay5_Timer             ;
    reg     [3:0]                   rWay6_Timer             ;
    reg     [3:0]                   rWay7_Timer             ;
    
    wire                            wWay0_Ready             ;
    wire                            wWay1_Ready             ;
    wire                            wWay2_Ready             ;
    wire                            wWay3_Ready             ;
    
    wire                            wWay4_Ready             ;
    wire                            wWay5_Ready             ;
    wire                            wWay6_Ready             ;
    wire                            wWay7_Ready             ;
    
    wire                            wWay0_Targeted          ;
    wire                            wWay1_Targeted          ;
    wire                            wWay2_Targeted          ;
    wire                            wWay3_Targeted          ;
    
    wire                            wWay4_Targeted          ;
    wire                            wWay5_Targeted          ;
    wire                            wWay6_Targeted          ;
    wire                            wWay7_Targeted          ;
    
    
    
    assign wWay0_Deasserted = (~ibCMDLast_SCC) & ibCMDLast & iWorkingWay[0];
    assign wWay1_Deasserted = (~ibCMDLast_SCC) & ibCMDLast & iWorkingWay[1];
    assign wWay2_Deasserted = (~ibCMDLast_SCC) & ibCMDLast & iWorkingWay[2];
    assign wWay3_Deasserted = (~ibCMDLast_SCC) & ibCMDLast & iWorkingWay[3];
    
    assign wWay4_Deasserted = (~ibCMDLast_SCC) & ibCMDLast & iWorkingWay[4];
    assign wWay5_Deasserted = (~ibCMDLast_SCC) & ibCMDLast & iWorkingWay[5];
    assign wWay6_Deasserted = (~ibCMDLast_SCC) & ibCMDLast & iWorkingWay[6];
    assign wWay7_Deasserted = (~ibCMDLast_SCC) & ibCMDLast & iWorkingWay[7];
    
    assign wWay0_Ready = (rWay0_Timer[3:0] == 4'b1110); // 14 cycle -> 140 ns
    assign wWay1_Ready = (rWay1_Timer[3:0] == 4'b1110);
    assign wWay2_Ready = (rWay2_Timer[3:0] == 4'b1110);
    assign wWay3_Ready = (rWay3_Timer[3:0] == 4'b1110);
    
    assign wWay4_Ready = (rWay4_Timer[3:0] == 4'b1110);
    assign wWay5_Ready = (rWay5_Timer[3:0] == 4'b1110);
    assign wWay6_Ready = (rWay6_Timer[3:0] == 4'b1110);
    assign wWay7_Ready = (rWay7_Timer[3:0] == 4'b1110);
    
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rWay0_Timer[3:0] <= 4'b1110;
            rWay1_Timer[3:0] <= 4'b1110;
            rWay2_Timer[3:0] <= 4'b1110;
            rWay3_Timer[3:0] <= 4'b1110;
            rWay4_Timer[3:0] <= 4'b1110;
            rWay5_Timer[3:0] <= 4'b1110;
            rWay6_Timer[3:0] <= 4'b1110;
            rWay7_Timer[3:0] <= 4'b1110;
        end else begin
            rWay0_Timer[3:0] <= (wWay0_Deasserted)? 4'b0000:((wWay0_Ready)? (rWay0_Timer[3:0]):(rWay0_Timer[3:0] + 1'b1));
            rWay1_Timer[3:0] <= (wWay1_Deasserted)? 4'b0000:((wWay1_Ready)? (rWay1_Timer[3:0]):(rWay1_Timer[3:0] + 1'b1));
            rWay2_Timer[3:0] <= (wWay2_Deasserted)? 4'b0000:((wWay2_Ready)? (rWay2_Timer[3:0]):(rWay2_Timer[3:0] + 1'b1));
            rWay3_Timer[3:0] <= (wWay3_Deasserted)? 4'b0000:((wWay3_Ready)? (rWay3_Timer[3:0]):(rWay3_Timer[3:0] + 1'b1));
            rWay4_Timer[3:0] <= (wWay4_Deasserted)? 4'b0000:((wWay4_Ready)? (rWay4_Timer[3:0]):(rWay4_Timer[3:0] + 1'b1));
            rWay5_Timer[3:0] <= (wWay5_Deasserted)? 4'b0000:((wWay5_Ready)? (rWay5_Timer[3:0]):(rWay5_Timer[3:0] + 1'b1));
            rWay6_Timer[3:0] <= (wWay6_Deasserted)? 4'b0000:((wWay6_Ready)? (rWay6_Timer[3:0]):(rWay6_Timer[3:0] + 1'b1));
            rWay7_Timer[3:0] <= (wWay7_Deasserted)? 4'b0000:((wWay7_Ready)? (rWay7_Timer[3:0]):(rWay7_Timer[3:0] + 1'b1));
        end
    end
    
    assign wWay0_Targeted = iTargetWay[0];
    assign wWay1_Targeted = iTargetWay[1];
    assign wWay2_Targeted = iTargetWay[2];
    assign wWay3_Targeted = iTargetWay[3];
    
    assign wWay4_Targeted = iTargetWay[4];
    assign wWay5_Targeted = iTargetWay[5];
    assign wWay6_Targeted = iTargetWay[6];
    assign wWay7_Targeted = iTargetWay[7];
    
    assign oCMDHold =   (wWay0_Targeted & (~wWay0_Ready)) | 
                        (wWay1_Targeted & (~wWay1_Ready)) |
                        (wWay2_Targeted & (~wWay2_Ready)) |
                        (wWay3_Targeted & (~wWay3_Ready)) |
                        (wWay4_Targeted & (~wWay4_Ready)) | 
                        (wWay5_Targeted & (~wWay5_Ready)) |
                        (wWay6_Targeted & (~wWay6_Ready)) |
                        (wWay7_Targeted & (~wWay7_Ready)) ;
    
endmodule

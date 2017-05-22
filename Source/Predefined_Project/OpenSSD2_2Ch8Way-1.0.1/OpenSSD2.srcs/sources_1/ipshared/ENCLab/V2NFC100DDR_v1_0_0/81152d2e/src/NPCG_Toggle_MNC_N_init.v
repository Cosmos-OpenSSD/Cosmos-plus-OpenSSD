//////////////////////////////////////////////////////////////////////////////////
// NPCG_Toggle_MNC_getFT for Cosmos OpenSSD
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
// Design Name: NPCG_Toggle_MNC_getFT
// Module Name: NPCG_Toggle_MNC_getFT
// File Name: NPCG_Toggle_MNC_getFT.v
//
// Version: v1.0.0
//
// Description: Get feature execution FSM
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module NPCG_Toggle_MNC_N_init
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
    input                           iSystemClock        ;
    input                           iReset              ;
    input   [5:0]                   iOpcode             ;
    input   [4:0]                   iTargetID           ;
    input   [4:0]                   iSourceID           ;
    input                           iCMDValid           ;
    output                          oCMDReady           ;
    input   [NumberOfWays - 1:0]    iWaySelect          ;
    output                          oStart              ;
    output                          oLastStep           ;
    input   [7:0]                   iPM_Ready           ;
    input   [7:0]                   iPM_LastStep        ;
    output  [7:0]                   oPM_PCommand        ;
    output  [2:0]                   oPM_PCommandOption  ;
    output  [NumberOfWays - 1:0]    oPM_TargetWay       ;
    output  [15:0]                  oPM_NumOfData       ;
    output                          oPM_CASelect        ;
    output  [7:0]                   oPM_CAData          ;
    
    // FSM Parameters/Wires/Regs
    localparam N_i_FSM_BIT = 6; // NAND initialization
    localparam N_i_RESET = 6'b00_0001;
    localparam N_i_READY = 6'b00_0010;
    localparam N_i_00001 = 6'b00_0100; // capture, CAL start
    localparam N_i_00002 = 6'b00_1000; // CA data
    localparam N_i_00003 = 6'b01_0000; // Timer start ready, Timer Loop
    localparam N_i_00004 = 6'b10_0000; // wait for request done
    
    reg     [N_i_FSM_BIT-1:0]       r_N_i_cur_state         ;
    reg     [N_i_FSM_BIT-1:0]       r_N_i_nxt_state         ;
    
    
    
    // Internal Wires/Regs
    reg     [4:0]                   rSourceID               ;
    
    reg                             rCMDReady               ;
    
    reg     [NumberOfWays - 1:0]    rWaySelect              ;
    
    wire                            wLastStep               ;
    
    reg     [7:0]                   rPM_PCommand            ;
    reg     [2:0]                   rPM_PCommandOption      ;
    reg     [15:0]                  rPM_NumOfData           ;
    
    reg                             rPM_CASelect            ;
    reg     [7:0]                   rPM_CAData              ;
    
    wire                            wPCGStart               ;
    wire                            wCapture                ;
    
    wire                            wPMReady                ;
    
    wire                            wCALReady               ;
    wire                            wCALStart               ;
    wire                            wCALDone                ;
    
    wire                            wTMReady                ;
    wire                            wTMStart                ;
    wire                            wTMDone                 ;
    
    reg     [3:0]                   rTM_counter             ;
    wire                            wTM_LoopDone            ;
    
    
    
    // Control Signals
    // Flow Contorl
    assign wPCGStart = (iOpcode[5:0] == 6'b101100) & (iTargetID[4:0] == 5'b00101) & iCMDValid;
    assign wCapture = (r_N_i_cur_state[N_i_FSM_BIT-1:0] == N_i_READY);
    
    assign wPMReady = (iPM_Ready[5:0] == 6'b111111);
    
    assign wCALReady = wPMReady;
    assign wCALStart = wCALReady & rPM_PCommand[3];
    assign wCALDone = iPM_LastStep[3];
    
    assign wTMReady = wPMReady;
    assign wTMStart = wTMReady & rPM_PCommand[0];
    assign wTMDone = iPM_LastStep[0];
    
    assign wTM_LoopDone = (rTM_counter[3:0] == 4'd10);
    
    assign wLastStep = wTMDone & wTM_LoopDone & (r_N_i_cur_state[N_i_FSM_BIT-1:0] == N_i_00004);
    
    
    
    // FSM: read STatus
    
    // update current state to next state
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            r_N_i_cur_state <= N_i_RESET;
        end else begin
            r_N_i_cur_state <= r_N_i_nxt_state;
        end
    end
    
    // deside next state
    always @ ( * ) begin
        case (r_N_i_cur_state)
        N_i_RESET: begin
            r_N_i_nxt_state <= N_i_READY;
        end
        N_i_READY: begin
            r_N_i_nxt_state <= (wPCGStart)? N_i_00001:N_i_READY;
        end
        N_i_00001: begin
            r_N_i_nxt_state <= (wCALStart)? N_i_00002:N_i_00001;
        end
        N_i_00002: begin
            r_N_i_nxt_state <= N_i_00003;
        end
        N_i_00003: begin
            r_N_i_nxt_state <= (wTM_LoopDone)? N_i_00004:N_i_00003;
        end
        N_i_00004: begin
            r_N_i_nxt_state <= (wLastStep)? N_i_READY:N_i_00004;
        end
        default:
            r_N_i_nxt_state <= N_i_READY;
        endcase
    end
    
    // state behaviour
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rSourceID[4:0]                  <= 0;
            
            rCMDReady                       <= 0;
            
            rWaySelect[NumberOfWays - 1:0]  <= 0;
            
            rPM_PCommand[7:0]               <= 0;
            rPM_PCommandOption[2:0]         <= 0;
            rPM_NumOfData[15:0]             <= 0;
            
            rPM_CASelect                    <= 0;
            rPM_CAData[7:0]                 <= 0;
            
            rTM_counter[3:0]                <= 0;
        end else begin
            case (r_N_i_nxt_state)
                N_i_RESET: begin
                    rSourceID[4:0]                  <= 0;
                    
                    rCMDReady                       <= 0;
                    
                    rWaySelect[NumberOfWays - 1:0]  <= 0;
                    
                    rPM_PCommand[7:0]               <= 0;
                    rPM_PCommandOption[2:0]         <= 0;
                    rPM_NumOfData[15:0]             <= 0;
                    
                    rPM_CASelect                    <= 0;
                    rPM_CAData[7:0]                 <= 0;
                    
                    rTM_counter[3:0]                <= 0;
                end
                N_i_READY: begin
                    rSourceID[4:0]                  <= 0;
                    
                    rCMDReady                       <= 1;
                    
                    rWaySelect[NumberOfWays - 1:0]  <= 0;
                    
                    rPM_PCommand[7:0]               <= 0;
                    rPM_PCommandOption[2:0]         <= 0;
                    rPM_NumOfData[15:0]             <= 0;
                    
                    rPM_CASelect                    <= 0;
                    rPM_CAData[7:0]                 <= 0;
                    
                    rTM_counter[3:0]                <= 0;
                end
                N_i_00001: begin
                    rSourceID[4:0]                  <= (wCapture)? iSourceID[4:0]:rSourceID[4:0];
                    
                    rCMDReady                       <= 0;
                    
                    rWaySelect[NumberOfWays - 1:0]  <= (wCapture)? iWaySelect[NumberOfWays - 1:0]:rWaySelect[NumberOfWays - 1:0];
                    
                    rPM_PCommand[7:0]               <= 8'b0000_1000;
                    rPM_PCommandOption[2:0]         <= 0;
                    rPM_NumOfData[15:0]             <= 15'h0000;
                    
                    rPM_CASelect                    <= 0;
                    rPM_CAData[7:0]                 <= 0;
                    
                    rTM_counter[3:0]                <= 0;
                end
                N_i_00002: begin
                    rSourceID[4:0]                  <= rSourceID[4:0];
                    
                    rCMDReady                       <= 0;
                    
                    rWaySelect[NumberOfWays - 1:0]  <= rWaySelect[NumberOfWays - 1:0];
                    
                    rPM_PCommand[7:0]               <= 0;
                    rPM_PCommandOption[2:0]         <= 0;
                    rPM_NumOfData[15:0]             <= 0;
                    
                    rPM_CASelect                    <= 1'b0;
                    rPM_CAData[7:0]                 <= 8'hFF;
                    
                    rTM_counter[3:0]                <= 4'b0001;
                end
                N_i_00003: begin
                    rSourceID[4:0]                  <= rSourceID[4:0];
                    
                    rCMDReady                       <= 0;
                    
                    rWaySelect[NumberOfWays - 1:0]  <= rWaySelect[NumberOfWays - 1:0];
                    
                    rPM_PCommand[7:0]               <= 8'b0000_0001;
                    rPM_PCommandOption[2:0]         <= 3'b001; // CE on
                    rPM_NumOfData[15:0]             <= 16'd50000; // real condition
                    //rPM_NumOfData[15:0]             <= 16'd5; // test condition
                    
                    rPM_CASelect                    <= 0;
                    rPM_CAData[7:0]                 <= 0;
                    
                    rTM_counter[3:0]                <= (wTMDone)? (rTM_counter[3:0] + 1'b1):(rTM_counter[3:0]);
                end
                N_i_00004: begin
                    rSourceID[4:0]                  <= rSourceID[4:0];
                    
                    rCMDReady                       <= 0;
                    
                    rWaySelect[NumberOfWays - 1:0]  <= rWaySelect[NumberOfWays - 1:0];
                    
                    rPM_PCommand[7:0]               <= 8'b0000_0000;
                    rPM_PCommandOption[2:0]         <= 0;
                    rPM_NumOfData[15:0]             <= 0;
                    
                    rPM_CASelect                    <= 0;
                    rPM_CAData[7:0]                 <= 0;
                    
                    rTM_counter[3:0]                <= rTM_counter[3:0];
                end
            endcase
        end
    end
    
    
    
    // Output
    assign oCMDReady = rCMDReady;
    
    assign oStart = wPCGStart;
    assign oLastStep = wLastStep;
    
    assign oPM_PCommand[7:0] = rPM_PCommand[7:0];
    assign oPM_PCommandOption[2:0] = rPM_PCommandOption[2:0];
    assign oPM_TargetWay[NumberOfWays - 1:0] = rWaySelect[NumberOfWays - 1:0];
    assign oPM_NumOfData[15:0] = rPM_NumOfData[15:0];
    
    assign oPM_CASelect = rPM_CASelect;
    assign oPM_CAData[7:0] = rPM_CAData[7:0];
    
endmodule

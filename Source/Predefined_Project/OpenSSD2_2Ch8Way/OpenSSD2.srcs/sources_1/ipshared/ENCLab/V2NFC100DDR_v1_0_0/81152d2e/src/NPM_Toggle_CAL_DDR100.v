//////////////////////////////////////////////////////////////////////////////////
// NPM_Toggle_CAL_DDR100 for Cosmos OpenSSD
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
// Design Name: NPM_Toggle_CAL_DDR100
// Module Name: NPM_Toggle_CAL_DDR100
// File Name: NPM_Toggle_CAL_DDR100.v
//
// Version: v1.0.0
//
// Description: Toggle NAND command and address output FSM
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module NPM_Toggle_CAL_DDR100
#
(
    parameter NumberOfWays    =   4
)
(
    iSystemClock            ,
    iReset                  ,
    oReady                  ,
    oLastStep               ,
    iStart                  ,
    iTargetWay              ,
    iNumOfData              ,
    iCASelect               ,
    iCAData                 ,
    oPO_DQStrobe            ,
    oPO_DQ                  ,
    oPO_ChipEnable          ,
    oPO_WriteEnable         ,
    oPO_AddressLatchEnable  ,
    oPO_CommandLatchEnable  ,
    oDQSOutEnable           ,
    oDQOutEnable            
);
    input                           iSystemClock            ;
    input                           iReset                  ;
    output                          oReady                  ;
    output                          oLastStep               ;
    input                           iStart                  ;
    input   [NumberOfWays - 1:0]    iTargetWay              ;
    input   [3:0]                   iNumOfData              ;
    input                           iCASelect               ;
    input   [7:0]                   iCAData                 ;
    output  [7:0]                   oPO_DQStrobe            ;
    output  [31:0]                  oPO_DQ                  ;
    output  [2*NumberOfWays - 1:0]  oPO_ChipEnable          ;
    output  [3:0]                   oPO_WriteEnable         ;
    output  [3:0]                   oPO_AddressLatchEnable  ;
    output  [3:0]                   oPO_CommandLatchEnable  ;
    output                          oDQSOutEnable           ;
    output                          oDQOutEnable            ;
    
    // FSM Parameters/Wires/Regs
    localparam CPT_FSM_BIT = 5; // CaPTure
    localparam CPT_RESET = 5'b00001;
    localparam CPT_READY = 5'b00010; // Ready
    localparam CPT_SFRST = 5'b00100; // Command/Address capture: first
    localparam CPT_SLOOP = 5'b01000; // Command/Address capture: loop
    localparam CPT_WAITS = 5'b10000;
    
    reg     [CPT_FSM_BIT-1:0]       rCPT_cur_state          ;
    reg     [CPT_FSM_BIT-1:0]       rCPT_nxt_state          ;
    
    localparam LCH_FSM_BIT = 8; // LatCH with PI buffer reset function
    localparam LCH_RESET = 8'b0000_0001;
    localparam LCH_READY = 8'b0000_0010; // Ready
    localparam LCH_PREST = 8'b0000_0100; // prefaring state
    localparam LCH_WDQSH = 8'b0000_1000; // DQS hold for program operation tWPSTH, wait BRAM buffer
    localparam LCH_ST001 = 8'b0001_0000; // LOOP state 01: 
    localparam LCH_ST002 = 8'b0010_0000; // LOOP state 02: 
    localparam LCH_ST003 = 8'b0100_0000; // LOOP state 03: 
    localparam LCH_ST004 = 8'b1000_0000; // LOOP state 04: 
    
    reg     [LCH_FSM_BIT-1:0]       rLCH_cur_state          ;
    reg     [LCH_FSM_BIT-1:0]       rLCH_nxt_state          ;
    
    
    
    // Internal Wires/Regs
    reg                             rReady                  ;
    reg                             rLastStep               ;
    reg     [3:0]                   rNumOfCommand           ;
    
    reg     [1:0]                   rLCHSubCounter          ;
    reg     [3:0]                   rLCHCounter             ;
    
    reg                             rCABufferWEnable        ;
    reg     [3:0]                   rCABufferWAddr          ;
    
    reg                             rCABufferREnable        ;
    reg     [3:0]                   rCABufferRAddr          ;
    wire                            wCABufferRSelect        ;
    wire    [7:0]                   wCABufferRData          ;
    
    reg                             rCASelect_B             ;
    reg     [7:0]                   rCAData_B               ;
    
    wire    [2*NumberOfWays - 1:0]  wPO_ChipEnable          ;
    
    wire                            wCPTDone                ;
    
    wire                            wtWPSTHStart            ;
    wire                            wtWPSTHDone             ;
    wire                            wLCHLoopDone            ;
    
    reg     [31:0]                  rPO_DQ                  ;
    reg     [2*NumberOfWays - 1:0]  rPO_ChipEnable          ;
    reg     [3:0]                   rPO_WriteEnable         ;
    reg     [3:0]                   rPO_AddressLatchEnable  ;
    reg     [3:0]                   rPO_CommandLatchEnable  ;
    
    reg                             rDQOutEnable            ;
    
    // PI buffer reset
    //reg                             rPI_BUFF_Reset          ;
    //reg                             rPI_BUFF_RE             ;
    //reg                             rPI_BUFF_WE             ;
    reg     [7:0]                   rPO_DQStrobe            ; // tWPSTH
    reg                             rDQSOutEnable           ; // tWPSTH
    
    
    
    // Control Signals
    
    // Target Way Decoder
    assign wPO_ChipEnable = { iTargetWay[NumberOfWays - 1:0], iTargetWay[NumberOfWays - 1:0] };
    
    // Flow Control
    assign wCPTDone = (rCABufferWAddr[3:0] == rNumOfCommand[3:0]);
    
    assign wtWPSTHStart = (rLCHSubCounter[1:0] == 2'b00); 
    assign wtWPSTHDone = (rLCHSubCounter[1:0] == 2'b11);
    assign wLCHLoopDone = (rLCHCounter[3:0] == rNumOfCommand[3:0]);
    
    
    
    // BRAM: Command/Address Buffer
    
    SDPRAM_9A16x9B16
    CABuffer
    (
        .clka(iSystemClock),    // input wire clka
        .ena(rCABufferWEnable),      // input wire ena
        .wea(rCABufferWEnable),      // input wire [0 : 0] wea
        .addra(rCABufferWAddr),  // input wire [3 : 0] addra
        .dina({ iCASelect, iCAData[7:0] }),    // input wire [8 : 0] dina
        .clkb(iSystemClock),    // input wire clkb
        .enb(rCABufferREnable),      // input wire enb
        .addrb(rCABufferRAddr),  // input wire [3 : 0] addrb
        .doutb({ wCABufferRSelect, wCABufferRData[7:0] })  // output wire [8 : 0] doutb
    );
    
    
    
    // FSM: Command/Address CaPTure (CPT)
    
    // update current state to next state
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rCPT_cur_state <= CPT_RESET;
        end else begin
            rCPT_cur_state <= rCPT_nxt_state;
        end
    end
    
    // deside next state
    always @ ( * ) begin
        case (rCPT_cur_state)
            CPT_RESET: begin
                rCPT_nxt_state <= CPT_READY;
            end
            CPT_READY: begin
                rCPT_nxt_state <= (iStart)? CPT_SFRST:CPT_READY;
            end
            CPT_SFRST: begin
                rCPT_nxt_state <= (wCPTDone)? CPT_WAITS:CPT_SLOOP;
            end
            CPT_SLOOP: begin
                rCPT_nxt_state <= (wCPTDone)? CPT_WAITS:CPT_SLOOP;
            end
            CPT_WAITS: begin
                rCPT_nxt_state <= (rLastStep)? ((iStart)? CPT_SFRST:CPT_READY):CPT_WAITS;
            end
            default:
                rCPT_nxt_state <= CPT_READY;
        endcase
    end
    
    // state behaviour
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rCABufferWEnable        <= 0;
            rCABufferWAddr[3:0]     <= 0;
        end else begin
            case (rCPT_nxt_state)
                CPT_RESET: begin
                    rCABufferWEnable        <= 0;
                    rCABufferWAddr[3:0]     <= 0;
                end
                CPT_READY: begin
                    rCABufferWEnable        <= 0;
                    rCABufferWAddr[3:0]     <= 0;
                end
                CPT_SFRST: begin
                    rCABufferWEnable        <= 1;
                    rCABufferWAddr[3:0]     <= 4'b0000;
                end
                CPT_SLOOP: begin
                    rCABufferWEnable        <= 1;
                    rCABufferWAddr[3:0]     <= rCABufferWAddr[3:0] + 1'b1;
                end
                CPT_WAITS: begin
                    rCABufferWEnable        <= 0;
                    rCABufferWAddr[3:0]     <= 0;
                end
            endcase
        end
    end
    
    
    
    // FSM: Command/Address LatCH (LCH) with PI buffer reset function
    
    // update current state to next state
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rLCH_cur_state <= LCH_RESET;
        end else begin
            rLCH_cur_state <= rLCH_nxt_state;
        end
    end
    
    // deside next state
    always @ ( * ) begin
        case (rLCH_cur_state)
            LCH_RESET: begin
                rLCH_nxt_state <= LCH_READY;
            end
            LCH_READY: begin
                rLCH_nxt_state <= (iStart)? LCH_PREST:LCH_READY;
            end
            LCH_PREST: begin
                rLCH_nxt_state <= LCH_WDQSH;
            end
            LCH_WDQSH: begin
                rLCH_nxt_state <= (wtWPSTHDone)? LCH_ST001:LCH_WDQSH;
            end
            LCH_ST001: begin
                rLCH_nxt_state <= LCH_ST002;
            end
            LCH_ST002: begin
                rLCH_nxt_state <= LCH_ST003;
            end
            LCH_ST003: begin
                rLCH_nxt_state <= LCH_ST004;
            end
            LCH_ST004: begin
                rLCH_nxt_state <= (rLastStep)? ((iStart)? LCH_PREST:LCH_READY):LCH_ST001;
            end
            default:
                rLCH_nxt_state <= LCH_READY;
        endcase
    end
    
    // state behaviour
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rReady                          <= 0;
            rLastStep                       <= 0;
            rNumOfCommand[3:0]              <= 0;
            
            rLCHSubCounter[1:0]             <= 0;
            rLCHCounter[3:0]                <= 0;
            
            rCABufferREnable                <= 0;
            rCABufferRAddr[3:0]             <= 0;
            
            rCASelect_B                     <= 0;
            rCAData_B[7:0]                  <= 0;
            
            rPO_DQ[31:0]                    <= 0;
            rPO_ChipEnable                  <= 0;
            rPO_WriteEnable[3:0]            <= 0;
            rPO_AddressLatchEnable[3:0]     <= 0;
            rPO_CommandLatchEnable[3:0]     <= 0;
            
            rDQOutEnable                    <= 0;
            
            // tWPSTH
            rPO_DQStrobe[7:0]               <= 0;
            rDQSOutEnable                   <= 0;
            
        end else begin
            case (rLCH_nxt_state)
                LCH_RESET: begin
                    rReady                          <= 0;
                    rLastStep                       <= 0;
                    rNumOfCommand[3:0]              <= 0;
                    
                    rLCHSubCounter[1:0]             <= 0;
                    rLCHCounter[3:0]                <= 0;
                    
                    rCABufferREnable                <= 0;
                    rCABufferRAddr[3:0]             <= 0;
                    
                    rCASelect_B                     <= 0;
                    rCAData_B[7:0]                  <= 0;
                    
                    rPO_DQ[31:0]                    <= 0;
                    rPO_ChipEnable                  <= 0;
                    rPO_WriteEnable[3:0]            <= 0;
                    rPO_AddressLatchEnable[3:0]     <= 0;
                    rPO_CommandLatchEnable[3:0]     <= 0;
                    
                    rDQOutEnable                    <= 0;
                    
                    // tWPSTH
                    rPO_DQStrobe[7:0]               <= 0;
                    rDQSOutEnable                   <= 0;
                    
                end
                LCH_READY: begin
                    rReady                          <= 1;
                    rLastStep                       <= 0;
                    rNumOfCommand[3:0]              <= 0;
                    
                    rLCHSubCounter[1:0]             <= 0;
                    rLCHCounter[3:0]                <= 0;
                    
                    rCABufferREnable                <= 0;
                    rCABufferRAddr[3:0]             <= 0;
                    
                    rCASelect_B                     <= 0;
                    rCAData_B[7:0]                  <= 0;
                    
                    rPO_DQ[31:0]                    <= 0;
                    rPO_ChipEnable                  <= 0;
                    rPO_WriteEnable[3:0]            <= 0;
                    rPO_AddressLatchEnable[3:0]     <= 0;
                    rPO_CommandLatchEnable[3:0]     <= 0;
                    
                    rDQOutEnable                    <= 0;
                    
                    // tWPSTH
                    rPO_DQStrobe[7:0]               <= 0;
                    rDQSOutEnable                   <= 0;
                    
                end
                LCH_PREST: begin
                    rReady                          <= 0;
                    rLastStep                       <= 0;
                    rNumOfCommand[3:0]              <= iNumOfData[3:0];
                    
                    rLCHSubCounter[1:0]             <= 0;
                    rLCHCounter[3:0]                <= 0;
                    
                    rCABufferREnable                <= 0;
                    rCABufferRAddr[3:0]             <= 0;
                    
                    rCASelect_B                     <= 0;
                    rCAData_B[7:0]                  <= 0;
                    
                    rPO_DQ[31:0]                    <= 0;
                    rPO_ChipEnable                  <= wPO_ChipEnable;
                    rPO_WriteEnable[3:0]            <= 0;
                    rPO_AddressLatchEnable[3:0]     <= 0;
                    rPO_CommandLatchEnable[3:0]     <= 0;
                    
                    rDQOutEnable                    <= 1;
                    
                    // tWPSTH
                    rPO_DQStrobe[7:0]               <= 8'b0000_0000;
                    rDQSOutEnable                   <= 1'b1;
                    
                end
                LCH_WDQSH: begin
                    rReady                          <= 0;
                    rLastStep                       <= 0;
                    rNumOfCommand[3:0]              <= rNumOfCommand[3:0];
                    
                    rLCHSubCounter[1:0]             <= rLCHSubCounter[1:0] + 1'b1;
                    rLCHCounter[3:0]                <= 0;
                    
                    rCABufferREnable                <= 1'b1;
                    rCABufferRAddr[3:0]             <= 4'b0000;
                    
                    rCASelect_B                     <= 0;
                    rCAData_B[7:0]                  <= 0;
                    
                    rPO_DQ[31:0]                    <= 0;
                    rPO_ChipEnable                  <= rPO_ChipEnable;
                    rPO_WriteEnable[3:0]            <= 0;
                    rPO_AddressLatchEnable[3:0]     <= (wtWPSTHStart)? ((iCASelect)? 4'b1111:4'b0000):(rPO_AddressLatchEnable[3:0]);
                    rPO_CommandLatchEnable[3:0]     <= (wtWPSTHStart)? ((iCASelect)? 4'b0000:4'b1111):(rPO_CommandLatchEnable[3:0]);
                    
                    rDQOutEnable                    <= 1;
                    
                    // tWPSTH
                    rPO_DQStrobe[7:0]               <= 8'b0000_0000;
                    rDQSOutEnable                   <= 1'b1;
                end
                LCH_ST001: begin
                    rReady                          <= 0;
                    rLastStep                       <= 0;
                    rNumOfCommand[3:0]              <= rNumOfCommand[3:0];
                    
                    rLCHSubCounter[1:0]             <= rLCHSubCounter[1:0];
                    rLCHCounter[3:0]                <= rCABufferRAddr[3:0];
                    
                    rCABufferREnable                <= 0;
                    rCABufferRAddr[3:0]             <= rCABufferRAddr[3:0];
                    
                    rCASelect_B                     <= wCABufferRSelect;
                    rCAData_B[7:0]                  <= wCABufferRData[7:0];
                    
                    rPO_DQ[31:0]                    <= 0;
                    rPO_ChipEnable                  <= rPO_ChipEnable;
                    rPO_WriteEnable[3:0]            <= 4'b1111;
                    rPO_AddressLatchEnable[3:0]     <= (wCABufferRSelect)? 4'b1111:4'b0000;
                    rPO_CommandLatchEnable[3:0]     <= (wCABufferRSelect)? 4'b0000:4'b1111;
                    
                    rDQOutEnable                    <= 1;
                    
                    // tWPSTH
                    rPO_DQStrobe[7:0]               <= 8'b0000_0000;//8'b1111_1111;
                    rDQSOutEnable                   <= 1'b1;
                    
                end
                LCH_ST002: begin
                    rReady                          <= 0;
                    rLastStep                       <= 0;
                    rNumOfCommand[3:0]              <= rNumOfCommand[3:0];
                    
                    rLCHSubCounter[1:0]             <= rLCHSubCounter[1:0];
                    rLCHCounter[3:0]                <= rLCHCounter[3:0];
                    
                    rCABufferREnable                <= 0;
                    rCABufferRAddr[3:0]             <= rCABufferRAddr[3:0];
                    
                    rCASelect_B                     <= rCASelect_B;
                    rCAData_B[7:0]                  <= rCAData_B[7:0];
                    
                    rPO_DQ[31:0]                    <= { 4{ rCAData_B[7:0] } };
                    rPO_ChipEnable                  <= rPO_ChipEnable;
                    rPO_WriteEnable[3:0]            <= 4'b1111;
                    rPO_AddressLatchEnable[3:0]     <= rPO_AddressLatchEnable[3:0];
                    rPO_CommandLatchEnable[3:0]     <= rPO_CommandLatchEnable[3:0];
                    
                    rDQOutEnable                    <= 1;
                    
                    // tWPSTH
                    rPO_DQStrobe[7:0]               <= 8'b0000_0000;//8'b1111_1111;
                    rDQSOutEnable                   <= 1'b1;
                    
                end
                LCH_ST003: begin
                    rReady                          <= 0;
                    rLastStep                       <= 0;
                    rNumOfCommand[3:0]              <= rNumOfCommand[3:0];
                    
                    rLCHSubCounter[1:0]             <= rLCHSubCounter[1:0];
                    rLCHCounter[3:0]                <= rLCHCounter[3:0];
                    
                    rCABufferREnable                <= ~wLCHLoopDone;
                    rCABufferRAddr[3:0]             <= rCABufferRAddr[3:0] + 1'b1;
                    
                    rCASelect_B                     <= rCASelect_B;
                    rCAData_B[7:0]                  <= rCAData_B[7:0];
                    
                    rPO_DQ[31:0]                    <= { 4{ rCAData_B[7:0] } };
                    rPO_ChipEnable                  <= rPO_ChipEnable;
                    rPO_WriteEnable[3:0]            <= 4'b0000;
                    rPO_AddressLatchEnable[3:0]     <= rPO_AddressLatchEnable[3:0];
                    rPO_CommandLatchEnable[3:0]     <= rPO_CommandLatchEnable[3:0];
                    
                    rDQOutEnable                    <= 1;
                    
                    // tWPSTH
                    rPO_DQStrobe[7:0]               <= 8'b0000_0000;//8'b1111_1111;
                    rDQSOutEnable                   <= 1'b1;
                    
                end
                LCH_ST004: begin
                    rReady                          <= wLCHLoopDone;
                    rLastStep                       <= wLCHLoopDone;
                    rNumOfCommand[3:0]              <= rNumOfCommand[3:0];
                    
                    rLCHSubCounter[1:0]             <= rLCHSubCounter[1:0];
                    rLCHCounter[3:0]                <= rLCHCounter[3:0];
                    
                    rCABufferREnable                <= 0;
                    rCABufferRAddr[3:0]             <= rCABufferRAddr[3:0];
                    
                    rCASelect_B                     <= rCASelect_B;
                    rCAData_B[7:0]                  <= rCAData_B[7:0];
                    
                    rPO_DQ[31:0]                    <= 0;
                    rPO_ChipEnable                  <= rPO_ChipEnable;
                    rPO_WriteEnable[3:0]            <= 4'b0000;
                    rPO_AddressLatchEnable[3:0]     <= rPO_AddressLatchEnable[3:0];
                    rPO_CommandLatchEnable[3:0]     <= rPO_CommandLatchEnable[3:0];
                    
                    rDQOutEnable                    <= 1;
                    
                    // tWPSTH
                    rPO_DQStrobe[7:0]               <= 8'b0000_0000;//8'b1111_1111;
                    rDQSOutEnable                   <= 1'b1;
                    
                end
            endcase
        end
    end
    
    
    
    // Output
    
    assign oReady                   = rReady                ;
    assign oLastStep                = rLastStep             ;
    
    assign oPO_DQ                   = rPO_DQ                ;
    assign oPO_ChipEnable           = rPO_ChipEnable        ;
    assign oPO_WriteEnable          = rPO_WriteEnable       ;
    assign oPO_AddressLatchEnable   = rPO_AddressLatchEnable;
    assign oPO_CommandLatchEnable   = rPO_CommandLatchEnable;
    
    assign oDQOutEnable             = rDQOutEnable          ;
    
    assign oPO_DQStrobe             = rPO_DQStrobe          ; // tWPSTH
    assign oDQSOutEnable            = rDQSOutEnable         ; // tWPSTH
    
endmodule

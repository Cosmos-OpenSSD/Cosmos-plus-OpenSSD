//////////////////////////////////////////////////////////////////////////////////
// NPM_Toggle_DO_tADL_DDR100 for Cosmos OpenSSD
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
// Design Name: NPM_Toggle_DO_tADL_DDR100
// Module Name: NPM_Toggle_DO_tADL_DDR100
// File Name: NPM_Toggle_DO_tADL_DDR100.v
//
// Version: v1.0.0
//
// Description: NFC PM data out FSM
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module NPM_Toggle_DO_tADL_DDR100
#
(
    // support "serial execution"
    
    // Data Packet Width (DQ): 8 bit
    
    // iOption: set SDR/DDR mode
    //          0-SDR(WE#), 1-DDR(DQS)
    
    // NumOfData: 0 means 1
    //            -> unit: word (32 bit = 4 B)
    
    // _tADL.v
    // (original design: tCDQSS = 110 ns, tWPRE = 30 ns)
    //
    // tCDQSS = 250 ns => 25 cycles
    // tWPRE  =  50 ns =>  5 cycles
    
    // future -> add data buffer?
    
    parameter NumberOfWays    =   4
)
(
    iSystemClock            ,
    iReset                  ,
    oReady                  ,
    oLastStep               ,
    iStart                  ,
    iOption                 ,
    iTargetWay              ,
    iWriteData              ,
    iWriteLast              ,
    iWriteValid             ,
    oWriteReady             ,
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
    input                           iOption                 ;
    input   [NumberOfWays - 1:0]    iTargetWay              ;
    input   [31:0]                  iWriteData              ;
    input                           iWriteLast              ;
    input                           iWriteValid             ;
    output                          oWriteReady             ;
    output  [7:0]                   oPO_DQStrobe            ;
    output  [31:0]                  oPO_DQ                  ;
    output  [2*NumberOfWays - 1:0]  oPO_ChipEnable          ;
    output  [3:0]                   oPO_WriteEnable         ;
    output  [3:0]                   oPO_AddressLatchEnable  ;
    output  [3:0]                   oPO_CommandLatchEnable  ;
    output                          oDQSOutEnable           ;
    output                          oDQOutEnable            ;
    
    // FSM Parameters/Wires/Regs
    localparam DTO_FSM_BIT = 9; // DaTa Out
    localparam DTO_RESET = 9'b000_000_001;
    localparam DTO_READY = 9'b000_000_010;
    localparam DTO_DQS01 = 9'b000_000_100; // info. capture, wait state for tCDQSS
    localparam DTO_DQS02 = 9'b000_001_000; // wait state for tCDQSS
    localparam DTO_WPRAM = 9'b000_010_000; // wait state for tWRPE
    localparam DTO_DQOUT = 9'b000_100_000; // DQ out: loop
    localparam DTO_PAUSE = 9'b001_000_000; // pause DQ out
    localparam DTO_DQLST = 9'b010_000_000; // DQ out: last
    localparam DTO_WPSAM = 9'b100_000_000; // wait state for tWPST
    localparam DTO_WPSA2 = 9'b110_000_000; // temp. state: will be removed
    
    reg     [DTO_FSM_BIT-1:0]       rDTO_cur_state          ;
    reg     [DTO_FSM_BIT-1:0]       rDTO_nxt_state          ;
    
    
    
    // Internal Wires/Regs
    reg                             rReady                  ;
    reg                             rLastStep               ;
    
    reg                             rOption                 ;
    
    reg     [4:0]                   rDTOSubCounter          ;
    wire    [2*NumberOfWays - 1:0]  wPO_ChipEnable          ;
    
    wire                            wtCDQSSDone             ;
    wire                            wtWPREDone              ;
    wire                            wLoopDone               ;
    wire                            wtWPSTDone              ;
    
    reg     [7:0]                   rPO_DQStrobe            ;
    reg     [31:0]                  rPO_DQ                  ;
    reg     [2*NumberOfWays - 1:0]  rPO_ChipEnable          ;
    reg     [3:0]                   rPO_WriteEnable         ;
    reg     [3:0]                   rPO_AddressLatchEnable  ;
    reg     [3:0]                   rPO_CommandLatchEnable  ;
    
    reg                             rDQSOutEnable           ;
    reg                             rDQOutEnable            ;
    
    reg                             rStageFlag              ;
    
    
    
    // Control Signals
    
    // Target Way Decoder
    assign wPO_ChipEnable = { iTargetWay[NumberOfWays - 1:0], iTargetWay[NumberOfWays - 1:0] };
    
    // Flow Control
    assign wtCDQSSDone = (rDTOSubCounter[4:0] == 5'd25); // 25 => 250 ns 
    assign wtWPREDone = (rDTOSubCounter[4:0] == 5'd30); // 30 - 25 = 5 => 50 ns
    assign wLoopDone = iWriteLast & iWriteValid;
    assign wtWPSTDone = (rDTOSubCounter[4:0] == 5'd3); // 3 - 0 = 3 => 30 ns, tWPST = 6.5 ns
    
    
    
    // FSM: DaTa Out (DTO)
    
    // update current state to next state
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rDTO_cur_state <= DTO_RESET;
        end else begin
            rDTO_cur_state <= rDTO_nxt_state;
        end
    end
    
    // deside next state
    always @ ( * ) begin
        case (rDTO_cur_state)
            DTO_RESET: begin
                rDTO_nxt_state <= DTO_READY;
            end
            DTO_READY: begin
                rDTO_nxt_state <= (iStart)? DTO_DQS01:DTO_READY;
            end
            DTO_DQS01: begin
                rDTO_nxt_state <= DTO_DQS02;
            end
            DTO_DQS02: begin
                rDTO_nxt_state <= (wtCDQSSDone)? DTO_WPRAM:DTO_DQS02;
            end
            DTO_WPRAM: begin
                rDTO_nxt_state <= (wtWPREDone)? ((iWriteValid)? DTO_DQOUT:DTO_PAUSE):DTO_WPRAM;
            end
            DTO_DQOUT: begin
                rDTO_nxt_state <= (rStageFlag)? (DTO_DQOUT):((wLoopDone)? DTO_DQLST:((iWriteValid)? DTO_DQOUT:DTO_PAUSE));
            end
            DTO_PAUSE: begin
                rDTO_nxt_state <= (wLoopDone)? DTO_DQLST:((iWriteValid)? DTO_DQOUT:DTO_PAUSE);
            end
            DTO_DQLST: begin
                rDTO_nxt_state <= (rStageFlag)? DTO_DQLST:DTO_WPSAM;
            end
            DTO_WPSAM: begin
                rDTO_nxt_state <= (wtWPSTDone)? DTO_WPSA2:DTO_WPSAM;
            end
            DTO_WPSA2: begin
                rDTO_nxt_state <= (iStart)? DTO_DQS01:DTO_READY;
            end
            default:
                rDTO_nxt_state <= DTO_READY;
        endcase
    end
    
    // state behaviour
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rReady                              <= 0;
            rLastStep                           <= 0;
            
            rOption                             <= 0;
            
            rDTOSubCounter[4:0]                 <= 0;
            
            rPO_DQStrobe[7:0]                   <= 8'b1111_1111;
            rPO_DQ[31:0]                        <= 0;
            rPO_ChipEnable                      <= 0;
            rPO_WriteEnable[3:0]                <= 0;
            rPO_AddressLatchEnable[3:0]         <= 0;
            rPO_CommandLatchEnable[3:0]         <= 0;
            
            rDQSOutEnable                       <= 0;
            rDQOutEnable                        <= 0;
            
            rStageFlag                          <= 0;
        end else begin
            case (rDTO_nxt_state)
                DTO_RESET: begin
                    rReady                              <= 0;
                    rLastStep                           <= 0;
                    
                    rOption                             <= 0;
                    
                    rDTOSubCounter[4:0]                 <= 0;
                    
                    rPO_DQStrobe[7:0]                   <= 8'b1111_1111;
                    rPO_DQ[31:0]                        <= 0;
                    rPO_ChipEnable                      <= 0;
                    rPO_WriteEnable[3:0]                <= 0;
                    rPO_AddressLatchEnable[3:0]         <= 0;
                    rPO_CommandLatchEnable[3:0]         <= 0;
                    
                    rDQSOutEnable                       <= 0;
                    rDQOutEnable                        <= 0;
                    
                    rStageFlag                          <= 0;
                end
                DTO_READY: begin
                    rReady                              <= 1;
                    rLastStep                           <= 0;
                    
                    rOption                             <= 0;
                    
                    rDTOSubCounter[4:0]                 <= 0;
                    
                    rPO_DQStrobe[7:0]                   <= 8'b1111_1111;
                    rPO_DQ[31:0]                        <= 0;
                    rPO_ChipEnable                      <= 0;
                    rPO_WriteEnable[3:0]                <= 0;
                    rPO_AddressLatchEnable[3:0]         <= 0;
                    rPO_CommandLatchEnable[3:0]         <= 0;
                    
                    rDQSOutEnable                       <= 0;
                    rDQOutEnable                        <= 0;
                    
                    rStageFlag                          <= 0;
                end
                DTO_DQS01: begin
                    rReady                              <= 0;
                    rLastStep                           <= 0;
                    
                    rOption                             <= iOption;
                    
                    rDTOSubCounter[4:0]                 <= 0;
                    
                    rPO_DQStrobe[7:0]                   <= 8'b1111_1111;
                    rPO_DQ[31:0]                        <= 0;
                    rPO_ChipEnable                      <= wPO_ChipEnable;
                    rPO_WriteEnable[3:0]                <= 4'b0000;
                    rPO_AddressLatchEnable[3:0]         <= 4'b1111;
                    rPO_CommandLatchEnable[3:0]         <= 4'b0000;
                    
                    rDQSOutEnable                       <= (iOption)? 1'b1:1'b0;
                    rDQOutEnable                        <= 1'b1;
                    
                    rStageFlag                          <= 0;
                end
                DTO_DQS02: begin
                    rReady                              <= 0;
                    rLastStep                           <= 0;
                    
                    rOption                             <= rOption;
                    
                    rDTOSubCounter[4:0]                 <= rDTOSubCounter[4:0] + 1'b1;
                    
                    rPO_DQStrobe[7:0]                   <= 8'b1111_1111;
                    rPO_DQ[31:0]                        <= 0;
                    rPO_ChipEnable                      <= rPO_ChipEnable;
                    rPO_WriteEnable[3:0]                <= 4'b0000;
                    rPO_AddressLatchEnable[3:0]         <= 4'b1111;
                    rPO_CommandLatchEnable[3:0]         <= 4'b0000;
                    
                    rDQSOutEnable                       <= (rOption)? 1'b1:1'b0;
                    rDQOutEnable                        <= 1'b1;
                    
                    rStageFlag                          <= 0;
                end
                DTO_WPRAM: begin
                    rReady                              <= 0;
                    rLastStep                           <= 0;
                    
                    rOption                             <= rOption;
                    
                    rDTOSubCounter[4:0]                 <= rDTOSubCounter[4:0] + 1'b1;
                    
                    rPO_DQStrobe[7:0]                   <= 8'b0000_0000;
                    rPO_DQ[31:0]                        <= 0;
                    rPO_ChipEnable                      <= rPO_ChipEnable;
                    rPO_WriteEnable[3:0]                <= (rOption)? 4'b0000:4'b1111;
                    rPO_AddressLatchEnable[3:0]         <= 4'b0000;
                    rPO_CommandLatchEnable[3:0]         <= 4'b0000;
                    
                    rDQSOutEnable                       <= (rOption)? 1'b1:1'b0;
                    rDQOutEnable                        <= 1'b1;
                    
                    rStageFlag                          <= 1'b0;
                end
                DTO_DQOUT: begin
                    rReady                              <= 0;
                    rLastStep                           <= 0;
                    
                    rOption                             <= rOption;
                    
                    rDTOSubCounter[4:0]                 <= rDTOSubCounter[4:0];
                    
                    rPO_DQStrobe[7:0]                   <= 8'b0110_0110;
                    rPO_DQ[31:0]                        <= (rStageFlag)? ({ rPO_DQ[31:16], rPO_DQ[31:16] }):iWriteData[31:0];
                    rPO_ChipEnable                      <= rPO_ChipEnable;
                    rPO_WriteEnable[3:0]                <= (rOption)? 4'b0000:4'b1001;
                    rPO_AddressLatchEnable[3:0]         <= 4'b0000;
                    rPO_CommandLatchEnable[3:0]         <= 4'b0000;
                    
                    rDQSOutEnable                       <= (rOption)? 1'b1:1'b0;
                    rDQOutEnable                        <= 1'b1;
                    
                    rStageFlag                          <= (rOption)? ((rStageFlag)? 1'b0:1'b1):1'b0;
                end
                DTO_PAUSE: begin
                    rReady                              <= 0;
                    rLastStep                           <= 0;
                    
                    rOption                             <= rOption;
                    
                    rDTOSubCounter[4:0]                 <= rDTOSubCounter[4:0];
                    
                    rPO_DQStrobe[7:0]                   <= 8'b0000_0000;
                    rPO_DQ[31:0]                        <= { 4{rPO_DQ[31:24]} };
                    rPO_ChipEnable                      <= rPO_ChipEnable;
                    rPO_WriteEnable[3:0]                <= (rOption)? 4'b0000:4'b1111;
                    rPO_AddressLatchEnable[3:0]         <= 4'b0000;
                    rPO_CommandLatchEnable[3:0]         <= 4'b0000;
                    
                    rDQSOutEnable                       <= (rOption)? 1'b1:1'b0;
                    rDQOutEnable                        <= 1'b1;
                    
                    rStageFlag                          <= 1'b0;
                end
                DTO_DQLST: begin
                    rReady                              <= 0;
                    rLastStep                           <= 0;
                    
                    rOption                             <= rOption;
                    
                    rDTOSubCounter[4:0]                 <= 0;
                    
                    rPO_DQStrobe[7:0]                   <= 8'b0110_0110;
                    rPO_DQ[31:0]                        <= (rStageFlag)? ({ rPO_DQ[31:16], rPO_DQ[31:16] }):iWriteData[31:0];
                    rPO_ChipEnable                      <= rPO_ChipEnable;
                    rPO_WriteEnable[3:0]                <= (rOption)? 4'b0000:4'b0001;
                    rPO_AddressLatchEnable[3:0]         <= 4'b0000;
                    rPO_CommandLatchEnable[3:0]         <= 4'b0000;
                    
                    rDQSOutEnable                       <= (rOption)? 1'b1:1'b0;
                    rDQOutEnable                        <= 1'b1;
                    
                    rStageFlag                          <= (rOption)? ((rStageFlag)? 1'b0:1'b1):1'b0;
                end
                DTO_WPSAM: begin
                    rReady                              <= 0;
                    rLastStep                           <= 0;
                    
                    rOption                             <= rOption;
                    
                    rDTOSubCounter[4:0]                 <= rDTOSubCounter[4:0] + 1'b1;
                    
                    rPO_DQStrobe[7:0]                   <= 8'b0000_0000;
                    rPO_DQ[31:0]                        <= 0;
                    rPO_ChipEnable                      <= rPO_ChipEnable;
                    rPO_WriteEnable[3:0]                <= 4'b0000;
                    rPO_AddressLatchEnable[3:0]         <= 4'b0000;
                    rPO_CommandLatchEnable[3:0]         <= 4'b0000;
                    
                    rDQSOutEnable                       <= (rOption)? 1'b1:1'b0;
                    rDQOutEnable                        <= 1'b0;
                    
                    rStageFlag                          <= 1'b0;
                end
                DTO_WPSA2: begin
                    rReady                              <= 1;
                    rLastStep                           <= 1;
                    
                    rOption                             <= rOption;
                    
                    rDTOSubCounter[4:0]                 <= rDTOSubCounter[4:0];
                    
                    rPO_DQStrobe[7:0]                   <= 8'b0000_0000;
                    rPO_DQ[31:0]                        <= 0;
                    rPO_ChipEnable                      <= rPO_ChipEnable;
                    rPO_WriteEnable[3:0]                <= 4'b0000;
                    rPO_AddressLatchEnable[3:0]         <= 4'b0000;
                    rPO_CommandLatchEnable[3:0]         <= 4'b0000;
                    
                    rDQSOutEnable                       <= (rOption)? 1'b1:1'b0;
                    rDQOutEnable                        <= 1'b0;
                    
                    rStageFlag                          <= 1'b0;
                end
            endcase
        end
    end
    
    
    
    // Output
    
    assign oReady               = rReady                ;
    assign oLastStep            = rLastStep             ;
    assign oWriteReady          = wtWPREDone & (~rStageFlag);
    
    assign oPO_DQStrobe         = rPO_DQStrobe          ;
    assign oPO_DQ               = rPO_DQ                ;
    assign oPO_ChipEnable       = rPO_ChipEnable        ;
    assign oPO_WriteEnable      = rPO_WriteEnable       ;
    assign oPO_AddressLatchEnable = rPO_AddressLatchEnable;
    assign oPO_CommandLatchEnable = rPO_CommandLatchEnable;
    
    assign oDQSOutEnable        = rDQSOutEnable         ;
    assign oDQOutEnable         = rDQOutEnable          ;
    
endmodule

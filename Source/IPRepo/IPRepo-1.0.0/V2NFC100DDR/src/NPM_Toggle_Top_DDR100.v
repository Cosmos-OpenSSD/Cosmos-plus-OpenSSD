//////////////////////////////////////////////////////////////////////////////////
// NPM_Toggle_Top_DDR100 for Cosmos OpenSSD
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
// Design Name: NPM_Toggle_Top_DDR100
// Module Name: NPM_Toggle_Top_DDR100
// File Name: NPM_Toggle_Top_DDR100.v
//
// Version: v1.0.0
//
// Description: NFC PM layer top
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module NPM_Toggle_Top_DDR100
#
(
    // iPCommand[7:0]: not support parallel primitive command execution
    //                 must set only 1 bit
    //
    // iPCommand[7]: .......... (reserved)
    // iPCommand[6]: PHY Buffer Reset
    // iPCommand[5]: PO Reset
    // iPCommand[4]: PI Reset
    // iPCommand[3]: C/A Latch
    // iPCommand[2]: Data Out
    // iPCommand[1]: Data In
    // iPCommand[0]: Timer
    
    // iPCommandOption[2:0]  : Timer Option
    // iPCommandOption[0:0]  : Data In Option
    // iPCommandOption[0:0]  : Data Out Option
    
    // iCEHold: turn off: any time, turn on: must be PM is running
    
    // supported PM
    //          internally used
    //                  > IDLE
    //          support serial execution
    //                  > PO Reset, PI Reset, C/A Latch, Data Out, Timer
    //          not support serial execution
    //                  > Data In
    // supported function
    //          > PM execution, CE hold, Data request, Data out, R/B- signal bypass
    
    // not supported PM (future works)
    //          > PI Buffer Reset, PI Trainer
    // not supported function (future works)
    //          > write protection
    
    parameter NumberOfWays    =   4
)
(
    iSystemClock            ,
    iReset                  ,
    oPM_Ready               ,
    oPM_LastStep            ,
    iPCommand               ,
    iPCommandOption         ,
    iTargetWay              ,
    iNumOfData              ,
    iCEHold                 ,
    iNANDPowerOnEvent       ,
    iCASelect               ,
    iCAData                 ,
    iWriteData              ,
    iWriteLast              ,
    iWriteValid             ,
    oWriteReady             ,
    oReadData               ,
    oReadLast               ,
    oReadValid              ,
    iReadReady              ,
    oReadyBusy              ,
    oPI_Reset               ,
    oPI_BUFF_Reset          ,
    oPO_Reset               ,
    oPI_BUFF_RE             ,
    oPI_BUFF_WE             ,
    oPI_BUFF_OutSel         ,
    iPI_BUFF_Empty          ,
    iPI_DQ                  ,
    iPI_ValidFlag           ,
    oPIDelayTapLoad         ,
    oPIDelayTap             ,
    iPIDelayReady           ,
    oPO_DQStrobe            ,
    oPO_DQ                  ,
    oPO_ChipEnable          ,
    oPO_ReadEnable          ,
    oPO_WriteEnable         ,
    oPO_AddressLatchEnable  ,
    oPO_CommandLatchEnable  ,
    iReadyBusy              ,
    oWriteProtect           ,
    oDQSOutEnable           ,
    oDQOutEnable
);
    input                           iSystemClock            ;
    input                           iReset                  ;
    output  [7:0]                   oPM_Ready               ;
    output  [7:0]                   oPM_LastStep            ;
    input   [7:0]                   iPCommand               ;
    input   [2:0]                   iPCommandOption         ;
    input   [NumberOfWays - 1:0]    iTargetWay              ;
    input   [15:0]                  iNumOfData              ;
    input                           iCEHold                 ;
    input                           iNANDPowerOnEvent       ;
    input                           iCASelect               ;
    input   [7:0]                   iCAData                 ;
    input   [31:0]                  iWriteData              ;
    input                           iWriteLast              ;
    input                           iWriteValid             ;
    output                          oWriteReady             ;
    output  [31:0]                  oReadData               ;
    output                          oReadLast               ;
    output                          oReadValid              ;
    input                           iReadReady              ;
    output  [NumberOfWays - 1:0]    oReadyBusy              ;
    output                          oPI_Reset               ;
    output                          oPI_BUFF_Reset          ;
    output                          oPO_Reset               ;
    output                          oPI_BUFF_RE             ;
    output                          oPI_BUFF_WE             ;
    output  [2:0]                   oPI_BUFF_OutSel         ;
    input                           iPI_BUFF_Empty          ;
    input   [31:0]                  iPI_DQ                  ;
    input   [3:0]                   iPI_ValidFlag           ;
    output                          oPIDelayTapLoad         ;
    output  [4:0]                   oPIDelayTap             ;
    input                           iPIDelayReady           ;
    output  [7:0]                   oPO_DQStrobe            ;
    output  [31:0]                  oPO_DQ                  ;
    output  [2*NumberOfWays - 1:0]  oPO_ChipEnable          ;
    output  [3:0]                   oPO_ReadEnable          ;
    output  [3:0]                   oPO_WriteEnable         ;
    output  [3:0]                   oPO_AddressLatchEnable  ;
    output  [3:0]                   oPO_CommandLatchEnable  ;
    input   [NumberOfWays - 1:0]    iReadyBusy              ;
    output                          oWriteProtect           ;
    output                          oDQSOutEnable           ;
    output                          oDQOutEnable            ;
    
    // FSM Parameters/Wires/Regs
    parameter PMC_FSM_BIT = 4; // P.M. Control
    parameter PMC_RESET = 4'b0001;
    parameter PMC_HOLD = 4'b0010;
    parameter PMC_ON = 4'b0100;
    parameter PMC_OFF = 4'b1000;
    
    reg     [PMC_FSM_BIT-1:0]       r_PMC_cur_state         ;
    reg     [PMC_FSM_BIT-1:0]       r_PMC_nxt_state         ;
    
    parameter CEH_FSM_BIT = 3; // CE Hold control
    parameter CEH_RESET = 3'b001;
    parameter CEH_HOLD = 3'b010;
    parameter CEH_UPDT = 3'b100;
    
    reg     [CEH_FSM_BIT-1:0]       r_CEH_cur_state         ;
    reg     [CEH_FSM_BIT-1:0]       r_CEH_nxt_state         ;
    
    
    
    // Internal Wires/Regs
    reg     [7:0]                   rPCommand               ;
    
    reg                             rCEHold                 ;
    reg     [2*NumberOfWays - 1:0]  rCEHold_PO_ChipEnable   ;
    
    wire                            wPCommandStrobe         ;
    wire                            wPM_LastStep            ;
    wire                            wPM_End                 ;
    wire                            wPM_Start               ;
    //wire                            wPMStartOrEnd           ;
    reg                             rPM_ONOFF               ;
    wire                            wPM_disable             ;
    
    //  - State Machine: PO Reset
    wire                            wPOR_Reset              ;
    
    wire                            wPOR_Ready              ;
    wire                            wPOR_LastStep           ;
    wire                            wPOR_Start              ;
    
    wire                            wPOR_PO_Reset           ;
    
    //  - State Machine: PI Reset
    wire                            wPIR_Reset              ;
    
    wire                            wPIR_Ready              ;
    wire                            wPIR_LastStep           ;
    wire                            wPIR_Start              ;
    
    wire                            wPIR_PI_Reset           ;
    
    wire                            wPIR_PIDelayReady       ;
    
    //  - State Machine: PHY Buffer Reset
    wire                            wPBR_Reset              ;
    
    wire                            wPBR_Ready              ;
    wire                            wPBR_LastStep           ;
    wire                            wPBR_Start              ;
    
    wire                            wPBR_PI_BUFF_Reset      ; // PI buffer reset
    wire                            wPBR_PI_BUFF_RE         ; // PI buffer reset
    wire                            wPBR_PI_BUFF_WE         ; // PI buffer reset
    wire    [7:0]                   wPBR_PO_DQStrobe        ; // PI buffer reset
    wire                            wPBR_DQSOutEnable       ; // PI buffer reset
    
    //  - State Machine: PI Trainer
    // ..
    
    //  - State Machine: IDLE
    wire                            wIDLE_PI_Reset          ;
    wire                            wIDLE_PI_BUFF_Reset     ;
    wire                            wIDLE_PO_Reset          ;
    wire                            wIDLE_PI_BUFF_RE        ;
    wire                            wIDLE_PI_BUFF_WE        ;
    wire    [2:0]                   wIDLE_PI_BUFF_OutSel    ;
    wire                            wIDLE_PIDelayTapLoad    ;
    wire    [4:0]                   wIDLE_PIDelayTap        ;
    wire    [7:0]                   wIDLE_PO_DQStrobe       ;
    wire    [31:0]                  wIDLE_PO_DQ             ;
    wire    [2*NumberOfWays - 1:0]  wIDLE_PO_ChipEnable     ;
    wire    [3:0]                   wIDLE_PO_ReadEnable     ;
    wire    [3:0]                   wIDLE_PO_WriteEnable    ;
    wire    [3:0]                   wIDLE_PO_AddressLatchEnable;
    wire    [3:0]                   wIDLE_PO_CommandLatchEnable;
    wire                            wIDLE_DQSOutEnable      ;
    wire                            wIDLE_DQOutEnable       ;
    
    //  - State Machine: Command/Address Latch
    wire                            wCAL_Reset              ;
    
    wire                            wCAL_Ready              ;
    wire                            wCAL_LastStep           ;
    wire                            wCAL_Start              ;
    wire    [NumberOfWays - 1:0]    wCAL_TargetWay          ;
    wire    [3:0]                   wCAL_NumOfData          ;
    wire                            wCAL_CASelect           ;
    wire    [7:0]                   wCAL_CAData             ;
    
    wire    [7:0]                   wCAL_PO_DQStrobe        ;
    wire    [31:0]                  wCAL_PO_DQ              ;
    wire    [2*NumberOfWays - 1:0]  wCAL_PO_ChipEnable      ;
    wire    [3:0]                   wCAL_PO_WriteEnable     ;
    wire    [3:0]                   wCAL_PO_AddressLatchEnable;
    wire    [3:0]                   wCAL_PO_CommandLatchEnable;
    wire                            wCAL_DQSOutEnable       ;
    wire                            wCAL_DQOutEnable        ;
    
    //  - State Machine: Data Out
    wire                            wDO_Reset               ;
    
    wire                            wDO_Ready               ;
    wire                            wDO_LastStep            ;
    wire                            wDO_Start               ;
    wire    [0:0]                   wDO_Option              ;
    wire    [NumberOfWays - 1:0]    wDO_TargetWay           ;
    wire    [31:0]                  wDO_WriteData           ;
    wire                            wDO_WriteLast           ;
    wire                            wDO_WriteValid          ;
    wire                            wDO_WriteReady          ;
    
    wire    [7:0]                   wDO_PO_DQStrobe         ;
    wire    [31:0]                  wDO_PO_DQ               ;
    wire    [2*NumberOfWays - 1:0]  wDO_PO_ChipEnable       ;
    wire    [3:0]                   wDO_PO_WriteEnable      ;
    wire    [3:0]                   wDO_PO_AddressLatchEnable;
    wire    [3:0]                   wDO_PO_CommandLatchEnable;
    wire                            wDO_DQSOutEnable        ;
    wire                            wDO_DQOutEnable         ;
    
    //  - State Machine: Data In
    wire                            wDI_Reset               ;
    
    wire                            wDI_Ready               ;
    wire                            wDI_LastStep            ;
    wire                            wDI_Start               ;
    wire    [0:0]                   wDI_Option              ;
    wire    [NumberOfWays - 1:0]    wDI_TargetWay           ;
    wire    [15:0]                  wDI_NumOfData           ;
    wire    [31:0]                  wDI_ReadData            ;
    wire                            wDI_ReadLast            ;
    wire                            wDI_ReadValid           ;
    wire                            wDI_ReadReady           ;
    
    wire                            wDI_PI_BUFF_RE          ;
    wire                            wDI_PI_BUFF_WE          ;
    wire    [2:0]                   wDI_PI_BUFF_OutSel      ;
    wire                            wDI_PI_BUFF_Empty       ;
    wire    [31:0]                  wDI_PI_DQ               ;
    wire    [3:0]                   wDI_PI_ValidFlag        ;
    
    wire    [2*NumberOfWays - 1:0]  wDI_PO_ChipEnable       ;
    wire    [3:0]                   wDI_PO_ReadEnable       ;
    wire    [3:0]                   wDI_PO_WriteEnable      ;
    wire    [3:0]                   wDI_PO_AddressLatchEnable;
    wire    [3:0]                   wDI_PO_CommandLatchEnable;
    wire                            wDI_DQSOutEnable        ;
    wire                            wDI_DQOutEnable         ;
    
    //  - State Machine: TiMer
    wire                            wTM_Reset               ;
    
    wire                            wTM_Ready               ;
    wire                            wTM_LastStep            ;
    wire                            wTM_Start               ;
    wire    [2:0]                   wTM_Option              ;
    wire    [NumberOfWays - 1:0]    wTM_TargetWay           ;
    wire    [15:0]                  wTM_NumOfData           ;
    
    wire    [7:0]                   wTM_PO_DQStrobe         ;
    wire    [2*NumberOfWays - 1:0]  wTM_PO_ChipEnable       ;
    wire    [3:0]                   wTM_PO_ReadEnable       ;
    wire    [3:0]                   wTM_PO_WriteEnable      ;
    wire    [3:0]                   wTM_PO_AddressLatchEnable;
    wire    [3:0]                   wTM_PO_CommandLatchEnable;
    wire                            wTM_DQSOutEnable        ;
    
    //  - NPhy_Toggle Interface PHYOutMux
    wire                           wPHYOutMux_PI_Reset      ;
    wire                           wPHYOutMux_PI_BUFF_Reset ;

    wire                           wPHYOutMux_PO_Reset      ;

    wire                           wPHYOutMux_PI_BUFF_RE    ;
    wire                           wPHYOutMux_PI_BUFF_WE    ;
    wire   [2:0]                   wPHYOutMux_PI_BUFF_OutSel;

    wire                           wPHYOutMux_PIDelayTapLoad;
    wire   [4:0]                   wPHYOutMux_PIDelayTap    ;

    wire   [7:0]                   wPHYOutMux_PO_DQStrobe   ;
    wire   [31:0]                  wPHYOutMux_PO_DQ         ;
    wire   [2*NumberOfWays - 1:0]  wPHYOutMux_PO_ChipEnable ;
    wire   [3:0]                   wPHYOutMux_PO_ReadEnable ;
    wire   [3:0]                   wPHYOutMux_PO_WriteEnable;
    wire   [3:0]                   wPHYOutMux_PO_AddressLatchEnable;
    wire   [3:0]                   wPHYOutMux_PO_CommandLatchEnable;

    wire                           wPHYOutMux_DQSOutEnable;
    wire                           wPHYOutMux_DQOutEnable;
    
    
    
    // P.M. Control
    
    // FSM
    // update current state to next state
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            r_PMC_cur_state <= PMC_RESET;
        end else begin
            r_PMC_cur_state <= r_PMC_nxt_state;
        end
    end
    
    // deside next state
    always @ ( * ) begin
        /*
        case (r_PMC_cur_state)
        PMC_RESET: begin
            r_PMC_nxt_state <= (wPM_Start)? PMC_ON:((wPM_End)? PMC_OFF:PMC_HOLD);
        end
        PMC_HOLD: begin
            r_PMC_nxt_state <= (wPM_Start)? PMC_ON:((wPM_End)? PMC_OFF:PMC_HOLD);
        end
        PMC_ON: begin
            r_PMC_nxt_state <= (wPM_End)? PMC_OFF:PMC_HOLD;
        end
        PMC_OFF: begin
            r_PMC_nxt_state <= (wPM_Start)? PMC_ON:((wPM_End)? PMC_OFF:PMC_HOLD);
        end
        endcase
        */
        r_PMC_nxt_state <= (wPM_Start)? PMC_ON:((wPM_End)? PMC_OFF:PMC_HOLD);
    end
    
    // state behaviour
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rPCommand[7:0]  <= 0;
            rPM_ONOFF       <= 0;
        end else begin
            case (r_PMC_nxt_state)
                PMC_RESET: begin
                    rPCommand[7:0]  <= 0;
                    rPM_ONOFF       <= 0;
                end
                PMC_HOLD: begin
                    rPCommand[7:0]  <= rPCommand[7:0];
                    rPM_ONOFF       <= rPM_ONOFF;
                end
                PMC_ON: begin
                    rPCommand[7:0]  <= iPCommand[7:0];
                    rPM_ONOFF       <= 1;
                end
                PMC_OFF: begin
                    rPCommand[7:0]  <= iPCommand[7:0];
                    rPM_ONOFF       <= 0;
                end
            endcase
        end
    end
    
    
    // Control Signals
    // Flow Control
    assign wPCommandStrobe = |(iPCommand[7:0]);
    assign wPM_LastStep = |(oPM_LastStep[7:0]);
    assign wPM_Start = wPCommandStrobe & ((~rPM_ONOFF) | (wPM_End));
    assign wPM_End = wPM_LastStep & (rPM_ONOFF);
    //assign wPMStartOrEnd = wPCommandStrobe | wPM_LastStep;
    assign wPM_disable = rPM_ONOFF & (~wPM_End);
    
    
    
    
    
    
    
    
    
    
    
    
    // CE Hold Control
    
    // FSM
    // update current state to next state
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            r_CEH_cur_state <= CEH_RESET;
        end else begin
            r_CEH_cur_state <= r_CEH_nxt_state;
        end
    end
    
    // deside next state
    always @ ( * ) begin
        case (r_CEH_cur_state)
        CEH_RESET: begin
            r_CEH_nxt_state <= (wPM_LastStep)? CEH_UPDT:CEH_HOLD;
        end
        CEH_HOLD: begin
            r_CEH_nxt_state <= (wPM_LastStep)? CEH_UPDT:CEH_HOLD;
        end
        CEH_UPDT: begin
            r_CEH_nxt_state <= CEH_HOLD;
        end
        default:
            r_CEH_nxt_state <= CEH_HOLD;
        endcase
    end
    
    // state behaviour
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rCEHold <= 0;
            rCEHold_PO_ChipEnable <= 0;
        end else begin
            case (r_CEH_nxt_state)
                CEH_RESET: begin
                    rCEHold <= 0;
                    rCEHold_PO_ChipEnable <= 0;
                end
                CEH_HOLD: begin
                    rCEHold <= iCEHold;
                    rCEHold_PO_ChipEnable <= rCEHold_PO_ChipEnable;
                end
                CEH_UPDT: begin
                    rCEHold <= iCEHold;
                    rCEHold_PO_ChipEnable <= wPHYOutMux_PO_ChipEnable;
                end
            endcase
        end
    end
    
    
    
    // Control Signals
    // Flow Control
    //assign wPCommandStrobe = |(iPCommand[7:0]);
    //assign wPM_LastStep = |(oPM_LastStep[7:0]);
    //assign wPMStartOrEnd = wPCommandStrobe | wPM_LastStep;
    
    // Internal Connections
    //  - Bypass Connections
    assign oReadyBusy[NumberOfWays - 1:0] = iReadyBusy[NumberOfWays - 1:0];
    
    //  - Not Supported Function
    assign oWriteProtect = 1'b0;
    
    //  - State Machines
    assign oPM_Ready[7] = 1'b0; // reserved
    assign oPM_Ready[6] = wPBR_Ready;
    assign oPM_Ready[5] = wPOR_Ready;
    assign oPM_Ready[4] = wPIR_Ready;
    assign oPM_Ready[3] = wCAL_Ready;
    assign oPM_Ready[2] = wDO_Ready;
    assign oPM_Ready[1] = wDI_Ready;
    assign oPM_Ready[0] = wTM_Ready;
    
    assign oPM_LastStep[7] = 1'b0; // reserved
    assign oPM_LastStep[6] = wPBR_LastStep;
    assign oPM_LastStep[5] = wPOR_LastStep;
    assign oPM_LastStep[4] = wPIR_LastStep;
    assign oPM_LastStep[3] = wCAL_LastStep;
    assign oPM_LastStep[2] = wDO_LastStep;
    assign oPM_LastStep[1] = wDI_LastStep;
    assign oPM_LastStep[0] = wTM_LastStep;
    
        // reserved: iPCommand[7]
    assign wPBR_Start = (~wPM_disable) & iPCommand[6];
    assign wPOR_Start = (~wPM_disable) & iPCommand[5];
    assign wPIR_Start = (~wPM_disable) & iPCommand[4];
    assign wCAL_Start = (~wPM_disable) & iPCommand[3];
    assign wDO_Start = (~wPM_disable) & iPCommand[2];
    assign wDI_Start = (~wPM_disable) & iPCommand[1];
    assign wTM_Start = (~wPM_disable) & iPCommand[0];
    
    //  - State Machine: PO Reset
    assign wPOR_Reset = iReset;
    
    //  - State Machine: PI Reset
    assign wPIR_Reset = iReset;
    
    assign wPIR_PIDelayReady = iPIDelayReady;
    
    //  - State Machine: PHY Buffer Reset
    assign wPBR_Reset = iReset;
    
    //  - State Machine: Command/Address Latch
    assign wCAL_Reset = iReset;
    
    assign wCAL_TargetWay[NumberOfWays - 1:0] = iTargetWay[NumberOfWays - 1:0];
    assign wCAL_NumOfData[3:0] = iNumOfData[3:0]; // shrinked
    
    assign wCAL_CASelect = iCASelect;
    assign wCAL_CAData[7:0] = iCAData[7:0];
    
    //  - State Machine: Data Out
    assign wDO_Reset = iReset;
    
    assign wDO_Option[0:0] = iPCommandOption[0:0]; // shrinked
    assign wDO_TargetWay[NumberOfWays - 1:0] = iTargetWay[NumberOfWays - 1:0];
    
    assign wDO_WriteData[31:0] = iWriteData[31:0];
    assign wDO_WriteLast = iWriteLast;
    assign wDO_WriteValid = iWriteValid;
    assign oWriteReady = wDO_WriteReady;
    
    //  - State Machine: Data In
    assign wDI_Reset = iReset;
    
    assign wDI_Option[0:0] = iPCommandOption[0:0]; // shrinked
    assign wDI_TargetWay[NumberOfWays - 1:0] = iTargetWay[NumberOfWays - 1:0];
    assign wDI_NumOfData[15:0] = iNumOfData[15:0];
    
    assign oReadData[31:0] = wDI_ReadData[31:0];
    assign oReadLast = wDI_ReadLast;
    assign oReadValid = wDI_ReadValid;
    assign wDI_ReadReady = iReadReady;
    
    assign wDI_PI_BUFF_Empty = iPI_BUFF_Empty;
    assign wDI_PI_DQ[31:0] = iPI_DQ[31:0];
    assign wDI_PI_ValidFlag[3:0] = iPI_ValidFlag[3:0];
    
    //  - State Machine: TiMer
    assign wTM_Reset = iReset;
    
    assign wTM_Option[2:0] = iPCommandOption[2:0];
    assign wTM_TargetWay[NumberOfWays - 1:0] = iTargetWay[NumberOfWays - 1:0];
    assign wTM_NumOfData[15:0] = iNumOfData[15:0];
    
    
    
    // State Machine: PO Reset
    
    NPM_Toggle_POR
    Inst_NPM_Toggle_POR
    (
        .iSystemClock       (iSystemClock               ),
        
        .iReset             (wPOR_Reset                 ),
        
        // NPM_Toggle Interface
        //  - PM-I Interface
        .oReady             (wPOR_Ready                 ),
        .oLastStep          (wPOR_LastStep              ),
        
        .iStart             (wPOR_Start                 ),
        
        // NPhy_Toggle Interface
        //  - RESET Interface
        .oPO_Reset          (wPOR_PO_Reset              )
    );
    
    
    
    // State Machine: PI Reset
    
    NPM_Toggle_PIR
    Inst_NPM_Toggle_PIR
    (
        .iSystemClock       (iSystemClock               ),
        
        .iReset             (wPIR_Reset                 ),
        
        // NPM_Toggle Interface
        //  - PM-I Interface
        .oReady             (wPIR_Ready                 ),
        .oLastStep          (wPIR_LastStep              ),
        
        .iStart             (wPIR_Start                 ),
        
        // NPhy_Toggle Interface
        //  - RESET Interface
        .oPI_Reset          (wPIR_PI_Reset              ),
        
        //  - PI Interface
        .iPIDelayReady      (wPIR_PIDelayReady          )
    );
    
    
    
    // State Machine: PHY Buffer Reset
    
    NPM_Toggle_PHY_B_Reset
    Inst_NPM_Toggle_PHY_B_Reset
    (
        .iSystemClock       (iSystemClock               ),
        
        .iReset             (wPBR_Reset                 ),
        
        // NPM_Toggle Interface
        //  - PM-I Interface
        .oReady             (wPBR_Ready                 ),
        .oLastStep          (wPBR_LastStep              ),
        
        .iStart             (wPBR_Start                 ),
        
        // NPhy_Toggle Interface
        //  - RESET Interface
        .oPI_BUFF_Reset     (wPBR_PI_BUFF_Reset         ), // PI buffer reset
        
        //  - PI Interface
        .oPI_BUFF_RE        (wPBR_PI_BUFF_RE            ), // PI buffer reset
        .oPI_BUFF_WE        (wPBR_PI_BUFF_WE            ), // PI buffer reset
        
        //  - PO Interface
        .oPO_DQStrobe       (wPBR_PO_DQStrobe           ), // PI buffer reset
        
        //  - Pad Interface
        .oDQSOutEnable      (wPBR_DQSOutEnable          )  // PI buffer reset
    );
    
    
    
    // State Machine: PI Trainer
    // ..
    
    
    
    // State Machine: IDLE
    
    NPM_Toggle_IDLE_DDR100
    #
    (
        .NumberOfWays   (NumberOfWays   )
    )
    Inst_NPM_Toggle_IDLE
    (
        // NAND Power On Event
        .iNANDPowerOnEvent  (iNANDPowerOnEvent          ),
        
        // NPhy_Toggle Interface
        //  - RESET Interface
        .oPI_Reset          (wIDLE_PI_Reset             ),
        .oPI_BUFF_Reset     (wIDLE_PI_BUFF_Reset        ),
        
        .oPO_Reset          (wIDLE_PO_Reset             ),
        
        //  - PI Interface
        .oPI_BUFF_RE        (wIDLE_PI_BUFF_RE           ),
        .oPI_BUFF_WE        (wIDLE_PI_BUFF_WE           ),
        .oPI_BUFF_OutSel    (wIDLE_PI_BUFF_OutSel       ),
        
        .oPIDelayTapLoad    (wIDLE_PIDelayTapLoad       ),
        .oPIDelayTap        (wIDLE_PIDelayTap           ),
        
        //  - PO Interface
        .oPO_DQStrobe       (wIDLE_PO_DQStrobe          ),
        .oPO_DQ             (wIDLE_PO_DQ                ),
        .oPO_ChipEnable     (wIDLE_PO_ChipEnable        ),
        .oPO_ReadEnable     (wIDLE_PO_ReadEnable        ),
        .oPO_WriteEnable    (wIDLE_PO_WriteEnable       ),
        .oPO_AddressLatchEnable(wIDLE_PO_AddressLatchEnable),
        .oPO_CommandLatchEnable(wIDLE_PO_CommandLatchEnable),
        
        //  - Pad Interface
        .oDQSOutEnable      (wIDLE_DQSOutEnable         ),
        .oDQOutEnable       (wIDLE_DQOutEnable          )
    );
    
    
    
    // State Machine: Command/Address Latch
    NPM_Toggle_CAL_DDR100
    #
    (
        .NumberOfWays   (NumberOfWays   )
    )
    Inst_NPM_Toggle_CAL
    (
        .iSystemClock       (iSystemClock               ),
        
        .iReset             (wCAL_Reset                 ),
        
        // NPM_Toggle Interface
        //  - PM-I Interface
        .oReady             (wCAL_Ready                 ),
        .oLastStep          (wCAL_LastStep              ),
        
        .iStart             (wCAL_Start                 ),
        .iTargetWay         (wCAL_TargetWay             ),
        .iNumOfData         (wCAL_NumOfData             ),
        
        .iCASelect          (wCAL_CASelect              ),
        .iCAData            (wCAL_CAData                ),
        
        // NPhy_Toggle Interface
        //  - PO Interface
        .oPO_DQStrobe       (wCAL_PO_DQStrobe           ),
        .oPO_DQ             (wCAL_PO_DQ                 ),
        .oPO_ChipEnable     (wCAL_PO_ChipEnable         ),
        .oPO_WriteEnable    (wCAL_PO_WriteEnable        ),
        .oPO_AddressLatchEnable(wCAL_PO_AddressLatchEnable ),
        .oPO_CommandLatchEnable(wCAL_PO_CommandLatchEnable ),
        
        //  - Pad Interface
        .oDQSOutEnable      (wCAL_DQSOutEnable          ),
        .oDQOutEnable       (wCAL_DQOutEnable           )
    );
    
    
    
    // State Machine: Data Out
    NPM_Toggle_DO_tADL_DDR100
    #
    (
        .NumberOfWays   (NumberOfWays   )
    )
    Inst_NPM_Toggle_DO
    (
        .iSystemClock       (iSystemClock               ),
        
        .iReset             (wDO_Reset                  ),
        
        // NPM_Toggle Interface
        //  - PM-I Interface
        .oReady             (wDO_Ready                  ),
        .oLastStep          (wDO_LastStep               ),
        
        .iStart             (wDO_Start                  ),
        .iOption            (wDO_Option                 ),
        .iTargetWay         (wDO_TargetWay              ),
        
        .iWriteData         (wDO_WriteData              ),
        .iWriteLast         (wDO_WriteLast              ),
        .iWriteValid        (wDO_WriteValid             ),
        .oWriteReady        (wDO_WriteReady             ),
        
        // NPhy_Toggle Interface
        //  - PO Interface
        .oPO_DQStrobe       (wDO_PO_DQStrobe            ),
        .oPO_DQ             (wDO_PO_DQ                  ),
        .oPO_ChipEnable     (wDO_PO_ChipEnable          ),
        .oPO_WriteEnable    (wDO_PO_WriteEnable         ),
        .oPO_AddressLatchEnable(wDO_PO_AddressLatchEnable  ),
        .oPO_CommandLatchEnable(wDO_PO_CommandLatchEnable  ),
        
        //  - Pad Interface
        .oDQSOutEnable      (wDO_DQSOutEnable           ),
        .oDQOutEnable       (wDO_DQOutEnable            )
    );
    
    
    
    // State Machine: Data In
    NPM_Toggle_DI_DDR100
    #
    (
        .NumberOfWays   (NumberOfWays   )
    )
    Inst_NPM_Toggle_DI
    (
        .iSystemClock       (iSystemClock               ),
        
        .iReset             (wDI_Reset                  ),
        
        // NPM_Toggle Interface
        //  - PM-I Interface
        .oReady             (wDI_Ready                  ),
        .oLastStep          (wDI_LastStep               ),
        
        .iStart             (wDI_Start                  ),
        .iOption            (wDI_Option                 ),
        .iTargetWay         (wDI_TargetWay              ),
        .iNumOfData         (wDI_NumOfData              ),
        
        .oReadData          (wDI_ReadData               ),
        .oReadLast          (wDI_ReadLast               ),
        .oReadValid         (wDI_ReadValid              ),
        .iReadReady         (wDI_ReadReady              ),
        
        // NPhy_Toggle Interface
        //  - PI Interface
        .oPI_BUFF_RE        (wDI_PI_BUFF_RE             ),
        .oPI_BUFF_WE        (wDI_PI_BUFF_WE             ),
        .oPI_BUFF_OutSel    (wDI_PI_BUFF_OutSel         ),
        .iPI_BUFF_Empty     (wDI_PI_BUFF_Empty          ),
        .iPI_DQ             (wDI_PI_DQ                  ),
        .iPI_ValidFlag      (wDI_PI_ValidFlag           ),
        
        //  - PO Interface
        .oPO_ChipEnable     (wDI_PO_ChipEnable          ),
        .oPO_ReadEnable     (wDI_PO_ReadEnable          ),
        .oPO_WriteEnable    (wDI_PO_WriteEnable         ),
        .oPO_AddressLatchEnable(wDI_PO_AddressLatchEnable  ),
        .oPO_CommandLatchEnable(wDI_PO_CommandLatchEnable  ),
        
        //  - Pad Interface
        .oDQSOutEnable      (wDI_DQSOutEnable           ),
        .oDQOutEnable       (wDI_DQOutEnable            )
    );
    
    
    
    // State Machine: TiMer
    
    NPM_Toggle_TIMER
    #
    (
        .NumberOfWays   (NumberOfWays   )
    )
    Inst_NPM_Toggle_TIMER
    (
        .iSystemClock       (iSystemClock               ),
        
        .iReset             (wTM_Reset                  ),
        
        // NPM_Toggle Interface
        //  - PM-I Interface
        .oReady             (wTM_Ready                  ),
        .oLastStep          (wTM_LastStep               ),
        
        .iStart             (wTM_Start                  ),
        .iOption            (wTM_Option                 ),
        .iTargetWay         (wTM_TargetWay              ),
        .iNumOfData         (wTM_NumOfData              ),
        
        //  - PM-X Interface
        .iPO_DQStrobe       (oPO_DQStrobe               ),
        .iPO_ReadEnable     (oPO_ReadEnable             ),
        .iPO_WriteEnable    (oPO_WriteEnable            ),
        .iPO_AddressLatchEnable(oPO_AddressLatchEnable  ),
        .iPO_CommandLatchEnable(oPO_CommandLatchEnable  ),
        
        // NPhy_Toggle Interface
        //  - PO Interface
        .oPO_DQStrobe       (wTM_PO_DQStrobe            ),
        .oPO_ChipEnable     (wTM_PO_ChipEnable          ),
        .oPO_ReadEnable     (wTM_PO_ReadEnable          ),
        .oPO_WriteEnable    (wTM_PO_WriteEnable         ),
        .oPO_AddressLatchEnable(wTM_PO_AddressLatchEnable),
        .oPO_CommandLatchEnable(wTM_PO_CommandLatchEnable),
        
        //  - Pad Interface
        .oDQSOutEnable      (wTM_DQSOutEnable           )
    );
    
    
    
    // NPhy_Toggle Interface PHYOutMux
    
    NPM_Toggle_PHYOutMux
    #
    (
        .NumberOfWays   (NumberOfWays   )
    )
    Inst_NPM_Toggle_PHYOutMux
    (
        // PHYOutMux Control Signals
        .iPCommand          (rPCommand[7:0]             ),
        .iCEHold            (rCEHold                    ),
        
        .iCEHold_ChipEnable (rCEHold_PO_ChipEnable      ),
        
        
        
        // State Machines Output
        
        //  - State Machine: PHY Buffer Reset
        //      - NPhy_Toggle Interface
        //          - RESET Interface
        .iPBR_PI_BUFF_Reset (wPBR_PI_BUFF_Reset         ),
        
        //          - PI Interface
        .iPBR_PI_BUFF_RE    (wPBR_PI_BUFF_RE            ),
        .iPBR_PI_BUFF_WE    (wPBR_PI_BUFF_WE            ),
        
        //          - PO Interface
        .iPBR_PO_DQStrobe   (wPBR_PO_DQStrobe           ),
        
        //          - Pad Interface
        .iPBR_DQSOutEnable  (wPBR_DQSOutEnable          ),
        
        //  - State Machine: PO Reset
        //      - NPhy_Toggle Interface
        //          - RESET Interface
        .iPOR_PO_Reset      (wPOR_PO_Reset              ),
        
        //  - State Machine: PI Reset
        //      - NPhy_Toggle Interface
        //          - RESET Interface
        .iPIR_PI_Reset      (wPIR_PI_Reset              ),
        
        //  - State Machine: IDLE
        //      - NPhy_Toggle Interface
        //          - RESET Interface
        .iIDLE_PI_Reset     (wIDLE_PI_Reset             ),
        .iIDLE_PI_BUFF_Reset(wIDLE_PI_BUFF_Reset        ),
    
        .iIDLE_PO_Reset     (wIDLE_PO_Reset             ),
    
        //          - PI Interface
        .iIDLE_PI_BUFF_RE   (wIDLE_PI_BUFF_RE           ),
        .iIDLE_PI_BUFF_WE   (wIDLE_PI_BUFF_WE           ),
        .iIDLE_PI_BUFF_OutSel(wIDLE_PI_BUFF_OutSel      ),
    
        .iIDLE_PIDelayTapLoad(wIDLE_PIDelayTapLoad      ),
        .iIDLE_PIDelayTap   (wIDLE_PIDelayTap           ),
    
        //          - PO Interface
        .iIDLE_PO_DQStrobe  (wIDLE_PO_DQStrobe          ),
        .iIDLE_PO_DQ        (wIDLE_PO_DQ                ),
        .iIDLE_PO_ChipEnable(wIDLE_PO_ChipEnable        ),
        .iIDLE_PO_ReadEnable(wIDLE_PO_ReadEnable        ),
        .iIDLE_PO_WriteEnable(wIDLE_PO_WriteEnable       ),
        .iIDLE_PO_AddressLatchEnable(wIDLE_PO_AddressLatchEnable),
        .iIDLE_PO_CommandLatchEnable(wIDLE_PO_CommandLatchEnable),
    
        //          - Pad Interface
        .iIDLE_DQSOutEnable (wIDLE_DQSOutEnable         ),
        .iIDLE_DQOutEnable  (wIDLE_DQOutEnable          ),
        
        //  - State Machine: Command/Address Latch
        //      - NPhy_Toggle Interface
        //          - PO Interface
        .iCAL_PO_DQStrobe   (wCAL_PO_DQStrobe           ),
        .iCAL_PO_DQ         (wCAL_PO_DQ                 ),
        .iCAL_PO_ChipEnable (wCAL_PO_ChipEnable         ),
        .iCAL_PO_WriteEnable(wCAL_PO_WriteEnable        ),
        .iCAL_PO_AddressLatchEnable(wCAL_PO_AddressLatchEnable),
        .iCAL_PO_CommandLatchEnable(wCAL_PO_CommandLatchEnable),
    
        //          - Pad Interface
        .iCAL_DQSOutEnable  (wCAL_DQSOutEnable          ),
        .iCAL_DQOutEnable   (wCAL_DQOutEnable           ),
        
        //  - State Machine: Data Out
        //      - NPhy_Toggle Interface
        //          - PO Interface
        .iDO_PO_DQStrobe    (wDO_PO_DQStrobe            ),
        .iDO_PO_DQ          (wDO_PO_DQ                  ),
        .iDO_PO_ChipEnable  (wDO_PO_ChipEnable          ),
        .iDO_PO_WriteEnable (wDO_PO_WriteEnable         ),
        .iDO_PO_AddressLatchEnable(wDO_PO_AddressLatchEnable),
        .iDO_PO_CommandLatchEnable(wDO_PO_CommandLatchEnable),
    
        //          - Pad Interface
        .iDO_DQSOutEnable   (wDO_DQSOutEnable           ),
        .iDO_DQOutEnable    (wDO_DQOutEnable            ),
        
        //  - State Machine: Data In
        //      - NPhy_Toggle Interface
        //          - PI Interface
        .iDI_PI_BUFF_RE     (wDI_PI_BUFF_RE             ),
        .iDI_PI_BUFF_WE     (wDI_PI_BUFF_WE             ),
        .iDI_PI_BUFF_OutSel (wDI_PI_BUFF_OutSel         ),
        
        //          - PO Interface
        .iDI_PO_ChipEnable  (wDI_PO_ChipEnable          ),
        .iDI_PO_ReadEnable  (wDI_PO_ReadEnable          ),
        .iDI_PO_WriteEnable (wDI_PO_WriteEnable         ),
        .iDI_PO_AddressLatchEnable(wDI_PO_AddressLatchEnable),
        .iDI_PO_CommandLatchEnable(wDI_PO_CommandLatchEnable),
        
        //          - Pad Interface
        .iDI_DQSOutEnable   (wDI_DQSOutEnable           ),
        .iDI_DQOutEnable    (wDI_DQOutEnable            ),
        
        //  - State Machine: Timer
        //      - NPhy_Toggle Interface
        //          - PO Interface
        .iTM_PO_DQStrobe    (wTM_PO_DQStrobe            ),
        .iTM_PO_ChipEnable  (wTM_PO_ChipEnable          ),
        .iTM_PO_ReadEnable  (wTM_PO_ReadEnable          ),
        .iTM_PO_WriteEnable (wTM_PO_WriteEnable         ),
        .iTM_PO_AddressLatchEnable(wTM_PO_AddressLatchEnable),
        .iTM_PO_CommandLatchEnable(wTM_PO_CommandLatchEnable),
        
        //          - Pad Interface
        .iTM_DQSOutEnable   (wTM_DQSOutEnable           ),
        
        // NPhy_Toggle Interface
        //  - RESET Interface
        .oPI_Reset          (wPHYOutMux_PI_Reset        ),
        .oPI_BUFF_Reset     (wPHYOutMux_PI_BUFF_Reset   ),
        
        .oPO_Reset          (wPHYOutMux_PO_Reset        ),
        
        //  - PI Interface
        .oPI_BUFF_RE        (wPHYOutMux_PI_BUFF_RE      ),
        .oPI_BUFF_WE        (wPHYOutMux_PI_BUFF_WE      ),
        .oPI_BUFF_OutSel    (wPHYOutMux_PI_BUFF_OutSel  ),
        
        .oPIDelayTapLoad    (wPHYOutMux_PIDelayTapLoad  ),
        .oPIDelayTap        (wPHYOutMux_PIDelayTap      ),
        
        //  - PO Interface
        .oPO_DQStrobe       (wPHYOutMux_PO_DQStrobe     ),
        .oPO_DQ             (wPHYOutMux_PO_DQ           ),
        .oPO_ChipEnable     (wPHYOutMux_PO_ChipEnable   ),
        .oPO_ReadEnable     (wPHYOutMux_PO_ReadEnable   ),
        .oPO_WriteEnable    (wPHYOutMux_PO_WriteEnable  ),
        .oPO_AddressLatchEnable(wPHYOutMux_PO_AddressLatchEnable),
        .oPO_CommandLatchEnable(wPHYOutMux_PO_CommandLatchEnable),
        
        //  - Pad Interface
        .oDQSOutEnable      (wPHYOutMux_DQSOutEnable    ),
        .oDQOutEnable       (wPHYOutMux_DQOutEnable     )
    );
    
    
    
    // PHY Module Output Wire Connections
    //  - NPhy_Toggle Interface
    //      - RESET Interface
    assign oPI_Reset = wPHYOutMux_PI_Reset;
    assign oPI_BUFF_Reset = wPHYOutMux_PI_BUFF_Reset;

    assign oPO_Reset = wPHYOutMux_PO_Reset;

    //      - PI Interface
    assign oPI_BUFF_RE = wPHYOutMux_PI_BUFF_RE;
    assign oPI_BUFF_WE = wPHYOutMux_PI_BUFF_WE;
    assign oPI_BUFF_OutSel[2:0] = wPHYOutMux_PI_BUFF_OutSel[2:0];

    assign oPIDelayTapLoad = wPHYOutMux_PIDelayTapLoad;
    assign oPIDelayTap[4:0] = wPHYOutMux_PIDelayTap[4:0];

    //      - PO Interface
    assign oPO_DQStrobe[7:0] = wPHYOutMux_PO_DQStrobe[7:0];
    assign oPO_DQ[31:0] = wPHYOutMux_PO_DQ[31:0];
    assign oPO_ChipEnable = wPHYOutMux_PO_ChipEnable;
    assign oPO_ReadEnable[3:0] = wPHYOutMux_PO_ReadEnable[3:0];
    assign oPO_WriteEnable[3:0] = wPHYOutMux_PO_WriteEnable[3:0];
    assign oPO_AddressLatchEnable[3:0] = wPHYOutMux_PO_AddressLatchEnable[3:0];
    assign oPO_CommandLatchEnable[3:0] = wPHYOutMux_PO_CommandLatchEnable[3:0];

    //      - Pad Interface
    assign oDQSOutEnable = wPHYOutMux_DQSOutEnable;
    assign oDQOutEnable = wPHYOutMux_DQOutEnable;
    
endmodule

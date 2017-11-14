//////////////////////////////////////////////////////////////////////////////////
// NFC_Toggle_Top_DDR100 for Cosmos OpenSSD
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
// Design Name: NFC_Toggle_Top_DDR100
// Module Name: NFC_Toggle_Top_DDR100
// File Name: NFC_Toggle_Top_DDR100.v
//
// Version: v1.0.0
//
// Description: NFC top
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module NFC_Toggle_Top_DDR100
#
(
    parameter IDelayValue           =   13  ,
    parameter InputClockBufferType  =   0   ,
    parameter NumberOfWays          =   8
)
(
    iSystemClock        ,
    iDelayRefClock      ,
    iOutputDrivingClock ,
    iReset              ,
    iOpcode             ,
    iTargetID           ,
    iSourceID           ,
    iAddress            ,
    iLength             ,
    iCMDValid           ,
    oCMDReady           ,
    iWriteData          ,
    iWriteLast          ,
    iWriteValid         ,
    oWriteReady         ,
    oReadData           ,
    oReadLast           ,
    oReadValid          ,
    iReadReady          ,
    oReadyBusy          ,
    IO_NAND_DQS_P       ,
    IO_NAND_DQS_N       ,
    IO_NAND_DQ          ,
    O_NAND_CE           ,
    O_NAND_WE           ,
    O_NAND_RE_P         ,
    O_NAND_RE_N         ,
    O_NAND_ALE          ,
    O_NAND_CLE          ,
    I_NAND_RB           ,
    O_NAND_WP   
);
    input                           iSystemClock            ; // SDR 100MHz
    input                           iDelayRefClock          ; // SDR 200Mhz
    input                           iOutputDrivingClock     ; // SDR 200Mhz
    input                           iReset                  ;
    input   [5:0]                   iOpcode                 ;
    input   [4:0]                   iTargetID               ;
    input   [4:0]                   iSourceID               ;
    input   [31:0]                  iAddress                ;
    input   [15:0]                  iLength                 ;
    input                           iCMDValid               ;
    output                          oCMDReady               ;
    input   [31:0]                  iWriteData              ;
    input                           iWriteLast              ;
    input                           iWriteValid             ;
    output                          oWriteReady             ;
    output  [31:0]                  oReadData               ;
    output                          oReadLast               ;
    output                          oReadValid              ;
    input                           iReadReady              ;
    output  [NumberOfWays - 1:0]    oReadyBusy              ; // bypass
    inout                           IO_NAND_DQS_P           ; // Differential: Positive
    inout                           IO_NAND_DQS_N           ; // Differential: Negative
    inout   [7:0]                   IO_NAND_DQ              ;
    output  [NumberOfWays - 1:0]    O_NAND_CE               ;
    output                          O_NAND_WE               ;
    output                          O_NAND_RE_P             ; // Differential: Positive
    output                          O_NAND_RE_N             ; // Differential: Negative
    output                          O_NAND_ALE              ;
    output                          O_NAND_CLE              ;
    input   [NumberOfWays - 1:0]    I_NAND_RB               ;
    output                          O_NAND_WP               ;
    
    // Internal Wires/Regs
    // Primitive Command Generator (P.C.G.) ~~~ Primitive Machine (P.M.)
    wire   [7:0]                   wPM_Ready_PCG_PM               ;
    wire   [7:0]                   wPM_LastStep_PCG_PM            ;
    
    wire  [7:0]                   wPM_PCommand_PCG_PM            ;
    wire  [2:0]                   wPM_PCommandOption_PCG_PM      ;
    wire  [NumberOfWays - 1:0]    wPM_TargetWay_PCG_PM           ;
    wire  [15:0]                  wPM_NumOfData_PCG_PM           ;
    wire                          wPM_CEHold_PCG_PM              ;
    wire                          wPM_NANDPowerOnEvent_PCG_PM       ;
    
    wire                          wPM_CASelect_PCG_PM            ;
    wire  [7:0]                   wPM_CAData_PCG_PM              ;
    
    wire  [31:0]                  wPM_WriteData_PCG_PM           ;
    wire                          wPM_WriteLast_PCG_PM           ;
    wire                          wPM_WriteValid_PCG_PM          ;
    wire                           wPM_WriteReady_PCG_PM          ;
    
    wire   [31:0]                  wPM_ReadData_PCG_PM            ;
    wire                           wPM_ReadLast_PCG_PM            ;
    wire                           wPM_ReadValid_PCG_PM           ;
    wire                          wPM_ReadReady_PCG_PM           ;
    
    wire   [NumberOfWays - 1:0]    wReadyBusy_PCG_PM             ;
    
    // Primitive Machine (P.M.) ~~~ Physical Module (PHY)
    wire                          wPI_Reset_PM_PHY                ;
    wire                          wPI_BUFF_Reset_PM_PHY          ;
    
    wire                          wPO_Reset_PM_PHY                ;
    
    wire                          wPI_BUFF_RE_PM_PHY             ;
    wire                          wPI_BUFF_WE_PM_PHY             ;
    wire  [2:0]                   wPI_BUFF_OutSel_PM_PHY         ;
    wire                           wPI_BUFF_Empty_PM_PHY          ;
    wire   [31:0]                  wPI_DQ_PM_PHY                  ;
    wire   [3:0]                   wPI_ValidFlag_PM_PHY           ;
    
    wire                          wPIDelayTapLoad_PM_PHY         ;
    wire  [4:0]                   wPIDelayTap_PM_PHY             ;
    wire                           wPIDelayReady_PM_PHY           ;
    
    wire  [7:0]                   wPO_DQStrobe_PM_PHY            ;
    wire  [31:0]                  wPO_DQ_PM_PHY                  ;
    wire  [2*NumberOfWays - 1:0]  wPO_ChipEnable_PM_PHY          ;
    wire  [3:0]                   wPO_ReadEnable_PM_PHY          ;
    wire  [3:0]                   wPO_WriteEnable_PM_PHY         ;
    wire  [3:0]                   wPO_AddressLatchEnable_PM_PHY  ;
    wire  [3:0]                   wPO_CommandLatchEnable_PM_PHY  ;
    
    wire   [NumberOfWays - 1:0]    wReadyBusy_PM_PHY              ;
    wire                          wWriteProtect_PM_PHY           ;
    
    wire                          wDQSOutEnable_PM_PHY           ;
    wire                          wDQOutEnable_PM_PHY            ;
    
    
    
    
    
    
    // Primitive Command Generator (P.C.G.)
    NPCG_Toggle_Top
    #
    (
        .NumberOfWays           (NumberOfWays           )
    )
    Inst_NPCG_Toggle_Top
    (
        .iSystemClock           (iSystemClock           ),
        
        .iReset                 (iReset                 ),
        
        
        
        // Dispatcher Interface
        //  - Command Channel
        .iOpcode                (iOpcode                ),
        .iTargetID              (iTargetID              ),
        .iSourceID              (iSourceID              ),
        
        .iAddress               (iAddress               ),
        .iLength                (iLength                ),
        
        .iCMDValid              (iCMDValid              ),
        .oCMDReady              (oCMDReady              ),
        
        //  - Data Write Channel
        .iWriteData             (iWriteData             ),
        .iWriteLast             (iWriteLast             ),
        .iWriteValid            (iWriteValid            ),
        .oWriteReady            (oWriteReady            ),
        
        //  - Data Read Channel
        .oReadData              (oReadData              ),
        .oReadLast              (oReadLast              ),
        .oReadValid             (oReadValid             ),
        .iReadReady             (iReadReady             ),
        
        //  - Miscellaneous Information Channel
        .oReadyBusy             (oReadyBusy             ),
        
        
        
        // NPCG_Toggle Interface
        .iPM_Ready              (wPM_Ready_PCG_PM),
        .iPM_LastStep           (wPM_LastStep_PCG_PM),
        
        .oPM_PCommand           (wPM_PCommand_PCG_PM),
        .oPM_PCommandOption     (wPM_PCommandOption_PCG_PM),
        .oPM_TargetWay          (wPM_TargetWay_PCG_PM),
        .oPM_NumOfData          (wPM_NumOfData_PCG_PM),
        .oPM_CEHold             (wPM_CEHold_PCG_PM),
        .oPM_NANDPowerOnEvent   (wPM_NANDPowerOnEvent_PCG_PM),
        
        .oPM_CASelect           (wPM_CASelect_PCG_PM),
        .oPM_CAData             (wPM_CAData_PCG_PM),
        
        .oPM_WriteData          (wPM_WriteData_PCG_PM),
        .oPM_WriteLast          (wPM_WriteLast_PCG_PM),
        .oPM_WriteValid         (wPM_WriteValid_PCG_PM),
        .iPM_WriteReady         (wPM_WriteReady_PCG_PM),
        
        .iPM_ReadData           (wPM_ReadData_PCG_PM),
        .iPM_ReadLast           (wPM_ReadLast_PCG_PM),
        .iPM_ReadValid          (wPM_ReadValid_PCG_PM),
        .oPM_ReadReady          (wPM_ReadReady_PCG_PM),
        
        .iReadyBusy             (wReadyBusy_PCG_PM      )
    );
    
    
    
    // Primitive Machine (P.M.)
    NPM_Toggle_Top_DDR100
    #
    (
        .NumberOfWays           (NumberOfWays           )
    )
    Inst_NPM_Toggle_Top
    (
        .iSystemClock           (iSystemClock           ),
        
        .iReset                 (iReset                 ),
        
        
        
        // NPCG_Toggle Interface
        .oPM_Ready              (wPM_Ready_PCG_PM),
        .oPM_LastStep           (wPM_LastStep_PCG_PM),
        
        .iPCommand              (wPM_PCommand_PCG_PM),
        .iPCommandOption        (wPM_PCommandOption_PCG_PM),
        .iTargetWay             (wPM_TargetWay_PCG_PM),
        .iNumOfData             (wPM_NumOfData_PCG_PM),
        .iCEHold                (wPM_CEHold_PCG_PM),
        .iNANDPowerOnEvent      (wPM_NANDPowerOnEvent_PCG_PM),
        
        .iCASelect              (wPM_CASelect_PCG_PM),
        .iCAData                (wPM_CAData_PCG_PM),
        
        .iWriteData             (wPM_WriteData_PCG_PM),
        .iWriteLast             (wPM_WriteLast_PCG_PM),
        .iWriteValid            (wPM_WriteValid_PCG_PM),
        .oWriteReady            (wPM_WriteReady_PCG_PM),
        
        .oReadData              (wPM_ReadData_PCG_PM),
        .oReadLast              (wPM_ReadLast_PCG_PM),
        .oReadValid             (wPM_ReadValid_PCG_PM),
        .iReadReady             (wPM_ReadReady_PCG_PM),
        
        .oReadyBusy             (wReadyBusy_PCG_PM),
        
        
        
        // NPhy_Toggle Interface
        //  - RESET Interface
        .oPI_Reset              (wPI_Reset_PM_PHY),
        .oPI_BUFF_Reset         (wPI_BUFF_Reset_PM_PHY),
        
        .oPO_Reset              (wPO_Reset_PM_PHY),
        
        //  - PI Interface
        .oPI_BUFF_RE            (wPI_BUFF_RE_PM_PHY),
        .oPI_BUFF_WE            (wPI_BUFF_WE_PM_PHY),
        .oPI_BUFF_OutSel        (wPI_BUFF_OutSel_PM_PHY),
        .iPI_BUFF_Empty         (wPI_BUFF_Empty_PM_PHY),
        .iPI_DQ                 (wPI_DQ_PM_PHY),
        .iPI_ValidFlag          (wPI_ValidFlag_PM_PHY),
        
        .oPIDelayTapLoad        (wPIDelayTapLoad_PM_PHY),
        .oPIDelayTap            (wPIDelayTap_PM_PHY),
        .iPIDelayReady          (wPIDelayReady_PM_PHY),
        
        //  - PO Interface
        .oPO_DQStrobe           (wPO_DQStrobe_PM_PHY),
        .oPO_DQ                 (wPO_DQ_PM_PHY),
        .oPO_ChipEnable         (wPO_ChipEnable_PM_PHY),
        .oPO_ReadEnable         (wPO_ReadEnable_PM_PHY),
        .oPO_WriteEnable        (wPO_WriteEnable_PM_PHY),
        .oPO_AddressLatchEnable (wPO_AddressLatchEnable_PM_PHY),
        .oPO_CommandLatchEnable (wPO_CommandLatchEnable_PM_PHY),
        
        //  - Miscellaneous Physical Interface
        .iReadyBusy             (wReadyBusy_PM_PHY),
        .oWriteProtect          (wWriteProtect_PM_PHY),
        
        //  - Pad Interface
        .oDQSOutEnable          (wDQSOutEnable_PM_PHY),
        .oDQOutEnable           (wDQOutEnable_PM_PHY    )
    );
    
    
    
    // Physical Module (PHY)
    NPhy_Toggle_Top_DDR100
    #
    (
        .IDelayValue            (IDelayValue            ),
        .InputClockBufferType   (InputClockBufferType   ),
        .NumberOfWays           (NumberOfWays           )
    )
    Inst_NPhy_Toggle_Top
    (
        .iSystemClock           (iSystemClock           ),
        .iDelayRefClock         (iDelayRefClock         ),
        .iOutputDrivingClock    (iOutputDrivingClock    ),
        
        // NPhy_Toggle Interface
        //  - RESET Interface
        .iPI_Reset              (wPI_Reset_PM_PHY),
        .iPI_BUFF_Reset         (wPI_BUFF_Reset_PM_PHY),
        
        .iPO_Reset              (wPO_Reset_PM_PHY),
        
        //  - PI Interface
        .iPI_BUFF_RE            (wPI_BUFF_RE_PM_PHY),
        .iPI_BUFF_WE            (wPI_BUFF_WE_PM_PHY),
        .iPI_BUFF_OutSel        (wPI_BUFF_OutSel_PM_PHY),
        .oPI_BUFF_Empty         (wPI_BUFF_Empty_PM_PHY),
        .oPI_DQ                 (wPI_DQ_PM_PHY),
        .oPI_ValidFlag          (wPI_ValidFlag_PM_PHY),
        
        .iPIDelayTapLoad        (wPIDelayTapLoad_PM_PHY),
        .iPIDelayTap            (wPIDelayTap_PM_PHY),
        .oPIDelayReady          (wPIDelayReady_PM_PHY),
        
        //  - PO Interface
        .iPO_DQStrobe           (wPO_DQStrobe_PM_PHY),
        .iPO_DQ                 (wPO_DQ_PM_PHY),
        .iPO_ChipEnable         (wPO_ChipEnable_PM_PHY),
        .iPO_ReadEnable         (wPO_ReadEnable_PM_PHY),
        .iPO_WriteEnable        (wPO_WriteEnable_PM_PHY),
        .iPO_AddressLatchEnable (wPO_AddressLatchEnable_PM_PHY),
        .iPO_CommandLatchEnable (wPO_CommandLatchEnable_PM_PHY),
        
        //  - Miscellaneous Physical Interface
        .oReadyBusy             (wReadyBusy_PM_PHY),
        .iWriteProtect          (wWriteProtect_PM_PHY),
        
        //  - Pad Interface
        .iDQSOutEnable          (wDQSOutEnable_PM_PHY),
        .iDQOutEnable           (wDQOutEnable_PM_PHY),
        
        // NAND Interface
        .IO_NAND_DQS_P          (IO_NAND_DQS_P          ), // Differential: Positive
        .IO_NAND_DQS_N          (IO_NAND_DQS_N          ), // Differential: Positive
        .IO_NAND_DQ             (IO_NAND_DQ             ),
        
        .O_NAND_CE              (O_NAND_CE              ),
        
        .O_NAND_WE              (O_NAND_WE              ),
        .O_NAND_RE_P            (O_NAND_RE_P            ), // Differential: Positive
        .O_NAND_RE_N            (O_NAND_RE_N            ), // Differential: Positive
        .O_NAND_ALE             (O_NAND_ALE             ),
        .O_NAND_CLE             (O_NAND_CLE             ),
        
        .I_NAND_RB              (I_NAND_RB              ),
        
        .O_NAND_WP              (O_NAND_WP              )
    );
    
endmodule

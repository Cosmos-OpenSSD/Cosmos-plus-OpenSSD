//////////////////////////////////////////////////////////////////////////////////
// NPM_Toggle_PHYOutMux for Cosmos OpenSSD
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
// Design Name: NPM_Toggle_PHYOutMux
// Module Name: NPM_Toggle_PHYOutMux
// File Name: NPM_Toggle_PHYOutMux.v
//
// Version: v1.0.0
//
// Description: NFC PM layer multiplexor
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module NPM_Toggle_PHYOutMux
#
(
    // Multiplexing by iPCommand[7:0]
    // not support parallel primitive command execution
    
    // ChipEnable: support CE holding function by iCEHold and wPM_idle
    
    // State Machines: PO Reset, PI Reset, IDLE, C/A Latch, Data Out, Data In, Timer
    
    parameter NumberOfWays    =   4
)
(
    iPCommand                   ,
    iCEHold                     ,
    iCEHold_ChipEnable          ,
    iPBR_PI_BUFF_Reset          ,
    iPBR_PI_BUFF_RE             ,
    iPBR_PI_BUFF_WE             ,
    iPBR_PO_DQStrobe            ,
    iPBR_DQSOutEnable           ,
    iPOR_PO_Reset               ,
    iPIR_PI_Reset               ,
    iIDLE_PI_Reset              ,
    iIDLE_PI_BUFF_Reset         ,
    iIDLE_PO_Reset              ,
    iIDLE_PI_BUFF_RE            ,
    iIDLE_PI_BUFF_WE            ,
    iIDLE_PI_BUFF_OutSel        ,
    iIDLE_PIDelayTapLoad        ,
    iIDLE_PIDelayTap            ,
    iIDLE_PO_DQStrobe           ,
    iIDLE_PO_DQ                 ,
    iIDLE_PO_ChipEnable         ,
    iIDLE_PO_ReadEnable         ,
    iIDLE_PO_WriteEnable        ,
    iIDLE_PO_AddressLatchEnable ,
    iIDLE_PO_CommandLatchEnable ,
    iIDLE_DQSOutEnable          ,
    iIDLE_DQOutEnable           ,
    iCAL_PO_DQStrobe            ,
    iCAL_PO_DQ                  ,
    iCAL_PO_ChipEnable          ,
    iCAL_PO_WriteEnable         ,
    iCAL_PO_AddressLatchEnable  ,
    iCAL_PO_CommandLatchEnable  ,
    iCAL_DQSOutEnable           ,
    iCAL_DQOutEnable            ,
    iDO_PO_DQStrobe             ,
    iDO_PO_DQ                   ,
    iDO_PO_ChipEnable           ,
    iDO_PO_WriteEnable          ,
    iDO_PO_AddressLatchEnable   ,
    iDO_PO_CommandLatchEnable   ,
    iDO_DQSOutEnable            ,
    iDO_DQOutEnable             ,
    iDI_PI_BUFF_RE              ,
    iDI_PI_BUFF_WE              ,
    iDI_PI_BUFF_OutSel          ,
    iDI_PO_ChipEnable           ,
    iDI_PO_ReadEnable           ,
    iDI_PO_WriteEnable          ,
    iDI_PO_AddressLatchEnable   ,
    iDI_PO_CommandLatchEnable   ,
    iDI_DQSOutEnable            ,
    iDI_DQOutEnable             ,
    iTM_PO_DQStrobe             ,
    iTM_PO_ChipEnable           ,
    iTM_PO_ReadEnable           ,
    iTM_PO_WriteEnable          ,
    iTM_PO_AddressLatchEnable   ,
    iTM_PO_CommandLatchEnable   ,
    iTM_DQSOutEnable            ,
    oPI_Reset                   ,
    oPI_BUFF_Reset              ,
    oPO_Reset                   ,
    oPI_BUFF_RE                 ,
    oPI_BUFF_WE                 ,
    oPI_BUFF_OutSel             ,
    oPIDelayTapLoad             ,
    oPIDelayTap                 ,
    oPO_DQStrobe                ,
    oPO_DQ                      ,
    oPO_ChipEnable              ,
    oPO_ReadEnable              ,
    oPO_WriteEnable             ,
    oPO_AddressLatchEnable      ,
    oPO_CommandLatchEnable      ,
    oDQSOutEnable               ,
    oDQOutEnable            
);
    input   [7:0]                   iPCommand                   ;
    input                           iCEHold                     ;
    input   [2*NumberOfWays - 1:0]  iCEHold_ChipEnable          ;
    input                           iPBR_PI_BUFF_Reset          ;
    input                           iPBR_PI_BUFF_RE             ;
    input                           iPBR_PI_BUFF_WE             ;
    input   [7:0]                   iPBR_PO_DQStrobe            ;
    input                           iPBR_DQSOutEnable           ;
    input                           iPOR_PO_Reset               ;
    input                           iPIR_PI_Reset               ;
    input                           iIDLE_PI_Reset              ;
    input                           iIDLE_PI_BUFF_Reset         ;
    input                           iIDLE_PO_Reset              ;
    input                           iIDLE_PI_BUFF_RE            ;
    input                           iIDLE_PI_BUFF_WE            ;
    input   [2:0]                   iIDLE_PI_BUFF_OutSel        ;
    input                           iIDLE_PIDelayTapLoad        ;
    input   [4:0]                   iIDLE_PIDelayTap            ;
    input   [7:0]                   iIDLE_PO_DQStrobe           ;
    input   [31:0]                  iIDLE_PO_DQ                 ;
    input   [2*NumberOfWays - 1:0]  iIDLE_PO_ChipEnable         ;
    input   [3:0]                   iIDLE_PO_ReadEnable         ;
    input   [3:0]                   iIDLE_PO_WriteEnable        ;
    input   [3:0]                   iIDLE_PO_AddressLatchEnable ;
    input   [3:0]                   iIDLE_PO_CommandLatchEnable ;
    input                           iIDLE_DQSOutEnable          ;
    input                           iIDLE_DQOutEnable           ;
    input   [7:0]                   iCAL_PO_DQStrobe            ;
    input   [31:0]                  iCAL_PO_DQ                  ;
    input   [2*NumberOfWays - 1:0]  iCAL_PO_ChipEnable          ;
    input   [3:0]                   iCAL_PO_WriteEnable         ;
    input   [3:0]                   iCAL_PO_AddressLatchEnable  ;
    input   [3:0]                   iCAL_PO_CommandLatchEnable  ;
    input                           iCAL_DQSOutEnable           ;
    input                           iCAL_DQOutEnable            ;
    input   [7:0]                   iDO_PO_DQStrobe             ;
    input   [31:0]                  iDO_PO_DQ                   ;
    input   [2*NumberOfWays - 1:0]  iDO_PO_ChipEnable           ;
    input   [3:0]                   iDO_PO_WriteEnable          ;
    input   [3:0]                   iDO_PO_AddressLatchEnable   ;
    input   [3:0]                   iDO_PO_CommandLatchEnable   ;
    input                           iDO_DQSOutEnable            ;
    input                           iDO_DQOutEnable             ;
    input                           iDI_PI_BUFF_RE              ;
    input                           iDI_PI_BUFF_WE              ;
    input   [2:0]                   iDI_PI_BUFF_OutSel          ;
    input   [2*NumberOfWays - 1:0]  iDI_PO_ChipEnable           ;
    input   [3:0]                   iDI_PO_ReadEnable           ;
    input   [3:0]                   iDI_PO_WriteEnable          ;
    input   [3:0]                   iDI_PO_AddressLatchEnable   ;
    input   [3:0]                   iDI_PO_CommandLatchEnable   ;
    input                           iDI_DQSOutEnable            ;
    input                           iDI_DQOutEnable             ;
    input   [7:0]                   iTM_PO_DQStrobe             ;
    input   [2*NumberOfWays - 1:0]  iTM_PO_ChipEnable           ;
    input   [3:0]                   iTM_PO_ReadEnable           ;
    input   [3:0]                   iTM_PO_WriteEnable          ;
    input   [3:0]                   iTM_PO_AddressLatchEnable   ;
    input   [3:0]                   iTM_PO_CommandLatchEnable   ;
    input                           iTM_DQSOutEnable            ;
    output                          oPI_Reset                   ;
    output                          oPI_BUFF_Reset              ;
    output                          oPO_Reset                   ;
    output                          oPI_BUFF_RE                 ;
    output                          oPI_BUFF_WE                 ;
    output  [2:0]                   oPI_BUFF_OutSel             ;
    output                          oPIDelayTapLoad             ;
    output  [4:0]                   oPIDelayTap                 ;
    output  [7:0]                   oPO_DQStrobe                ;
    output  [31:0]                  oPO_DQ                      ;
    output  [2*NumberOfWays - 1:0]  oPO_ChipEnable              ;
    output  [3:0]                   oPO_ReadEnable              ;
    output  [3:0]                   oPO_WriteEnable             ;
    output  [3:0]                   oPO_AddressLatchEnable      ;
    output  [3:0]                   oPO_CommandLatchEnable      ;
    output                          oDQSOutEnable               ;
    output                          oDQOutEnable                ;
    
    // Internal Wires/Regs
    wire                            wPM_idle                ;
    
    //  - NPhy_Toggle Interface
    //      - RESET Interface
    reg                             rPI_Reset               ;
    reg                             rPI_BUFF_Reset          ;
    
    reg                             rPO_Reset               ;
    
    //      - PI Interface
    reg                             rPI_BUFF_RE             ;
    reg                             rPI_BUFF_WE             ;
    reg     [2:0]                   rPI_BUFF_OutSel         ;
    
    reg                             rPIDelayTapLoad         ;
    reg     [4:0]                   rPIDelayTap             ;
    
    //      - PO Interface
    reg     [7:0]                   rPO_DQStrobe            ;
    reg     [31:0]                  rPO_DQ                  ;
    reg     [2*NumberOfWays - 1:0]  rPO_ChipEnable          ;
    reg     [3:0]                   rPO_ReadEnable          ;
    reg     [3:0]                   rPO_WriteEnable         ;
    reg     [3:0]                   rPO_AddressLatchEnable  ;
    reg     [3:0]                   rPO_CommandLatchEnable  ;
    
    //      - Pad Interface
    reg                             rDQSOutEnable           ;
    reg                             rDQOutEnable            ;
    
    
    
    // Control Signals
    assign wPM_idle = ~( |(iPCommand[7:0]) );
    
    
    
    // NPhy_Toggle Interface
    
    // PI_Reset
    always @ (*) begin
        //if (wPM_idle) begin // All PMs are in inactive state.
            
        //end else if (iPCommand[6]) begin // PHY Buffer Reset
            
        //end else if (iPCommand[5]) begin // PO Reset
            
        if (iPCommand[4]) begin // PI Reset
            rPI_Reset <= iPIR_PI_Reset;
        //end else if (iPCommand[3]) begin // Command/Address Latch
            
        //end else if (iPCommand[2]) begin // Data Out
            
        //end else if (iPCommand[1]) begin // Data In
            
        //end else if (iPCommand[0]) begin // Timer
            
        end else begin // default
            rPI_Reset <= iIDLE_PI_Reset;
        end
    end
    
    // PI_BUFF_Reset
    always @ (*) begin
        //if (wPM_idle) begin // All PMs are in inactive state.
            
        if (iPCommand[6]) begin // PHY Buffer Reset
            rPI_BUFF_Reset <= iPBR_PI_BUFF_Reset;
        //end else if (iPCommand[5]) begin // PO Reset
            
        //end else if (iPCommand[4]) begin // PI Reset
            
        //end else if (iPCommand[3]) begin // Command/Address Latch
            
        //end else if (iPCommand[2]) begin // Data Out
            
        //end else if (iPCommand[1]) begin // Data In
            
        //end else if (iPCommand[0]) begin // Timer
            
        end else begin // default
            rPI_BUFF_Reset <= iIDLE_PI_BUFF_Reset;
        end
    end
    
    // PO_Reset
    always @ (*) begin
        //if (wPM_idle) begin // All PMs are in inactive state.
            
        //end else if (iPCommand[6]) begin // PHY Buffer Reset
            
        if (iPCommand[5]) begin // PO Reset
            rPO_Reset <= iPOR_PO_Reset;
        //end else if (iPCommand[4]) begin // PI Reset
            
        //end else if (iPCommand[3]) begin // Command/Address Latch
            
        //end else if (iPCommand[2]) begin // Data Out
            
        //end else if (iPCommand[1]) begin // Data In
            
        //end else if (iPCommand[0]) begin // Timer
            
        end else begin // default
            rPO_Reset <= iIDLE_PO_Reset;
        end
    end
    
    // PI_BUFF_RE
    always @ (*) begin
        //if (wPM_idle) begin // All PMs are in inactive state.
            
        if (iPCommand[6]) begin // PHY Buffer Reset
            rPI_BUFF_RE <= iPBR_PI_BUFF_RE;
        //end else if (iPCommand[5]) begin // PO Reset
            
        //end else if (iPCommand[4]) begin // PI Reset
            
        //end else if (iPCommand[3]) begin // Command/Address Latch
            
        //end else if (iPCommand[2]) begin // Data Out
            
        end else if (iPCommand[1]) begin // Data In
            rPI_BUFF_RE <= iDI_PI_BUFF_RE;
        //end else if (iPCommand[0]) begin // Timer
            
        end else begin // default
            rPI_BUFF_RE <= iIDLE_PI_BUFF_RE;
        end
    end
    
    // PI_BUFF_WE
    always @ (*) begin
        //if (wPM_idle) begin // All PMs are in inactive state.
            
        if (iPCommand[6]) begin // PHY Buffer Reset
            rPI_BUFF_WE <= iPBR_PI_BUFF_WE;
        //end else if (iPCommand[5]) begin // PO Reset
            
        //end else if (iPCommand[4]) begin // PI Reset
            
        //end else if (iPCommand[3]) begin // Command/Address Latch
            
        //end else if (iPCommand[2]) begin // Data Out
            
        end else if (iPCommand[1]) begin // Data In
            rPI_BUFF_WE <= iDI_PI_BUFF_WE;
        //end else if (iPCommand[0]) begin // Timer
            
        end else begin // default
            rPI_BUFF_WE <= iIDLE_PI_BUFF_WE;
        end
    end
    
    // PI_BUFF_OutSel[2:0]
    always @ (*) begin
        //if (wPM_idle) begin // All PMs are in inactive state.
            
        //end else if (iPCommand[6]) begin // PHY Buffer Reset
            
        //end else if (iPCommand[5]) begin // PO Reset
            
        //end else if (iPCommand[4]) begin // PI Reset
            
        //end else if (iPCommand[3]) begin // Command/Address Latch
            
        //end else if (iPCommand[2]) begin // Data Out
            
        if (iPCommand[1]) begin // Data In
            rPI_BUFF_OutSel[2:0] <= iDI_PI_BUFF_OutSel[2:0];
        //end else if (iPCommand[0]) begin // Timer
            
        end else begin // default
            rPI_BUFF_OutSel[2:0] <= iIDLE_PI_BUFF_OutSel[2:0];
        end
    end
    
    // PIDelayTapLoad
    always @ (*) begin
        //if (wPM_idle) begin // All PMs are in inactive state.
            
        //end else if (iPCommand[6]) begin // PHY Buffer Reset
            
        //end else if (iPCommand[5]) begin // PO Reset
            
        //end else if (iPCommand[4]) begin // PI Reset
            
        //end else if (iPCommand[3]) begin // Command/Address Latch
            
        //end else if (iPCommand[2]) begin // Data Out
            
        //end else if (iPCommand[1]) begin // Data In
            
        //end else if (iPCommand[0]) begin // Timer
            
        //end else begin // default
            rPIDelayTapLoad <= iIDLE_PIDelayTapLoad;
        //end
    end
    
    // PIDelayTap[4:0]
    always @ (*) begin
        //if (wPM_idle) begin // All PMs are in inactive state.
            
        //end else if (iPCommand[6]) begin // PHY Buffer Reset
            
        //end else if (iPCommand[5]) begin // PO Reset
            
        //end else if (iPCommand[4]) begin // PI Reset
            
        //end else if (iPCommand[3]) begin // Command/Address Latch
            
        //end else if (iPCommand[2]) begin // Data Out
            
        //end else if (iPCommand[1]) begin // Data In
            
        //end else if (iPCommand[0]) begin // Timer
            
        //end else begin // default
            rPIDelayTap[4:0] <= iIDLE_PIDelayTap[4:0];
        //end
    end
    
    // PO_DQStrobe[7:0]
    always @ (*) begin
        //if (wPM_idle) begin // All PMs are in inactive state.
            
        if (iPCommand[6]) begin // PHY Buffer Reset
            rPO_DQStrobe[7:0] <= iPBR_PO_DQStrobe[7:0];
        //end else if (iPCommand[5]) begin // PO Reset
            
        //end else if (iPCommand[4]) begin // PI Reset
            
        end else if (iPCommand[3]) begin // Command/Address Latch
            rPO_DQStrobe[7:0] <= iCAL_PO_DQStrobe[7:0];
        end else if (iPCommand[2]) begin // Data Out
            rPO_DQStrobe[7:0] <= iDO_PO_DQStrobe[7:0];
        //end else if (iPCommand[1]) begin // Data In
            
        end else if (iPCommand[0]) begin // Timer
            rPO_DQStrobe[7:0] <= iTM_PO_DQStrobe[7:0];
        end else begin // default
            rPO_DQStrobe[7:0] <= iIDLE_PO_DQStrobe[7:0];
        end
    end
    
    // PO_DQ[31:0]
    always @ (*) begin
        //if (wPM_idle) begin // All PMs are in inactive state.
            
        //end else if (iPCommand[6]) begin // PHY Buffer Reset
            
        //end else if (iPCommand[5]) begin // PO Reset
            
        //end else if (iPCommand[4]) begin // PI Reset
            
        if (iPCommand[3]) begin // Command/Address Latch
            rPO_DQ[31:0] <= iCAL_PO_DQ[31:0];
        end else if (iPCommand[2]) begin // Data Out
            rPO_DQ[31:0] <= iDO_PO_DQ[31:0];
        //end else if (iPCommand[1]) begin // Data In
            
        //end else if (iPCommand[0]) begin // Timer
            
        end else begin // default
            rPO_DQ[31:0] <= iIDLE_PO_DQ[31:0];
        end
    end
    
    // PO_ChipEnable[7:0]
    always @ (*) begin
        if (wPM_idle) begin // All PMs are in inactive state.
            rPO_ChipEnable <= (iCEHold)? iCEHold_ChipEnable:iIDLE_PO_ChipEnable;
        //end else if (iPCommand[6]) begin // PHY Buffer Reset
            
        //end else if (iPCommand[5]) begin // PO Reset
            
        //end else if (iPCommand[4]) begin // PI Reset
            
        end else if (iPCommand[3]) begin // Command/Address Latch
            rPO_ChipEnable <= iCAL_PO_ChipEnable;
        end else if (iPCommand[2]) begin // Data Out
            rPO_ChipEnable <= iDO_PO_ChipEnable;
        end else if (iPCommand[1]) begin // Data In
            rPO_ChipEnable <= iDI_PO_ChipEnable;
        end else if (iPCommand[0]) begin // Timer
            rPO_ChipEnable <= iTM_PO_ChipEnable;
        end else begin // default
            rPO_ChipEnable <= iIDLE_PO_ChipEnable;
        end
    end
    
    // PO_ReadEnable[3:0]
    always @ (*) begin
        //if (wPM_idle) begin // All PMs are in inactive state.
            
        //end else if (iPCommand[6]) begin // PHY Buffer Reset
            
        //end else if (iPCommand[5]) begin // PO Reset
            
        //end else if (iPCommand[4]) begin // PI Reset
            
        //end else if (iPCommand[3]) begin // Command/Address Latch
            
        //end else if (iPCommand[2]) begin // Data Out
            
        if (iPCommand[1]) begin // Data In
            rPO_ReadEnable[3:0] <= iDI_PO_ReadEnable[3:0];
        end else if (iPCommand[0]) begin // Timer
            rPO_ReadEnable[3:0] <= iTM_PO_ReadEnable[3:0];
        end else begin // default
            rPO_ReadEnable[3:0] <= iIDLE_PO_ReadEnable[3:0];
        end
    end
    
    // PO_WriteEnable[3:0]
    always @ (*) begin
        //if (wPM_idle) begin // All PMs are in inactive state.
            
        //end else if (iPCommand[6]) begin // PHY Buffer Reset
            
        //end else if (iPCommand[5]) begin // PO Reset
            
        //end else if (iPCommand[4]) begin // PI Reset
            
        if (iPCommand[3]) begin // Command/Address Latch
            rPO_WriteEnable[3:0] <= iCAL_PO_WriteEnable[3:0];
        end else if (iPCommand[2]) begin // Data Out
            rPO_WriteEnable[3:0] <= iDO_PO_WriteEnable[3:0];
        end else if (iPCommand[1]) begin // Data In
            rPO_WriteEnable[3:0] <= iDI_PO_WriteEnable[3:0];
        end else if (iPCommand[0]) begin // Timer
            rPO_WriteEnable[3:0] <= iTM_PO_WriteEnable[3:0];
        end else begin // default
            rPO_WriteEnable[3:0] <= iIDLE_PO_WriteEnable[3:0];
        end
    end
    
    // PO_AddressLatchEnable[3:0]
    always @ (*) begin
        //if (wPM_idle) begin // All PMs are in inactive state.
            
        //end else if (iPCommand[6]) begin // PHY Buffer Reset
            
        //end else if (iPCommand[5]) begin // PO Reset
            
        //end else if (iPCommand[4]) begin // PI Reset
            
        if (iPCommand[3]) begin // Command/Address Latch
            rPO_AddressLatchEnable[3:0] <= iCAL_PO_AddressLatchEnable[3:0];
        end else if (iPCommand[2]) begin // Data Out
            rPO_AddressLatchEnable[3:0] <= iDO_PO_AddressLatchEnable[3:0];
        end else if (iPCommand[1]) begin // Data In
            rPO_AddressLatchEnable[3:0] <= iDI_PO_AddressLatchEnable[3:0];
        end else if (iPCommand[0]) begin // Timer
            rPO_AddressLatchEnable[3:0] <= iTM_PO_AddressLatchEnable[3:0];
        end else begin // default
            rPO_AddressLatchEnable[3:0] <= iIDLE_PO_AddressLatchEnable[3:0];
        end
    end
    
    // PO_CommandLatchEnable[3:0]
    always @ (*) begin
        //if (wPM_idle) begin // All PMs are in inactive state.
            
        //end else if (iPCommand[6]) begin // PHY Buffer Reset
            
        //end else if (iPCommand[5]) begin // PO Reset
            
        //end else if (iPCommand[4]) begin // PI Reset
            
        if (iPCommand[3]) begin // Command/Address Latch
            rPO_CommandLatchEnable[3:0] <= iCAL_PO_CommandLatchEnable[3:0];
        end else if (iPCommand[2]) begin // Data Out
            rPO_CommandLatchEnable[3:0] <= iDO_PO_CommandLatchEnable[3:0];
        end else if (iPCommand[1]) begin // Data In
            rPO_CommandLatchEnable[3:0] <= iDI_PO_CommandLatchEnable[3:0];
        end else if (iPCommand[0]) begin // Timer
            rPO_CommandLatchEnable[3:0] <= iTM_PO_CommandLatchEnable[3:0];
        end else begin // default
            rPO_CommandLatchEnable[3:0] <= iIDLE_PO_CommandLatchEnable[3:0];
        end
    end
    
    // DQSOutEnable
    always @ (*) begin
        //if (wPM_idle) begin // All PMs are in inactive state.
            
        if (iPCommand[6]) begin // PHY Buffer Reset
            rDQSOutEnable <= iPBR_DQSOutEnable;
        //end else if (iPCommand[5]) begin // PO Reset
            
        //end else if (iPCommand[4]) begin // PI Reset
            
        end else if (iPCommand[3]) begin // Command/Address Latch
            rDQSOutEnable <= iCAL_DQSOutEnable;
        end else if (iPCommand[2]) begin // Data Out
            rDQSOutEnable <= iDO_DQSOutEnable;
        end else if (iPCommand[1]) begin // Data In
            rDQSOutEnable <= iDI_DQSOutEnable;
        end else if (iPCommand[0]) begin // Timer
            rDQSOutEnable <= iTM_DQSOutEnable;
        end else begin // default
            rDQSOutEnable <= iIDLE_DQSOutEnable;
        end
    end
    
    // DQOutEnable
    always @ (*) begin
        //if (wPM_idle) begin // All PMs are in inactive state.
            
        //end else if (iPCommand[6]) begin // PHY Buffer Reset
            
        //end else if (iPCommand[5]) begin // PO Reset
            
        //end else if (iPCommand[4]) begin // PI Reset
            
        if (iPCommand[3]) begin // Command/Address Latch
            rDQOutEnable <= iCAL_DQOutEnable;
        end else if (iPCommand[2]) begin // Data Out
            rDQOutEnable <= iDO_DQOutEnable;
        end else if (iPCommand[1]) begin // Data In
            rDQOutEnable <= iDI_DQOutEnable;
        //end else if (iPCommand[0]) begin // Timer
            
        end else begin // default
            rDQOutEnable <= iIDLE_DQOutEnable;
        end
    end
    
    
    
    // Wire Connections
    
    //  - NPhy_Toggle Interface
    //      - RESET Interface
    assign oPI_Reset = rPI_Reset;
    assign oPI_BUFF_Reset = rPI_BUFF_Reset;
    
    assign oPO_Reset = rPO_Reset;
    
    //      - PI Interface
    assign oPI_BUFF_RE = rPI_BUFF_RE;
    assign oPI_BUFF_WE = rPI_BUFF_WE;
    assign oPI_BUFF_OutSel[2:0] = rPI_BUFF_OutSel[2:0];
    
    assign oPIDelayTapLoad = rPIDelayTapLoad;
    assign oPIDelayTap[4:0] = rPIDelayTap[4:0];
    
    //      - PO Interface
    assign oPO_DQStrobe[7:0] = rPO_DQStrobe[7:0];
    assign oPO_DQ[31:0] = rPO_DQ[31:0];
    assign oPO_ChipEnable = rPO_ChipEnable;
    assign oPO_ReadEnable[3:0] = rPO_ReadEnable[3:0];
    assign oPO_WriteEnable[3:0] = rPO_WriteEnable[3:0];
    assign oPO_AddressLatchEnable[3:0] = rPO_AddressLatchEnable[3:0];
    assign oPO_CommandLatchEnable[3:0] = rPO_CommandLatchEnable[3:0];
    
    //      - Pad Interface
    assign oDQSOutEnable = rDQSOutEnable;
    assign oDQOutEnable = rDQOutEnable;
    
endmodule

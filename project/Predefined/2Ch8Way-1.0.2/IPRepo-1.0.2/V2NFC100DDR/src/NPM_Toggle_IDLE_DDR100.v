//////////////////////////////////////////////////////////////////////////////////
// NPM_Toggle_IDLE_DDR100 for Cosmos OpenSSD
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
// Design Name: NPM_Toggle_IDLE_DDR100
// Module Name: NPM_Toggle_IDLE_DDR100
// File Name: NPM_Toggle_IDLE_DDR100.v
//
// Version: v1.0.0
//
// Description: NFC PM idle FSM
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module NPM_Toggle_IDLE_DDR100
#
(
    parameter NumberOfWays    =   4
)
(
    iNANDPowerOnEvent       ,
    oPI_Reset               ,
    oPI_BUFF_Reset          ,
    oPO_Reset               ,
    oPI_BUFF_RE             ,
    oPI_BUFF_WE             ,
    oPI_BUFF_OutSel         ,
    oPIDelayTapLoad         ,
    oPIDelayTap             ,
    oPO_DQStrobe            ,
    oPO_DQ                  ,
    oPO_ChipEnable          ,
    oPO_ReadEnable          ,
    oPO_WriteEnable         ,
    oPO_AddressLatchEnable  ,
    oPO_CommandLatchEnable  ,
    oDQSOutEnable           ,
    oDQOutEnable            
);
    input                           iNANDPowerOnEvent       ;
    output                          oPI_Reset               ;
    output                          oPI_BUFF_Reset          ;
    output                          oPO_Reset               ;
    output                          oPI_BUFF_RE             ;
    output                          oPI_BUFF_WE             ;
    output  [2:0]                   oPI_BUFF_OutSel         ;
    output                          oPIDelayTapLoad         ;
    output  [4:0]                   oPIDelayTap             ;
    output  [7:0]                   oPO_DQStrobe            ;
    output  [31:0]                  oPO_DQ                  ;
    output  [2*NumberOfWays - 1:0]  oPO_ChipEnable          ;
    output  [3:0]                   oPO_ReadEnable          ;
    output  [3:0]                   oPO_WriteEnable         ;
    output  [3:0]                   oPO_AddressLatchEnable  ;
    output  [3:0]                   oPO_CommandLatchEnable  ;
    output                          oDQSOutEnable           ;
    output                          oDQOutEnable            ;
    
    // NPhy_Toggle Interface
    //  - RESET Interface
    assign oPI_Reset = (iNANDPowerOnEvent)? 1'b1:1'b0;
    assign oPI_BUFF_Reset = 0;
    
    assign oPO_Reset = (iNANDPowerOnEvent)? 1'b1:1'b0;
    
    //  - PI Interface
    assign oPI_BUFF_RE = 0;
    assign oPI_BUFF_WE = 0;
    assign oPI_BUFF_OutSel[2:0] = 3'b000;
    //iPI_BUFF_Empty
    //iReadData[31:0]
    
    assign oPIDelayTapLoad = 0;
    assign oPIDelayTap[4:0] = 5'b11100; // 28(d)
    //iPIDelayReady
    
    //  - PO Interface
    assign oPO_DQStrobe[7:0] = 8'b1111_1111;
    assign oPO_DQ[31:0] = 0;
    assign oPO_ChipEnable = 0;
    assign oPO_ReadEnable[3:0] = 0;
    assign oPO_WriteEnable[3:0] = 0;
    assign oPO_AddressLatchEnable[3:0] = 0;
    assign oPO_CommandLatchEnable[3:0] = 0;
    
    //  - Pad Interface
    assign oDQSOutEnable = 0;
    assign oDQOutEnable = 0;
    
    //iReadyBusy[NumberOfWays - 1:0] // bypass
    
endmodule

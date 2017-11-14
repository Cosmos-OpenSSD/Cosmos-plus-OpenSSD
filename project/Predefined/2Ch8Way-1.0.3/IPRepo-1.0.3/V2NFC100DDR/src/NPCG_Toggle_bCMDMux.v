//////////////////////////////////////////////////////////////////////////////////
// NPCG_Toggle_bCMDMux for Cosmos OpenSSD
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
// Design Name: NPCG_Toggle_bCMDMux
// Module Name: NPCG_Toggle_bCMDMux
// File Name: NPCG_Toggle_bCMDMux.v
//
// Version: v1.0.0
//
// Description: NFC PCG layer command multiplexor
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module NPCG_Toggle_bCMDMux
#
(
    // Multiplexing by ibCMDReadySet[10:0]
    // not support parallel primitive command execution
    
    // [11]: MNC_getFT, get features (100101)
    // [10]: SCC_N_poe, NAND Power-ON Event (111110)
    // [ 9]: SCC_PI_reset, PHY. reset: PI (110010)
    // [ 8]: SCC_PO_reset, PHY. reset: PO (110000)
    // [ 7]: MNC_N_init, reset: NAND initializing (101100)
    // [ 6]: MNC_readST, read status (DDR) (101001)
    // [ 5]: MNC_readID, read ID (101011 + length[7:0](option, 00h/40h))
    // [ 4]: MNC_setFT, set features (SDR/DDR) (100000/100001 + length[7:0](option, 01h/02h/10h/30h))
    // [ 3]: BNC_B_erase, block erase: address write, execute (D0h) (001000)
    // [ 2]: BNC_P_program, page program: address write, data transfer (10h) (000100 + length[15:0](length, word))
    // [ 1]: BNC_P_read_DT00h, page read (DT): data transfer after read status (00h) (000011 + length[15:0](length, word))
    // [ 0]: BNC_P_read_AW30h, page read (AW): address write (30h) (000000)
    
    parameter NumofbCMD = 12, // number of blocking commands
    parameter NumberOfWays    =   4
)
(
    ibCMDReadySet                       ,
    iIDLE_WriteReady                    ,
    iIDLE_ReadData                      ,
    iIDLE_ReadLast                      ,
    iIDLE_ReadValid                     ,
    iIDLE_PM_PCommand                   ,
    iIDLE_PM_PCommandOption             ,
    iIDLE_PM_TargetWay                  ,
    iIDLE_PM_NumOfData                  ,
    iIDLE_PM_CASelect                   ,
    iIDLE_PM_CAData                     ,
    iIDLE_PM_WriteData                  ,
    iIDLE_PM_WriteLast                  ,
    iIDLE_PM_WriteValid                 ,
    iIDLE_PM_ReadReady                  ,
    iMNC_getFT_ReadData                 ,
    iMNC_getFT_ReadLast                 ,
    iMNC_getFT_ReadValid                ,
    iMNC_getFT_PM_PCommand              ,
    iMNC_getFT_PM_PCommandOption        ,
    iMNC_getFT_PM_TargetWay             ,
    iMNC_getFT_PM_NumOfData             ,
    iMNC_getFT_PM_CASelect              ,
    iMNC_getFT_PM_CAData                ,
    iMNC_getFT_PM_ReadReady             ,
    iSCC_N_poe_PM_PCommand              ,
    iSCC_N_poe_PM_PCommandOption        ,
    iSCC_N_poe_PM_NumOfData             ,
    iSCC_PI_reset_PM_PCommand           ,
    iSCC_PO_reset_PM_PCommand           ,
    iMNC_N_init_PM_PCommand             ,
    iMNC_N_init_PM_PCommandOption       ,
    iMNC_N_init_PM_TargetWay            ,
    iMNC_N_init_PM_NumOfData            ,
    iMNC_N_init_PM_CASelect             ,
    iMNC_N_init_PM_CAData               ,
    iMNC_readST_ReadData                ,
    iMNC_readST_ReadLast                ,
    iMNC_readST_ReadValid               ,
    iMNC_readST_PM_PCommand             ,
    iMNC_readST_PM_PCommandOption       ,
    iMNC_readST_PM_TargetWay            ,
    iMNC_readST_PM_NumOfData            ,
    iMNC_readST_PM_CASelect             ,
    iMNC_readST_PM_CAData               ,
    iMNC_readST_PM_ReadReady            ,
    iMNC_setFT_WriteReady               ,
    iMNC_setFT_PM_PCommand              ,
    iMNC_setFT_PM_PCommandOption        ,
    iMNC_setFT_PM_TargetWay             ,
    iMNC_setFT_PM_NumOfData             ,
    iMNC_setFT_PM_CASelect              ,
    iMNC_setFT_PM_CAData                ,
    iMNC_setFT_PM_WriteData             ,
    iMNC_setFT_PM_WriteLast             ,
    iMNC_setFT_PM_WriteValid            ,
    iBNC_B_erase_PM_PCommand            ,
    iBNC_B_erase_PM_PCommandOption      ,
    iBNC_B_erase_PM_TargetWay           ,
    iBNC_B_erase_PM_NumOfData           ,
    iBNC_B_erase_PM_CASelect            ,
    iBNC_B_erase_PM_CAData              ,
    iBNC_P_prog_WriteReady              ,
    iBNC_P_prog_PM_PCommand             ,
    iBNC_P_prog_PM_PCommandOption       ,
    iBNC_P_prog_PM_TargetWay            ,
    iBNC_P_prog_PM_NumOfData            ,
    iBNC_P_prog_PM_CASelect             ,
    iBNC_P_prog_PM_CAData               ,
    iBNC_P_prog_PM_WriteData            ,
    iBNC_P_prog_PM_WriteLast            ,
    iBNC_P_prog_PM_WriteValid           ,
    iBNC_P_read_DT00h_ReadData          ,
    iBNC_P_read_DT00h_ReadLast          ,
    iBNC_P_read_DT00h_ReadValid         ,
    iBNC_P_read_DT00h_PM_PCommand       ,
    iBNC_P_read_DT00h_PM_PCommandOption ,
    iBNC_P_read_DT00h_PM_TargetWay      ,
    iBNC_P_read_DT00h_PM_NumOfData      ,
    iBNC_P_read_DT00h_PM_CASelect       ,
    iBNC_P_read_DT00h_PM_CAData         ,
    iBNC_P_read_DT00h_PM_ReadReady      ,
    iBNC_P_read_AW30h_PM_PCommand       ,
    iBNC_P_read_AW30h_PM_PCommandOption ,
    iBNC_P_read_AW30h_PM_TargetWay      ,
    iBNC_P_read_AW30h_PM_NumOfData      ,
    iBNC_P_read_AW30h_PM_CASelect       ,
    iBNC_P_read_AW30h_PM_CAData         ,
    oWriteReady                         ,
    oReadData                           ,
    oReadLast                           ,
    oReadValid                          ,
    oPM_PCommand                        ,
    oPM_PCommandOption                  ,
    oPM_TargetWay                       ,
    oPM_NumOfData                       ,
    oPM_CASelect                        ,
    oPM_CAData                          ,
    oPM_WriteData                       ,
    oPM_WriteLast                       ,
    oPM_WriteValid                      ,
    oPM_ReadReady
);
    input   [NumofbCMD-1:0]             ibCMDReadySet                       ;
    input                               iIDLE_WriteReady                    ;
    input   [31:0]                      iIDLE_ReadData                      ;
    input                               iIDLE_ReadLast                      ;
    input                               iIDLE_ReadValid                     ;
    input   [7:0]                       iIDLE_PM_PCommand                   ;
    input   [2:0]                       iIDLE_PM_PCommandOption             ;
    input   [NumberOfWays - 1:0]        iIDLE_PM_TargetWay                  ;
    input   [15:0]                      iIDLE_PM_NumOfData                  ;
    input                               iIDLE_PM_CASelect                   ;
    input   [7:0]                       iIDLE_PM_CAData                     ;
    input   [31:0]                      iIDLE_PM_WriteData                  ;
    input                               iIDLE_PM_WriteLast                  ;
    input                               iIDLE_PM_WriteValid                 ;
    input                               iIDLE_PM_ReadReady                  ;
    input   [31:0]                      iMNC_getFT_ReadData                 ;
    input                               iMNC_getFT_ReadLast                 ;
    input                               iMNC_getFT_ReadValid                ;
    input   [7:0]                       iMNC_getFT_PM_PCommand              ;
    input   [2:0]                       iMNC_getFT_PM_PCommandOption        ;
    input   [NumberOfWays - 1:0]        iMNC_getFT_PM_TargetWay             ;
    input   [15:0]                      iMNC_getFT_PM_NumOfData             ;
    input                               iMNC_getFT_PM_CASelect              ;
    input   [7:0]                       iMNC_getFT_PM_CAData                ;
    input                               iMNC_getFT_PM_ReadReady             ;
    input   [7:0]                       iSCC_N_poe_PM_PCommand              ;
    input   [2:0]                       iSCC_N_poe_PM_PCommandOption        ;
    input   [15:0]                      iSCC_N_poe_PM_NumOfData             ;
    input   [7:0]                       iSCC_PI_reset_PM_PCommand           ;
    input   [7:0]                       iSCC_PO_reset_PM_PCommand           ;
    input   [7:0]                       iMNC_N_init_PM_PCommand             ;
    input   [2:0]                       iMNC_N_init_PM_PCommandOption       ;
    input   [NumberOfWays - 1:0]        iMNC_N_init_PM_TargetWay            ;
    input   [15:0]                      iMNC_N_init_PM_NumOfData            ;
    input                               iMNC_N_init_PM_CASelect             ;
    input   [7:0]                       iMNC_N_init_PM_CAData               ;
    input   [31:0]                      iMNC_readST_ReadData                ;
    input                               iMNC_readST_ReadLast                ;
    input                               iMNC_readST_ReadValid               ;
    input   [7:0]                       iMNC_readST_PM_PCommand             ;
    input   [2:0]                       iMNC_readST_PM_PCommandOption       ;
    input   [NumberOfWays - 1:0]        iMNC_readST_PM_TargetWay            ;
    input   [15:0]                      iMNC_readST_PM_NumOfData            ;
    input                               iMNC_readST_PM_CASelect             ;
    input   [7:0]                       iMNC_readST_PM_CAData               ;
    input                               iMNC_readST_PM_ReadReady            ;
    input                               iMNC_setFT_WriteReady               ;
    input   [7:0]                       iMNC_setFT_PM_PCommand              ;
    input   [2:0]                       iMNC_setFT_PM_PCommandOption        ;
    input   [NumberOfWays - 1:0]        iMNC_setFT_PM_TargetWay             ;
    input   [15:0]                      iMNC_setFT_PM_NumOfData             ;
    input                               iMNC_setFT_PM_CASelect              ;
    input   [7:0]                       iMNC_setFT_PM_CAData                ;
    input   [31:0]                      iMNC_setFT_PM_WriteData             ;
    input                               iMNC_setFT_PM_WriteLast             ;
    input                               iMNC_setFT_PM_WriteValid            ;
    input   [7:0]                       iBNC_B_erase_PM_PCommand            ;
    input   [2:0]                       iBNC_B_erase_PM_PCommandOption      ;
    input   [NumberOfWays - 1:0]        iBNC_B_erase_PM_TargetWay           ;
    input   [15:0]                      iBNC_B_erase_PM_NumOfData           ;
    input                               iBNC_B_erase_PM_CASelect            ;
    input   [7:0]                       iBNC_B_erase_PM_CAData              ;
    input                               iBNC_P_prog_WriteReady              ;
    input   [7:0]                       iBNC_P_prog_PM_PCommand             ;
    input   [2:0]                       iBNC_P_prog_PM_PCommandOption       ;
    input   [NumberOfWays - 1:0]        iBNC_P_prog_PM_TargetWay            ;
    input   [15:0]                      iBNC_P_prog_PM_NumOfData            ;
    input                               iBNC_P_prog_PM_CASelect             ;
    input   [7:0]                       iBNC_P_prog_PM_CAData               ;
    input   [31:0]                      iBNC_P_prog_PM_WriteData            ;
    input                               iBNC_P_prog_PM_WriteLast            ;
    input                               iBNC_P_prog_PM_WriteValid           ;
    input   [31:0]                      iBNC_P_read_DT00h_ReadData          ;
    input                               iBNC_P_read_DT00h_ReadLast          ;
    input                               iBNC_P_read_DT00h_ReadValid         ;
    input   [7:0]                       iBNC_P_read_DT00h_PM_PCommand       ;
    input   [2:0]                       iBNC_P_read_DT00h_PM_PCommandOption ;
    input   [NumberOfWays - 1:0]        iBNC_P_read_DT00h_PM_TargetWay      ;
    input   [15:0]                      iBNC_P_read_DT00h_PM_NumOfData      ;
    input                               iBNC_P_read_DT00h_PM_CASelect       ;
    input   [7:0]                       iBNC_P_read_DT00h_PM_CAData         ;
    input                               iBNC_P_read_DT00h_PM_ReadReady      ;
    input   [7:0]                       iBNC_P_read_AW30h_PM_PCommand       ;
    input   [2:0]                       iBNC_P_read_AW30h_PM_PCommandOption ;
    input   [NumberOfWays - 1:0]        iBNC_P_read_AW30h_PM_TargetWay      ;
    input   [15:0]                      iBNC_P_read_AW30h_PM_NumOfData      ;
    input                               iBNC_P_read_AW30h_PM_CASelect       ;
    input   [7:0]                       iBNC_P_read_AW30h_PM_CAData         ;
    output                              oWriteReady                         ;
    output  [31:0]                      oReadData                           ;
    output                              oReadLast                           ;
    output                              oReadValid                          ;
    output  [7:0]                       oPM_PCommand                        ;
    output  [2:0]                       oPM_PCommandOption                  ;
    output  [NumberOfWays - 1:0]        oPM_TargetWay                       ;
    output  [15:0]                      oPM_NumOfData                       ;
    output                              oPM_CASelect                        ;
    output  [7:0]                       oPM_CAData                          ;
    output  [31:0]                      oPM_WriteData                       ;
    output                              oPM_WriteLast                       ;
    output                              oPM_WriteValid                      ;
    output                              oPM_ReadReady                       ;
    
    // Internal Wires/Regs
    wire    [NumofbCMD-1:0]         ibCMDActive             ;
    //wire                            wbCMD_idle              ;
    
    //  - Dispatcher Interface
    //      - Data Write Channel
    reg                             rWriteReady             ;
    
    //      - Data Read Channel
    reg     [31:0]                  rReadData               ;
    reg                             rReadLast               ;
    reg                             rReadValid              ;
    
    //  - NPCG_Toggle Interface
    reg     [7:0]                   rPM_PCommand            ;
    reg     [2:0]                   rPM_PCommandOption      ;
    reg     [NumberOfWays - 1:0]    rPM_TargetWay           ;
    reg     [15:0]                  rPM_NumOfData           ;
    
    reg                             rPM_CASelect            ;
    reg     [7:0]                   rPM_CAData              ;
    
    reg     [31:0]                  rPM_WriteData           ;
    reg                             rPM_WriteLast           ;
    reg                             rPM_WriteValid          ;
    
    reg                             rPM_ReadReady           ;
    
    
    
    // Control Signals
    //assign wbCMD_idle = ~( &(ibCMDReadySet[NumofbCMD-1:0]) );
    assign ibCMDActive[NumofbCMD-1:0] = ~ibCMDReadySet[NumofbCMD-1:0];
    
    
    
    // Mux
    
    // Dispatcher Interface
    //  - Data Write Channel
    // rWriteReady
    always @ (*) begin
        //if (wbCMD_idle) begin // All blocking command machines are in inactive state.
            
        //end else if (ibCMDActive[11]) begin // MNC_getFT
            
        //end else if (ibCMDActive[10]) begin // SCC_N_poe
            
        //end else if (ibCMDActive[ 9]) begin // SCC_PI_reset
            
        //end else if (ibCMDActive[ 8]) begin // SCC_PO_reset
            
        //end else if (ibCMDActive[ 7]) begin // MNC_N_init
            
        //end else if (ibCMDActive[ 6]) begin // MNC_readST
            
        //end else if (ibCMDActive[ 5]) begin // MNC_readID
            
        if (ibCMDActive[ 4]) begin // MNC_setFT
            rWriteReady <= iMNC_setFT_WriteReady;
        //end else if (ibCMDActive[ 3]) begin // BNC_B_erase
            
        end else if (ibCMDActive[ 2]) begin // BNC_P_program
            rWriteReady <= iBNC_P_prog_WriteReady;
        //end else if (ibCMDActive[ 1]) begin // BNC_P_read_DT00h
            
        //end else if (ibCMDActive[ 0]) begin // BNC_P_read_AW30h
            
        end else begin // default
            rWriteReady <= iIDLE_WriteReady;
        end
    end
    
    //  - Data Read Channel
    // rReadData[31:0]
    always @ (*) begin
        //if (wbCMD_idle) begin // All blocking command machines are in inactive state.
            
        if (ibCMDActive[11]) begin // MNC_getFT
            rReadData[31:0] <= iMNC_getFT_ReadData[31:0];
        //end else if (ibCMDActive[10]) begin // SCC_N_poe
            
        //end else if (ibCMDActive[ 9]) begin // SCC_PI_reset
            
        //end else if (ibCMDActive[ 8]) begin // SCC_PO_reset
            
        //end else if (ibCMDActive[ 7]) begin // MNC_N_init
            
        end else if (ibCMDActive[ 6]) begin // MNC_readST
            rReadData[31:0] <= iMNC_readST_ReadData[31:0];
        //end else if (ibCMDActive[ 5]) begin // MNC_readID
            
        //end else if (ibCMDActive[ 4]) begin // MNC_setFT
            
        //end else if (ibCMDActive[ 3]) begin // BNC_B_erase
            
        //end else if (ibCMDActive[ 2]) begin // BNC_P_program
            
        end else if (ibCMDActive[ 1]) begin // BNC_P_read_DT00h
            rReadData[31:0] <= iBNC_P_read_DT00h_ReadData[31:0];
        //end else if (ibCMDActive[ 0]) begin // BNC_P_read_AW30h
            
        end else begin // default
            rReadData[31:0] <= iIDLE_ReadData[31:0];
        end
    end
    
    // rReadLast
    always @ (*) begin
        //if (wbCMD_idle) begin // All blocking command machines are in inactive state.
            
        if (ibCMDActive[11]) begin // MNC_getFT
            rReadLast <= iMNC_getFT_ReadLast;
        //end else if (ibCMDActive[10]) begin // SCC_N_poe
            
        //end else if (ibCMDActive[ 9]) begin // SCC_PI_reset
            
        //end else if (ibCMDActive[ 8]) begin // SCC_PO_reset
            
        //end else if (ibCMDActive[ 7]) begin // MNC_N_init
            
        end else if (ibCMDActive[ 6]) begin // MNC_readST
            rReadLast <= iMNC_readST_ReadLast;
        //end else if (ibCMDActive[ 5]) begin // MNC_readID
            
        //end else if (ibCMDActive[ 4]) begin // MNC_setFT
            
        //end else if (ibCMDActive[ 3]) begin // BNC_B_erase
            
        //end else if (ibCMDActive[ 2]) begin // BNC_P_program
            
        end else if (ibCMDActive[ 1]) begin // BNC_P_read_DT00h
            rReadLast <= iBNC_P_read_DT00h_ReadLast;
        //end else if (ibCMDActive[ 0]) begin // BNC_P_read_AW30h
            
        end else begin // default
            rReadLast <= iIDLE_ReadLast;
        end
    end
    
    // rReadValid
    always @ (*) begin
        //if (wbCMD_idle) begin // All blocking command machines are in inactive state.
            
        if (ibCMDActive[11]) begin // MNC_getFT
            rReadValid <= iMNC_getFT_ReadValid;
        //end else if (ibCMDActive[10]) begin // SCC_N_poe
            
        //end else if (ibCMDActive[ 9]) begin // SCC_PI_reset
            
        //end else if (ibCMDActive[ 8]) begin // SCC_PO_reset
            
        //end else if (ibCMDActive[ 7]) begin // MNC_N_init
            
        end else if (ibCMDActive[ 6]) begin // MNC_readST
            rReadValid <= iMNC_readST_ReadValid;
        //end else if (ibCMDActive[ 5]) begin // MNC_readID
            
        //end else if (ibCMDActive[ 4]) begin // MNC_setFT
            
        //end else if (ibCMDActive[ 3]) begin // BNC_B_erase
            
        //end else if (ibCMDActive[ 2]) begin // BNC_P_program
            
        end else if (ibCMDActive[ 1]) begin // BNC_P_read_DT00h
            rReadValid <= iBNC_P_read_DT00h_ReadValid;
        //end else if (ibCMDActive[ 0]) begin // BNC_P_read_AW30h
            
        end else begin // default
            rReadValid <= iIDLE_ReadValid;
        end
    end
    
    // NPCG_Toggle Interface
    // rPM_PCommand[7:0]
    always @ (*) begin
        //if (wbCMD_idle) begin // All blocking command machines are in inactive state.
            
        if (ibCMDActive[11]) begin // MNC_getFT
            rPM_PCommand[7:0] <= iMNC_getFT_PM_PCommand[7:0];
        end else if (ibCMDActive[10]) begin // SCC_N_poe
            rPM_PCommand[7:0] <= iSCC_N_poe_PM_PCommand[7:0];
        end else if (ibCMDActive[ 9]) begin // SCC_PI_reset
            rPM_PCommand[7:0] <= iSCC_PI_reset_PM_PCommand[7:0];
        end else if (ibCMDActive[ 8]) begin // SCC_PO_reset
            rPM_PCommand[7:0] <= iSCC_PO_reset_PM_PCommand[7:0];
        end else if (ibCMDActive[ 7]) begin // MNC_N_init
            rPM_PCommand[7:0] <= iMNC_N_init_PM_PCommand[7:0];
        end else if (ibCMDActive[ 6]) begin // MNC_readST
            rPM_PCommand[7:0] <= iMNC_readST_PM_PCommand[7:0];
        //end else if (ibCMDActive[ 5]) begin // MNC_readID
            
        end else if (ibCMDActive[ 4]) begin // MNC_setFT
            rPM_PCommand[7:0] <= iMNC_setFT_PM_PCommand[7:0];
        end else if (ibCMDActive[ 3]) begin // BNC_B_erase
            rPM_PCommand[7:0] <= iBNC_B_erase_PM_PCommand[7:0];
        end else if (ibCMDActive[ 2]) begin // BNC_P_program
            rPM_PCommand[7:0] <= iBNC_P_prog_PM_PCommand[7:0];
        end else if (ibCMDActive[ 1]) begin // BNC_P_read_DT00h
            rPM_PCommand[7:0] <= iBNC_P_read_DT00h_PM_PCommand[7:0];
        end else if (ibCMDActive[ 0]) begin // BNC_P_read_AW30h
            rPM_PCommand[7:0] <= iBNC_P_read_AW30h_PM_PCommand[7:0];
        end else begin // default
            rPM_PCommand[7:0] <= iIDLE_PM_PCommand[7:0];
        end
    end
    
    // rPM_PCommandOption[2:0]
    always @ (*) begin
        //if (wbCMD_idle) begin // All blocking command machines are in inactive state.
            
        if (ibCMDActive[11]) begin // MNC_getFT
            rPM_PCommandOption[2:0] <= iMNC_getFT_PM_PCommandOption[2:0];
        end else if (ibCMDActive[10]) begin // SCC_N_poe
            rPM_PCommandOption[2:0] <= iSCC_N_poe_PM_PCommandOption[2:0];
        //end else if (ibCMDActive[ 9]) begin // SCC_PI_reset
            
        //end else if (ibCMDActive[ 8]) begin // SCC_PO_reset
            
        end else if (ibCMDActive[ 7]) begin // MNC_N_init
            rPM_PCommandOption[2:0] <= iMNC_N_init_PM_PCommandOption[2:0];
        end else if (ibCMDActive[ 6]) begin // MNC_readST
            rPM_PCommandOption[2:0] <= iMNC_readST_PM_PCommandOption[2:0];
        //end else if (ibCMDActive[ 5]) begin // MNC_readID
            
        end else if (ibCMDActive[ 4]) begin // MNC_setFT
            rPM_PCommandOption[2:0] <= iMNC_setFT_PM_PCommandOption[2:0];
        end else if (ibCMDActive[ 3]) begin // BNC_B_erase
            rPM_PCommandOption[2:0] <= iBNC_B_erase_PM_PCommandOption[2:0];
        end else if (ibCMDActive[ 2]) begin // BNC_P_program
            rPM_PCommandOption[2:0] <= iBNC_P_prog_PM_PCommandOption[2:0];
        end else if (ibCMDActive[ 1]) begin // BNC_P_read_DT00h
            rPM_PCommandOption[2:0] <= iBNC_P_read_DT00h_PM_PCommandOption[2:0];
        end else if (ibCMDActive[ 0]) begin // BNC_P_read_AW30h
            rPM_PCommandOption[2:0] <= iBNC_P_read_AW30h_PM_PCommandOption[2:0];
        end else begin // default
            rPM_PCommandOption[2:0] <= iIDLE_PM_PCommandOption[2:0];
        end
    end
    
    // rPM_TargetWay[NumberOfWays - 1:0]
    always @ (*) begin
        //if (wbCMD_idle) begin // All blocking command machines are in inactive state.
            
        if (ibCMDActive[11]) begin // MNC_getFT
            rPM_TargetWay[NumberOfWays - 1:0] <= iMNC_getFT_PM_TargetWay[NumberOfWays - 1:0];
        //end else if (ibCMDActive[10]) begin // SCC_N_poe
            
        //end else if (ibCMDActive[ 9]) begin // SCC_PI_reset
            
        //end else if (ibCMDActive[ 8]) begin // SCC_PO_reset
            
        end else if (ibCMDActive[ 7]) begin // MNC_N_init
            rPM_TargetWay[NumberOfWays - 1:0] <= iMNC_N_init_PM_TargetWay[NumberOfWays - 1:0];
        end else if (ibCMDActive[ 6]) begin // MNC_readST
            rPM_TargetWay[NumberOfWays - 1:0] <= iMNC_readST_PM_TargetWay[NumberOfWays - 1:0];
        //end else if (ibCMDActive[ 5]) begin // MNC_readID
            
        end else if (ibCMDActive[ 4]) begin // MNC_setFT
            rPM_TargetWay[NumberOfWays - 1:0] <= iMNC_setFT_PM_TargetWay[NumberOfWays - 1:0];
        end else if (ibCMDActive[ 3]) begin // BNC_B_erase
            rPM_TargetWay[NumberOfWays - 1:0] <= iBNC_B_erase_PM_TargetWay[NumberOfWays - 1:0];
        end else if (ibCMDActive[ 2]) begin // BNC_P_program
            rPM_TargetWay[NumberOfWays - 1:0] <= iBNC_P_prog_PM_TargetWay[NumberOfWays - 1:0];
        end else if (ibCMDActive[ 1]) begin // BNC_P_read_DT00h
            rPM_TargetWay[NumberOfWays - 1:0] <= iBNC_P_read_DT00h_PM_TargetWay[NumberOfWays - 1:0];
        end else if (ibCMDActive[ 0]) begin // BNC_P_read_AW30h
            rPM_TargetWay[NumberOfWays - 1:0] <= iBNC_P_read_AW30h_PM_TargetWay[NumberOfWays - 1:0];
        end else begin // default
            rPM_TargetWay[NumberOfWays - 1:0] <= iIDLE_PM_TargetWay[NumberOfWays - 1:0];
        end
    end
    
    // rPM_NumOfData[15:0]
    always @ (*) begin
        //if (wbCMD_idle) begin // All blocking command machines are in inactive state.
            
        if (ibCMDActive[11]) begin // MNC_getFT
            rPM_NumOfData[15:0] <= iMNC_getFT_PM_NumOfData[15:0];
        end else if (ibCMDActive[10]) begin // SCC_N_poe
            rPM_NumOfData[15:0] <= iSCC_N_poe_PM_NumOfData[15:0];
        //end else if (ibCMDActive[ 9]) begin // SCC_PI_reset
            
        //end else if (ibCMDActive[ 8]) begin // SCC_PO_reset
            
        end else if (ibCMDActive[ 7]) begin // MNC_N_init
            rPM_NumOfData[15:0] <= iMNC_N_init_PM_NumOfData[15:0];
        end else if (ibCMDActive[ 6]) begin // MNC_readST
            rPM_NumOfData[15:0] <= iMNC_readST_PM_NumOfData[15:0];
        //end else if (ibCMDActive[ 5]) begin // MNC_readID
            
        end else if (ibCMDActive[ 4]) begin // MNC_setFT
            rPM_NumOfData[15:0] <= iMNC_setFT_PM_NumOfData[15:0];
        end else if (ibCMDActive[ 3]) begin // BNC_B_erase
            rPM_NumOfData[15:0] <= iBNC_B_erase_PM_NumOfData[15:0];
        end else if (ibCMDActive[ 2]) begin // BNC_P_program
            rPM_NumOfData[15:0] <= iBNC_P_prog_PM_NumOfData[15:0];
        end else if (ibCMDActive[ 1]) begin // BNC_P_read_DT00h
            rPM_NumOfData[15:0] <= iBNC_P_read_DT00h_PM_NumOfData[15:0];
        end else if (ibCMDActive[ 0]) begin // BNC_P_read_AW30h
            rPM_NumOfData[15:0] <= iBNC_P_read_AW30h_PM_NumOfData[15:0];
        end else begin // default
            rPM_NumOfData[15:0] <= iIDLE_PM_NumOfData[15:0];
        end
    end
    
    // rPM_CASelect
    always @ (*) begin
        //if (wbCMD_idle) begin // All blocking command machines are in inactive state.
            
        if (ibCMDActive[11]) begin // MNC_getFT
            rPM_CASelect <= iMNC_getFT_PM_CASelect;
        //end else if (ibCMDActive[10]) begin // SCC_N_poe
            
        //end else if (ibCMDActive[ 9]) begin // SCC_PI_reset
            
        //end else if (ibCMDActive[ 8]) begin // SCC_PO_reset
            
        end else if (ibCMDActive[ 7]) begin // MNC_N_init
            rPM_CASelect <= iMNC_N_init_PM_CASelect;
        end else if (ibCMDActive[ 6]) begin // MNC_readST
            rPM_CASelect <= iMNC_readST_PM_CASelect;
        //end else if (ibCMDActive[ 5]) begin // MNC_readID
            
        end else if (ibCMDActive[ 4]) begin // MNC_setFT
            rPM_CASelect <= iMNC_setFT_PM_CASelect;
        end else if (ibCMDActive[ 3]) begin // BNC_B_erase
            rPM_CASelect <= iBNC_B_erase_PM_CASelect;
        end else if (ibCMDActive[ 2]) begin // BNC_P_program
            rPM_CASelect <= iBNC_P_prog_PM_CASelect;
        end else if (ibCMDActive[ 1]) begin // BNC_P_read_DT00h
            rPM_CASelect <= iBNC_P_read_DT00h_PM_CASelect;
        end else if (ibCMDActive[ 0]) begin // BNC_P_read_AW30h
            rPM_CASelect <= iBNC_P_read_AW30h_PM_CASelect;
        end else begin // default
            rPM_CASelect <= iIDLE_PM_CASelect;
        end
    end
    
    // rPM_CAData[7:0]
    always @ (*) begin
        //if (wbCMD_idle) begin // All blocking command machines are in inactive state.
            
        if (ibCMDActive[11]) begin // MNC_getFT
            rPM_CAData[7:0] <= iMNC_getFT_PM_CAData[7:0];
        //end else if (ibCMDActive[10]) begin // SCC_N_poe
            
        //end else if (ibCMDActive[ 9]) begin // SCC_PI_reset
            
        //end else if (ibCMDActive[ 8]) begin // SCC_PO_reset
            
        end else if (ibCMDActive[ 7]) begin // MNC_N_init
            rPM_CAData[7:0] <= iMNC_N_init_PM_CAData[7:0];
        end else if (ibCMDActive[ 6]) begin // MNC_readST
            rPM_CAData[7:0] <= iMNC_readST_PM_CAData[7:0];
        //end else if (ibCMDActive[ 5]) begin // MNC_readID
            
        end else if (ibCMDActive[ 4]) begin // MNC_setFT
            rPM_CAData[7:0] <= iMNC_setFT_PM_CAData[7:0];
        end else if (ibCMDActive[ 3]) begin // BNC_B_erase
            rPM_CAData[7:0] <= iBNC_B_erase_PM_CAData[7:0];
        end else if (ibCMDActive[ 2]) begin // BNC_P_program
            rPM_CAData[7:0] <= iBNC_P_prog_PM_CAData[7:0];
        end else if (ibCMDActive[ 1]) begin // BNC_P_read_DT00h
            rPM_CAData[7:0] <= iBNC_P_read_DT00h_PM_CAData[7:0];
        end else if (ibCMDActive[ 0]) begin // BNC_P_read_AW30h
            rPM_CAData[7:0] <= iBNC_P_read_AW30h_PM_CAData[7:0];
        end else begin // default
            rPM_CAData[7:0] <= iIDLE_PM_CAData[7:0];
        end
    end
    
    // rPM_WriteData[31:0]
    always @ (*) begin
        //if (wbCMD_idle) begin // All blocking command machines are in inactive state.
            
        //end else if (ibCMDActive[11]) begin // MNC_getFT
            
        //end else if (ibCMDActive[10]) begin // SCC_N_poe
            
        //end else if (ibCMDActive[ 9]) begin // SCC_PI_reset
            
        //end else if (ibCMDActive[ 8]) begin // SCC_PO_reset
            
        //end else if (ibCMDActive[ 7]) begin // MNC_N_init
            
        //end else if (ibCMDActive[ 6]) begin // MNC_readST
            
        //end else if (ibCMDActive[ 5]) begin // MNC_readID
            
        if (ibCMDActive[ 4]) begin // MNC_setFT
            rPM_WriteData[31:0] <= iMNC_setFT_PM_WriteData[31:0];
        //end else if (ibCMDActive[ 3]) begin // BNC_B_erase
            
        end else if (ibCMDActive[ 2]) begin // BNC_P_program
            rPM_WriteData[31:0] <= iBNC_P_prog_PM_WriteData[31:0];
        //end else if (ibCMDActive[ 1]) begin // BNC_P_read_DT00h
            
        //end else if (ibCMDActive[ 0]) begin // BNC_P_read_AW30h
            
        end else begin // default
            rPM_WriteData[31:0] <= iIDLE_PM_WriteData[31:0];
        end
    end
    
    // rPM_WriteLast
    always @ (*) begin
        //if (wbCMD_idle) begin // All blocking command machines are in inactive state.
            
        //end else if (ibCMDActive[11]) begin // MNC_getFT
            
        //end else if (ibCMDActive[10]) begin // SCC_N_poe
            
        //end else if (ibCMDActive[ 9]) begin // SCC_PI_reset
            
        //end else if (ibCMDActive[ 8]) begin // SCC_PO_reset
            
        //end else if (ibCMDActive[ 7]) begin // MNC_N_init
            
        //end else if (ibCMDActive[ 6]) begin // MNC_readST
            
        //end else if (ibCMDActive[ 5]) begin // MNC_readID
            
        if (ibCMDActive[ 4]) begin // MNC_setFT
            rPM_WriteLast <= iMNC_setFT_PM_WriteLast;
        //end else if (ibCMDActive[ 3]) begin // BNC_B_erase
            
        end else if (ibCMDActive[ 2]) begin // BNC_P_program
            rPM_WriteLast <= iBNC_P_prog_PM_WriteLast;
        //end else if (ibCMDActive[ 1]) begin // BNC_P_read_DT00h
            
        //end else if (ibCMDActive[ 0]) begin // BNC_P_read_AW30h
            
        end else begin // default
            rPM_WriteLast <= iIDLE_PM_WriteLast;
        end
    end
    
    // rPM_WriteValid
    always @ (*) begin
        //if (wbCMD_idle) begin // All blocking command machines are in inactive state.
            
        //end else if (ibCMDActive[11]) begin // MNC_getFT
            
        //end else if (ibCMDActive[10]) begin // SCC_N_poe
            
        //end else if (ibCMDActive[ 9]) begin // SCC_PI_reset
            
        //end else if (ibCMDActive[ 8]) begin // SCC_PO_reset
            
        //end else if (ibCMDActive[ 7]) begin // MNC_N_init
            
        //end else if (ibCMDActive[ 6]) begin // MNC_readST
            
        //end else if (ibCMDActive[ 5]) begin // MNC_readID
            
        if (ibCMDActive[ 4]) begin // MNC_setFT
            rPM_WriteValid <= iMNC_setFT_PM_WriteValid;
        //end else if (ibCMDActive[ 3]) begin // BNC_B_erase
            
        end else if (ibCMDActive[ 2]) begin // BNC_P_program
            rPM_WriteValid <= iBNC_P_prog_PM_WriteValid;
        //end else if (ibCMDActive[ 1]) begin // BNC_P_read_DT00h
            
        //end else if (ibCMDActive[ 0]) begin // BNC_P_read_AW30h
            
        end else begin // default
            rPM_WriteValid <= iIDLE_PM_WriteValid;
        end
    end
    
    // rPM_ReadReady
    always @ (*) begin
        //if (wbCMD_idle) begin // All blocking command machines are in inactive state.
            
        if (ibCMDActive[11]) begin // MNC_getFT
            rPM_ReadReady <= iMNC_getFT_PM_ReadReady;
        //end else if (ibCMDActive[10]) begin // SCC_N_poe
            
        //end else if (ibCMDActive[ 9]) begin // SCC_PI_reset
            
        //end else if (ibCMDActive[ 8]) begin // SCC_PO_reset
            
        //end else if (ibCMDActive[ 7]) begin // MNC_N_init
            
        end else if (ibCMDActive[ 6]) begin // MNC_readST
            rPM_ReadReady <= iMNC_readST_PM_ReadReady;
        //end else if (ibCMDActive[ 5]) begin // MNC_readID
            
        //end else if (ibCMDActive[ 4]) begin // MNC_setFT
            
        //end else if (ibCMDActive[ 3]) begin // BNC_B_erase
            
        //end else if (ibCMDActive[ 2]) begin // BNC_P_program
            
        end else if (ibCMDActive[ 1]) begin // BNC_P_read_DT00h
            rPM_ReadReady <= iBNC_P_read_DT00h_PM_ReadReady;
        //end else if (ibCMDActive[ 0]) begin // BNC_P_read_AW30h
            
        end else begin // default
            rPM_ReadReady <= iIDLE_PM_ReadReady;
        end
    end
    
    
    
    // Wire Connections
    
    //  - Dispatcher Interface
    //      - Data Write Channel
    assign oWriteReady = rWriteReady;
    
    //      - Data Read Channel
    assign oReadData[31:0] = rReadData[31:0];
    assign oReadLast = rReadLast;
    assign oReadValid = rReadValid;
    
    //  - NPCG_Toggle Interface
    assign oPM_PCommand[7:0] = rPM_PCommand[7:0];
    assign oPM_PCommandOption[2:0] = rPM_PCommandOption[2:0];
    assign oPM_TargetWay[NumberOfWays - 1:0] = rPM_TargetWay[NumberOfWays - 1:0];
    assign oPM_NumOfData[15:0] = rPM_NumOfData[15:0];
    
    assign oPM_CASelect = rPM_CASelect;
    assign oPM_CAData[7:0] = rPM_CAData[7:0];
    
    assign oPM_WriteData[31:0] = rPM_WriteData[31:0];
    assign oPM_WriteLast = rPM_WriteLast;
    assign oPM_WriteValid = rPM_WriteValid;
    
    assign oPM_ReadReady = rPM_ReadReady;
    
endmodule

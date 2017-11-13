//////////////////////////////////////////////////////////////////////////////////
// NPhy_Toggle_Physical_Input_DDR100 for Cosmos OpenSSD
// Copyright (c) 2015 Hanyang University ENC Lab.
// Contributed by Ilyong Jung <iyjung@enc.hanyang.ac.kr>
//                Kibin Park <kbpark@enc.hanyang.ac.kr>
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
// Engineer: Ilyong Jung <iyjung@enc.hanyang.ac.kr>, Kibin Park <kbpark@enc.hanyang.ac.kr>
// 
// Project Name: Cosmos OpenSSD
// Design Name: NPhy_Toggle_Physical_Input_DDR100
// Module Name: NPhy_Toggle_Physical_Input_DDR100
// File Name: NPhy_Toggle_Physical_Input_DDR100.v
//
// Version: v1.0.0
//
// Description: NFC phy input module
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module NPhy_Toggle_Physical_Input_DDR100
#
(
    parameter IDelayValue           = 13,
    parameter InputClockBufferType  = 0
)
(
    iSystemClock    ,
    iDelayRefClock  ,
    iModuleReset    ,
    iBufferReset    ,
    iPI_Buff_RE     ,
    iPI_Buff_WE     ,
    iPI_Buff_OutSel ,
    oPI_Buff_Empty  ,
    oPI_DQ          ,
    oPI_ValidFlag   ,
    iPI_DelayTapLoad,
    iPI_DelayTap    ,
    oPI_DelayReady  ,
    iDQSFromNAND    ,
    iDQFromNAND
);
    input           iSystemClock        ;
    input           iDelayRefClock      ;
    input           iModuleReset        ;
    input           iBufferReset        ;
    input           iPI_Buff_RE         ;
    input           iPI_Buff_WE         ;
    input   [2:0]   iPI_Buff_OutSel     ; // 000: IN_FIFO, 100: Nm4+Nm3, 101: Nm3+Nm2, 110: Nm2+Nm1, 111: Nm1+ZERO
    output          oPI_Buff_Empty      ;
    output  [31:0]  oPI_DQ              ; // DQ, 4 bit * 8 bit data width = 32 bit interface width
    output  [3:0]   oPI_ValidFlag       ; // { Nm1, Nm2, Nm3, Nm4 }
    input           iPI_DelayTapLoad    ;
    input   [4:0]   iPI_DelayTap        ;
    output          oPI_DelayReady      ;
    input           iDQSFromNAND        ;
    input   [7:0]   iDQFromNAND         ;
    // Input Capture Clock -> delayed DQS signal with IDELAYE2
    // IDELAYE2, REFCLK: SDR 200MHz
    //           Tap resolution: 1/(32*2*200MHz) = 78.125 ps
    //           Initial Tap: 28, 78.125 ps * 28 = 2187.5 ps
    
    // Data Width (DQ): 8 bit
    
    // 1:2 DDR Deserializtion with IDDR
    // IDDR, 1:2 Desirialization
    //       C: delayed DDR 100MHz
    // IN_FIFO
    //          WRCLK: delayed SDR 100MHz RDCLK: SDR 100MHz ARRAY_MODE_4_X_4
    
    // IDELAYCTRL, Minimum Reset Pulse Width: 52 ns
    //             Reset to Ready: 3.22 us
    // IN_FIFO, Maximum Frequency (RDCLK, WRCLK): 533.05 MHz, 1.0 V, -3
    
    // Internal Wires/Regs
    
    reg     rBufferReset        ;
    
    wire    wDelayedDQS         ;
    wire    wDelayedDQSClock    ;
    wire    wtestFULL;
    
    IDELAYCTRL
    Inst_DQSIDELAYCTRL
    (
        .REFCLK (iDelayRefClock     ),
        .RST    (iModuleReset       ),
        .RDY    (oPI_DelayReady     )
    );
    
    IDELAYE2
    #
    (
        .IDELAY_TYPE        ("VARIABLE" ),
        .DELAY_SRC          ("IDATAIN"  ),
        .IDELAY_VALUE       (IDelayValue),
        .SIGNAL_PATTERN     ("CLOCK"    ),
        .REFCLK_FREQUENCY   (200        )
    )
    Inst_DQSIDELAY
    (
        .CNTVALUEOUT    (                   ),
        .DATAOUT        (wDelayedDQS        ),
        .C              (iSystemClock       ),
        .CE             (0                  ),
        .CINVCTRL       (0                  ),
        .CNTVALUEIN     (iPI_DelayTap       ),
        .DATAIN         (0                  ),
        .IDATAIN        (iDQSFromNAND       ),
        .INC            (0                  ),
        .LD             (iPI_DelayTapLoad   ),
        .LDPIPEEN       (0                  ),
        .REGRST         (iModuleReset       )
    );

    generate
        // InputClockBufferType
        // 0: IBUFG (default)
        // 1: IBUFG + BUFG
        // 2: BUFR
        if (InputClockBufferType == 0)
        begin
            IBUFG
            Inst_DQSCLOCK
            (
                .I  (wDelayedDQS        ),
                .O  (wDelayedDQSClock   )
            );
        end
        else if (InputClockBufferType == 1)
        begin
            wire wDelayedDQSClockUnbuffered;
            IBUFG
            Inst_DQSCLOCK_IBUFG
            (
                .I  (wDelayedDQS                ),
                .O  (wDelayedDQSClockUnbuffered )
            );
            BUFG
            Inst_DQSCLOCK_BUFG
            (
                .I  (wDelayedDQSClockUnbuffered ),
                .O  (wDelayedDQSClock           )
            );
        end
        else if (InputClockBufferType == 2)
        begin
            BUFR
            Inst_DQSCLOCK
            (
                .I  (wDelayedDQS        ),
                .O  (wDelayedDQSClock   ),
                .CE (1                  ),
                .CLR(0                  )
            );
        end
        else
        begin
        end
    endgenerate
    
    genvar c;
    
    wire    [7:0]   wDQAtRising     ;
    wire    [7:0]   wDQAtFalling    ;
    
    generate
    for (c = 0; c < 8; c = c + 1)
    begin: DQIDDRBits    
        IDDR
        #
        (
            .DDR_CLK_EDGE   ("OPPOSITE_EDGE"    ),
            .INIT_Q1        (0                  ),
            .INIT_Q2        (0                  ),
            .SRTYPE         ("SYNC"             )
        )
        Inst_DQIDDR
        (
            .Q1 ( wDQAtRising[c]    ),
            .Q2 (wDQAtFalling[c]    ),
            .C  (wDelayedDQSClock   ),
            .CE (1                  ),
            .D  (iDQFromNAND[c]      ),
            .R  (0                  ),
            .S  (0                  )
        );
    end
    endgenerate
    
    wire    [7:0]   wDQ0  ;
    wire    [7:0]   wDQ1  ;
    wire    [7:0]   wDQ2  ;
    wire    [7:0]   wDQ3  ;
    
    always @ (posedge wDelayedDQSClock)
        if (iBufferReset)
            rBufferReset <= iBufferReset;
        else
            rBufferReset <= 1'b0;
    
    reg rIN_FIFO_WE_Latch;
    
    always @ (posedge wDelayedDQSClock) begin
        if (rBufferReset) begin
            rIN_FIFO_WE_Latch <= 0;
        end else begin
            rIN_FIFO_WE_Latch <= iPI_Buff_WE;
        end
    end
    
    IN_FIFO
    #
    (
        .ARRAY_MODE ("ARRAY_MODE_4_X_4")
    )
    Inst_DQINFIFO4x4
    (
        .D0     (wDQAtRising[3:0]               ),
        .D1     (wDQAtRising[7:4]               ),
        .D2     (wDQAtFalling[3:0]              ),
        .D3     (wDQAtFalling[7:4]              ),
        .Q0     ({ wDQ2[3:0], wDQ0[3:0] }       ),
        .Q1     ({ wDQ2[7:4], wDQ0[7:4] }       ),
        .Q2     ({ wDQ3[3:0], wDQ1[3:0] }       ),
        .Q3     ({ wDQ3[7:4], wDQ1[7:4] }       ),
        
        .RDCLK  (iSystemClock                   ),
        .RDEN   (iPI_Buff_RE                    ),
        .EMPTY  (oPI_Buff_Empty                 ),
        
        .WRCLK  (wDelayedDQSClock               ),
        .WREN   (rIN_FIFO_WE_Latch              ),
        .FULL   (wtestFULL),
        
        .RESET  (rBufferReset                   )
    );
    
    reg [15:0]  rNm2_Buffer     ;
    reg [15:0]  rNm3_Buffer     ;
    reg [15:0]  rNm4_Buffer     ;
    
    wire        wNm1_ValidFlag  ;
    reg         rNm2_ValidFlag  ;
    reg         rNm3_ValidFlag  ;
    reg         rNm4_ValidFlag  ;
    
    reg [31:0]  rPI_DQ          ;
    
    assign wNm1_ValidFlag = rIN_FIFO_WE_Latch;
    
    always @ (posedge wDelayedDQSClock) begin
        if (rBufferReset) begin
            rNm2_Buffer[15:0] <= 0;
            rNm3_Buffer[15:0] <= 0;
            rNm4_Buffer[15:0] <= 0;
            
            rNm2_ValidFlag <= 0;
            rNm3_ValidFlag <= 0;
            rNm4_ValidFlag <= 0;
        end else begin
            rNm2_Buffer[15:0] <= { wDQAtFalling[7:0], wDQAtRising[7:0] };
            rNm3_Buffer[15:0] <= rNm2_Buffer[15:0];
            rNm4_Buffer[15:0] <= rNm3_Buffer[15:0];
            
            rNm2_ValidFlag <= wNm1_ValidFlag;
            rNm3_ValidFlag <= rNm2_ValidFlag;
            rNm4_ValidFlag <= rNm3_ValidFlag;
        end
    end
    
    // 000: IN_FIFO, 001 ~ 011: reserved
    // 100: Nm4+Nm3, 101: Nm3+Nm2, 110: Nm2+Nm1, 111: Nm1+ZERO
    
    always @ (*) begin
        case ( iPI_Buff_OutSel[2:0] )
            3'b000: begin // 000: IN_FIFO
                rPI_DQ[ 7: 0] <= wDQ0[7:0];
                rPI_DQ[15: 8] <= wDQ1[7:0];
                rPI_DQ[23:16] <= wDQ2[7:0];
                rPI_DQ[31:24] <= wDQ3[7:0];
            end
            3'b100: begin // 100: Nm4+Nm3
                rPI_DQ[ 7: 0] <= rNm4_Buffer[ 7: 0];
                rPI_DQ[15: 8] <= rNm4_Buffer[15: 8];
                rPI_DQ[23:16] <= rNm3_Buffer[ 7: 0];
                rPI_DQ[31:24] <= rNm3_Buffer[15: 8];
            end
            3'b101: begin // 101: Nm3+Nm2
                rPI_DQ[ 7: 0] <= rNm3_Buffer[ 7: 0];
                rPI_DQ[15: 8] <= rNm3_Buffer[15: 8];
                rPI_DQ[23:16] <= rNm2_Buffer[ 7: 0];
                rPI_DQ[31:24] <= rNm2_Buffer[15: 8];
            end
            3'b110: begin // 110: Nm2+Nm1
                rPI_DQ[ 7: 0] <= rNm2_Buffer[ 7: 0];
                rPI_DQ[15: 8] <= rNm2_Buffer[15: 8];
                rPI_DQ[23:16] <= wDQAtRising[ 7: 0];
                rPI_DQ[31:24] <= wDQAtFalling[ 7: 0];
            end
            3'b111: begin // 111: Nm1+ZERO
                rPI_DQ[ 7: 0] <= wDQAtRising[ 7: 0];
                rPI_DQ[15: 8] <= wDQAtFalling[ 7: 0];
                rPI_DQ[23:16] <= 0;
                rPI_DQ[31:24] <= 0;
            end
            default: begin // 001 ~ 011: reserved
                rPI_DQ[ 7: 0] <= wDQ0[7:0];
                rPI_DQ[15: 8] <= wDQ1[7:0];
                rPI_DQ[23:16] <= wDQ2[7:0];
                rPI_DQ[31:24] <= wDQ3[7:0];
            end
        endcase
    end
    
    assign oPI_DQ[ 7: 0] = rPI_DQ[ 7: 0];
    assign oPI_DQ[15: 8] = rPI_DQ[15: 8];
    assign oPI_DQ[23:16] = rPI_DQ[23:16];
    assign oPI_DQ[31:24] = rPI_DQ[31:24];
    
    assign oPI_ValidFlag[3:0] = { wNm1_ValidFlag, rNm2_ValidFlag, rNm3_ValidFlag, rNm4_ValidFlag };
    
endmodule

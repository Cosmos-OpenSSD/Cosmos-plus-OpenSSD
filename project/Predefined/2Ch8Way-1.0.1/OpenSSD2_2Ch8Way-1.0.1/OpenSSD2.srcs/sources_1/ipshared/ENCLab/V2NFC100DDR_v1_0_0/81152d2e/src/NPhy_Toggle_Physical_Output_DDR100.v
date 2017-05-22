//////////////////////////////////////////////////////////////////////////////////
// NPhy_Toggle_Physical_Output_DDR100 for Cosmos OpenSSD
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
// Design Name: NPhy_Toggle_Physical_Output_DDR100
// Module Name: NPhy_Toggle_Physical_Output_DDR100
// File Name: NPhy_Toggle_Physical_Output_DDR100.v
//
// Version: v1.0.0
//
// Description: NFC phy output module
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module NPhy_Toggle_Physical_Output_DDR100
#
(
    parameter NumberOfWays    =   4
)
(
    iSystemClock            ,
    iOutputDrivingClock     ,
    iModuleReset            ,
    iDQSOutEnable           ,
    iDQOutEnable            ,
    iPO_DQStrobe            ,
    iPO_DQ                  ,
    iPO_ChipEnable          ,
    iPO_ReadEnable          ,
    iPO_WriteEnable         ,
    iPO_AddressLatchEnable  ,
    iPO_CommandLatchEnable  ,
    oDQSOutEnableToPinpad   ,
    oDQOutEnableToPinpad    ,
    oDQSToNAND              ,
    oDQToNAND               ,
    oCEToNAND               ,
    oWEToNAND               ,
    oREToNAND               ,
    oALEToNAND              ,
    oCLEToNAND
);
    // Data Width (DQ): 8 bit
    
    // 4:1 DDR Serialization with OSERDESE2
    // OSERDESE2, 4:1 DDR Serialization
    //            CLKDIV: SDR 100MHz CLK: SDR 200MHz OQ: DDR 200MHz
    //            output resolution: 2.50 ns
    input                           iSystemClock            ;
    input                           iOutputDrivingClock     ;
    input                           iModuleReset            ;
    input                           iDQSOutEnable           ;
    input                           iDQOutEnable            ;
    input   [7:0]                   iPO_DQStrobe            ; // DQS, full res.
    input   [31:0]                  iPO_DQ                  ; // DQ, half res., 2 bit * 8 bit data width = 16 bit interface width
    input   [2*NumberOfWays - 1:0]  iPO_ChipEnable          ; // CE, quater res., 1 bit * 4 way = 4 bit interface width
    input   [3:0]                   iPO_ReadEnable          ; // RE, half res.
    input   [3:0]                   iPO_WriteEnable         ; // WE, half res.
    input   [3:0]                   iPO_AddressLatchEnable  ; // ALE, half res.
    input   [3:0]                   iPO_CommandLatchEnable  ; // CLE, half res.
    output                          oDQSOutEnableToPinpad   ;
    output  [7:0]                   oDQOutEnableToPinpad    ;
    output                          oDQSToNAND              ;
    output  [7:0]                   oDQToNAND               ;
    output  [NumberOfWays - 1:0]    oCEToNAND               ;
    output                          oWEToNAND               ;
    output                          oREToNAND               ;
    output                          oALEToNAND              ;
    output                          oCLEToNAND              ;
    
    
    reg     rDQSOutEnable_buffer;
    reg     rDQSOut_IOBUF_T;
    reg     rDQOutEnable_buffer;
    reg     rDQOut_IOBUF_T;
    
    always @ (posedge iSystemClock) begin
        if (iModuleReset) begin
            rDQSOutEnable_buffer <= 0;
            rDQSOut_IOBUF_T      <= 1;
            rDQOutEnable_buffer  <= 0;
            rDQOut_IOBUF_T       <= 1;
        end else begin
            rDQSOutEnable_buffer <= iDQSOutEnable;
            rDQSOut_IOBUF_T      <= ~rDQSOutEnable_buffer;
            rDQOutEnable_buffer  <= iDQOutEnable;
            rDQOut_IOBUF_T       <= ~rDQOutEnable_buffer;
        end       
    end
    
    genvar c, d;
    
    OSERDESE2
    #
    (
        .DATA_RATE_OQ   ("DDR"      ),
        //.DATA_RATE_TQ   ("SDR"      ),
        .DATA_RATE_TQ   ("BUF"      ),
        .DATA_WIDTH     (4          ),
        .INIT_OQ        (1'b0       ),
        .INIT_TQ        (1'b1       ),
        .SERDES_MODE    ("MASTER"   ),
        .SRVAL_OQ       (1'b0       ),
        .SRVAL_TQ       (1'b1       ),
        .TRISTATE_WIDTH (1          )
    )
    Inst_DQSOSERDES
    (
        .OFB        (                       ),
        .OQ         (oDQSToNAND             ),
        .SHIFTOUT1  (                       ),
        .SHIFTOUT2  (                       ),
        .TBYTEOUT   (                       ),
        .TFB        (                       ),
        .TQ         (oDQSOutEnableToPinpad  ), // to pinpad

        .CLK        (iOutputDrivingClock    ),
        .CLKDIV     (iSystemClock           ),
        .D1         (iPO_DQStrobe[0]        ),
        .D2         (iPO_DQStrobe[1]        ),
        .D3         (iPO_DQStrobe[2]        ),
        .D4         (iPO_DQStrobe[3]        ),
        .D5         (iPO_DQStrobe[4]        ),
        .D6         (iPO_DQStrobe[5]        ),
        .D7         (iPO_DQStrobe[6]        ),
        .D8         (iPO_DQStrobe[7]        ),
        .OCE        (1'b1                   ),
        .RST        (iModuleReset           ),
        .SHIFTIN1   (0                      ),
        .SHIFTIN2   (0                      ),
        .T1         (rDQSOut_IOBUF_T        ), // from P.M.
        .T2         (0                      ),
        .T3         (0                      ),
        .T4         (0                      ),
        .TBYTEIN    (0                      ),
        .TCE        (1'b1                   )
    );
    
    generate
    for (c = 0; c < 8; c = c + 1)
    begin : DQOSERDESBits
        OSERDESE2
        #
        (
            .DATA_RATE_OQ   ("DDR"      ),
            //.DATA_RATE_TQ   ("SDR"      ),
            .DATA_RATE_TQ   ("BUF"      ),
            .DATA_WIDTH     (4          ),
            .INIT_OQ        (1'b0       ),
            .INIT_TQ        (1'b1       ),
            .SERDES_MODE    ("MASTER"   ),
            .SRVAL_OQ       (1'b0       ),
            .SRVAL_TQ       (1'b1       ),
            .TRISTATE_WIDTH (1          )
        )
        Inst_DQOSERDES
        (
            .OFB        (                   ),
            .OQ         (oDQToNAND[c]       ),
            .SHIFTOUT1  (                   ),
            .SHIFTOUT2  (                   ),
            .TBYTEOUT   (                   ),
            .TFB        (                   ),
            .TQ         (oDQOutEnableToPinpad[c]), // to pinpad

            .CLK        (iOutputDrivingClock),
            .CLKDIV     (iSystemClock       ),
            .D1         (iPO_DQ[ 0 + c]     ),
            .D2         (iPO_DQ[ 0 + c]     ),
            .D3         (iPO_DQ[ 8 + c]     ),
            .D4         (iPO_DQ[ 8 + c]     ),
            .D5         (iPO_DQ[16 + c]     ),
            .D6         (iPO_DQ[16 + c]     ),
            .D7         (iPO_DQ[24 + c]     ),
            .D8         (iPO_DQ[24 + c]     ),
            .OCE        (1'b1               ),
            .RST        (iModuleReset       ),
            .SHIFTIN1   (0                  ),
            .SHIFTIN2   (0                  ),
            .T1         (rDQOut_IOBUF_T     ), // from P.M.
            .T2         (0                  ),
            .T3         (0                  ),
            .T4         (0                  ),
            .TBYTEIN    (0                  ),
            .TCE        (1'b1               )
        );
    end
    endgenerate

    generate
    for (d = 0; d < NumberOfWays; d = d + 1)
    begin : CEOSERDESBits
        OSERDESE2
        #
        (
            .DATA_RATE_OQ   ("DDR"      ),
            //.DATA_RATE_TQ   ("SDR"      ),
            .DATA_RATE_TQ   ("BUF"      ),
            .DATA_WIDTH     (4          ),
            .INIT_OQ        (1'b1       ),
            //.INIT_OQ        (1'b0       ),
            .INIT_TQ        (1'b0       ),
            .SERDES_MODE    ("MASTER"   ),
            .SRVAL_OQ       (1'b1       ),
            //.SRVAL_OQ       (1'b0       ),
            .SRVAL_TQ       (1'b0       ),
            .TRISTATE_WIDTH (1          ),
            
            
            .IS_D1_INVERTED (1'b1       ),
            .IS_D2_INVERTED (1'b1       ),
            .IS_D3_INVERTED (1'b1       ),
            .IS_D4_INVERTED (1'b1       ),
            .IS_D5_INVERTED (1'b1       ),
            .IS_D6_INVERTED (1'b1       ),
            .IS_D7_INVERTED (1'b1       ),
            .IS_D8_INVERTED (1'b1       )
        )
        Inst_CEOSERDES
        (
            .OFB        (                       ),
            .OQ         (oCEToNAND[d]           ),
            .SHIFTOUT1  (                       ),
            .SHIFTOUT2  (                       ),
            .TBYTEOUT   (                       ),
            .TFB        (                       ),
            .TQ         (                       ),

            .CLK        (iOutputDrivingClock    ),
            .CLKDIV     (iSystemClock           ),
            .D1         (iPO_ChipEnable[0 + d]  ),
            .D2         (iPO_ChipEnable[0 + d]  ),
            .D3         (iPO_ChipEnable[0 + d]  ),
            .D4         (iPO_ChipEnable[0 + d]  ),
            .D5         (iPO_ChipEnable[NumberOfWays + d]),
            .D6         (iPO_ChipEnable[NumberOfWays + d]),
            .D7         (iPO_ChipEnable[NumberOfWays + d]),
            .D8         (iPO_ChipEnable[NumberOfWays + d]),
            .OCE        (1'b1                   ),
            .RST        (iModuleReset           ),
            .SHIFTIN1   (0                      ),
            .SHIFTIN2   (0                      ),
            .T1         (1'b0                   ),
            .T2         (0                      ),
            .T3         (0                      ),
            .T4         (0                      ),
            .TBYTEIN    (0                      ),
            .TCE        (1'b1                   )
        );
    end
    endgenerate
    
    OSERDESE2
    #
    (
        .DATA_RATE_OQ   ("DDR"      ),
        //.DATA_RATE_TQ   ("SDR"      ),
        .DATA_RATE_TQ   ("BUF"      ),
        .DATA_WIDTH     (4          ),
        .INIT_OQ        (1'b1       ),
        //.INIT_OQ        (1'b0       ),
        .INIT_TQ        (1'b0       ),
        .SERDES_MODE    ("MASTER"   ),
        .SRVAL_OQ       (1'b1       ),
        //.SRVAL_OQ       (1'b0       ),
        .SRVAL_TQ       (1'b0       ),
        .TRISTATE_WIDTH (1          )
        
        /* // single-ended
        .IS_D1_INVERTED (1'b1       ),
        .IS_D2_INVERTED (1'b1       ),
        .IS_D3_INVERTED (1'b1       ),
        .IS_D4_INVERTED (1'b1       ),
        .IS_D5_INVERTED (1'b1       ),
        .IS_D6_INVERTED (1'b1       ),
        .IS_D7_INVERTED (1'b1       ),
        .IS_D8_INVERTED (1'b1       )
        */
    )
    Inst_REOSERDES
    (
        .OFB        (                       ),
        .OQ         (oREToNAND              ),
        .SHIFTOUT1  (                       ),
        .SHIFTOUT2  (                       ),
        .TBYTEOUT   (                       ),
        .TFB        (                       ),
        .TQ         (                       ),

        .CLK        (iOutputDrivingClock    ),
        .CLKDIV     (iSystemClock           ),
        .D1         (iPO_ReadEnable[0]      ),
        .D2         (iPO_ReadEnable[0]      ),
        .D3         (iPO_ReadEnable[1]      ),
        .D4         (iPO_ReadEnable[1]      ),
        .D5         (iPO_ReadEnable[2]      ),
        .D6         (iPO_ReadEnable[2]      ),
        .D7         (iPO_ReadEnable[3]      ),
        .D8         (iPO_ReadEnable[3]      ),
        .OCE        (1'b1                   ),
        .RST        (iModuleReset           ),
        .SHIFTIN1   (0                      ),
        .SHIFTIN2   (0                      ),
        .T1         (1'b0                   ),
        .T2         (0                      ),
        .T3         (0                      ),
        .T4         (0                      ),
        .TBYTEIN    (0                      ),
        .TCE        (1'b1                   )
    );
    
    OSERDESE2
    #
    (
        .DATA_RATE_OQ   ("DDR"      ),
        //.DATA_RATE_TQ   ("SDR"      ),
        .DATA_RATE_TQ   ("BUF"      ),
        .DATA_WIDTH     (4          ),
        .INIT_OQ        (1'b1       ),
        //.INIT_OQ        (1'b0       ),
        .INIT_TQ        (1'b0       ),
        .SERDES_MODE    ("MASTER"   ),
        .SRVAL_OQ       (1'b1       ),
        //.SRVAL_OQ       (1'b0       ),
        .SRVAL_TQ       (1'b0       ),
        .TRISTATE_WIDTH (1          ),
        
        .IS_D1_INVERTED (1'b1       ),
        .IS_D2_INVERTED (1'b1       ),
        .IS_D3_INVERTED (1'b1       ),
        .IS_D4_INVERTED (1'b1       ),
        .IS_D5_INVERTED (1'b1       ),
        .IS_D6_INVERTED (1'b1       ),
        .IS_D7_INVERTED (1'b1       ),
        .IS_D8_INVERTED (1'b1       )
    )
    Inst_WEOSERDES
    (
        .OFB        (                       ),
        .OQ         (oWEToNAND              ),
        .SHIFTOUT1  (                       ),
        .SHIFTOUT2  (                       ),
        .TBYTEOUT   (                       ),
        .TFB        (                       ),
        .TQ         (                       ),

        .CLK        (iOutputDrivingClock    ),
        .CLKDIV     (iSystemClock           ),
        .D1         (iPO_WriteEnable[0]     ),
        .D2         (iPO_WriteEnable[0]     ),
        .D3         (iPO_WriteEnable[1]     ),
        .D4         (iPO_WriteEnable[1]     ),
        .D5         (iPO_WriteEnable[2]     ),
        .D6         (iPO_WriteEnable[2]     ),
        .D7         (iPO_WriteEnable[3]     ),
        .D8         (iPO_WriteEnable[3]     ),
        .OCE        (1'b1                   ),
        .RST        (iModuleReset           ),
        .SHIFTIN1   (0                      ),
        .SHIFTIN2   (0                      ),
        .T1         (1'b0                   ),
        .T2         (0                      ),
        .T3         (0                      ),
        .T4         (0                      ),
        .TBYTEIN    (0                      ),
        .TCE        (1'b1                   )
    );
    
    OSERDESE2
    #
    (
        .DATA_RATE_OQ   ("DDR"      ),
        //.DATA_RATE_TQ   ("SDR"      ),
        .DATA_RATE_TQ   ("BUF"      ),
        .DATA_WIDTH     (4          ),
        .INIT_OQ        (1'b0       ),
        .INIT_TQ        (1'b0       ),
        .SERDES_MODE    ("MASTER"   ),
        .SRVAL_OQ       (1'b0       ),
        .SRVAL_TQ       (1'b0       ),
        .TRISTATE_WIDTH (1          )
    )
    Inst_ALEOSERDES
    (
        .OFB        (                       ),
        .OQ         (oALEToNAND             ),
        .SHIFTOUT1  (                       ),
        .SHIFTOUT2  (                       ),
        .TBYTEOUT   (                       ),
        .TFB        (                       ),
        .TQ         (                       ),

        .CLK        (iOutputDrivingClock    ),
        .CLKDIV     (iSystemClock           ),
        .D1         (iPO_AddressLatchEnable[0]),
        .D2         (iPO_AddressLatchEnable[0]),
        .D3         (iPO_AddressLatchEnable[1]),
        .D4         (iPO_AddressLatchEnable[1]),
        .D5         (iPO_AddressLatchEnable[2]),
        .D6         (iPO_AddressLatchEnable[2]),
        .D7         (iPO_AddressLatchEnable[3]),
        .D8         (iPO_AddressLatchEnable[3]),
        .OCE        (1'b1                   ),
        .RST        (iModuleReset           ),
        .SHIFTIN1   (0                      ),
        .SHIFTIN2   (0                      ),
        .T1         (1'b0                   ),
        .T2         (0                      ),
        .T3         (0                      ),
        .T4         (0                      ),
        .TBYTEIN    (0                      ),
        .TCE        (1'b1                   )
    );

    OSERDESE2
    #
    (
        .DATA_RATE_OQ   ("DDR"      ),
        //.DATA_RATE_TQ   ("SDR"      ),
        .DATA_RATE_TQ   ("BUF"      ),
        .DATA_WIDTH     (4          ),
        .INIT_OQ        (1'b0       ),
        .INIT_TQ        (1'b0       ),
        .SERDES_MODE    ("MASTER"   ),
        .SRVAL_OQ       (1'b0       ),
        .SRVAL_TQ       (1'b0       ),
        .TRISTATE_WIDTH (1          )
    )
    Inst_CLEOSERDES
    (
        .OFB        (                       ),
        .OQ         (oCLEToNAND             ),
        .SHIFTOUT1  (                       ),
        .SHIFTOUT2  (                       ),
        .TBYTEOUT   (                       ),
        .TFB        (                       ),
        .TQ         (                       ),

        .CLK        (iOutputDrivingClock    ),
        .CLKDIV     (iSystemClock           ),
        .D1         (iPO_CommandLatchEnable[0]),
        .D2         (iPO_CommandLatchEnable[0]),
        .D3         (iPO_CommandLatchEnable[1]),
        .D4         (iPO_CommandLatchEnable[1]),
        .D5         (iPO_CommandLatchEnable[2]),
        .D6         (iPO_CommandLatchEnable[2]),
        .D7         (iPO_CommandLatchEnable[3]),
        .D8         (iPO_CommandLatchEnable[3]),
        .OCE        (1'b1                   ),
        .RST        (iModuleReset           ),
        .SHIFTIN1   (0                      ),
        .SHIFTIN2   (0                      ),
        .T1         (1'b0                   ),
        .T2         (0                      ),
        .T3         (0                      ),
        .T4         (0                      ),
        .TBYTEIN    (0                      ),
        .TCE        (1'b1                   )
    );

endmodule

//////////////////////////////////////////////////////////////////////////////////
// NPhy_Toggle_Pinpad for Cosmos OpenSSD
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
// Engineer: Ilyong Jung <iyjung@enc.hanyang.ac.kr>
// 
// Project Name: Cosmos OpenSSD
// Design Name: NPhy_Toggle_Pinpad
// Module Name: NPhy_Toggle_Pinpad
// File Name: NPhy_Toggle_Pinpad.v
//
// Version: v1.0.0
//
// Description: Toggle NAND pin pad
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module NPhy_Toggle_Pinpad
#
(
    parameter NumberOfWays    =   4
)
(
    iDQSOutEnable   ,
    iDQSToNAND      ,
    oDQSFromNAND    ,
    iDQOutEnable    ,
    iDQToNAND       ,
    oDQFromNAND     ,
    iCEToNAND       ,
    iWEToNAND       ,
    iREToNAND       ,
    iALEToNAND      ,
    iCLEToNAND      ,
    oRBFromNAND     ,
    iWPToNAND       ,
    IO_NAND_DQS_P   ,
    IO_NAND_DQS_N   ,
    IO_NAND_DQ      ,
    O_NAND_CE       ,
    O_NAND_WE       ,
    O_NAND_RE_P     ,
    O_NAND_RE_N     ,
    O_NAND_ALE      ,
    O_NAND_CLE      ,
    I_NAND_RB       ,
    O_NAND_WP 
);
    // Direction Select: 0-read from NAND, 1-write to NAND
    input                           iDQSOutEnable   ;
    input                           iDQSToNAND      ;
    output                          oDQSFromNAND    ;
    input   [7:0]                   iDQOutEnable    ;
    input   [7:0]                   iDQToNAND       ;
    output  [7:0]                   oDQFromNAND     ;
    input   [NumberOfWays - 1:0]    iCEToNAND       ;
    input                           iWEToNAND       ;
    input                           iREToNAND       ;
    input                           iALEToNAND      ;
    input                           iCLEToNAND      ;
    output  [NumberOfWays - 1:0]    oRBFromNAND     ;
    input                           iWPToNAND       ;
    inout                           IO_NAND_DQS_P   ; // Differential: Positive
    inout                           IO_NAND_DQS_N   ; // Differential: Negative
    inout   [7:0]                   IO_NAND_DQ      ;
    output  [NumberOfWays - 1:0]    O_NAND_CE       ;
    output                          O_NAND_WE       ;
    output                          O_NAND_RE_P     ; // Differential: Positive
    output                          O_NAND_RE_N     ; // Differential: Negative
    output                          O_NAND_ALE      ;
    output                          O_NAND_CLE      ;
    input   [NumberOfWays - 1:0]    I_NAND_RB       ;
    output                          O_NAND_WP       ; 
    
    genvar  c, d, e;

    // DQS Pad: Differential signal
    /*
    IBUF
    Inst_DQSIBUF
    (
        .I(IO_NAND_DQS      ),
        .O(oDQSFromNAND     )
    );
    OBUFT
    Inst_DQSOBUF
    (
        .I(iDQSToNAND       ),
        .O(IO_NAND_DQS      ),
        .T(iDQSOutEnable    )
    );
    */
    IOBUFDS
    Inst_DQSIOBUFDS
    (
        .I(iDQSToNAND       ),
        .T(iDQSOutEnable    ),
        
        .O(oDQSFromNAND     ),
        
        .IO (IO_NAND_DQS_P  ),
        .IOB(IO_NAND_DQS_N  )
    );
    
    // DQ Pad
    generate
    for (c = 0; c < 8; c = c + 1)
    begin: DQBits
        /*
        IBUF
        Inst_DQIBUF
        (
            .I(IO_NAND_DQ[c]    ),
            .O(oDQFromNAND[c]   )
        );
        OBUFT
        Inst_DQOBUFT
        (
            .I(iDQToNAND[c]     ),
            .O(IO_NAND_DQ[c]    ),
            .T(iDQOutEnable[c]  )
        );
        */
        IOBUF
        Inst_DQIOBUF
        (
            .I(iDQToNAND[c]     ),
            .T(iDQOutEnable[c]  ),
            
            .O(oDQFromNAND[c]   ),
            
            .IO(IO_NAND_DQ[c]   )
        );
    end
    endgenerate
    /*
    // CE Pad
    assign O_NAND_CE = iCEToNAND;
    
    // WE Pad
    assign O_NAND_WE = iWEToNAND;
    
    // RE Pad
    //assign O_NAND_RE = iREToNAND;
    
    // ALE Pad
    assign O_NAND_ALE = iALEToNAND;
    
    // CLE Pad
    assign O_NAND_CLE = iCLEToNAND;
    
    // RB Pad
    assign oRBFromNAND = I_NAND_RB;
    
    // WP Pad
    assign O_NAND_WP = iWPToNAND;
    */
    // CE Pad
    generate
    for (d = 0; d < NumberOfWays; d = d + 1)
    begin: CEs
        OBUF
        Inst_CEOBUF
        (
            .I(iCEToNAND[d]),
            .O(O_NAND_CE[d])
        );    
    end
    endgenerate
    
    
    // WE Pad
    OBUF
    Inst_WEOBUF
    (
        .I(iWEToNAND  ),
        .O(O_NAND_WE  )
    ); 
    
    // RE Pad: Differential signal
    /*
    OBUF
    Inst_REOBUF
    (
        .I(iREToNAND  ),
        .O(O_NAND_RE  )
    );
    */
    OBUFDS
    Inst_REOBUFDS
    (
        .I (iREToNAND   ),
        .O (O_NAND_RE_P ),
        .OB(O_NAND_RE_N )
    );
    
    // ALE Pad
    OBUF
    Inst_ALEOBUF
    (
        .I(iALEToNAND  ),
        .O(O_NAND_ALE  )
    ); 
    
    // CLE Pad
    OBUF
    Inst_CLEOBUF
    (
        .I(iCLEToNAND  ),
        .O(O_NAND_CLE  )
    );
    
    // RB Pad
    generate
    for (e = 0; e < NumberOfWays; e = e + 1)
    begin: RBs
        IBUF
        Inst_RBIBUF
        (
            .I(I_NAND_RB[e]),
            .O(oRBFromNAND[e])
        );   
    end
    endgenerate
    
    // WP Pad
    OBUF
    Inst_WPOBUF
    (
        .I(iWPToNAND    ),
        .O(O_NAND_WP    )
    );

endmodule


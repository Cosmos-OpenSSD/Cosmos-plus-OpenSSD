//////////////////////////////////////////////////////////////////////////////////
// V2DatapathClockConverter32 for Cosmos OpenSSD
// Copyright (c) 2015 Hanyang University ENC Lab.
// Contributed by Kibin Park <kbpark@enc.hanyang.ac.kr>
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
// Engineer: Kibin Park <kbpark@enc.hanyang.ac.kr>
// 
// Project Name: Cosmos OpenSSD
// Design Name: V2 data path clock converter 32
// Module Name: V2DatapathClockConverter32
// File Name: V2DatapathClockConverter32.v
//
// Version: v1.0.0
//
// Description: data path clock converter
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1 ns / 1 ps

module V2DatapathClockConverter32
#
(
)
(
    iSClock         ,
    iSReset         ,
    iSWOpcode       ,
    iSWTargetID     ,
    iSWSourceID     ,
    iSWAddress      ,
    iSWLength       ,
    iSWCMDValid     ,
    oSWCMDReady     ,
    iSWriteData     ,
    iSWriteLast     ,
    iSWriteValid    ,
    oSWriteReady    ,
    iSROpcode       ,
    iSRTargetID     ,
    iSRSourceID     ,
    iSRAddress      ,
    iSRLength       ,
    iSRCMDValid     ,
    oSRCMDReady     ,
    oSReadData      ,
    oSReadLast      ,
    oSReadValid     ,
    iSReadReady     ,
    iMClock         ,
    iMReset         ,
    oMWOpcode       ,
    oMWTargetID     ,
    oMWSourceID     ,
    oMWAddress      ,
    oMWLength       ,
    oMWCMDValid     ,
    iMWCMDReady     ,
    oMWriteData     ,
    oMWriteLast     ,
    oMWriteValid    ,
    iMWriteReady    ,
    oMROpcode       ,
    oMRTargetID     ,
    oMRSourceID     ,
    oMRAddress      ,
    oMRLength       ,
    oMRCMDValid     ,
    iMRCMDReady     ,
    iMReadData      ,
    iMReadLast      ,
    iMReadValid     ,
    oMReadReady
);

    input                           iSClock         ;
    input                           iSReset         ;
    
    input   [5:0]                   iSWOpcode       ;
    input   [4:0]                   iSWTargetID     ;
    input   [4:0]                   iSWSourceID     ;
    input   [31:0]                  iSWAddress      ;
    input   [15:0]                  iSWLength       ;
    input                           iSWCMDValid     ;
    output                          oSWCMDReady     ;
    input   [31:0]                  iSWriteData     ;
    input                           iSWriteLast     ;
    input                           iSWriteValid    ;
    output                          oSWriteReady    ;
    
    input   [5:0]                   iSROpcode       ;
    input   [4:0]                   iSRTargetID     ;
    input   [4:0]                   iSRSourceID     ;
    input   [31:0]                  iSRAddress      ;
    input   [15:0]                  iSRLength       ;
    input                           iSRCMDValid     ;
    output                          oSRCMDReady     ;
    output  [31:0]                  oSReadData      ;
    output                          oSReadLast      ;
    output                          oSReadValid     ;
    input                           iSReadReady     ;

    input                           iMClock         ;
    input                           iMReset         ;
    
    output  [5:0]                   oMWOpcode       ;
    output  [4:0]                   oMWTargetID     ;
    output  [4:0]                   oMWSourceID     ;
    output  [31:0]                  oMWAddress      ;
    output  [15:0]                  oMWLength       ;
    output                          oMWCMDValid     ;
    input                           iMWCMDReady     ;
    output  [31:0]                  oMWriteData     ;
    output                          oMWriteLast     ;
    output                          oMWriteValid    ;
    input                           iMWriteReady    ;
    
    output  [5:0]                   oMROpcode       ;
    output  [4:0]                   oMRTargetID     ;
    output  [4:0]                   oMRSourceID     ;
    output  [31:0]                  oMRAddress      ;
    output  [15:0]                  oMRLength       ;
    output                          oMRCMDValid     ;
    input                           iMRCMDReady     ;
    input   [31:0]                  iMReadData      ;
    input                           iMReadLast      ;
    input                           iMReadValid     ;
    output                          oMReadReady     ;
    
    genvar rbgen;
    
    wire            wCWChCDCFIFOPopEnable   ;
    wire            wCWChCDCFIFOEmpty       ;
    wire            wCWChCDCFIFOFull        ;
    wire    [63:0]  wCWChCmdDataIn          ;
    wire    [63:0]  wCWChCmdDataOut         ;
    
    wire            wCRChCDCFIFOPopEnable   ;
    wire            wCRChCDCFIFOEmpty       ;
    wire            wCRChCDCFIFOFull        ;
    wire    [63:0]  wCRChCmdDataIn          ;
    wire    [63:0]  wCRChCmdDataOut         ;
    
    wire            wWChCDCFIFOPopEnable    ;
    wire            wWChCDCFIFOEmpty        ;
    wire            wWChCDCFIFOFull         ;
    
    wire            wRChCDCFIFOPopEnable    ;
    wire            wRChCDCFIFOEmpty        ;
    wire            wRChCDCFIFOFull         ;
    
    AutoFIFOPopControl
    Inst_CWChCDCFIFOControl
    (
        .iClock         (iMClock                ),
        .iReset         (iMReset                ),
        .oPopSignal     (wCWChCDCFIFOPopEnable  ),
        .iEmpty         (wCWChCDCFIFOEmpty      ),
        .oValid         (oMWCMDValid            ),
        .iReady         (iMWCMDReady            )
    );
    
    DCFIFO_64x16_DR
    Inst_CWChCDCFIFO
    (
        .iWClock        (iSClock                    ),
        .iWReset        (iSReset                    ),
        .iPushData      (wCWChCmdDataIn             ),
        .iPushEnable    (iSWCMDValid & oSWCMDReady  ),
        .oIsFull        (wCWChCDCFIFOFull           ),
        .iRClock        (iMClock                    ),
        .iRReset        (iMReset                    ),
        .oPopData       (wCWChCmdDataOut            ),
        .iPopEnable     (wCWChCDCFIFOPopEnable      ),
        .oIsEmpty       (wCWChCDCFIFOEmpty          )
    );
    
    assign wCWChCmdDataIn                                               = {iSWOpcode, iSWTargetID, iSWSourceID, iSWAddress, iSWLength};
    assign {oMWOpcode, oMWTargetID, oMWSourceID, oMWAddress, oMWLength} = wCWChCmdDataOut;
    assign oSWCMDReady                                                  = !wCWChCDCFIFOFull;
    
    AutoFIFOPopControl
    Inst_CRChCDCFIFOControl
    (
        .iClock         (iMClock                ),
        .iReset         (iMReset                ),
        .oPopSignal     (wCRChCDCFIFOPopEnable  ),
        .iEmpty         (wCRChCDCFIFOEmpty      ),
        .oValid         (oMRCMDValid            ),
        .iReady         (iMRCMDReady            )
    );
    
    DCFIFO_64x16_DR
    Inst_CRChCDCFIFO
    (
        .iWClock        (iSClock                    ),
        .iWReset        (iSReset                    ),
        .iPushData      (wCRChCmdDataIn             ),
        .iPushEnable    (iSRCMDValid & oSRCMDReady  ),
        .oIsFull        (wCRChCDCFIFOFull           ),
        .iRClock        (iMClock                    ),
        .iRReset        (iMReset                    ),
        .oPopData       (wCRChCmdDataOut            ),
        .iPopEnable     (wCRChCDCFIFOPopEnable      ),
        .oIsEmpty       (wCRChCDCFIFOEmpty          )
    );
    
    assign wCRChCmdDataIn                                               = {iSROpcode, iSRTargetID, iSRSourceID, iSRAddress, iSRLength};
    assign {oMROpcode, oMRTargetID, oMRSourceID, oMRAddress, oMRLength} = wCRChCmdDataOut;
    assign oSRCMDReady                                                  = !wCRChCDCFIFOFull;
    
    AutoFIFOPopControl
    Inst_WChCDCFIFOControl
    (
        .iClock         (iMClock                ),
        .iReset         (iMReset                ),
        .oPopSignal     (wWChCDCFIFOPopEnable   ),
        .iEmpty         (wWChCDCFIFOEmpty       ),
        .oValid         (oMWriteValid           ),
        .iReady         (iMWriteReady           )
    );
    
    DCFIFO_36x16_DR
    Inst_WChCDCFIFO
    (
        .iWClock        (iSClock                    ),
        .iWReset        (iSReset                    ),
        .iPushData      ({iSWriteData, iSWriteLast} ),
        .iPushEnable    (iSWriteValid & oSWriteReady),
        .oIsFull        (wWChCDCFIFOFull            ),
        .iRClock        (iMClock                    ),
        .iRReset        (iMReset                    ),
        .oPopData       ({oMWriteData, oMWriteLast} ),
        .iPopEnable     (wWChCDCFIFOPopEnable       ),
        .oIsEmpty       (wWChCDCFIFOEmpty           )
    );
    
    assign oSWriteReady = !wWChCDCFIFOFull;
    
    AutoFIFOPopControl
    Inst_RChCDCFIFOControl
    (
        .iClock         (iSClock                ),
        .iReset         (iSReset                ),
        .oPopSignal     (wRChCDCFIFOPopEnable   ),
        .iEmpty         (wRChCDCFIFOEmpty       ),
        .oValid         (oSReadValid            ),
        .iReady         (iSReadReady            )
    );
    
    DCFIFO_36x16_DR
    Inst_RChCDCFIFO
    (
        .iWClock        (iMClock                    ),
        .iWReset        (iMReset                    ),
        .iPushData      ({iMReadData, iMReadLast}   ),
        .iPushEnable    (iMReadValid & oMReadReady  ),
        .oIsFull        (wRChCDCFIFOFull            ),
        .iRClock        (iSClock                    ),
        .iRReset        (iSReset                    ),
        .oPopData       ({oSReadData, oSReadLast}   ),
        .iPopEnable     (wRChCDCFIFOPopEnable       ),
        .oIsEmpty       (wRChCDCFIFOEmpty           )
    );
    
    assign oMReadReady = !wRChCDCFIFOFull;

endmodule
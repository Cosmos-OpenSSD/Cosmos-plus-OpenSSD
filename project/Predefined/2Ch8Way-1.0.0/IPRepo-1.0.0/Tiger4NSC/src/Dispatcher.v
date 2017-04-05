//////////////////////////////////////////////////////////////////////////////////
// Dispatcher for Cosmos OpenSSD
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
// Design Name: Dispatcher
// Module Name: Dispatcher
// File Name: Dispatcher.v
//
// Version: v1.0.0
//
// Description: Central way controller
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
// * v1.1.0
//   - external brom interface
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module Dispatcher
#
(
    parameter AddressWidth          = 32    ,
    parameter DataWidth             = 32    ,
    parameter InnerIFLengthWidth    = 16    ,
    parameter NumberOfWays          = 4     ,
    parameter ProgWordWidth         = 64    ,
    parameter UProgSize             = 256
)
(
    iClock          ,
    iReset          ,
    iWriteAddress   ,
    iReadAddress    ,
    iWriteData      ,
    oReadData       ,
    iWriteValid     ,
    iReadValid      ,
    oWriteAck       ,
    oReadAck        ,
    oDstWOpcode     ,
    oDstWTargetID   ,
    oDstWSourceID   ,
    oDstWAddress    ,
    oDstWLength     ,
    oDstWCmdValid   ,
    iDstWCmdReady   ,
    oDstWriteData   ,
    oDstWriteValid  ,
    oDstWriteLast   ,
    iDstWriteReady  ,
    oDstROpcode     ,
    oDstRTargetID   ,
    oDstRSourceID   ,
    oDstRAddress    ,
    oDstRLength     ,
    oDstRCmdValid   ,
    iDstRCmdReady   ,
    iDstReadData    ,
    iDstReadValid   ,
    iDstReadLast    ,
    oDstReadReady   ,
    oPCGWOpcode     ,
    oPCGWTargetID   ,
    oPCGWSourceID   ,
    oPCGWAddress    ,
    oPCGWLength     ,
    oPCGWCmdValid   ,
    iPCGWCmdReady   ,
    oPCGWriteData   ,
    oPCGWriteValid  ,
    oPCGWriteLast   ,
    iPCGWriteReady  ,
    oPCGROpcode     ,
    oPCGRTargetID   ,
    oPCGRSourceID   ,
    oPCGRAddress    ,
    oPCGRLength     ,
    oPCGRCmdValid   ,
    iPCGRCmdReady   ,
    iPCGReadData    ,
    iPCGReadValid   ,
    iPCGReadLast    ,
    oPCGReadReady   ,
    iWaysReadybusy  ,
    oROMClock       ,
    oROMReset       ,
    oROMAddr        ,
    oROMRW          ,
    oROMEnable      ,
    oROMWData       ,
    iROMRData
);
    input                               iClock          ;
    input                               iReset          ;
    // Command Interface
    input   [AddressWidth - 1:0]        iWriteAddress   ;
    input   [AddressWidth - 1:0]        iReadAddress    ;
    input   [DataWidth - 1:0]           iWriteData      ;
    output  [DataWidth - 1:0]           oReadData       ;
    input                               iWriteValid     ;
    input                               iReadValid      ;
    output                              oWriteAck       ;
    output                              oReadAck        ;

    // Data Cascade Layer Interface
    output  [5:0]                       oDstWOpcode     ;
    output  [4:0]                       oDstWTargetID   ;
    output  [4:0]                       oDstWSourceID   ;
    output  [AddressWidth - 1:0]        oDstWAddress    ;
    output  [InnerIFLengthWidth - 1:0]  oDstWLength     ;
    output                              oDstWCmdValid   ;
    input                               iDstWCmdReady   ;
    output  [DataWidth - 1:0]           oDstWriteData   ;
    output                              oDstWriteValid  ;
    output                              oDstWriteLast   ;
    input                               iDstWriteReady  ;
    
    output  [5:0]                       oDstROpcode     ;
    output  [4:0]                       oDstRTargetID   ;
    output  [4:0]                       oDstRSourceID   ;
    output  [AddressWidth - 1:0]        oDstRAddress    ;
    output  [InnerIFLengthWidth - 1:0]  oDstRLength     ;
    output                              oDstRCmdValid   ;
    input                               iDstRCmdReady   ;
    input   [DataWidth - 1:0]           iDstReadData    ;
    input                               iDstReadValid   ;
    input                               iDstReadLast    ;
    output                              oDstReadReady   ;
    
    // PCG Interface
    output  [5:0]                       oPCGWOpcode     ;
    output  [4:0]                       oPCGWTargetID   ;
    output  [4:0]                       oPCGWSourceID   ;
    output  [39:0]                      oPCGWAddress    ;
    output  [InnerIFLengthWidth - 1:0]  oPCGWLength     ;
    output                              oPCGWCmdValid   ;
    input                               iPCGWCmdReady   ;
    output  [DataWidth - 1:0]           oPCGWriteData   ;
    output                              oPCGWriteValid  ;
    output                              oPCGWriteLast   ;
    input                               iPCGWriteReady  ;
    
    output  [5:0]                       oPCGROpcode     ;
    output  [4:0]                       oPCGRTargetID   ;
    output  [4:0]                       oPCGRSourceID   ;
    output  [39:0]                      oPCGRAddress    ;
    output  [InnerIFLengthWidth - 1:0]  oPCGRLength     ;
    output                              oPCGRCmdValid   ;
    input                               iPCGRCmdReady   ;
    input   [DataWidth - 1:0]           iPCGReadData    ;
    input                               iPCGReadValid   ;
    input                               iPCGReadLast    ;
    output                              oPCGReadReady   ;
    
    input   [NumberOfWays - 1:0]        iWaysReadybusy  ;
    
    output                              oROMClock           ;
    output                              oROMReset           ;
    output  [$clog2(UProgSize) - 1:0]   oROMAddr            ;
    output                              oROMRW              ;
    output                              oROMEnable          ;
    output  [ProgWordWidth - 1:0]       oROMWData           ;
    input   [ProgWordWidth - 1:0]       iROMRData           ;
    
    // internal signals
    // muxed command channel
    wire                                wMuxSelect      ;
    wire    [5:0]                       wMuxedWOpcode   ;
    wire    [4:0]                       wMuxedWTargetID ;
    wire    [4:0]                       wMuxedWSourceID ;
    wire    [39:0]                      wMuxedWAddress  ;
    wire    [InnerIFLengthWidth - 1:0]  wMuxedWLength   ;
    wire                                wMuxedWCmdValid ;
    wire                                wMuxedWCmdReady ;
    wire    [5:0]                       wMuxedROpcode   ;
    wire    [4:0]                       wMuxedRTargetID ;
    wire    [4:0]                       wMuxedRSourceID ;
    wire    [39:0]                      wMuxedRAddress  ;
    wire    [InnerIFLengthWidth - 1:0]  wMuxedRLength   ;
    wire                                wMuxedRCmdValid ;
    wire                                wMuxedRCmdReady ;
    
    // registers
    localparam NumberOfRegs = 9;
    parameter UProgSizeWidth = $clog2(UProgSize);
    reg     [AddressWidth - 1:0]        rDataAddress                    ;
    reg     [AddressWidth - 1:0]        rSpareAddress                   ;
    reg     [AddressWidth - 1:0]        rErrCntAddress                  ;
    reg     [AddressWidth - 1:0]        rCmpltAddress                   ;
    reg     [23:0]                      rRowAddress                     ;
    reg     [15:0]                      rColAddress                     ;
    reg     [DataWidth - 1:0]           rUserData                       ;
    reg     [NumberOfWays - 1:0]        rWaySelection                   ;
    reg     [31:0]                      rUProgramSelect                 ;
    
    wire    [AddressWidth - 1:0]        wLPQDataAddress                 ;
    wire    [AddressWidth - 1:0]        wLPQSpareAddress                ;
    wire    [AddressWidth - 1:0]        wLPQErrCntAddress               ;
    wire    [AddressWidth - 1:0]        wLPQCmpltAddress                ;
    wire    [23:0]                      wLPQRowAddress                  ;
    wire    [15:0]                      wLPQColAddress                  ;
    wire    [DataWidth - 1:0]           wLPQUserData                    ;
    wire    [NumberOfWays - 1:0]        wLPQWaySelection                ;
    wire    [UProgSizeWidth - 1:0]      wLPQUProgramSelect              ;
    
    wire    [AddressWidth - 1:0]        wDataAddress                    ;
    wire    [AddressWidth - 1:0]        wSpareAddress                   ;
    wire    [AddressWidth - 1:0]        wErrCntAddress                  ;
    wire    [AddressWidth - 1:0]        wCmpltAddress                   ;
    wire    [23:0]                      wRowAddress                     ;
    wire    [15:0]                      wColAddress                     ;
    wire    [DataWidth - 1:0]           wUserData                       ;
    wire    [NumberOfWays - 1:0]        wWaySelection                   ;
    wire    [UProgSizeWidth - 1:0]      wUProgramSelect                 ;
    
    wire    [AddressWidth - 1:0]        wHPQDataAddress                 ;
    wire    [AddressWidth - 1:0]        wHPQSpareAddress                ;
    wire    [AddressWidth - 1:0]        wHPQErrCntAddress               ;
    wire    [AddressWidth - 1:0]        wHPQCmpltAddress                ;
    wire    [23:0]                      wHPQRowAddress                  ;
    wire    [15:0]                      wHPQColAddress                  ;
    wire    [DataWidth - 1:0]           wHPQUserData                    ;
    wire    [NumberOfWays - 1:0]        wHPQWaySelection                ;
    wire    [UProgSizeWidth - 1:0]      wHPQUProgramSelect              ;
    
    wire                                wDispatchFSMTrigger             ;
    reg                                 rUProgSelValid                  ;
    // 0: ready/busy
    reg                                 rChStatus                       ;
    
    wire    [NumberOfWays - 1:0]        wSelectedWay                    ;
    reg     [DataWidth - 1:0]           rReadDataOut                    ;
    reg     [DataWidth - 1:0]           rRegDataOut                     ;
    
    //
    wire    [ProgWordWidth - 1:0]       wUProgData      ;
    reg     [ProgWordWidth - 1:0]       rUProgData      ;
    wire                                wUProgDataValid ;
    wire                                wUProgDataReady ;
    
    wire    [5:0]                       wDPQWOpcode     ;
    wire    [4:0]                       wDPQWTargetID   ;
    wire    [4:0]                       wDPQWSourceID   ;
    wire    [AddressWidth - 1:0]        wDPQWAddress    ;
    wire    [InnerIFLengthWidth - 1:0]  wDPQWLength     ;
    wire                                wDPQWCmdValid   ;
    wire                                wDPQWCmdReady   ;
    
    wire    [5:0]                       wDPQROpcode     ;
    wire    [4:0]                       wDPQRTargetID   ;
    wire    [4:0]                       wDPQRSourceID   ;
    wire    [AddressWidth - 1:0]        wDPQRAddress    ;
    wire    [InnerIFLengthWidth - 1:0]  wDPQRLength     ;
    wire                                wDPQRCmdValid   ;
    wire                                wDPQRCmdReady   ;
    
    wire    [DataWidth - 1:0]           wDPQWriteData   ;
    wire                                wDPQWriteValid  ;
    wire                                wDPQWriteLast   ;
    wire                                wDPQWriteReady  ;
    
    wire    [DataWidth - 1:0]           wDPQReadData    ;
    wire                                wDPQReadValid   ;
    wire                                wDPQReadLast    ;
    wire                                wDPQReadReady   ;
    
    reg                                 rPipeliningMode ;
    
    localparam State_Halt               = 3'b000        ;
    localparam State_FirstFetch         = 3'b001        ;
    localparam State_Decode             = 3'b011        ;
    localparam State_WritecmdToModule   = 3'b010        ;
    localparam State_ReadcmdToModule    = 3'b110        ;
    localparam State_UpTransfer         = 3'b111        ;
    localparam State_DownTransfer       = 3'b101        ;
    localparam State_NextRequest        = 3'b100        ;
    
    V2DatapathClockConverter32
    DatapathQueue
    (
        .iSClock        (iClock         ),
        .iSReset        (iReset         ),
        .iSWOpcode      (wDPQWOpcode    ),
        .iSWTargetID    (wDPQWTargetID  ),
        .iSWSourceID    (wDPQWSourceID  ),
        .iSWAddress     (wDPQWAddress   ),
        .iSWLength      (wDPQWLength    ),
        .iSWCMDValid    (wDPQWCmdValid  ),
        .oSWCMDReady    (wDPQWCmdReady  ),
        .iSWriteData    (wDPQWriteData   ),
        .iSWriteLast    (wDPQWriteLast   ),
        .iSWriteValid   (wDPQWriteValid  ),
        .oSWriteReady   (wDPQWriteReady  ),
        .iSROpcode      (wDPQROpcode    ),
        .iSRTargetID    (wDPQRTargetID  ),
        .iSRSourceID    (wDPQRSourceID  ),
        .iSRAddress     (wDPQRAddress   ),
        .iSRLength      (wDPQRLength    ),
        .iSRCMDValid    (wDPQRCmdValid  ),
        .oSRCMDReady    (wDPQRCmdReady  ),
        .oSReadData     (wDPQReadData    ),
        .oSReadLast     (wDPQReadLast    ),
        .oSReadValid    (wDPQReadValid   ),
        .iSReadReady    (wDPQReadReady   ),
        .iMClock        (iClock         ),
        .iMReset        (iReset         ),
        .oMWOpcode      (oDstWOpcode    ),
        .oMWTargetID    (oDstWTargetID  ),
        .oMWSourceID    (oDstWSourceID  ),
        .oMWAddress     (oDstWAddress   ),
        .oMWLength      (oDstWLength    ),
        .oMWCMDValid    (oDstWCmdValid  ),
        .iMWCMDReady    (iDstWCmdReady  ),
        .oMWriteData    (oDstWriteData  ),
        .oMWriteLast    (oDstWriteLast  ),
        .oMWriteValid   (oDstWriteValid ),
        .iMWriteReady   (iDstWriteReady ),
        .oMROpcode      (oDstROpcode    ),
        .oMRTargetID    (oDstRTargetID  ),
        .oMRSourceID    (oDstRSourceID  ),
        .oMRAddress     (oDstRAddress   ),
        .oMRLength      (oDstRLength    ),
        .oMRCMDValid    (oDstRCmdValid  ),
        .iMRCMDReady    (iDstRCmdReady  ),
        .iMReadData     (iDstReadData   ),
        .iMReadLast     (iDstReadLast   ),
        .iMReadValid    (iDstReadValid  ),
        .oMReadReady    (oDstReadReady  )
    );

    // Mux
    CommandChannelMux
    Inst_CommandChannelMux
    (
        .iClock         (iClock         ),
        .iReset         (iReset         ),
        .oDstWOpcode    (wDPQWOpcode    ),
        .oDstWTargetID  (wDPQWTargetID  ),
        .oDstWSourceID  (wDPQWSourceID  ),
        .oDstWAddress   (wDPQWAddress   ),
        .oDstWLength    (wDPQWLength    ),
        .oDstWCmdValid  (wDPQWCmdValid  ),
        .iDstWCmdReady  (wDPQWCmdReady  ),
        .oDstROpcode    (wDPQROpcode    ),
        .oDstRTargetID  (wDPQRTargetID  ),
        .oDstRSourceID  (wDPQRSourceID  ),
        .oDstRAddress   (wDPQRAddress   ),
        .oDstRLength    (wDPQRLength    ),
        .oDstRCmdValid  (wDPQRCmdValid  ),
        .iDstRCmdReady  (wDPQRCmdReady  ),
        .oPCGWOpcode    (oPCGWOpcode    ),
        .oPCGWTargetID  (oPCGWTargetID  ),
        .oPCGWSourceID  (oPCGWSourceID  ),
        .oPCGWAddress   (oPCGWAddress   ),
        .oPCGWLength    (oPCGWLength    ),
        .oPCGWCmdValid  (oPCGWCmdValid  ),
        .iPCGWCmdReady  (iPCGWCmdReady  ),
        .oPCGROpcode    (oPCGROpcode    ),
        .oPCGRTargetID  (oPCGRTargetID  ),
        .oPCGRSourceID  (oPCGRSourceID  ),
        .oPCGRAddress   (oPCGRAddress   ),
        .oPCGRLength    (oPCGRLength    ),
        .oPCGRCmdValid  (oPCGRCmdValid  ),
        .iPCGRCmdReady  (iPCGRCmdReady  ),
        .iMuxSelect     (wMuxSelect     ),
        .iMuxedWOpcode  (wMuxedWOpcode  ),
        .iMuxedWTargetID(wMuxedWTargetID),
        .iMuxedWSourceID(wMuxedWSourceID),
        .iMuxedWAddress (wMuxedWAddress ),
        .iMuxedWLength  (wMuxedWLength  ),
        .iMuxedWCmdValid(wMuxedWCmdValid),
        .oMuxedWCmdReady(wMuxedWCmdReady),
        .iMuxedROpcode  (wMuxedROpcode  ),
        .iMuxedRTargetID(wMuxedRTargetID),
        .iMuxedRSourceID(wMuxedRSourceID),
        .iMuxedRAddress (wMuxedRAddress ),
        .iMuxedRLength  (wMuxedRLength  ),
        .iMuxedRCmdValid(wMuxedRCmdValid),
        .oMuxedRCmdReady(wMuxedRCmdReady)
    );
    
    // RegisterFile
    Decoder
    #
    (
        .OutputWidth(NumberOfWays)
    )
    Inst_WaySelector
    (
        .I(iWriteData   ),
        .O(wSelectedWay )
    );
    
    assign oReadData = rReadDataOut;
    
    wire wReqQPushSignal    ;
    
    wire wReqLPQFull        ;
    wire wReqLPQPopSignal   ;
    wire wReqLPQEmpty       ;
    wire wReqLPQValid       ;
    wire wReqLPQReady       ;
    
    wire wReqHPQFull        ;
    wire wReqHPQPopSignal   ;
    wire wReqHPQEmpty       ;
    wire wReqHPQValid       ;
    wire wReqHPQReady       ;
    
    wire wReqQValid         ;
    wire wReqQReady         ;
    
    wire wReqQFull          ;
    wire wReqQEmpty         ;
    
    wire [7:0]  wReqQCount  ;
    wire [3:0]  wReqLPQCount;
    wire [3:0]  wReqHPQCount;
    
    assign wReqQCount = {wReqHPQCount, wReqLPQCount};
    
    localparam ReqQState_Idle         = 1'b0        ;
    localparam ReqQState_Push         = 1'b1        ;
    reg rReqQNextState;
    reg rReqQCurState;
    
    always @ (posedge iClock)
        if (iReset)
            rReqQCurState <= ReqQState_Idle;
        else
            rReqQCurState <= rReqQNextState;
    
    always @ (*)
        case (rReqQCurState)
        ReqQState_Idle:
            rReqQNextState <= (iWriteValid && (iWriteAddress[7:0] == 8'h00))?ReqQState_Push:ReqQState_Idle;
        ReqQState_Push:
            rReqQNextState <= (!wReqQFull)?ReqQState_Idle:ReqQState_Push;
        endcase
    
    assign oWriteAck = (rReqQCurState == ReqQState_Idle);
    
    assign wReqQFull = (rUProgramSelect[31])?wReqHPQFull:wReqLPQFull;
    
    assign wReqQPushSignal = !wReqQFull && (rReqQCurState == ReqQState_Push);
    
    always @ (*)
        if (rReqQCurState == ReqQState_Idle)
            rChStatus <= 1'b0;
        else
            rChStatus <= 1'b1;
        
    DRSCFIFO_288x16_withCount
    Inst_ReqQ_Low_Priority
    (
        .iClock         (iClock                 ),
        .iReset         (iReset                 ),
        .iPushData      ({
                            rDataAddress    ,
                            rSpareAddress   ,
                            rErrCntAddress  ,
                            rCmpltAddress   ,
                            rRowAddress     ,
                            rColAddress     ,
                            rUserData       ,
                            rWaySelection   ,
                            rUProgramSelect[UProgSizeWidth - 1:0]
                         }),
        .iPushEnable    (wReqQPushSignal & !rUProgramSelect[31]),
        .oIsFull        (wReqLPQFull            ),
        .oPopData       ({
                            wLPQDataAddress    ,
                            wLPQSpareAddress   ,
                            wLPQErrCntAddress  ,
                            wLPQCmpltAddress   ,
                            wLPQRowAddress     ,
                            wLPQColAddress     ,
                            wLPQUserData       ,
                            wLPQWaySelection   ,
                            wLPQUProgramSelect[UProgSizeWidth - 1:0]
                         }),
        .iPopEnable     (wReqLPQPopSignal       ),
        .oIsEmpty       (wReqLPQEmpty           ),
        .oDataCount     (wReqLPQCount           )
    );
    
    AutoFIFOPopControl
    Inst_ReqQ_Low_Priority_PopControl
    (
        .iClock         (iClock                 ),
        .iReset         (iReset                 ),
        .oPopSignal     (wReqLPQPopSignal       ),
        .iEmpty         (wReqLPQEmpty           ),
        .oValid         (wReqLPQValid           ),
        .iReady         (wReqLPQReady           )
    );
        
    DRSCFIFO_288x16_withCount
    Inst_ReqQ_High_Priority
    (
        .iClock         (iClock                 ),
        .iReset         (iReset                 ),
        .iPushData      ({
                            rDataAddress    ,
                            rSpareAddress   ,
                            rErrCntAddress  ,
                            rCmpltAddress   ,
                            rRowAddress     ,
                            rColAddress     ,
                            rUserData       ,
                            rWaySelection   ,
                            rUProgramSelect[UProgSizeWidth - 1:0]
                         }),
        .iPushEnable    (wReqQPushSignal & rUProgramSelect[31]),
        .oIsFull        (wReqHPQFull            ),
        .oPopData       ({
                            wHPQDataAddress    ,
                            wHPQSpareAddress   ,
                            wHPQErrCntAddress  ,
                            wHPQCmpltAddress   ,
                            wHPQRowAddress     ,
                            wHPQColAddress     ,
                            wHPQUserData       ,
                            wHPQWaySelection   ,
                            wHPQUProgramSelect[UProgSizeWidth - 1:0]
                         }),
        .iPopEnable     (wReqHPQPopSignal       ),
        .oIsEmpty       (wReqHPQEmpty           ),
        .oDataCount     (wReqHPQCount           )
    );
    
    AutoFIFOPopControl
    Inst_ReqQ_High_Priority_PopControl
    (
        .iClock         (iClock                 ),
        .iReset         (iReset                 ),
        .oPopSignal     (wReqHPQPopSignal       ),
        .iEmpty         (wReqHPQEmpty           ),
        .oValid         (wReqHPQValid           ),
        .iReady         (wReqHPQReady           )
    );
    
    assign wDataAddress     = (wReqHPQValid)?wHPQDataAddress   :wLPQDataAddress   ;
    assign wSpareAddress    = (wReqHPQValid)?wHPQSpareAddress  :wLPQSpareAddress  ;
    assign wErrCntAddress   = (wReqHPQValid)?wHPQErrCntAddress :wLPQErrCntAddress ;
    assign wCmpltAddress    = (wReqHPQValid)?wHPQCmpltAddress  :wLPQCmpltAddress  ;
    assign wRowAddress      = (wReqHPQValid)?wHPQRowAddress    :wLPQRowAddress    ;
    assign wColAddress      = (wReqHPQValid)?wHPQColAddress    :wLPQColAddress    ;
    assign wUserData        = (wReqHPQValid)?wHPQUserData      :wLPQUserData      ;
    assign wWaySelection    = (wReqHPQValid)?wHPQWaySelection  :wLPQWaySelection  ;
    assign wUProgramSelect  = (wReqHPQValid)?wHPQUProgramSelect:wLPQUProgramSelect;
    
    assign wReqQValid       = (wReqHPQValid)?wReqHPQValid:wReqLPQValid;
    assign wReqHPQReady     = (wReqHPQValid)?wReqQReady:0;
    assign wReqLPQReady     = (wReqHPQValid)?0:wReqQReady;
    assign wReqQEmpty       = (wReqHPQValid)?wReqHPQEmpty:wReqLPQEmpty;
    
    wire    [31:0] wIdleTimeCounter;
    
    TimeCounter
    LLNFCIdleTimeCounter
    (
        .iClock         (iClock                                             ),
        .iReset         (iReset                                             ),
        .iEnabled       (1'b1                                               ),
        .iPeriodSetting (iWriteData                                         ),
        .iSettingValid  (iWriteValid && oWriteAck & (iWriteAddress == 8'h30)),
        .iProbe         (iPCGWCmdReady                                      ),
        .oCountValue    (wIdleTimeCounter                                   )
    );
    
    always @ (posedge iClock)
        if (iReset)
        begin
            rUProgramSelect <= {(UProgSizeWidth){1'b0}};
            rRowAddress     <= 24'b0;
            rColAddress     <= 16'b0;
            rUserData       <= 32'h12341234;
            rDataAddress    <= {(AddressWidth){1'b0}};
            rSpareAddress   <= {(AddressWidth){1'b0}};
            rErrCntAddress  <= {(AddressWidth){1'b0}};
            rCmpltAddress   <= {(AddressWidth){1'b0}};
            rWaySelection   <= 1'b1;
            rPipeliningMode <= 1'b0;
        end
        else
        begin
            if (iWriteValid && oWriteAck)
                case (iWriteAddress[7:0])
                1'h00:
                    rUProgramSelect         <= iWriteData;
                8'h04:
                    rRowAddress             <= iWriteData;
                8'h08:
                    rUserData               <= iWriteData;
                8'h0C:
                    rDataAddress            <= iWriteData;
                8'h10:
                    rSpareAddress           <= iWriteData;
                8'h14:
                    rErrCntAddress          <= iWriteData;
                8'h18:
                    rCmpltAddress           <= iWriteData;
                8'h1C:
                    rWaySelection           <= wSelectedWay;
                8'h28:
                    rColAddress             <= iWriteData;
                8'h38:
                    rPipeliningMode         <= iWriteData[0];
                endcase
        end
    
    always @ (posedge iClock)
        if (iReset)
            rReadDataOut <= {(DataWidth){1'b0}};
        else
            if (iReadValid)
            begin
                case (iReadAddress[7:0])
                8'h00:
                    rReadDataOut            <= rUProgramSelect      ;
                8'h04:
                    rReadDataOut            <= rRowAddress          ;
                8'h08:
                    rReadDataOut            <= rUserData            ;
                8'h0C:
                    rReadDataOut            <= rDataAddress         ;
                8'h10:
                    rReadDataOut            <= rSpareAddress        ;
                8'h14:
                    rReadDataOut            <= rErrCntAddress       ;
                8'h18:
                    rReadDataOut            <= rCmpltAddress        ;
                8'h1C:
                    rReadDataOut            <= rWaySelection        ;
                8'h20:
                    rReadDataOut            <= rChStatus            ;
                8'h24:
                    rReadDataOut            <= iWaysReadybusy       ;
                8'h28:
                    rReadDataOut            <= rColAddress          ;
                8'h2C:
                    rReadDataOut            <= !rChStatus & wReqQEmpty & (iPCGWCmdReady != 1'b0);
                8'h30:
                    rReadDataOut            <= wIdleTimeCounter     ;
                8'h34:
                    rReadDataOut            <= wReqQCount           ;
                8'h38:
                    rReadDataOut            <= rPipeliningMode      ;
                endcase
            end
            
    reg rReadAck    ;
    
    always @ (posedge iClock)
        if (iReset)
            rReadAck <= 1'b0;
        else
            if (!rReadAck && iReadValid)
                rReadAck <= 1'b1;
            else
                rReadAck <= 1'b0;
    
    assign oReadAck = rReadAck;
    
    uProgROM
    #
    (
        .ProgWordWidth  (ProgWordWidth  ),
        .UProgSize      (UProgSize      )
    )
    Inst_uProgROM
    (
        .iClock                 (iClock         ),
        .iReset                 (iReset         ),
        .iNewProgCursor         (wUProgramSelect),
        .iNewProgCursorValid    (rUProgSelValid ),
        .oProgData              (wUProgData     ),
        .oProgDataValid         (wUProgDataValid),
        .iProgDataReady         (wUProgDataReady),
        .oROMClock              (oROMClock      ),
        .oROMReset              (oROMReset      ),
        .oROMAddr               (oROMAddr       ),
        .oROMRW                 (oROMRW         ),
        .oROMEnable             (oROMEnable     ),
        .oROMWData              (oROMWData      ),
        .iROMRData              (iROMRData      )
    );
    
    reg     [2:0]                       rCurState       ;
    reg     [2:0]                       rNextState      ;
    
    localparam UPFunc_Halt      = 4'b0000;
    localparam UPFunc_WriteCmd  = 4'b0001;
    localparam UPFunc_ReadCmd   = 4'b0010;
    localparam UPFunc_Uptrans   = 4'b0100;
    localparam UPFunc_Downtrans = 4'b1000;
    wire    [3:0]                       wRegdUPFunc             ;
    wire                                wRegdUPChSelect         ;
    wire    [5:0]                       wRegdUPOpcode           ;
    wire    [4:0]                       wRegdUPSourceID         ;
    wire    [4:0]                       wRegdUPTargetID         ;
    wire    [InnerIFLengthWidth - 1:0]  wRegdUPLength           ;
    wire    [3:0]                       wRegdUPAddrSrcRegSel    ;
    wire    [3:0]                       wUPFunc                 ;
    wire                                wUPChSelect             ;
    wire    [5:0]                       wUPOpcode               ;
    wire    [4:0]                       wUPSourceID             ;
    wire    [4:0]                       wUPTargetID             ;
    wire    [InnerIFLengthWidth - 1:0]  wUPLength               ;
    wire    [3:0]                       wUPAddrSrcRegSel        ;
    
    wire                                wUptrfLenQPushSignal    ;
    wire                                wUptrfLenQFull          ;
    wire                                wUptrfLenQPopSignal     ;
    wire                                wUptrfLenQEmpty         ;
    wire    [InnerIFLengthWidth - 1:0]  wUptrfLenQLength        ;
    wire                                wUptrfLenQValid         ;
    wire                                wUptrfLenQReady         ;
    
    wire                                wDntrfLenQPushSignal    ;
    wire                                wDntrfLenQFull          ;
    wire                                wDntrfLenQPopSignal     ;
    wire                                wDntrfLenQEmpty         ;
    wire    [InnerIFLengthWidth - 1:0]  wDntrfLenQLength        ;
    wire                                wDntrfLenQValid         ;
    wire                                wDntrfLenQReady         ;
    
    assign
    {
        wRegdUPChSelect     ,
        wRegdUPAddrSrcRegSel,
        wRegdUPOpcode       ,
        wRegdUPSourceID     ,
        wRegdUPTargetID     ,
        wRegdUPLength       ,
        wRegdUPFunc
    } = rUProgData;
    assign
    {
        wUPChSelect     ,
        wUPAddrSrcRegSel,
        wUPOpcode       ,
        wUPSourceID     ,
        wUPTargetID     ,
        wUPLength       ,
        wUPFunc
    } = wUProgData;
    
    assign wMuxSelect = wRegdUPChSelect;
    
    always @ (posedge iClock)
        if (iReset)
            rCurState <= State_Halt;
        else
            rCurState <= rNextState;
    
    always @ (*)
        case (rCurState)
        State_Halt:
            rNextState <= (wReqQValid)?State_FirstFetch:State_Halt;
        State_FirstFetch:
            rNextState <= State_Decode;
        State_Decode:
        begin
            if (wUProgDataValid)
                case (wUPFunc)
                UPFunc_WriteCmd:
                    rNextState <= State_WritecmdToModule;
                UPFunc_ReadCmd:
                    rNextState <= State_ReadcmdToModule;
                UPFunc_Uptrans:
                    rNextState <= State_UpTransfer;
                UPFunc_Downtrans:
                    rNextState <= State_DownTransfer;
                default:
                    rNextState <= State_NextRequest;
                endcase
            else
                rNextState <= State_Decode;
        end
        State_WritecmdToModule:
            rNextState <= (wMuxedWCmdReady)?State_Decode:State_WritecmdToModule;
        State_ReadcmdToModule:
            rNextState <= (wMuxedRCmdReady)?State_Decode:State_ReadcmdToModule;
        State_UpTransfer:
            rNextState <= (!wUptrfLenQFull)?State_Decode:State_UpTransfer;
        State_DownTransfer:
            rNextState <= (!wDntrfLenQFull)?State_Decode:State_DownTransfer;
        State_NextRequest:
            rNextState <= (rPipeliningMode | iPCGWCmdReady)?State_Halt:State_NextRequest;
        default:
            rNextState <= State_Halt;
        endcase
    
    assign wReqQReady = (rNextState == State_Halt);
    
    always @ (posedge iClock)
        if (iReset)
            rUProgSelValid <= 1'b0;
        else
            if (!rUProgSelValid && rCurState == State_Halt && wReqQValid)
                rUProgSelValid <= 1'b1;
            else
                rUProgSelValid <= 1'b0;
    
    assign wUProgDataReady = (rCurState == State_Decode);

    always @ (posedge iClock)
        if (iReset)
            rUProgData <= {(ProgWordWidth){1'b0}};
        else
            case (rCurState)
            State_Decode:
                if (wUProgDataValid)
                    rUProgData <= wUProgData;
            endcase

    always @ (posedge iClock)
        if (iReset)
            rRegDataOut <= {(DataWidth){1'b0}};
        else
        begin
            if (rCurState == State_Decode)
                case (wUPAddrSrcRegSel)
                0:
                    rRegDataOut             <= {(DataWidth){1'b0}}  ;
                1:
                    rRegDataOut             <= wRowAddress          ; // Row Address
                2:
                    rRegDataOut             <= wUserData            ;
                3:
                    rRegDataOut             <= wDataAddress         ;
                4:
                    rRegDataOut             <= wSpareAddress        ;
                5:
                    rRegDataOut             <= wErrCntAddress       ;
                6:
                    rRegDataOut             <= wCmpltAddress        ;
                7:
                    rRegDataOut             <= wWaySelection        ;
                8:
                    rRegDataOut             <= wColAddress          ;
                endcase
        end
    
    assign wMuxedWOpcode    = wRegdUPOpcode     ;
    assign wMuxedWTargetID  = wRegdUPTargetID   ;
    assign wMuxedWSourceID  = wRegdUPSourceID   ;
    assign wMuxedWAddress   = rRegDataOut       ;
    assign wMuxedWLength    = wRegdUPLength     ;
    assign wMuxedWCmdValid  = (rCurState == State_WritecmdToModule);
    assign wMuxedROpcode    = wRegdUPOpcode     ;
    assign wMuxedRTargetID  = wRegdUPTargetID   ;
    assign wMuxedRSourceID  = wRegdUPSourceID   ;
    assign wMuxedRAddress   = rRegDataOut       ;
    assign wMuxedRLength    = wRegdUPLength     ;
    assign wMuxedRCmdValid  = (rCurState == State_ReadcmdToModule);
    
    assign wUptrfLenQPushSignal = (rCurState == State_UpTransfer) && !wUptrfLenQFull;
    
    SCFIFO_64x64_withCount
    Inst_UptrfLenQ
    (
        .iClock         (iClock                 ),
        .iReset         (iReset                 ),
        .iPushData      (wRegdUPLength          ),
        .iPushEnable    (wUptrfLenQPushSignal   ),
        .oIsFull        (wUptrfLenQFull         ),
        .oPopData       (wUptrfLenQLength       ),
        .iPopEnable     (wUptrfLenQPopSignal    ),
        .oIsEmpty       (wUptrfLenQEmpty        ),
        .oDataCount     (                       )
    );
    
    AutoFIFOPopControl
    Inst_UptrfLenQAutoPop
    (
        .iClock         (iClock                 ),
        .iReset         (iReset                 ),
        .oPopSignal     (wUptrfLenQPopSignal    ),
        .iEmpty         (wUptrfLenQEmpty        ),
        .oValid         (wUptrfLenQValid        ),
        .iReady         (wUptrfLenQReady        )
    );
    
    DataDriver
    #
    (
        .DataWidth      (32                     ),
        .LengthWidth    (InnerIFLengthWidth     )
    )
    Inst_UptrfDataDriver
    (
        .CLK            (iClock                 ),
        .RESET          (iReset                 ),
        .SRCLEN         (wUptrfLenQLength       ),
        .SRCVALID       (wUptrfLenQValid        ),
        .SRCREADY       (wUptrfLenQReady        ),
        .DATA           (iPCGReadData           ),
        .DVALID         (iPCGReadValid          ),
        .DREADY         (oPCGReadReady          ),
        .XDATA          (wDPQWriteData          ),
        .XDVALID        (wDPQWriteValid         ),
        .XDREADY        (wDPQWriteReady         ),
        .XDLAST         (wDPQWriteLast          )
    );
    
    assign wDntrfLenQPushSignal = (rCurState == State_DownTransfer) && !wDntrfLenQFull;
    
    SCFIFO_64x64_withCount
    Inst_DntrfLenQ
    (
        .iClock         (iClock                 ),
        .iReset         (iReset                 ),
        .iPushData      (wRegdUPLength          ),
        .iPushEnable    (wDntrfLenQPushSignal   ),
        .oIsFull        (wDntrfLenQFull         ),
        .oPopData       (wDntrfLenQLength       ),
        .iPopEnable     (wDntrfLenQPopSignal    ),
        .oIsEmpty       (wDntrfLenQEmpty        ),
        .oDataCount     (                       )
    );
    
    AutoFIFOPopControl
    Inst_DntrfLenQAutoPop
    (
        .iClock         (iClock                 ),
        .iReset         (iReset                 ),
        .oPopSignal     (wDntrfLenQPopSignal    ),
        .iEmpty         (wDntrfLenQEmpty        ),
        .oValid         (wDntrfLenQValid        ),
        .iReady         (wDntrfLenQReady        )
    );
    
    DataDriver
    #
    (
        .DataWidth      (32                     ),
        .LengthWidth    (InnerIFLengthWidth     )
    )
    Inst_DntrfDataDriver
    (
        .CLK            (iClock                 ),
        .RESET          (iReset                 ),
        .SRCLEN         (wDntrfLenQLength       ),
        .SRCVALID       (wDntrfLenQValid        ),
        .SRCREADY       (wDntrfLenQReady        ),
        .DATA           (wDPQReadData           ),
        .DVALID         (wDPQReadValid          ),
        .DREADY         (wDPQReadReady          ),
        .XDATA          (oPCGWriteData          ),
        .XDVALID        (oPCGWriteValid         ),
        .XDREADY        (iPCGWriteReady         ),
        .XDLAST         (oPCGWriteLast          )
    );

endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// BCHDecoderControl for Cosmos OpenSSD
// Copyright (c) 2015 Hanyang University ENC Lab.
// Contributed by Jinwoo Jeong <jwjeong@enc.hanyang.ac.kr>
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
// Engineer: Jinwoo Jeong <jwjeong@enc.hanyang.ac.kr>
//           Kibin Park <kbpark@enc.hanyang.ac.kr>
// 
// Project Name: Cosmos OpenSSD
// Design Name: BCH decoder controller
// Module Name: BCHDecoderControl
// File Name: BCHDecoderControl.v
//
// Version: v1.0.0
//
// Description: BCH decoder controller
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////

module BCHDecoderControl
#
(
    parameter AddressWidth          = 32    ,
    parameter DataWidth             = 32    ,
    parameter InnerIFLengthWidth    = 16    ,
    parameter ThisID                = 2     ,
    parameter Multi                 = 2     ,
    parameter GaloisFieldDegree     = 12    ,
    parameter MaxErrorCountBits     = 9     ,
    parameter Syndromes             = 27    ,
    parameter ELPCoefficients       = 15
)
(
    iClock              ,
    iReset              ,
    iSrcOpcode          ,
    iSrcTargetID        ,
    iSrcSourceID        ,
    iSrcAddress         ,
    iSrcLength          ,
    iSrcCmdValid        ,
    oSrcCmdReady        ,
    iSrcWriteData       ,
    iSrcWriteValid      ,
    iSrcWriteLast       ,
    oSrcWriteReady      ,
    oDstOpcode          ,
    oDstTargetID        ,
    oDstSourceID        ,
    oDstAddress         ,
    oDstLength          ,
    oDstCmdValid        ,
    iDstCmdReady        ,
    oDstWriteData       ,
    oDstWriteValid      ,
    oDstWriteLast       ,
    iDstWriteReady      ,
    
    iSharedKESReady     ,
    oErrorDetectionEnd  ,
    oDecodeNeeded       ,
    oSyndromes          ,
    iIntraSharedKESEnd  ,
    iErroredChunk       ,
    iCorrectionFail     ,
    iErrorCount         ,
    iELPCoefficients    ,
    oCSAvailable
);

    input                                                   iClock              ;
    input                                                   iReset              ;
    
    input   [5:0]                                           iSrcOpcode          ;
    input   [4:0]                                           iSrcTargetID        ;
    input   [4:0]                                           iSrcSourceID        ;
    input   [AddressWidth - 1:0]                            iSrcAddress         ;
    input   [InnerIFLengthWidth - 1:0]                      iSrcLength          ;
    input                                                   iSrcCmdValid        ;
    output                                                  oSrcCmdReady        ;
    
    output  [5:0]                                           oDstOpcode          ;
    output  [4:0]                                           oDstTargetID        ;
    output  [4:0]                                           oDstSourceID        ;
    output  [AddressWidth - 1:0]                            oDstAddress         ;
    output  [InnerIFLengthWidth - 1:0]                      oDstLength          ;
    output                                                  oDstCmdValid        ;
    input                                                   iDstCmdReady        ;
    
    input   [DataWidth - 1:0]                               iSrcWriteData       ;
    input                                                   iSrcWriteValid      ;
    input                                                   iSrcWriteLast       ;
    output                                                  oSrcWriteReady      ;
    
    output  [DataWidth - 1:0]                               oDstWriteData       ;
    output                                                  oDstWriteValid      ;
    output                                                  oDstWriteLast       ;
    input                                                   iDstWriteReady      ;
    
    input                                                   iSharedKESReady     ;
    output  [Multi - 1:0]                                   oErrorDetectionEnd  ;
    output  [Multi - 1:0]                                   oDecodeNeeded       ;
    output  [Multi*GaloisFieldDegree*Syndromes - 1:0]       oSyndromes          ;
    input                                                   iIntraSharedKESEnd  ;
    input   [Multi - 1:0]                                   iErroredChunk       ;
    input   [Multi - 1:0]                                   iCorrectionFail     ;
    input   [Multi*MaxErrorCountBits - 1:0]                 iErrorCount         ;
    input   [Multi*GaloisFieldDegree*ELPCoefficients - 1:0] iELPCoefficients    ;
    output                                                  oCSAvailable        ;
    
    wire    [4:0]                                           wQueuedCmdSourceID  ;
    wire    [4:0]                                           wQueuedCmdTargetID  ;
    wire    [5:0]                                           wQueuedCmdOpcode    ;
    wire    [1:0]                                           wQueuedCmdType      ;
    wire    [AddressWidth - 1:0]                            wQueuedCmdAddress   ;
    wire    [InnerIFLengthWidth - 1:0]                      wQueuedCmdLength    ;
    wire                                                    wQueuedCmdValid     ;
    wire                                                    wQueuedCmdReady     ;
    
    wire    [4:0]                                           wCmdSourceID        ;
    wire    [4:0]                                           wCmdTargetID        ;
    wire    [5:0]                                           wCmdOpcode          ;
    wire    [1:0]                                           wCmdType            ;
    wire    [AddressWidth - 1:0]                            wCmdAddress         ;
    wire    [InnerIFLengthWidth - 1:0]                      wCmdLength          ;
    wire                                                    wCmdValid           ;
    wire                                                    wCmdReady           ;
    
    wire    [DataWidth - 1:0]                               wBufferedWriteData  ;
    wire                                                    wBufferedWriteValid ;
    wire                                                    wBufferedWriteLast  ;
    wire                                                    wBufferedWriteReady ;
    
    wire                                                    wDataQueuePushSignal; 
    wire                                                    wDataQueuePopSignal ;
    wire                                                    wDataQueueFull      ;
    wire                                                    wDataQueueEmpty     ;
    
    wire    [DataWidth - 1:0]                               wBypassWriteData    ;
    wire                                                    wBypassWriteLast    ;
    wire                                                    wBypassWriteValid   ;
    wire                                                    wBypassWriteReady   ;
    wire    [DataWidth - 1:0]                               wDecWriteData       ;
    wire                                                    wDecWriteValid      ;
    wire                                                    wDecWriteReady      ;
    wire                                                    wDecInDataLast      ;
    wire                                                    wDecAvailable       ;
    wire                                                    wDecodeFinished     ;
    wire                                                    wDecodeSuccess      ;
    wire    [MaxErrorCountBits - 1:0]                       wErrorSum           ;
    wire    [4*Multi - 1:0]                                 wErrorCountOut      ;
    wire    [DataWidth - 1:0]                               wCorrectedData      ;
    wire                                                    wCorrectedDataLast  ;
    wire                                                    wCorrectedDataValid ;
    wire                                                    wCorrectedDataReady ;
    wire                                                    wCSReset            ;
    wire                                                    wCSAvailable        ;
    wire                                                    wDecStandby         ;
    
    assign  oCSAvailable = wCSAvailable && wDecStandby;
    
    BCHDecoderCommandReception
    #
    (
        .AddressWidth       (AddressWidth       ),
        .DataWidth          (DataWidth          ),
        .InnerIFLengthWidth (InnerIFLengthWidth ),
        .ThisID             (ThisID             )
    )
    Inst_BCHDecoderCommandReception
    (
        .iClock             (iClock             ),
        .iReset             (iReset             ),
        .iSrcOpcode         (iSrcOpcode         ),
        .iSrcTargetID       (iSrcTargetID       ),
        .iSrcSourceID       (iSrcSourceID       ),
        .iSrcAddress        (iSrcAddress        ),
        .iSrcLength         (iSrcLength         ),
        .iSrcCmdValid       (iSrcCmdValid       ),
        .oSrcCmdReady       (oSrcCmdReady       ),
        .oQueuedCmdType     (wQueuedCmdType     ),
        .oQueuedCmdSourceID (wQueuedCmdSourceID ),
        .oQueuedCmdTargetID (wQueuedCmdTargetID ),
        .oQueuedCmdOpcode   (wQueuedCmdOpcode   ),
        .oQueuedCmdAddress  (wQueuedCmdAddress  ),
        .oQueuedCmdLength   (wQueuedCmdLength   ),
        .oQueuedCmdValid    (wQueuedCmdValid    ),
        .iQueuedCmdReady    (wQueuedCmdReady    )
    );
    
    BCHDecoderInputControl
    #
    (
        .AddressWidth       (AddressWidth       ),
        .DataWidth          (DataWidth          ),
        .InnerIFLengthWidth (InnerIFLengthWidth ),
        .ThisID             (ThisID             )
    )
    Inst_BCHDecoderInControlCore
    (
        .iClock             (iClock             ),
        .iReset             (iReset             ),
        .oDstOpcode         (wCmdOpcode         ),
        .oDstTargetID       (wCmdTargetID       ),
        .oDstSourceID       (wCmdSourceID       ),
        .oDstCmdType        (wCmdType           ),
        .oDstAddress        (wCmdAddress        ),
        .oDstLength         (wCmdLength         ),
        .oDstCmdValid       (wCmdValid          ),
        .iDstCmdReady       (wCmdReady          ),
        .iCmdSourceID       (wQueuedCmdSourceID ),
        .iCmdTargetID       (wQueuedCmdTargetID ),
        .iCmdOpcode         (wQueuedCmdOpcode   ),
        .iCmdType           (wQueuedCmdType     ),
        .iCmdAddress        (wQueuedCmdAddress  ),
        .iCmdLength         (wQueuedCmdLength   ),
        .iCmdValid          (wQueuedCmdValid    ),
        .oCmdReady          (wQueuedCmdReady    ),
        .iSrcWriteData      (iSrcWriteData      ),
        .iSrcWriteValid     (iSrcWriteValid     ),
        .iSrcWriteLast      (iSrcWriteLast      ),
        .oSrcWriteReady     (oSrcWriteReady     ),
        .oBypassWriteData   (wBypassWriteData   ),
        .oBypassWriteLast   (wBypassWriteLast   ),
        .oBypassWriteValid  (wBypassWriteValid  ),
        .iBypassWriteReady  (wBypassWriteReady  ),
        .oDecWriteData      (wDecWriteData      ),
        .oDecWriteValid     (wDecWriteValid     ),
        .iDecWriteReady     (wDecWriteReady     ),
        .iDecInDataLast     (wDecInDataLast     ),
        .iDecAvailable      (wDecAvailable      )
    );
    
    BCHDecoderX
    #
    (   
        .DataWidth          (DataWidth          ),
        .Multi              (Multi              ),
        .MaxErrorCountBits  (MaxErrorCountBits  ),
        .GaloisFieldDegree  (GaloisFieldDegree  ),
        .Syndromes          (Syndromes          ),
        .ELPCoefficients    (ELPCoefficients    )
    )
    Inst_BCHDecoderIO
    (
        .iClock                 (iClock                 ),
        .iReset                 (iReset                 ),
        .iData                  (wDecWriteData          ),
        .iDataValid             (wDecWriteValid         ),
        .oDataReady             (wDecWriteReady         ),
        .oDataLast              (wDecInDataLast         ),
        .oDecoderReady          (wDecAvailable          ),
        .oDecodeFinished        (wDecodeFinished        ),
        .oDecodeSuccess         (wDecodeSuccess         ),
        .oErrorSum              (wErrorSum              ),
        .oErrorCountOut         (wErrorCountOut         ),
        .oCorrectedData         (wCorrectedData         ),
        .oCorrectedDataValid    (wCorrectedDataValid    ),
        .oCorrectedDataLast     (wCorrectedDataLast     ),
        .iCorrectedDataReady    (wCorrectedDataReady    ),
        
        .iSharedKESReady        (iSharedKESReady        ),
        .oErrorDetectionEnd     (oErrorDetectionEnd     ),
        .oDecodeNeeded          (oDecodeNeeded          ),
        .oSyndromes             (oSyndromes             ),
        .iIntraSharedKESEnd     (iIntraSharedKESEnd     ),
        .iErroredChunk          (iErroredChunk          ),
        .iCorrectionFail        (iCorrectionFail        ),
        .iErrorCount            (iErrorCount            ),
        .iELPCoefficients       (iELPCoefficients       ),
        .oCSAvailable           (wCSAvailable           ),
        .iCSReset               (wCSReset               )
    );    
    
    
    BCHDecoderOutputControl
    #
    (
        .AddressWidth           (AddressWidth           ),
        .DataWidth              (DataWidth              ),
        .InnerIFLengthWidth     (InnerIFLengthWidth     ),
        .ThisID                 (ThisID                 ),
        .Multi                  (Multi                  ),
        .MaxErrorCountBits      (MaxErrorCountBits      )
    )
    Inst_BCHDecoderOutControlCore
    (
        .iClock                 (iClock                 ),
        .iReset                 (iReset                 ),
        .oDstOpcode             (oDstOpcode             ),
        .oDstTargetID           (oDstTargetID           ),
        .oDstSourceID           (oDstSourceID           ),
        .oDstAddress            (oDstAddress            ),
        .oDstLength             (oDstLength             ),
        .oDstCmdValid           (oDstCmdValid           ),
        .iDstCmdReady           (iDstCmdReady           ),
        .iCmdSourceID           (wCmdSourceID           ),
        .iCmdTargetID           (wCmdTargetID           ),
        .iCmdOpcode             (wCmdOpcode             ),
        .iCmdType               (wCmdType               ),
        .iCmdAddress            (wCmdAddress            ),
        .iCmdLength             (wCmdLength             ),
        .iCmdValid              (wCmdValid              ),
        .oCmdReady              (wCmdReady              ),
        .iBypassWriteData       (wBypassWriteData       ),
        .iBypassWriteLast       (wBypassWriteLast       ),
        .iBypassWriteValid      (wBypassWriteValid      ),
        .oBypassWriteReady      (wBypassWriteReady      ),
        .iDecWriteData          (wCorrectedData         ),
        .iDecWriteValid         (wCorrectedDataValid    ),
        .iDecWriteLast          (wCorrectedDataLast     ),
        .oDecWriteReady         (wCorrectedDataReady    ),
        .oDstWriteData          (wBufferedWriteData     ),
        .oDstWriteValid         (wBufferedWriteValid    ),
        .oDstWriteLast          (wBufferedWriteLast     ),
        .iDstWriteReady         (wBufferedWriteReady    ),
        .iDecodeFinished        (wDecodeFinished        ),
        .iDecodeSuccess         (wDecodeSuccess         ),
        .iErrorSum              (wErrorSum              ),
        .iErrorCountOut         (wErrorCountOut         ),
        .oCSReset               (wCSReset               ),
        .oDecStandby            (wDecStandby            )
    );
    
    assign wDataQueuePushSignal = wBufferedWriteValid && !wDataQueueFull;
    assign wBufferedWriteReady  = !wDataQueueFull;
    
    AutoFIFOPopControl
    Inst_DataQueueAutoPopControl
    (
        .iClock         (iClock             ),
        .iReset         (iReset             ),
        .oPopSignal     (wDataQueuePopSignal),
        .iEmpty         (wDataQueueEmpty    ),
        .oValid         (oDstWriteValid     ),
        .iReady         (iDstWriteReady     )
    );

    SCFIFO_64x64_withCount
    Inst_DataQueue
    (
        .iClock         (iClock                                             ),
        .iReset         (iReset                                             ),
        .iPushData      ({wBufferedWriteData, wBufferedWriteLast}           ),
        .iPushEnable    (wDataQueuePushSignal                               ),
        .oIsFull        (wDataQueueFull                                     ),
        .oPopData       ({oDstWriteData, oDstWriteLast}                     ),
        .iPopEnable     (wDataQueuePopSignal                                ),
        .oIsEmpty       (wDataQueueEmpty                                    ),
        .oDataCount     (                                                   )
    );
    
endmodule

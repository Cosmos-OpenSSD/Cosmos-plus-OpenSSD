//////////////////////////////////////////////////////////////////////////////////
// BCHEncoderDataChannel for Cosmos OpenSSD
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
// Design Name: BCH encoder controller data channel
// Module Name: BCHEncoderDataChannel
// File Name: BCHEncoderDataChannel.v
//
// Version: v1.0.0
//
// Description: BCH encoder controller data channel
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft 
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module BCHEncoderDataChannel
#
(
    parameter DataWidth             = 32    ,
    parameter InnerIFLengthWidth    = 16
)
(
    iClock          ,
    iReset          ,
    iLength         ,
    iCmdType        ,
    iCmdValid       ,
    oCmdReady       ,
    oSrcReadData    ,
    oSrcReadValid   ,
    oSrcReadLast    ,
    iSrcReadReady   ,
    iDstReadData    ,
    iDstReadValid   ,
    iDstReadLast    ,
    oDstReadReady
);

    input                               iClock          ;
    input                               iReset          ;
    
    input   [InnerIFLengthWidth - 1:0]  iLength         ;
    input   [1:0]                       iCmdType        ;
    input                               iCmdValid       ;
    output                              oCmdReady       ;
    
    output  [DataWidth - 1:0]           oSrcReadData    ;
    output                              oSrcReadValid   ;
    output                              oSrcReadLast    ;
    input                               iSrcReadReady   ;
    
    input   [DataWidth - 1:0]           iDstReadData    ;
    input                               iDstReadValid   ;
    input                               iDstReadLast    ;
    output                              oDstReadReady   ;
    
    reg     [DataWidth - 1:0]           rReadData       ;
    reg                                 rReadLast       ;
    reg                                 rReadValid      ;
    wire                                wReadReady      ;
    wire                                wReadFull       ;
    wire                                wReadEmpty      ;
    
    reg                                 rDstReadReady       ;
    
    parameter   ECCCtrlCmdType_Bypass           = 2'b00     ;
    parameter   ECCCtrlCmdType_PageEncode       = 2'b01     ;
    parameter   ECCCtrlCmdType_SpareEncode      = 2'b10     ;
    reg     [1:0]                       rCmdType            ;
    reg     [InnerIFLengthWidth - 1:0]  rLength             ;
    reg     [5:0]                       rCurLoopCount       ;
    reg     [5:0]                       rGoalLoopCount      ;
    //reg     [7:0]                       rCounter            ;
    
    reg                             rCRCSpareSwitch         ;
	wire                            wPageEncEnable          ;
    wire                            wCRCEncEnable           ;
    wire                            wCRCDataValid           ;
    wire    [DataWidth - 1:0]       wCRCData                ;
    reg                             rDstPageDataValid       ;
    reg                             rDstPageDataLast        ;
    reg     [DataWidth - 1:0]       rDstPageData            ;
    reg                             rPageDataValid          ;
    wire                            wCRCSpareSwitch         ;
    wire                            wCRCParityLast          ;
    wire                            wCRCParityValid         ;
    wire    [DataWidth - 1:0]       wCRCParityOut           ;
    
    wire                            wDownConverterReady     ;
    wire                            wDownConvertedDataValid ;
    wire                            wDownConvertedDataLast  ;
    wire    [DataWidth/2 - 1:0]     wDownConvertedData      ;
    wire                            wEncoderReady           ;
    wire                            wEncodeDataInReady      ;
    
    wire                            wPageDataLast           ;
    wire    [DataWidth/2 - 1:0]     wPageParityData         ;
    wire                            wPageParityValid        ;
    wire                            wPageParityLast         ;
    wire                            wUpConverterReady       ;
    
    wire                        wEncodeDataValid;
    wire    [DataWidth/2 - 1:0] wEncodeData;
    wire                        wUpConvertDataValid;
    wire    [DataWidth/2 - 1:0] wUpConvertData;
    wire                        wUpConvertedDataValid;
    wire                        wUpConvertedDataLast;
    reg                         rUpConvertedDataLast;
    wire                        wUpConvertedParityLast;
    wire    [DataWidth - 1:0]   wUpConvertedData;
    reg                         rReadReady;
    wire                        wDataBufferPopSignal    ;
    
    wire                        wCRCAvailable   ;
    wire                        wReset          ;
    
    localparam      State_Idle          = 3'b000;
    localparam      State_Forward       = 3'b001;
    localparam      State_Encode        = 3'b011;
    localparam      State_ParityOut     = 3'b010;
    localparam      State_LoopEnd       = 3'b110;
    reg     [2:0]   rCurState   ;
    reg     [2:0]   rNextState  ;

    assign oCmdReady = (rCurState == State_Idle);
    assign wReadReady = !wReadFull;
    assign wEncodeDataValid    =    (rCurState == State_ParityOut)  ?   wPageParityValid        : 
                                    (rCurState == State_Encode)     ?   wDownConvertedDataValid : 1'b0; 
    assign wEncodeData         =    (rCurState == State_ParityOut)  ?   wPageParityData         :   
                                    (rCurState == State_Encode)     ?   wDownConvertedData      : {(DataWidth/2){1'b0}};
    assign wUpConvertDataValid =    (rUpConvertedDataLast | wUpConvertedDataLast) ? 1'b0 : wEncodeDataValid;
    assign wEncodeDataInReady = (rCurState == State_Encode) && (wUpConverterReady & wEncoderReady);
    assign oDstReadReady = rDstReadReady;
    assign wCRCDataValid = rDstPageDataValid & wDownConverterReady;
    assign wCRCData = rDstPageData;
    assign wCRCEncEnable = (rCmdType == ECCCtrlCmdType_SpareEncode) ? 1'b0 : 1'b1;
    assign wPageEncEnable = 1'b1;
    assign wReset = (iReset) || ((rCmdType == ECCCtrlCmdType_SpareEncode) && (rCurState == State_ParityOut));
    
    always @ (posedge iClock)
        if (iReset)
            rCurState <= State_Idle;
        else
            rCurState <= rNextState;
            
    always @ (posedge iClock)
        if (iReset)
            rCRCSpareSwitch <= 0;
        else
        begin
            if (wCRCSpareSwitch)
            rCRCSpareSwitch <= 1'b1;
            else 
            begin
                if (wPageDataLast && (rCmdType == ECCCtrlCmdType_SpareEncode))
                    rCRCSpareSwitch <= 1'b0;
            end        
        end
    
    always @ (*)
        case (rCurState)
        State_Idle:
            if (iCmdValid)
            begin
                if (iCmdType == ECCCtrlCmdType_Bypass)
                    rNextState <= State_Forward;
                else
                    rNextState <= State_Encode;
            end
            else
                rNextState <= State_Idle;
        State_Forward:
            rNextState <= (iDstReadValid && iDstReadLast && oDstReadReady)?State_Idle:State_Forward;
        State_Encode:
                rNextState <= (wPageDataLast)?State_ParityOut:State_Encode;
        State_ParityOut:
                rNextState <= (wUpConvertedDataValid && wReadReady && wUpConvertedParityLast)?State_LoopEnd:State_ParityOut;
        State_LoopEnd:
            rNextState <= (rCurLoopCount == rGoalLoopCount)?State_Idle:State_Encode;
        default:
            rNextState <= State_Idle;
        endcase
    

    always @ (posedge iClock)
        if (iReset)
            rCmdType <= 2'b0;
        else
            case (rCurState)
            State_Idle:
                if (iCmdValid)
                    rCmdType <= iCmdType;
            endcase

    always @ (posedge iClock)
        if (iReset)
            rLength <= {(InnerIFLengthWidth){1'b0}};
        else
            case (rCurState)
            State_Idle:
                if (iCmdValid)
                    rLength <= iLength;
            endcase
    
    /*always @ (posedge iClock)
        if (iReset)
            rCounter <= {(8){1'b0}};
        else
            case (rCurState)
            State_Encode:
                rCounter <= (iDstReadValid & oDstReadReady) ? rCounter + 1'b1 : rCounter;
            default:
                rCounter <= {(8){1'b0}};
            endcase*/
    
    always @ (posedge iClock)
        if (iReset)
            rCurLoopCount <= {(6){1'b0}};
        else
            case (rCurState)
            State_Idle:
                rCurLoopCount <= {(6){1'b0}};
            State_LoopEnd:
                rCurLoopCount <= rCurLoopCount + 1'b1;
            endcase

    always @ (posedge iClock)
        if (iReset)
            rGoalLoopCount <= {(6){1'b0}};
        else
            case (rCurState)
            State_Idle:
                if (iCmdValid)
                begin
                    if (iCmdType == ECCCtrlCmdType_PageEncode)
                        rGoalLoopCount <= 31;
                    else
                        rGoalLoopCount <= 0;
                end
            endcase
    
    /*always @ (*)
        case (rCurState)
        State_Idle:
            rSpareCounter <= {(8){1'b0}};
        State_Encode:
            if (rCRCSpareSwitch && iDstReadValid && wCRCParityLast && wDstReadReady)
                rSpareCounter <= rSpareCounter + 1'b1;
        endcase
    */
    always @ (*)
        case (rCurState)
        State_Encode:
            if (rCmdType == ECCCtrlCmdType_PageEncode)
            begin
                rDstPageData        <=  iDstReadData;
                rDstPageDataValid   <=  iDstReadValid;
            end
            else
                if (rCRCSpareSwitch)
                begin
                    if (wCRCAvailable)
                        begin
                            rDstPageData        <=  {(DataWidth){1'b0}};
                            rDstPageDataValid   <=  1'b1;
                        end
                    else
                        begin
                            rDstPageData        <=  wCRCParityOut;
                            rDstPageDataValid   <=  wCRCParityValid;
                        end
                end        
                else
                    begin
                        rDstPageData        <=  iDstReadData;
                        rDstPageDataValid   <=  iDstReadValid;
                    end
        default:
            begin
                rDstPageData        <=  {(DataWidth){1'b0}};
                rDstPageDataValid   <=  1'b0;
            end
        endcase
    
    always @ (posedge iClock)
        if (iReset)
            rDstPageDataLast <= 0;
        else
            if (wCRCParityLast & rDstPageDataValid)
                rDstPageDataLast    <=  1'b1;    
            else
                rDstPageDataLast    <=  1'b0;
    
    always @ (posedge iClock)
        if (iReset)
            rUpConvertedDataLast <= 0;
        else
            if (wUpConvertedDataLast)
                rUpConvertedDataLast <= wUpConvertedDataLast;
            else
                if (rCurState == State_ParityOut)
                    rUpConvertedDataLast <= 0;
    always @ (*)
        case (rCurState)
        State_Forward:
            begin
                rReadData       <=  iDstReadData    ;
                rReadValid      <=  iDstReadValid   ;
                rReadLast       <=  iDstReadLast    ;
                rDstReadReady   <=  wReadReady      ;
            end
        State_Encode:
            begin
                rReadData       <=  wUpConvertedData                ;
                rReadValid      <=  (rUpConvertedDataLast) ? 1'b0 : wUpConvertedDataValid           ;
                rReadLast       <=  1'b0                            ;
                if (rCRCSpareSwitch & wCRCAvailable)
                    rDstReadReady <= 1'b0;
                else
                    rDstReadReady <= wDownConverterReady;
            end
        State_ParityOut:
            begin
                rReadData       <=  wUpConvertedData                                        ;
                rReadValid      <=  wUpConvertedDataValid;
                rReadLast       <=  wUpConvertedParityLast && (rCurLoopCount == rGoalLoopCount)    ;
                rDstReadReady   <=  1'b0                                                    ;
            end
        default:
            begin
                rReadData       <=  {(DataWidth){1'b0}}         ;
                rReadValid      <=  1'b0                        ;
                rReadLast       <=  1'b0                        ;
                rDstReadReady   <=  1'b0                        ;
            end
        endcase
    
	CRC_Generator
	#
	(
		.DATA_WIDTH			(32),
	    .HASH_LENGTH		(64),
	    .INPUT_COUNT_BITS	(13),
	    .INPUT_COUNT		(4158),
	    .OUTPUT_COUNT		(2)
	)
	CRCGenerator
	(
		.i_clk					(iClock),
		.i_nRESET				(!iReset),
		.i_execute_crc_gen		(wCRCEncEnable),
		.i_message_valid		(wCRCDataValid),
		.i_message				(wCRCData),
		.i_out_pause			(!rDstReadReady),
		.o_crc_gen_start		(),
		.o_last_message			(),
		.o_crc_gen_complete		(),
		.o_crc_spare_switch     (wCRCSpareSwitch),
		.o_parity_out_strobe	(wCRCParityValid),
		.o_parity_out_start		(),
		.o_parity_out_complete	(wCRCParityLast),
		.o_parity_out			(wCRCParityOut),
        .o_crc_available        (wCRCAvailable)
	);
    EncWidthConverter32to16
	#(
		.InputDataWidth(32),
		.OutputDataWidth(16)
	)
	Inst_WidthDownConverter
	(
		.iClock					(iClock),
		.iReset					(wReset),
		.iSrcDataValid          (rDstPageDataValid),
        .iSrcDataLast           (rDstPageDataLast),
		.iSrcData               (rDstPageData),
		.oConverterReady        (wDownConverterReady),
		.oConvertedDataValid    (wDownConvertedDataValid),
        .oConvertedDataLast     (wDownConvertedDataLast),
		.oConvertedData         (wDownConvertedData),
		.iDstReady              (wEncodeDataInReady)
	);
	    
    BCHEncoderX
    #
    (
        .Multi(2)
    )
    BCHPageEncoder
    (
        .iClock         (iClock),
        .iReset         (iReset),
        .iEnable        (wPageEncEnable),
        .iData          (wEncodeData),
        .iDataValid     (wEncodeDataValid),
        .oDataReady     (wEncoderReady),
        .oDataLast      (wPageDataLast),
        .oParityData    (wPageParityData),
        .oParityValid   (wPageParityValid),
        .oParityLast    (wPageParityLast),
        .iParityReady   (wUpConverterReady)
    );
    
    EncWidthConverter16to32
	#(
		.InputDataWidth(16),
		.OutputDataWidth(32)
	)
	Inst_WidthUpConverter
	(
		.iClock					(iClock),
		.iReset					(iReset),
        .iCurLoopCount          (rCurLoopCount[0]),
        .iCmdType               (rCmdType),
		.iSrcDataValid          (wUpConvertDataValid),
        .iSrcDataLast           (wDownConvertedDataLast),
        .iSrcParityLast         (wPageParityLast),
		.iSrcData               (wEncodeData),
		.oConverterReady        (wUpConverterReady),
		.oConvertedDataValid    (wUpConvertedDataValid),
        .oConvertedDataLast     (wUpConvertedDataLast),
        .oConvertedParityLast   (wUpConvertedParityLast),
		.oConvertedData         (wUpConvertedData),
		.iDstReady              (wReadReady)
	);
    
    SCFIFO_64x64_withCount
    DataBuffer
    (
        .iClock         (iClock                         ),
        .iReset         (iReset                         ),
        .iPushData      ({rReadData, rReadLast}         ),
        .iPushEnable    (rReadValid && wReadReady       ),
        .oIsFull        (wReadFull                      ),
        .oPopData       ({oSrcReadData, oSrcReadLast}   ),
        .iPopEnable     (wDataBufferPopSignal           ),
        .oIsEmpty       (wReadEmpty                     ),
        .oDataCount     (                               )
    );
    AutoFIFOPopControl
    DataBufferControl
    (
        .iClock         (iClock                         ),
        .iReset         (iReset                         ),
        .oPopSignal     (wDataBufferPopSignal           ),
        .iEmpty         (wReadEmpty                     ),
        .oValid         (oSrcReadValid                  ),
        .iReady         (iSrcReadReady                  )
    );
    
endmodule

`timescale 1ns / 1ps

module BCHEncoderDataChannel
#
(
    parameter   DataWidth           = 32    ,
    parameter   InnerIFLengthWidth  = 16
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

    input                               iClock                  ;
    input                               iReset                  ;
    
    input   [InnerIFLengthWidth - 1:0]  iLength                 ;
    input   [1:0]                       iCmdType                ;
    input                               iCmdValid               ;
    output                              oCmdReady               ;
    
    output  [DataWidth - 1:0]           oSrcReadData            ;
    output                              oSrcReadValid           ;
    output                              oSrcReadLast            ;
    input                               iSrcReadReady           ;
    
    input   [DataWidth - 1:0]           iDstReadData            ;
    input                               iDstReadValid           ;
    input                               iDstReadLast            ;
    output                              oDstReadReady           ;
    
    parameter   ECCCtrlCmdType_Bypass       = 2'b00             ;
    parameter   ECCCtrlCmdType_PageEncode   = 2'b01             ;
    parameter   ECCCtrlCmdType_SpareEncode  = 2'b10             ;
    
    localparam  State_Idle                  = 3'b000            ;
    localparam  State_CmdSelect             = 3'b001            ;
    localparam  State_Bypass                = 3'b011            ;
    localparam  State_PageEncode            = 3'b101            ;
    localparam  State_SpareEncode           = 3'b111            ;
    localparam  State_CRCParityOut          = 3'b110            ;
    localparam  State_ZeroPadding           = 3'b100            ;
    
    reg     [2:0]                       rCurState               ;
    reg     [2:0]                       rNextState              ;
    
    reg     [InnerIFLengthWidth - 1:0]  rLength                 ;
    reg     [1:0]                       rCmdType                ;
    
    reg     [DataWidth - 1:0]           rDstReadData            ;
    reg                                 rDstReadValid           ;
    reg                                 rDstReadLast            ;
    reg                                 rDstReadReady           ;
    
    reg     [1:0]                       rInDataSelect           ;
    
    wire                                wCRCEncoderEnable       ;
    wire                                wCRCReadValid           ;
    wire    [DataWidth - 1:0]           wCRCReadData            ;
    wire                                wCRCReadLast            ;
    wire    [DataWidth - 1:0]           wCRCParityOut           ;
    wire                                wCRCParityOutValid      ;
    wire                                wCRCParityOutLast       ;
    
    wire    [DataWidth/2 - 1:0]         wDownConvertedData      ;
    wire                                wDownConvertedValid     ;
    wire                                wDownConvertedLast      ;
    wire    [1:0]                       wECCCtrlCmdType         ;
    wire                                wECCCtrlCmdValid        ;
    wire                                wDstReadReady           ;
                
    wire                                wEncoderDataInReady     ;
    wire    [DataWidth/2 - 1:0]         wEncodedData            ;
    wire                                wEncodedDataValid       ;
    wire                                wEncodedDataLast        ;
                
    wire                                wUpConverterReady       ;
    wire    [DataWidth - 1:0]           wSrcReadData            ;
    wire                                wSrcReadValid           ;
    wire                                wSrcReadLast            ;
                
    wire                                wReadFull               ;
    wire                                wDataBufferPopSignal    ;
    wire                                wReadEmpty              ;
    
    reg     [5:0]                       rZeroPaddingCount       ;
    wire                                wZeroPaddingLast        ;
    
    assign oCmdReady = (rCurState == State_Idle);
    assign oDstReadReady = rDstReadReady;
    
    assign wCRCEncoderEnable    = (rCmdType == ECCCtrlCmdType_PageEncode);
    assign wCRCReadValid        = rDstReadValid && wDstReadReady;
    assign wCRCReadData         = rDstReadData;
    assign wZeroPaddingLast     = &rZeroPaddingCount;
        
    always @ (posedge iClock)
        if (iReset)
            rCurState <= State_Idle;
        else
            rCurState <= rNextState;
    
    always @ (*)
        case (rCurState)
        State_Idle:
            rNextState <= (iCmdValid) ? State_CmdSelect : State_Idle;
        State_CmdSelect:
            case (rCmdType)
            ECCCtrlCmdType_Bypass:
                rNextState <= State_Bypass;
            ECCCtrlCmdType_PageEncode:
                rNextState <= State_PageEncode;
            ECCCtrlCmdType_SpareEncode:
                rNextState <= State_SpareEncode;
            default:
                rNextState <= State_Idle;
            endcase
        State_Bypass:
            rNextState <= (rDstReadValid && rDstReadLast && wDstReadReady) ? State_Idle : State_Bypass;
        State_PageEncode:
            rNextState <= (rDstReadValid && rDstReadLast && wDstReadReady) ? State_Idle : State_PageEncode;
        State_SpareEncode:
            rNextState <= (rDstReadValid && wCRCReadLast && wDstReadReady) ? State_CRCParityOut : State_SpareEncode;
        State_CRCParityOut:
            rNextState <= (rDstReadValid && rDstReadLast && wDstReadReady) ? State_ZeroPadding : State_CRCParityOut;
        State_ZeroPadding:
            rNextState <= (rDstReadValid && wZeroPaddingLast && wDstReadReady) ? State_Idle : State_ZeroPadding;
        default:
            rNextState <= State_Idle;
        endcase
    
    always @ (posedge iClock)
        if (iReset)
            begin         
                rCmdType <= 2'b0;
                rLength <= {(InnerIFLengthWidth){1'b0}};
            end
        else
            if (iCmdValid && oCmdReady)
                begin
                    rCmdType <= iCmdType;
                    rLength <= iLength;
                end
        
    always @ (*)
        case (rCurState)
        State_Bypass:
            rInDataSelect <= 2'b01;
        State_PageEncode:
            rInDataSelect <= 2'b01;
        State_SpareEncode:
            rInDataSelect <= 2'b01;
        State_CRCParityOut:
            rInDataSelect <= 2'b10;
        State_ZeroPadding:
            rInDataSelect <= 2'b11;
        default:
            rInDataSelect <= 2'b00;
        endcase
    
    always @ (*)
        case (rInDataSelect)
        2'b00:
            begin
                rDstReadData <= {(DataWidth){1'b0}};
                rDstReadValid <= 1'b0;
                rDstReadLast <= 1'b0;
                rDstReadReady <= 1'b0;
            end
        2'b01:
            begin
                rDstReadData <= iDstReadData;
                rDstReadValid <= iDstReadValid;
                rDstReadLast <= iDstReadLast;
                rDstReadReady <= wDstReadReady;
            end
        2'b10:
            begin
                rDstReadData <= wCRCParityOut;
                rDstReadValid <= wCRCParityOutValid;
                rDstReadLast <= wCRCParityOutLast;
                rDstReadReady <= wDstReadReady & wCRCParityOutValid;
            end
        2'b11:
            begin
                rDstReadData <= {(DataWidth){1'b0}};
                rDstReadValid <= 1'b1;
                rDstReadLast <= wZeroPaddingLast;
                rDstReadReady <= 1'b0;
            end
        default:
            begin
                rDstReadData <= {(DataWidth){1'b0}};
                rDstReadValid <= 1'b0;
                rDstReadLast <= 1'b0;
                rDstReadReady <= 1'b0;
            end
        endcase
    
    always @ (posedge iClock)
        if (iReset)
            rZeroPaddingCount <= 6'b0;
        else
            case (rInDataSelect)
            2'b11:
                if (rDstReadValid && wDstReadReady)
                    rZeroPaddingCount <= rZeroPaddingCount + 1'b1;
                else
                    rZeroPaddingCount <= rZeroPaddingCount;
            default:
                rZeroPaddingCount <= 6'b0;
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
		.i_clk					(iClock                 ),
		.i_RESET				(iReset                 ),
		.i_execute_crc_gen		(wCRCEncoderEnable      ),
		.i_message_valid		(wCRCReadValid          ),
		.i_message				(wCRCReadData           ),
		.o_crc_gen_start		(                       ),
		.o_last_message			(wCRCReadLast           ),
		.o_crc_gen_complete		(                       ),
		.o_parity_out_strobe	(wCRCParityOutValid     ),
		.o_parity_out_start		(                       ),
		.o_parity_out_complete	(wCRCParityOutLast      ),
		.o_parity_out			(wCRCParityOut          ),
		.i_out_pause			(!wDstReadReady         ),
        .o_crc_available        (                       )
	);
    
    BCHEncoderInputBuffer
    #
    (
        .InputDataWidth     (32                     ),
        .OutputDataWidth    (16                     )
    )
    DownConverter_32to16
    (
        .iClock             (iClock                 ),
        .iReset             (iReset                 ),
        .iSrcCmdType        (rCmdType               ),
        .iSrcCmdValid       (rDstReadValid          ),
        .oSrcReadData       (wDownConvertedData     ),
        .oSrcReadValid      (wDownConvertedValid    ),
        .oSrcReadLast       (wDownConvertedLast     ),
        .iSrcReadReady      (wEncoderDataInReady    ),
        .oECCCtrlCmdType    (wECCCtrlCmdType        ),
        .oECCCtrlCmdValid   (wECCCtrlCmdValid       ),
        .iDstReadData       (rDstReadData           ),
        .iDstReadValid      (rDstReadValid          ),
        .iDstReadLast       (rDstReadLast           ),
        .oDstReadReady      (wDstReadReady          )
    );
    
    
    ClusteredEncoder
    #
    (
        .Multi              (2                      ), 
        .BitParallelLevel   (8                      )
    )
    BCHEncoderX
    (
        .iClock             (iClock                 ),
        .iReset             (iReset                 ),
        .iCmdType           (wECCCtrlCmdType        ),
        .iCmdValid          (wECCCtrlCmdValid       ),
        .iData              (wDownConvertedData     ),
        .iDataValid         (wDownConvertedValid    ),
        .iDataLast          (wDownConvertedLast     ),
        .oDataReady         (wEncoderDataInReady    ),
        .oEncodedData       (wEncodedData           ),
        .oEncodedDataValid  (wEncodedDataValid      ),
        .oEncodedDataLast   (wEncodedDataLast       ),
        .iReceiverReady     (wUpConverterReady      )
    );
    
    
    BCHEncoderOutputBuffer
    #
    (
        .InputDataWidth     (16                     ),
        .OutputDataWidth    (32                     )
    )
    UpConverter_16to32
    (
        .iClock             (iClock                 ),
        .iReset             (iReset                 ),
        .oSrcReadData       (wSrcReadData           ),
        .oSrcReadValid      (wSrcReadValid          ),
        .oSrcReadLast       (wSrcReadLast           ),
        .iSrcReadReady      (!wReadFull             ),
        .iDstReadData       (wEncodedData           ),
        .iDstReadValid      (wEncodedDataValid      ),
        .iDstReadLast       (wEncodedDataLast       ),
        .oDstReadReady      (wUpConverterReady      )
    );
    
    
    SCFIFO_64x64_withCount
    DataBuffer
    (
        .iClock             (iClock                         ),
        .iReset             (iReset                         ),
        .iPushData          ({wSrcReadData, wSrcReadLast}   ),
        .iPushEnable        (wSrcReadValid && !wReadFull    ),
        .oIsFull            (wReadFull                      ),
        .oPopData           ({oSrcReadData, oSrcReadLast}   ),
        .iPopEnable         (wDataBufferPopSignal           ),
        .oIsEmpty           (wReadEmpty                     ),
        .oDataCount         (                               )
    );
    AutoFIFOPopControl
    DataBufferControl
    (
        .iClock             (iClock                         ),
        .iReset             (iReset                         ),
        .oPopSignal         (wDataBufferPopSignal           ),
        .iEmpty             (wReadEmpty                     ),
        .oValid             (oSrcReadValid                  ),
        .iReady             (iSrcReadReady                  )
    );
endmodule
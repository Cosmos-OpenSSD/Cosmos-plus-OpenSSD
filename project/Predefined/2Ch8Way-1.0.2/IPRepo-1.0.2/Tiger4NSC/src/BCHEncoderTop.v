`timescale 1ns / 1ps

module BCHEncoderTop
#
(
    parameter   BitParallelLevel    = 8      ,
    parameter   InputCount          = 256    ,
    parameter   InputCountBits      = 9      ,
    parameter   ParityLength        = 168    ,
    parameter   OutputCount         = 21     ,
    parameter   OutputCountBits     = 5      
)
(
    iClock              ,
    iReset              ,
    iEnable             ,
    oEncoderAvailable   ,
    iData               ,
    iDataValid          ,
    oDataReady          ,
    oEncodedData        ,
    oEncodedDataValid   ,
    oEncodedDataLast    ,
    iReceiverReady
);

    input                               iClock              ;
    input                               iReset              ;
    input                               iEnable             ;
    output                              oEncoderAvailable   ;
    input   [BitParallelLevel - 1:0]    iData               ;
    input                               iDataValid          ;
    output                              oDataReady          ;
    output  [BitParallelLevel - 1:0]    oEncodedData        ;
    output                              oEncodedDataValid   ;
    output                              oEncodedDataLast    ;
    input                               iReceiverReady      ;
    
    localparam  State_Idle              = 2'b00             ;
    localparam  State_EncDataIn         = 2'b01             ;
    localparam  State_MessagePassingEnd = 2'b11             ;
    localparam  State_ParityOut         = 2'b10             ;
    
    reg     [1:0]                       rCurState           ;
    reg     [1:0]                       rNextState          ;
    
    reg     [BitParallelLevel - 1:0]    rMessage            ;
    reg     [ParityLength - 1:0]        rParityCode         ;
    wire    [ParityLength - 1:0]        wNextParityCode     ;
    reg                                 rDataValid          ;
    
    reg     [InputCountBits - 1:0]      rDataCount          ;
    reg     [InputCountBits - 1:0]      rDataOutCount       ;
    reg     [OutputCountBits - 1:0]     rParityCount        ;
    wire                                wInputDataLast      ;
    wire                                wOutputDataLast     ;
    wire                                wOutputParityLast   ;
    
    assign wInputDataLast = (rDataCount == InputCount)      ;
    assign wOutputDataLast = (rDataOutCount == InputCount-1);
    assign wOutputParityLast = (rParityCount == OutputCount);
    assign oEncoderAvailable = (rCurState == State_Idle)    ;
    assign oDataReady = (rCurState[1] == 0) ? !oEncoderAvailable & iReceiverReady : 1'b0;
    assign oEncodedData = (rParityCount == 0) ? rMessage : rParityCode[ParityLength - 1:ParityLength-BitParallelLevel];
    assign oEncodedDataValid = rDataValid;
    assign oEncodedDataLast = wOutputParityLast;
    
    
    always @ (posedge iClock)
        if (iReset)
            rCurState <= State_Idle;
        else
            rCurState <= rNextState;
    
    always @ (*)
        case (rCurState)
        State_Idle:
            rNextState <= (iEnable) ? State_EncDataIn : State_Idle;
        State_EncDataIn:
            rNextState <= (wInputDataLast && iDataValid && oDataReady) ? State_MessagePassingEnd : State_EncDataIn;
        State_MessagePassingEnd:
            rNextState <= (wOutputDataLast && oEncodedDataValid && iReceiverReady) ? State_ParityOut : State_MessagePassingEnd;
        State_ParityOut:
            rNextState <= (wOutputParityLast && oEncodedDataValid && iReceiverReady) ? State_Idle : State_ParityOut;
        default:
            rNextState <= State_Idle;
        endcase
        
    always @ (posedge iClock)
        if (iReset)
            rMessage <= {(BitParallelLevel){1'b0}};
        else
            case (rCurState)
            State_EncDataIn:
                if (iDataValid && oDataReady)
                    rMessage <= iData;
                else
                    rMessage <= rMessage;
            default:
                rMessage <= {(BitParallelLevel){1'b0}};
            endcase
    
    always @ (posedge iClock)
        if (iReset)
            rParityCode <= {(ParityLength){1'b0}};
        else
            case (rCurState)
            State_Idle:
                rParityCode <= {(ParityLength){1'b0}};
            State_EncDataIn:
                if (rDataCount == 1)
                    rParityCode <= {(ParityLength){1'b0}};
                else
                    if (iDataValid && oDataReady)
                        rParityCode <= wNextParityCode;
                    else
                        rParityCode <= rParityCode;
            State_MessagePassingEnd:
                rParityCode <= wNextParityCode;
            State_ParityOut:
                if (oEncodedDataValid && iReceiverReady)
                    rParityCode <= rParityCode << BitParallelLevel;
                else
                    rParityCode <= rParityCode;
            default:
                rParityCode <= {(ParityLength){1'b0}};
            endcase
    
    always @ (posedge iClock)
        if (iReset)
            rDataCount <= {(InputCountBits){1'b0}};
        else
            case (rCurState)
            State_Idle:
                if (iEnable)
                    rDataCount <= 1;
                else
                    rDataCount <= {(InputCountBits){1'b0}};
            State_EncDataIn:
                if (iDataValid && oDataReady)
                    rDataCount <= rDataCount + 1'b1;
                else
                    rDataCount <= rDataCount;
            default:
                rDataCount <= {(InputCountBits){1'b0}};
            endcase
    
    always @ (posedge iClock)
        if (iReset)
            rDataOutCount <= {(InputCountBits){1'b0}};
        else
            case (rCurState)
            State_EncDataIn:
                if (oEncodedDataValid && iReceiverReady)
                    rDataOutCount <= rDataOutCount + 1'b1;
                else
                    rDataOutCount <= rDataOutCount;
            State_MessagePassingEnd:
                if (oEncodedDataValid && iReceiverReady)
                    rDataOutCount <= rDataOutCount + 1'b1;
                else
                    rDataOutCount <= rDataOutCount;
            default:
                rDataOutCount <= {(InputCountBits){1'b0}};
            endcase
    
    always @ (posedge iClock)
        if (iReset)
            rParityCount <= {(OutputCountBits){1'b0}};
        else
            case (rCurState)
            State_MessagePassingEnd:
                if (wOutputDataLast && oEncodedDataValid && iReceiverReady)
                    rParityCount <= 1;
                else
                    rParityCount <= {(OutputCountBits){1'b0}};
            State_ParityOut:
                if (oEncodedDataValid && iReceiverReady)
                    rParityCount <= rParityCount + 1'b1;
                else
                    rParityCount <= rParityCount;
            default:
                rParityCount <= {(OutputCountBits){1'b0}};
            endcase
    
    always @ (posedge iClock)
        if (iReset)
            rDataValid <= 1'b0;
        else
            case (rCurState)
            State_Idle:
                rDataValid <= 1'b0;
            State_EncDataIn:
                rDataValid <= iDataValid;
            State_MessagePassingEnd:
                rDataValid <= iDataValid;
            State_ParityOut:
                rDataValid <= 1'b1;
            default:
                rDataValid <= 1'b0;
            endcase                
    
    ModifiedParallelLFSR
    #(
        .BitParallelLevel   (8  ),
        .ParityLength       (168)
    )
    m_p_lfsXOR
    (
        .iMessage   (rMessage       ),
        .iCurParity (rParityCode    ),
        .oNextParity(wNextParityCode)
    );
endmodule
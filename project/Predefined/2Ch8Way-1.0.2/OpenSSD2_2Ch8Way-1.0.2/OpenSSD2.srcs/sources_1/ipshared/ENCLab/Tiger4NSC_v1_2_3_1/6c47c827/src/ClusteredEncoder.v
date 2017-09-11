`timescale 1ns / 1ps

module ClusteredEncoder
#
(
    parameter   Multi               = 2 ,
    parameter   BitParallelLevel    = 8
)
(
    iClock              ,
    iReset              ,
    iCmdType            ,
    iCmdValid           ,
    iData               ,
    iDataValid          ,
    iDataLast           ,
    oDataReady          ,
    oEncodedData        ,
    oEncodedDataValid   ,
    oEncodedDataLast    ,
    iReceiverReady
);
    
    input                                   iClock              ;
    input                                   iReset              ;
    input   [1:0]                           iCmdType            ;
    input                                   iCmdValid           ;
    input   [Multi*BitParallelLevel - 1:0]  iData               ;
    input                                   iDataValid          ;
    input                                   iDataLast           ;
    output                                  oDataReady          ;
    output  [Multi*BitParallelLevel - 1:0]  oEncodedData        ;
    output                                  oEncodedDataValid   ;
    output                                  oEncodedDataLast    ;
    input                                   iReceiverReady      ;
    
    parameter   ECCCtrlCmdType_Bypass       = 2'b00             ;
    parameter   ECCCtrlCmdType_PageEncode   = 2'b01             ;
    parameter   ECCCtrlCmdType_SpareEncode  = 2'b10             ;
    
    localparam  State_Idle                  = 3'b000            ;
    localparam  State_CmdSelect             = 3'b011            ;
    localparam  State_Bypass                = 3'b001            ;
    localparam  State_PageEncode            = 3'b010            ;
    localparam  State_SpareEncode           = 3'b100            ;
    localparam  State_ZeroPadding           = 3'b101            ;
    localparam  State_SpareParityOut        = 3'b111            ;
    
    reg     [2:0]   rCurState   ;
    reg     [2:0]   rNextState  ;
    
    reg     [1:0]   rCmdType    ;
    reg             rCmdValid   ;
    
    reg     [Multi*BitParallelLevel - 1:0]  rOutputData         ;
    reg                                     rOutputValid        ;
    reg                                     rOutputLast         ;
    
    wire                                    wEncEnable          ;
    wire    [Multi - 1:0]                   wEncoderAvailable   ;
    wire    [Multi - 1:0]                   wDataReady          ;
    wire    [Multi*BitParallelLevel - 1:0]  wEncodedData        ;
    wire    [Multi - 1:0]                   wEncodedDataValid   ;
    wire    [Multi - 1:0]                   wEncodedDataLast    ;
    
    reg                                     rSpareDataLast      ;
    reg                                     rSpareParityLast    ;
    reg                                     rZeroPaddingLast    ;
    reg     [4:0]                           rPageLastCount      ;
    
    assign wEncEnable = (rCurState == State_PageEncode) || (rCurState == State_SpareEncode);
       
    always @ (posedge iClock)
        if (iReset)
            rCurState <= State_Idle;
        else
            rCurState <= rNextState;
    
    always @ (*)
        case (rCurState)
        State_Idle:
            rNextState <= (iCmdValid && iDataValid) ? State_CmdSelect : State_Idle;
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
            rNextState <= (rOutputValid && rOutputLast && iReceiverReady) ? State_Idle : State_Bypass;
        State_PageEncode:
            rNextState <= (rOutputValid && rOutputLast && iReceiverReady) ? State_Idle : State_PageEncode;
        State_SpareEncode:
            rNextState <= (rSpareDataLast && rOutputValid && iReceiverReady) ? State_ZeroPadding : State_SpareEncode;
        State_ZeroPadding:
            rNextState <= (rZeroPaddingLast && iReceiverReady) ? State_SpareParityOut : State_ZeroPadding;
        State_SpareParityOut:
            rNextState <= (rOutputValid && rOutputLast && iReceiverReady) ? State_Idle : State_SpareParityOut;
        default:
            rNextState <= State_Idle;
        endcase
    
    always @ (*)
        case (rCurState)
        State_Idle:
            begin
                rOutputData <= {(Multi*BitParallelLevel){1'b0}};
                rOutputValid <= 1'b0;
                rOutputLast <= 1'b0;
            end
        State_Bypass:
            begin
                rOutputData <= iData;
                rOutputValid <= iDataValid;
                rOutputLast <= iDataLast;
            end
        State_PageEncode:
            begin
                rOutputData <= wEncodedData;
                rOutputValid <= &wEncodedDataValid;
                rOutputLast <= &wEncodedDataLast;
            end
        State_SpareEncode:
            begin
                rOutputData <= wEncodedData;
                rOutputValid <= &wEncodedDataValid;
                rOutputLast <= &wEncodedDataLast;
            end
        State_ZeroPadding:
            begin
                rOutputData <= {(Multi*BitParallelLevel){1'b0}};
                rOutputValid <= 1'b0;
                rOutputLast <= 1'b0;
            end
        State_SpareParityOut:
            if (rSpareParityLast)
                begin
                    rOutputData <= {(Multi*BitParallelLevel){1'b0}};
                    rOutputValid <= 1'b1;
                    rOutputLast <= 1'b1;
                end
            else
                begin
                    rOutputData <= wEncodedData;
                    rOutputValid <= &wEncodedDataValid;
                    rOutputLast <= 1'b0;
                end
        default:
            begin
                rOutputData <= {(Multi*BitParallelLevel){1'b0}};
                rOutputValid <= 1'b0;
                rOutputLast <= 1'b0;
            end
        endcase
    
    always @ (posedge iClock)
        if (iReset)
            rCmdType <= 2'b0;
        else
            if (iCmdValid && iDataValid && (rCurState == State_Idle))
                rCmdType <= iCmdType;                    
        
    always @ (posedge iClock)
        if (iReset)
            rSpareParityLast <= 1'b0;
        else
            case (rCurState)
            State_SpareParityOut:
                if (&wEncodedDataLast)
                    rSpareParityLast <= 1'b1;
            State_Idle:
                rSpareParityLast <= 1'b0;
            default:
                rSpareParityLast <= rSpareParityLast;
            endcase
    
    always @ (posedge iClock)
        if (iReset)
            rSpareDataLast <= 1'b0;
        else
            case (rCurState)
            State_SpareEncode:
                if (iDataLast && iDataValid && oDataReady)
                    rSpareDataLast <= 1'b1;
            default:
                rSpareDataLast <= 1'b0;
            endcase
    
    always @ (posedge iClock)
        if (iReset)
            rZeroPaddingLast <= 1'b0;
        else
            case (rCurState)
            State_ZeroPadding:
                if (iDataLast && iDataValid && oDataReady)
                    rZeroPaddingLast <= 1'b1;
            default:
                rZeroPaddingLast <= 1'b0;
            endcase
    
    always @ (posedge iClock)
        if (iReset)
            rPageLastCount <= 5'b0;
        else
            case (rCurState)
            State_PageEncode:
                if ((rPageLastCount == 31) && rOutputLast && rOutputValid && iReceiverReady)
                    rPageLastCount <= 5'b0;
                else if (rOutputLast && rOutputValid && iReceiverReady)
                    rPageLastCount <= rPageLastCount + 1'b1;
            default:
                rPageLastCount <= rPageLastCount;
            endcase
    
    genvar c;
    generate
        for (c = 0; c < Multi; c = c + 1)
        begin
            BCHEncoderTop
            BCHEncoder
            (
                .iClock             (iClock                                                         ),
                .iReset             (iReset                                                         ),
                .iEnable            (wEncEnable                                                     ),
                .oEncoderAvailable  (wEncoderAvailable[c]                                           ),
                .iData              (iData[(c + 1)*BitParallelLevel - 1:c*BitParallelLevel]         ),
                .iDataValid         (iDataValid                                                     ),
                .oDataReady         (wDataReady[c]                                                  ),
                .oEncodedData       (wEncodedData[(c + 1)*BitParallelLevel - 1:c*BitParallelLevel]  ),
                .oEncodedDataValid  (wEncodedDataValid[c]                                           ),
                .oEncodedDataLast   (wEncodedDataLast[c]                                            ),
                .iReceiverReady     (iReceiverReady                                                 )
            );
        end
    endgenerate
    
    assign oEncodedData = rOutputData;
    assign oEncodedDataValid = rOutputValid;
    assign oEncodedDataLast = (rCurState == State_PageEncode) ? ((rOutputLast) && (rPageLastCount == 31)) : rOutputLast;
    assign oDataReady = (rCurState == State_Bypass) ? iReceiverReady : &wDataReady;

endmodule
        
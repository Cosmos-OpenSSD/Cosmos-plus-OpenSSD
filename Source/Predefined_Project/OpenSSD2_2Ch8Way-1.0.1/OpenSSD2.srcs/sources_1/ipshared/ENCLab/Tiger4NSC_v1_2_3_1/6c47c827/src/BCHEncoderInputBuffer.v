`timescale 1ns / 1ps

module BCHEncoderInputBuffer
#
(
    parameter   InputDataWidth  = 32    , 
    parameter   OutputDataWidth = 16
)
(
    iClock          ,
    iReset          ,
    iSrcCmdType     ,
    iSrcCmdValid    ,
    oSrcReadData    ,
    oSrcReadValid   ,
    oSrcReadLast    ,
    iSrcReadReady   ,
    oECCCtrlCmdType ,
    oECCCtrlCmdValid,
    iDstReadData    ,
    iDstReadValid   ,
    iDstReadLast    ,
    oDstReadReady
);

    input                       iClock          ;
    input                       iReset          ;
    
    input   [1:0]               iSrcCmdType     ;
    input                       iSrcCmdValid    ;
    output  [OutputDataWidth - 1:0] oSrcReadData    ;
    output                      oSrcReadValid   ;
    output                      oSrcReadLast    ;
    input                       iSrcReadReady   ;
    
    output  [1:0]               oECCCtrlCmdType ;
    output                      oECCCtrlCmdValid;
    input   [InputDataWidth - 1:0]   iDstReadData    ;
    input                       iDstReadValid   ;
    input                       iDstReadLast    ;
    output                      oDstReadReady   ;
    
    wire    [17:0]              wECCCtrlCmdType ;
    wire                        wDstReadReady   ;
    
    assign wECCCtrlCmdType = {iSrcCmdValid, iSrcCmdType, {6'b0}, iSrcCmdValid, iSrcCmdType, iDstReadLast};
    assign oDstReadReady = !wDstReadReady;
    
    DCFIFO32x64W_16x128R
    InputDataBuffer
    (
        .iClock         (iClock                             ),
        .iReset         (iReset                             ),
        .iPushData      (iDstReadData                       ),
        .iPushEnable    (iDstReadValid && !wDstReadReady    ),
        .oIsFull        (wDstReadReady                      ),
        .oPopData       (oSrcReadData                       ),
        .iPopEnable     (wFIFOPopSignal                     ),
        .oIsEmpty       (wFIFOEmpty                         ),
        .oDataCount     (                                   )
    );
    AutoFIFOPopControl
    InputDataBufferControl
    (
        .iClock         (iClock                             ),
        .iReset         (iReset                             ),
        .oPopSignal     (wFIFOPopSignal                     ),
        .iEmpty         (wFIFOEmpty                         ),
        .oValid         (oSrcReadValid                      ),
        .iReady         (iSrcReadReady                      )
    );
    DCFIFO18x64W_9x128R
    InputDataLastBuffer
    (
        .iClock         (iClock                                             ),
        .iReset         (iReset                                             ),
        .iPushData      (wECCCtrlCmdType                                    ),
        .iPushEnable    (iDstReadValid && !wDstReadReady                    ),
        .oIsFull        (                                                   ),
        .oPopData       ({oECCCtrlCmdValid, oECCCtrlCmdType, oSrcReadLast}  ),
        .iPopEnable     (wFIFOPopSignal                                     ),
        .oIsEmpty       (                                                   ),
        .oDataCount     (                                                   )
    );
endmodule
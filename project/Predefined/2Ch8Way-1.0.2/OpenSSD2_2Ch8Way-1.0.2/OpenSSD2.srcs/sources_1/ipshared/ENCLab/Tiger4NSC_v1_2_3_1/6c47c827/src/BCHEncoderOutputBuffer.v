`timescale 1ns / 1ps

module BCHEncoderOutputBuffer
#(
    parameter   InputDataWidth  = 16,
    parameter   OutputDataWidth = 32
)
(
    iClock          ,
    iReset          ,
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
    output  [OutputDataWidth - 1:0]     oSrcReadData    ;
    output                              oSrcReadValid   ;
    output                              oSrcReadLast    ;
    input                               iSrcReadReady   ;
    input   [InputDataWidth - 1:0]      iDstReadData    ;
    input                               iDstReadValid   ;
    input                               iDstReadLast    ;
    output                              oDstReadReady   ;
    
    wire                                wFIFOPopSignal  ;
    wire                                wFIFOEmpty      ;
    wire                                wIsFull         ;
    
    assign oDstReadReady = !wIsFull;
    
    DCFIFO16x128W_32x64R
    InputDataBuffer
    (
        .iClock         (iClock                             ), 
        .iReset         (iReset                             ),
        .iPushData      (iDstReadData                       ),
        .iPushEnable    (iDstReadValid && oDstReadReady     ),
        .oIsFull        (wIsFull                            ),
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
    DCFIFO9x128W_18x64R
    InputDataLastBuffer
    (
        .iClock         (iClock                             ),
        .iReset         (iReset                             ),
        .iPushData      ({iDstReadLast}                     ),
        .iPushEnable    (iDstReadValid && oDstReadReady     ),
        .oIsFull        (                                   ),
        .oPopData       ({oSrcReadLast}                     ),
        .iPopEnable     (wFIFOPopSignal                     ),
        .oIsEmpty       (                                   ),
        .oDataCount     (                                   )
    );
    
endmodule
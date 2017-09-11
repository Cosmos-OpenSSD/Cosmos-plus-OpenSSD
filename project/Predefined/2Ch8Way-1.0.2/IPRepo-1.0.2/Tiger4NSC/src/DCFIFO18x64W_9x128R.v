`timescale 1ns / 1ps
module DCFIFO18x64W_9x128R
(
    input           iClock      ,
    input           iReset      ,
    
    input   [17:0]  iPushData   ,
    input           iPushEnable ,
    output          oIsFull     ,
    
    output  [8:0]  oPopData    ,
    input           iPopEnable  ,
    output          oIsEmpty    ,
    
    output  [5:0]   oDataCount
);

    DPBDCFIFO18x64W_9x128R
    Inst_DPBDCFIFO18x64W_9x128R
    (
        .wr_clk         (iClock         ),
        .rd_clk         (iClock         ),
        .rst            (iReset         ),
        .full           (oIsFull        ),
        .din            (iPushData      ),
        .wr_en          (iPushEnable    ),
        .empty          (oIsEmpty       ),
        .dout           (oPopData       ),
        .rd_en          (iPopEnable     ),
        .wr_data_count  (oDataCount     )
    );
    
endmodule
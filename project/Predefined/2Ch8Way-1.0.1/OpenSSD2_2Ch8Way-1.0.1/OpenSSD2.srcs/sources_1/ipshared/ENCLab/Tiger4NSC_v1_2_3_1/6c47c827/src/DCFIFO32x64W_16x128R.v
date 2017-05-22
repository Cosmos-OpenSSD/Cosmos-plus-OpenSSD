`timescale 1ns / 1ps
module DCFIFO32x64W_16x128R
(
    input           iClock      ,
    input           iReset      ,
    
    input   [31:0]  iPushData   ,
    input           iPushEnable ,
    output          oIsFull     ,
    
    output  [15:0]  oPopData    ,
    input           iPopEnable  ,
    output          oIsEmpty    ,
    
    output  [5:0]   oDataCount
);

    DPBDCFIFO32x64W_16x128R
    Inst_DPBDCFIFO32x64W_16x128R
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
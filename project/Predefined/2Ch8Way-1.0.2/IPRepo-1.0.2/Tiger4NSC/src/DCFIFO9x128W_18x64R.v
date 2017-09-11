`timescale 1ns / 1ps
module DCFIFO9x128W_18x64R
(
    input           iClock      ,
    input           iReset      ,
    
    input   [8:0]  iPushData   ,
    input           iPushEnable ,
    output          oIsFull     ,
    
    output  [17:0]  oPopData    ,
    input           iPopEnable  ,
    output          oIsEmpty    ,
    
    output  [6:0]   oDataCount
);

    DPBDCFIFO9x128W_18x64R
    Inst_DPBDCFIFO9x128W_18x64R
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
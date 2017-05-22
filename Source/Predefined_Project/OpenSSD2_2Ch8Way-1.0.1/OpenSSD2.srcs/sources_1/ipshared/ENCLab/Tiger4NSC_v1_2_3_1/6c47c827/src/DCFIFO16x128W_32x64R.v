`timescale 1ns / 1ps
module DCFIFO16x128W_32x64R
(
    input           iClock      ,
    input           iReset      ,
    
    input   [15:0]  iPushData   ,
    input           iPushEnable ,
    output          oIsFull     ,
    
    output  [31:0]  oPopData    ,
    input           iPopEnable  ,
    output          oIsEmpty    ,
    
    output  [6:0]   oDataCount
);

    DPBDCFIFO16x128W_32x64R
    Inst_DPBDCFIFO16x128W_32x64R
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
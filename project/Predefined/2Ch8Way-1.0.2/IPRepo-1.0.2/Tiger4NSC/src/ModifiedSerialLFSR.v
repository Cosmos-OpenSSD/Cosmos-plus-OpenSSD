`timescale 1ns / 1ps
module ModifiedSerialLFSR
#(
    parameter   ParityLength    = 168
)
(
    iMessage    ,
    iCurParity  ,
    oNextParity
);

    input                           iMessage    ;
    input   [ParityLength - 1:0]    iCurParity  ;
    output  [ParityLength - 1:0]    oNextParity ;
    
    parameter   [0:168] BCHEncGenPoly = 169'b1100011001001101001001011010010000001010100100010101010000111100111110110010110000100000001101100011000011111011010100011001110110100011110100100001001101010100010111001;
    // LSB is MAXIMUM order term, so parameter has switched order
    
    wire    wFeedBack   ;
    
    assign  wFeedBack   = iMessage ^ iCurParity[ParityLength - 1];
    assign  oNextParity[0] = wFeedBack;
    
    genvar c;
    generate
        for (c = 1; c < ParityLength; c = c + 1)
        begin
            if (BCHEncGenPoly[c] == 1)
                assign oNextParity[c] = iCurParity[c - 1] ^ wFeedBack;
            else
                assign oNextParity[c] = iCurParity[c - 1];
        end
    endgenerate
endmodule

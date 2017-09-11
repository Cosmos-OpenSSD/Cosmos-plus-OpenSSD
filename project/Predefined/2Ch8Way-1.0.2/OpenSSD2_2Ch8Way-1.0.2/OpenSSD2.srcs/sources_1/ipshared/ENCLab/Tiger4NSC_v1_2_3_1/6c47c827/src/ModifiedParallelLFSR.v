`timescale 1ns / 1ps

module ModifiedParallelLFSR
#(
    parameter   BitParallelLevel    = 8,
    parameter   ParityLength        = 168
)
(
    iMessage    ,
    iCurParity  ,
    oNextParity
);
    input   [BitParallelLevel - 1:0]    iMessage    ;
    input   [ParityLength - 1:0]        iCurParity  ;
    output  [ParityLength - 1:0]        oNextParity ;
    
    wire    [ParityLength * (BitParallelLevel + 1) - 1:0]   wParallelWire   ;
    
    genvar c;
    generate
        for (c = 0; c < BitParallelLevel; c = c + 1)
        begin
            ModifiedSerialLFSR
            #
            (
                .ParityLength(168)
            )
            m_s_lfsXOR
            (
                .iMessage   (iMessage[c]                                                        ),
                .iCurParity (wParallelWire[ParityLength * (c + 2) - 1:ParityLength * (c + 1)]   ),
                .oNextParity(wParallelWire[ParityLength * (c + 1) - 1:ParityLength * (c)    ]   )
            );
        end
	endgenerate
    
    assign  wParallelWire[ParityLength * (BitParallelLevel + 1) - 1:ParityLength * (BitParallelLevel)] = iCurParity;
    assign  oNextParity[ParityLength - 1:0] = wParallelWire[ParityLength - 1:0];
        
endmodule

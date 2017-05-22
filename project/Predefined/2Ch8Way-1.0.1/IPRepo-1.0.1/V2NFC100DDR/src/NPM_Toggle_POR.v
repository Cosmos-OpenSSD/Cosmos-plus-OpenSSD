//////////////////////////////////////////////////////////////////////////////////
// NPM_Toggle_POR for Cosmos OpenSSD
// Copyright (c) 2015 Hanyang University ENC Lab.
// Contributed by Ilyong Jung <iyjung@enc.hanyang.ac.kr>
//                Yong Ho Song <yhsong@enc.hanyang.ac.kr>
//
// This file is part of Cosmos OpenSSD.
//
// Cosmos OpenSSD is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3, or (at your option)
// any later version.
//
// Cosmos OpenSSD is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
// See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Cosmos OpenSSD; see the file COPYING.
// If not, see <http://www.gnu.org/licenses/>. 
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Company: ENC Lab. <http://enc.hanyang.ac.kr>
// Engineer: Ilyong Jung <iyjung@enc.hanyang.ac.kr>
// 
// Project Name: Cosmos OpenSSD
// Design Name: NPM_Toggle_POR
// Module Name: NPM_Toggle_POR
// File Name: NPM_Toggle_POR.v
//
// Version: v1.0.0
//
// Description: NFC PM output module reset
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module NPM_Toggle_POR
(
    iSystemClock            ,
    iReset                  ,
    oReady                  ,
    oLastStep               ,
    iStart                  ,
    oPO_Reset                       
);
    input                           iSystemClock            ;
    input                           iReset                  ;
    output                          oReady                  ;
    output                          oLastStep               ;
    input                           iStart                  ;
    output                          oPO_Reset               ;
    
    // FSM Parameters/Wires/Regs
    parameter POR_FSM_BIT = 4;
    parameter POR_RESET = 4'b0001;
    parameter POR_READY = 4'b0010;
    parameter POR_RFRST = 4'b0100; // reset first
    parameter POR_RLOOP = 4'b1000; // reset loop
    
    reg     [POR_FSM_BIT-1:0]       rPOR_cur_state          ;
    reg     [POR_FSM_BIT-1:0]       rPOR_nxt_state          ;
    
    
    
    // Internal Wires/Regs
    reg                             rReady                  ;
    
    reg     [3:0]                   rTimer                  ;
    
    wire                            wJOBDone                ;
    
    reg                             rPO_Reset               ;
    
    
    
    // Control Signals
    
    // Flow Control
    
    assign wJOBDone = (4'b1001 == rTimer[3:0]); // 1 + '9' = 10 cycles
    
    
    
    // FSM
    
    // update current state to next state
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rPOR_cur_state <= POR_RESET;
        end else begin
            rPOR_cur_state <= rPOR_nxt_state;
        end
    end
    
    // deside next state
    always @ ( * ) begin
        case (rPOR_cur_state)
            POR_RESET: begin
                rPOR_nxt_state <= POR_READY;
            end
            POR_READY: begin
                rPOR_nxt_state <= (iStart)? POR_RFRST:POR_READY;
            end
            POR_RFRST: begin
                rPOR_nxt_state <= POR_RLOOP;
            end
            POR_RLOOP: begin
                rPOR_nxt_state <= (wJOBDone)? ((iStart)? POR_RFRST:POR_READY):POR_RLOOP;
            end
            default:
                rPOR_nxt_state <= POR_READY;
        endcase
    end
    
    // state behaviour
    always @ (posedge iSystemClock, posedge iReset) begin
        if (iReset) begin
            rReady          <= 0;
            rTimer[3:0]     <= 0;
            rPO_Reset       <= 0;
        end else begin
            case (rPOR_nxt_state)
                POR_RESET: begin
                    rReady          <= 0;
                    rTimer[3:0]     <= 0;
                    rPO_Reset       <= 0;
                end
                POR_READY: begin
                    rReady          <= 1;
                    rTimer[3:0]     <= 0;
                    rPO_Reset       <= 0;
                end
                POR_RFRST: begin
                    rReady          <= 0;
                    rTimer[3:0]     <= 4'b0000;
                    rPO_Reset       <= 1;
                end
                POR_RLOOP: begin
                    rReady          <= 0;
                    rTimer[3:0]     <= rTimer[3:0] + 1'b1;
                    rPO_Reset       <= 1;
                end
            endcase
        end
    end
    
    
    
    // Output
    
    assign oReady               = rReady | wJOBDone     ;
    assign oLastStep            = wJOBDone              ;
    
    assign oPO_Reset            = rPO_Reset              ;
    
endmodule

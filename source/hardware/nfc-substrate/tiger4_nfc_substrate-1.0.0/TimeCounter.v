//////////////////////////////////////////////////////////////////////////////////
// TimeCounter for Cosmos OpenSSD
// Copyright (c) 2015 Hanyang University ENC Lab.
// Contributed by Kibin Park <kbpark@enc.hanyang.ac.kr>
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
// Engineer: Kibin Park <kbpark@enc.hanyang.ac.kr>
// 
// Project Name: Cosmos OpenSSD
// Design Name: TimeCounter
// Module Name: TimeCounter
// File Name: TimeCounter.v
//
// Version: v1.0.0
//
// Description: Time counter
//
//////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////////
// Revision History:
//
// * v1.0.0
//   - first draft
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module TimeCounter
#
(
    parameter TimerWidth            = 32        ,
    parameter DefaultPeriod         = 100000000
)
(
    iClock          ,
    iReset          ,
    iEnabled        ,
    iPeriodSetting  ,
    iSettingValid   ,
    iProbe          ,
    oCountValue
);
    input                       iClock          ;                                                                              
    input                       iReset          ;                                                                              
    input                       iEnabled        ;                                                                              
    input   [TimerWidth - 1:0]  iPeriodSetting  ;                                                      
    input                       iSettingValid   ;                          
    input                       iProbe          ;        
    output  [TimerWidth - 1:0]  oCountValue     ;

    reg     [TimerWidth - 1:0]  rPeriod         ;
    reg     [TimerWidth - 1:0]  rSampledCount   ;
    reg     [TimerWidth - 1:0]  rCounter        ;
    reg     [TimerWidth - 1:0]  rTimeCount      ;
    
    always @ (posedge iClock)
        if (iReset | !iEnabled | rTimeCount == rPeriod)
            rCounter <= {(TimerWidth){1'b0}};
        else
            if (iEnabled & iProbe)
                rCounter <= rCounter + 1'b1;

    always @ (posedge iClock)
        if (iReset | !iEnabled | rTimeCount == rPeriod)
            rTimeCount <= {(TimerWidth){1'b0}};
        else
            if (iEnabled)
                rTimeCount <= rTimeCount + 1'b1;

    always @ (posedge iClock)
        if (iReset)
            rSampledCount <= {(TimerWidth){1'b0}};
        else
            if (rTimeCount == rPeriod)
                rSampledCount <= rCounter;

    always @ (posedge iClock)
        if (iReset)
            rPeriod <= DefaultPeriod;
        else
            if (iSettingValid)
                rPeriod <= iPeriodSetting;
    
    assign oCountValue = rSampledCount;
    
endmodule

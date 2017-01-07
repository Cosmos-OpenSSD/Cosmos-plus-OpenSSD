
/*
----------------------------------------------------------------------------------
Copyright (c) 2013-2014

  Embedded and Network Computing Lab.
  Open SSD Project
  Hanyang University

All rights reserved.

----------------------------------------------------------------------------------

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

  1. Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in the
     documentation and/or other materials provided with the distribution.

  3. All advertising materials mentioning features or use of this source code
     must display the following acknowledgement:
     This product includes source code developed 
     by the Embedded and Network Computing Lab. and the Open SSD Project.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

----------------------------------------------------------------------------------

http://enclab.hanyang.ac.kr/
http://www.openssd-project.org/
http://www.hanyang.ac.kr/

----------------------------------------------------------------------------------
*/

`define		D_CPLD_FMT					3'b010
`define		D_CPLD_TYPE					5'b01010
`define		D_CPLD_TC					3'b000
`define		D_CPLD_ATTR1				1'b0
`define		D_CPLD_TH					1'b0
`define		D_CPLD_TD					1'b0
`define		D_CPLD_EP					1'b0
`define		D_CPLD_ATTR2				2'b00
`define		D_CPLD_AT					2'b00
`define		D_CPLD_CS					3'b000
`define		D_CPLD_BCM					1'b0

`define		D_MRD_FMT					3'b001
`define		D_MRD_TYPE					5'b00000
`define		D_MRD_TC					3'b000
`define		D_MRD_ATTR1					1'b0
`define		D_MRD_TH					1'b0
`define		D_MRD_TD					1'b0
`define		D_MRD_EP					1'b0
`define		D_MRD_ATTR2					2'b00
`define		D_MRD_AT					2'b00
`define		D_MRD_LAST_BE				4'b1111
`define		D_MRD_1ST_BE				4'b1111

`define		D_MWR_FMT					3'b011
`define		D_MWR_TYPE					5'b00000
`define		D_MWR_TC					3'b000
`define		D_MWR_ATTR1					1'b0
`define		D_MWR_TH					1'b0
`define		D_MWR_TD					1'b0
`define		D_MWR_EP					1'b0
`define		D_MWR_ATTR2					2'b00
`define		D_MWR_AT					2'b00
`define		D_MWR_LAST_BE				4'b1111
`define		D_MWR_1ST_BE				4'b1111
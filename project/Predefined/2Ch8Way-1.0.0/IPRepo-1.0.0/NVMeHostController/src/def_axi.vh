
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


`define		D_AXI_RESP_OKAY					2'b00
`define		D_AXI_RESP_EXOKAY				2'b01
`define		D_AXI_RESP_SLVERR				2'b10
`define		D_AXI_RESP_DECERR				2'b11

`define		D_AXBURST_FIXED					2'b00
`define		D_AXBURST_INCR					2'b01
`define		D_AXBURST_WRAP					2'b10

`define		D_AXLOCK_NORMAL					2'b00
`define		D_AXLOCK_EXCLUSIVE				2'b01
`define		D_AXLOCK_LOCKED					2'b10

`define		D_AXCACHE_NON_CACHE				4'b0000
`define		D_AXCACHE_WA					4'b1000
`define		D_AXCACHE_RA					4'b0100
`define		D_AXCACHE_CACHEABLE				4'b0010
`define		D_AXCACHE_BUFFERABLE			4'b0001

`define		D_AXPROT_SECURE					3'b000
`define		D_AXPROT_PRIVILEGED				3'b001
`define		D_AXPROT_NON_SECURE				3'b010
`define		D_AXPROT_INSTRUCTION			3'b100

`define		D_AXSIZE_001_BYTES				3'b000
`define		D_AXSIZE_002_BYTES				3'b001
`define		D_AXSIZE_004_BYTES				3'b010
`define		D_AXSIZE_008_BYTES				3'b011
`define		D_AXSIZE_016_BYTES				3'b100
`define		D_AXSIZE_032_BYTES				3'b101
`define		D_AXSIZE_064_BYTES				3'b110
`define		D_AXSIZE_128_BYTES				3'b111


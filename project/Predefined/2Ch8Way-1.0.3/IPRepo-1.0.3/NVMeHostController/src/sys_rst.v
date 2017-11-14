
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


`timescale 1ns / 1ps

module sys_rst
(
	input									cpu_bus_clk,
	input									cpu_bus_rst_n,

	input									pcie_perst_n,
	input									user_reset_out,
	input									pcie_pl_hot_rst,
	input									pcie_user_logic_rst,

	output									pcie_sys_rst_n,
	output									pcie_user_rst_n
);


localparam	LP_PCIE_RST_CNT_WIDTH			= 9;
localparam	LP_PCIE_RST_CNT					= 380;
localparam	LP_PCIE_HOT_RST_CNT				= 50;

localparam	S_RESET							= 6'b000001;
localparam	S_RESET_CNT						= 6'b000010;
localparam	S_HOT_RESET						= 6'b000100;
localparam	S_HOT_RESET_CNT					= 6'b001000;
localparam	S_HOT_RESET_WAIT				= 6'b010000;
localparam	S_IDLE							= 6'b100000;


reg		[5:0]								cur_state;
reg		[5:0]								next_state;

(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_pcie_perst_n;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_pcie_perst_n_sync;

(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_pcie_pl_hot_rst;
(* KEEP = "TRUE", SHIFT_EXTRACT = "NO" *)	reg											r_pcie_pl_hot_rst_sync;

reg		[LP_PCIE_RST_CNT_WIDTH-1:0]			r_rst_cnt;
reg											r_pcie_sys_rst_n;
reg											r_pcie_hot_rst;

assign pcie_user_rst_n = ~(user_reset_out | r_pcie_hot_rst);
//assign pcie_user_rst_n = ~(user_reset_out);
assign pcie_sys_rst_n = r_pcie_sys_rst_n;

always @ (posedge cpu_bus_clk)
begin
	r_pcie_perst_n_sync <= pcie_perst_n;
	r_pcie_perst_n <= r_pcie_perst_n_sync;
	r_pcie_pl_hot_rst_sync <= pcie_pl_hot_rst;
	r_pcie_pl_hot_rst <= r_pcie_pl_hot_rst_sync;
end


always @ (posedge cpu_bus_clk or negedge cpu_bus_rst_n)
begin
	if(cpu_bus_rst_n == 0)
		cur_state <= S_RESET;
	else
		cur_state <= next_state;
end

always @ (*)
begin
	case(cur_state)
		S_RESET: begin
			next_state <= S_RESET_CNT;
		end
		S_RESET_CNT: begin
			if(r_pcie_perst_n == 0)
				next_state <= S_RESET;
			else if(r_rst_cnt == 0)
				next_state <= S_IDLE;
			else
				next_state <= S_RESET_CNT;
		end
		S_HOT_RESET: begin
			next_state <= S_HOT_RESET_CNT;
		end
		S_HOT_RESET_CNT: begin
			if(r_pcie_perst_n == 0)
				next_state <= S_RESET;
			else if(r_rst_cnt == 0)
				next_state <= S_HOT_RESET_WAIT;
			else
				next_state <= S_HOT_RESET_CNT;
		end
		S_HOT_RESET_WAIT: begin
			if(r_pcie_perst_n == 0)
				next_state <= S_RESET;
			else if(r_pcie_pl_hot_rst == 1)
				next_state <= S_HOT_RESET_WAIT;
			else
				next_state <= S_IDLE;
		end
		S_IDLE: begin
			if(r_pcie_perst_n == 0)
				next_state <= S_RESET;
			else if(r_pcie_pl_hot_rst == 1 || pcie_user_logic_rst == 1)
				next_state <= S_HOT_RESET;
			else
				next_state <= S_IDLE;
		end
		default: begin
			next_state <= S_RESET;
		end
	endcase
end



always @ (posedge cpu_bus_clk)
begin
	case(cur_state)
		S_RESET: begin
			r_rst_cnt <= LP_PCIE_RST_CNT;
		end
		S_RESET_CNT: begin
			r_rst_cnt <= r_rst_cnt - 1'b1;
		end
		S_HOT_RESET: begin
			r_rst_cnt <= LP_PCIE_HOT_RST_CNT;
		end
		S_HOT_RESET_CNT: begin
			r_rst_cnt <= r_rst_cnt - 1'b1;
		end
		S_HOT_RESET_WAIT: begin

		end
		S_IDLE: begin

		end
		default: begin

		end
	endcase
end


always @ (*)
begin
	case(cur_state)
		S_RESET: begin
			r_pcie_sys_rst_n <= 0;
			r_pcie_hot_rst <= 0;
		end
		S_RESET_CNT: begin
			r_pcie_sys_rst_n <= 0;
			r_pcie_hot_rst <= 0;
		end
		S_HOT_RESET: begin
			r_pcie_sys_rst_n <= 1;
			r_pcie_hot_rst <= 1;
		end
		S_HOT_RESET_CNT: begin
			r_pcie_sys_rst_n <= 1;
			r_pcie_hot_rst <= 1;
		end
		S_HOT_RESET_WAIT: begin
			r_pcie_sys_rst_n <= 1;
			r_pcie_hot_rst <= 1;
		end
		S_IDLE: begin
			r_pcie_sys_rst_n <= 1;
			r_pcie_hot_rst <= 0;
		end
		default: begin
			r_pcie_sys_rst_n <= 0;
			r_pcie_hot_rst <= 0;
		end
	endcase
end

endmodule
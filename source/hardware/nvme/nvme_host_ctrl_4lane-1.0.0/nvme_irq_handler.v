
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

module nvme_irq_handler # (
	parameter	C_PCIE_DATA_WIDTH			= 128,
	parameter	C_PCIE_ADDR_WIDTH			= 36
)
(
	input									pcie_user_clk,
	input									pcie_user_rst_n,

	input	[15:0]							cfg_command,
	input									cfg_interrupt_msienable,

	input									nvme_intms_ivms,
	input									nvme_intmc_ivmc,
	output									cq_irq_status,

	input	[8:0]							cq_rst_n,
	input	[8:0]							cq_valid,
	input	[8:0]							io_cq_irq_en,
	input	[2:0]							io_cq1_iv,
	input	[2:0]							io_cq2_iv,
	input	[2:0]							io_cq3_iv,
	input	[2:0]							io_cq4_iv,
	input	[2:0]							io_cq5_iv,
	input	[2:0]							io_cq6_iv,
	input	[2:0]							io_cq7_iv,
	input	[2:0]							io_cq8_iv,

	input	[7:0]							admin_cq_tail_ptr,
	input	[7:0]							io_cq1_tail_ptr,
	input	[7:0]							io_cq2_tail_ptr,
	input	[7:0]							io_cq3_tail_ptr,
	input	[7:0]							io_cq4_tail_ptr,
	input	[7:0]							io_cq5_tail_ptr,
	input	[7:0]							io_cq6_tail_ptr,
	input	[7:0]							io_cq7_tail_ptr,
	input	[7:0]							io_cq8_tail_ptr,

	input	[7:0]							admin_cq_head_ptr,
	input	[7:0]							io_cq1_head_ptr,
	input	[7:0]							io_cq2_head_ptr,
	input	[7:0]							io_cq3_head_ptr,
	input	[7:0]							io_cq4_head_ptr,
	input	[7:0]							io_cq5_head_ptr,
	input	[7:0]							io_cq6_head_ptr,
	input	[7:0]							io_cq7_head_ptr,
	input	[7:0]							io_cq8_head_ptr,
	input	[8:0]							cq_head_update,

	output									pcie_legacy_irq_set,
	output									pcie_msi_irq_set,
	output	[2:0]							pcie_irq_vector,
	output									pcie_legacy_irq_clear,
	input									pcie_irq_done
);

localparam	LP_LEGACY_IRQ_DELAY_TIME		= 8'h10;

localparam	S_IDLE							= 6'b000001;
localparam	S_PCIE_MSI_IRQ_SET				= 6'b000010;
localparam	S_LEGACY_IRQ_SET				= 6'b000100;
localparam	S_LEGACY_IRQ_TIMER				= 6'b001000;
localparam	S_CQ_MSI_IRQ_MASK				= 6'b010000;
localparam	S_CQ_IRQ_DONE					= 6'b100000;


reg		[5:0]								cur_state;
reg		[5:0]								next_state;

reg											r_pcie_irq_en;
reg											r_pcie_msi_en;

wire	[8:0]								w_cq_legacy_irq_status;
reg											r_cq_legacy_irq_req;
wire	[8:0]								w_cq_msi_irq_status;
wire	[8:0]								w_cq_msi_irq_mask;
reg		[8:0]								r_cq_msi_irq_sel;
wire										w_cq_msi_irq_req;
reg		[8:0]								r_cq_msi_irq_ack;
reg											r_pcie_msi_irq_set;
reg		[2:0]								r_pcie_irq_vector;
reg											r_pcie_legacy_irq_set;
reg		[7:0]								r_legacy_irq_timer;

assign w_cq_msi_irq_mask = {r_cq_msi_irq_sel[7:0], r_cq_msi_irq_sel[8]};
assign w_cq_msi_irq_req = ((w_cq_msi_irq_status & w_cq_msi_irq_mask) != 0);

assign pcie_legacy_irq_set = r_pcie_legacy_irq_set;
assign pcie_msi_irq_set = r_pcie_msi_irq_set;
assign pcie_irq_vector = r_pcie_irq_vector;
assign pcie_legacy_irq_clear = ((nvme_intms_ivms | nvme_intmc_ivmc) | (~r_cq_legacy_irq_req | ~r_pcie_irq_en) | r_pcie_msi_en);
assign cq_irq_status = r_pcie_legacy_irq_set;

always @ (posedge pcie_user_clk)
begin
	r_pcie_irq_en <= ~cfg_command[10];
	r_pcie_msi_en <= cfg_interrupt_msienable;
	r_cq_legacy_irq_req <= (w_cq_legacy_irq_status != 0);
end

always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0)
		cur_state <= S_IDLE;
	else
		cur_state <= next_state;
end

always @ (*)
begin
	case(cur_state)
		S_IDLE: begin
			if(r_pcie_msi_en == 1) begin
				if((w_cq_msi_irq_req | w_cq_msi_irq_status[0]) == 1)
					next_state <= S_PCIE_MSI_IRQ_SET;
				else
					next_state <= S_IDLE;
			end
			else if(r_pcie_irq_en == 1)begin
				if(r_cq_legacy_irq_req == 1)
					next_state <= S_LEGACY_IRQ_SET;
				else
					next_state <= S_IDLE;
			end
			else
				next_state <= S_IDLE;
		end
		S_PCIE_MSI_IRQ_SET: begin
			if(pcie_irq_done == 1)
				next_state <= S_CQ_MSI_IRQ_MASK;
			else
				next_state <= S_PCIE_MSI_IRQ_SET;
		end
		S_LEGACY_IRQ_SET: begin
			if(pcie_irq_done == 1)
				next_state <= S_LEGACY_IRQ_TIMER;
			else
				next_state <= S_LEGACY_IRQ_SET;
		end
		S_LEGACY_IRQ_TIMER: begin
			if(r_legacy_irq_timer == 0)
				next_state <= S_CQ_IRQ_DONE;
			else
				next_state <= S_LEGACY_IRQ_TIMER;
		end
		S_CQ_MSI_IRQ_MASK: begin
			next_state <= S_CQ_IRQ_DONE;
		end
		S_CQ_IRQ_DONE: begin
			next_state <= S_IDLE;
		end
		default: begin
			next_state <= S_IDLE;
		end
	endcase
end

always @ (posedge pcie_user_clk)
begin
	case(cur_state)
		S_IDLE: begin

		end
		S_PCIE_MSI_IRQ_SET: begin

		end
		S_LEGACY_IRQ_SET: begin
			r_legacy_irq_timer <= LP_LEGACY_IRQ_DELAY_TIME;
		end
		S_LEGACY_IRQ_TIMER: begin
			r_legacy_irq_timer <= r_legacy_irq_timer - 1;
		end
		S_CQ_MSI_IRQ_MASK: begin

		end
		S_CQ_IRQ_DONE: begin

		end
		default: begin

		end
	endcase
end

always @ (posedge pcie_user_clk or negedge pcie_user_rst_n)
begin
	if(pcie_user_rst_n == 0) begin
		r_cq_msi_irq_sel <= 1;
	end
	else begin
		case(cur_state)
			S_IDLE: begin
				if(w_cq_msi_irq_status[0] == 1)
					r_cq_msi_irq_sel <= 1;
				else
					r_cq_msi_irq_sel <= w_cq_msi_irq_mask;
			end
			S_PCIE_MSI_IRQ_SET: begin

			end
			S_LEGACY_IRQ_SET: begin

			end
			S_LEGACY_IRQ_TIMER: begin

			end
			S_CQ_MSI_IRQ_MASK: begin

			end
			S_CQ_IRQ_DONE: begin

			end
			default: begin

			end
		endcase
	end
end

always @ (*)
begin
	case(r_cq_msi_irq_sel)  // synthesis parallel_case full_case
		9'b000000001: r_pcie_irq_vector <= 0;
		9'b000000010: r_pcie_irq_vector <= io_cq1_iv;
		9'b000000100: r_pcie_irq_vector <= io_cq2_iv;
		9'b000001000: r_pcie_irq_vector <= io_cq3_iv;
		9'b000010000: r_pcie_irq_vector <= io_cq4_iv;
		9'b000100000: r_pcie_irq_vector <= io_cq5_iv;
		9'b001000000: r_pcie_irq_vector <= io_cq6_iv;
		9'b010000000: r_pcie_irq_vector <= io_cq7_iv;
		9'b100000000: r_pcie_irq_vector <= io_cq8_iv;
	endcase
end

always @ (*)
begin
	case(cur_state)
		S_IDLE: begin
			r_pcie_legacy_irq_set <= 0;
			r_pcie_msi_irq_set <= 0;
			r_cq_msi_irq_ack <= 0;
		end
		S_PCIE_MSI_IRQ_SET: begin
			r_pcie_legacy_irq_set <= 0;
			r_pcie_msi_irq_set <= 1;
			r_cq_msi_irq_ack <= 0;
		end
		S_LEGACY_IRQ_SET: begin
			r_pcie_legacy_irq_set <= 1;
			r_pcie_msi_irq_set <= 0;
			r_cq_msi_irq_ack <= 0;
		end
		S_LEGACY_IRQ_TIMER: begin
			r_pcie_legacy_irq_set <= 0;
			r_pcie_msi_irq_set <= 0;
			r_cq_msi_irq_ack <= 0;
		end
		S_CQ_MSI_IRQ_MASK: begin
			r_pcie_legacy_irq_set <= 0;
			r_pcie_msi_irq_set <= 0;
			r_cq_msi_irq_ack <= r_cq_msi_irq_sel;
		end
		S_CQ_IRQ_DONE: begin
			r_pcie_legacy_irq_set <= 0;
			r_pcie_msi_irq_set <= 0;
			r_cq_msi_irq_ack <= 0;
		end
		default: begin
			r_pcie_legacy_irq_set <= 0;
			r_pcie_msi_irq_set <= 0;
			r_cq_msi_irq_ack <= 0;
		end
	endcase
	
end

nvme_cq_check
nvme_cq_check_inst0
(
	.pcie_user_clk									(pcie_user_clk),
	.pcie_user_rst_n								(pcie_user_rst_n),

	.pcie_msi_en									(r_pcie_msi_en),

	.cq_rst_n										(cq_rst_n[0]),
	.cq_valid										(cq_valid[0]),
	.io_cq_irq_en									(io_cq_irq_en[0]),
	
	.cq_tail_ptr									(admin_cq_tail_ptr),
	.cq_head_ptr									(admin_cq_head_ptr),
	.cq_head_update									(cq_head_update[0]),

	.cq_legacy_irq_req								(w_cq_legacy_irq_status[0]),
	.cq_msi_irq_req									(w_cq_msi_irq_status[0]),
	.cq_msi_irq_ack									(r_cq_msi_irq_ack[0])
);

nvme_cq_check
nvme_cq_check_inst1
(
	.pcie_user_clk									(pcie_user_clk),
	.pcie_user_rst_n								(pcie_user_rst_n),

	.pcie_msi_en									(r_pcie_msi_en),

	.cq_rst_n										(cq_rst_n[1]),
	.cq_valid										(cq_valid[1]),
	.io_cq_irq_en									(io_cq_irq_en[1]),
	
	.cq_tail_ptr									(io_cq1_tail_ptr),
	.cq_head_ptr									(io_cq1_head_ptr),
	.cq_head_update									(cq_head_update[1]),

	.cq_legacy_irq_req								(w_cq_legacy_irq_status[1]),
	.cq_msi_irq_req									(w_cq_msi_irq_status[1]),
	.cq_msi_irq_ack									(r_cq_msi_irq_ack[1])
);

nvme_cq_check
nvme_cq_check_inst2
(
	.pcie_user_clk									(pcie_user_clk),
	.pcie_user_rst_n								(pcie_user_rst_n),

	.pcie_msi_en									(r_pcie_msi_en),

	.cq_rst_n										(cq_rst_n[2]),
	.cq_valid										(cq_valid[2]),
	.io_cq_irq_en									(io_cq_irq_en[2]),
	
	.cq_tail_ptr									(io_cq2_tail_ptr),
	.cq_head_ptr									(io_cq2_head_ptr),
	.cq_head_update									(cq_head_update[2]),

	.cq_legacy_irq_req								(w_cq_legacy_irq_status[2]),
	.cq_msi_irq_req									(w_cq_msi_irq_status[2]),
	.cq_msi_irq_ack									(r_cq_msi_irq_ack[2])
);


nvme_cq_check
nvme_cq_check_inst3
(
	.pcie_user_clk									(pcie_user_clk),
	.pcie_user_rst_n								(pcie_user_rst_n),

	.pcie_msi_en									(r_pcie_msi_en),

	.cq_rst_n										(cq_rst_n[3]),
	.cq_valid										(cq_valid[3]),
	.io_cq_irq_en									(io_cq_irq_en[3]),
	
	.cq_tail_ptr									(io_cq3_tail_ptr),
	.cq_head_ptr									(io_cq3_head_ptr),
	.cq_head_update									(cq_head_update[3]),

	.cq_legacy_irq_req								(w_cq_legacy_irq_status[3]),
	.cq_msi_irq_req									(w_cq_msi_irq_status[3]),
	.cq_msi_irq_ack									(r_cq_msi_irq_ack[3])
);


nvme_cq_check
nvme_cq_check_inst4
(
	.pcie_user_clk									(pcie_user_clk),
	.pcie_user_rst_n								(pcie_user_rst_n),

	.pcie_msi_en									(r_pcie_msi_en),

	.cq_rst_n										(cq_rst_n[4]),
	.cq_valid										(cq_valid[4]),
	.io_cq_irq_en									(io_cq_irq_en[4]),
	
	.cq_tail_ptr									(io_cq4_tail_ptr),
	.cq_head_ptr									(io_cq4_head_ptr),
	.cq_head_update									(cq_head_update[4]),

	.cq_legacy_irq_req								(w_cq_legacy_irq_status[4]),
	.cq_msi_irq_req									(w_cq_msi_irq_status[4]),
	.cq_msi_irq_ack									(r_cq_msi_irq_ack[4])
);


nvme_cq_check
nvme_cq_check_inst5
(
	.pcie_user_clk									(pcie_user_clk),
	.pcie_user_rst_n								(pcie_user_rst_n),

	.pcie_msi_en									(r_pcie_msi_en),

	.cq_rst_n										(cq_rst_n[5]),
	.cq_valid										(cq_valid[5]),
	.io_cq_irq_en									(io_cq_irq_en[5]),
	
	.cq_tail_ptr									(io_cq5_tail_ptr),
	.cq_head_ptr									(io_cq5_head_ptr),
	.cq_head_update									(cq_head_update[5]),

	.cq_legacy_irq_req								(w_cq_legacy_irq_status[5]),
	.cq_msi_irq_req									(w_cq_msi_irq_status[5]),
	.cq_msi_irq_ack									(r_cq_msi_irq_ack[5])
);


nvme_cq_check
nvme_cq_check_inst6
(
	.pcie_user_clk									(pcie_user_clk),
	.pcie_user_rst_n								(pcie_user_rst_n),

	.pcie_msi_en									(r_pcie_msi_en),

	.cq_rst_n										(cq_rst_n[6]),
	.cq_valid										(cq_valid[6]),
	.io_cq_irq_en									(io_cq_irq_en[6]),
	
	.cq_tail_ptr									(io_cq6_tail_ptr),
	.cq_head_ptr									(io_cq6_head_ptr),
	.cq_head_update									(cq_head_update[6]),

	.cq_legacy_irq_req								(w_cq_legacy_irq_status[6]),
	.cq_msi_irq_req									(w_cq_msi_irq_status[6]),
	.cq_msi_irq_ack									(r_cq_msi_irq_ack[6])
);


nvme_cq_check
nvme_cq_check_inst7
(
	.pcie_user_clk									(pcie_user_clk),
	.pcie_user_rst_n								(pcie_user_rst_n),

	.pcie_msi_en									(r_pcie_msi_en),

	.cq_rst_n										(cq_rst_n[7]),
	.cq_valid										(cq_valid[7]),
	.io_cq_irq_en									(io_cq_irq_en[7]),
	
	.cq_tail_ptr									(io_cq7_tail_ptr),
	.cq_head_ptr									(io_cq7_head_ptr),
	.cq_head_update									(cq_head_update[7]),

	.cq_legacy_irq_req								(w_cq_legacy_irq_status[7]),
	.cq_msi_irq_req									(w_cq_msi_irq_status[7]),
	.cq_msi_irq_ack									(r_cq_msi_irq_ack[7])
);


nvme_cq_check
nvme_cq_check_inst8
(
	.pcie_user_clk									(pcie_user_clk),
	.pcie_user_rst_n								(pcie_user_rst_n),

	.pcie_msi_en									(r_pcie_msi_en),

	.cq_rst_n										(cq_rst_n[8]),
	.cq_valid										(cq_valid[8]),
	.io_cq_irq_en									(io_cq_irq_en[8]),
	
	.cq_tail_ptr									(io_cq8_tail_ptr),
	.cq_head_ptr									(io_cq8_head_ptr),
	.cq_head_update									(cq_head_update[8]),

	.cq_legacy_irq_req								(w_cq_legacy_irq_status[8]),
	.cq_msi_irq_req									(w_cq_msi_irq_status[8]),
	.cq_msi_irq_ack									(r_cq_msi_irq_ack[8])
);


endmodule
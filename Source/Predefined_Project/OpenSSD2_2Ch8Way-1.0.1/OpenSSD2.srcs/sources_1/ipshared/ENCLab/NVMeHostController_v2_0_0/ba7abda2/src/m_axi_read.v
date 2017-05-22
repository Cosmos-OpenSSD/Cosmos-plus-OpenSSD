
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

`include	"def_axi.vh"

module m_axi_read # (
	parameter	C_M_AXI_ADDR_WIDTH			= 32,
	parameter	C_M_AXI_DATA_WIDTH			= 64,
	parameter	C_M_AXI_ID_WIDTH			= 1,
	parameter	C_M_AXI_ARUSER_WIDTH		= 1,
	parameter	C_M_AXI_RUSER_WIDTH			= 1
)
(
////////////////////////////////////////////////////////////////
//AXI4 master read channel signals
	input									m_axi_aclk,
	input									m_axi_aresetn,

// Read address channel
	output	[C_M_AXI_ID_WIDTH-1:0]			m_axi_arid,
	output	[C_M_AXI_ADDR_WIDTH-1:0]		m_axi_araddr,
	output	[7:0]							m_axi_arlen,
	output	[2:0]							m_axi_arsize,
	output	[1:0]							m_axi_arburst,
	output	[1:0]							m_axi_arlock,
	output	[3:0]							m_axi_arcache,
	output	[2:0]							m_axi_arprot,
	output	[3:0]							m_axi_arregion,
	output	[3:0] 							m_axi_arqos,
	output	[C_M_AXI_ARUSER_WIDTH-1:0]		m_axi_aruser,
	output									m_axi_arvalid,
	input									m_axi_arready,

// Read data channel
	input	[C_M_AXI_ID_WIDTH-1:0]			m_axi_rid,
	input	[C_M_AXI_DATA_WIDTH-1:0]		m_axi_rdata,
	input	[1:0]							m_axi_rresp,
	input									m_axi_rlast,
	input	[C_M_AXI_RUSER_WIDTH-1:0]		m_axi_ruser,
	input									m_axi_rvalid,
	output 									m_axi_rready,

	output									m_axi_rresp_err,

	output									dev_tx_cmd_rd_en,
	input	[29:0]							dev_tx_cmd_rd_data,
	input									dev_tx_cmd_empty_n,

	output									pcie_tx_fifo_alloc_en,
	output	[9:4]							pcie_tx_fifo_alloc_len,
	output									pcie_tx_fifo_wr_en,
	output	[C_M_AXI_DATA_WIDTH-1:0]		pcie_tx_fifo_wr_data,
	input									pcie_tx_fifo_full_n
);

localparam	LP_AR_DELAY						= 7;

localparam	S_IDLE							= 8'b00000001;
localparam	S_CMD_0							= 8'b00000010;
localparam	S_CMD_1							= 8'b00000100;
localparam	S_WAIT_FULL_N					= 8'b00001000;
localparam	S_AR_REQ						= 8'b00010000;
localparam	S_AR_WAIT						= 8'b00100000;
localparam	S_AR_DONE						= 8'b01000000;
localparam	S_AR_DELAY						= 8'b10000000;

reg		[7:0]								cur_state;
reg		[7:0]								next_state;

reg		[31:2]								r_dev_addr;
reg		[12:2]								r_dev_dma_len;
reg		[9:2]								r_dev_cur_len;
reg		[9:2]								r_m_axi_arlen;
reg		[4:0]								r_ar_delay;

reg											r_dev_tx_cmd_rd_en;
reg											r_pcie_tx_fifo_alloc_en;

wire										w_axi_ar_req_gnt;
reg		[2:0]								r_axi_ar_req_gnt;
reg											r_axi_ar_req;

reg											r_m_axi_arvalid;
reg		[C_M_AXI_DATA_WIDTH-1 : 0]			r_m_axi_rdata;
reg											r_m_axi_rlast;
//reg											r_m_axi_rlast_d1;
//wire										w_m_axi_rlast;
reg											r_m_axi_rvalid;
reg		[C_M_AXI_ID_WIDTH-1:0]				r_m_axi_rid;
reg		[1:0]								r_m_axi_rresp;
reg											r_m_axi_rresp_err;
reg											r_m_axi_rresp_err_d1;
reg											r_m_axi_rresp_err_d2;

assign m_axi_arid = 0;
assign m_axi_araddr = {r_dev_addr, 2'b0};
assign m_axi_arlen = {1'b0, r_m_axi_arlen[9:3]};
assign m_axi_arsize = `D_AXSIZE_008_BYTES;
assign m_axi_arburst = `D_AXBURST_INCR;
assign m_axi_arlock = `D_AXLOCK_NORMAL;
assign m_axi_arcache = `D_AXCACHE_NON_CACHE;
assign m_axi_arprot = `D_AXPROT_SECURE;
assign m_axi_arregion = 0;
assign m_axi_arqos = 0;
assign m_axi_aruser = 0;
assign m_axi_arvalid = r_m_axi_arvalid;
assign m_axi_rready = 1;

assign m_axi_rresp_err = r_m_axi_rresp_err_d2;

assign dev_tx_cmd_rd_en = r_dev_tx_cmd_rd_en;
assign pcie_tx_fifo_alloc_en = r_pcie_tx_fifo_alloc_en;
assign pcie_tx_fifo_alloc_len = r_dev_cur_len[9:4];

assign pcie_tx_fifo_wr_en = r_m_axi_rvalid;
assign pcie_tx_fifo_wr_data = r_m_axi_rdata;


always @ (posedge m_axi_aclk or negedge m_axi_aresetn)
begin
	if(m_axi_aresetn == 0)
		cur_state <= S_IDLE;
	else
		cur_state <= next_state;
end

always @ (*)
begin
	case(cur_state)
		S_IDLE: begin
			if(dev_tx_cmd_empty_n == 1)
				next_state <= S_CMD_0;
			else
				next_state <= S_IDLE;
		end
		S_CMD_0: begin
			next_state <= S_CMD_1;
		end
		S_CMD_1: begin
			next_state <= S_WAIT_FULL_N;
		end
		S_WAIT_FULL_N: begin
			if(pcie_tx_fifo_full_n == 1 && w_axi_ar_req_gnt == 1)
					next_state <= S_AR_REQ;
				else
					next_state <= S_WAIT_FULL_N;
		end
		S_AR_REQ: begin
			if(m_axi_arready == 1)
				next_state <= S_AR_DONE;
			else
				next_state <= S_AR_WAIT;
		end
		S_AR_WAIT: begin
			if(m_axi_arready == 1)
				next_state <= S_AR_DONE;
			else
				next_state <= S_AR_WAIT;
		end
		S_AR_DONE: begin
			if(r_dev_dma_len == 0)
				next_state <= S_IDLE;
			else
				next_state <= S_AR_DELAY;
		end
		S_AR_DELAY: begin
			if(r_ar_delay == 0)
				next_state <= S_WAIT_FULL_N;
			else
				next_state <= S_AR_DELAY;
		end
		default: begin
			next_state <= S_IDLE;
		end
	endcase
end

always @ (posedge m_axi_aclk)
begin
	case(cur_state)
		S_IDLE: begin

		end
		S_CMD_0: begin
			r_dev_dma_len <= {dev_tx_cmd_rd_data[10:2], 2'b0};
		end
		S_CMD_1: begin
			if(r_dev_dma_len[8:2] == 0)
				r_dev_cur_len[9] <= 1;
			else
				r_dev_cur_len[9] <= 0;
			
			r_dev_cur_len[8:2] <= r_dev_dma_len[8:2];
			r_dev_addr <= {dev_tx_cmd_rd_data[29:2], 2'b0};
		end
		S_WAIT_FULL_N: begin
			r_m_axi_arlen <= r_dev_cur_len - 2;
		end
		S_AR_REQ: begin
			r_dev_dma_len <= r_dev_dma_len - r_dev_cur_len;
		end
		S_AR_WAIT: begin

		end
		S_AR_DONE: begin
			r_dev_cur_len <= 8'h80;
			r_dev_addr <= r_dev_addr + r_dev_cur_len;
			r_ar_delay <= LP_AR_DELAY;
		end
		S_AR_DELAY: begin
			r_ar_delay <= r_ar_delay - 1;
		end
		default: begin

		end
	endcase
end

always @ (*)
begin
	case(cur_state)
		S_IDLE: begin
			r_m_axi_arvalid <= 0;
			r_dev_tx_cmd_rd_en <= 0;
			r_pcie_tx_fifo_alloc_en <= 0;
			r_axi_ar_req <= 0;
		end
		S_CMD_0: begin
			r_m_axi_arvalid <= 0;
			r_dev_tx_cmd_rd_en <= 1;
			r_pcie_tx_fifo_alloc_en <= 0;
			r_axi_ar_req <= 0;
		end
		S_CMD_1: begin
			r_m_axi_arvalid <= 0;
			r_dev_tx_cmd_rd_en <= 1;
			r_pcie_tx_fifo_alloc_en <= 0;
			r_axi_ar_req <= 0;
		end
		S_WAIT_FULL_N: begin
			r_m_axi_arvalid <= 0;
			r_dev_tx_cmd_rd_en <= 0;
			r_pcie_tx_fifo_alloc_en <= 0;
			r_axi_ar_req <= 0;
		end
		S_AR_REQ: begin
			r_m_axi_arvalid <= 1;
			r_dev_tx_cmd_rd_en <= 0;
			r_pcie_tx_fifo_alloc_en <= 1;
			r_axi_ar_req <= 1;
		end
		S_AR_WAIT: begin
			r_m_axi_arvalid <= 1;
			r_dev_tx_cmd_rd_en <= 0;
			r_pcie_tx_fifo_alloc_en <= 0;
			r_axi_ar_req <= 0;
		end
		S_AR_DONE: begin
			r_m_axi_arvalid <= 0;
			r_dev_tx_cmd_rd_en <= 0;
			r_pcie_tx_fifo_alloc_en <= 0;
			r_axi_ar_req <= 0;
		end
		S_AR_DELAY: begin
			r_m_axi_arvalid <= 0;
			r_dev_tx_cmd_rd_en <= 0;
			r_pcie_tx_fifo_alloc_en <= 0;
			r_axi_ar_req <= 0;
		end
		default: begin
			r_m_axi_arvalid <= 0;
			r_dev_tx_cmd_rd_en <= 0;
			r_pcie_tx_fifo_alloc_en <= 0;
			r_axi_ar_req <= 0;
		end
	endcase
end

//assign w_m_axi_rlast = r_m_axi_rlast & ~r_m_axi_rlast_d1;

always @ (posedge m_axi_aclk)
begin
	r_m_axi_rid <= m_axi_rid;
	r_m_axi_rdata <= m_axi_rdata;
	r_m_axi_rlast <= m_axi_rlast & m_axi_rvalid;
	//r_m_axi_rlast_d1 <= r_m_axi_rlast;
	r_m_axi_rvalid <= m_axi_rvalid;
	r_m_axi_rresp <= m_axi_rresp;

	r_m_axi_rresp_err_d1 <= r_m_axi_rresp_err;
	r_m_axi_rresp_err_d2 <= r_m_axi_rresp_err | r_m_axi_rresp_err_d1;

end

always @ (*)
begin
	if(r_m_axi_rvalid == 1 && (r_m_axi_rresp != `D_AXI_RESP_OKAY || r_m_axi_rid != 0))
		r_m_axi_rresp_err <= 1;
	else
		r_m_axi_rresp_err <= 0;
end

assign w_axi_ar_req_gnt = r_axi_ar_req_gnt[2];

always @ (posedge m_axi_aclk or negedge m_axi_aresetn)
begin
	if(m_axi_aresetn == 0) begin
		r_axi_ar_req_gnt <= 3'b110;
	end
	else begin
		case({r_m_axi_rlast, r_axi_ar_req})
			2'b01: begin
				r_axi_ar_req_gnt <= {r_axi_ar_req_gnt[1:0], r_axi_ar_req_gnt[2]};
			end
			2'b10: begin
				r_axi_ar_req_gnt <= {r_axi_ar_req_gnt[0], r_axi_ar_req_gnt[2:1]};
			end
			default: begin

			end
		endcase
	end
end



endmodule
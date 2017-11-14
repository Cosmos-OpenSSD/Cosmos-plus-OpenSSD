
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

module m_axi_write # (
	parameter	C_M_AXI_ADDR_WIDTH			= 32,
	parameter	C_M_AXI_DATA_WIDTH			= 64,
	parameter	C_M_AXI_ID_WIDTH			= 1,
	parameter	C_M_AXI_AWUSER_WIDTH		= 1,
	parameter	C_M_AXI_WUSER_WIDTH			= 1,
	parameter	C_M_AXI_BUSER_WIDTH			= 1
)
(

////////////////////////////////////////////////////////////////
//AXI4 master write channel signal
	input									m_axi_aclk,
	input									m_axi_aresetn,

	// Write address channel
	output	[C_M_AXI_ID_WIDTH-1:0]			m_axi_awid,
	output	[C_M_AXI_ADDR_WIDTH-1:0]		m_axi_awaddr,
	output	[7:0]							m_axi_awlen,
	output	[2:0]							m_axi_awsize,
	output	[1:0]							m_axi_awburst,
	output	[1:0]							m_axi_awlock,
	output	[3:0]							m_axi_awcache,
	output	[2:0]							m_axi_awprot,
	output	[3:0]							m_axi_awregion,
	output	[3:0]							m_axi_awqos,
	output	[C_M_AXI_AWUSER_WIDTH-1:0]		m_axi_awuser,
	output									m_axi_awvalid,
	input									m_axi_awready,

// Write data channel
	output	[C_M_AXI_ID_WIDTH-1:0]			m_axi_wid,
	output	[C_M_AXI_DATA_WIDTH-1:0]		m_axi_wdata,
	output	[(C_M_AXI_DATA_WIDTH/8)-1:0]	m_axi_wstrb,
	output									m_axi_wlast,
	output	[C_M_AXI_WUSER_WIDTH-1:0]		m_axi_wuser,
	output									m_axi_wvalid,
	input									m_axi_wready,

// Write response channel
	input	[C_M_AXI_ID_WIDTH-1:0]			m_axi_bid,
	input	[1:0]							m_axi_bresp,
	input									m_axi_bvalid,
	input	[C_M_AXI_BUSER_WIDTH-1:0]		m_axi_buser,
	output									m_axi_bready,

	output									m_axi_bresp_err,

	output									dev_rx_cmd_rd_en,
	input	[29:0]							dev_rx_cmd_rd_data,
	input									dev_rx_cmd_empty_n,

	output									pcie_rx_fifo_rd_en,
	input	[C_M_AXI_DATA_WIDTH-1:0]		pcie_rx_fifo_rd_data,
	output									pcie_rx_fifo_free_en,
	output	[9:4]							pcie_rx_fifo_free_len,
	input									pcie_rx_fifo_empty_n,

	output									dma_rx_done_wr_en,
	output	[20:0]							dma_rx_done_wr_data,
	input									dma_rx_done_wr_rdy_n
);

localparam	LP_AW_DELAY						= 7;

localparam	S_AW_IDLE						= 11'b00000000001;
localparam	S_AW_CMD_0						= 11'b00000000010;
localparam	S_AW_CMD_1						= 11'b00000000100;
localparam	S_AW_WAIT_EMPTY_N				= 11'b00000001000;
localparam	S_AW_REQ						= 11'b00000010000;
localparam	S_AW_WAIT						= 11'b00000100000;
localparam	S_AW_W_REQ						= 11'b00001000000;
localparam	S_AW_DONE						= 11'b00010000000;
localparam	S_AW_DELAY						= 11'b00100000000;
localparam	S_AW_DMA_DONE_WR_WAIT			= 11'b01000000000;
localparam	S_AW_DMA_DONE_WR				= 11'b10000000000;


reg		[10:0]								cur_aw_state;
reg		[10:0]								next_aw_state;

localparam	S_W_IDLE						= 4'b0001;
localparam	S_W_DATA						= 4'b0010;
localparam	S_W_READY_WAIT					= 4'b0100;
localparam	S_W_DATA_LAST					= 4'b1000;

reg		[4:0]								cur_w_state;
reg		[4:0]								next_w_state;

reg											r_dma_cmd_type;
reg		[6:0]								r_hcmd_slot_tag;
reg		[31:2]								r_dev_addr;
reg		[12:2]								r_dev_dma_len;
reg		[12:2]								r_dev_dma_orig_len;
reg		[9:2]								r_dev_cur_len;
reg		[9:2]								r_wr_data_cnt;
reg		[4:0]								r_aw_delay;

reg		[9:2]								r_m_axi_awlen;
reg											r_m_axi_awvalid;
reg		[C_M_AXI_DATA_WIDTH-1:0]			r_m_axi_wdata;
reg											r_m_axi_wlast;
reg											r_m_axi_wvalid;
reg											r_m_axi_wdata_sel;

reg											r_m_axi_bvalid;
//reg											r_m_axi_bvalid_d1;
//wire										w_m_axi_bvalid;
reg		[C_M_AXI_ID_WIDTH-1:0]				r_m_axi_bid;
reg		[1:0]								r_m_axi_bresp;
reg											r_m_axi_bresp_err;
reg											r_m_axi_bresp_err_d1;
reg											r_m_axi_bresp_err_d2;

reg		[2:0]								r_axi_aw_req_gnt;
reg											r_axi_aw_req;
wire										w_axi_aw_req_gnt;
reg											r_axi_wr_req;
reg											r_axi_wr_rdy;

reg											r_dev_rx_cmd_rd_en;
reg											r_pcie_rx_fifo_rd_en;
reg		[C_M_AXI_DATA_WIDTH-1:0]			r_pcie_rx_fifo_rd_data;
reg		[C_M_AXI_DATA_WIDTH-1:0]			r_pcie_rx_fifo_rd_data_d1;
reg											r_pcie_rx_fifo_free_en;

reg											r_dma_rx_done_wr_en;

wire	[63:0]								w_one_padding;

assign w_one_padding = 64'hFFFF_FFFF_FFFF_FFFF;

assign m_axi_awid = 0;
assign m_axi_awaddr = {r_dev_addr, 2'b0};
assign m_axi_awlen = {1'b0, r_m_axi_awlen[9:3]};
assign m_axi_awsize = `D_AXSIZE_008_BYTES;
assign m_axi_awburst = `D_AXBURST_INCR;
assign m_axi_awlock = `D_AXLOCK_NORMAL;
assign m_axi_awcache = `D_AXCACHE_NON_CACHE;
assign m_axi_awprot = `D_AXPROT_SECURE;
assign m_axi_awregion = 0;
assign m_axi_awqos = 0;
assign m_axi_awuser = 0;
assign m_axi_awvalid = r_m_axi_awvalid;

assign m_axi_wid = 0;
assign m_axi_wdata = r_m_axi_wdata;
assign m_axi_wstrb = w_one_padding[(C_M_AXI_DATA_WIDTH/8)-1:0];
assign m_axi_wlast = r_m_axi_wlast;
assign m_axi_wuser = 0;
assign m_axi_wvalid = r_m_axi_wvalid;

assign m_axi_bready = 1;
assign m_axi_bresp_err = r_m_axi_bresp_err_d2;

assign dev_rx_cmd_rd_en = r_dev_rx_cmd_rd_en;
assign pcie_rx_fifo_rd_en = r_pcie_rx_fifo_rd_en;
assign pcie_rx_fifo_free_en = r_pcie_rx_fifo_free_en;
assign pcie_rx_fifo_free_len = r_dev_cur_len[9:4];

assign dma_rx_done_wr_en = r_dma_rx_done_wr_en;
assign dma_rx_done_wr_data = {r_dma_cmd_type, 1'b1, 1'b0, r_hcmd_slot_tag, r_dev_dma_orig_len};


always @ (posedge m_axi_aclk or negedge m_axi_aresetn)
begin
	if(m_axi_aresetn == 0)
		cur_aw_state <= S_AW_IDLE;
	else
		cur_aw_state <= next_aw_state;
end

always @ (*)
begin
	case(cur_aw_state)
		S_AW_IDLE: begin
			if(dev_rx_cmd_empty_n == 1)
				next_aw_state <= S_AW_CMD_0;
			else
				next_aw_state <= S_AW_IDLE;
		end
		S_AW_CMD_0: begin
			next_aw_state <= S_AW_CMD_1;
		end
		S_AW_CMD_1: begin
			next_aw_state <= S_AW_WAIT_EMPTY_N;
		end
		S_AW_WAIT_EMPTY_N: begin
			if(pcie_rx_fifo_empty_n == 1 && w_axi_aw_req_gnt == 1)
				next_aw_state <= S_AW_REQ;
			else
				next_aw_state <= S_AW_WAIT_EMPTY_N;
		end
		S_AW_REQ: begin
			if(m_axi_awready == 1)
				next_aw_state <= S_AW_W_REQ;
			else
				next_aw_state <= S_AW_WAIT;
		end
		S_AW_WAIT: begin
			if(m_axi_awready == 1)
				next_aw_state <= S_AW_W_REQ;
			else
				next_aw_state <= S_AW_WAIT;
		end
		S_AW_W_REQ: begin
			if(r_axi_wr_rdy == 1)
				next_aw_state <= S_AW_DONE;
			else
				next_aw_state <= S_AW_W_REQ;
		end
		S_AW_DONE: begin
			if(r_dev_dma_len == 0)
				next_aw_state <= S_AW_DMA_DONE_WR_WAIT;
			else
				next_aw_state <= S_AW_DELAY;
		end
		S_AW_DELAY: begin
			if(r_aw_delay == 0)
				next_aw_state <= S_AW_WAIT_EMPTY_N;
			else
				next_aw_state <= S_AW_DELAY;
		end
		S_AW_DMA_DONE_WR_WAIT: begin
			if(dma_rx_done_wr_rdy_n == 1)
				next_aw_state <= S_AW_DMA_DONE_WR_WAIT;
			else
				next_aw_state <= S_AW_DMA_DONE_WR;
		end
		S_AW_DMA_DONE_WR: begin
			next_aw_state <= S_AW_IDLE;
		end
		default: begin
			next_aw_state <= S_AW_IDLE;
		end
	endcase
end

always @ (posedge m_axi_aclk)
begin
	case(cur_aw_state)
		S_AW_IDLE: begin

		end
		S_AW_CMD_0: begin
			r_dma_cmd_type <= dev_rx_cmd_rd_data[19];
			r_hcmd_slot_tag <= dev_rx_cmd_rd_data[17:11];
			r_dev_dma_len <= {dev_rx_cmd_rd_data[10:2], 2'b0};
		end
		S_AW_CMD_1: begin
			r_dev_dma_orig_len <= r_dev_dma_len;
			if(r_dev_dma_len[8:2] == 0)
				r_dev_cur_len[9] <= 1;
			else
				r_dev_cur_len[9] <= 0;
			
			r_dev_cur_len[8:2] <= r_dev_dma_len[8:2];
			r_dev_addr <= {dev_rx_cmd_rd_data[29:2], 2'b0};
		end
		S_AW_WAIT_EMPTY_N: begin
			r_m_axi_awlen <= r_dev_cur_len - 2;
		end
		S_AW_REQ: begin
			r_dev_dma_len <= r_dev_dma_len - r_dev_cur_len;
		end
		S_AW_WAIT: begin

		end
		S_AW_W_REQ: begin

		end
		S_AW_DONE: begin
			r_dev_cur_len <= 8'h80;
			r_dev_addr <= r_dev_addr + r_dev_cur_len;
			r_aw_delay <= LP_AW_DELAY;
		end
		S_AW_DELAY: begin
			r_aw_delay <= r_aw_delay - 1;
		end
		S_AW_DMA_DONE_WR_WAIT: begin

		end
		S_AW_DMA_DONE_WR: begin

		end
		default: begin

		end
	endcase
end


always @ (*)
begin
	case(cur_aw_state)
		S_AW_IDLE: begin
			r_dev_rx_cmd_rd_en <= 0;
			r_m_axi_awvalid <= 0;
			r_axi_aw_req <= 0;
			r_axi_wr_req <= 0;
			r_pcie_rx_fifo_free_en <= 0;
			r_dma_rx_done_wr_en <= 0;
		end
		S_AW_CMD_0: begin
			r_dev_rx_cmd_rd_en <= 1;
			r_m_axi_awvalid <= 0;
			r_axi_aw_req <= 0;
			r_axi_wr_req <= 0;
			r_pcie_rx_fifo_free_en <= 0;
			r_dma_rx_done_wr_en <= 0;
		end
		S_AW_CMD_1: begin
			r_dev_rx_cmd_rd_en <= 1;
			r_m_axi_awvalid <= 0;
			r_axi_aw_req <= 0;
			r_axi_wr_req <= 0;
			r_pcie_rx_fifo_free_en <= 0;
			r_dma_rx_done_wr_en <= 0;
		end
		S_AW_WAIT_EMPTY_N: begin
			r_dev_rx_cmd_rd_en <= 0;
			r_m_axi_awvalid <= 0;
			r_axi_aw_req <= 0;
			r_axi_wr_req <= 0;
			r_pcie_rx_fifo_free_en <= 0;
			r_dma_rx_done_wr_en <= 0;
		end
		S_AW_REQ: begin
			r_dev_rx_cmd_rd_en <= 0;
			r_m_axi_awvalid <= 1;
			r_axi_aw_req <= 1;
			r_axi_wr_req <= 0;
			r_pcie_rx_fifo_free_en <= 1;
			r_dma_rx_done_wr_en <= 0;
		end
		S_AW_WAIT: begin
			r_dev_rx_cmd_rd_en <= 0;
			r_m_axi_awvalid <= 1;
			r_axi_aw_req <= 0;
			r_axi_wr_req <= 0;
			r_pcie_rx_fifo_free_en <= 0;
			r_dma_rx_done_wr_en <= 0;
		end
		S_AW_W_REQ: begin
			r_dev_rx_cmd_rd_en <= 0;
			r_m_axi_awvalid <= 0;
			r_axi_aw_req <= 0;
			r_axi_wr_req <= 1;
			r_pcie_rx_fifo_free_en <= 0;
			r_dma_rx_done_wr_en <= 0;
		end
		S_AW_DONE: begin
			r_dev_rx_cmd_rd_en <= 0;
			r_m_axi_awvalid <= 0;
			r_axi_aw_req <= 0;
			r_axi_wr_req <= 0;
			r_pcie_rx_fifo_free_en <= 0;
			r_dma_rx_done_wr_en <= 0;
		end
		S_AW_DELAY: begin
			r_dev_rx_cmd_rd_en <= 0;
			r_m_axi_awvalid <= 0;
			r_axi_aw_req <= 0;
			r_axi_wr_req <= 0;
			r_pcie_rx_fifo_free_en <= 0;
			r_dma_rx_done_wr_en <= 0;
		end
		S_AW_DMA_DONE_WR_WAIT: begin
			r_dev_rx_cmd_rd_en <= 0;
			r_m_axi_awvalid <= 0;
			r_axi_aw_req <= 0;
			r_axi_wr_req <= 0;
			r_pcie_rx_fifo_free_en <= 0;
			r_dma_rx_done_wr_en <= 0;
		end
		S_AW_DMA_DONE_WR: begin
			r_dev_rx_cmd_rd_en <= 0;
			r_m_axi_awvalid <= 0;
			r_axi_aw_req <= 0;
			r_axi_wr_req <= 0;
			r_pcie_rx_fifo_free_en <= 0;
			r_dma_rx_done_wr_en <= 1;
		end
		default: begin
			r_dev_rx_cmd_rd_en <= 0;
			r_m_axi_awvalid <= 0;
			r_axi_aw_req <= 0;
			r_axi_wr_req <= 0;
			r_pcie_rx_fifo_free_en <= 0;
			r_dma_rx_done_wr_en <= 0;
		end
	endcase
end

assign w_axi_aw_req_gnt = r_axi_aw_req_gnt[2];

//assign w_m_axi_bvalid = r_m_axi_bvalid & ~r_m_axi_bvalid_d1;

always @ (posedge m_axi_aclk)
begin
	r_m_axi_bvalid <= m_axi_bvalid;
//	r_m_axi_bvalid_d1 <= r_m_axi_bvalid;
	r_m_axi_bid <= m_axi_bid;
	r_m_axi_bresp <= m_axi_bresp;

	r_m_axi_bresp_err_d1 <= r_m_axi_bresp_err;
	r_m_axi_bresp_err_d2 <= r_m_axi_bresp_err | r_m_axi_bresp_err_d1;
end

always @ (*)
begin
	if(r_m_axi_bvalid == 1 && (r_m_axi_bresp != `D_AXI_RESP_OKAY || r_m_axi_bid != 0))
		r_m_axi_bresp_err <= 1;
	else
		r_m_axi_bresp_err <= 0;
end

always @ (posedge m_axi_aclk or negedge m_axi_aresetn)
begin
	if(m_axi_aresetn == 0) begin
		r_axi_aw_req_gnt <= 3'b110;
	end
	else begin
		case({r_m_axi_bvalid, r_axi_aw_req})
			2'b01: begin
				r_axi_aw_req_gnt <= {r_axi_aw_req_gnt[1:0], r_axi_aw_req_gnt[2]};
			end
			2'b10: begin
				r_axi_aw_req_gnt <= {r_axi_aw_req_gnt[0], r_axi_aw_req_gnt[2:1]};
			end
			default: begin

			end
		endcase
	end
end

always @ (posedge m_axi_aclk or negedge m_axi_aresetn)
begin
	if(m_axi_aresetn == 0)
		cur_w_state <= S_W_IDLE;
	else
		cur_w_state <= next_w_state;
end

always @ (*)
begin
	case(cur_w_state)
		S_W_IDLE: begin
			if(r_axi_wr_req == 1) begin
				if(r_m_axi_awlen == 0)
					next_w_state <= S_W_DATA_LAST;
				else
					next_w_state <= S_W_DATA;
			end
			else
				next_w_state <= S_W_IDLE;
		end
		S_W_DATA: begin
			if(m_axi_wready == 1) begin
				if(r_wr_data_cnt == 2)
					next_w_state <= S_W_DATA_LAST;
				else
					next_w_state <= S_W_DATA;
			end
			else
				next_w_state <= S_W_READY_WAIT;
		end
		S_W_READY_WAIT: begin
			if(m_axi_wready == 1) begin
				if(r_wr_data_cnt == 0)
					next_w_state <= S_W_DATA_LAST;
				else
					next_w_state <= S_W_DATA;
			end
			else
				next_w_state <= S_W_READY_WAIT;
		end
		S_W_DATA_LAST: begin
			if(m_axi_wready == 1)
				next_w_state <= S_W_IDLE;
			else
				next_w_state <= S_W_DATA_LAST;
		end
		default: begin
			next_w_state <= S_W_IDLE;
		end
	endcase
end

always @ (posedge m_axi_aclk)
begin
	case(cur_w_state)
		S_W_IDLE: begin
			r_wr_data_cnt <= r_m_axi_awlen;
			r_pcie_rx_fifo_rd_data <= pcie_rx_fifo_rd_data;
		end
		S_W_DATA: begin
			r_wr_data_cnt <= r_wr_data_cnt - 2;
			r_pcie_rx_fifo_rd_data <= pcie_rx_fifo_rd_data;
			r_pcie_rx_fifo_rd_data_d1 <= r_pcie_rx_fifo_rd_data;
		end
		S_W_READY_WAIT: begin

		end
		S_W_DATA_LAST: begin

		end
		default: begin

		end
	endcase
end

always @ (*)
begin
	if(r_m_axi_wdata_sel == 1)
		r_m_axi_wdata <= r_pcie_rx_fifo_rd_data_d1;
	else
		r_m_axi_wdata <= r_pcie_rx_fifo_rd_data;
end

always @ (*)
begin
	case(cur_w_state)
		S_W_IDLE: begin
			r_m_axi_wdata_sel <= 0;
			r_m_axi_wlast <= 0;
			r_m_axi_wvalid <= 0;
			r_axi_wr_rdy <= 1;
			r_pcie_rx_fifo_rd_en <= r_axi_wr_req;
		end
		S_W_DATA: begin
			r_m_axi_wdata_sel <= 0;
			r_m_axi_wlast <= 0;
			r_m_axi_wvalid <= 1;
			r_axi_wr_rdy <= 0;
			r_pcie_rx_fifo_rd_en <= 1;
		end
		S_W_READY_WAIT: begin
			r_m_axi_wdata_sel <= 1;
			r_m_axi_wlast <= 0;
			r_m_axi_wvalid <= 1;
			r_axi_wr_rdy <= 0;
			r_pcie_rx_fifo_rd_en <= 0;
		end
		S_W_DATA_LAST: begin
			r_m_axi_wdata_sel <= 0;
			r_m_axi_wlast <= 1;
			r_m_axi_wvalid <= 1;
			r_axi_wr_rdy <= 0;
			r_pcie_rx_fifo_rd_en <= 0;
		end
		default: begin
			r_m_axi_wdata_sel <= 0;
			r_m_axi_wlast <= 0;
			r_m_axi_wvalid <= 0;
			r_axi_wr_rdy <= 0;
			r_pcie_rx_fifo_rd_en <= 0;
		end
	endcase
end

endmodule

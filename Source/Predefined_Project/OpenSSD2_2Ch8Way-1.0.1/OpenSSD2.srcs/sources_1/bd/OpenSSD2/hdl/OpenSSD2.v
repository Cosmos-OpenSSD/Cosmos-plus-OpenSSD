//Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2014.4.1 (win64) Build 1149489 Thu Feb 19 16:23:09 MST 2015
//Date        : Mon May 22 16:31:43 2017
//Host        : aCentauri running 64-bit Service Pack 1  (build 7601)
//Command     : generate_target OpenSSD2.bd
//Design      : OpenSSD2
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module OpenSSD2
   (DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    IO_NAND_CH0_DQ,
    IO_NAND_CH0_DQS_N,
    IO_NAND_CH0_DQS_P,
    IO_NAND_CH1_DQ,
    IO_NAND_CH1_DQS_N,
    IO_NAND_CH1_DQS_P,
    I_NAND_CH0_RB,
    I_NAND_CH1_RB,
    O_DEBUG,
    O_NAND_CH0_ALE,
    O_NAND_CH0_CE,
    O_NAND_CH0_CLE,
    O_NAND_CH0_RE_N,
    O_NAND_CH0_RE_P,
    O_NAND_CH0_WE,
    O_NAND_CH0_WP,
    O_NAND_CH1_ALE,
    O_NAND_CH1_CE,
    O_NAND_CH1_CLE,
    O_NAND_CH1_RE_N,
    O_NAND_CH1_RE_P,
    O_NAND_CH1_WE,
    O_NAND_CH1_WP,
    pcie_perst_n,
    pcie_ref_clk_n,
    pcie_ref_clk_p,
    pcie_rx_n,
    pcie_rx_p,
    pcie_tx_n,
    pcie_tx_p);
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  inout [7:0]IO_NAND_CH0_DQ;
  inout IO_NAND_CH0_DQS_N;
  inout IO_NAND_CH0_DQS_P;
  inout [7:0]IO_NAND_CH1_DQ;
  inout IO_NAND_CH1_DQS_N;
  inout IO_NAND_CH1_DQS_P;
  input [7:0]I_NAND_CH0_RB;
  input [7:0]I_NAND_CH1_RB;
  output [31:0]O_DEBUG;
  output O_NAND_CH0_ALE;
  output [7:0]O_NAND_CH0_CE;
  output O_NAND_CH0_CLE;
  output O_NAND_CH0_RE_N;
  output O_NAND_CH0_RE_P;
  output O_NAND_CH0_WE;
  output O_NAND_CH0_WP;
  output O_NAND_CH1_ALE;
  output [7:0]O_NAND_CH1_CE;
  output O_NAND_CH1_CLE;
  output O_NAND_CH1_RE_N;
  output O_NAND_CH1_RE_P;
  output O_NAND_CH1_WE;
  output O_NAND_CH1_WP;
  input pcie_perst_n;
  input pcie_ref_clk_n;
  input pcie_ref_clk_p;
  input [7:0]pcie_rx_n;
  input [7:0]pcie_rx_p;
  output [7:0]pcie_tx_n;
  output [7:0]pcie_tx_p;

  wire [0:0]ARESETN_1;
  wire [0:0]ARESETN_2;
  wire [0:0]ARESETN_3;
  wire CH0MMCMC1H200_clk_out1;
  wire GND_1;
  wire [31:0]GPIC0_M00_AXI_ARADDR;
  wire [2:0]GPIC0_M00_AXI_ARPROT;
  wire GPIC0_M00_AXI_ARREADY;
  wire GPIC0_M00_AXI_ARVALID;
  wire [31:0]GPIC0_M00_AXI_AWADDR;
  wire [2:0]GPIC0_M00_AXI_AWPROT;
  wire GPIC0_M00_AXI_AWREADY;
  wire GPIC0_M00_AXI_AWVALID;
  wire GPIC0_M00_AXI_BREADY;
  wire [1:0]GPIC0_M00_AXI_BRESP;
  wire GPIC0_M00_AXI_BVALID;
  wire [31:0]GPIC0_M00_AXI_RDATA;
  wire GPIC0_M00_AXI_RREADY;
  wire [1:0]GPIC0_M00_AXI_RRESP;
  wire GPIC0_M00_AXI_RVALID;
  wire [31:0]GPIC0_M00_AXI_WDATA;
  wire GPIC0_M00_AXI_WREADY;
  wire [3:0]GPIC0_M00_AXI_WSTRB;
  wire GPIC0_M00_AXI_WVALID;
  wire [31:0]GPIC0_M01_AXI_ARADDR;
  wire [2:0]GPIC0_M01_AXI_ARPROT;
  wire GPIC0_M01_AXI_ARREADY;
  wire GPIC0_M01_AXI_ARVALID;
  wire [31:0]GPIC0_M01_AXI_AWADDR;
  wire [2:0]GPIC0_M01_AXI_AWPROT;
  wire GPIC0_M01_AXI_AWREADY;
  wire GPIC0_M01_AXI_AWVALID;
  wire GPIC0_M01_AXI_BREADY;
  wire [1:0]GPIC0_M01_AXI_BRESP;
  wire GPIC0_M01_AXI_BVALID;
  wire [31:0]GPIC0_M01_AXI_RDATA;
  wire GPIC0_M01_AXI_RREADY;
  wire [1:0]GPIC0_M01_AXI_RRESP;
  wire GPIC0_M01_AXI_RVALID;
  wire [31:0]GPIC0_M01_AXI_WDATA;
  wire GPIC0_M01_AXI_WREADY;
  wire [3:0]GPIC0_M01_AXI_WSTRB;
  wire GPIC0_M01_AXI_WVALID;
  wire [31:0]GPIC1_M00_AXI_ARADDR;
  wire [2:0]GPIC1_M00_AXI_ARPROT;
  wire GPIC1_M00_AXI_ARREADY;
  wire GPIC1_M00_AXI_ARVALID;
  wire [31:0]GPIC1_M00_AXI_AWADDR;
  wire [2:0]GPIC1_M00_AXI_AWPROT;
  wire GPIC1_M00_AXI_AWREADY;
  wire GPIC1_M00_AXI_AWVALID;
  wire GPIC1_M00_AXI_BREADY;
  wire [1:0]GPIC1_M00_AXI_BRESP;
  wire GPIC1_M00_AXI_BVALID;
  wire [31:0]GPIC1_M00_AXI_RDATA;
  wire GPIC1_M00_AXI_RREADY;
  wire [1:0]GPIC1_M00_AXI_RRESP;
  wire GPIC1_M00_AXI_RVALID;
  wire [31:0]GPIC1_M00_AXI_WDATA;
  wire GPIC1_M00_AXI_WREADY;
  wire [3:0]GPIC1_M00_AXI_WSTRB;
  wire GPIC1_M00_AXI_WVALID;
  wire [31:0]HPIC3_M00_AXI_ARADDR;
  wire [1:0]HPIC3_M00_AXI_ARBURST;
  wire [3:0]HPIC3_M00_AXI_ARCACHE;
  wire [0:0]HPIC3_M00_AXI_ARID;
  wire [3:0]HPIC3_M00_AXI_ARLEN;
  wire [1:0]HPIC3_M00_AXI_ARLOCK;
  wire [2:0]HPIC3_M00_AXI_ARPROT;
  wire [3:0]HPIC3_M00_AXI_ARQOS;
  wire HPIC3_M00_AXI_ARREADY;
  wire [2:0]HPIC3_M00_AXI_ARSIZE;
  wire HPIC3_M00_AXI_ARVALID;
  wire [31:0]HPIC3_M00_AXI_AWADDR;
  wire [1:0]HPIC3_M00_AXI_AWBURST;
  wire [3:0]HPIC3_M00_AXI_AWCACHE;
  wire [0:0]HPIC3_M00_AXI_AWID;
  wire [3:0]HPIC3_M00_AXI_AWLEN;
  wire [1:0]HPIC3_M00_AXI_AWLOCK;
  wire [2:0]HPIC3_M00_AXI_AWPROT;
  wire [3:0]HPIC3_M00_AXI_AWQOS;
  wire HPIC3_M00_AXI_AWREADY;
  wire [2:0]HPIC3_M00_AXI_AWSIZE;
  wire HPIC3_M00_AXI_AWVALID;
  wire [5:0]HPIC3_M00_AXI_BID;
  wire HPIC3_M00_AXI_BREADY;
  wire [1:0]HPIC3_M00_AXI_BRESP;
  wire HPIC3_M00_AXI_BVALID;
  wire [63:0]HPIC3_M00_AXI_RDATA;
  wire [5:0]HPIC3_M00_AXI_RID;
  wire HPIC3_M00_AXI_RLAST;
  wire HPIC3_M00_AXI_RREADY;
  wire [1:0]HPIC3_M00_AXI_RRESP;
  wire HPIC3_M00_AXI_RVALID;
  wire [63:0]HPIC3_M00_AXI_WDATA;
  wire [0:0]HPIC3_M00_AXI_WID;
  wire HPIC3_M00_AXI_WLAST;
  wire HPIC3_M00_AXI_WREADY;
  wire [7:0]HPIC3_M00_AXI_WSTRB;
  wire HPIC3_M00_AXI_WVALID;
  wire [7:0]I_NAND_RB_1;
  wire [7:0]I_NAND_RB_2;
  wire [0:0]M00_ARESETN_1;
  wire [0:0]M00_ARESETN_2;
  wire NVMeHostController_0_dev_irq_assert;
  wire [31:0]NVMeHostController_0_m0_axi_ARADDR;
  wire [1:0]NVMeHostController_0_m0_axi_ARBURST;
  wire [3:0]NVMeHostController_0_m0_axi_ARCACHE;
  wire [0:0]NVMeHostController_0_m0_axi_ARID;
  wire [7:0]NVMeHostController_0_m0_axi_ARLEN;
  wire [1:0]NVMeHostController_0_m0_axi_ARLOCK;
  wire [2:0]NVMeHostController_0_m0_axi_ARPROT;
  wire [3:0]NVMeHostController_0_m0_axi_ARQOS;
  wire NVMeHostController_0_m0_axi_ARREADY;
  wire [3:0]NVMeHostController_0_m0_axi_ARREGION;
  wire [2:0]NVMeHostController_0_m0_axi_ARSIZE;
  wire [0:0]NVMeHostController_0_m0_axi_ARUSER;
  wire NVMeHostController_0_m0_axi_ARVALID;
  wire [31:0]NVMeHostController_0_m0_axi_AWADDR;
  wire [1:0]NVMeHostController_0_m0_axi_AWBURST;
  wire [3:0]NVMeHostController_0_m0_axi_AWCACHE;
  wire [0:0]NVMeHostController_0_m0_axi_AWID;
  wire [7:0]NVMeHostController_0_m0_axi_AWLEN;
  wire [1:0]NVMeHostController_0_m0_axi_AWLOCK;
  wire [2:0]NVMeHostController_0_m0_axi_AWPROT;
  wire [3:0]NVMeHostController_0_m0_axi_AWQOS;
  wire NVMeHostController_0_m0_axi_AWREADY;
  wire [3:0]NVMeHostController_0_m0_axi_AWREGION;
  wire [2:0]NVMeHostController_0_m0_axi_AWSIZE;
  wire [0:0]NVMeHostController_0_m0_axi_AWUSER;
  wire NVMeHostController_0_m0_axi_AWVALID;
  wire [0:0]NVMeHostController_0_m0_axi_BID;
  wire NVMeHostController_0_m0_axi_BREADY;
  wire [1:0]NVMeHostController_0_m0_axi_BRESP;
  wire NVMeHostController_0_m0_axi_BVALID;
  wire [63:0]NVMeHostController_0_m0_axi_RDATA;
  wire [0:0]NVMeHostController_0_m0_axi_RID;
  wire NVMeHostController_0_m0_axi_RLAST;
  wire NVMeHostController_0_m0_axi_RREADY;
  wire [1:0]NVMeHostController_0_m0_axi_RRESP;
  wire [0:0]NVMeHostController_0_m0_axi_RUSER;
  wire NVMeHostController_0_m0_axi_RVALID;
  wire [63:0]NVMeHostController_0_m0_axi_WDATA;
  wire NVMeHostController_0_m0_axi_WLAST;
  wire NVMeHostController_0_m0_axi_WREADY;
  wire [7:0]NVMeHostController_0_m0_axi_WSTRB;
  wire [0:0]NVMeHostController_0_m0_axi_WUSER;
  wire NVMeHostController_0_m0_axi_WVALID;
  wire [7:0]NVMeHostController_0_pcie_tx_n;
  wire [7:0]NVMeHostController_0_pcie_tx_p;
  wire Net;
  wire [7:0]Net1;
  wire Net2;
  wire Net3;
  wire Net4;
  wire [7:0]Net5;
  wire PS_FCLK_CLK0;
  wire PS_FCLK_CLK2;
  wire PS_FCLK_CLK3;
  wire PS_FCLK_RESET0_N;
  wire PS_FCLK_RESET2_N;
  wire PS_FCLK_RESET3_N;
  wire [31:0]PS_M_AXI_GP0_ARADDR;
  wire [1:0]PS_M_AXI_GP0_ARBURST;
  wire [3:0]PS_M_AXI_GP0_ARCACHE;
  wire [11:0]PS_M_AXI_GP0_ARID;
  wire [3:0]PS_M_AXI_GP0_ARLEN;
  wire [1:0]PS_M_AXI_GP0_ARLOCK;
  wire [2:0]PS_M_AXI_GP0_ARPROT;
  wire [3:0]PS_M_AXI_GP0_ARQOS;
  wire PS_M_AXI_GP0_ARREADY;
  wire [2:0]PS_M_AXI_GP0_ARSIZE;
  wire PS_M_AXI_GP0_ARVALID;
  wire [31:0]PS_M_AXI_GP0_AWADDR;
  wire [1:0]PS_M_AXI_GP0_AWBURST;
  wire [3:0]PS_M_AXI_GP0_AWCACHE;
  wire [11:0]PS_M_AXI_GP0_AWID;
  wire [3:0]PS_M_AXI_GP0_AWLEN;
  wire [1:0]PS_M_AXI_GP0_AWLOCK;
  wire [2:0]PS_M_AXI_GP0_AWPROT;
  wire [3:0]PS_M_AXI_GP0_AWQOS;
  wire PS_M_AXI_GP0_AWREADY;
  wire [2:0]PS_M_AXI_GP0_AWSIZE;
  wire PS_M_AXI_GP0_AWVALID;
  wire [11:0]PS_M_AXI_GP0_BID;
  wire PS_M_AXI_GP0_BREADY;
  wire [1:0]PS_M_AXI_GP0_BRESP;
  wire PS_M_AXI_GP0_BVALID;
  wire [31:0]PS_M_AXI_GP0_RDATA;
  wire [11:0]PS_M_AXI_GP0_RID;
  wire PS_M_AXI_GP0_RLAST;
  wire PS_M_AXI_GP0_RREADY;
  wire [1:0]PS_M_AXI_GP0_RRESP;
  wire PS_M_AXI_GP0_RVALID;
  wire [31:0]PS_M_AXI_GP0_WDATA;
  wire [11:0]PS_M_AXI_GP0_WID;
  wire PS_M_AXI_GP0_WLAST;
  wire PS_M_AXI_GP0_WREADY;
  wire [3:0]PS_M_AXI_GP0_WSTRB;
  wire PS_M_AXI_GP0_WVALID;
  wire [31:0]S00_AXI_2_ARADDR;
  wire [1:0]S00_AXI_2_ARBURST;
  wire [3:0]S00_AXI_2_ARCACHE;
  wire [11:0]S00_AXI_2_ARID;
  wire [3:0]S00_AXI_2_ARLEN;
  wire [1:0]S00_AXI_2_ARLOCK;
  wire [2:0]S00_AXI_2_ARPROT;
  wire [3:0]S00_AXI_2_ARQOS;
  wire S00_AXI_2_ARREADY;
  wire [2:0]S00_AXI_2_ARSIZE;
  wire S00_AXI_2_ARVALID;
  wire [31:0]S00_AXI_2_AWADDR;
  wire [1:0]S00_AXI_2_AWBURST;
  wire [3:0]S00_AXI_2_AWCACHE;
  wire [11:0]S00_AXI_2_AWID;
  wire [3:0]S00_AXI_2_AWLEN;
  wire [1:0]S00_AXI_2_AWLOCK;
  wire [2:0]S00_AXI_2_AWPROT;
  wire [3:0]S00_AXI_2_AWQOS;
  wire S00_AXI_2_AWREADY;
  wire [2:0]S00_AXI_2_AWSIZE;
  wire S00_AXI_2_AWVALID;
  wire [11:0]S00_AXI_2_BID;
  wire S00_AXI_2_BREADY;
  wire [1:0]S00_AXI_2_BRESP;
  wire S00_AXI_2_BVALID;
  wire [31:0]S00_AXI_2_RDATA;
  wire [11:0]S00_AXI_2_RID;
  wire S00_AXI_2_RLAST;
  wire S00_AXI_2_RREADY;
  wire [1:0]S00_AXI_2_RRESP;
  wire S00_AXI_2_RVALID;
  wire [31:0]S00_AXI_2_WDATA;
  wire [11:0]S00_AXI_2_WID;
  wire S00_AXI_2_WLAST;
  wire S00_AXI_2_WREADY;
  wire [3:0]S00_AXI_2_WSTRB;
  wire S00_AXI_2_WVALID;
  wire [31:0]S01_AXI_1_ARADDR;
  wire [1:0]S01_AXI_1_ARBURST;
  wire [3:0]S01_AXI_1_ARCACHE;
  wire [7:0]S01_AXI_1_ARLEN;
  wire [2:0]S01_AXI_1_ARPROT;
  wire S01_AXI_1_ARREADY;
  wire [2:0]S01_AXI_1_ARSIZE;
  wire S01_AXI_1_ARVALID;
  wire [31:0]S01_AXI_1_AWADDR;
  wire [1:0]S01_AXI_1_AWBURST;
  wire [3:0]S01_AXI_1_AWCACHE;
  wire [7:0]S01_AXI_1_AWLEN;
  wire [2:0]S01_AXI_1_AWPROT;
  wire S01_AXI_1_AWREADY;
  wire [2:0]S01_AXI_1_AWSIZE;
  wire S01_AXI_1_AWVALID;
  wire S01_AXI_1_BREADY;
  wire [1:0]S01_AXI_1_BRESP;
  wire S01_AXI_1_BVALID;
  wire [31:0]S01_AXI_1_RDATA;
  wire S01_AXI_1_RLAST;
  wire S01_AXI_1_RREADY;
  wire [1:0]S01_AXI_1_RRESP;
  wire S01_AXI_1_RVALID;
  wire [31:0]S01_AXI_1_WDATA;
  wire S01_AXI_1_WLAST;
  wire S01_AXI_1_WREADY;
  wire [3:0]S01_AXI_1_WSTRB;
  wire S01_AXI_1_WVALID;
  wire [31:0]Tiger4NSC_0_D_AXI_ARADDR;
  wire [1:0]Tiger4NSC_0_D_AXI_ARBURST;
  wire [3:0]Tiger4NSC_0_D_AXI_ARCACHE;
  wire [7:0]Tiger4NSC_0_D_AXI_ARLEN;
  wire [2:0]Tiger4NSC_0_D_AXI_ARPROT;
  wire Tiger4NSC_0_D_AXI_ARREADY;
  wire [2:0]Tiger4NSC_0_D_AXI_ARSIZE;
  wire Tiger4NSC_0_D_AXI_ARVALID;
  wire [31:0]Tiger4NSC_0_D_AXI_AWADDR;
  wire [1:0]Tiger4NSC_0_D_AXI_AWBURST;
  wire [3:0]Tiger4NSC_0_D_AXI_AWCACHE;
  wire [7:0]Tiger4NSC_0_D_AXI_AWLEN;
  wire [2:0]Tiger4NSC_0_D_AXI_AWPROT;
  wire Tiger4NSC_0_D_AXI_AWREADY;
  wire [2:0]Tiger4NSC_0_D_AXI_AWSIZE;
  wire Tiger4NSC_0_D_AXI_AWVALID;
  wire Tiger4NSC_0_D_AXI_BREADY;
  wire [1:0]Tiger4NSC_0_D_AXI_BRESP;
  wire Tiger4NSC_0_D_AXI_BVALID;
  wire [31:0]Tiger4NSC_0_D_AXI_RDATA;
  wire Tiger4NSC_0_D_AXI_RLAST;
  wire Tiger4NSC_0_D_AXI_RREADY;
  wire [1:0]Tiger4NSC_0_D_AXI_RRESP;
  wire Tiger4NSC_0_D_AXI_RVALID;
  wire [31:0]Tiger4NSC_0_D_AXI_WDATA;
  wire Tiger4NSC_0_D_AXI_WLAST;
  wire Tiger4NSC_0_D_AXI_WREADY;
  wire [3:0]Tiger4NSC_0_D_AXI_WSTRB;
  wire Tiger4NSC_0_D_AXI_WVALID;
  wire [31:0]Tiger4NSC_0_NFCInterface_Address;
  wire Tiger4NSC_0_NFCInterface_CMDReady;
  wire Tiger4NSC_0_NFCInterface_CMDValid;
  wire [15:0]Tiger4NSC_0_NFCInterface_Length;
  wire [5:0]Tiger4NSC_0_NFCInterface_Opcode;
  wire [31:0]Tiger4NSC_0_NFCInterface_ReadData;
  wire Tiger4NSC_0_NFCInterface_ReadLast;
  wire Tiger4NSC_0_NFCInterface_ReadReady;
  wire Tiger4NSC_0_NFCInterface_ReadValid;
  wire [7:0]Tiger4NSC_0_NFCInterface_ReadyBusy;
  wire [4:0]Tiger4NSC_0_NFCInterface_SourceID;
  wire [4:0]Tiger4NSC_0_NFCInterface_TargetID;
  wire [31:0]Tiger4NSC_0_NFCInterface_WriteData;
  wire Tiger4NSC_0_NFCInterface_WriteLast;
  wire Tiger4NSC_0_NFCInterface_WriteReady;
  wire Tiger4NSC_0_NFCInterface_WriteValid;
  wire Tiger4NSC_0_SharedKESInterface_CSAvailable;
  wire [1:0]Tiger4NSC_0_SharedKESInterface_CorrectionFail;
  wire [1:0]Tiger4NSC_0_SharedKESInterface_DecodeNeeded;
  wire [359:0]Tiger4NSC_0_SharedKESInterface_ELPCoefficients;
  wire [17:0]Tiger4NSC_0_SharedKESInterface_ErrorCount;
  wire [1:0]Tiger4NSC_0_SharedKESInterface_ErrorDetectionEnd;
  wire [1:0]Tiger4NSC_0_SharedKESInterface_ErroredChunk;
  wire Tiger4NSC_0_SharedKESInterface_IntraSharedKESEnd;
  wire Tiger4NSC_0_SharedKESInterface_SharedKESReady;
  wire [647:0]Tiger4NSC_0_SharedKESInterface_Syndromes;
  wire [255:0]Tiger4NSC_0_uROMInterface_ADDR;
  wire Tiger4NSC_0_uROMInterface_CLK;
  wire [63:0]Tiger4NSC_0_uROMInterface_DIN;
  wire [63:0]Tiger4NSC_0_uROMInterface_DOUT;
  wire Tiger4NSC_0_uROMInterface_EN;
  wire Tiger4NSC_0_uROMInterface_RST;
  wire Tiger4NSC_0_uROMInterface_WE;
  wire [31:0]Tiger4NSC_1_NFCInterface_Address;
  wire Tiger4NSC_1_NFCInterface_CMDReady;
  wire Tiger4NSC_1_NFCInterface_CMDValid;
  wire [15:0]Tiger4NSC_1_NFCInterface_Length;
  wire [5:0]Tiger4NSC_1_NFCInterface_Opcode;
  wire [31:0]Tiger4NSC_1_NFCInterface_ReadData;
  wire Tiger4NSC_1_NFCInterface_ReadLast;
  wire Tiger4NSC_1_NFCInterface_ReadReady;
  wire Tiger4NSC_1_NFCInterface_ReadValid;
  wire [7:0]Tiger4NSC_1_NFCInterface_ReadyBusy;
  wire [4:0]Tiger4NSC_1_NFCInterface_SourceID;
  wire [4:0]Tiger4NSC_1_NFCInterface_TargetID;
  wire [31:0]Tiger4NSC_1_NFCInterface_WriteData;
  wire Tiger4NSC_1_NFCInterface_WriteLast;
  wire Tiger4NSC_1_NFCInterface_WriteReady;
  wire Tiger4NSC_1_NFCInterface_WriteValid;
  wire Tiger4NSC_1_SharedKESInterface_CSAvailable;
  wire [1:0]Tiger4NSC_1_SharedKESInterface_CorrectionFail;
  wire [1:0]Tiger4NSC_1_SharedKESInterface_DecodeNeeded;
  wire [359:0]Tiger4NSC_1_SharedKESInterface_ELPCoefficients;
  wire [17:0]Tiger4NSC_1_SharedKESInterface_ErrorCount;
  wire [1:0]Tiger4NSC_1_SharedKESInterface_ErrorDetectionEnd;
  wire [1:0]Tiger4NSC_1_SharedKESInterface_ErroredChunk;
  wire Tiger4NSC_1_SharedKESInterface_IntraSharedKESEnd;
  wire Tiger4NSC_1_SharedKESInterface_SharedKESReady;
  wire [647:0]Tiger4NSC_1_SharedKESInterface_Syndromes;
  wire [255:0]Tiger4NSC_1_uROMInterface_ADDR;
  wire Tiger4NSC_1_uROMInterface_CLK;
  wire [63:0]Tiger4NSC_1_uROMInterface_DIN;
  wire [63:0]Tiger4NSC_1_uROMInterface_DOUT;
  wire Tiger4NSC_1_uROMInterface_EN;
  wire Tiger4NSC_1_uROMInterface_RST;
  wire Tiger4NSC_1_uROMInterface_WE;
  wire V2NFC100DDR_0_O_NAND_ALE;
  wire [7:0]V2NFC100DDR_0_O_NAND_CE;
  wire V2NFC100DDR_0_O_NAND_CLE;
  wire V2NFC100DDR_0_O_NAND_RE_N;
  wire V2NFC100DDR_0_O_NAND_RE_P;
  wire V2NFC100DDR_0_O_NAND_WE;
  wire V2NFC100DDR_0_O_NAND_WP;
  wire V2NFC100DDR_1_O_NAND_ALE;
  wire [7:0]V2NFC100DDR_1_O_NAND_CE;
  wire V2NFC100DDR_1_O_NAND_CLE;
  wire V2NFC100DDR_1_O_NAND_RE_N;
  wire V2NFC100DDR_1_O_NAND_RE_P;
  wire V2NFC100DDR_1_O_NAND_WE;
  wire V2NFC100DDR_1_O_NAND_WP;
  wire VCC_1;
  wire [31:0]axi_interconnect_0_M00_AXI_ARADDR;
  wire [1:0]axi_interconnect_0_M00_AXI_ARBURST;
  wire [3:0]axi_interconnect_0_M00_AXI_ARCACHE;
  wire [0:0]axi_interconnect_0_M00_AXI_ARID;
  wire [3:0]axi_interconnect_0_M00_AXI_ARLEN;
  wire [1:0]axi_interconnect_0_M00_AXI_ARLOCK;
  wire [2:0]axi_interconnect_0_M00_AXI_ARPROT;
  wire [3:0]axi_interconnect_0_M00_AXI_ARQOS;
  wire axi_interconnect_0_M00_AXI_ARREADY;
  wire [2:0]axi_interconnect_0_M00_AXI_ARSIZE;
  wire axi_interconnect_0_M00_AXI_ARVALID;
  wire [31:0]axi_interconnect_0_M00_AXI_AWADDR;
  wire [1:0]axi_interconnect_0_M00_AXI_AWBURST;
  wire [3:0]axi_interconnect_0_M00_AXI_AWCACHE;
  wire [0:0]axi_interconnect_0_M00_AXI_AWID;
  wire [3:0]axi_interconnect_0_M00_AXI_AWLEN;
  wire [1:0]axi_interconnect_0_M00_AXI_AWLOCK;
  wire [2:0]axi_interconnect_0_M00_AXI_AWPROT;
  wire [3:0]axi_interconnect_0_M00_AXI_AWQOS;
  wire axi_interconnect_0_M00_AXI_AWREADY;
  wire [2:0]axi_interconnect_0_M00_AXI_AWSIZE;
  wire axi_interconnect_0_M00_AXI_AWVALID;
  wire [5:0]axi_interconnect_0_M00_AXI_BID;
  wire axi_interconnect_0_M00_AXI_BREADY;
  wire [1:0]axi_interconnect_0_M00_AXI_BRESP;
  wire axi_interconnect_0_M00_AXI_BVALID;
  wire [63:0]axi_interconnect_0_M00_AXI_RDATA;
  wire [5:0]axi_interconnect_0_M00_AXI_RID;
  wire axi_interconnect_0_M00_AXI_RLAST;
  wire axi_interconnect_0_M00_AXI_RREADY;
  wire [1:0]axi_interconnect_0_M00_AXI_RRESP;
  wire axi_interconnect_0_M00_AXI_RVALID;
  wire [63:0]axi_interconnect_0_M00_AXI_WDATA;
  wire [0:0]axi_interconnect_0_M00_AXI_WID;
  wire axi_interconnect_0_M00_AXI_WLAST;
  wire axi_interconnect_0_M00_AXI_WREADY;
  wire [7:0]axi_interconnect_0_M00_AXI_WSTRB;
  wire axi_interconnect_0_M00_AXI_WVALID;
  wire pcie_perst_n_1;
  wire pcie_ref_clk_n_1;
  wire pcie_ref_clk_p_1;
  wire [7:0]pcie_rx_n_1;
  wire [7:0]pcie_rx_p_1;
  wire [0:0]proc_sys_reset_0_peripheral_reset;
  wire [0:0]proc_sys_reset_2_peripheral_aresetn;
  wire [14:0]processing_system7_0_DDR_ADDR;
  wire [2:0]processing_system7_0_DDR_BA;
  wire processing_system7_0_DDR_CAS_N;
  wire processing_system7_0_DDR_CKE;
  wire processing_system7_0_DDR_CK_N;
  wire processing_system7_0_DDR_CK_P;
  wire processing_system7_0_DDR_CS_N;
  wire [3:0]processing_system7_0_DDR_DM;
  wire [31:0]processing_system7_0_DDR_DQ;
  wire [3:0]processing_system7_0_DDR_DQS_N;
  wire [3:0]processing_system7_0_DDR_DQS_P;
  wire processing_system7_0_DDR_ODT;
  wire processing_system7_0_DDR_RAS_N;
  wire processing_system7_0_DDR_RESET_N;
  wire processing_system7_0_DDR_WE_N;
  wire processing_system7_0_FIXED_IO_DDR_VRN;
  wire processing_system7_0_FIXED_IO_DDR_VRP;
  wire [53:0]processing_system7_0_FIXED_IO_MIO;
  wire processing_system7_0_FIXED_IO_PS_CLK;
  wire processing_system7_0_FIXED_IO_PS_PORB;
  wire processing_system7_0_FIXED_IO_PS_SRSTB;

  assign I_NAND_RB_1 = I_NAND_CH0_RB[7:0];
  assign I_NAND_RB_2 = I_NAND_CH1_RB[7:0];
  assign O_NAND_CH0_ALE = V2NFC100DDR_0_O_NAND_ALE;
  assign O_NAND_CH0_CE[7:0] = V2NFC100DDR_0_O_NAND_CE;
  assign O_NAND_CH0_CLE = V2NFC100DDR_0_O_NAND_CLE;
  assign O_NAND_CH0_RE_N = V2NFC100DDR_0_O_NAND_RE_N;
  assign O_NAND_CH0_RE_P = V2NFC100DDR_0_O_NAND_RE_P;
  assign O_NAND_CH0_WE = V2NFC100DDR_0_O_NAND_WE;
  assign O_NAND_CH0_WP = V2NFC100DDR_0_O_NAND_WP;
  assign O_NAND_CH1_ALE = V2NFC100DDR_1_O_NAND_ALE;
  assign O_NAND_CH1_CE[7:0] = V2NFC100DDR_1_O_NAND_CE;
  assign O_NAND_CH1_CLE = V2NFC100DDR_1_O_NAND_CLE;
  assign O_NAND_CH1_RE_N = V2NFC100DDR_1_O_NAND_RE_N;
  assign O_NAND_CH1_RE_P = V2NFC100DDR_1_O_NAND_RE_P;
  assign O_NAND_CH1_WE = V2NFC100DDR_1_O_NAND_WE;
  assign O_NAND_CH1_WP = V2NFC100DDR_1_O_NAND_WP;
  assign pcie_perst_n_1 = pcie_perst_n;
  assign pcie_ref_clk_n_1 = pcie_ref_clk_n;
  assign pcie_ref_clk_p_1 = pcie_ref_clk_p;
  assign pcie_rx_n_1 = pcie_rx_n[7:0];
  assign pcie_rx_p_1 = pcie_rx_p[7:0];
  assign pcie_tx_n[7:0] = NVMeHostController_0_pcie_tx_n;
  assign pcie_tx_p[7:0] = NVMeHostController_0_pcie_tx_p;
OpenSSD2_clk_wiz_0_0 CH0MMCMC1H200
       (.clk_in1(PS_FCLK_CLK0),
        .clk_out1(CH0MMCMC1H200_clk_out1),
        .reset(proc_sys_reset_0_peripheral_reset));
OpenSSD2_blk_mem_gen_0_0 Dispatcher_uCode_0
       (.addra(Tiger4NSC_0_uROMInterface_ADDR[7:0]),
        .clka(Tiger4NSC_0_uROMInterface_CLK),
        .dina(Tiger4NSC_0_uROMInterface_DIN),
        .douta(Tiger4NSC_0_uROMInterface_DOUT),
        .ena(Tiger4NSC_0_uROMInterface_EN),
        .rsta(Tiger4NSC_0_uROMInterface_RST),
        .wea(Tiger4NSC_0_uROMInterface_WE));
OpenSSD2_Dispatcher_uCode_0_0 Dispatcher_uCode_1
       (.addra(Tiger4NSC_1_uROMInterface_ADDR[7:0]),
        .clka(Tiger4NSC_1_uROMInterface_CLK),
        .dina(Tiger4NSC_1_uROMInterface_DIN),
        .douta(Tiger4NSC_1_uROMInterface_DOUT),
        .ena(Tiger4NSC_1_uROMInterface_EN),
        .rsta(Tiger4NSC_1_uROMInterface_RST),
        .wea(Tiger4NSC_1_uROMInterface_WE));
GND GND
       (.G(GND_1));
OpenSSD2_axi_interconnect_0_0 GPIC0
       (.ACLK(PS_FCLK_CLK0),
        .ARESETN(ARESETN_1),
        .M00_ACLK(PS_FCLK_CLK0),
        .M00_ARESETN(M00_ARESETN_1),
        .M00_AXI_araddr(GPIC0_M00_AXI_ARADDR),
        .M00_AXI_arprot(GPIC0_M00_AXI_ARPROT),
        .M00_AXI_arready(GPIC0_M00_AXI_ARREADY),
        .M00_AXI_arvalid(GPIC0_M00_AXI_ARVALID),
        .M00_AXI_awaddr(GPIC0_M00_AXI_AWADDR),
        .M00_AXI_awprot(GPIC0_M00_AXI_AWPROT),
        .M00_AXI_awready(GPIC0_M00_AXI_AWREADY),
        .M00_AXI_awvalid(GPIC0_M00_AXI_AWVALID),
        .M00_AXI_bready(GPIC0_M00_AXI_BREADY),
        .M00_AXI_bresp(GPIC0_M00_AXI_BRESP),
        .M00_AXI_bvalid(GPIC0_M00_AXI_BVALID),
        .M00_AXI_rdata(GPIC0_M00_AXI_RDATA),
        .M00_AXI_rready(GPIC0_M00_AXI_RREADY),
        .M00_AXI_rresp(GPIC0_M00_AXI_RRESP),
        .M00_AXI_rvalid(GPIC0_M00_AXI_RVALID),
        .M00_AXI_wdata(GPIC0_M00_AXI_WDATA),
        .M00_AXI_wready(GPIC0_M00_AXI_WREADY),
        .M00_AXI_wstrb(GPIC0_M00_AXI_WSTRB),
        .M00_AXI_wvalid(GPIC0_M00_AXI_WVALID),
        .M01_ACLK(PS_FCLK_CLK0),
        .M01_ARESETN(M00_ARESETN_1),
        .M01_AXI_araddr(GPIC0_M01_AXI_ARADDR),
        .M01_AXI_arprot(GPIC0_M01_AXI_ARPROT),
        .M01_AXI_arready(GPIC0_M01_AXI_ARREADY),
        .M01_AXI_arvalid(GPIC0_M01_AXI_ARVALID),
        .M01_AXI_awaddr(GPIC0_M01_AXI_AWADDR),
        .M01_AXI_awprot(GPIC0_M01_AXI_AWPROT),
        .M01_AXI_awready(GPIC0_M01_AXI_AWREADY),
        .M01_AXI_awvalid(GPIC0_M01_AXI_AWVALID),
        .M01_AXI_bready(GPIC0_M01_AXI_BREADY),
        .M01_AXI_bresp(GPIC0_M01_AXI_BRESP),
        .M01_AXI_bvalid(GPIC0_M01_AXI_BVALID),
        .M01_AXI_rdata(GPIC0_M01_AXI_RDATA),
        .M01_AXI_rready(GPIC0_M01_AXI_RREADY),
        .M01_AXI_rresp(GPIC0_M01_AXI_RRESP),
        .M01_AXI_rvalid(GPIC0_M01_AXI_RVALID),
        .M01_AXI_wdata(GPIC0_M01_AXI_WDATA),
        .M01_AXI_wready(GPIC0_M01_AXI_WREADY),
        .M01_AXI_wstrb(GPIC0_M01_AXI_WSTRB),
        .M01_AXI_wvalid(GPIC0_M01_AXI_WVALID),
        .S00_ACLK(PS_FCLK_CLK0),
        .S00_ARESETN(M00_ARESETN_1),
        .S00_AXI_araddr(PS_M_AXI_GP0_ARADDR),
        .S00_AXI_arburst(PS_M_AXI_GP0_ARBURST),
        .S00_AXI_arcache(PS_M_AXI_GP0_ARCACHE),
        .S00_AXI_arid(PS_M_AXI_GP0_ARID),
        .S00_AXI_arlen(PS_M_AXI_GP0_ARLEN),
        .S00_AXI_arlock(PS_M_AXI_GP0_ARLOCK),
        .S00_AXI_arprot(PS_M_AXI_GP0_ARPROT),
        .S00_AXI_arqos(PS_M_AXI_GP0_ARQOS),
        .S00_AXI_arready(PS_M_AXI_GP0_ARREADY),
        .S00_AXI_arsize(PS_M_AXI_GP0_ARSIZE),
        .S00_AXI_arvalid(PS_M_AXI_GP0_ARVALID),
        .S00_AXI_awaddr(PS_M_AXI_GP0_AWADDR),
        .S00_AXI_awburst(PS_M_AXI_GP0_AWBURST),
        .S00_AXI_awcache(PS_M_AXI_GP0_AWCACHE),
        .S00_AXI_awid(PS_M_AXI_GP0_AWID),
        .S00_AXI_awlen(PS_M_AXI_GP0_AWLEN),
        .S00_AXI_awlock(PS_M_AXI_GP0_AWLOCK),
        .S00_AXI_awprot(PS_M_AXI_GP0_AWPROT),
        .S00_AXI_awqos(PS_M_AXI_GP0_AWQOS),
        .S00_AXI_awready(PS_M_AXI_GP0_AWREADY),
        .S00_AXI_awsize(PS_M_AXI_GP0_AWSIZE),
        .S00_AXI_awvalid(PS_M_AXI_GP0_AWVALID),
        .S00_AXI_bid(PS_M_AXI_GP0_BID),
        .S00_AXI_bready(PS_M_AXI_GP0_BREADY),
        .S00_AXI_bresp(PS_M_AXI_GP0_BRESP),
        .S00_AXI_bvalid(PS_M_AXI_GP0_BVALID),
        .S00_AXI_rdata(PS_M_AXI_GP0_RDATA),
        .S00_AXI_rid(PS_M_AXI_GP0_RID),
        .S00_AXI_rlast(PS_M_AXI_GP0_RLAST),
        .S00_AXI_rready(PS_M_AXI_GP0_RREADY),
        .S00_AXI_rresp(PS_M_AXI_GP0_RRESP),
        .S00_AXI_rvalid(PS_M_AXI_GP0_RVALID),
        .S00_AXI_wdata(PS_M_AXI_GP0_WDATA),
        .S00_AXI_wid(PS_M_AXI_GP0_WID),
        .S00_AXI_wlast(PS_M_AXI_GP0_WLAST),
        .S00_AXI_wready(PS_M_AXI_GP0_WREADY),
        .S00_AXI_wstrb(PS_M_AXI_GP0_WSTRB),
        .S00_AXI_wvalid(PS_M_AXI_GP0_WVALID));
OpenSSD2_axi_interconnect_0_2 GPIC1
       (.ACLK(PS_FCLK_CLK2),
        .ARESETN(ARESETN_3),
        .M00_ACLK(PS_FCLK_CLK2),
        .M00_ARESETN(proc_sys_reset_2_peripheral_aresetn),
        .M00_AXI_araddr(GPIC1_M00_AXI_ARADDR),
        .M00_AXI_arprot(GPIC1_M00_AXI_ARPROT),
        .M00_AXI_arready(GPIC1_M00_AXI_ARREADY),
        .M00_AXI_arvalid(GPIC1_M00_AXI_ARVALID),
        .M00_AXI_awaddr(GPIC1_M00_AXI_AWADDR),
        .M00_AXI_awprot(GPIC1_M00_AXI_AWPROT),
        .M00_AXI_awready(GPIC1_M00_AXI_AWREADY),
        .M00_AXI_awvalid(GPIC1_M00_AXI_AWVALID),
        .M00_AXI_bready(GPIC1_M00_AXI_BREADY),
        .M00_AXI_bresp(GPIC1_M00_AXI_BRESP),
        .M00_AXI_bvalid(GPIC1_M00_AXI_BVALID),
        .M00_AXI_rdata(GPIC1_M00_AXI_RDATA),
        .M00_AXI_rready(GPIC1_M00_AXI_RREADY),
        .M00_AXI_rresp(GPIC1_M00_AXI_RRESP),
        .M00_AXI_rvalid(GPIC1_M00_AXI_RVALID),
        .M00_AXI_wdata(GPIC1_M00_AXI_WDATA),
        .M00_AXI_wready(GPIC1_M00_AXI_WREADY),
        .M00_AXI_wstrb(GPIC1_M00_AXI_WSTRB),
        .M00_AXI_wvalid(GPIC1_M00_AXI_WVALID),
        .S00_ACLK(PS_FCLK_CLK2),
        .S00_ARESETN(proc_sys_reset_2_peripheral_aresetn),
        .S00_AXI_araddr(S00_AXI_2_ARADDR),
        .S00_AXI_arburst(S00_AXI_2_ARBURST),
        .S00_AXI_arcache(S00_AXI_2_ARCACHE),
        .S00_AXI_arid(S00_AXI_2_ARID),
        .S00_AXI_arlen(S00_AXI_2_ARLEN),
        .S00_AXI_arlock(S00_AXI_2_ARLOCK),
        .S00_AXI_arprot(S00_AXI_2_ARPROT),
        .S00_AXI_arqos(S00_AXI_2_ARQOS),
        .S00_AXI_arready(S00_AXI_2_ARREADY),
        .S00_AXI_arsize(S00_AXI_2_ARSIZE),
        .S00_AXI_arvalid(S00_AXI_2_ARVALID),
        .S00_AXI_awaddr(S00_AXI_2_AWADDR),
        .S00_AXI_awburst(S00_AXI_2_AWBURST),
        .S00_AXI_awcache(S00_AXI_2_AWCACHE),
        .S00_AXI_awid(S00_AXI_2_AWID),
        .S00_AXI_awlen(S00_AXI_2_AWLEN),
        .S00_AXI_awlock(S00_AXI_2_AWLOCK),
        .S00_AXI_awprot(S00_AXI_2_AWPROT),
        .S00_AXI_awqos(S00_AXI_2_AWQOS),
        .S00_AXI_awready(S00_AXI_2_AWREADY),
        .S00_AXI_awsize(S00_AXI_2_AWSIZE),
        .S00_AXI_awvalid(S00_AXI_2_AWVALID),
        .S00_AXI_bid(S00_AXI_2_BID),
        .S00_AXI_bready(S00_AXI_2_BREADY),
        .S00_AXI_bresp(S00_AXI_2_BRESP),
        .S00_AXI_bvalid(S00_AXI_2_BVALID),
        .S00_AXI_rdata(S00_AXI_2_RDATA),
        .S00_AXI_rid(S00_AXI_2_RID),
        .S00_AXI_rlast(S00_AXI_2_RLAST),
        .S00_AXI_rready(S00_AXI_2_RREADY),
        .S00_AXI_rresp(S00_AXI_2_RRESP),
        .S00_AXI_rvalid(S00_AXI_2_RVALID),
        .S00_AXI_wdata(S00_AXI_2_WDATA),
        .S00_AXI_wid(S00_AXI_2_WID),
        .S00_AXI_wlast(S00_AXI_2_WLAST),
        .S00_AXI_wready(S00_AXI_2_WREADY),
        .S00_AXI_wstrb(S00_AXI_2_WSTRB),
        .S00_AXI_wvalid(S00_AXI_2_WVALID));
OpenSSD2_axi_interconnect_0_1 HPIC3
       (.ACLK(PS_FCLK_CLK3),
        .ARESETN(ARESETN_2),
        .M00_ACLK(PS_FCLK_CLK3),
        .M00_ARESETN(M00_ARESETN_2),
        .M00_AXI_araddr(HPIC3_M00_AXI_ARADDR),
        .M00_AXI_arburst(HPIC3_M00_AXI_ARBURST),
        .M00_AXI_arcache(HPIC3_M00_AXI_ARCACHE),
        .M00_AXI_arid(HPIC3_M00_AXI_ARID),
        .M00_AXI_arlen(HPIC3_M00_AXI_ARLEN),
        .M00_AXI_arlock(HPIC3_M00_AXI_ARLOCK),
        .M00_AXI_arprot(HPIC3_M00_AXI_ARPROT),
        .M00_AXI_arqos(HPIC3_M00_AXI_ARQOS),
        .M00_AXI_arready(HPIC3_M00_AXI_ARREADY),
        .M00_AXI_arsize(HPIC3_M00_AXI_ARSIZE),
        .M00_AXI_arvalid(HPIC3_M00_AXI_ARVALID),
        .M00_AXI_awaddr(HPIC3_M00_AXI_AWADDR),
        .M00_AXI_awburst(HPIC3_M00_AXI_AWBURST),
        .M00_AXI_awcache(HPIC3_M00_AXI_AWCACHE),
        .M00_AXI_awid(HPIC3_M00_AXI_AWID),
        .M00_AXI_awlen(HPIC3_M00_AXI_AWLEN),
        .M00_AXI_awlock(HPIC3_M00_AXI_AWLOCK),
        .M00_AXI_awprot(HPIC3_M00_AXI_AWPROT),
        .M00_AXI_awqos(HPIC3_M00_AXI_AWQOS),
        .M00_AXI_awready(HPIC3_M00_AXI_AWREADY),
        .M00_AXI_awsize(HPIC3_M00_AXI_AWSIZE),
        .M00_AXI_awvalid(HPIC3_M00_AXI_AWVALID),
        .M00_AXI_bid(HPIC3_M00_AXI_BID[0]),
        .M00_AXI_bready(HPIC3_M00_AXI_BREADY),
        .M00_AXI_bresp(HPIC3_M00_AXI_BRESP),
        .M00_AXI_bvalid(HPIC3_M00_AXI_BVALID),
        .M00_AXI_rdata(HPIC3_M00_AXI_RDATA),
        .M00_AXI_rid(HPIC3_M00_AXI_RID[0]),
        .M00_AXI_rlast(HPIC3_M00_AXI_RLAST),
        .M00_AXI_rready(HPIC3_M00_AXI_RREADY),
        .M00_AXI_rresp(HPIC3_M00_AXI_RRESP),
        .M00_AXI_rvalid(HPIC3_M00_AXI_RVALID),
        .M00_AXI_wdata(HPIC3_M00_AXI_WDATA),
        .M00_AXI_wid(HPIC3_M00_AXI_WID),
        .M00_AXI_wlast(HPIC3_M00_AXI_WLAST),
        .M00_AXI_wready(HPIC3_M00_AXI_WREADY),
        .M00_AXI_wstrb(HPIC3_M00_AXI_WSTRB),
        .M00_AXI_wvalid(HPIC3_M00_AXI_WVALID),
        .S00_ACLK(PS_FCLK_CLK3),
        .S00_ARESETN(M00_ARESETN_2),
        .S00_AXI_araddr(NVMeHostController_0_m0_axi_ARADDR),
        .S00_AXI_arburst(NVMeHostController_0_m0_axi_ARBURST),
        .S00_AXI_arcache(NVMeHostController_0_m0_axi_ARCACHE),
        .S00_AXI_arid(NVMeHostController_0_m0_axi_ARID),
        .S00_AXI_arlen(NVMeHostController_0_m0_axi_ARLEN),
        .S00_AXI_arlock(NVMeHostController_0_m0_axi_ARLOCK[0]),
        .S00_AXI_arprot(NVMeHostController_0_m0_axi_ARPROT),
        .S00_AXI_arqos(NVMeHostController_0_m0_axi_ARQOS),
        .S00_AXI_arready(NVMeHostController_0_m0_axi_ARREADY),
        .S00_AXI_arregion(NVMeHostController_0_m0_axi_ARREGION),
        .S00_AXI_arsize(NVMeHostController_0_m0_axi_ARSIZE),
        .S00_AXI_aruser(NVMeHostController_0_m0_axi_ARUSER),
        .S00_AXI_arvalid(NVMeHostController_0_m0_axi_ARVALID),
        .S00_AXI_awaddr(NVMeHostController_0_m0_axi_AWADDR),
        .S00_AXI_awburst(NVMeHostController_0_m0_axi_AWBURST),
        .S00_AXI_awcache(NVMeHostController_0_m0_axi_AWCACHE),
        .S00_AXI_awid(NVMeHostController_0_m0_axi_AWID),
        .S00_AXI_awlen(NVMeHostController_0_m0_axi_AWLEN),
        .S00_AXI_awlock(NVMeHostController_0_m0_axi_AWLOCK[0]),
        .S00_AXI_awprot(NVMeHostController_0_m0_axi_AWPROT),
        .S00_AXI_awqos(NVMeHostController_0_m0_axi_AWQOS),
        .S00_AXI_awready(NVMeHostController_0_m0_axi_AWREADY),
        .S00_AXI_awregion(NVMeHostController_0_m0_axi_AWREGION),
        .S00_AXI_awsize(NVMeHostController_0_m0_axi_AWSIZE),
        .S00_AXI_awuser(NVMeHostController_0_m0_axi_AWUSER),
        .S00_AXI_awvalid(NVMeHostController_0_m0_axi_AWVALID),
        .S00_AXI_bid(NVMeHostController_0_m0_axi_BID),
        .S00_AXI_bready(NVMeHostController_0_m0_axi_BREADY),
        .S00_AXI_bresp(NVMeHostController_0_m0_axi_BRESP),
        .S00_AXI_bvalid(NVMeHostController_0_m0_axi_BVALID),
        .S00_AXI_rdata(NVMeHostController_0_m0_axi_RDATA),
        .S00_AXI_rid(NVMeHostController_0_m0_axi_RID),
        .S00_AXI_rlast(NVMeHostController_0_m0_axi_RLAST),
        .S00_AXI_rready(NVMeHostController_0_m0_axi_RREADY),
        .S00_AXI_rresp(NVMeHostController_0_m0_axi_RRESP),
        .S00_AXI_ruser(NVMeHostController_0_m0_axi_RUSER),
        .S00_AXI_rvalid(NVMeHostController_0_m0_axi_RVALID),
        .S00_AXI_wdata(NVMeHostController_0_m0_axi_WDATA),
        .S00_AXI_wlast(NVMeHostController_0_m0_axi_WLAST),
        .S00_AXI_wready(NVMeHostController_0_m0_axi_WREADY),
        .S00_AXI_wstrb(NVMeHostController_0_m0_axi_WSTRB),
        .S00_AXI_wuser(NVMeHostController_0_m0_axi_WUSER),
        .S00_AXI_wvalid(NVMeHostController_0_m0_axi_WVALID));
OpenSSD2_NVMeHostController_0_0 NVMeHostController_0
       (.dev_irq_assert(NVMeHostController_0_dev_irq_assert),
        .m0_axi_aclk(PS_FCLK_CLK3),
        .m0_axi_araddr(NVMeHostController_0_m0_axi_ARADDR),
        .m0_axi_arburst(NVMeHostController_0_m0_axi_ARBURST),
        .m0_axi_arcache(NVMeHostController_0_m0_axi_ARCACHE),
        .m0_axi_aresetn(M00_ARESETN_2),
        .m0_axi_arid(NVMeHostController_0_m0_axi_ARID),
        .m0_axi_arlen(NVMeHostController_0_m0_axi_ARLEN),
        .m0_axi_arlock(NVMeHostController_0_m0_axi_ARLOCK),
        .m0_axi_arprot(NVMeHostController_0_m0_axi_ARPROT),
        .m0_axi_arqos(NVMeHostController_0_m0_axi_ARQOS),
        .m0_axi_arready(NVMeHostController_0_m0_axi_ARREADY),
        .m0_axi_arregion(NVMeHostController_0_m0_axi_ARREGION),
        .m0_axi_arsize(NVMeHostController_0_m0_axi_ARSIZE),
        .m0_axi_aruser(NVMeHostController_0_m0_axi_ARUSER),
        .m0_axi_arvalid(NVMeHostController_0_m0_axi_ARVALID),
        .m0_axi_awaddr(NVMeHostController_0_m0_axi_AWADDR),
        .m0_axi_awburst(NVMeHostController_0_m0_axi_AWBURST),
        .m0_axi_awcache(NVMeHostController_0_m0_axi_AWCACHE),
        .m0_axi_awid(NVMeHostController_0_m0_axi_AWID),
        .m0_axi_awlen(NVMeHostController_0_m0_axi_AWLEN),
        .m0_axi_awlock(NVMeHostController_0_m0_axi_AWLOCK),
        .m0_axi_awprot(NVMeHostController_0_m0_axi_AWPROT),
        .m0_axi_awqos(NVMeHostController_0_m0_axi_AWQOS),
        .m0_axi_awready(NVMeHostController_0_m0_axi_AWREADY),
        .m0_axi_awregion(NVMeHostController_0_m0_axi_AWREGION),
        .m0_axi_awsize(NVMeHostController_0_m0_axi_AWSIZE),
        .m0_axi_awuser(NVMeHostController_0_m0_axi_AWUSER),
        .m0_axi_awvalid(NVMeHostController_0_m0_axi_AWVALID),
        .m0_axi_bid(NVMeHostController_0_m0_axi_BID),
        .m0_axi_bready(NVMeHostController_0_m0_axi_BREADY),
        .m0_axi_bresp(NVMeHostController_0_m0_axi_BRESP),
        .m0_axi_buser(GND_1),
        .m0_axi_bvalid(NVMeHostController_0_m0_axi_BVALID),
        .m0_axi_rdata(NVMeHostController_0_m0_axi_RDATA),
        .m0_axi_rid(NVMeHostController_0_m0_axi_RID),
        .m0_axi_rlast(NVMeHostController_0_m0_axi_RLAST),
        .m0_axi_rready(NVMeHostController_0_m0_axi_RREADY),
        .m0_axi_rresp(NVMeHostController_0_m0_axi_RRESP),
        .m0_axi_ruser(NVMeHostController_0_m0_axi_RUSER),
        .m0_axi_rvalid(NVMeHostController_0_m0_axi_RVALID),
        .m0_axi_wdata(NVMeHostController_0_m0_axi_WDATA),
        .m0_axi_wlast(NVMeHostController_0_m0_axi_WLAST),
        .m0_axi_wready(NVMeHostController_0_m0_axi_WREADY),
        .m0_axi_wstrb(NVMeHostController_0_m0_axi_WSTRB),
        .m0_axi_wuser(NVMeHostController_0_m0_axi_WUSER),
        .m0_axi_wvalid(NVMeHostController_0_m0_axi_WVALID),
        .pcie_perst_n(pcie_perst_n_1),
        .pcie_ref_clk_n(pcie_ref_clk_n_1),
        .pcie_ref_clk_p(pcie_ref_clk_p_1),
        .pcie_rx_n(pcie_rx_n_1),
        .pcie_rx_p(pcie_rx_p_1),
        .pcie_tx_n(NVMeHostController_0_pcie_tx_n),
        .pcie_tx_p(NVMeHostController_0_pcie_tx_p),
        .s0_axi_aclk(PS_FCLK_CLK2),
        .s0_axi_araddr(GPIC1_M00_AXI_ARADDR),
        .s0_axi_aresetn(proc_sys_reset_2_peripheral_aresetn),
        .s0_axi_arprot(GPIC1_M00_AXI_ARPROT),
        .s0_axi_arready(GPIC1_M00_AXI_ARREADY),
        .s0_axi_arvalid(GPIC1_M00_AXI_ARVALID),
        .s0_axi_awaddr(GPIC1_M00_AXI_AWADDR),
        .s0_axi_awprot(GPIC1_M00_AXI_AWPROT),
        .s0_axi_awready(GPIC1_M00_AXI_AWREADY),
        .s0_axi_awvalid(GPIC1_M00_AXI_AWVALID),
        .s0_axi_bready(GPIC1_M00_AXI_BREADY),
        .s0_axi_bresp(GPIC1_M00_AXI_BRESP),
        .s0_axi_bvalid(GPIC1_M00_AXI_BVALID),
        .s0_axi_rdata(GPIC1_M00_AXI_RDATA),
        .s0_axi_rready(GPIC1_M00_AXI_RREADY),
        .s0_axi_rresp(GPIC1_M00_AXI_RRESP),
        .s0_axi_rvalid(GPIC1_M00_AXI_RVALID),
        .s0_axi_wdata(GPIC1_M00_AXI_WDATA),
        .s0_axi_wready(GPIC1_M00_AXI_WREADY),
        .s0_axi_wstrb(GPIC1_M00_AXI_WSTRB),
        .s0_axi_wvalid(GPIC1_M00_AXI_WVALID));
OpenSSD2_processing_system7_0_0 PS
       (.DDR_Addr(DDR_addr[14:0]),
        .DDR_BankAddr(DDR_ba[2:0]),
        .DDR_CAS_n(DDR_cas_n),
        .DDR_CKE(DDR_cke),
        .DDR_CS_n(DDR_cs_n),
        .DDR_Clk(DDR_ck_p),
        .DDR_Clk_n(DDR_ck_n),
        .DDR_DM(DDR_dm[3:0]),
        .DDR_DQ(DDR_dq[31:0]),
        .DDR_DQS(DDR_dqs_p[3:0]),
        .DDR_DQS_n(DDR_dqs_n[3:0]),
        .DDR_DRSTB(DDR_reset_n),
        .DDR_ODT(DDR_odt),
        .DDR_RAS_n(DDR_ras_n),
        .DDR_VRN(FIXED_IO_ddr_vrn),
        .DDR_VRP(FIXED_IO_ddr_vrp),
        .DDR_WEB(DDR_we_n),
        .FCLK_CLK0(PS_FCLK_CLK0),
        .FCLK_CLK2(PS_FCLK_CLK2),
        .FCLK_CLK3(PS_FCLK_CLK3),
        .FCLK_RESET0_N(PS_FCLK_RESET0_N),
        .FCLK_RESET2_N(PS_FCLK_RESET2_N),
        .FCLK_RESET3_N(PS_FCLK_RESET3_N),
        .IRQ_F2P(NVMeHostController_0_dev_irq_assert),
        .MIO(FIXED_IO_mio[53:0]),
        .M_AXI_GP0_ACLK(PS_FCLK_CLK0),
        .M_AXI_GP0_ARADDR(PS_M_AXI_GP0_ARADDR),
        .M_AXI_GP0_ARBURST(PS_M_AXI_GP0_ARBURST),
        .M_AXI_GP0_ARCACHE(PS_M_AXI_GP0_ARCACHE),
        .M_AXI_GP0_ARID(PS_M_AXI_GP0_ARID),
        .M_AXI_GP0_ARLEN(PS_M_AXI_GP0_ARLEN),
        .M_AXI_GP0_ARLOCK(PS_M_AXI_GP0_ARLOCK),
        .M_AXI_GP0_ARPROT(PS_M_AXI_GP0_ARPROT),
        .M_AXI_GP0_ARQOS(PS_M_AXI_GP0_ARQOS),
        .M_AXI_GP0_ARREADY(PS_M_AXI_GP0_ARREADY),
        .M_AXI_GP0_ARSIZE(PS_M_AXI_GP0_ARSIZE),
        .M_AXI_GP0_ARVALID(PS_M_AXI_GP0_ARVALID),
        .M_AXI_GP0_AWADDR(PS_M_AXI_GP0_AWADDR),
        .M_AXI_GP0_AWBURST(PS_M_AXI_GP0_AWBURST),
        .M_AXI_GP0_AWCACHE(PS_M_AXI_GP0_AWCACHE),
        .M_AXI_GP0_AWID(PS_M_AXI_GP0_AWID),
        .M_AXI_GP0_AWLEN(PS_M_AXI_GP0_AWLEN),
        .M_AXI_GP0_AWLOCK(PS_M_AXI_GP0_AWLOCK),
        .M_AXI_GP0_AWPROT(PS_M_AXI_GP0_AWPROT),
        .M_AXI_GP0_AWQOS(PS_M_AXI_GP0_AWQOS),
        .M_AXI_GP0_AWREADY(PS_M_AXI_GP0_AWREADY),
        .M_AXI_GP0_AWSIZE(PS_M_AXI_GP0_AWSIZE),
        .M_AXI_GP0_AWVALID(PS_M_AXI_GP0_AWVALID),
        .M_AXI_GP0_BID(PS_M_AXI_GP0_BID),
        .M_AXI_GP0_BREADY(PS_M_AXI_GP0_BREADY),
        .M_AXI_GP0_BRESP(PS_M_AXI_GP0_BRESP),
        .M_AXI_GP0_BVALID(PS_M_AXI_GP0_BVALID),
        .M_AXI_GP0_RDATA(PS_M_AXI_GP0_RDATA),
        .M_AXI_GP0_RID(PS_M_AXI_GP0_RID),
        .M_AXI_GP0_RLAST(PS_M_AXI_GP0_RLAST),
        .M_AXI_GP0_RREADY(PS_M_AXI_GP0_RREADY),
        .M_AXI_GP0_RRESP(PS_M_AXI_GP0_RRESP),
        .M_AXI_GP0_RVALID(PS_M_AXI_GP0_RVALID),
        .M_AXI_GP0_WDATA(PS_M_AXI_GP0_WDATA),
        .M_AXI_GP0_WID(PS_M_AXI_GP0_WID),
        .M_AXI_GP0_WLAST(PS_M_AXI_GP0_WLAST),
        .M_AXI_GP0_WREADY(PS_M_AXI_GP0_WREADY),
        .M_AXI_GP0_WSTRB(PS_M_AXI_GP0_WSTRB),
        .M_AXI_GP0_WVALID(PS_M_AXI_GP0_WVALID),
        .M_AXI_GP1_ACLK(PS_FCLK_CLK2),
        .M_AXI_GP1_ARADDR(S00_AXI_2_ARADDR),
        .M_AXI_GP1_ARBURST(S00_AXI_2_ARBURST),
        .M_AXI_GP1_ARCACHE(S00_AXI_2_ARCACHE),
        .M_AXI_GP1_ARID(S00_AXI_2_ARID),
        .M_AXI_GP1_ARLEN(S00_AXI_2_ARLEN),
        .M_AXI_GP1_ARLOCK(S00_AXI_2_ARLOCK),
        .M_AXI_GP1_ARPROT(S00_AXI_2_ARPROT),
        .M_AXI_GP1_ARQOS(S00_AXI_2_ARQOS),
        .M_AXI_GP1_ARREADY(S00_AXI_2_ARREADY),
        .M_AXI_GP1_ARSIZE(S00_AXI_2_ARSIZE),
        .M_AXI_GP1_ARVALID(S00_AXI_2_ARVALID),
        .M_AXI_GP1_AWADDR(S00_AXI_2_AWADDR),
        .M_AXI_GP1_AWBURST(S00_AXI_2_AWBURST),
        .M_AXI_GP1_AWCACHE(S00_AXI_2_AWCACHE),
        .M_AXI_GP1_AWID(S00_AXI_2_AWID),
        .M_AXI_GP1_AWLEN(S00_AXI_2_AWLEN),
        .M_AXI_GP1_AWLOCK(S00_AXI_2_AWLOCK),
        .M_AXI_GP1_AWPROT(S00_AXI_2_AWPROT),
        .M_AXI_GP1_AWQOS(S00_AXI_2_AWQOS),
        .M_AXI_GP1_AWREADY(S00_AXI_2_AWREADY),
        .M_AXI_GP1_AWSIZE(S00_AXI_2_AWSIZE),
        .M_AXI_GP1_AWVALID(S00_AXI_2_AWVALID),
        .M_AXI_GP1_BID(S00_AXI_2_BID),
        .M_AXI_GP1_BREADY(S00_AXI_2_BREADY),
        .M_AXI_GP1_BRESP(S00_AXI_2_BRESP),
        .M_AXI_GP1_BVALID(S00_AXI_2_BVALID),
        .M_AXI_GP1_RDATA(S00_AXI_2_RDATA),
        .M_AXI_GP1_RID(S00_AXI_2_RID),
        .M_AXI_GP1_RLAST(S00_AXI_2_RLAST),
        .M_AXI_GP1_RREADY(S00_AXI_2_RREADY),
        .M_AXI_GP1_RRESP(S00_AXI_2_RRESP),
        .M_AXI_GP1_RVALID(S00_AXI_2_RVALID),
        .M_AXI_GP1_WDATA(S00_AXI_2_WDATA),
        .M_AXI_GP1_WID(S00_AXI_2_WID),
        .M_AXI_GP1_WLAST(S00_AXI_2_WLAST),
        .M_AXI_GP1_WREADY(S00_AXI_2_WREADY),
        .M_AXI_GP1_WSTRB(S00_AXI_2_WSTRB),
        .M_AXI_GP1_WVALID(S00_AXI_2_WVALID),
        .PS_CLK(FIXED_IO_ps_clk),
        .PS_PORB(FIXED_IO_ps_porb),
        .PS_SRSTB(FIXED_IO_ps_srstb),
        .S_AXI_HP0_ACLK(PS_FCLK_CLK3),
        .S_AXI_HP0_ARADDR(axi_interconnect_0_M00_AXI_ARADDR),
        .S_AXI_HP0_ARBURST(axi_interconnect_0_M00_AXI_ARBURST),
        .S_AXI_HP0_ARCACHE(axi_interconnect_0_M00_AXI_ARCACHE),
        .S_AXI_HP0_ARID(axi_interconnect_0_M00_AXI_ARID),
        .S_AXI_HP0_ARLEN(axi_interconnect_0_M00_AXI_ARLEN),
        .S_AXI_HP0_ARLOCK(axi_interconnect_0_M00_AXI_ARLOCK),
        .S_AXI_HP0_ARPROT(axi_interconnect_0_M00_AXI_ARPROT),
        .S_AXI_HP0_ARQOS(axi_interconnect_0_M00_AXI_ARQOS),
        .S_AXI_HP0_ARREADY(axi_interconnect_0_M00_AXI_ARREADY),
        .S_AXI_HP0_ARSIZE(axi_interconnect_0_M00_AXI_ARSIZE),
        .S_AXI_HP0_ARVALID(axi_interconnect_0_M00_AXI_ARVALID),
        .S_AXI_HP0_AWADDR(axi_interconnect_0_M00_AXI_AWADDR),
        .S_AXI_HP0_AWBURST(axi_interconnect_0_M00_AXI_AWBURST),
        .S_AXI_HP0_AWCACHE(axi_interconnect_0_M00_AXI_AWCACHE),
        .S_AXI_HP0_AWID(axi_interconnect_0_M00_AXI_AWID),
        .S_AXI_HP0_AWLEN(axi_interconnect_0_M00_AXI_AWLEN),
        .S_AXI_HP0_AWLOCK(axi_interconnect_0_M00_AXI_AWLOCK),
        .S_AXI_HP0_AWPROT(axi_interconnect_0_M00_AXI_AWPROT),
        .S_AXI_HP0_AWQOS(axi_interconnect_0_M00_AXI_AWQOS),
        .S_AXI_HP0_AWREADY(axi_interconnect_0_M00_AXI_AWREADY),
        .S_AXI_HP0_AWSIZE(axi_interconnect_0_M00_AXI_AWSIZE),
        .S_AXI_HP0_AWVALID(axi_interconnect_0_M00_AXI_AWVALID),
        .S_AXI_HP0_BID(axi_interconnect_0_M00_AXI_BID),
        .S_AXI_HP0_BREADY(axi_interconnect_0_M00_AXI_BREADY),
        .S_AXI_HP0_BRESP(axi_interconnect_0_M00_AXI_BRESP),
        .S_AXI_HP0_BVALID(axi_interconnect_0_M00_AXI_BVALID),
        .S_AXI_HP0_RDATA(axi_interconnect_0_M00_AXI_RDATA),
        .S_AXI_HP0_RDISSUECAP1_EN(GND_1),
        .S_AXI_HP0_RID(axi_interconnect_0_M00_AXI_RID),
        .S_AXI_HP0_RLAST(axi_interconnect_0_M00_AXI_RLAST),
        .S_AXI_HP0_RREADY(axi_interconnect_0_M00_AXI_RREADY),
        .S_AXI_HP0_RRESP(axi_interconnect_0_M00_AXI_RRESP),
        .S_AXI_HP0_RVALID(axi_interconnect_0_M00_AXI_RVALID),
        .S_AXI_HP0_WDATA(axi_interconnect_0_M00_AXI_WDATA),
        .S_AXI_HP0_WID(axi_interconnect_0_M00_AXI_WID),
        .S_AXI_HP0_WLAST(axi_interconnect_0_M00_AXI_WLAST),
        .S_AXI_HP0_WREADY(axi_interconnect_0_M00_AXI_WREADY),
        .S_AXI_HP0_WRISSUECAP1_EN(GND_1),
        .S_AXI_HP0_WSTRB(axi_interconnect_0_M00_AXI_WSTRB),
        .S_AXI_HP0_WVALID(axi_interconnect_0_M00_AXI_WVALID),
        .S_AXI_HP3_ACLK(PS_FCLK_CLK3),
        .S_AXI_HP3_ARADDR(HPIC3_M00_AXI_ARADDR),
        .S_AXI_HP3_ARBURST(HPIC3_M00_AXI_ARBURST),
        .S_AXI_HP3_ARCACHE(HPIC3_M00_AXI_ARCACHE),
        .S_AXI_HP3_ARID(HPIC3_M00_AXI_ARID),
        .S_AXI_HP3_ARLEN(HPIC3_M00_AXI_ARLEN),
        .S_AXI_HP3_ARLOCK(HPIC3_M00_AXI_ARLOCK),
        .S_AXI_HP3_ARPROT(HPIC3_M00_AXI_ARPROT),
        .S_AXI_HP3_ARQOS(HPIC3_M00_AXI_ARQOS),
        .S_AXI_HP3_ARREADY(HPIC3_M00_AXI_ARREADY),
        .S_AXI_HP3_ARSIZE(HPIC3_M00_AXI_ARSIZE),
        .S_AXI_HP3_ARVALID(HPIC3_M00_AXI_ARVALID),
        .S_AXI_HP3_AWADDR(HPIC3_M00_AXI_AWADDR),
        .S_AXI_HP3_AWBURST(HPIC3_M00_AXI_AWBURST),
        .S_AXI_HP3_AWCACHE(HPIC3_M00_AXI_AWCACHE),
        .S_AXI_HP3_AWID(HPIC3_M00_AXI_AWID),
        .S_AXI_HP3_AWLEN(HPIC3_M00_AXI_AWLEN),
        .S_AXI_HP3_AWLOCK(HPIC3_M00_AXI_AWLOCK),
        .S_AXI_HP3_AWPROT(HPIC3_M00_AXI_AWPROT),
        .S_AXI_HP3_AWQOS(HPIC3_M00_AXI_AWQOS),
        .S_AXI_HP3_AWREADY(HPIC3_M00_AXI_AWREADY),
        .S_AXI_HP3_AWSIZE(HPIC3_M00_AXI_AWSIZE),
        .S_AXI_HP3_AWVALID(HPIC3_M00_AXI_AWVALID),
        .S_AXI_HP3_BID(HPIC3_M00_AXI_BID),
        .S_AXI_HP3_BREADY(HPIC3_M00_AXI_BREADY),
        .S_AXI_HP3_BRESP(HPIC3_M00_AXI_BRESP),
        .S_AXI_HP3_BVALID(HPIC3_M00_AXI_BVALID),
        .S_AXI_HP3_RDATA(HPIC3_M00_AXI_RDATA),
        .S_AXI_HP3_RDISSUECAP1_EN(GND_1),
        .S_AXI_HP3_RID(HPIC3_M00_AXI_RID),
        .S_AXI_HP3_RLAST(HPIC3_M00_AXI_RLAST),
        .S_AXI_HP3_RREADY(HPIC3_M00_AXI_RREADY),
        .S_AXI_HP3_RRESP(HPIC3_M00_AXI_RRESP),
        .S_AXI_HP3_RVALID(HPIC3_M00_AXI_RVALID),
        .S_AXI_HP3_WDATA(HPIC3_M00_AXI_WDATA),
        .S_AXI_HP3_WID(HPIC3_M00_AXI_WID),
        .S_AXI_HP3_WLAST(HPIC3_M00_AXI_WLAST),
        .S_AXI_HP3_WREADY(HPIC3_M00_AXI_WREADY),
        .S_AXI_HP3_WRISSUECAP1_EN(GND_1),
        .S_AXI_HP3_WSTRB(HPIC3_M00_AXI_WSTRB),
        .S_AXI_HP3_WVALID(HPIC3_M00_AXI_WVALID),
        .USB0_VBUS_PWRFAULT(GND_1));
OpenSSD2_Tiger4NSC_0_0 Tiger4NSC_0
       (.C_ARADDR(GPIC0_M00_AXI_ARADDR),
        .C_ARPROT(GPIC0_M00_AXI_ARPROT),
        .C_ARREADY(GPIC0_M00_AXI_ARREADY),
        .C_ARVALID(GPIC0_M00_AXI_ARVALID),
        .C_AWADDR(GPIC0_M00_AXI_AWADDR),
        .C_AWPROT(GPIC0_M00_AXI_AWPROT),
        .C_AWREADY(GPIC0_M00_AXI_AWREADY),
        .C_AWVALID(GPIC0_M00_AXI_AWVALID),
        .C_BREADY(GPIC0_M00_AXI_BREADY),
        .C_BRESP(GPIC0_M00_AXI_BRESP),
        .C_BVALID(GPIC0_M00_AXI_BVALID),
        .C_RDATA(GPIC0_M00_AXI_RDATA),
        .C_RREADY(GPIC0_M00_AXI_RREADY),
        .C_RRESP(GPIC0_M00_AXI_RRESP),
        .C_RVALID(GPIC0_M00_AXI_RVALID),
        .C_WDATA(GPIC0_M00_AXI_WDATA),
        .C_WREADY(GPIC0_M00_AXI_WREADY),
        .C_WSTRB(GPIC0_M00_AXI_WSTRB),
        .C_WVALID(GPIC0_M00_AXI_WVALID),
        .D_ARADDR(Tiger4NSC_0_D_AXI_ARADDR),
        .D_ARBURST(Tiger4NSC_0_D_AXI_ARBURST),
        .D_ARCACHE(Tiger4NSC_0_D_AXI_ARCACHE),
        .D_ARLEN(Tiger4NSC_0_D_AXI_ARLEN),
        .D_ARPROT(Tiger4NSC_0_D_AXI_ARPROT),
        .D_ARREADY(Tiger4NSC_0_D_AXI_ARREADY),
        .D_ARSIZE(Tiger4NSC_0_D_AXI_ARSIZE),
        .D_ARVALID(Tiger4NSC_0_D_AXI_ARVALID),
        .D_AWADDR(Tiger4NSC_0_D_AXI_AWADDR),
        .D_AWBURST(Tiger4NSC_0_D_AXI_AWBURST),
        .D_AWCACHE(Tiger4NSC_0_D_AXI_AWCACHE),
        .D_AWLEN(Tiger4NSC_0_D_AXI_AWLEN),
        .D_AWPROT(Tiger4NSC_0_D_AXI_AWPROT),
        .D_AWREADY(Tiger4NSC_0_D_AXI_AWREADY),
        .D_AWSIZE(Tiger4NSC_0_D_AXI_AWSIZE),
        .D_AWVALID(Tiger4NSC_0_D_AXI_AWVALID),
        .D_BREADY(Tiger4NSC_0_D_AXI_BREADY),
        .D_BRESP(Tiger4NSC_0_D_AXI_BRESP),
        .D_BVALID(Tiger4NSC_0_D_AXI_BVALID),
        .D_RDATA(Tiger4NSC_0_D_AXI_RDATA),
        .D_RLAST(Tiger4NSC_0_D_AXI_RLAST),
        .D_RREADY(Tiger4NSC_0_D_AXI_RREADY),
        .D_RRESP(Tiger4NSC_0_D_AXI_RRESP),
        .D_RVALID(Tiger4NSC_0_D_AXI_RVALID),
        .D_WDATA(Tiger4NSC_0_D_AXI_WDATA),
        .D_WLAST(Tiger4NSC_0_D_AXI_WLAST),
        .D_WREADY(Tiger4NSC_0_D_AXI_WREADY),
        .D_WSTRB(Tiger4NSC_0_D_AXI_WSTRB),
        .D_WVALID(Tiger4NSC_0_D_AXI_WVALID),
        .iCMDReady(Tiger4NSC_0_NFCInterface_CMDReady),
        .iClock(PS_FCLK_CLK0),
        .iCorrectionFail(Tiger4NSC_0_SharedKESInterface_CorrectionFail),
        .iELPCoefficients(Tiger4NSC_0_SharedKESInterface_ELPCoefficients),
        .iErrorCount(Tiger4NSC_0_SharedKESInterface_ErrorCount),
        .iErroredChunk(Tiger4NSC_0_SharedKESInterface_ErroredChunk),
        .iIntraSharedKESEnd(Tiger4NSC_0_SharedKESInterface_IntraSharedKESEnd),
        .iROMRData(Tiger4NSC_0_uROMInterface_DOUT),
        .iReadData(Tiger4NSC_0_NFCInterface_ReadData),
        .iReadLast(Tiger4NSC_0_NFCInterface_ReadLast),
        .iReadValid(Tiger4NSC_0_NFCInterface_ReadValid),
        .iReadyBusy(Tiger4NSC_0_NFCInterface_ReadyBusy),
        .iReset(proc_sys_reset_0_peripheral_reset),
        .iSharedKESReady(Tiger4NSC_0_SharedKESInterface_SharedKESReady),
        .iWriteReady(Tiger4NSC_0_NFCInterface_WriteReady),
        .oAddress(Tiger4NSC_0_NFCInterface_Address),
        .oCMDValid(Tiger4NSC_0_NFCInterface_CMDValid),
        .oCSAvailable(Tiger4NSC_0_SharedKESInterface_CSAvailable),
        .oDecodeNeeded(Tiger4NSC_0_SharedKESInterface_DecodeNeeded),
        .oErrorDetectionEnd(Tiger4NSC_0_SharedKESInterface_ErrorDetectionEnd),
        .oLength(Tiger4NSC_0_NFCInterface_Length),
        .oOpcode(Tiger4NSC_0_NFCInterface_Opcode),
        .oROMAddr(Tiger4NSC_0_uROMInterface_ADDR),
        .oROMClock(Tiger4NSC_0_uROMInterface_CLK),
        .oROMEnable(Tiger4NSC_0_uROMInterface_EN),
        .oROMRW(Tiger4NSC_0_uROMInterface_WE),
        .oROMReset(Tiger4NSC_0_uROMInterface_RST),
        .oROMWData(Tiger4NSC_0_uROMInterface_DIN),
        .oReadReady(Tiger4NSC_0_NFCInterface_ReadReady),
        .oSourceID(Tiger4NSC_0_NFCInterface_SourceID),
        .oSyndromes(Tiger4NSC_0_SharedKESInterface_Syndromes),
        .oTargetID(Tiger4NSC_0_NFCInterface_TargetID),
        .oWriteData(Tiger4NSC_0_NFCInterface_WriteData),
        .oWriteLast(Tiger4NSC_0_NFCInterface_WriteLast),
        .oWriteValid(Tiger4NSC_0_NFCInterface_WriteValid));
OpenSSD2_Tiger4NSC_1_0 Tiger4NSC_1
       (.C_ARADDR(GPIC0_M01_AXI_ARADDR),
        .C_ARPROT(GPIC0_M01_AXI_ARPROT),
        .C_ARREADY(GPIC0_M01_AXI_ARREADY),
        .C_ARVALID(GPIC0_M01_AXI_ARVALID),
        .C_AWADDR(GPIC0_M01_AXI_AWADDR),
        .C_AWPROT(GPIC0_M01_AXI_AWPROT),
        .C_AWREADY(GPIC0_M01_AXI_AWREADY),
        .C_AWVALID(GPIC0_M01_AXI_AWVALID),
        .C_BREADY(GPIC0_M01_AXI_BREADY),
        .C_BRESP(GPIC0_M01_AXI_BRESP),
        .C_BVALID(GPIC0_M01_AXI_BVALID),
        .C_RDATA(GPIC0_M01_AXI_RDATA),
        .C_RREADY(GPIC0_M01_AXI_RREADY),
        .C_RRESP(GPIC0_M01_AXI_RRESP),
        .C_RVALID(GPIC0_M01_AXI_RVALID),
        .C_WDATA(GPIC0_M01_AXI_WDATA),
        .C_WREADY(GPIC0_M01_AXI_WREADY),
        .C_WSTRB(GPIC0_M01_AXI_WSTRB),
        .C_WVALID(GPIC0_M01_AXI_WVALID),
        .D_ARADDR(S01_AXI_1_ARADDR),
        .D_ARBURST(S01_AXI_1_ARBURST),
        .D_ARCACHE(S01_AXI_1_ARCACHE),
        .D_ARLEN(S01_AXI_1_ARLEN),
        .D_ARPROT(S01_AXI_1_ARPROT),
        .D_ARREADY(S01_AXI_1_ARREADY),
        .D_ARSIZE(S01_AXI_1_ARSIZE),
        .D_ARVALID(S01_AXI_1_ARVALID),
        .D_AWADDR(S01_AXI_1_AWADDR),
        .D_AWBURST(S01_AXI_1_AWBURST),
        .D_AWCACHE(S01_AXI_1_AWCACHE),
        .D_AWLEN(S01_AXI_1_AWLEN),
        .D_AWPROT(S01_AXI_1_AWPROT),
        .D_AWREADY(S01_AXI_1_AWREADY),
        .D_AWSIZE(S01_AXI_1_AWSIZE),
        .D_AWVALID(S01_AXI_1_AWVALID),
        .D_BREADY(S01_AXI_1_BREADY),
        .D_BRESP(S01_AXI_1_BRESP),
        .D_BVALID(S01_AXI_1_BVALID),
        .D_RDATA(S01_AXI_1_RDATA),
        .D_RLAST(S01_AXI_1_RLAST),
        .D_RREADY(S01_AXI_1_RREADY),
        .D_RRESP(S01_AXI_1_RRESP),
        .D_RVALID(S01_AXI_1_RVALID),
        .D_WDATA(S01_AXI_1_WDATA),
        .D_WLAST(S01_AXI_1_WLAST),
        .D_WREADY(S01_AXI_1_WREADY),
        .D_WSTRB(S01_AXI_1_WSTRB),
        .D_WVALID(S01_AXI_1_WVALID),
        .iCMDReady(Tiger4NSC_1_NFCInterface_CMDReady),
        .iClock(PS_FCLK_CLK0),
        .iCorrectionFail(Tiger4NSC_1_SharedKESInterface_CorrectionFail),
        .iELPCoefficients(Tiger4NSC_1_SharedKESInterface_ELPCoefficients),
        .iErrorCount(Tiger4NSC_1_SharedKESInterface_ErrorCount),
        .iErroredChunk(Tiger4NSC_1_SharedKESInterface_ErroredChunk),
        .iIntraSharedKESEnd(Tiger4NSC_1_SharedKESInterface_IntraSharedKESEnd),
        .iROMRData(Tiger4NSC_1_uROMInterface_DOUT),
        .iReadData(Tiger4NSC_1_NFCInterface_ReadData),
        .iReadLast(Tiger4NSC_1_NFCInterface_ReadLast),
        .iReadValid(Tiger4NSC_1_NFCInterface_ReadValid),
        .iReadyBusy(Tiger4NSC_1_NFCInterface_ReadyBusy),
        .iReset(proc_sys_reset_0_peripheral_reset),
        .iSharedKESReady(Tiger4NSC_1_SharedKESInterface_SharedKESReady),
        .iWriteReady(Tiger4NSC_1_NFCInterface_WriteReady),
        .oAddress(Tiger4NSC_1_NFCInterface_Address),
        .oCMDValid(Tiger4NSC_1_NFCInterface_CMDValid),
        .oCSAvailable(Tiger4NSC_1_SharedKESInterface_CSAvailable),
        .oDecodeNeeded(Tiger4NSC_1_SharedKESInterface_DecodeNeeded),
        .oErrorDetectionEnd(Tiger4NSC_1_SharedKESInterface_ErrorDetectionEnd),
        .oLength(Tiger4NSC_1_NFCInterface_Length),
        .oOpcode(Tiger4NSC_1_NFCInterface_Opcode),
        .oROMAddr(Tiger4NSC_1_uROMInterface_ADDR),
        .oROMClock(Tiger4NSC_1_uROMInterface_CLK),
        .oROMEnable(Tiger4NSC_1_uROMInterface_EN),
        .oROMRW(Tiger4NSC_1_uROMInterface_WE),
        .oROMReset(Tiger4NSC_1_uROMInterface_RST),
        .oROMWData(Tiger4NSC_1_uROMInterface_DIN),
        .oReadReady(Tiger4NSC_1_NFCInterface_ReadReady),
        .oSourceID(Tiger4NSC_1_NFCInterface_SourceID),
        .oSyndromes(Tiger4NSC_1_SharedKESInterface_Syndromes),
        .oTargetID(Tiger4NSC_1_NFCInterface_TargetID),
        .oWriteData(Tiger4NSC_1_NFCInterface_WriteData),
        .oWriteLast(Tiger4NSC_1_NFCInterface_WriteLast),
        .oWriteValid(Tiger4NSC_1_NFCInterface_WriteValid));
OpenSSD2_Tiger4SharedKES_0_0 Tiger4SharedKES_0
       (.iCSAvailable_0(Tiger4NSC_0_SharedKESInterface_CSAvailable),
        .iCSAvailable_1(Tiger4NSC_1_SharedKESInterface_CSAvailable),
        .iCSAvailable_2(GND_1),
        .iCSAvailable_3(GND_1),
        .iClock(PS_FCLK_CLK0),
        .iDecodeNeeded_0(Tiger4NSC_0_SharedKESInterface_DecodeNeeded),
        .iDecodeNeeded_1(Tiger4NSC_1_SharedKESInterface_DecodeNeeded),
        .iDecodeNeeded_2({GND_1,GND_1}),
        .iDecodeNeeded_3({GND_1,GND_1}),
        .iErrorDetectionEnd_0(Tiger4NSC_0_SharedKESInterface_ErrorDetectionEnd),
        .iErrorDetectionEnd_1(Tiger4NSC_1_SharedKESInterface_ErrorDetectionEnd),
        .iErrorDetectionEnd_2({GND_1,GND_1}),
        .iErrorDetectionEnd_3({GND_1,GND_1}),
        .iReset(proc_sys_reset_0_peripheral_reset),
        .iSyndromes_0(Tiger4NSC_0_SharedKESInterface_Syndromes),
        .iSyndromes_1(Tiger4NSC_1_SharedKESInterface_Syndromes),
        .iSyndromes_2({GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1}),
        .iSyndromes_3({GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1}),
        .oClusterErrorCount_0(Tiger4NSC_0_SharedKESInterface_ErrorCount),
        .oClusterErrorCount_1(Tiger4NSC_1_SharedKESInterface_ErrorCount),
        .oCorrectionFail_0(Tiger4NSC_0_SharedKESInterface_CorrectionFail),
        .oCorrectionFail_1(Tiger4NSC_1_SharedKESInterface_CorrectionFail),
        .oELPCoefficients_0(Tiger4NSC_0_SharedKESInterface_ELPCoefficients),
        .oELPCoefficients_1(Tiger4NSC_1_SharedKESInterface_ELPCoefficients),
        .oErroredChunk_0(Tiger4NSC_0_SharedKESInterface_ErroredChunk),
        .oErroredChunk_1(Tiger4NSC_1_SharedKESInterface_ErroredChunk),
        .oIntraSharedKESEnd_0(Tiger4NSC_0_SharedKESInterface_IntraSharedKESEnd),
        .oIntraSharedKESEnd_1(Tiger4NSC_1_SharedKESInterface_IntraSharedKESEnd),
        .oSharedKESReady_0(Tiger4NSC_0_SharedKESInterface_SharedKESReady),
        .oSharedKESReady_1(Tiger4NSC_1_SharedKESInterface_SharedKESReady));
OpenSSD2_V2NFC100DDR_0_0 V2NFC100DDR_0
       (.IO_NAND_DQ(IO_NAND_CH0_DQ[7:0]),
        .IO_NAND_DQS_N(IO_NAND_CH0_DQS_N),
        .IO_NAND_DQS_P(IO_NAND_CH0_DQS_P),
        .I_NAND_RB(I_NAND_RB_1),
        .O_NAND_ALE(V2NFC100DDR_0_O_NAND_ALE),
        .O_NAND_CE(V2NFC100DDR_0_O_NAND_CE),
        .O_NAND_CLE(V2NFC100DDR_0_O_NAND_CLE),
        .O_NAND_RE_N(V2NFC100DDR_0_O_NAND_RE_N),
        .O_NAND_RE_P(V2NFC100DDR_0_O_NAND_RE_P),
        .O_NAND_WE(V2NFC100DDR_0_O_NAND_WE),
        .O_NAND_WP(V2NFC100DDR_0_O_NAND_WP),
        .iAddress(Tiger4NSC_0_NFCInterface_Address),
        .iCMDValid(Tiger4NSC_0_NFCInterface_CMDValid),
        .iDelayRefClock(CH0MMCMC1H200_clk_out1),
        .iLength(Tiger4NSC_0_NFCInterface_Length),
        .iOpcode(Tiger4NSC_0_NFCInterface_Opcode),
        .iOutputDrivingClock(CH0MMCMC1H200_clk_out1),
        .iReadReady(Tiger4NSC_0_NFCInterface_ReadReady),
        .iReset(proc_sys_reset_0_peripheral_reset),
        .iSourceID(Tiger4NSC_0_NFCInterface_SourceID),
        .iSystemClock(PS_FCLK_CLK0),
        .iTargetID(Tiger4NSC_0_NFCInterface_TargetID),
        .iWriteData(Tiger4NSC_0_NFCInterface_WriteData),
        .iWriteLast(Tiger4NSC_0_NFCInterface_WriteLast),
        .iWriteValid(Tiger4NSC_0_NFCInterface_WriteValid),
        .oCMDReady(Tiger4NSC_0_NFCInterface_CMDReady),
        .oReadData(Tiger4NSC_0_NFCInterface_ReadData),
        .oReadLast(Tiger4NSC_0_NFCInterface_ReadLast),
        .oReadValid(Tiger4NSC_0_NFCInterface_ReadValid),
        .oReadyBusy(Tiger4NSC_0_NFCInterface_ReadyBusy),
        .oWriteReady(Tiger4NSC_0_NFCInterface_WriteReady));
OpenSSD2_V2NFC100DDR_1_0 V2NFC100DDR_1
       (.IO_NAND_DQ(IO_NAND_CH1_DQ[7:0]),
        .IO_NAND_DQS_N(IO_NAND_CH1_DQS_N),
        .IO_NAND_DQS_P(IO_NAND_CH1_DQS_P),
        .I_NAND_RB(I_NAND_RB_2),
        .O_NAND_ALE(V2NFC100DDR_1_O_NAND_ALE),
        .O_NAND_CE(V2NFC100DDR_1_O_NAND_CE),
        .O_NAND_CLE(V2NFC100DDR_1_O_NAND_CLE),
        .O_NAND_RE_N(V2NFC100DDR_1_O_NAND_RE_N),
        .O_NAND_RE_P(V2NFC100DDR_1_O_NAND_RE_P),
        .O_NAND_WE(V2NFC100DDR_1_O_NAND_WE),
        .O_NAND_WP(V2NFC100DDR_1_O_NAND_WP),
        .iAddress(Tiger4NSC_1_NFCInterface_Address),
        .iCMDValid(Tiger4NSC_1_NFCInterface_CMDValid),
        .iDelayRefClock(CH0MMCMC1H200_clk_out1),
        .iLength(Tiger4NSC_1_NFCInterface_Length),
        .iOpcode(Tiger4NSC_1_NFCInterface_Opcode),
        .iOutputDrivingClock(CH0MMCMC1H200_clk_out1),
        .iReadReady(Tiger4NSC_1_NFCInterface_ReadReady),
        .iReset(proc_sys_reset_0_peripheral_reset),
        .iSourceID(Tiger4NSC_1_NFCInterface_SourceID),
        .iSystemClock(PS_FCLK_CLK0),
        .iTargetID(Tiger4NSC_1_NFCInterface_TargetID),
        .iWriteData(Tiger4NSC_1_NFCInterface_WriteData),
        .iWriteLast(Tiger4NSC_1_NFCInterface_WriteLast),
        .iWriteValid(Tiger4NSC_1_NFCInterface_WriteValid),
        .oCMDReady(Tiger4NSC_1_NFCInterface_CMDReady),
        .oReadData(Tiger4NSC_1_NFCInterface_ReadData),
        .oReadLast(Tiger4NSC_1_NFCInterface_ReadLast),
        .oReadValid(Tiger4NSC_1_NFCInterface_ReadValid),
        .oReadyBusy(Tiger4NSC_1_NFCInterface_ReadyBusy),
        .oWriteReady(Tiger4NSC_1_NFCInterface_WriteReady));
VCC VCC
       (.P(VCC_1));
OpenSSD2_axi_interconnect_0_3 axi_interconnect_0
       (.ACLK(PS_FCLK_CLK3),
        .ARESETN(ARESETN_2),
        .M00_ACLK(PS_FCLK_CLK3),
        .M00_ARESETN(M00_ARESETN_2),
        .M00_AXI_araddr(axi_interconnect_0_M00_AXI_ARADDR),
        .M00_AXI_arburst(axi_interconnect_0_M00_AXI_ARBURST),
        .M00_AXI_arcache(axi_interconnect_0_M00_AXI_ARCACHE),
        .M00_AXI_arid(axi_interconnect_0_M00_AXI_ARID),
        .M00_AXI_arlen(axi_interconnect_0_M00_AXI_ARLEN),
        .M00_AXI_arlock(axi_interconnect_0_M00_AXI_ARLOCK),
        .M00_AXI_arprot(axi_interconnect_0_M00_AXI_ARPROT),
        .M00_AXI_arqos(axi_interconnect_0_M00_AXI_ARQOS),
        .M00_AXI_arready(axi_interconnect_0_M00_AXI_ARREADY),
        .M00_AXI_arsize(axi_interconnect_0_M00_AXI_ARSIZE),
        .M00_AXI_arvalid(axi_interconnect_0_M00_AXI_ARVALID),
        .M00_AXI_awaddr(axi_interconnect_0_M00_AXI_AWADDR),
        .M00_AXI_awburst(axi_interconnect_0_M00_AXI_AWBURST),
        .M00_AXI_awcache(axi_interconnect_0_M00_AXI_AWCACHE),
        .M00_AXI_awid(axi_interconnect_0_M00_AXI_AWID),
        .M00_AXI_awlen(axi_interconnect_0_M00_AXI_AWLEN),
        .M00_AXI_awlock(axi_interconnect_0_M00_AXI_AWLOCK),
        .M00_AXI_awprot(axi_interconnect_0_M00_AXI_AWPROT),
        .M00_AXI_awqos(axi_interconnect_0_M00_AXI_AWQOS),
        .M00_AXI_awready(axi_interconnect_0_M00_AXI_AWREADY),
        .M00_AXI_awsize(axi_interconnect_0_M00_AXI_AWSIZE),
        .M00_AXI_awvalid(axi_interconnect_0_M00_AXI_AWVALID),
        .M00_AXI_bid(axi_interconnect_0_M00_AXI_BID[0]),
        .M00_AXI_bready(axi_interconnect_0_M00_AXI_BREADY),
        .M00_AXI_bresp(axi_interconnect_0_M00_AXI_BRESP),
        .M00_AXI_bvalid(axi_interconnect_0_M00_AXI_BVALID),
        .M00_AXI_rdata(axi_interconnect_0_M00_AXI_RDATA),
        .M00_AXI_rid(axi_interconnect_0_M00_AXI_RID[0]),
        .M00_AXI_rlast(axi_interconnect_0_M00_AXI_RLAST),
        .M00_AXI_rready(axi_interconnect_0_M00_AXI_RREADY),
        .M00_AXI_rresp(axi_interconnect_0_M00_AXI_RRESP),
        .M00_AXI_rvalid(axi_interconnect_0_M00_AXI_RVALID),
        .M00_AXI_wdata(axi_interconnect_0_M00_AXI_WDATA),
        .M00_AXI_wid(axi_interconnect_0_M00_AXI_WID),
        .M00_AXI_wlast(axi_interconnect_0_M00_AXI_WLAST),
        .M00_AXI_wready(axi_interconnect_0_M00_AXI_WREADY),
        .M00_AXI_wstrb(axi_interconnect_0_M00_AXI_WSTRB),
        .M00_AXI_wvalid(axi_interconnect_0_M00_AXI_WVALID),
        .S00_ACLK(PS_FCLK_CLK0),
        .S00_ARESETN(M00_ARESETN_1),
        .S00_AXI_araddr(Tiger4NSC_0_D_AXI_ARADDR),
        .S00_AXI_arburst(Tiger4NSC_0_D_AXI_ARBURST),
        .S00_AXI_arcache(Tiger4NSC_0_D_AXI_ARCACHE),
        .S00_AXI_arlen(Tiger4NSC_0_D_AXI_ARLEN),
        .S00_AXI_arprot(Tiger4NSC_0_D_AXI_ARPROT),
        .S00_AXI_arready(Tiger4NSC_0_D_AXI_ARREADY),
        .S00_AXI_arsize(Tiger4NSC_0_D_AXI_ARSIZE),
        .S00_AXI_arvalid(Tiger4NSC_0_D_AXI_ARVALID),
        .S00_AXI_awaddr(Tiger4NSC_0_D_AXI_AWADDR),
        .S00_AXI_awburst(Tiger4NSC_0_D_AXI_AWBURST),
        .S00_AXI_awcache(Tiger4NSC_0_D_AXI_AWCACHE),
        .S00_AXI_awlen(Tiger4NSC_0_D_AXI_AWLEN),
        .S00_AXI_awprot(Tiger4NSC_0_D_AXI_AWPROT),
        .S00_AXI_awready(Tiger4NSC_0_D_AXI_AWREADY),
        .S00_AXI_awsize(Tiger4NSC_0_D_AXI_AWSIZE),
        .S00_AXI_awvalid(Tiger4NSC_0_D_AXI_AWVALID),
        .S00_AXI_bready(Tiger4NSC_0_D_AXI_BREADY),
        .S00_AXI_bresp(Tiger4NSC_0_D_AXI_BRESP),
        .S00_AXI_bvalid(Tiger4NSC_0_D_AXI_BVALID),
        .S00_AXI_rdata(Tiger4NSC_0_D_AXI_RDATA),
        .S00_AXI_rlast(Tiger4NSC_0_D_AXI_RLAST),
        .S00_AXI_rready(Tiger4NSC_0_D_AXI_RREADY),
        .S00_AXI_rresp(Tiger4NSC_0_D_AXI_RRESP),
        .S00_AXI_rvalid(Tiger4NSC_0_D_AXI_RVALID),
        .S00_AXI_wdata(Tiger4NSC_0_D_AXI_WDATA),
        .S00_AXI_wlast(Tiger4NSC_0_D_AXI_WLAST),
        .S00_AXI_wready(Tiger4NSC_0_D_AXI_WREADY),
        .S00_AXI_wstrb(Tiger4NSC_0_D_AXI_WSTRB),
        .S00_AXI_wvalid(Tiger4NSC_0_D_AXI_WVALID),
        .S01_ACLK(PS_FCLK_CLK0),
        .S01_ARESETN(M00_ARESETN_1),
        .S01_AXI_araddr(S01_AXI_1_ARADDR),
        .S01_AXI_arburst(S01_AXI_1_ARBURST),
        .S01_AXI_arcache(S01_AXI_1_ARCACHE),
        .S01_AXI_arlen(S01_AXI_1_ARLEN),
        .S01_AXI_arprot(S01_AXI_1_ARPROT),
        .S01_AXI_arready(S01_AXI_1_ARREADY),
        .S01_AXI_arsize(S01_AXI_1_ARSIZE),
        .S01_AXI_arvalid(S01_AXI_1_ARVALID),
        .S01_AXI_awaddr(S01_AXI_1_AWADDR),
        .S01_AXI_awburst(S01_AXI_1_AWBURST),
        .S01_AXI_awcache(S01_AXI_1_AWCACHE),
        .S01_AXI_awlen(S01_AXI_1_AWLEN),
        .S01_AXI_awprot(S01_AXI_1_AWPROT),
        .S01_AXI_awready(S01_AXI_1_AWREADY),
        .S01_AXI_awsize(S01_AXI_1_AWSIZE),
        .S01_AXI_awvalid(S01_AXI_1_AWVALID),
        .S01_AXI_bready(S01_AXI_1_BREADY),
        .S01_AXI_bresp(S01_AXI_1_BRESP),
        .S01_AXI_bvalid(S01_AXI_1_BVALID),
        .S01_AXI_rdata(S01_AXI_1_RDATA),
        .S01_AXI_rlast(S01_AXI_1_RLAST),
        .S01_AXI_rready(S01_AXI_1_RREADY),
        .S01_AXI_rresp(S01_AXI_1_RRESP),
        .S01_AXI_rvalid(S01_AXI_1_RVALID),
        .S01_AXI_wdata(S01_AXI_1_WDATA),
        .S01_AXI_wlast(S01_AXI_1_WLAST),
        .S01_AXI_wready(S01_AXI_1_WREADY),
        .S01_AXI_wstrb(S01_AXI_1_WSTRB),
        .S01_AXI_wvalid(S01_AXI_1_WVALID));
OpenSSD2_proc_sys_reset_0_0 proc_sys_reset_0
       (.aux_reset_in(VCC_1),
        .dcm_locked(VCC_1),
        .ext_reset_in(PS_FCLK_RESET0_N),
        .interconnect_aresetn(ARESETN_1),
        .mb_debug_sys_rst(GND_1),
        .peripheral_aresetn(M00_ARESETN_1),
        .peripheral_reset(proc_sys_reset_0_peripheral_reset),
        .slowest_sync_clk(PS_FCLK_CLK0));
OpenSSD2_proc_sys_reset_2_0 proc_sys_reset_2
       (.aux_reset_in(VCC_1),
        .dcm_locked(VCC_1),
        .ext_reset_in(PS_FCLK_RESET2_N),
        .interconnect_aresetn(ARESETN_3),
        .mb_debug_sys_rst(GND_1),
        .peripheral_aresetn(proc_sys_reset_2_peripheral_aresetn),
        .slowest_sync_clk(PS_FCLK_CLK2));
OpenSSD2_proc_sys_reset_3_0 proc_sys_reset_3
       (.aux_reset_in(VCC_1),
        .dcm_locked(VCC_1),
        .ext_reset_in(PS_FCLK_RESET3_N),
        .interconnect_aresetn(ARESETN_2),
        .mb_debug_sys_rst(GND_1),
        .peripheral_aresetn(M00_ARESETN_2),
        .slowest_sync_clk(PS_FCLK_CLK3));
endmodule

module OpenSSD2_axi_interconnect_0_0
   (ACLK,
    ARESETN,
    M00_ACLK,
    M00_ARESETN,
    M00_AXI_araddr,
    M00_AXI_arprot,
    M00_AXI_arready,
    M00_AXI_arvalid,
    M00_AXI_awaddr,
    M00_AXI_awprot,
    M00_AXI_awready,
    M00_AXI_awvalid,
    M00_AXI_bready,
    M00_AXI_bresp,
    M00_AXI_bvalid,
    M00_AXI_rdata,
    M00_AXI_rready,
    M00_AXI_rresp,
    M00_AXI_rvalid,
    M00_AXI_wdata,
    M00_AXI_wready,
    M00_AXI_wstrb,
    M00_AXI_wvalid,
    M01_ACLK,
    M01_ARESETN,
    M01_AXI_araddr,
    M01_AXI_arprot,
    M01_AXI_arready,
    M01_AXI_arvalid,
    M01_AXI_awaddr,
    M01_AXI_awprot,
    M01_AXI_awready,
    M01_AXI_awvalid,
    M01_AXI_bready,
    M01_AXI_bresp,
    M01_AXI_bvalid,
    M01_AXI_rdata,
    M01_AXI_rready,
    M01_AXI_rresp,
    M01_AXI_rvalid,
    M01_AXI_wdata,
    M01_AXI_wready,
    M01_AXI_wstrb,
    M01_AXI_wvalid,
    S00_ACLK,
    S00_ARESETN,
    S00_AXI_araddr,
    S00_AXI_arburst,
    S00_AXI_arcache,
    S00_AXI_arid,
    S00_AXI_arlen,
    S00_AXI_arlock,
    S00_AXI_arprot,
    S00_AXI_arqos,
    S00_AXI_arready,
    S00_AXI_arsize,
    S00_AXI_arvalid,
    S00_AXI_awaddr,
    S00_AXI_awburst,
    S00_AXI_awcache,
    S00_AXI_awid,
    S00_AXI_awlen,
    S00_AXI_awlock,
    S00_AXI_awprot,
    S00_AXI_awqos,
    S00_AXI_awready,
    S00_AXI_awsize,
    S00_AXI_awvalid,
    S00_AXI_bid,
    S00_AXI_bready,
    S00_AXI_bresp,
    S00_AXI_bvalid,
    S00_AXI_rdata,
    S00_AXI_rid,
    S00_AXI_rlast,
    S00_AXI_rready,
    S00_AXI_rresp,
    S00_AXI_rvalid,
    S00_AXI_wdata,
    S00_AXI_wid,
    S00_AXI_wlast,
    S00_AXI_wready,
    S00_AXI_wstrb,
    S00_AXI_wvalid);
  input ACLK;
  input [0:0]ARESETN;
  input M00_ACLK;
  input [0:0]M00_ARESETN;
  output [31:0]M00_AXI_araddr;
  output [2:0]M00_AXI_arprot;
  input M00_AXI_arready;
  output M00_AXI_arvalid;
  output [31:0]M00_AXI_awaddr;
  output [2:0]M00_AXI_awprot;
  input M00_AXI_awready;
  output M00_AXI_awvalid;
  output M00_AXI_bready;
  input [1:0]M00_AXI_bresp;
  input M00_AXI_bvalid;
  input [31:0]M00_AXI_rdata;
  output M00_AXI_rready;
  input [1:0]M00_AXI_rresp;
  input M00_AXI_rvalid;
  output [31:0]M00_AXI_wdata;
  input M00_AXI_wready;
  output [3:0]M00_AXI_wstrb;
  output M00_AXI_wvalid;
  input M01_ACLK;
  input [0:0]M01_ARESETN;
  output [31:0]M01_AXI_araddr;
  output [2:0]M01_AXI_arprot;
  input M01_AXI_arready;
  output M01_AXI_arvalid;
  output [31:0]M01_AXI_awaddr;
  output [2:0]M01_AXI_awprot;
  input M01_AXI_awready;
  output M01_AXI_awvalid;
  output M01_AXI_bready;
  input [1:0]M01_AXI_bresp;
  input M01_AXI_bvalid;
  input [31:0]M01_AXI_rdata;
  output M01_AXI_rready;
  input [1:0]M01_AXI_rresp;
  input M01_AXI_rvalid;
  output [31:0]M01_AXI_wdata;
  input M01_AXI_wready;
  output [3:0]M01_AXI_wstrb;
  output M01_AXI_wvalid;
  input S00_ACLK;
  input [0:0]S00_ARESETN;
  input [31:0]S00_AXI_araddr;
  input [1:0]S00_AXI_arburst;
  input [3:0]S00_AXI_arcache;
  input [11:0]S00_AXI_arid;
  input [3:0]S00_AXI_arlen;
  input [1:0]S00_AXI_arlock;
  input [2:0]S00_AXI_arprot;
  input [3:0]S00_AXI_arqos;
  output S00_AXI_arready;
  input [2:0]S00_AXI_arsize;
  input S00_AXI_arvalid;
  input [31:0]S00_AXI_awaddr;
  input [1:0]S00_AXI_awburst;
  input [3:0]S00_AXI_awcache;
  input [11:0]S00_AXI_awid;
  input [3:0]S00_AXI_awlen;
  input [1:0]S00_AXI_awlock;
  input [2:0]S00_AXI_awprot;
  input [3:0]S00_AXI_awqos;
  output S00_AXI_awready;
  input [2:0]S00_AXI_awsize;
  input S00_AXI_awvalid;
  output [11:0]S00_AXI_bid;
  input S00_AXI_bready;
  output [1:0]S00_AXI_bresp;
  output S00_AXI_bvalid;
  output [31:0]S00_AXI_rdata;
  output [11:0]S00_AXI_rid;
  output S00_AXI_rlast;
  input S00_AXI_rready;
  output [1:0]S00_AXI_rresp;
  output S00_AXI_rvalid;
  input [31:0]S00_AXI_wdata;
  input [11:0]S00_AXI_wid;
  input S00_AXI_wlast;
  output S00_AXI_wready;
  input [3:0]S00_AXI_wstrb;
  input S00_AXI_wvalid;

  wire GPIC0_ACLK_net;
  wire [0:0]GPIC0_ARESETN_net;
  wire [31:0]GPIC0_to_s00_couplers_ARADDR;
  wire [1:0]GPIC0_to_s00_couplers_ARBURST;
  wire [3:0]GPIC0_to_s00_couplers_ARCACHE;
  wire [11:0]GPIC0_to_s00_couplers_ARID;
  wire [3:0]GPIC0_to_s00_couplers_ARLEN;
  wire [1:0]GPIC0_to_s00_couplers_ARLOCK;
  wire [2:0]GPIC0_to_s00_couplers_ARPROT;
  wire [3:0]GPIC0_to_s00_couplers_ARQOS;
  wire GPIC0_to_s00_couplers_ARREADY;
  wire [2:0]GPIC0_to_s00_couplers_ARSIZE;
  wire GPIC0_to_s00_couplers_ARVALID;
  wire [31:0]GPIC0_to_s00_couplers_AWADDR;
  wire [1:0]GPIC0_to_s00_couplers_AWBURST;
  wire [3:0]GPIC0_to_s00_couplers_AWCACHE;
  wire [11:0]GPIC0_to_s00_couplers_AWID;
  wire [3:0]GPIC0_to_s00_couplers_AWLEN;
  wire [1:0]GPIC0_to_s00_couplers_AWLOCK;
  wire [2:0]GPIC0_to_s00_couplers_AWPROT;
  wire [3:0]GPIC0_to_s00_couplers_AWQOS;
  wire GPIC0_to_s00_couplers_AWREADY;
  wire [2:0]GPIC0_to_s00_couplers_AWSIZE;
  wire GPIC0_to_s00_couplers_AWVALID;
  wire [11:0]GPIC0_to_s00_couplers_BID;
  wire GPIC0_to_s00_couplers_BREADY;
  wire [1:0]GPIC0_to_s00_couplers_BRESP;
  wire GPIC0_to_s00_couplers_BVALID;
  wire [31:0]GPIC0_to_s00_couplers_RDATA;
  wire [11:0]GPIC0_to_s00_couplers_RID;
  wire GPIC0_to_s00_couplers_RLAST;
  wire GPIC0_to_s00_couplers_RREADY;
  wire [1:0]GPIC0_to_s00_couplers_RRESP;
  wire GPIC0_to_s00_couplers_RVALID;
  wire [31:0]GPIC0_to_s00_couplers_WDATA;
  wire [11:0]GPIC0_to_s00_couplers_WID;
  wire GPIC0_to_s00_couplers_WLAST;
  wire GPIC0_to_s00_couplers_WREADY;
  wire [3:0]GPIC0_to_s00_couplers_WSTRB;
  wire GPIC0_to_s00_couplers_WVALID;
  wire M00_ACLK_1;
  wire [0:0]M00_ARESETN_1;
  wire M01_ACLK_1;
  wire [0:0]M01_ARESETN_1;
  wire S00_ACLK_1;
  wire [0:0]S00_ARESETN_1;
  wire [31:0]m00_couplers_to_GPIC0_ARADDR;
  wire [2:0]m00_couplers_to_GPIC0_ARPROT;
  wire m00_couplers_to_GPIC0_ARREADY;
  wire m00_couplers_to_GPIC0_ARVALID;
  wire [31:0]m00_couplers_to_GPIC0_AWADDR;
  wire [2:0]m00_couplers_to_GPIC0_AWPROT;
  wire m00_couplers_to_GPIC0_AWREADY;
  wire m00_couplers_to_GPIC0_AWVALID;
  wire m00_couplers_to_GPIC0_BREADY;
  wire [1:0]m00_couplers_to_GPIC0_BRESP;
  wire m00_couplers_to_GPIC0_BVALID;
  wire [31:0]m00_couplers_to_GPIC0_RDATA;
  wire m00_couplers_to_GPIC0_RREADY;
  wire [1:0]m00_couplers_to_GPIC0_RRESP;
  wire m00_couplers_to_GPIC0_RVALID;
  wire [31:0]m00_couplers_to_GPIC0_WDATA;
  wire m00_couplers_to_GPIC0_WREADY;
  wire [3:0]m00_couplers_to_GPIC0_WSTRB;
  wire m00_couplers_to_GPIC0_WVALID;
  wire [31:0]m01_couplers_to_GPIC0_ARADDR;
  wire [2:0]m01_couplers_to_GPIC0_ARPROT;
  wire m01_couplers_to_GPIC0_ARREADY;
  wire m01_couplers_to_GPIC0_ARVALID;
  wire [31:0]m01_couplers_to_GPIC0_AWADDR;
  wire [2:0]m01_couplers_to_GPIC0_AWPROT;
  wire m01_couplers_to_GPIC0_AWREADY;
  wire m01_couplers_to_GPIC0_AWVALID;
  wire m01_couplers_to_GPIC0_BREADY;
  wire [1:0]m01_couplers_to_GPIC0_BRESP;
  wire m01_couplers_to_GPIC0_BVALID;
  wire [31:0]m01_couplers_to_GPIC0_RDATA;
  wire m01_couplers_to_GPIC0_RREADY;
  wire [1:0]m01_couplers_to_GPIC0_RRESP;
  wire m01_couplers_to_GPIC0_RVALID;
  wire [31:0]m01_couplers_to_GPIC0_WDATA;
  wire m01_couplers_to_GPIC0_WREADY;
  wire [3:0]m01_couplers_to_GPIC0_WSTRB;
  wire m01_couplers_to_GPIC0_WVALID;
  wire [31:0]s00_couplers_to_xbar_ARADDR;
  wire [2:0]s00_couplers_to_xbar_ARPROT;
  wire [0:0]s00_couplers_to_xbar_ARREADY;
  wire s00_couplers_to_xbar_ARVALID;
  wire [31:0]s00_couplers_to_xbar_AWADDR;
  wire [2:0]s00_couplers_to_xbar_AWPROT;
  wire [0:0]s00_couplers_to_xbar_AWREADY;
  wire s00_couplers_to_xbar_AWVALID;
  wire s00_couplers_to_xbar_BREADY;
  wire [1:0]s00_couplers_to_xbar_BRESP;
  wire [0:0]s00_couplers_to_xbar_BVALID;
  wire [31:0]s00_couplers_to_xbar_RDATA;
  wire s00_couplers_to_xbar_RREADY;
  wire [1:0]s00_couplers_to_xbar_RRESP;
  wire [0:0]s00_couplers_to_xbar_RVALID;
  wire [31:0]s00_couplers_to_xbar_WDATA;
  wire [0:0]s00_couplers_to_xbar_WREADY;
  wire [3:0]s00_couplers_to_xbar_WSTRB;
  wire s00_couplers_to_xbar_WVALID;
  wire [31:0]xbar_to_m00_couplers_ARADDR;
  wire [2:0]xbar_to_m00_couplers_ARPROT;
  wire xbar_to_m00_couplers_ARREADY;
  wire [0:0]xbar_to_m00_couplers_ARVALID;
  wire [31:0]xbar_to_m00_couplers_AWADDR;
  wire [2:0]xbar_to_m00_couplers_AWPROT;
  wire xbar_to_m00_couplers_AWREADY;
  wire [0:0]xbar_to_m00_couplers_AWVALID;
  wire [0:0]xbar_to_m00_couplers_BREADY;
  wire [1:0]xbar_to_m00_couplers_BRESP;
  wire xbar_to_m00_couplers_BVALID;
  wire [31:0]xbar_to_m00_couplers_RDATA;
  wire [0:0]xbar_to_m00_couplers_RREADY;
  wire [1:0]xbar_to_m00_couplers_RRESP;
  wire xbar_to_m00_couplers_RVALID;
  wire [31:0]xbar_to_m00_couplers_WDATA;
  wire xbar_to_m00_couplers_WREADY;
  wire [3:0]xbar_to_m00_couplers_WSTRB;
  wire [0:0]xbar_to_m00_couplers_WVALID;
  wire [63:32]xbar_to_m01_couplers_ARADDR;
  wire [5:3]xbar_to_m01_couplers_ARPROT;
  wire xbar_to_m01_couplers_ARREADY;
  wire [1:1]xbar_to_m01_couplers_ARVALID;
  wire [63:32]xbar_to_m01_couplers_AWADDR;
  wire [5:3]xbar_to_m01_couplers_AWPROT;
  wire xbar_to_m01_couplers_AWREADY;
  wire [1:1]xbar_to_m01_couplers_AWVALID;
  wire [1:1]xbar_to_m01_couplers_BREADY;
  wire [1:0]xbar_to_m01_couplers_BRESP;
  wire xbar_to_m01_couplers_BVALID;
  wire [31:0]xbar_to_m01_couplers_RDATA;
  wire [1:1]xbar_to_m01_couplers_RREADY;
  wire [1:0]xbar_to_m01_couplers_RRESP;
  wire xbar_to_m01_couplers_RVALID;
  wire [63:32]xbar_to_m01_couplers_WDATA;
  wire xbar_to_m01_couplers_WREADY;
  wire [7:4]xbar_to_m01_couplers_WSTRB;
  wire [1:1]xbar_to_m01_couplers_WVALID;

  assign GPIC0_ACLK_net = ACLK;
  assign GPIC0_ARESETN_net = ARESETN[0];
  assign GPIC0_to_s00_couplers_ARADDR = S00_AXI_araddr[31:0];
  assign GPIC0_to_s00_couplers_ARBURST = S00_AXI_arburst[1:0];
  assign GPIC0_to_s00_couplers_ARCACHE = S00_AXI_arcache[3:0];
  assign GPIC0_to_s00_couplers_ARID = S00_AXI_arid[11:0];
  assign GPIC0_to_s00_couplers_ARLEN = S00_AXI_arlen[3:0];
  assign GPIC0_to_s00_couplers_ARLOCK = S00_AXI_arlock[1:0];
  assign GPIC0_to_s00_couplers_ARPROT = S00_AXI_arprot[2:0];
  assign GPIC0_to_s00_couplers_ARQOS = S00_AXI_arqos[3:0];
  assign GPIC0_to_s00_couplers_ARSIZE = S00_AXI_arsize[2:0];
  assign GPIC0_to_s00_couplers_ARVALID = S00_AXI_arvalid;
  assign GPIC0_to_s00_couplers_AWADDR = S00_AXI_awaddr[31:0];
  assign GPIC0_to_s00_couplers_AWBURST = S00_AXI_awburst[1:0];
  assign GPIC0_to_s00_couplers_AWCACHE = S00_AXI_awcache[3:0];
  assign GPIC0_to_s00_couplers_AWID = S00_AXI_awid[11:0];
  assign GPIC0_to_s00_couplers_AWLEN = S00_AXI_awlen[3:0];
  assign GPIC0_to_s00_couplers_AWLOCK = S00_AXI_awlock[1:0];
  assign GPIC0_to_s00_couplers_AWPROT = S00_AXI_awprot[2:0];
  assign GPIC0_to_s00_couplers_AWQOS = S00_AXI_awqos[3:0];
  assign GPIC0_to_s00_couplers_AWSIZE = S00_AXI_awsize[2:0];
  assign GPIC0_to_s00_couplers_AWVALID = S00_AXI_awvalid;
  assign GPIC0_to_s00_couplers_BREADY = S00_AXI_bready;
  assign GPIC0_to_s00_couplers_RREADY = S00_AXI_rready;
  assign GPIC0_to_s00_couplers_WDATA = S00_AXI_wdata[31:0];
  assign GPIC0_to_s00_couplers_WID = S00_AXI_wid[11:0];
  assign GPIC0_to_s00_couplers_WLAST = S00_AXI_wlast;
  assign GPIC0_to_s00_couplers_WSTRB = S00_AXI_wstrb[3:0];
  assign GPIC0_to_s00_couplers_WVALID = S00_AXI_wvalid;
  assign M00_ACLK_1 = M00_ACLK;
  assign M00_ARESETN_1 = M00_ARESETN[0];
  assign M00_AXI_araddr[31:0] = m00_couplers_to_GPIC0_ARADDR;
  assign M00_AXI_arprot[2:0] = m00_couplers_to_GPIC0_ARPROT;
  assign M00_AXI_arvalid = m00_couplers_to_GPIC0_ARVALID;
  assign M00_AXI_awaddr[31:0] = m00_couplers_to_GPIC0_AWADDR;
  assign M00_AXI_awprot[2:0] = m00_couplers_to_GPIC0_AWPROT;
  assign M00_AXI_awvalid = m00_couplers_to_GPIC0_AWVALID;
  assign M00_AXI_bready = m00_couplers_to_GPIC0_BREADY;
  assign M00_AXI_rready = m00_couplers_to_GPIC0_RREADY;
  assign M00_AXI_wdata[31:0] = m00_couplers_to_GPIC0_WDATA;
  assign M00_AXI_wstrb[3:0] = m00_couplers_to_GPIC0_WSTRB;
  assign M00_AXI_wvalid = m00_couplers_to_GPIC0_WVALID;
  assign M01_ACLK_1 = M01_ACLK;
  assign M01_ARESETN_1 = M01_ARESETN[0];
  assign M01_AXI_araddr[31:0] = m01_couplers_to_GPIC0_ARADDR;
  assign M01_AXI_arprot[2:0] = m01_couplers_to_GPIC0_ARPROT;
  assign M01_AXI_arvalid = m01_couplers_to_GPIC0_ARVALID;
  assign M01_AXI_awaddr[31:0] = m01_couplers_to_GPIC0_AWADDR;
  assign M01_AXI_awprot[2:0] = m01_couplers_to_GPIC0_AWPROT;
  assign M01_AXI_awvalid = m01_couplers_to_GPIC0_AWVALID;
  assign M01_AXI_bready = m01_couplers_to_GPIC0_BREADY;
  assign M01_AXI_rready = m01_couplers_to_GPIC0_RREADY;
  assign M01_AXI_wdata[31:0] = m01_couplers_to_GPIC0_WDATA;
  assign M01_AXI_wstrb[3:0] = m01_couplers_to_GPIC0_WSTRB;
  assign M01_AXI_wvalid = m01_couplers_to_GPIC0_WVALID;
  assign S00_ACLK_1 = S00_ACLK;
  assign S00_ARESETN_1 = S00_ARESETN[0];
  assign S00_AXI_arready = GPIC0_to_s00_couplers_ARREADY;
  assign S00_AXI_awready = GPIC0_to_s00_couplers_AWREADY;
  assign S00_AXI_bid[11:0] = GPIC0_to_s00_couplers_BID;
  assign S00_AXI_bresp[1:0] = GPIC0_to_s00_couplers_BRESP;
  assign S00_AXI_bvalid = GPIC0_to_s00_couplers_BVALID;
  assign S00_AXI_rdata[31:0] = GPIC0_to_s00_couplers_RDATA;
  assign S00_AXI_rid[11:0] = GPIC0_to_s00_couplers_RID;
  assign S00_AXI_rlast = GPIC0_to_s00_couplers_RLAST;
  assign S00_AXI_rresp[1:0] = GPIC0_to_s00_couplers_RRESP;
  assign S00_AXI_rvalid = GPIC0_to_s00_couplers_RVALID;
  assign S00_AXI_wready = GPIC0_to_s00_couplers_WREADY;
  assign m00_couplers_to_GPIC0_ARREADY = M00_AXI_arready;
  assign m00_couplers_to_GPIC0_AWREADY = M00_AXI_awready;
  assign m00_couplers_to_GPIC0_BRESP = M00_AXI_bresp[1:0];
  assign m00_couplers_to_GPIC0_BVALID = M00_AXI_bvalid;
  assign m00_couplers_to_GPIC0_RDATA = M00_AXI_rdata[31:0];
  assign m00_couplers_to_GPIC0_RRESP = M00_AXI_rresp[1:0];
  assign m00_couplers_to_GPIC0_RVALID = M00_AXI_rvalid;
  assign m00_couplers_to_GPIC0_WREADY = M00_AXI_wready;
  assign m01_couplers_to_GPIC0_ARREADY = M01_AXI_arready;
  assign m01_couplers_to_GPIC0_AWREADY = M01_AXI_awready;
  assign m01_couplers_to_GPIC0_BRESP = M01_AXI_bresp[1:0];
  assign m01_couplers_to_GPIC0_BVALID = M01_AXI_bvalid;
  assign m01_couplers_to_GPIC0_RDATA = M01_AXI_rdata[31:0];
  assign m01_couplers_to_GPIC0_RRESP = M01_AXI_rresp[1:0];
  assign m01_couplers_to_GPIC0_RVALID = M01_AXI_rvalid;
  assign m01_couplers_to_GPIC0_WREADY = M01_AXI_wready;
m00_couplers_imp_12DCAQQ m00_couplers
       (.M_ACLK(M00_ACLK_1),
        .M_ARESETN(M00_ARESETN_1),
        .M_AXI_araddr(m00_couplers_to_GPIC0_ARADDR),
        .M_AXI_arprot(m00_couplers_to_GPIC0_ARPROT),
        .M_AXI_arready(m00_couplers_to_GPIC0_ARREADY),
        .M_AXI_arvalid(m00_couplers_to_GPIC0_ARVALID),
        .M_AXI_awaddr(m00_couplers_to_GPIC0_AWADDR),
        .M_AXI_awprot(m00_couplers_to_GPIC0_AWPROT),
        .M_AXI_awready(m00_couplers_to_GPIC0_AWREADY),
        .M_AXI_awvalid(m00_couplers_to_GPIC0_AWVALID),
        .M_AXI_bready(m00_couplers_to_GPIC0_BREADY),
        .M_AXI_bresp(m00_couplers_to_GPIC0_BRESP),
        .M_AXI_bvalid(m00_couplers_to_GPIC0_BVALID),
        .M_AXI_rdata(m00_couplers_to_GPIC0_RDATA),
        .M_AXI_rready(m00_couplers_to_GPIC0_RREADY),
        .M_AXI_rresp(m00_couplers_to_GPIC0_RRESP),
        .M_AXI_rvalid(m00_couplers_to_GPIC0_RVALID),
        .M_AXI_wdata(m00_couplers_to_GPIC0_WDATA),
        .M_AXI_wready(m00_couplers_to_GPIC0_WREADY),
        .M_AXI_wstrb(m00_couplers_to_GPIC0_WSTRB),
        .M_AXI_wvalid(m00_couplers_to_GPIC0_WVALID),
        .S_ACLK(GPIC0_ACLK_net),
        .S_ARESETN(GPIC0_ARESETN_net),
        .S_AXI_araddr(xbar_to_m00_couplers_ARADDR),
        .S_AXI_arprot(xbar_to_m00_couplers_ARPROT),
        .S_AXI_arready(xbar_to_m00_couplers_ARREADY),
        .S_AXI_arvalid(xbar_to_m00_couplers_ARVALID),
        .S_AXI_awaddr(xbar_to_m00_couplers_AWADDR),
        .S_AXI_awprot(xbar_to_m00_couplers_AWPROT),
        .S_AXI_awready(xbar_to_m00_couplers_AWREADY),
        .S_AXI_awvalid(xbar_to_m00_couplers_AWVALID),
        .S_AXI_bready(xbar_to_m00_couplers_BREADY),
        .S_AXI_bresp(xbar_to_m00_couplers_BRESP),
        .S_AXI_bvalid(xbar_to_m00_couplers_BVALID),
        .S_AXI_rdata(xbar_to_m00_couplers_RDATA),
        .S_AXI_rready(xbar_to_m00_couplers_RREADY),
        .S_AXI_rresp(xbar_to_m00_couplers_RRESP),
        .S_AXI_rvalid(xbar_to_m00_couplers_RVALID),
        .S_AXI_wdata(xbar_to_m00_couplers_WDATA),
        .S_AXI_wready(xbar_to_m00_couplers_WREADY),
        .S_AXI_wstrb(xbar_to_m00_couplers_WSTRB),
        .S_AXI_wvalid(xbar_to_m00_couplers_WVALID));
m01_couplers_imp_S1U0SJ m01_couplers
       (.M_ACLK(M01_ACLK_1),
        .M_ARESETN(M01_ARESETN_1),
        .M_AXI_araddr(m01_couplers_to_GPIC0_ARADDR),
        .M_AXI_arprot(m01_couplers_to_GPIC0_ARPROT),
        .M_AXI_arready(m01_couplers_to_GPIC0_ARREADY),
        .M_AXI_arvalid(m01_couplers_to_GPIC0_ARVALID),
        .M_AXI_awaddr(m01_couplers_to_GPIC0_AWADDR),
        .M_AXI_awprot(m01_couplers_to_GPIC0_AWPROT),
        .M_AXI_awready(m01_couplers_to_GPIC0_AWREADY),
        .M_AXI_awvalid(m01_couplers_to_GPIC0_AWVALID),
        .M_AXI_bready(m01_couplers_to_GPIC0_BREADY),
        .M_AXI_bresp(m01_couplers_to_GPIC0_BRESP),
        .M_AXI_bvalid(m01_couplers_to_GPIC0_BVALID),
        .M_AXI_rdata(m01_couplers_to_GPIC0_RDATA),
        .M_AXI_rready(m01_couplers_to_GPIC0_RREADY),
        .M_AXI_rresp(m01_couplers_to_GPIC0_RRESP),
        .M_AXI_rvalid(m01_couplers_to_GPIC0_RVALID),
        .M_AXI_wdata(m01_couplers_to_GPIC0_WDATA),
        .M_AXI_wready(m01_couplers_to_GPIC0_WREADY),
        .M_AXI_wstrb(m01_couplers_to_GPIC0_WSTRB),
        .M_AXI_wvalid(m01_couplers_to_GPIC0_WVALID),
        .S_ACLK(GPIC0_ACLK_net),
        .S_ARESETN(GPIC0_ARESETN_net),
        .S_AXI_araddr(xbar_to_m01_couplers_ARADDR),
        .S_AXI_arprot(xbar_to_m01_couplers_ARPROT),
        .S_AXI_arready(xbar_to_m01_couplers_ARREADY),
        .S_AXI_arvalid(xbar_to_m01_couplers_ARVALID),
        .S_AXI_awaddr(xbar_to_m01_couplers_AWADDR),
        .S_AXI_awprot(xbar_to_m01_couplers_AWPROT),
        .S_AXI_awready(xbar_to_m01_couplers_AWREADY),
        .S_AXI_awvalid(xbar_to_m01_couplers_AWVALID),
        .S_AXI_bready(xbar_to_m01_couplers_BREADY),
        .S_AXI_bresp(xbar_to_m01_couplers_BRESP),
        .S_AXI_bvalid(xbar_to_m01_couplers_BVALID),
        .S_AXI_rdata(xbar_to_m01_couplers_RDATA),
        .S_AXI_rready(xbar_to_m01_couplers_RREADY),
        .S_AXI_rresp(xbar_to_m01_couplers_RRESP),
        .S_AXI_rvalid(xbar_to_m01_couplers_RVALID),
        .S_AXI_wdata(xbar_to_m01_couplers_WDATA),
        .S_AXI_wready(xbar_to_m01_couplers_WREADY),
        .S_AXI_wstrb(xbar_to_m01_couplers_WSTRB),
        .S_AXI_wvalid(xbar_to_m01_couplers_WVALID));
s00_couplers_imp_W195PC s00_couplers
       (.M_ACLK(GPIC0_ACLK_net),
        .M_ARESETN(GPIC0_ARESETN_net),
        .M_AXI_araddr(s00_couplers_to_xbar_ARADDR),
        .M_AXI_arprot(s00_couplers_to_xbar_ARPROT),
        .M_AXI_arready(s00_couplers_to_xbar_ARREADY),
        .M_AXI_arvalid(s00_couplers_to_xbar_ARVALID),
        .M_AXI_awaddr(s00_couplers_to_xbar_AWADDR),
        .M_AXI_awprot(s00_couplers_to_xbar_AWPROT),
        .M_AXI_awready(s00_couplers_to_xbar_AWREADY),
        .M_AXI_awvalid(s00_couplers_to_xbar_AWVALID),
        .M_AXI_bready(s00_couplers_to_xbar_BREADY),
        .M_AXI_bresp(s00_couplers_to_xbar_BRESP),
        .M_AXI_bvalid(s00_couplers_to_xbar_BVALID),
        .M_AXI_rdata(s00_couplers_to_xbar_RDATA),
        .M_AXI_rready(s00_couplers_to_xbar_RREADY),
        .M_AXI_rresp(s00_couplers_to_xbar_RRESP),
        .M_AXI_rvalid(s00_couplers_to_xbar_RVALID),
        .M_AXI_wdata(s00_couplers_to_xbar_WDATA),
        .M_AXI_wready(s00_couplers_to_xbar_WREADY),
        .M_AXI_wstrb(s00_couplers_to_xbar_WSTRB),
        .M_AXI_wvalid(s00_couplers_to_xbar_WVALID),
        .S_ACLK(S00_ACLK_1),
        .S_ARESETN(S00_ARESETN_1),
        .S_AXI_araddr(GPIC0_to_s00_couplers_ARADDR),
        .S_AXI_arburst(GPIC0_to_s00_couplers_ARBURST),
        .S_AXI_arcache(GPIC0_to_s00_couplers_ARCACHE),
        .S_AXI_arid(GPIC0_to_s00_couplers_ARID),
        .S_AXI_arlen(GPIC0_to_s00_couplers_ARLEN),
        .S_AXI_arlock(GPIC0_to_s00_couplers_ARLOCK),
        .S_AXI_arprot(GPIC0_to_s00_couplers_ARPROT),
        .S_AXI_arqos(GPIC0_to_s00_couplers_ARQOS),
        .S_AXI_arready(GPIC0_to_s00_couplers_ARREADY),
        .S_AXI_arsize(GPIC0_to_s00_couplers_ARSIZE),
        .S_AXI_arvalid(GPIC0_to_s00_couplers_ARVALID),
        .S_AXI_awaddr(GPIC0_to_s00_couplers_AWADDR),
        .S_AXI_awburst(GPIC0_to_s00_couplers_AWBURST),
        .S_AXI_awcache(GPIC0_to_s00_couplers_AWCACHE),
        .S_AXI_awid(GPIC0_to_s00_couplers_AWID),
        .S_AXI_awlen(GPIC0_to_s00_couplers_AWLEN),
        .S_AXI_awlock(GPIC0_to_s00_couplers_AWLOCK),
        .S_AXI_awprot(GPIC0_to_s00_couplers_AWPROT),
        .S_AXI_awqos(GPIC0_to_s00_couplers_AWQOS),
        .S_AXI_awready(GPIC0_to_s00_couplers_AWREADY),
        .S_AXI_awsize(GPIC0_to_s00_couplers_AWSIZE),
        .S_AXI_awvalid(GPIC0_to_s00_couplers_AWVALID),
        .S_AXI_bid(GPIC0_to_s00_couplers_BID),
        .S_AXI_bready(GPIC0_to_s00_couplers_BREADY),
        .S_AXI_bresp(GPIC0_to_s00_couplers_BRESP),
        .S_AXI_bvalid(GPIC0_to_s00_couplers_BVALID),
        .S_AXI_rdata(GPIC0_to_s00_couplers_RDATA),
        .S_AXI_rid(GPIC0_to_s00_couplers_RID),
        .S_AXI_rlast(GPIC0_to_s00_couplers_RLAST),
        .S_AXI_rready(GPIC0_to_s00_couplers_RREADY),
        .S_AXI_rresp(GPIC0_to_s00_couplers_RRESP),
        .S_AXI_rvalid(GPIC0_to_s00_couplers_RVALID),
        .S_AXI_wdata(GPIC0_to_s00_couplers_WDATA),
        .S_AXI_wid(GPIC0_to_s00_couplers_WID),
        .S_AXI_wlast(GPIC0_to_s00_couplers_WLAST),
        .S_AXI_wready(GPIC0_to_s00_couplers_WREADY),
        .S_AXI_wstrb(GPIC0_to_s00_couplers_WSTRB),
        .S_AXI_wvalid(GPIC0_to_s00_couplers_WVALID));
OpenSSD2_xbar_0 xbar
       (.aclk(GPIC0_ACLK_net),
        .aresetn(GPIC0_ARESETN_net),
        .m_axi_araddr({xbar_to_m01_couplers_ARADDR,xbar_to_m00_couplers_ARADDR}),
        .m_axi_arprot({xbar_to_m01_couplers_ARPROT,xbar_to_m00_couplers_ARPROT}),
        .m_axi_arready({xbar_to_m01_couplers_ARREADY,xbar_to_m00_couplers_ARREADY}),
        .m_axi_arvalid({xbar_to_m01_couplers_ARVALID,xbar_to_m00_couplers_ARVALID}),
        .m_axi_awaddr({xbar_to_m01_couplers_AWADDR,xbar_to_m00_couplers_AWADDR}),
        .m_axi_awprot({xbar_to_m01_couplers_AWPROT,xbar_to_m00_couplers_AWPROT}),
        .m_axi_awready({xbar_to_m01_couplers_AWREADY,xbar_to_m00_couplers_AWREADY}),
        .m_axi_awvalid({xbar_to_m01_couplers_AWVALID,xbar_to_m00_couplers_AWVALID}),
        .m_axi_bready({xbar_to_m01_couplers_BREADY,xbar_to_m00_couplers_BREADY}),
        .m_axi_bresp({xbar_to_m01_couplers_BRESP,xbar_to_m00_couplers_BRESP}),
        .m_axi_bvalid({xbar_to_m01_couplers_BVALID,xbar_to_m00_couplers_BVALID}),
        .m_axi_rdata({xbar_to_m01_couplers_RDATA,xbar_to_m00_couplers_RDATA}),
        .m_axi_rready({xbar_to_m01_couplers_RREADY,xbar_to_m00_couplers_RREADY}),
        .m_axi_rresp({xbar_to_m01_couplers_RRESP,xbar_to_m00_couplers_RRESP}),
        .m_axi_rvalid({xbar_to_m01_couplers_RVALID,xbar_to_m00_couplers_RVALID}),
        .m_axi_wdata({xbar_to_m01_couplers_WDATA,xbar_to_m00_couplers_WDATA}),
        .m_axi_wready({xbar_to_m01_couplers_WREADY,xbar_to_m00_couplers_WREADY}),
        .m_axi_wstrb({xbar_to_m01_couplers_WSTRB,xbar_to_m00_couplers_WSTRB}),
        .m_axi_wvalid({xbar_to_m01_couplers_WVALID,xbar_to_m00_couplers_WVALID}),
        .s_axi_araddr(s00_couplers_to_xbar_ARADDR),
        .s_axi_arprot(s00_couplers_to_xbar_ARPROT),
        .s_axi_arready(s00_couplers_to_xbar_ARREADY),
        .s_axi_arvalid(s00_couplers_to_xbar_ARVALID),
        .s_axi_awaddr(s00_couplers_to_xbar_AWADDR),
        .s_axi_awprot(s00_couplers_to_xbar_AWPROT),
        .s_axi_awready(s00_couplers_to_xbar_AWREADY),
        .s_axi_awvalid(s00_couplers_to_xbar_AWVALID),
        .s_axi_bready(s00_couplers_to_xbar_BREADY),
        .s_axi_bresp(s00_couplers_to_xbar_BRESP),
        .s_axi_bvalid(s00_couplers_to_xbar_BVALID),
        .s_axi_rdata(s00_couplers_to_xbar_RDATA),
        .s_axi_rready(s00_couplers_to_xbar_RREADY),
        .s_axi_rresp(s00_couplers_to_xbar_RRESP),
        .s_axi_rvalid(s00_couplers_to_xbar_RVALID),
        .s_axi_wdata(s00_couplers_to_xbar_WDATA),
        .s_axi_wready(s00_couplers_to_xbar_WREADY),
        .s_axi_wstrb(s00_couplers_to_xbar_WSTRB),
        .s_axi_wvalid(s00_couplers_to_xbar_WVALID));
endmodule

module OpenSSD2_axi_interconnect_0_1
   (ACLK,
    ARESETN,
    M00_ACLK,
    M00_ARESETN,
    M00_AXI_araddr,
    M00_AXI_arburst,
    M00_AXI_arcache,
    M00_AXI_arid,
    M00_AXI_arlen,
    M00_AXI_arlock,
    M00_AXI_arprot,
    M00_AXI_arqos,
    M00_AXI_arready,
    M00_AXI_arsize,
    M00_AXI_arvalid,
    M00_AXI_awaddr,
    M00_AXI_awburst,
    M00_AXI_awcache,
    M00_AXI_awid,
    M00_AXI_awlen,
    M00_AXI_awlock,
    M00_AXI_awprot,
    M00_AXI_awqos,
    M00_AXI_awready,
    M00_AXI_awsize,
    M00_AXI_awvalid,
    M00_AXI_bid,
    M00_AXI_bready,
    M00_AXI_bresp,
    M00_AXI_bvalid,
    M00_AXI_rdata,
    M00_AXI_rid,
    M00_AXI_rlast,
    M00_AXI_rready,
    M00_AXI_rresp,
    M00_AXI_rvalid,
    M00_AXI_wdata,
    M00_AXI_wid,
    M00_AXI_wlast,
    M00_AXI_wready,
    M00_AXI_wstrb,
    M00_AXI_wvalid,
    S00_ACLK,
    S00_ARESETN,
    S00_AXI_araddr,
    S00_AXI_arburst,
    S00_AXI_arcache,
    S00_AXI_arid,
    S00_AXI_arlen,
    S00_AXI_arlock,
    S00_AXI_arprot,
    S00_AXI_arqos,
    S00_AXI_arready,
    S00_AXI_arregion,
    S00_AXI_arsize,
    S00_AXI_aruser,
    S00_AXI_arvalid,
    S00_AXI_awaddr,
    S00_AXI_awburst,
    S00_AXI_awcache,
    S00_AXI_awid,
    S00_AXI_awlen,
    S00_AXI_awlock,
    S00_AXI_awprot,
    S00_AXI_awqos,
    S00_AXI_awready,
    S00_AXI_awregion,
    S00_AXI_awsize,
    S00_AXI_awuser,
    S00_AXI_awvalid,
    S00_AXI_bid,
    S00_AXI_bready,
    S00_AXI_bresp,
    S00_AXI_bvalid,
    S00_AXI_rdata,
    S00_AXI_rid,
    S00_AXI_rlast,
    S00_AXI_rready,
    S00_AXI_rresp,
    S00_AXI_ruser,
    S00_AXI_rvalid,
    S00_AXI_wdata,
    S00_AXI_wlast,
    S00_AXI_wready,
    S00_AXI_wstrb,
    S00_AXI_wuser,
    S00_AXI_wvalid);
  input ACLK;
  input [0:0]ARESETN;
  input M00_ACLK;
  input [0:0]M00_ARESETN;
  output [31:0]M00_AXI_araddr;
  output [1:0]M00_AXI_arburst;
  output [3:0]M00_AXI_arcache;
  output [0:0]M00_AXI_arid;
  output [3:0]M00_AXI_arlen;
  output [1:0]M00_AXI_arlock;
  output [2:0]M00_AXI_arprot;
  output [3:0]M00_AXI_arqos;
  input M00_AXI_arready;
  output [2:0]M00_AXI_arsize;
  output M00_AXI_arvalid;
  output [31:0]M00_AXI_awaddr;
  output [1:0]M00_AXI_awburst;
  output [3:0]M00_AXI_awcache;
  output [0:0]M00_AXI_awid;
  output [3:0]M00_AXI_awlen;
  output [1:0]M00_AXI_awlock;
  output [2:0]M00_AXI_awprot;
  output [3:0]M00_AXI_awqos;
  input M00_AXI_awready;
  output [2:0]M00_AXI_awsize;
  output M00_AXI_awvalid;
  input [0:0]M00_AXI_bid;
  output M00_AXI_bready;
  input [1:0]M00_AXI_bresp;
  input M00_AXI_bvalid;
  input [63:0]M00_AXI_rdata;
  input [0:0]M00_AXI_rid;
  input M00_AXI_rlast;
  output M00_AXI_rready;
  input [1:0]M00_AXI_rresp;
  input M00_AXI_rvalid;
  output [63:0]M00_AXI_wdata;
  output [0:0]M00_AXI_wid;
  output M00_AXI_wlast;
  input M00_AXI_wready;
  output [7:0]M00_AXI_wstrb;
  output M00_AXI_wvalid;
  input S00_ACLK;
  input [0:0]S00_ARESETN;
  input [31:0]S00_AXI_araddr;
  input [1:0]S00_AXI_arburst;
  input [3:0]S00_AXI_arcache;
  input [0:0]S00_AXI_arid;
  input [7:0]S00_AXI_arlen;
  input [0:0]S00_AXI_arlock;
  input [2:0]S00_AXI_arprot;
  input [3:0]S00_AXI_arqos;
  output S00_AXI_arready;
  input [3:0]S00_AXI_arregion;
  input [2:0]S00_AXI_arsize;
  input [0:0]S00_AXI_aruser;
  input S00_AXI_arvalid;
  input [31:0]S00_AXI_awaddr;
  input [1:0]S00_AXI_awburst;
  input [3:0]S00_AXI_awcache;
  input [0:0]S00_AXI_awid;
  input [7:0]S00_AXI_awlen;
  input [0:0]S00_AXI_awlock;
  input [2:0]S00_AXI_awprot;
  input [3:0]S00_AXI_awqos;
  output S00_AXI_awready;
  input [3:0]S00_AXI_awregion;
  input [2:0]S00_AXI_awsize;
  input [0:0]S00_AXI_awuser;
  input S00_AXI_awvalid;
  output [0:0]S00_AXI_bid;
  input S00_AXI_bready;
  output [1:0]S00_AXI_bresp;
  output S00_AXI_bvalid;
  output [63:0]S00_AXI_rdata;
  output [0:0]S00_AXI_rid;
  output S00_AXI_rlast;
  input S00_AXI_rready;
  output [1:0]S00_AXI_rresp;
  output [0:0]S00_AXI_ruser;
  output S00_AXI_rvalid;
  input [63:0]S00_AXI_wdata;
  input S00_AXI_wlast;
  output S00_AXI_wready;
  input [7:0]S00_AXI_wstrb;
  input [0:0]S00_AXI_wuser;
  input S00_AXI_wvalid;

  wire HPIC3_ACLK_net;
  wire [0:0]HPIC3_ARESETN_net;
  wire [31:0]HPIC3_to_s00_couplers_ARADDR;
  wire [1:0]HPIC3_to_s00_couplers_ARBURST;
  wire [3:0]HPIC3_to_s00_couplers_ARCACHE;
  wire [0:0]HPIC3_to_s00_couplers_ARID;
  wire [7:0]HPIC3_to_s00_couplers_ARLEN;
  wire [0:0]HPIC3_to_s00_couplers_ARLOCK;
  wire [2:0]HPIC3_to_s00_couplers_ARPROT;
  wire [3:0]HPIC3_to_s00_couplers_ARQOS;
  wire HPIC3_to_s00_couplers_ARREADY;
  wire [3:0]HPIC3_to_s00_couplers_ARREGION;
  wire [2:0]HPIC3_to_s00_couplers_ARSIZE;
  wire [0:0]HPIC3_to_s00_couplers_ARUSER;
  wire HPIC3_to_s00_couplers_ARVALID;
  wire [31:0]HPIC3_to_s00_couplers_AWADDR;
  wire [1:0]HPIC3_to_s00_couplers_AWBURST;
  wire [3:0]HPIC3_to_s00_couplers_AWCACHE;
  wire [0:0]HPIC3_to_s00_couplers_AWID;
  wire [7:0]HPIC3_to_s00_couplers_AWLEN;
  wire [0:0]HPIC3_to_s00_couplers_AWLOCK;
  wire [2:0]HPIC3_to_s00_couplers_AWPROT;
  wire [3:0]HPIC3_to_s00_couplers_AWQOS;
  wire HPIC3_to_s00_couplers_AWREADY;
  wire [3:0]HPIC3_to_s00_couplers_AWREGION;
  wire [2:0]HPIC3_to_s00_couplers_AWSIZE;
  wire [0:0]HPIC3_to_s00_couplers_AWUSER;
  wire HPIC3_to_s00_couplers_AWVALID;
  wire [0:0]HPIC3_to_s00_couplers_BID;
  wire HPIC3_to_s00_couplers_BREADY;
  wire [1:0]HPIC3_to_s00_couplers_BRESP;
  wire HPIC3_to_s00_couplers_BVALID;
  wire [63:0]HPIC3_to_s00_couplers_RDATA;
  wire [0:0]HPIC3_to_s00_couplers_RID;
  wire HPIC3_to_s00_couplers_RLAST;
  wire HPIC3_to_s00_couplers_RREADY;
  wire [1:0]HPIC3_to_s00_couplers_RRESP;
  wire [0:0]HPIC3_to_s00_couplers_RUSER;
  wire HPIC3_to_s00_couplers_RVALID;
  wire [63:0]HPIC3_to_s00_couplers_WDATA;
  wire HPIC3_to_s00_couplers_WLAST;
  wire HPIC3_to_s00_couplers_WREADY;
  wire [7:0]HPIC3_to_s00_couplers_WSTRB;
  wire [0:0]HPIC3_to_s00_couplers_WUSER;
  wire HPIC3_to_s00_couplers_WVALID;
  wire S00_ACLK_1;
  wire [0:0]S00_ARESETN_1;
  wire [31:0]s00_couplers_to_HPIC3_ARADDR;
  wire [1:0]s00_couplers_to_HPIC3_ARBURST;
  wire [3:0]s00_couplers_to_HPIC3_ARCACHE;
  wire [0:0]s00_couplers_to_HPIC3_ARID;
  wire [3:0]s00_couplers_to_HPIC3_ARLEN;
  wire [1:0]s00_couplers_to_HPIC3_ARLOCK;
  wire [2:0]s00_couplers_to_HPIC3_ARPROT;
  wire [3:0]s00_couplers_to_HPIC3_ARQOS;
  wire s00_couplers_to_HPIC3_ARREADY;
  wire [2:0]s00_couplers_to_HPIC3_ARSIZE;
  wire s00_couplers_to_HPIC3_ARVALID;
  wire [31:0]s00_couplers_to_HPIC3_AWADDR;
  wire [1:0]s00_couplers_to_HPIC3_AWBURST;
  wire [3:0]s00_couplers_to_HPIC3_AWCACHE;
  wire [0:0]s00_couplers_to_HPIC3_AWID;
  wire [3:0]s00_couplers_to_HPIC3_AWLEN;
  wire [1:0]s00_couplers_to_HPIC3_AWLOCK;
  wire [2:0]s00_couplers_to_HPIC3_AWPROT;
  wire [3:0]s00_couplers_to_HPIC3_AWQOS;
  wire s00_couplers_to_HPIC3_AWREADY;
  wire [2:0]s00_couplers_to_HPIC3_AWSIZE;
  wire s00_couplers_to_HPIC3_AWVALID;
  wire [0:0]s00_couplers_to_HPIC3_BID;
  wire s00_couplers_to_HPIC3_BREADY;
  wire [1:0]s00_couplers_to_HPIC3_BRESP;
  wire s00_couplers_to_HPIC3_BVALID;
  wire [63:0]s00_couplers_to_HPIC3_RDATA;
  wire [0:0]s00_couplers_to_HPIC3_RID;
  wire s00_couplers_to_HPIC3_RLAST;
  wire s00_couplers_to_HPIC3_RREADY;
  wire [1:0]s00_couplers_to_HPIC3_RRESP;
  wire s00_couplers_to_HPIC3_RVALID;
  wire [63:0]s00_couplers_to_HPIC3_WDATA;
  wire [0:0]s00_couplers_to_HPIC3_WID;
  wire s00_couplers_to_HPIC3_WLAST;
  wire s00_couplers_to_HPIC3_WREADY;
  wire [7:0]s00_couplers_to_HPIC3_WSTRB;
  wire s00_couplers_to_HPIC3_WVALID;

  assign HPIC3_ACLK_net = M00_ACLK;
  assign HPIC3_ARESETN_net = M00_ARESETN[0];
  assign HPIC3_to_s00_couplers_ARADDR = S00_AXI_araddr[31:0];
  assign HPIC3_to_s00_couplers_ARBURST = S00_AXI_arburst[1:0];
  assign HPIC3_to_s00_couplers_ARCACHE = S00_AXI_arcache[3:0];
  assign HPIC3_to_s00_couplers_ARID = S00_AXI_arid[0];
  assign HPIC3_to_s00_couplers_ARLEN = S00_AXI_arlen[7:0];
  assign HPIC3_to_s00_couplers_ARLOCK = S00_AXI_arlock[0];
  assign HPIC3_to_s00_couplers_ARPROT = S00_AXI_arprot[2:0];
  assign HPIC3_to_s00_couplers_ARQOS = S00_AXI_arqos[3:0];
  assign HPIC3_to_s00_couplers_ARREGION = S00_AXI_arregion[3:0];
  assign HPIC3_to_s00_couplers_ARSIZE = S00_AXI_arsize[2:0];
  assign HPIC3_to_s00_couplers_ARUSER = S00_AXI_aruser[0];
  assign HPIC3_to_s00_couplers_ARVALID = S00_AXI_arvalid;
  assign HPIC3_to_s00_couplers_AWADDR = S00_AXI_awaddr[31:0];
  assign HPIC3_to_s00_couplers_AWBURST = S00_AXI_awburst[1:0];
  assign HPIC3_to_s00_couplers_AWCACHE = S00_AXI_awcache[3:0];
  assign HPIC3_to_s00_couplers_AWID = S00_AXI_awid[0];
  assign HPIC3_to_s00_couplers_AWLEN = S00_AXI_awlen[7:0];
  assign HPIC3_to_s00_couplers_AWLOCK = S00_AXI_awlock[0];
  assign HPIC3_to_s00_couplers_AWPROT = S00_AXI_awprot[2:0];
  assign HPIC3_to_s00_couplers_AWQOS = S00_AXI_awqos[3:0];
  assign HPIC3_to_s00_couplers_AWREGION = S00_AXI_awregion[3:0];
  assign HPIC3_to_s00_couplers_AWSIZE = S00_AXI_awsize[2:0];
  assign HPIC3_to_s00_couplers_AWUSER = S00_AXI_awuser[0];
  assign HPIC3_to_s00_couplers_AWVALID = S00_AXI_awvalid;
  assign HPIC3_to_s00_couplers_BREADY = S00_AXI_bready;
  assign HPIC3_to_s00_couplers_RREADY = S00_AXI_rready;
  assign HPIC3_to_s00_couplers_WDATA = S00_AXI_wdata[63:0];
  assign HPIC3_to_s00_couplers_WLAST = S00_AXI_wlast;
  assign HPIC3_to_s00_couplers_WSTRB = S00_AXI_wstrb[7:0];
  assign HPIC3_to_s00_couplers_WUSER = S00_AXI_wuser[0];
  assign HPIC3_to_s00_couplers_WVALID = S00_AXI_wvalid;
  assign M00_AXI_araddr[31:0] = s00_couplers_to_HPIC3_ARADDR;
  assign M00_AXI_arburst[1:0] = s00_couplers_to_HPIC3_ARBURST;
  assign M00_AXI_arcache[3:0] = s00_couplers_to_HPIC3_ARCACHE;
  assign M00_AXI_arid[0] = s00_couplers_to_HPIC3_ARID;
  assign M00_AXI_arlen[3:0] = s00_couplers_to_HPIC3_ARLEN;
  assign M00_AXI_arlock[1:0] = s00_couplers_to_HPIC3_ARLOCK;
  assign M00_AXI_arprot[2:0] = s00_couplers_to_HPIC3_ARPROT;
  assign M00_AXI_arqos[3:0] = s00_couplers_to_HPIC3_ARQOS;
  assign M00_AXI_arsize[2:0] = s00_couplers_to_HPIC3_ARSIZE;
  assign M00_AXI_arvalid = s00_couplers_to_HPIC3_ARVALID;
  assign M00_AXI_awaddr[31:0] = s00_couplers_to_HPIC3_AWADDR;
  assign M00_AXI_awburst[1:0] = s00_couplers_to_HPIC3_AWBURST;
  assign M00_AXI_awcache[3:0] = s00_couplers_to_HPIC3_AWCACHE;
  assign M00_AXI_awid[0] = s00_couplers_to_HPIC3_AWID;
  assign M00_AXI_awlen[3:0] = s00_couplers_to_HPIC3_AWLEN;
  assign M00_AXI_awlock[1:0] = s00_couplers_to_HPIC3_AWLOCK;
  assign M00_AXI_awprot[2:0] = s00_couplers_to_HPIC3_AWPROT;
  assign M00_AXI_awqos[3:0] = s00_couplers_to_HPIC3_AWQOS;
  assign M00_AXI_awsize[2:0] = s00_couplers_to_HPIC3_AWSIZE;
  assign M00_AXI_awvalid = s00_couplers_to_HPIC3_AWVALID;
  assign M00_AXI_bready = s00_couplers_to_HPIC3_BREADY;
  assign M00_AXI_rready = s00_couplers_to_HPIC3_RREADY;
  assign M00_AXI_wdata[63:0] = s00_couplers_to_HPIC3_WDATA;
  assign M00_AXI_wid[0] = s00_couplers_to_HPIC3_WID;
  assign M00_AXI_wlast = s00_couplers_to_HPIC3_WLAST;
  assign M00_AXI_wstrb[7:0] = s00_couplers_to_HPIC3_WSTRB;
  assign M00_AXI_wvalid = s00_couplers_to_HPIC3_WVALID;
  assign S00_ACLK_1 = S00_ACLK;
  assign S00_ARESETN_1 = S00_ARESETN[0];
  assign S00_AXI_arready = HPIC3_to_s00_couplers_ARREADY;
  assign S00_AXI_awready = HPIC3_to_s00_couplers_AWREADY;
  assign S00_AXI_bid[0] = HPIC3_to_s00_couplers_BID;
  assign S00_AXI_bresp[1:0] = HPIC3_to_s00_couplers_BRESP;
  assign S00_AXI_bvalid = HPIC3_to_s00_couplers_BVALID;
  assign S00_AXI_rdata[63:0] = HPIC3_to_s00_couplers_RDATA;
  assign S00_AXI_rid[0] = HPIC3_to_s00_couplers_RID;
  assign S00_AXI_rlast = HPIC3_to_s00_couplers_RLAST;
  assign S00_AXI_rresp[1:0] = HPIC3_to_s00_couplers_RRESP;
  assign S00_AXI_ruser[0] = HPIC3_to_s00_couplers_RUSER;
  assign S00_AXI_rvalid = HPIC3_to_s00_couplers_RVALID;
  assign S00_AXI_wready = HPIC3_to_s00_couplers_WREADY;
  assign s00_couplers_to_HPIC3_ARREADY = M00_AXI_arready;
  assign s00_couplers_to_HPIC3_AWREADY = M00_AXI_awready;
  assign s00_couplers_to_HPIC3_BID = M00_AXI_bid[0];
  assign s00_couplers_to_HPIC3_BRESP = M00_AXI_bresp[1:0];
  assign s00_couplers_to_HPIC3_BVALID = M00_AXI_bvalid;
  assign s00_couplers_to_HPIC3_RDATA = M00_AXI_rdata[63:0];
  assign s00_couplers_to_HPIC3_RID = M00_AXI_rid[0];
  assign s00_couplers_to_HPIC3_RLAST = M00_AXI_rlast;
  assign s00_couplers_to_HPIC3_RRESP = M00_AXI_rresp[1:0];
  assign s00_couplers_to_HPIC3_RVALID = M00_AXI_rvalid;
  assign s00_couplers_to_HPIC3_WREADY = M00_AXI_wready;
s00_couplers_imp_1JGQSCA s00_couplers
       (.M_ACLK(HPIC3_ACLK_net),
        .M_ARESETN(HPIC3_ARESETN_net),
        .M_AXI_araddr(s00_couplers_to_HPIC3_ARADDR),
        .M_AXI_arburst(s00_couplers_to_HPIC3_ARBURST),
        .M_AXI_arcache(s00_couplers_to_HPIC3_ARCACHE),
        .M_AXI_arid(s00_couplers_to_HPIC3_ARID),
        .M_AXI_arlen(s00_couplers_to_HPIC3_ARLEN),
        .M_AXI_arlock(s00_couplers_to_HPIC3_ARLOCK),
        .M_AXI_arprot(s00_couplers_to_HPIC3_ARPROT),
        .M_AXI_arqos(s00_couplers_to_HPIC3_ARQOS),
        .M_AXI_arready(s00_couplers_to_HPIC3_ARREADY),
        .M_AXI_arsize(s00_couplers_to_HPIC3_ARSIZE),
        .M_AXI_arvalid(s00_couplers_to_HPIC3_ARVALID),
        .M_AXI_awaddr(s00_couplers_to_HPIC3_AWADDR),
        .M_AXI_awburst(s00_couplers_to_HPIC3_AWBURST),
        .M_AXI_awcache(s00_couplers_to_HPIC3_AWCACHE),
        .M_AXI_awid(s00_couplers_to_HPIC3_AWID),
        .M_AXI_awlen(s00_couplers_to_HPIC3_AWLEN),
        .M_AXI_awlock(s00_couplers_to_HPIC3_AWLOCK),
        .M_AXI_awprot(s00_couplers_to_HPIC3_AWPROT),
        .M_AXI_awqos(s00_couplers_to_HPIC3_AWQOS),
        .M_AXI_awready(s00_couplers_to_HPIC3_AWREADY),
        .M_AXI_awsize(s00_couplers_to_HPIC3_AWSIZE),
        .M_AXI_awvalid(s00_couplers_to_HPIC3_AWVALID),
        .M_AXI_bid(s00_couplers_to_HPIC3_BID),
        .M_AXI_bready(s00_couplers_to_HPIC3_BREADY),
        .M_AXI_bresp(s00_couplers_to_HPIC3_BRESP),
        .M_AXI_bvalid(s00_couplers_to_HPIC3_BVALID),
        .M_AXI_rdata(s00_couplers_to_HPIC3_RDATA),
        .M_AXI_rid(s00_couplers_to_HPIC3_RID),
        .M_AXI_rlast(s00_couplers_to_HPIC3_RLAST),
        .M_AXI_rready(s00_couplers_to_HPIC3_RREADY),
        .M_AXI_rresp(s00_couplers_to_HPIC3_RRESP),
        .M_AXI_rvalid(s00_couplers_to_HPIC3_RVALID),
        .M_AXI_wdata(s00_couplers_to_HPIC3_WDATA),
        .M_AXI_wid(s00_couplers_to_HPIC3_WID),
        .M_AXI_wlast(s00_couplers_to_HPIC3_WLAST),
        .M_AXI_wready(s00_couplers_to_HPIC3_WREADY),
        .M_AXI_wstrb(s00_couplers_to_HPIC3_WSTRB),
        .M_AXI_wvalid(s00_couplers_to_HPIC3_WVALID),
        .S_ACLK(S00_ACLK_1),
        .S_ARESETN(S00_ARESETN_1),
        .S_AXI_araddr(HPIC3_to_s00_couplers_ARADDR),
        .S_AXI_arburst(HPIC3_to_s00_couplers_ARBURST),
        .S_AXI_arcache(HPIC3_to_s00_couplers_ARCACHE),
        .S_AXI_arid(HPIC3_to_s00_couplers_ARID),
        .S_AXI_arlen(HPIC3_to_s00_couplers_ARLEN),
        .S_AXI_arlock(HPIC3_to_s00_couplers_ARLOCK),
        .S_AXI_arprot(HPIC3_to_s00_couplers_ARPROT),
        .S_AXI_arqos(HPIC3_to_s00_couplers_ARQOS),
        .S_AXI_arready(HPIC3_to_s00_couplers_ARREADY),
        .S_AXI_arregion(HPIC3_to_s00_couplers_ARREGION),
        .S_AXI_arsize(HPIC3_to_s00_couplers_ARSIZE),
        .S_AXI_aruser(HPIC3_to_s00_couplers_ARUSER),
        .S_AXI_arvalid(HPIC3_to_s00_couplers_ARVALID),
        .S_AXI_awaddr(HPIC3_to_s00_couplers_AWADDR),
        .S_AXI_awburst(HPIC3_to_s00_couplers_AWBURST),
        .S_AXI_awcache(HPIC3_to_s00_couplers_AWCACHE),
        .S_AXI_awid(HPIC3_to_s00_couplers_AWID),
        .S_AXI_awlen(HPIC3_to_s00_couplers_AWLEN),
        .S_AXI_awlock(HPIC3_to_s00_couplers_AWLOCK),
        .S_AXI_awprot(HPIC3_to_s00_couplers_AWPROT),
        .S_AXI_awqos(HPIC3_to_s00_couplers_AWQOS),
        .S_AXI_awready(HPIC3_to_s00_couplers_AWREADY),
        .S_AXI_awregion(HPIC3_to_s00_couplers_AWREGION),
        .S_AXI_awsize(HPIC3_to_s00_couplers_AWSIZE),
        .S_AXI_awuser(HPIC3_to_s00_couplers_AWUSER),
        .S_AXI_awvalid(HPIC3_to_s00_couplers_AWVALID),
        .S_AXI_bid(HPIC3_to_s00_couplers_BID),
        .S_AXI_bready(HPIC3_to_s00_couplers_BREADY),
        .S_AXI_bresp(HPIC3_to_s00_couplers_BRESP),
        .S_AXI_bvalid(HPIC3_to_s00_couplers_BVALID),
        .S_AXI_rdata(HPIC3_to_s00_couplers_RDATA),
        .S_AXI_rid(HPIC3_to_s00_couplers_RID),
        .S_AXI_rlast(HPIC3_to_s00_couplers_RLAST),
        .S_AXI_rready(HPIC3_to_s00_couplers_RREADY),
        .S_AXI_rresp(HPIC3_to_s00_couplers_RRESP),
        .S_AXI_ruser(HPIC3_to_s00_couplers_RUSER),
        .S_AXI_rvalid(HPIC3_to_s00_couplers_RVALID),
        .S_AXI_wdata(HPIC3_to_s00_couplers_WDATA),
        .S_AXI_wlast(HPIC3_to_s00_couplers_WLAST),
        .S_AXI_wready(HPIC3_to_s00_couplers_WREADY),
        .S_AXI_wstrb(HPIC3_to_s00_couplers_WSTRB),
        .S_AXI_wuser(HPIC3_to_s00_couplers_WUSER),
        .S_AXI_wvalid(HPIC3_to_s00_couplers_WVALID));
endmodule

module OpenSSD2_axi_interconnect_0_2
   (ACLK,
    ARESETN,
    M00_ACLK,
    M00_ARESETN,
    M00_AXI_araddr,
    M00_AXI_arprot,
    M00_AXI_arready,
    M00_AXI_arvalid,
    M00_AXI_awaddr,
    M00_AXI_awprot,
    M00_AXI_awready,
    M00_AXI_awvalid,
    M00_AXI_bready,
    M00_AXI_bresp,
    M00_AXI_bvalid,
    M00_AXI_rdata,
    M00_AXI_rready,
    M00_AXI_rresp,
    M00_AXI_rvalid,
    M00_AXI_wdata,
    M00_AXI_wready,
    M00_AXI_wstrb,
    M00_AXI_wvalid,
    S00_ACLK,
    S00_ARESETN,
    S00_AXI_araddr,
    S00_AXI_arburst,
    S00_AXI_arcache,
    S00_AXI_arid,
    S00_AXI_arlen,
    S00_AXI_arlock,
    S00_AXI_arprot,
    S00_AXI_arqos,
    S00_AXI_arready,
    S00_AXI_arsize,
    S00_AXI_arvalid,
    S00_AXI_awaddr,
    S00_AXI_awburst,
    S00_AXI_awcache,
    S00_AXI_awid,
    S00_AXI_awlen,
    S00_AXI_awlock,
    S00_AXI_awprot,
    S00_AXI_awqos,
    S00_AXI_awready,
    S00_AXI_awsize,
    S00_AXI_awvalid,
    S00_AXI_bid,
    S00_AXI_bready,
    S00_AXI_bresp,
    S00_AXI_bvalid,
    S00_AXI_rdata,
    S00_AXI_rid,
    S00_AXI_rlast,
    S00_AXI_rready,
    S00_AXI_rresp,
    S00_AXI_rvalid,
    S00_AXI_wdata,
    S00_AXI_wid,
    S00_AXI_wlast,
    S00_AXI_wready,
    S00_AXI_wstrb,
    S00_AXI_wvalid);
  input ACLK;
  input [0:0]ARESETN;
  input M00_ACLK;
  input [0:0]M00_ARESETN;
  output [31:0]M00_AXI_araddr;
  output [2:0]M00_AXI_arprot;
  input M00_AXI_arready;
  output M00_AXI_arvalid;
  output [31:0]M00_AXI_awaddr;
  output [2:0]M00_AXI_awprot;
  input M00_AXI_awready;
  output M00_AXI_awvalid;
  output M00_AXI_bready;
  input [1:0]M00_AXI_bresp;
  input M00_AXI_bvalid;
  input [31:0]M00_AXI_rdata;
  output M00_AXI_rready;
  input [1:0]M00_AXI_rresp;
  input M00_AXI_rvalid;
  output [31:0]M00_AXI_wdata;
  input M00_AXI_wready;
  output [3:0]M00_AXI_wstrb;
  output M00_AXI_wvalid;
  input S00_ACLK;
  input [0:0]S00_ARESETN;
  input [31:0]S00_AXI_araddr;
  input [1:0]S00_AXI_arburst;
  input [3:0]S00_AXI_arcache;
  input [11:0]S00_AXI_arid;
  input [3:0]S00_AXI_arlen;
  input [1:0]S00_AXI_arlock;
  input [2:0]S00_AXI_arprot;
  input [3:0]S00_AXI_arqos;
  output S00_AXI_arready;
  input [2:0]S00_AXI_arsize;
  input S00_AXI_arvalid;
  input [31:0]S00_AXI_awaddr;
  input [1:0]S00_AXI_awburst;
  input [3:0]S00_AXI_awcache;
  input [11:0]S00_AXI_awid;
  input [3:0]S00_AXI_awlen;
  input [1:0]S00_AXI_awlock;
  input [2:0]S00_AXI_awprot;
  input [3:0]S00_AXI_awqos;
  output S00_AXI_awready;
  input [2:0]S00_AXI_awsize;
  input S00_AXI_awvalid;
  output [11:0]S00_AXI_bid;
  input S00_AXI_bready;
  output [1:0]S00_AXI_bresp;
  output S00_AXI_bvalid;
  output [31:0]S00_AXI_rdata;
  output [11:0]S00_AXI_rid;
  output S00_AXI_rlast;
  input S00_AXI_rready;
  output [1:0]S00_AXI_rresp;
  output S00_AXI_rvalid;
  input [31:0]S00_AXI_wdata;
  input [11:0]S00_AXI_wid;
  input S00_AXI_wlast;
  output S00_AXI_wready;
  input [3:0]S00_AXI_wstrb;
  input S00_AXI_wvalid;

  wire GPIC1_ACLK_net;
  wire [0:0]GPIC1_ARESETN_net;
  wire [31:0]GPIC1_to_s00_couplers_ARADDR;
  wire [1:0]GPIC1_to_s00_couplers_ARBURST;
  wire [3:0]GPIC1_to_s00_couplers_ARCACHE;
  wire [11:0]GPIC1_to_s00_couplers_ARID;
  wire [3:0]GPIC1_to_s00_couplers_ARLEN;
  wire [1:0]GPIC1_to_s00_couplers_ARLOCK;
  wire [2:0]GPIC1_to_s00_couplers_ARPROT;
  wire [3:0]GPIC1_to_s00_couplers_ARQOS;
  wire GPIC1_to_s00_couplers_ARREADY;
  wire [2:0]GPIC1_to_s00_couplers_ARSIZE;
  wire GPIC1_to_s00_couplers_ARVALID;
  wire [31:0]GPIC1_to_s00_couplers_AWADDR;
  wire [1:0]GPIC1_to_s00_couplers_AWBURST;
  wire [3:0]GPIC1_to_s00_couplers_AWCACHE;
  wire [11:0]GPIC1_to_s00_couplers_AWID;
  wire [3:0]GPIC1_to_s00_couplers_AWLEN;
  wire [1:0]GPIC1_to_s00_couplers_AWLOCK;
  wire [2:0]GPIC1_to_s00_couplers_AWPROT;
  wire [3:0]GPIC1_to_s00_couplers_AWQOS;
  wire GPIC1_to_s00_couplers_AWREADY;
  wire [2:0]GPIC1_to_s00_couplers_AWSIZE;
  wire GPIC1_to_s00_couplers_AWVALID;
  wire [11:0]GPIC1_to_s00_couplers_BID;
  wire GPIC1_to_s00_couplers_BREADY;
  wire [1:0]GPIC1_to_s00_couplers_BRESP;
  wire GPIC1_to_s00_couplers_BVALID;
  wire [31:0]GPIC1_to_s00_couplers_RDATA;
  wire [11:0]GPIC1_to_s00_couplers_RID;
  wire GPIC1_to_s00_couplers_RLAST;
  wire GPIC1_to_s00_couplers_RREADY;
  wire [1:0]GPIC1_to_s00_couplers_RRESP;
  wire GPIC1_to_s00_couplers_RVALID;
  wire [31:0]GPIC1_to_s00_couplers_WDATA;
  wire [11:0]GPIC1_to_s00_couplers_WID;
  wire GPIC1_to_s00_couplers_WLAST;
  wire GPIC1_to_s00_couplers_WREADY;
  wire [3:0]GPIC1_to_s00_couplers_WSTRB;
  wire GPIC1_to_s00_couplers_WVALID;
  wire S00_ACLK_1;
  wire [0:0]S00_ARESETN_1;
  wire [31:0]s00_couplers_to_GPIC1_ARADDR;
  wire [2:0]s00_couplers_to_GPIC1_ARPROT;
  wire s00_couplers_to_GPIC1_ARREADY;
  wire s00_couplers_to_GPIC1_ARVALID;
  wire [31:0]s00_couplers_to_GPIC1_AWADDR;
  wire [2:0]s00_couplers_to_GPIC1_AWPROT;
  wire s00_couplers_to_GPIC1_AWREADY;
  wire s00_couplers_to_GPIC1_AWVALID;
  wire s00_couplers_to_GPIC1_BREADY;
  wire [1:0]s00_couplers_to_GPIC1_BRESP;
  wire s00_couplers_to_GPIC1_BVALID;
  wire [31:0]s00_couplers_to_GPIC1_RDATA;
  wire s00_couplers_to_GPIC1_RREADY;
  wire [1:0]s00_couplers_to_GPIC1_RRESP;
  wire s00_couplers_to_GPIC1_RVALID;
  wire [31:0]s00_couplers_to_GPIC1_WDATA;
  wire s00_couplers_to_GPIC1_WREADY;
  wire [3:0]s00_couplers_to_GPIC1_WSTRB;
  wire s00_couplers_to_GPIC1_WVALID;

  assign GPIC1_ACLK_net = M00_ACLK;
  assign GPIC1_ARESETN_net = M00_ARESETN[0];
  assign GPIC1_to_s00_couplers_ARADDR = S00_AXI_araddr[31:0];
  assign GPIC1_to_s00_couplers_ARBURST = S00_AXI_arburst[1:0];
  assign GPIC1_to_s00_couplers_ARCACHE = S00_AXI_arcache[3:0];
  assign GPIC1_to_s00_couplers_ARID = S00_AXI_arid[11:0];
  assign GPIC1_to_s00_couplers_ARLEN = S00_AXI_arlen[3:0];
  assign GPIC1_to_s00_couplers_ARLOCK = S00_AXI_arlock[1:0];
  assign GPIC1_to_s00_couplers_ARPROT = S00_AXI_arprot[2:0];
  assign GPIC1_to_s00_couplers_ARQOS = S00_AXI_arqos[3:0];
  assign GPIC1_to_s00_couplers_ARSIZE = S00_AXI_arsize[2:0];
  assign GPIC1_to_s00_couplers_ARVALID = S00_AXI_arvalid;
  assign GPIC1_to_s00_couplers_AWADDR = S00_AXI_awaddr[31:0];
  assign GPIC1_to_s00_couplers_AWBURST = S00_AXI_awburst[1:0];
  assign GPIC1_to_s00_couplers_AWCACHE = S00_AXI_awcache[3:0];
  assign GPIC1_to_s00_couplers_AWID = S00_AXI_awid[11:0];
  assign GPIC1_to_s00_couplers_AWLEN = S00_AXI_awlen[3:0];
  assign GPIC1_to_s00_couplers_AWLOCK = S00_AXI_awlock[1:0];
  assign GPIC1_to_s00_couplers_AWPROT = S00_AXI_awprot[2:0];
  assign GPIC1_to_s00_couplers_AWQOS = S00_AXI_awqos[3:0];
  assign GPIC1_to_s00_couplers_AWSIZE = S00_AXI_awsize[2:0];
  assign GPIC1_to_s00_couplers_AWVALID = S00_AXI_awvalid;
  assign GPIC1_to_s00_couplers_BREADY = S00_AXI_bready;
  assign GPIC1_to_s00_couplers_RREADY = S00_AXI_rready;
  assign GPIC1_to_s00_couplers_WDATA = S00_AXI_wdata[31:0];
  assign GPIC1_to_s00_couplers_WID = S00_AXI_wid[11:0];
  assign GPIC1_to_s00_couplers_WLAST = S00_AXI_wlast;
  assign GPIC1_to_s00_couplers_WSTRB = S00_AXI_wstrb[3:0];
  assign GPIC1_to_s00_couplers_WVALID = S00_AXI_wvalid;
  assign M00_AXI_araddr[31:0] = s00_couplers_to_GPIC1_ARADDR;
  assign M00_AXI_arprot[2:0] = s00_couplers_to_GPIC1_ARPROT;
  assign M00_AXI_arvalid = s00_couplers_to_GPIC1_ARVALID;
  assign M00_AXI_awaddr[31:0] = s00_couplers_to_GPIC1_AWADDR;
  assign M00_AXI_awprot[2:0] = s00_couplers_to_GPIC1_AWPROT;
  assign M00_AXI_awvalid = s00_couplers_to_GPIC1_AWVALID;
  assign M00_AXI_bready = s00_couplers_to_GPIC1_BREADY;
  assign M00_AXI_rready = s00_couplers_to_GPIC1_RREADY;
  assign M00_AXI_wdata[31:0] = s00_couplers_to_GPIC1_WDATA;
  assign M00_AXI_wstrb[3:0] = s00_couplers_to_GPIC1_WSTRB;
  assign M00_AXI_wvalid = s00_couplers_to_GPIC1_WVALID;
  assign S00_ACLK_1 = S00_ACLK;
  assign S00_ARESETN_1 = S00_ARESETN[0];
  assign S00_AXI_arready = GPIC1_to_s00_couplers_ARREADY;
  assign S00_AXI_awready = GPIC1_to_s00_couplers_AWREADY;
  assign S00_AXI_bid[11:0] = GPIC1_to_s00_couplers_BID;
  assign S00_AXI_bresp[1:0] = GPIC1_to_s00_couplers_BRESP;
  assign S00_AXI_bvalid = GPIC1_to_s00_couplers_BVALID;
  assign S00_AXI_rdata[31:0] = GPIC1_to_s00_couplers_RDATA;
  assign S00_AXI_rid[11:0] = GPIC1_to_s00_couplers_RID;
  assign S00_AXI_rlast = GPIC1_to_s00_couplers_RLAST;
  assign S00_AXI_rresp[1:0] = GPIC1_to_s00_couplers_RRESP;
  assign S00_AXI_rvalid = GPIC1_to_s00_couplers_RVALID;
  assign S00_AXI_wready = GPIC1_to_s00_couplers_WREADY;
  assign s00_couplers_to_GPIC1_ARREADY = M00_AXI_arready;
  assign s00_couplers_to_GPIC1_AWREADY = M00_AXI_awready;
  assign s00_couplers_to_GPIC1_BRESP = M00_AXI_bresp[1:0];
  assign s00_couplers_to_GPIC1_BVALID = M00_AXI_bvalid;
  assign s00_couplers_to_GPIC1_RDATA = M00_AXI_rdata[31:0];
  assign s00_couplers_to_GPIC1_RRESP = M00_AXI_rresp[1:0];
  assign s00_couplers_to_GPIC1_RVALID = M00_AXI_rvalid;
  assign s00_couplers_to_GPIC1_WREADY = M00_AXI_wready;
s00_couplers_imp_RUHP0G s00_couplers
       (.M_ACLK(GPIC1_ACLK_net),
        .M_ARESETN(GPIC1_ARESETN_net),
        .M_AXI_araddr(s00_couplers_to_GPIC1_ARADDR),
        .M_AXI_arprot(s00_couplers_to_GPIC1_ARPROT),
        .M_AXI_arready(s00_couplers_to_GPIC1_ARREADY),
        .M_AXI_arvalid(s00_couplers_to_GPIC1_ARVALID),
        .M_AXI_awaddr(s00_couplers_to_GPIC1_AWADDR),
        .M_AXI_awprot(s00_couplers_to_GPIC1_AWPROT),
        .M_AXI_awready(s00_couplers_to_GPIC1_AWREADY),
        .M_AXI_awvalid(s00_couplers_to_GPIC1_AWVALID),
        .M_AXI_bready(s00_couplers_to_GPIC1_BREADY),
        .M_AXI_bresp(s00_couplers_to_GPIC1_BRESP),
        .M_AXI_bvalid(s00_couplers_to_GPIC1_BVALID),
        .M_AXI_rdata(s00_couplers_to_GPIC1_RDATA),
        .M_AXI_rready(s00_couplers_to_GPIC1_RREADY),
        .M_AXI_rresp(s00_couplers_to_GPIC1_RRESP),
        .M_AXI_rvalid(s00_couplers_to_GPIC1_RVALID),
        .M_AXI_wdata(s00_couplers_to_GPIC1_WDATA),
        .M_AXI_wready(s00_couplers_to_GPIC1_WREADY),
        .M_AXI_wstrb(s00_couplers_to_GPIC1_WSTRB),
        .M_AXI_wvalid(s00_couplers_to_GPIC1_WVALID),
        .S_ACLK(S00_ACLK_1),
        .S_ARESETN(S00_ARESETN_1),
        .S_AXI_araddr(GPIC1_to_s00_couplers_ARADDR),
        .S_AXI_arburst(GPIC1_to_s00_couplers_ARBURST),
        .S_AXI_arcache(GPIC1_to_s00_couplers_ARCACHE),
        .S_AXI_arid(GPIC1_to_s00_couplers_ARID),
        .S_AXI_arlen(GPIC1_to_s00_couplers_ARLEN),
        .S_AXI_arlock(GPIC1_to_s00_couplers_ARLOCK),
        .S_AXI_arprot(GPIC1_to_s00_couplers_ARPROT),
        .S_AXI_arqos(GPIC1_to_s00_couplers_ARQOS),
        .S_AXI_arready(GPIC1_to_s00_couplers_ARREADY),
        .S_AXI_arsize(GPIC1_to_s00_couplers_ARSIZE),
        .S_AXI_arvalid(GPIC1_to_s00_couplers_ARVALID),
        .S_AXI_awaddr(GPIC1_to_s00_couplers_AWADDR),
        .S_AXI_awburst(GPIC1_to_s00_couplers_AWBURST),
        .S_AXI_awcache(GPIC1_to_s00_couplers_AWCACHE),
        .S_AXI_awid(GPIC1_to_s00_couplers_AWID),
        .S_AXI_awlen(GPIC1_to_s00_couplers_AWLEN),
        .S_AXI_awlock(GPIC1_to_s00_couplers_AWLOCK),
        .S_AXI_awprot(GPIC1_to_s00_couplers_AWPROT),
        .S_AXI_awqos(GPIC1_to_s00_couplers_AWQOS),
        .S_AXI_awready(GPIC1_to_s00_couplers_AWREADY),
        .S_AXI_awsize(GPIC1_to_s00_couplers_AWSIZE),
        .S_AXI_awvalid(GPIC1_to_s00_couplers_AWVALID),
        .S_AXI_bid(GPIC1_to_s00_couplers_BID),
        .S_AXI_bready(GPIC1_to_s00_couplers_BREADY),
        .S_AXI_bresp(GPIC1_to_s00_couplers_BRESP),
        .S_AXI_bvalid(GPIC1_to_s00_couplers_BVALID),
        .S_AXI_rdata(GPIC1_to_s00_couplers_RDATA),
        .S_AXI_rid(GPIC1_to_s00_couplers_RID),
        .S_AXI_rlast(GPIC1_to_s00_couplers_RLAST),
        .S_AXI_rready(GPIC1_to_s00_couplers_RREADY),
        .S_AXI_rresp(GPIC1_to_s00_couplers_RRESP),
        .S_AXI_rvalid(GPIC1_to_s00_couplers_RVALID),
        .S_AXI_wdata(GPIC1_to_s00_couplers_WDATA),
        .S_AXI_wid(GPIC1_to_s00_couplers_WID),
        .S_AXI_wlast(GPIC1_to_s00_couplers_WLAST),
        .S_AXI_wready(GPIC1_to_s00_couplers_WREADY),
        .S_AXI_wstrb(GPIC1_to_s00_couplers_WSTRB),
        .S_AXI_wvalid(GPIC1_to_s00_couplers_WVALID));
endmodule

module OpenSSD2_axi_interconnect_0_3
   (ACLK,
    ARESETN,
    M00_ACLK,
    M00_ARESETN,
    M00_AXI_araddr,
    M00_AXI_arburst,
    M00_AXI_arcache,
    M00_AXI_arid,
    M00_AXI_arlen,
    M00_AXI_arlock,
    M00_AXI_arprot,
    M00_AXI_arqos,
    M00_AXI_arready,
    M00_AXI_arsize,
    M00_AXI_arvalid,
    M00_AXI_awaddr,
    M00_AXI_awburst,
    M00_AXI_awcache,
    M00_AXI_awid,
    M00_AXI_awlen,
    M00_AXI_awlock,
    M00_AXI_awprot,
    M00_AXI_awqos,
    M00_AXI_awready,
    M00_AXI_awsize,
    M00_AXI_awvalid,
    M00_AXI_bid,
    M00_AXI_bready,
    M00_AXI_bresp,
    M00_AXI_bvalid,
    M00_AXI_rdata,
    M00_AXI_rid,
    M00_AXI_rlast,
    M00_AXI_rready,
    M00_AXI_rresp,
    M00_AXI_rvalid,
    M00_AXI_wdata,
    M00_AXI_wid,
    M00_AXI_wlast,
    M00_AXI_wready,
    M00_AXI_wstrb,
    M00_AXI_wvalid,
    S00_ACLK,
    S00_ARESETN,
    S00_AXI_araddr,
    S00_AXI_arburst,
    S00_AXI_arcache,
    S00_AXI_arlen,
    S00_AXI_arprot,
    S00_AXI_arready,
    S00_AXI_arsize,
    S00_AXI_arvalid,
    S00_AXI_awaddr,
    S00_AXI_awburst,
    S00_AXI_awcache,
    S00_AXI_awlen,
    S00_AXI_awprot,
    S00_AXI_awready,
    S00_AXI_awsize,
    S00_AXI_awvalid,
    S00_AXI_bready,
    S00_AXI_bresp,
    S00_AXI_bvalid,
    S00_AXI_rdata,
    S00_AXI_rlast,
    S00_AXI_rready,
    S00_AXI_rresp,
    S00_AXI_rvalid,
    S00_AXI_wdata,
    S00_AXI_wlast,
    S00_AXI_wready,
    S00_AXI_wstrb,
    S00_AXI_wvalid,
    S01_ACLK,
    S01_ARESETN,
    S01_AXI_araddr,
    S01_AXI_arburst,
    S01_AXI_arcache,
    S01_AXI_arlen,
    S01_AXI_arprot,
    S01_AXI_arready,
    S01_AXI_arsize,
    S01_AXI_arvalid,
    S01_AXI_awaddr,
    S01_AXI_awburst,
    S01_AXI_awcache,
    S01_AXI_awlen,
    S01_AXI_awprot,
    S01_AXI_awready,
    S01_AXI_awsize,
    S01_AXI_awvalid,
    S01_AXI_bready,
    S01_AXI_bresp,
    S01_AXI_bvalid,
    S01_AXI_rdata,
    S01_AXI_rlast,
    S01_AXI_rready,
    S01_AXI_rresp,
    S01_AXI_rvalid,
    S01_AXI_wdata,
    S01_AXI_wlast,
    S01_AXI_wready,
    S01_AXI_wstrb,
    S01_AXI_wvalid);
  input ACLK;
  input [0:0]ARESETN;
  input M00_ACLK;
  input [0:0]M00_ARESETN;
  output [31:0]M00_AXI_araddr;
  output [1:0]M00_AXI_arburst;
  output [3:0]M00_AXI_arcache;
  output [0:0]M00_AXI_arid;
  output [3:0]M00_AXI_arlen;
  output [1:0]M00_AXI_arlock;
  output [2:0]M00_AXI_arprot;
  output [3:0]M00_AXI_arqos;
  input M00_AXI_arready;
  output [2:0]M00_AXI_arsize;
  output M00_AXI_arvalid;
  output [31:0]M00_AXI_awaddr;
  output [1:0]M00_AXI_awburst;
  output [3:0]M00_AXI_awcache;
  output [0:0]M00_AXI_awid;
  output [3:0]M00_AXI_awlen;
  output [1:0]M00_AXI_awlock;
  output [2:0]M00_AXI_awprot;
  output [3:0]M00_AXI_awqos;
  input M00_AXI_awready;
  output [2:0]M00_AXI_awsize;
  output M00_AXI_awvalid;
  input [0:0]M00_AXI_bid;
  output M00_AXI_bready;
  input [1:0]M00_AXI_bresp;
  input M00_AXI_bvalid;
  input [63:0]M00_AXI_rdata;
  input [0:0]M00_AXI_rid;
  input M00_AXI_rlast;
  output M00_AXI_rready;
  input [1:0]M00_AXI_rresp;
  input M00_AXI_rvalid;
  output [63:0]M00_AXI_wdata;
  output [0:0]M00_AXI_wid;
  output M00_AXI_wlast;
  input M00_AXI_wready;
  output [7:0]M00_AXI_wstrb;
  output M00_AXI_wvalid;
  input S00_ACLK;
  input [0:0]S00_ARESETN;
  input [31:0]S00_AXI_araddr;
  input [1:0]S00_AXI_arburst;
  input [3:0]S00_AXI_arcache;
  input [7:0]S00_AXI_arlen;
  input [2:0]S00_AXI_arprot;
  output S00_AXI_arready;
  input [2:0]S00_AXI_arsize;
  input S00_AXI_arvalid;
  input [31:0]S00_AXI_awaddr;
  input [1:0]S00_AXI_awburst;
  input [3:0]S00_AXI_awcache;
  input [7:0]S00_AXI_awlen;
  input [2:0]S00_AXI_awprot;
  output S00_AXI_awready;
  input [2:0]S00_AXI_awsize;
  input S00_AXI_awvalid;
  input S00_AXI_bready;
  output [1:0]S00_AXI_bresp;
  output S00_AXI_bvalid;
  output [31:0]S00_AXI_rdata;
  output S00_AXI_rlast;
  input S00_AXI_rready;
  output [1:0]S00_AXI_rresp;
  output S00_AXI_rvalid;
  input [31:0]S00_AXI_wdata;
  input S00_AXI_wlast;
  output S00_AXI_wready;
  input [3:0]S00_AXI_wstrb;
  input S00_AXI_wvalid;
  input S01_ACLK;
  input [0:0]S01_ARESETN;
  input [31:0]S01_AXI_araddr;
  input [1:0]S01_AXI_arburst;
  input [3:0]S01_AXI_arcache;
  input [7:0]S01_AXI_arlen;
  input [2:0]S01_AXI_arprot;
  output S01_AXI_arready;
  input [2:0]S01_AXI_arsize;
  input S01_AXI_arvalid;
  input [31:0]S01_AXI_awaddr;
  input [1:0]S01_AXI_awburst;
  input [3:0]S01_AXI_awcache;
  input [7:0]S01_AXI_awlen;
  input [2:0]S01_AXI_awprot;
  output S01_AXI_awready;
  input [2:0]S01_AXI_awsize;
  input S01_AXI_awvalid;
  input S01_AXI_bready;
  output [1:0]S01_AXI_bresp;
  output S01_AXI_bvalid;
  output [31:0]S01_AXI_rdata;
  output S01_AXI_rlast;
  input S01_AXI_rready;
  output [1:0]S01_AXI_rresp;
  output S01_AXI_rvalid;
  input [31:0]S01_AXI_wdata;
  input S01_AXI_wlast;
  output S01_AXI_wready;
  input [3:0]S01_AXI_wstrb;
  input S01_AXI_wvalid;

  wire GND_1;
  wire M00_ACLK_1;
  wire [0:0]M00_ARESETN_1;
  wire S00_ACLK_1;
  wire [0:0]S00_ARESETN_1;
  wire S01_ACLK_1;
  wire [0:0]S01_ARESETN_1;
  wire axi_interconnect_0_ACLK_net;
  wire [0:0]axi_interconnect_0_ARESETN_net;
  wire [31:0]axi_interconnect_0_to_s00_couplers_ARADDR;
  wire [1:0]axi_interconnect_0_to_s00_couplers_ARBURST;
  wire [3:0]axi_interconnect_0_to_s00_couplers_ARCACHE;
  wire [7:0]axi_interconnect_0_to_s00_couplers_ARLEN;
  wire [2:0]axi_interconnect_0_to_s00_couplers_ARPROT;
  wire axi_interconnect_0_to_s00_couplers_ARREADY;
  wire [2:0]axi_interconnect_0_to_s00_couplers_ARSIZE;
  wire axi_interconnect_0_to_s00_couplers_ARVALID;
  wire [31:0]axi_interconnect_0_to_s00_couplers_AWADDR;
  wire [1:0]axi_interconnect_0_to_s00_couplers_AWBURST;
  wire [3:0]axi_interconnect_0_to_s00_couplers_AWCACHE;
  wire [7:0]axi_interconnect_0_to_s00_couplers_AWLEN;
  wire [2:0]axi_interconnect_0_to_s00_couplers_AWPROT;
  wire axi_interconnect_0_to_s00_couplers_AWREADY;
  wire [2:0]axi_interconnect_0_to_s00_couplers_AWSIZE;
  wire axi_interconnect_0_to_s00_couplers_AWVALID;
  wire axi_interconnect_0_to_s00_couplers_BREADY;
  wire [1:0]axi_interconnect_0_to_s00_couplers_BRESP;
  wire axi_interconnect_0_to_s00_couplers_BVALID;
  wire [31:0]axi_interconnect_0_to_s00_couplers_RDATA;
  wire axi_interconnect_0_to_s00_couplers_RLAST;
  wire axi_interconnect_0_to_s00_couplers_RREADY;
  wire [1:0]axi_interconnect_0_to_s00_couplers_RRESP;
  wire axi_interconnect_0_to_s00_couplers_RVALID;
  wire [31:0]axi_interconnect_0_to_s00_couplers_WDATA;
  wire axi_interconnect_0_to_s00_couplers_WLAST;
  wire axi_interconnect_0_to_s00_couplers_WREADY;
  wire [3:0]axi_interconnect_0_to_s00_couplers_WSTRB;
  wire axi_interconnect_0_to_s00_couplers_WVALID;
  wire [31:0]axi_interconnect_0_to_s01_couplers_ARADDR;
  wire [1:0]axi_interconnect_0_to_s01_couplers_ARBURST;
  wire [3:0]axi_interconnect_0_to_s01_couplers_ARCACHE;
  wire [7:0]axi_interconnect_0_to_s01_couplers_ARLEN;
  wire [2:0]axi_interconnect_0_to_s01_couplers_ARPROT;
  wire axi_interconnect_0_to_s01_couplers_ARREADY;
  wire [2:0]axi_interconnect_0_to_s01_couplers_ARSIZE;
  wire axi_interconnect_0_to_s01_couplers_ARVALID;
  wire [31:0]axi_interconnect_0_to_s01_couplers_AWADDR;
  wire [1:0]axi_interconnect_0_to_s01_couplers_AWBURST;
  wire [3:0]axi_interconnect_0_to_s01_couplers_AWCACHE;
  wire [7:0]axi_interconnect_0_to_s01_couplers_AWLEN;
  wire [2:0]axi_interconnect_0_to_s01_couplers_AWPROT;
  wire axi_interconnect_0_to_s01_couplers_AWREADY;
  wire [2:0]axi_interconnect_0_to_s01_couplers_AWSIZE;
  wire axi_interconnect_0_to_s01_couplers_AWVALID;
  wire axi_interconnect_0_to_s01_couplers_BREADY;
  wire [1:0]axi_interconnect_0_to_s01_couplers_BRESP;
  wire axi_interconnect_0_to_s01_couplers_BVALID;
  wire [31:0]axi_interconnect_0_to_s01_couplers_RDATA;
  wire axi_interconnect_0_to_s01_couplers_RLAST;
  wire axi_interconnect_0_to_s01_couplers_RREADY;
  wire [1:0]axi_interconnect_0_to_s01_couplers_RRESP;
  wire axi_interconnect_0_to_s01_couplers_RVALID;
  wire [31:0]axi_interconnect_0_to_s01_couplers_WDATA;
  wire axi_interconnect_0_to_s01_couplers_WLAST;
  wire axi_interconnect_0_to_s01_couplers_WREADY;
  wire [3:0]axi_interconnect_0_to_s01_couplers_WSTRB;
  wire axi_interconnect_0_to_s01_couplers_WVALID;
  wire [31:0]m00_couplers_to_axi_interconnect_0_ARADDR;
  wire [1:0]m00_couplers_to_axi_interconnect_0_ARBURST;
  wire [3:0]m00_couplers_to_axi_interconnect_0_ARCACHE;
  wire [0:0]m00_couplers_to_axi_interconnect_0_ARID;
  wire [3:0]m00_couplers_to_axi_interconnect_0_ARLEN;
  wire [1:0]m00_couplers_to_axi_interconnect_0_ARLOCK;
  wire [2:0]m00_couplers_to_axi_interconnect_0_ARPROT;
  wire [3:0]m00_couplers_to_axi_interconnect_0_ARQOS;
  wire m00_couplers_to_axi_interconnect_0_ARREADY;
  wire [2:0]m00_couplers_to_axi_interconnect_0_ARSIZE;
  wire m00_couplers_to_axi_interconnect_0_ARVALID;
  wire [31:0]m00_couplers_to_axi_interconnect_0_AWADDR;
  wire [1:0]m00_couplers_to_axi_interconnect_0_AWBURST;
  wire [3:0]m00_couplers_to_axi_interconnect_0_AWCACHE;
  wire [0:0]m00_couplers_to_axi_interconnect_0_AWID;
  wire [3:0]m00_couplers_to_axi_interconnect_0_AWLEN;
  wire [1:0]m00_couplers_to_axi_interconnect_0_AWLOCK;
  wire [2:0]m00_couplers_to_axi_interconnect_0_AWPROT;
  wire [3:0]m00_couplers_to_axi_interconnect_0_AWQOS;
  wire m00_couplers_to_axi_interconnect_0_AWREADY;
  wire [2:0]m00_couplers_to_axi_interconnect_0_AWSIZE;
  wire m00_couplers_to_axi_interconnect_0_AWVALID;
  wire [0:0]m00_couplers_to_axi_interconnect_0_BID;
  wire m00_couplers_to_axi_interconnect_0_BREADY;
  wire [1:0]m00_couplers_to_axi_interconnect_0_BRESP;
  wire m00_couplers_to_axi_interconnect_0_BVALID;
  wire [63:0]m00_couplers_to_axi_interconnect_0_RDATA;
  wire [0:0]m00_couplers_to_axi_interconnect_0_RID;
  wire m00_couplers_to_axi_interconnect_0_RLAST;
  wire m00_couplers_to_axi_interconnect_0_RREADY;
  wire [1:0]m00_couplers_to_axi_interconnect_0_RRESP;
  wire m00_couplers_to_axi_interconnect_0_RVALID;
  wire [63:0]m00_couplers_to_axi_interconnect_0_WDATA;
  wire [0:0]m00_couplers_to_axi_interconnect_0_WID;
  wire m00_couplers_to_axi_interconnect_0_WLAST;
  wire m00_couplers_to_axi_interconnect_0_WREADY;
  wire [7:0]m00_couplers_to_axi_interconnect_0_WSTRB;
  wire m00_couplers_to_axi_interconnect_0_WVALID;
  wire [31:0]s00_couplers_to_xbar_ARADDR;
  wire [1:0]s00_couplers_to_xbar_ARBURST;
  wire [3:0]s00_couplers_to_xbar_ARCACHE;
  wire [7:0]s00_couplers_to_xbar_ARLEN;
  wire [0:0]s00_couplers_to_xbar_ARLOCK;
  wire [2:0]s00_couplers_to_xbar_ARPROT;
  wire [3:0]s00_couplers_to_xbar_ARQOS;
  wire [0:0]s00_couplers_to_xbar_ARREADY;
  wire [2:0]s00_couplers_to_xbar_ARSIZE;
  wire s00_couplers_to_xbar_ARVALID;
  wire [31:0]s00_couplers_to_xbar_AWADDR;
  wire [1:0]s00_couplers_to_xbar_AWBURST;
  wire [3:0]s00_couplers_to_xbar_AWCACHE;
  wire [7:0]s00_couplers_to_xbar_AWLEN;
  wire [0:0]s00_couplers_to_xbar_AWLOCK;
  wire [2:0]s00_couplers_to_xbar_AWPROT;
  wire [3:0]s00_couplers_to_xbar_AWQOS;
  wire [0:0]s00_couplers_to_xbar_AWREADY;
  wire [2:0]s00_couplers_to_xbar_AWSIZE;
  wire s00_couplers_to_xbar_AWVALID;
  wire s00_couplers_to_xbar_BREADY;
  wire [1:0]s00_couplers_to_xbar_BRESP;
  wire [0:0]s00_couplers_to_xbar_BVALID;
  wire [63:0]s00_couplers_to_xbar_RDATA;
  wire [0:0]s00_couplers_to_xbar_RLAST;
  wire s00_couplers_to_xbar_RREADY;
  wire [1:0]s00_couplers_to_xbar_RRESP;
  wire [0:0]s00_couplers_to_xbar_RVALID;
  wire [63:0]s00_couplers_to_xbar_WDATA;
  wire s00_couplers_to_xbar_WLAST;
  wire [0:0]s00_couplers_to_xbar_WREADY;
  wire [7:0]s00_couplers_to_xbar_WSTRB;
  wire s00_couplers_to_xbar_WVALID;
  wire [31:0]s01_couplers_to_xbar_ARADDR;
  wire [1:0]s01_couplers_to_xbar_ARBURST;
  wire [3:0]s01_couplers_to_xbar_ARCACHE;
  wire [7:0]s01_couplers_to_xbar_ARLEN;
  wire [0:0]s01_couplers_to_xbar_ARLOCK;
  wire [2:0]s01_couplers_to_xbar_ARPROT;
  wire [3:0]s01_couplers_to_xbar_ARQOS;
  wire [1:1]s01_couplers_to_xbar_ARREADY;
  wire [2:0]s01_couplers_to_xbar_ARSIZE;
  wire s01_couplers_to_xbar_ARVALID;
  wire [31:0]s01_couplers_to_xbar_AWADDR;
  wire [1:0]s01_couplers_to_xbar_AWBURST;
  wire [3:0]s01_couplers_to_xbar_AWCACHE;
  wire [7:0]s01_couplers_to_xbar_AWLEN;
  wire [0:0]s01_couplers_to_xbar_AWLOCK;
  wire [2:0]s01_couplers_to_xbar_AWPROT;
  wire [3:0]s01_couplers_to_xbar_AWQOS;
  wire [1:1]s01_couplers_to_xbar_AWREADY;
  wire [2:0]s01_couplers_to_xbar_AWSIZE;
  wire s01_couplers_to_xbar_AWVALID;
  wire s01_couplers_to_xbar_BREADY;
  wire [3:2]s01_couplers_to_xbar_BRESP;
  wire [1:1]s01_couplers_to_xbar_BVALID;
  wire [127:64]s01_couplers_to_xbar_RDATA;
  wire [1:1]s01_couplers_to_xbar_RLAST;
  wire s01_couplers_to_xbar_RREADY;
  wire [3:2]s01_couplers_to_xbar_RRESP;
  wire [1:1]s01_couplers_to_xbar_RVALID;
  wire [63:0]s01_couplers_to_xbar_WDATA;
  wire s01_couplers_to_xbar_WLAST;
  wire [1:1]s01_couplers_to_xbar_WREADY;
  wire [7:0]s01_couplers_to_xbar_WSTRB;
  wire s01_couplers_to_xbar_WVALID;
  wire [31:0]xbar_to_m00_couplers_ARADDR;
  wire [1:0]xbar_to_m00_couplers_ARBURST;
  wire [3:0]xbar_to_m00_couplers_ARCACHE;
  wire [0:0]xbar_to_m00_couplers_ARID;
  wire [7:0]xbar_to_m00_couplers_ARLEN;
  wire [0:0]xbar_to_m00_couplers_ARLOCK;
  wire [2:0]xbar_to_m00_couplers_ARPROT;
  wire [3:0]xbar_to_m00_couplers_ARQOS;
  wire xbar_to_m00_couplers_ARREADY;
  wire [3:0]xbar_to_m00_couplers_ARREGION;
  wire [2:0]xbar_to_m00_couplers_ARSIZE;
  wire [0:0]xbar_to_m00_couplers_ARVALID;
  wire [31:0]xbar_to_m00_couplers_AWADDR;
  wire [1:0]xbar_to_m00_couplers_AWBURST;
  wire [3:0]xbar_to_m00_couplers_AWCACHE;
  wire [0:0]xbar_to_m00_couplers_AWID;
  wire [7:0]xbar_to_m00_couplers_AWLEN;
  wire [0:0]xbar_to_m00_couplers_AWLOCK;
  wire [2:0]xbar_to_m00_couplers_AWPROT;
  wire [3:0]xbar_to_m00_couplers_AWQOS;
  wire xbar_to_m00_couplers_AWREADY;
  wire [3:0]xbar_to_m00_couplers_AWREGION;
  wire [2:0]xbar_to_m00_couplers_AWSIZE;
  wire [0:0]xbar_to_m00_couplers_AWVALID;
  wire [0:0]xbar_to_m00_couplers_BID;
  wire [0:0]xbar_to_m00_couplers_BREADY;
  wire [1:0]xbar_to_m00_couplers_BRESP;
  wire xbar_to_m00_couplers_BVALID;
  wire [63:0]xbar_to_m00_couplers_RDATA;
  wire [0:0]xbar_to_m00_couplers_RID;
  wire xbar_to_m00_couplers_RLAST;
  wire [0:0]xbar_to_m00_couplers_RREADY;
  wire [1:0]xbar_to_m00_couplers_RRESP;
  wire xbar_to_m00_couplers_RVALID;
  wire [63:0]xbar_to_m00_couplers_WDATA;
  wire [0:0]xbar_to_m00_couplers_WLAST;
  wire xbar_to_m00_couplers_WREADY;
  wire [7:0]xbar_to_m00_couplers_WSTRB;
  wire [0:0]xbar_to_m00_couplers_WVALID;

  assign M00_ACLK_1 = M00_ACLK;
  assign M00_ARESETN_1 = M00_ARESETN[0];
  assign M00_AXI_araddr[31:0] = m00_couplers_to_axi_interconnect_0_ARADDR;
  assign M00_AXI_arburst[1:0] = m00_couplers_to_axi_interconnect_0_ARBURST;
  assign M00_AXI_arcache[3:0] = m00_couplers_to_axi_interconnect_0_ARCACHE;
  assign M00_AXI_arid[0] = m00_couplers_to_axi_interconnect_0_ARID;
  assign M00_AXI_arlen[3:0] = m00_couplers_to_axi_interconnect_0_ARLEN;
  assign M00_AXI_arlock[1:0] = m00_couplers_to_axi_interconnect_0_ARLOCK;
  assign M00_AXI_arprot[2:0] = m00_couplers_to_axi_interconnect_0_ARPROT;
  assign M00_AXI_arqos[3:0] = m00_couplers_to_axi_interconnect_0_ARQOS;
  assign M00_AXI_arsize[2:0] = m00_couplers_to_axi_interconnect_0_ARSIZE;
  assign M00_AXI_arvalid = m00_couplers_to_axi_interconnect_0_ARVALID;
  assign M00_AXI_awaddr[31:0] = m00_couplers_to_axi_interconnect_0_AWADDR;
  assign M00_AXI_awburst[1:0] = m00_couplers_to_axi_interconnect_0_AWBURST;
  assign M00_AXI_awcache[3:0] = m00_couplers_to_axi_interconnect_0_AWCACHE;
  assign M00_AXI_awid[0] = m00_couplers_to_axi_interconnect_0_AWID;
  assign M00_AXI_awlen[3:0] = m00_couplers_to_axi_interconnect_0_AWLEN;
  assign M00_AXI_awlock[1:0] = m00_couplers_to_axi_interconnect_0_AWLOCK;
  assign M00_AXI_awprot[2:0] = m00_couplers_to_axi_interconnect_0_AWPROT;
  assign M00_AXI_awqos[3:0] = m00_couplers_to_axi_interconnect_0_AWQOS;
  assign M00_AXI_awsize[2:0] = m00_couplers_to_axi_interconnect_0_AWSIZE;
  assign M00_AXI_awvalid = m00_couplers_to_axi_interconnect_0_AWVALID;
  assign M00_AXI_bready = m00_couplers_to_axi_interconnect_0_BREADY;
  assign M00_AXI_rready = m00_couplers_to_axi_interconnect_0_RREADY;
  assign M00_AXI_wdata[63:0] = m00_couplers_to_axi_interconnect_0_WDATA;
  assign M00_AXI_wid[0] = m00_couplers_to_axi_interconnect_0_WID;
  assign M00_AXI_wlast = m00_couplers_to_axi_interconnect_0_WLAST;
  assign M00_AXI_wstrb[7:0] = m00_couplers_to_axi_interconnect_0_WSTRB;
  assign M00_AXI_wvalid = m00_couplers_to_axi_interconnect_0_WVALID;
  assign S00_ACLK_1 = S00_ACLK;
  assign S00_ARESETN_1 = S00_ARESETN[0];
  assign S00_AXI_arready = axi_interconnect_0_to_s00_couplers_ARREADY;
  assign S00_AXI_awready = axi_interconnect_0_to_s00_couplers_AWREADY;
  assign S00_AXI_bresp[1:0] = axi_interconnect_0_to_s00_couplers_BRESP;
  assign S00_AXI_bvalid = axi_interconnect_0_to_s00_couplers_BVALID;
  assign S00_AXI_rdata[31:0] = axi_interconnect_0_to_s00_couplers_RDATA;
  assign S00_AXI_rlast = axi_interconnect_0_to_s00_couplers_RLAST;
  assign S00_AXI_rresp[1:0] = axi_interconnect_0_to_s00_couplers_RRESP;
  assign S00_AXI_rvalid = axi_interconnect_0_to_s00_couplers_RVALID;
  assign S00_AXI_wready = axi_interconnect_0_to_s00_couplers_WREADY;
  assign S01_ACLK_1 = S01_ACLK;
  assign S01_ARESETN_1 = S01_ARESETN[0];
  assign S01_AXI_arready = axi_interconnect_0_to_s01_couplers_ARREADY;
  assign S01_AXI_awready = axi_interconnect_0_to_s01_couplers_AWREADY;
  assign S01_AXI_bresp[1:0] = axi_interconnect_0_to_s01_couplers_BRESP;
  assign S01_AXI_bvalid = axi_interconnect_0_to_s01_couplers_BVALID;
  assign S01_AXI_rdata[31:0] = axi_interconnect_0_to_s01_couplers_RDATA;
  assign S01_AXI_rlast = axi_interconnect_0_to_s01_couplers_RLAST;
  assign S01_AXI_rresp[1:0] = axi_interconnect_0_to_s01_couplers_RRESP;
  assign S01_AXI_rvalid = axi_interconnect_0_to_s01_couplers_RVALID;
  assign S01_AXI_wready = axi_interconnect_0_to_s01_couplers_WREADY;
  assign axi_interconnect_0_ACLK_net = ACLK;
  assign axi_interconnect_0_ARESETN_net = ARESETN[0];
  assign axi_interconnect_0_to_s00_couplers_ARADDR = S00_AXI_araddr[31:0];
  assign axi_interconnect_0_to_s00_couplers_ARBURST = S00_AXI_arburst[1:0];
  assign axi_interconnect_0_to_s00_couplers_ARCACHE = S00_AXI_arcache[3:0];
  assign axi_interconnect_0_to_s00_couplers_ARLEN = S00_AXI_arlen[7:0];
  assign axi_interconnect_0_to_s00_couplers_ARPROT = S00_AXI_arprot[2:0];
  assign axi_interconnect_0_to_s00_couplers_ARSIZE = S00_AXI_arsize[2:0];
  assign axi_interconnect_0_to_s00_couplers_ARVALID = S00_AXI_arvalid;
  assign axi_interconnect_0_to_s00_couplers_AWADDR = S00_AXI_awaddr[31:0];
  assign axi_interconnect_0_to_s00_couplers_AWBURST = S00_AXI_awburst[1:0];
  assign axi_interconnect_0_to_s00_couplers_AWCACHE = S00_AXI_awcache[3:0];
  assign axi_interconnect_0_to_s00_couplers_AWLEN = S00_AXI_awlen[7:0];
  assign axi_interconnect_0_to_s00_couplers_AWPROT = S00_AXI_awprot[2:0];
  assign axi_interconnect_0_to_s00_couplers_AWSIZE = S00_AXI_awsize[2:0];
  assign axi_interconnect_0_to_s00_couplers_AWVALID = S00_AXI_awvalid;
  assign axi_interconnect_0_to_s00_couplers_BREADY = S00_AXI_bready;
  assign axi_interconnect_0_to_s00_couplers_RREADY = S00_AXI_rready;
  assign axi_interconnect_0_to_s00_couplers_WDATA = S00_AXI_wdata[31:0];
  assign axi_interconnect_0_to_s00_couplers_WLAST = S00_AXI_wlast;
  assign axi_interconnect_0_to_s00_couplers_WSTRB = S00_AXI_wstrb[3:0];
  assign axi_interconnect_0_to_s00_couplers_WVALID = S00_AXI_wvalid;
  assign axi_interconnect_0_to_s01_couplers_ARADDR = S01_AXI_araddr[31:0];
  assign axi_interconnect_0_to_s01_couplers_ARBURST = S01_AXI_arburst[1:0];
  assign axi_interconnect_0_to_s01_couplers_ARCACHE = S01_AXI_arcache[3:0];
  assign axi_interconnect_0_to_s01_couplers_ARLEN = S01_AXI_arlen[7:0];
  assign axi_interconnect_0_to_s01_couplers_ARPROT = S01_AXI_arprot[2:0];
  assign axi_interconnect_0_to_s01_couplers_ARSIZE = S01_AXI_arsize[2:0];
  assign axi_interconnect_0_to_s01_couplers_ARVALID = S01_AXI_arvalid;
  assign axi_interconnect_0_to_s01_couplers_AWADDR = S01_AXI_awaddr[31:0];
  assign axi_interconnect_0_to_s01_couplers_AWBURST = S01_AXI_awburst[1:0];
  assign axi_interconnect_0_to_s01_couplers_AWCACHE = S01_AXI_awcache[3:0];
  assign axi_interconnect_0_to_s01_couplers_AWLEN = S01_AXI_awlen[7:0];
  assign axi_interconnect_0_to_s01_couplers_AWPROT = S01_AXI_awprot[2:0];
  assign axi_interconnect_0_to_s01_couplers_AWSIZE = S01_AXI_awsize[2:0];
  assign axi_interconnect_0_to_s01_couplers_AWVALID = S01_AXI_awvalid;
  assign axi_interconnect_0_to_s01_couplers_BREADY = S01_AXI_bready;
  assign axi_interconnect_0_to_s01_couplers_RREADY = S01_AXI_rready;
  assign axi_interconnect_0_to_s01_couplers_WDATA = S01_AXI_wdata[31:0];
  assign axi_interconnect_0_to_s01_couplers_WLAST = S01_AXI_wlast;
  assign axi_interconnect_0_to_s01_couplers_WSTRB = S01_AXI_wstrb[3:0];
  assign axi_interconnect_0_to_s01_couplers_WVALID = S01_AXI_wvalid;
  assign m00_couplers_to_axi_interconnect_0_ARREADY = M00_AXI_arready;
  assign m00_couplers_to_axi_interconnect_0_AWREADY = M00_AXI_awready;
  assign m00_couplers_to_axi_interconnect_0_BID = M00_AXI_bid[0];
  assign m00_couplers_to_axi_interconnect_0_BRESP = M00_AXI_bresp[1:0];
  assign m00_couplers_to_axi_interconnect_0_BVALID = M00_AXI_bvalid;
  assign m00_couplers_to_axi_interconnect_0_RDATA = M00_AXI_rdata[63:0];
  assign m00_couplers_to_axi_interconnect_0_RID = M00_AXI_rid[0];
  assign m00_couplers_to_axi_interconnect_0_RLAST = M00_AXI_rlast;
  assign m00_couplers_to_axi_interconnect_0_RRESP = M00_AXI_rresp[1:0];
  assign m00_couplers_to_axi_interconnect_0_RVALID = M00_AXI_rvalid;
  assign m00_couplers_to_axi_interconnect_0_WREADY = M00_AXI_wready;
GND GND
       (.G(GND_1));
m00_couplers_imp_GJ2UD0 m00_couplers
       (.M_ACLK(M00_ACLK_1),
        .M_ARESETN(M00_ARESETN_1),
        .M_AXI_araddr(m00_couplers_to_axi_interconnect_0_ARADDR),
        .M_AXI_arburst(m00_couplers_to_axi_interconnect_0_ARBURST),
        .M_AXI_arcache(m00_couplers_to_axi_interconnect_0_ARCACHE),
        .M_AXI_arid(m00_couplers_to_axi_interconnect_0_ARID),
        .M_AXI_arlen(m00_couplers_to_axi_interconnect_0_ARLEN),
        .M_AXI_arlock(m00_couplers_to_axi_interconnect_0_ARLOCK),
        .M_AXI_arprot(m00_couplers_to_axi_interconnect_0_ARPROT),
        .M_AXI_arqos(m00_couplers_to_axi_interconnect_0_ARQOS),
        .M_AXI_arready(m00_couplers_to_axi_interconnect_0_ARREADY),
        .M_AXI_arsize(m00_couplers_to_axi_interconnect_0_ARSIZE),
        .M_AXI_arvalid(m00_couplers_to_axi_interconnect_0_ARVALID),
        .M_AXI_awaddr(m00_couplers_to_axi_interconnect_0_AWADDR),
        .M_AXI_awburst(m00_couplers_to_axi_interconnect_0_AWBURST),
        .M_AXI_awcache(m00_couplers_to_axi_interconnect_0_AWCACHE),
        .M_AXI_awid(m00_couplers_to_axi_interconnect_0_AWID),
        .M_AXI_awlen(m00_couplers_to_axi_interconnect_0_AWLEN),
        .M_AXI_awlock(m00_couplers_to_axi_interconnect_0_AWLOCK),
        .M_AXI_awprot(m00_couplers_to_axi_interconnect_0_AWPROT),
        .M_AXI_awqos(m00_couplers_to_axi_interconnect_0_AWQOS),
        .M_AXI_awready(m00_couplers_to_axi_interconnect_0_AWREADY),
        .M_AXI_awsize(m00_couplers_to_axi_interconnect_0_AWSIZE),
        .M_AXI_awvalid(m00_couplers_to_axi_interconnect_0_AWVALID),
        .M_AXI_bid(m00_couplers_to_axi_interconnect_0_BID),
        .M_AXI_bready(m00_couplers_to_axi_interconnect_0_BREADY),
        .M_AXI_bresp(m00_couplers_to_axi_interconnect_0_BRESP),
        .M_AXI_bvalid(m00_couplers_to_axi_interconnect_0_BVALID),
        .M_AXI_rdata(m00_couplers_to_axi_interconnect_0_RDATA),
        .M_AXI_rid(m00_couplers_to_axi_interconnect_0_RID),
        .M_AXI_rlast(m00_couplers_to_axi_interconnect_0_RLAST),
        .M_AXI_rready(m00_couplers_to_axi_interconnect_0_RREADY),
        .M_AXI_rresp(m00_couplers_to_axi_interconnect_0_RRESP),
        .M_AXI_rvalid(m00_couplers_to_axi_interconnect_0_RVALID),
        .M_AXI_wdata(m00_couplers_to_axi_interconnect_0_WDATA),
        .M_AXI_wid(m00_couplers_to_axi_interconnect_0_WID),
        .M_AXI_wlast(m00_couplers_to_axi_interconnect_0_WLAST),
        .M_AXI_wready(m00_couplers_to_axi_interconnect_0_WREADY),
        .M_AXI_wstrb(m00_couplers_to_axi_interconnect_0_WSTRB),
        .M_AXI_wvalid(m00_couplers_to_axi_interconnect_0_WVALID),
        .S_ACLK(axi_interconnect_0_ACLK_net),
        .S_ARESETN(axi_interconnect_0_ARESETN_net),
        .S_AXI_araddr(xbar_to_m00_couplers_ARADDR),
        .S_AXI_arburst(xbar_to_m00_couplers_ARBURST),
        .S_AXI_arcache(xbar_to_m00_couplers_ARCACHE),
        .S_AXI_arid(xbar_to_m00_couplers_ARID),
        .S_AXI_arlen(xbar_to_m00_couplers_ARLEN),
        .S_AXI_arlock(xbar_to_m00_couplers_ARLOCK),
        .S_AXI_arprot(xbar_to_m00_couplers_ARPROT),
        .S_AXI_arqos(xbar_to_m00_couplers_ARQOS),
        .S_AXI_arready(xbar_to_m00_couplers_ARREADY),
        .S_AXI_arregion(xbar_to_m00_couplers_ARREGION),
        .S_AXI_arsize(xbar_to_m00_couplers_ARSIZE),
        .S_AXI_arvalid(xbar_to_m00_couplers_ARVALID),
        .S_AXI_awaddr(xbar_to_m00_couplers_AWADDR),
        .S_AXI_awburst(xbar_to_m00_couplers_AWBURST),
        .S_AXI_awcache(xbar_to_m00_couplers_AWCACHE),
        .S_AXI_awid(xbar_to_m00_couplers_AWID),
        .S_AXI_awlen(xbar_to_m00_couplers_AWLEN),
        .S_AXI_awlock(xbar_to_m00_couplers_AWLOCK),
        .S_AXI_awprot(xbar_to_m00_couplers_AWPROT),
        .S_AXI_awqos(xbar_to_m00_couplers_AWQOS),
        .S_AXI_awready(xbar_to_m00_couplers_AWREADY),
        .S_AXI_awregion(xbar_to_m00_couplers_AWREGION),
        .S_AXI_awsize(xbar_to_m00_couplers_AWSIZE),
        .S_AXI_awvalid(xbar_to_m00_couplers_AWVALID),
        .S_AXI_bid(xbar_to_m00_couplers_BID),
        .S_AXI_bready(xbar_to_m00_couplers_BREADY),
        .S_AXI_bresp(xbar_to_m00_couplers_BRESP),
        .S_AXI_bvalid(xbar_to_m00_couplers_BVALID),
        .S_AXI_rdata(xbar_to_m00_couplers_RDATA),
        .S_AXI_rid(xbar_to_m00_couplers_RID),
        .S_AXI_rlast(xbar_to_m00_couplers_RLAST),
        .S_AXI_rready(xbar_to_m00_couplers_RREADY),
        .S_AXI_rresp(xbar_to_m00_couplers_RRESP),
        .S_AXI_rvalid(xbar_to_m00_couplers_RVALID),
        .S_AXI_wdata(xbar_to_m00_couplers_WDATA),
        .S_AXI_wlast(xbar_to_m00_couplers_WLAST),
        .S_AXI_wready(xbar_to_m00_couplers_WREADY),
        .S_AXI_wstrb(xbar_to_m00_couplers_WSTRB),
        .S_AXI_wvalid(xbar_to_m00_couplers_WVALID));
s00_couplers_imp_1I0LFG6 s00_couplers
       (.M_ACLK(axi_interconnect_0_ACLK_net),
        .M_ARESETN(axi_interconnect_0_ARESETN_net),
        .M_AXI_araddr(s00_couplers_to_xbar_ARADDR),
        .M_AXI_arburst(s00_couplers_to_xbar_ARBURST),
        .M_AXI_arcache(s00_couplers_to_xbar_ARCACHE),
        .M_AXI_arlen(s00_couplers_to_xbar_ARLEN),
        .M_AXI_arlock(s00_couplers_to_xbar_ARLOCK),
        .M_AXI_arprot(s00_couplers_to_xbar_ARPROT),
        .M_AXI_arqos(s00_couplers_to_xbar_ARQOS),
        .M_AXI_arready(s00_couplers_to_xbar_ARREADY),
        .M_AXI_arsize(s00_couplers_to_xbar_ARSIZE),
        .M_AXI_arvalid(s00_couplers_to_xbar_ARVALID),
        .M_AXI_awaddr(s00_couplers_to_xbar_AWADDR),
        .M_AXI_awburst(s00_couplers_to_xbar_AWBURST),
        .M_AXI_awcache(s00_couplers_to_xbar_AWCACHE),
        .M_AXI_awlen(s00_couplers_to_xbar_AWLEN),
        .M_AXI_awlock(s00_couplers_to_xbar_AWLOCK),
        .M_AXI_awprot(s00_couplers_to_xbar_AWPROT),
        .M_AXI_awqos(s00_couplers_to_xbar_AWQOS),
        .M_AXI_awready(s00_couplers_to_xbar_AWREADY),
        .M_AXI_awsize(s00_couplers_to_xbar_AWSIZE),
        .M_AXI_awvalid(s00_couplers_to_xbar_AWVALID),
        .M_AXI_bready(s00_couplers_to_xbar_BREADY),
        .M_AXI_bresp(s00_couplers_to_xbar_BRESP),
        .M_AXI_bvalid(s00_couplers_to_xbar_BVALID),
        .M_AXI_rdata(s00_couplers_to_xbar_RDATA),
        .M_AXI_rlast(s00_couplers_to_xbar_RLAST),
        .M_AXI_rready(s00_couplers_to_xbar_RREADY),
        .M_AXI_rresp(s00_couplers_to_xbar_RRESP),
        .M_AXI_rvalid(s00_couplers_to_xbar_RVALID),
        .M_AXI_wdata(s00_couplers_to_xbar_WDATA),
        .M_AXI_wlast(s00_couplers_to_xbar_WLAST),
        .M_AXI_wready(s00_couplers_to_xbar_WREADY),
        .M_AXI_wstrb(s00_couplers_to_xbar_WSTRB),
        .M_AXI_wvalid(s00_couplers_to_xbar_WVALID),
        .S_ACLK(S00_ACLK_1),
        .S_ARESETN(S00_ARESETN_1),
        .S_AXI_araddr(axi_interconnect_0_to_s00_couplers_ARADDR),
        .S_AXI_arburst(axi_interconnect_0_to_s00_couplers_ARBURST),
        .S_AXI_arcache(axi_interconnect_0_to_s00_couplers_ARCACHE),
        .S_AXI_arlen(axi_interconnect_0_to_s00_couplers_ARLEN),
        .S_AXI_arprot(axi_interconnect_0_to_s00_couplers_ARPROT),
        .S_AXI_arready(axi_interconnect_0_to_s00_couplers_ARREADY),
        .S_AXI_arsize(axi_interconnect_0_to_s00_couplers_ARSIZE),
        .S_AXI_arvalid(axi_interconnect_0_to_s00_couplers_ARVALID),
        .S_AXI_awaddr(axi_interconnect_0_to_s00_couplers_AWADDR),
        .S_AXI_awburst(axi_interconnect_0_to_s00_couplers_AWBURST),
        .S_AXI_awcache(axi_interconnect_0_to_s00_couplers_AWCACHE),
        .S_AXI_awlen(axi_interconnect_0_to_s00_couplers_AWLEN),
        .S_AXI_awprot(axi_interconnect_0_to_s00_couplers_AWPROT),
        .S_AXI_awready(axi_interconnect_0_to_s00_couplers_AWREADY),
        .S_AXI_awsize(axi_interconnect_0_to_s00_couplers_AWSIZE),
        .S_AXI_awvalid(axi_interconnect_0_to_s00_couplers_AWVALID),
        .S_AXI_bready(axi_interconnect_0_to_s00_couplers_BREADY),
        .S_AXI_bresp(axi_interconnect_0_to_s00_couplers_BRESP),
        .S_AXI_bvalid(axi_interconnect_0_to_s00_couplers_BVALID),
        .S_AXI_rdata(axi_interconnect_0_to_s00_couplers_RDATA),
        .S_AXI_rlast(axi_interconnect_0_to_s00_couplers_RLAST),
        .S_AXI_rready(axi_interconnect_0_to_s00_couplers_RREADY),
        .S_AXI_rresp(axi_interconnect_0_to_s00_couplers_RRESP),
        .S_AXI_rvalid(axi_interconnect_0_to_s00_couplers_RVALID),
        .S_AXI_wdata(axi_interconnect_0_to_s00_couplers_WDATA),
        .S_AXI_wlast(axi_interconnect_0_to_s00_couplers_WLAST),
        .S_AXI_wready(axi_interconnect_0_to_s00_couplers_WREADY),
        .S_AXI_wstrb(axi_interconnect_0_to_s00_couplers_WSTRB),
        .S_AXI_wvalid(axi_interconnect_0_to_s00_couplers_WVALID));
s01_couplers_imp_CRGJ2V s01_couplers
       (.M_ACLK(axi_interconnect_0_ACLK_net),
        .M_ARESETN(axi_interconnect_0_ARESETN_net),
        .M_AXI_araddr(s01_couplers_to_xbar_ARADDR),
        .M_AXI_arburst(s01_couplers_to_xbar_ARBURST),
        .M_AXI_arcache(s01_couplers_to_xbar_ARCACHE),
        .M_AXI_arlen(s01_couplers_to_xbar_ARLEN),
        .M_AXI_arlock(s01_couplers_to_xbar_ARLOCK),
        .M_AXI_arprot(s01_couplers_to_xbar_ARPROT),
        .M_AXI_arqos(s01_couplers_to_xbar_ARQOS),
        .M_AXI_arready(s01_couplers_to_xbar_ARREADY),
        .M_AXI_arsize(s01_couplers_to_xbar_ARSIZE),
        .M_AXI_arvalid(s01_couplers_to_xbar_ARVALID),
        .M_AXI_awaddr(s01_couplers_to_xbar_AWADDR),
        .M_AXI_awburst(s01_couplers_to_xbar_AWBURST),
        .M_AXI_awcache(s01_couplers_to_xbar_AWCACHE),
        .M_AXI_awlen(s01_couplers_to_xbar_AWLEN),
        .M_AXI_awlock(s01_couplers_to_xbar_AWLOCK),
        .M_AXI_awprot(s01_couplers_to_xbar_AWPROT),
        .M_AXI_awqos(s01_couplers_to_xbar_AWQOS),
        .M_AXI_awready(s01_couplers_to_xbar_AWREADY),
        .M_AXI_awsize(s01_couplers_to_xbar_AWSIZE),
        .M_AXI_awvalid(s01_couplers_to_xbar_AWVALID),
        .M_AXI_bready(s01_couplers_to_xbar_BREADY),
        .M_AXI_bresp(s01_couplers_to_xbar_BRESP),
        .M_AXI_bvalid(s01_couplers_to_xbar_BVALID),
        .M_AXI_rdata(s01_couplers_to_xbar_RDATA),
        .M_AXI_rlast(s01_couplers_to_xbar_RLAST),
        .M_AXI_rready(s01_couplers_to_xbar_RREADY),
        .M_AXI_rresp(s01_couplers_to_xbar_RRESP),
        .M_AXI_rvalid(s01_couplers_to_xbar_RVALID),
        .M_AXI_wdata(s01_couplers_to_xbar_WDATA),
        .M_AXI_wlast(s01_couplers_to_xbar_WLAST),
        .M_AXI_wready(s01_couplers_to_xbar_WREADY),
        .M_AXI_wstrb(s01_couplers_to_xbar_WSTRB),
        .M_AXI_wvalid(s01_couplers_to_xbar_WVALID),
        .S_ACLK(S01_ACLK_1),
        .S_ARESETN(S01_ARESETN_1),
        .S_AXI_araddr(axi_interconnect_0_to_s01_couplers_ARADDR),
        .S_AXI_arburst(axi_interconnect_0_to_s01_couplers_ARBURST),
        .S_AXI_arcache(axi_interconnect_0_to_s01_couplers_ARCACHE),
        .S_AXI_arlen(axi_interconnect_0_to_s01_couplers_ARLEN),
        .S_AXI_arprot(axi_interconnect_0_to_s01_couplers_ARPROT),
        .S_AXI_arready(axi_interconnect_0_to_s01_couplers_ARREADY),
        .S_AXI_arsize(axi_interconnect_0_to_s01_couplers_ARSIZE),
        .S_AXI_arvalid(axi_interconnect_0_to_s01_couplers_ARVALID),
        .S_AXI_awaddr(axi_interconnect_0_to_s01_couplers_AWADDR),
        .S_AXI_awburst(axi_interconnect_0_to_s01_couplers_AWBURST),
        .S_AXI_awcache(axi_interconnect_0_to_s01_couplers_AWCACHE),
        .S_AXI_awlen(axi_interconnect_0_to_s01_couplers_AWLEN),
        .S_AXI_awprot(axi_interconnect_0_to_s01_couplers_AWPROT),
        .S_AXI_awready(axi_interconnect_0_to_s01_couplers_AWREADY),
        .S_AXI_awsize(axi_interconnect_0_to_s01_couplers_AWSIZE),
        .S_AXI_awvalid(axi_interconnect_0_to_s01_couplers_AWVALID),
        .S_AXI_bready(axi_interconnect_0_to_s01_couplers_BREADY),
        .S_AXI_bresp(axi_interconnect_0_to_s01_couplers_BRESP),
        .S_AXI_bvalid(axi_interconnect_0_to_s01_couplers_BVALID),
        .S_AXI_rdata(axi_interconnect_0_to_s01_couplers_RDATA),
        .S_AXI_rlast(axi_interconnect_0_to_s01_couplers_RLAST),
        .S_AXI_rready(axi_interconnect_0_to_s01_couplers_RREADY),
        .S_AXI_rresp(axi_interconnect_0_to_s01_couplers_RRESP),
        .S_AXI_rvalid(axi_interconnect_0_to_s01_couplers_RVALID),
        .S_AXI_wdata(axi_interconnect_0_to_s01_couplers_WDATA),
        .S_AXI_wlast(axi_interconnect_0_to_s01_couplers_WLAST),
        .S_AXI_wready(axi_interconnect_0_to_s01_couplers_WREADY),
        .S_AXI_wstrb(axi_interconnect_0_to_s01_couplers_WSTRB),
        .S_AXI_wvalid(axi_interconnect_0_to_s01_couplers_WVALID));
OpenSSD2_xbar_1 xbar
       (.aclk(axi_interconnect_0_ACLK_net),
        .aresetn(axi_interconnect_0_ARESETN_net),
        .m_axi_araddr(xbar_to_m00_couplers_ARADDR),
        .m_axi_arburst(xbar_to_m00_couplers_ARBURST),
        .m_axi_arcache(xbar_to_m00_couplers_ARCACHE),
        .m_axi_arid(xbar_to_m00_couplers_ARID),
        .m_axi_arlen(xbar_to_m00_couplers_ARLEN),
        .m_axi_arlock(xbar_to_m00_couplers_ARLOCK),
        .m_axi_arprot(xbar_to_m00_couplers_ARPROT),
        .m_axi_arqos(xbar_to_m00_couplers_ARQOS),
        .m_axi_arready(xbar_to_m00_couplers_ARREADY),
        .m_axi_arregion(xbar_to_m00_couplers_ARREGION),
        .m_axi_arsize(xbar_to_m00_couplers_ARSIZE),
        .m_axi_arvalid(xbar_to_m00_couplers_ARVALID),
        .m_axi_awaddr(xbar_to_m00_couplers_AWADDR),
        .m_axi_awburst(xbar_to_m00_couplers_AWBURST),
        .m_axi_awcache(xbar_to_m00_couplers_AWCACHE),
        .m_axi_awid(xbar_to_m00_couplers_AWID),
        .m_axi_awlen(xbar_to_m00_couplers_AWLEN),
        .m_axi_awlock(xbar_to_m00_couplers_AWLOCK),
        .m_axi_awprot(xbar_to_m00_couplers_AWPROT),
        .m_axi_awqos(xbar_to_m00_couplers_AWQOS),
        .m_axi_awready(xbar_to_m00_couplers_AWREADY),
        .m_axi_awregion(xbar_to_m00_couplers_AWREGION),
        .m_axi_awsize(xbar_to_m00_couplers_AWSIZE),
        .m_axi_awvalid(xbar_to_m00_couplers_AWVALID),
        .m_axi_bid(xbar_to_m00_couplers_BID),
        .m_axi_bready(xbar_to_m00_couplers_BREADY),
        .m_axi_bresp(xbar_to_m00_couplers_BRESP),
        .m_axi_bvalid(xbar_to_m00_couplers_BVALID),
        .m_axi_rdata(xbar_to_m00_couplers_RDATA),
        .m_axi_rid(xbar_to_m00_couplers_RID),
        .m_axi_rlast(xbar_to_m00_couplers_RLAST),
        .m_axi_rready(xbar_to_m00_couplers_RREADY),
        .m_axi_rresp(xbar_to_m00_couplers_RRESP),
        .m_axi_rvalid(xbar_to_m00_couplers_RVALID),
        .m_axi_wdata(xbar_to_m00_couplers_WDATA),
        .m_axi_wlast(xbar_to_m00_couplers_WLAST),
        .m_axi_wready(xbar_to_m00_couplers_WREADY),
        .m_axi_wstrb(xbar_to_m00_couplers_WSTRB),
        .m_axi_wvalid(xbar_to_m00_couplers_WVALID),
        .s_axi_araddr({s01_couplers_to_xbar_ARADDR,s00_couplers_to_xbar_ARADDR}),
        .s_axi_arburst({s01_couplers_to_xbar_ARBURST,s00_couplers_to_xbar_ARBURST}),
        .s_axi_arcache({s01_couplers_to_xbar_ARCACHE,s00_couplers_to_xbar_ARCACHE}),
        .s_axi_arid({GND_1,GND_1}),
        .s_axi_arlen({s01_couplers_to_xbar_ARLEN,s00_couplers_to_xbar_ARLEN}),
        .s_axi_arlock({s01_couplers_to_xbar_ARLOCK,s00_couplers_to_xbar_ARLOCK}),
        .s_axi_arprot({s01_couplers_to_xbar_ARPROT,s00_couplers_to_xbar_ARPROT}),
        .s_axi_arqos({s01_couplers_to_xbar_ARQOS,s00_couplers_to_xbar_ARQOS}),
        .s_axi_arready({s01_couplers_to_xbar_ARREADY,s00_couplers_to_xbar_ARREADY}),
        .s_axi_arsize({s01_couplers_to_xbar_ARSIZE,s00_couplers_to_xbar_ARSIZE}),
        .s_axi_arvalid({s01_couplers_to_xbar_ARVALID,s00_couplers_to_xbar_ARVALID}),
        .s_axi_awaddr({s01_couplers_to_xbar_AWADDR,s00_couplers_to_xbar_AWADDR}),
        .s_axi_awburst({s01_couplers_to_xbar_AWBURST,s00_couplers_to_xbar_AWBURST}),
        .s_axi_awcache({s01_couplers_to_xbar_AWCACHE,s00_couplers_to_xbar_AWCACHE}),
        .s_axi_awid({GND_1,GND_1}),
        .s_axi_awlen({s01_couplers_to_xbar_AWLEN,s00_couplers_to_xbar_AWLEN}),
        .s_axi_awlock({s01_couplers_to_xbar_AWLOCK,s00_couplers_to_xbar_AWLOCK}),
        .s_axi_awprot({s01_couplers_to_xbar_AWPROT,s00_couplers_to_xbar_AWPROT}),
        .s_axi_awqos({s01_couplers_to_xbar_AWQOS,s00_couplers_to_xbar_AWQOS}),
        .s_axi_awready({s01_couplers_to_xbar_AWREADY,s00_couplers_to_xbar_AWREADY}),
        .s_axi_awsize({s01_couplers_to_xbar_AWSIZE,s00_couplers_to_xbar_AWSIZE}),
        .s_axi_awvalid({s01_couplers_to_xbar_AWVALID,s00_couplers_to_xbar_AWVALID}),
        .s_axi_bready({s01_couplers_to_xbar_BREADY,s00_couplers_to_xbar_BREADY}),
        .s_axi_bresp({s01_couplers_to_xbar_BRESP,s00_couplers_to_xbar_BRESP}),
        .s_axi_bvalid({s01_couplers_to_xbar_BVALID,s00_couplers_to_xbar_BVALID}),
        .s_axi_rdata({s01_couplers_to_xbar_RDATA,s00_couplers_to_xbar_RDATA}),
        .s_axi_rlast({s01_couplers_to_xbar_RLAST,s00_couplers_to_xbar_RLAST}),
        .s_axi_rready({s01_couplers_to_xbar_RREADY,s00_couplers_to_xbar_RREADY}),
        .s_axi_rresp({s01_couplers_to_xbar_RRESP,s00_couplers_to_xbar_RRESP}),
        .s_axi_rvalid({s01_couplers_to_xbar_RVALID,s00_couplers_to_xbar_RVALID}),
        .s_axi_wdata({s01_couplers_to_xbar_WDATA,s00_couplers_to_xbar_WDATA}),
        .s_axi_wlast({s01_couplers_to_xbar_WLAST,s00_couplers_to_xbar_WLAST}),
        .s_axi_wready({s01_couplers_to_xbar_WREADY,s00_couplers_to_xbar_WREADY}),
        .s_axi_wstrb({s01_couplers_to_xbar_WSTRB,s00_couplers_to_xbar_WSTRB}),
        .s_axi_wvalid({s01_couplers_to_xbar_WVALID,s00_couplers_to_xbar_WVALID}));
endmodule

module m00_couplers_imp_12DCAQQ
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arprot,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awprot,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arprot,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awprot,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input [0:0]M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [2:0]M_AXI_arprot;
  input M_AXI_arready;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [2:0]M_AXI_awprot;
  input M_AXI_awready;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input [0:0]S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [2:0]S_AXI_arprot;
  output S_AXI_arready;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [2:0]S_AXI_awprot;
  output S_AXI_awready;
  input S_AXI_awvalid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  output S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire [31:0]m00_couplers_to_m00_couplers_ARADDR;
  wire [2:0]m00_couplers_to_m00_couplers_ARPROT;
  wire m00_couplers_to_m00_couplers_ARREADY;
  wire m00_couplers_to_m00_couplers_ARVALID;
  wire [31:0]m00_couplers_to_m00_couplers_AWADDR;
  wire [2:0]m00_couplers_to_m00_couplers_AWPROT;
  wire m00_couplers_to_m00_couplers_AWREADY;
  wire m00_couplers_to_m00_couplers_AWVALID;
  wire m00_couplers_to_m00_couplers_BREADY;
  wire [1:0]m00_couplers_to_m00_couplers_BRESP;
  wire m00_couplers_to_m00_couplers_BVALID;
  wire [31:0]m00_couplers_to_m00_couplers_RDATA;
  wire m00_couplers_to_m00_couplers_RREADY;
  wire [1:0]m00_couplers_to_m00_couplers_RRESP;
  wire m00_couplers_to_m00_couplers_RVALID;
  wire [31:0]m00_couplers_to_m00_couplers_WDATA;
  wire m00_couplers_to_m00_couplers_WREADY;
  wire [3:0]m00_couplers_to_m00_couplers_WSTRB;
  wire m00_couplers_to_m00_couplers_WVALID;

  assign M_AXI_araddr[31:0] = m00_couplers_to_m00_couplers_ARADDR;
  assign M_AXI_arprot[2:0] = m00_couplers_to_m00_couplers_ARPROT;
  assign M_AXI_arvalid = m00_couplers_to_m00_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = m00_couplers_to_m00_couplers_AWADDR;
  assign M_AXI_awprot[2:0] = m00_couplers_to_m00_couplers_AWPROT;
  assign M_AXI_awvalid = m00_couplers_to_m00_couplers_AWVALID;
  assign M_AXI_bready = m00_couplers_to_m00_couplers_BREADY;
  assign M_AXI_rready = m00_couplers_to_m00_couplers_RREADY;
  assign M_AXI_wdata[31:0] = m00_couplers_to_m00_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = m00_couplers_to_m00_couplers_WSTRB;
  assign M_AXI_wvalid = m00_couplers_to_m00_couplers_WVALID;
  assign S_AXI_arready = m00_couplers_to_m00_couplers_ARREADY;
  assign S_AXI_awready = m00_couplers_to_m00_couplers_AWREADY;
  assign S_AXI_bresp[1:0] = m00_couplers_to_m00_couplers_BRESP;
  assign S_AXI_bvalid = m00_couplers_to_m00_couplers_BVALID;
  assign S_AXI_rdata[31:0] = m00_couplers_to_m00_couplers_RDATA;
  assign S_AXI_rresp[1:0] = m00_couplers_to_m00_couplers_RRESP;
  assign S_AXI_rvalid = m00_couplers_to_m00_couplers_RVALID;
  assign S_AXI_wready = m00_couplers_to_m00_couplers_WREADY;
  assign m00_couplers_to_m00_couplers_ARADDR = S_AXI_araddr[31:0];
  assign m00_couplers_to_m00_couplers_ARPROT = S_AXI_arprot[2:0];
  assign m00_couplers_to_m00_couplers_ARREADY = M_AXI_arready;
  assign m00_couplers_to_m00_couplers_ARVALID = S_AXI_arvalid;
  assign m00_couplers_to_m00_couplers_AWADDR = S_AXI_awaddr[31:0];
  assign m00_couplers_to_m00_couplers_AWPROT = S_AXI_awprot[2:0];
  assign m00_couplers_to_m00_couplers_AWREADY = M_AXI_awready;
  assign m00_couplers_to_m00_couplers_AWVALID = S_AXI_awvalid;
  assign m00_couplers_to_m00_couplers_BREADY = S_AXI_bready;
  assign m00_couplers_to_m00_couplers_BRESP = M_AXI_bresp[1:0];
  assign m00_couplers_to_m00_couplers_BVALID = M_AXI_bvalid;
  assign m00_couplers_to_m00_couplers_RDATA = M_AXI_rdata[31:0];
  assign m00_couplers_to_m00_couplers_RREADY = S_AXI_rready;
  assign m00_couplers_to_m00_couplers_RRESP = M_AXI_rresp[1:0];
  assign m00_couplers_to_m00_couplers_RVALID = M_AXI_rvalid;
  assign m00_couplers_to_m00_couplers_WDATA = S_AXI_wdata[31:0];
  assign m00_couplers_to_m00_couplers_WREADY = M_AXI_wready;
  assign m00_couplers_to_m00_couplers_WSTRB = S_AXI_wstrb[3:0];
  assign m00_couplers_to_m00_couplers_WVALID = S_AXI_wvalid;
endmodule

module m00_couplers_imp_GJ2UD0
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arburst,
    M_AXI_arcache,
    M_AXI_arid,
    M_AXI_arlen,
    M_AXI_arlock,
    M_AXI_arprot,
    M_AXI_arqos,
    M_AXI_arready,
    M_AXI_arsize,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awburst,
    M_AXI_awcache,
    M_AXI_awid,
    M_AXI_awlen,
    M_AXI_awlock,
    M_AXI_awprot,
    M_AXI_awqos,
    M_AXI_awready,
    M_AXI_awsize,
    M_AXI_awvalid,
    M_AXI_bid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rid,
    M_AXI_rlast,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wid,
    M_AXI_wlast,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arburst,
    S_AXI_arcache,
    S_AXI_arid,
    S_AXI_arlen,
    S_AXI_arlock,
    S_AXI_arprot,
    S_AXI_arqos,
    S_AXI_arready,
    S_AXI_arregion,
    S_AXI_arsize,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awburst,
    S_AXI_awcache,
    S_AXI_awid,
    S_AXI_awlen,
    S_AXI_awlock,
    S_AXI_awprot,
    S_AXI_awqos,
    S_AXI_awready,
    S_AXI_awregion,
    S_AXI_awsize,
    S_AXI_awvalid,
    S_AXI_bid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rid,
    S_AXI_rlast,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wlast,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input [0:0]M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [1:0]M_AXI_arburst;
  output [3:0]M_AXI_arcache;
  output [0:0]M_AXI_arid;
  output [3:0]M_AXI_arlen;
  output [1:0]M_AXI_arlock;
  output [2:0]M_AXI_arprot;
  output [3:0]M_AXI_arqos;
  input M_AXI_arready;
  output [2:0]M_AXI_arsize;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [1:0]M_AXI_awburst;
  output [3:0]M_AXI_awcache;
  output [0:0]M_AXI_awid;
  output [3:0]M_AXI_awlen;
  output [1:0]M_AXI_awlock;
  output [2:0]M_AXI_awprot;
  output [3:0]M_AXI_awqos;
  input M_AXI_awready;
  output [2:0]M_AXI_awsize;
  output M_AXI_awvalid;
  input [0:0]M_AXI_bid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [63:0]M_AXI_rdata;
  input [0:0]M_AXI_rid;
  input M_AXI_rlast;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [63:0]M_AXI_wdata;
  output [0:0]M_AXI_wid;
  output M_AXI_wlast;
  input M_AXI_wready;
  output [7:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input [0:0]S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [1:0]S_AXI_arburst;
  input [3:0]S_AXI_arcache;
  input [0:0]S_AXI_arid;
  input [7:0]S_AXI_arlen;
  input [0:0]S_AXI_arlock;
  input [2:0]S_AXI_arprot;
  input [3:0]S_AXI_arqos;
  output S_AXI_arready;
  input [3:0]S_AXI_arregion;
  input [2:0]S_AXI_arsize;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [1:0]S_AXI_awburst;
  input [3:0]S_AXI_awcache;
  input [0:0]S_AXI_awid;
  input [7:0]S_AXI_awlen;
  input [0:0]S_AXI_awlock;
  input [2:0]S_AXI_awprot;
  input [3:0]S_AXI_awqos;
  output S_AXI_awready;
  input [3:0]S_AXI_awregion;
  input [2:0]S_AXI_awsize;
  input S_AXI_awvalid;
  output [0:0]S_AXI_bid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [63:0]S_AXI_rdata;
  output [0:0]S_AXI_rid;
  output S_AXI_rlast;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [63:0]S_AXI_wdata;
  input S_AXI_wlast;
  output S_AXI_wready;
  input [7:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire M_ACLK_1;
  wire [0:0]M_ARESETN_1;
  wire S_ACLK_1;
  wire [0:0]S_ARESETN_1;
  wire [31:0]auto_pc_to_m00_regslice_ARADDR;
  wire [1:0]auto_pc_to_m00_regslice_ARBURST;
  wire [3:0]auto_pc_to_m00_regslice_ARCACHE;
  wire [0:0]auto_pc_to_m00_regslice_ARID;
  wire [3:0]auto_pc_to_m00_regslice_ARLEN;
  wire [1:0]auto_pc_to_m00_regslice_ARLOCK;
  wire [2:0]auto_pc_to_m00_regslice_ARPROT;
  wire [3:0]auto_pc_to_m00_regslice_ARQOS;
  wire auto_pc_to_m00_regslice_ARREADY;
  wire [2:0]auto_pc_to_m00_regslice_ARSIZE;
  wire auto_pc_to_m00_regslice_ARVALID;
  wire [31:0]auto_pc_to_m00_regslice_AWADDR;
  wire [1:0]auto_pc_to_m00_regslice_AWBURST;
  wire [3:0]auto_pc_to_m00_regslice_AWCACHE;
  wire [0:0]auto_pc_to_m00_regslice_AWID;
  wire [3:0]auto_pc_to_m00_regslice_AWLEN;
  wire [1:0]auto_pc_to_m00_regslice_AWLOCK;
  wire [2:0]auto_pc_to_m00_regslice_AWPROT;
  wire [3:0]auto_pc_to_m00_regslice_AWQOS;
  wire auto_pc_to_m00_regslice_AWREADY;
  wire [2:0]auto_pc_to_m00_regslice_AWSIZE;
  wire auto_pc_to_m00_regslice_AWVALID;
  wire [0:0]auto_pc_to_m00_regslice_BID;
  wire auto_pc_to_m00_regslice_BREADY;
  wire [1:0]auto_pc_to_m00_regslice_BRESP;
  wire auto_pc_to_m00_regslice_BVALID;
  wire [63:0]auto_pc_to_m00_regslice_RDATA;
  wire [0:0]auto_pc_to_m00_regslice_RID;
  wire auto_pc_to_m00_regslice_RLAST;
  wire auto_pc_to_m00_regslice_RREADY;
  wire [1:0]auto_pc_to_m00_regslice_RRESP;
  wire auto_pc_to_m00_regslice_RVALID;
  wire [63:0]auto_pc_to_m00_regslice_WDATA;
  wire [0:0]auto_pc_to_m00_regslice_WID;
  wire auto_pc_to_m00_regslice_WLAST;
  wire auto_pc_to_m00_regslice_WREADY;
  wire [7:0]auto_pc_to_m00_regslice_WSTRB;
  wire auto_pc_to_m00_regslice_WVALID;
  wire [31:0]m00_couplers_to_m00_data_fifo_ARADDR;
  wire [1:0]m00_couplers_to_m00_data_fifo_ARBURST;
  wire [3:0]m00_couplers_to_m00_data_fifo_ARCACHE;
  wire [0:0]m00_couplers_to_m00_data_fifo_ARID;
  wire [7:0]m00_couplers_to_m00_data_fifo_ARLEN;
  wire [0:0]m00_couplers_to_m00_data_fifo_ARLOCK;
  wire [2:0]m00_couplers_to_m00_data_fifo_ARPROT;
  wire [3:0]m00_couplers_to_m00_data_fifo_ARQOS;
  wire m00_couplers_to_m00_data_fifo_ARREADY;
  wire [3:0]m00_couplers_to_m00_data_fifo_ARREGION;
  wire [2:0]m00_couplers_to_m00_data_fifo_ARSIZE;
  wire m00_couplers_to_m00_data_fifo_ARVALID;
  wire [31:0]m00_couplers_to_m00_data_fifo_AWADDR;
  wire [1:0]m00_couplers_to_m00_data_fifo_AWBURST;
  wire [3:0]m00_couplers_to_m00_data_fifo_AWCACHE;
  wire [0:0]m00_couplers_to_m00_data_fifo_AWID;
  wire [7:0]m00_couplers_to_m00_data_fifo_AWLEN;
  wire [0:0]m00_couplers_to_m00_data_fifo_AWLOCK;
  wire [2:0]m00_couplers_to_m00_data_fifo_AWPROT;
  wire [3:0]m00_couplers_to_m00_data_fifo_AWQOS;
  wire m00_couplers_to_m00_data_fifo_AWREADY;
  wire [3:0]m00_couplers_to_m00_data_fifo_AWREGION;
  wire [2:0]m00_couplers_to_m00_data_fifo_AWSIZE;
  wire m00_couplers_to_m00_data_fifo_AWVALID;
  wire [0:0]m00_couplers_to_m00_data_fifo_BID;
  wire m00_couplers_to_m00_data_fifo_BREADY;
  wire [1:0]m00_couplers_to_m00_data_fifo_BRESP;
  wire m00_couplers_to_m00_data_fifo_BVALID;
  wire [63:0]m00_couplers_to_m00_data_fifo_RDATA;
  wire [0:0]m00_couplers_to_m00_data_fifo_RID;
  wire m00_couplers_to_m00_data_fifo_RLAST;
  wire m00_couplers_to_m00_data_fifo_RREADY;
  wire [1:0]m00_couplers_to_m00_data_fifo_RRESP;
  wire m00_couplers_to_m00_data_fifo_RVALID;
  wire [63:0]m00_couplers_to_m00_data_fifo_WDATA;
  wire m00_couplers_to_m00_data_fifo_WLAST;
  wire m00_couplers_to_m00_data_fifo_WREADY;
  wire [7:0]m00_couplers_to_m00_data_fifo_WSTRB;
  wire m00_couplers_to_m00_data_fifo_WVALID;
  wire [31:0]m00_data_fifo_to_auto_pc_ARADDR;
  wire [1:0]m00_data_fifo_to_auto_pc_ARBURST;
  wire [3:0]m00_data_fifo_to_auto_pc_ARCACHE;
  wire [0:0]m00_data_fifo_to_auto_pc_ARID;
  wire [7:0]m00_data_fifo_to_auto_pc_ARLEN;
  wire [0:0]m00_data_fifo_to_auto_pc_ARLOCK;
  wire [2:0]m00_data_fifo_to_auto_pc_ARPROT;
  wire [3:0]m00_data_fifo_to_auto_pc_ARQOS;
  wire m00_data_fifo_to_auto_pc_ARREADY;
  wire [3:0]m00_data_fifo_to_auto_pc_ARREGION;
  wire [2:0]m00_data_fifo_to_auto_pc_ARSIZE;
  wire m00_data_fifo_to_auto_pc_ARVALID;
  wire [31:0]m00_data_fifo_to_auto_pc_AWADDR;
  wire [1:0]m00_data_fifo_to_auto_pc_AWBURST;
  wire [3:0]m00_data_fifo_to_auto_pc_AWCACHE;
  wire [0:0]m00_data_fifo_to_auto_pc_AWID;
  wire [7:0]m00_data_fifo_to_auto_pc_AWLEN;
  wire [0:0]m00_data_fifo_to_auto_pc_AWLOCK;
  wire [2:0]m00_data_fifo_to_auto_pc_AWPROT;
  wire [3:0]m00_data_fifo_to_auto_pc_AWQOS;
  wire m00_data_fifo_to_auto_pc_AWREADY;
  wire [3:0]m00_data_fifo_to_auto_pc_AWREGION;
  wire [2:0]m00_data_fifo_to_auto_pc_AWSIZE;
  wire m00_data_fifo_to_auto_pc_AWVALID;
  wire [0:0]m00_data_fifo_to_auto_pc_BID;
  wire m00_data_fifo_to_auto_pc_BREADY;
  wire [1:0]m00_data_fifo_to_auto_pc_BRESP;
  wire m00_data_fifo_to_auto_pc_BVALID;
  wire [63:0]m00_data_fifo_to_auto_pc_RDATA;
  wire [0:0]m00_data_fifo_to_auto_pc_RID;
  wire m00_data_fifo_to_auto_pc_RLAST;
  wire m00_data_fifo_to_auto_pc_RREADY;
  wire [1:0]m00_data_fifo_to_auto_pc_RRESP;
  wire m00_data_fifo_to_auto_pc_RVALID;
  wire [63:0]m00_data_fifo_to_auto_pc_WDATA;
  wire m00_data_fifo_to_auto_pc_WLAST;
  wire m00_data_fifo_to_auto_pc_WREADY;
  wire [7:0]m00_data_fifo_to_auto_pc_WSTRB;
  wire m00_data_fifo_to_auto_pc_WVALID;
  wire [31:0]m00_regslice_to_m00_couplers_ARADDR;
  wire [1:0]m00_regslice_to_m00_couplers_ARBURST;
  wire [3:0]m00_regslice_to_m00_couplers_ARCACHE;
  wire [0:0]m00_regslice_to_m00_couplers_ARID;
  wire [3:0]m00_regslice_to_m00_couplers_ARLEN;
  wire [1:0]m00_regslice_to_m00_couplers_ARLOCK;
  wire [2:0]m00_regslice_to_m00_couplers_ARPROT;
  wire [3:0]m00_regslice_to_m00_couplers_ARQOS;
  wire m00_regslice_to_m00_couplers_ARREADY;
  wire [2:0]m00_regslice_to_m00_couplers_ARSIZE;
  wire m00_regslice_to_m00_couplers_ARVALID;
  wire [31:0]m00_regslice_to_m00_couplers_AWADDR;
  wire [1:0]m00_regslice_to_m00_couplers_AWBURST;
  wire [3:0]m00_regslice_to_m00_couplers_AWCACHE;
  wire [0:0]m00_regslice_to_m00_couplers_AWID;
  wire [3:0]m00_regslice_to_m00_couplers_AWLEN;
  wire [1:0]m00_regslice_to_m00_couplers_AWLOCK;
  wire [2:0]m00_regslice_to_m00_couplers_AWPROT;
  wire [3:0]m00_regslice_to_m00_couplers_AWQOS;
  wire m00_regslice_to_m00_couplers_AWREADY;
  wire [2:0]m00_regslice_to_m00_couplers_AWSIZE;
  wire m00_regslice_to_m00_couplers_AWVALID;
  wire [0:0]m00_regslice_to_m00_couplers_BID;
  wire m00_regslice_to_m00_couplers_BREADY;
  wire [1:0]m00_regslice_to_m00_couplers_BRESP;
  wire m00_regslice_to_m00_couplers_BVALID;
  wire [63:0]m00_regslice_to_m00_couplers_RDATA;
  wire [0:0]m00_regslice_to_m00_couplers_RID;
  wire m00_regslice_to_m00_couplers_RLAST;
  wire m00_regslice_to_m00_couplers_RREADY;
  wire [1:0]m00_regslice_to_m00_couplers_RRESP;
  wire m00_regslice_to_m00_couplers_RVALID;
  wire [63:0]m00_regslice_to_m00_couplers_WDATA;
  wire [0:0]m00_regslice_to_m00_couplers_WID;
  wire m00_regslice_to_m00_couplers_WLAST;
  wire m00_regslice_to_m00_couplers_WREADY;
  wire [7:0]m00_regslice_to_m00_couplers_WSTRB;
  wire m00_regslice_to_m00_couplers_WVALID;

  assign M_ACLK_1 = M_ACLK;
  assign M_ARESETN_1 = M_ARESETN[0];
  assign M_AXI_araddr[31:0] = m00_regslice_to_m00_couplers_ARADDR;
  assign M_AXI_arburst[1:0] = m00_regslice_to_m00_couplers_ARBURST;
  assign M_AXI_arcache[3:0] = m00_regslice_to_m00_couplers_ARCACHE;
  assign M_AXI_arid[0] = m00_regslice_to_m00_couplers_ARID;
  assign M_AXI_arlen[3:0] = m00_regslice_to_m00_couplers_ARLEN;
  assign M_AXI_arlock[1:0] = m00_regslice_to_m00_couplers_ARLOCK;
  assign M_AXI_arprot[2:0] = m00_regslice_to_m00_couplers_ARPROT;
  assign M_AXI_arqos[3:0] = m00_regslice_to_m00_couplers_ARQOS;
  assign M_AXI_arsize[2:0] = m00_regslice_to_m00_couplers_ARSIZE;
  assign M_AXI_arvalid = m00_regslice_to_m00_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = m00_regslice_to_m00_couplers_AWADDR;
  assign M_AXI_awburst[1:0] = m00_regslice_to_m00_couplers_AWBURST;
  assign M_AXI_awcache[3:0] = m00_regslice_to_m00_couplers_AWCACHE;
  assign M_AXI_awid[0] = m00_regslice_to_m00_couplers_AWID;
  assign M_AXI_awlen[3:0] = m00_regslice_to_m00_couplers_AWLEN;
  assign M_AXI_awlock[1:0] = m00_regslice_to_m00_couplers_AWLOCK;
  assign M_AXI_awprot[2:0] = m00_regslice_to_m00_couplers_AWPROT;
  assign M_AXI_awqos[3:0] = m00_regslice_to_m00_couplers_AWQOS;
  assign M_AXI_awsize[2:0] = m00_regslice_to_m00_couplers_AWSIZE;
  assign M_AXI_awvalid = m00_regslice_to_m00_couplers_AWVALID;
  assign M_AXI_bready = m00_regslice_to_m00_couplers_BREADY;
  assign M_AXI_rready = m00_regslice_to_m00_couplers_RREADY;
  assign M_AXI_wdata[63:0] = m00_regslice_to_m00_couplers_WDATA;
  assign M_AXI_wid[0] = m00_regslice_to_m00_couplers_WID;
  assign M_AXI_wlast = m00_regslice_to_m00_couplers_WLAST;
  assign M_AXI_wstrb[7:0] = m00_regslice_to_m00_couplers_WSTRB;
  assign M_AXI_wvalid = m00_regslice_to_m00_couplers_WVALID;
  assign S_ACLK_1 = S_ACLK;
  assign S_ARESETN_1 = S_ARESETN[0];
  assign S_AXI_arready = m00_couplers_to_m00_data_fifo_ARREADY;
  assign S_AXI_awready = m00_couplers_to_m00_data_fifo_AWREADY;
  assign S_AXI_bid[0] = m00_couplers_to_m00_data_fifo_BID;
  assign S_AXI_bresp[1:0] = m00_couplers_to_m00_data_fifo_BRESP;
  assign S_AXI_bvalid = m00_couplers_to_m00_data_fifo_BVALID;
  assign S_AXI_rdata[63:0] = m00_couplers_to_m00_data_fifo_RDATA;
  assign S_AXI_rid[0] = m00_couplers_to_m00_data_fifo_RID;
  assign S_AXI_rlast = m00_couplers_to_m00_data_fifo_RLAST;
  assign S_AXI_rresp[1:0] = m00_couplers_to_m00_data_fifo_RRESP;
  assign S_AXI_rvalid = m00_couplers_to_m00_data_fifo_RVALID;
  assign S_AXI_wready = m00_couplers_to_m00_data_fifo_WREADY;
  assign m00_couplers_to_m00_data_fifo_ARADDR = S_AXI_araddr[31:0];
  assign m00_couplers_to_m00_data_fifo_ARBURST = S_AXI_arburst[1:0];
  assign m00_couplers_to_m00_data_fifo_ARCACHE = S_AXI_arcache[3:0];
  assign m00_couplers_to_m00_data_fifo_ARID = S_AXI_arid[0];
  assign m00_couplers_to_m00_data_fifo_ARLEN = S_AXI_arlen[7:0];
  assign m00_couplers_to_m00_data_fifo_ARLOCK = S_AXI_arlock[0];
  assign m00_couplers_to_m00_data_fifo_ARPROT = S_AXI_arprot[2:0];
  assign m00_couplers_to_m00_data_fifo_ARQOS = S_AXI_arqos[3:0];
  assign m00_couplers_to_m00_data_fifo_ARREGION = S_AXI_arregion[3:0];
  assign m00_couplers_to_m00_data_fifo_ARSIZE = S_AXI_arsize[2:0];
  assign m00_couplers_to_m00_data_fifo_ARVALID = S_AXI_arvalid;
  assign m00_couplers_to_m00_data_fifo_AWADDR = S_AXI_awaddr[31:0];
  assign m00_couplers_to_m00_data_fifo_AWBURST = S_AXI_awburst[1:0];
  assign m00_couplers_to_m00_data_fifo_AWCACHE = S_AXI_awcache[3:0];
  assign m00_couplers_to_m00_data_fifo_AWID = S_AXI_awid[0];
  assign m00_couplers_to_m00_data_fifo_AWLEN = S_AXI_awlen[7:0];
  assign m00_couplers_to_m00_data_fifo_AWLOCK = S_AXI_awlock[0];
  assign m00_couplers_to_m00_data_fifo_AWPROT = S_AXI_awprot[2:0];
  assign m00_couplers_to_m00_data_fifo_AWQOS = S_AXI_awqos[3:0];
  assign m00_couplers_to_m00_data_fifo_AWREGION = S_AXI_awregion[3:0];
  assign m00_couplers_to_m00_data_fifo_AWSIZE = S_AXI_awsize[2:0];
  assign m00_couplers_to_m00_data_fifo_AWVALID = S_AXI_awvalid;
  assign m00_couplers_to_m00_data_fifo_BREADY = S_AXI_bready;
  assign m00_couplers_to_m00_data_fifo_RREADY = S_AXI_rready;
  assign m00_couplers_to_m00_data_fifo_WDATA = S_AXI_wdata[63:0];
  assign m00_couplers_to_m00_data_fifo_WLAST = S_AXI_wlast;
  assign m00_couplers_to_m00_data_fifo_WSTRB = S_AXI_wstrb[7:0];
  assign m00_couplers_to_m00_data_fifo_WVALID = S_AXI_wvalid;
  assign m00_regslice_to_m00_couplers_ARREADY = M_AXI_arready;
  assign m00_regslice_to_m00_couplers_AWREADY = M_AXI_awready;
  assign m00_regslice_to_m00_couplers_BID = M_AXI_bid[0];
  assign m00_regslice_to_m00_couplers_BRESP = M_AXI_bresp[1:0];
  assign m00_regslice_to_m00_couplers_BVALID = M_AXI_bvalid;
  assign m00_regslice_to_m00_couplers_RDATA = M_AXI_rdata[63:0];
  assign m00_regslice_to_m00_couplers_RID = M_AXI_rid[0];
  assign m00_regslice_to_m00_couplers_RLAST = M_AXI_rlast;
  assign m00_regslice_to_m00_couplers_RRESP = M_AXI_rresp[1:0];
  assign m00_regslice_to_m00_couplers_RVALID = M_AXI_rvalid;
  assign m00_regslice_to_m00_couplers_WREADY = M_AXI_wready;
OpenSSD2_auto_pc_3 auto_pc
       (.aclk(S_ACLK_1),
        .aresetn(S_ARESETN_1),
        .m_axi_araddr(auto_pc_to_m00_regslice_ARADDR),
        .m_axi_arburst(auto_pc_to_m00_regslice_ARBURST),
        .m_axi_arcache(auto_pc_to_m00_regslice_ARCACHE),
        .m_axi_arid(auto_pc_to_m00_regslice_ARID),
        .m_axi_arlen(auto_pc_to_m00_regslice_ARLEN),
        .m_axi_arlock(auto_pc_to_m00_regslice_ARLOCK),
        .m_axi_arprot(auto_pc_to_m00_regslice_ARPROT),
        .m_axi_arqos(auto_pc_to_m00_regslice_ARQOS),
        .m_axi_arready(auto_pc_to_m00_regslice_ARREADY),
        .m_axi_arsize(auto_pc_to_m00_regslice_ARSIZE),
        .m_axi_arvalid(auto_pc_to_m00_regslice_ARVALID),
        .m_axi_awaddr(auto_pc_to_m00_regslice_AWADDR),
        .m_axi_awburst(auto_pc_to_m00_regslice_AWBURST),
        .m_axi_awcache(auto_pc_to_m00_regslice_AWCACHE),
        .m_axi_awid(auto_pc_to_m00_regslice_AWID),
        .m_axi_awlen(auto_pc_to_m00_regslice_AWLEN),
        .m_axi_awlock(auto_pc_to_m00_regslice_AWLOCK),
        .m_axi_awprot(auto_pc_to_m00_regslice_AWPROT),
        .m_axi_awqos(auto_pc_to_m00_regslice_AWQOS),
        .m_axi_awready(auto_pc_to_m00_regslice_AWREADY),
        .m_axi_awsize(auto_pc_to_m00_regslice_AWSIZE),
        .m_axi_awvalid(auto_pc_to_m00_regslice_AWVALID),
        .m_axi_bid(auto_pc_to_m00_regslice_BID),
        .m_axi_bready(auto_pc_to_m00_regslice_BREADY),
        .m_axi_bresp(auto_pc_to_m00_regslice_BRESP),
        .m_axi_bvalid(auto_pc_to_m00_regslice_BVALID),
        .m_axi_rdata(auto_pc_to_m00_regslice_RDATA),
        .m_axi_rid(auto_pc_to_m00_regslice_RID),
        .m_axi_rlast(auto_pc_to_m00_regslice_RLAST),
        .m_axi_rready(auto_pc_to_m00_regslice_RREADY),
        .m_axi_rresp(auto_pc_to_m00_regslice_RRESP),
        .m_axi_rvalid(auto_pc_to_m00_regslice_RVALID),
        .m_axi_wdata(auto_pc_to_m00_regslice_WDATA),
        .m_axi_wid(auto_pc_to_m00_regslice_WID),
        .m_axi_wlast(auto_pc_to_m00_regslice_WLAST),
        .m_axi_wready(auto_pc_to_m00_regslice_WREADY),
        .m_axi_wstrb(auto_pc_to_m00_regslice_WSTRB),
        .m_axi_wvalid(auto_pc_to_m00_regslice_WVALID),
        .s_axi_araddr(m00_data_fifo_to_auto_pc_ARADDR),
        .s_axi_arburst(m00_data_fifo_to_auto_pc_ARBURST),
        .s_axi_arcache(m00_data_fifo_to_auto_pc_ARCACHE),
        .s_axi_arid(m00_data_fifo_to_auto_pc_ARID),
        .s_axi_arlen(m00_data_fifo_to_auto_pc_ARLEN),
        .s_axi_arlock(m00_data_fifo_to_auto_pc_ARLOCK),
        .s_axi_arprot(m00_data_fifo_to_auto_pc_ARPROT),
        .s_axi_arqos(m00_data_fifo_to_auto_pc_ARQOS),
        .s_axi_arready(m00_data_fifo_to_auto_pc_ARREADY),
        .s_axi_arregion(m00_data_fifo_to_auto_pc_ARREGION),
        .s_axi_arsize(m00_data_fifo_to_auto_pc_ARSIZE),
        .s_axi_arvalid(m00_data_fifo_to_auto_pc_ARVALID),
        .s_axi_awaddr(m00_data_fifo_to_auto_pc_AWADDR),
        .s_axi_awburst(m00_data_fifo_to_auto_pc_AWBURST),
        .s_axi_awcache(m00_data_fifo_to_auto_pc_AWCACHE),
        .s_axi_awid(m00_data_fifo_to_auto_pc_AWID),
        .s_axi_awlen(m00_data_fifo_to_auto_pc_AWLEN),
        .s_axi_awlock(m00_data_fifo_to_auto_pc_AWLOCK),
        .s_axi_awprot(m00_data_fifo_to_auto_pc_AWPROT),
        .s_axi_awqos(m00_data_fifo_to_auto_pc_AWQOS),
        .s_axi_awready(m00_data_fifo_to_auto_pc_AWREADY),
        .s_axi_awregion(m00_data_fifo_to_auto_pc_AWREGION),
        .s_axi_awsize(m00_data_fifo_to_auto_pc_AWSIZE),
        .s_axi_awvalid(m00_data_fifo_to_auto_pc_AWVALID),
        .s_axi_bid(m00_data_fifo_to_auto_pc_BID),
        .s_axi_bready(m00_data_fifo_to_auto_pc_BREADY),
        .s_axi_bresp(m00_data_fifo_to_auto_pc_BRESP),
        .s_axi_bvalid(m00_data_fifo_to_auto_pc_BVALID),
        .s_axi_rdata(m00_data_fifo_to_auto_pc_RDATA),
        .s_axi_rid(m00_data_fifo_to_auto_pc_RID),
        .s_axi_rlast(m00_data_fifo_to_auto_pc_RLAST),
        .s_axi_rready(m00_data_fifo_to_auto_pc_RREADY),
        .s_axi_rresp(m00_data_fifo_to_auto_pc_RRESP),
        .s_axi_rvalid(m00_data_fifo_to_auto_pc_RVALID),
        .s_axi_wdata(m00_data_fifo_to_auto_pc_WDATA),
        .s_axi_wlast(m00_data_fifo_to_auto_pc_WLAST),
        .s_axi_wready(m00_data_fifo_to_auto_pc_WREADY),
        .s_axi_wstrb(m00_data_fifo_to_auto_pc_WSTRB),
        .s_axi_wvalid(m00_data_fifo_to_auto_pc_WVALID));
OpenSSD2_m00_data_fifo_0 m00_data_fifo
       (.aclk(S_ACLK_1),
        .aresetn(S_ARESETN_1),
        .m_axi_araddr(m00_data_fifo_to_auto_pc_ARADDR),
        .m_axi_arburst(m00_data_fifo_to_auto_pc_ARBURST),
        .m_axi_arcache(m00_data_fifo_to_auto_pc_ARCACHE),
        .m_axi_arid(m00_data_fifo_to_auto_pc_ARID),
        .m_axi_arlen(m00_data_fifo_to_auto_pc_ARLEN),
        .m_axi_arlock(m00_data_fifo_to_auto_pc_ARLOCK),
        .m_axi_arprot(m00_data_fifo_to_auto_pc_ARPROT),
        .m_axi_arqos(m00_data_fifo_to_auto_pc_ARQOS),
        .m_axi_arready(m00_data_fifo_to_auto_pc_ARREADY),
        .m_axi_arregion(m00_data_fifo_to_auto_pc_ARREGION),
        .m_axi_arsize(m00_data_fifo_to_auto_pc_ARSIZE),
        .m_axi_arvalid(m00_data_fifo_to_auto_pc_ARVALID),
        .m_axi_awaddr(m00_data_fifo_to_auto_pc_AWADDR),
        .m_axi_awburst(m00_data_fifo_to_auto_pc_AWBURST),
        .m_axi_awcache(m00_data_fifo_to_auto_pc_AWCACHE),
        .m_axi_awid(m00_data_fifo_to_auto_pc_AWID),
        .m_axi_awlen(m00_data_fifo_to_auto_pc_AWLEN),
        .m_axi_awlock(m00_data_fifo_to_auto_pc_AWLOCK),
        .m_axi_awprot(m00_data_fifo_to_auto_pc_AWPROT),
        .m_axi_awqos(m00_data_fifo_to_auto_pc_AWQOS),
        .m_axi_awready(m00_data_fifo_to_auto_pc_AWREADY),
        .m_axi_awregion(m00_data_fifo_to_auto_pc_AWREGION),
        .m_axi_awsize(m00_data_fifo_to_auto_pc_AWSIZE),
        .m_axi_awvalid(m00_data_fifo_to_auto_pc_AWVALID),
        .m_axi_bid(m00_data_fifo_to_auto_pc_BID),
        .m_axi_bready(m00_data_fifo_to_auto_pc_BREADY),
        .m_axi_bresp(m00_data_fifo_to_auto_pc_BRESP),
        .m_axi_bvalid(m00_data_fifo_to_auto_pc_BVALID),
        .m_axi_rdata(m00_data_fifo_to_auto_pc_RDATA),
        .m_axi_rid(m00_data_fifo_to_auto_pc_RID),
        .m_axi_rlast(m00_data_fifo_to_auto_pc_RLAST),
        .m_axi_rready(m00_data_fifo_to_auto_pc_RREADY),
        .m_axi_rresp(m00_data_fifo_to_auto_pc_RRESP),
        .m_axi_rvalid(m00_data_fifo_to_auto_pc_RVALID),
        .m_axi_wdata(m00_data_fifo_to_auto_pc_WDATA),
        .m_axi_wlast(m00_data_fifo_to_auto_pc_WLAST),
        .m_axi_wready(m00_data_fifo_to_auto_pc_WREADY),
        .m_axi_wstrb(m00_data_fifo_to_auto_pc_WSTRB),
        .m_axi_wvalid(m00_data_fifo_to_auto_pc_WVALID),
        .s_axi_araddr(m00_couplers_to_m00_data_fifo_ARADDR),
        .s_axi_arburst(m00_couplers_to_m00_data_fifo_ARBURST),
        .s_axi_arcache(m00_couplers_to_m00_data_fifo_ARCACHE),
        .s_axi_arid(m00_couplers_to_m00_data_fifo_ARID),
        .s_axi_arlen(m00_couplers_to_m00_data_fifo_ARLEN),
        .s_axi_arlock(m00_couplers_to_m00_data_fifo_ARLOCK),
        .s_axi_arprot(m00_couplers_to_m00_data_fifo_ARPROT),
        .s_axi_arqos(m00_couplers_to_m00_data_fifo_ARQOS),
        .s_axi_arready(m00_couplers_to_m00_data_fifo_ARREADY),
        .s_axi_arregion(m00_couplers_to_m00_data_fifo_ARREGION),
        .s_axi_arsize(m00_couplers_to_m00_data_fifo_ARSIZE),
        .s_axi_arvalid(m00_couplers_to_m00_data_fifo_ARVALID),
        .s_axi_awaddr(m00_couplers_to_m00_data_fifo_AWADDR),
        .s_axi_awburst(m00_couplers_to_m00_data_fifo_AWBURST),
        .s_axi_awcache(m00_couplers_to_m00_data_fifo_AWCACHE),
        .s_axi_awid(m00_couplers_to_m00_data_fifo_AWID),
        .s_axi_awlen(m00_couplers_to_m00_data_fifo_AWLEN),
        .s_axi_awlock(m00_couplers_to_m00_data_fifo_AWLOCK),
        .s_axi_awprot(m00_couplers_to_m00_data_fifo_AWPROT),
        .s_axi_awqos(m00_couplers_to_m00_data_fifo_AWQOS),
        .s_axi_awready(m00_couplers_to_m00_data_fifo_AWREADY),
        .s_axi_awregion(m00_couplers_to_m00_data_fifo_AWREGION),
        .s_axi_awsize(m00_couplers_to_m00_data_fifo_AWSIZE),
        .s_axi_awvalid(m00_couplers_to_m00_data_fifo_AWVALID),
        .s_axi_bid(m00_couplers_to_m00_data_fifo_BID),
        .s_axi_bready(m00_couplers_to_m00_data_fifo_BREADY),
        .s_axi_bresp(m00_couplers_to_m00_data_fifo_BRESP),
        .s_axi_bvalid(m00_couplers_to_m00_data_fifo_BVALID),
        .s_axi_rdata(m00_couplers_to_m00_data_fifo_RDATA),
        .s_axi_rid(m00_couplers_to_m00_data_fifo_RID),
        .s_axi_rlast(m00_couplers_to_m00_data_fifo_RLAST),
        .s_axi_rready(m00_couplers_to_m00_data_fifo_RREADY),
        .s_axi_rresp(m00_couplers_to_m00_data_fifo_RRESP),
        .s_axi_rvalid(m00_couplers_to_m00_data_fifo_RVALID),
        .s_axi_wdata(m00_couplers_to_m00_data_fifo_WDATA),
        .s_axi_wlast(m00_couplers_to_m00_data_fifo_WLAST),
        .s_axi_wready(m00_couplers_to_m00_data_fifo_WREADY),
        .s_axi_wstrb(m00_couplers_to_m00_data_fifo_WSTRB),
        .s_axi_wvalid(m00_couplers_to_m00_data_fifo_WVALID));
OpenSSD2_m00_regslice_0 m00_regslice
       (.aclk(M_ACLK_1),
        .aresetn(M_ARESETN_1),
        .m_axi_araddr(m00_regslice_to_m00_couplers_ARADDR),
        .m_axi_arburst(m00_regslice_to_m00_couplers_ARBURST),
        .m_axi_arcache(m00_regslice_to_m00_couplers_ARCACHE),
        .m_axi_arid(m00_regslice_to_m00_couplers_ARID),
        .m_axi_arlen(m00_regslice_to_m00_couplers_ARLEN),
        .m_axi_arlock(m00_regslice_to_m00_couplers_ARLOCK),
        .m_axi_arprot(m00_regslice_to_m00_couplers_ARPROT),
        .m_axi_arqos(m00_regslice_to_m00_couplers_ARQOS),
        .m_axi_arready(m00_regslice_to_m00_couplers_ARREADY),
        .m_axi_arsize(m00_regslice_to_m00_couplers_ARSIZE),
        .m_axi_arvalid(m00_regslice_to_m00_couplers_ARVALID),
        .m_axi_awaddr(m00_regslice_to_m00_couplers_AWADDR),
        .m_axi_awburst(m00_regslice_to_m00_couplers_AWBURST),
        .m_axi_awcache(m00_regslice_to_m00_couplers_AWCACHE),
        .m_axi_awid(m00_regslice_to_m00_couplers_AWID),
        .m_axi_awlen(m00_regslice_to_m00_couplers_AWLEN),
        .m_axi_awlock(m00_regslice_to_m00_couplers_AWLOCK),
        .m_axi_awprot(m00_regslice_to_m00_couplers_AWPROT),
        .m_axi_awqos(m00_regslice_to_m00_couplers_AWQOS),
        .m_axi_awready(m00_regslice_to_m00_couplers_AWREADY),
        .m_axi_awsize(m00_regslice_to_m00_couplers_AWSIZE),
        .m_axi_awvalid(m00_regslice_to_m00_couplers_AWVALID),
        .m_axi_bid(m00_regslice_to_m00_couplers_BID),
        .m_axi_bready(m00_regslice_to_m00_couplers_BREADY),
        .m_axi_bresp(m00_regslice_to_m00_couplers_BRESP),
        .m_axi_bvalid(m00_regslice_to_m00_couplers_BVALID),
        .m_axi_rdata(m00_regslice_to_m00_couplers_RDATA),
        .m_axi_rid(m00_regslice_to_m00_couplers_RID),
        .m_axi_rlast(m00_regslice_to_m00_couplers_RLAST),
        .m_axi_rready(m00_regslice_to_m00_couplers_RREADY),
        .m_axi_rresp(m00_regslice_to_m00_couplers_RRESP),
        .m_axi_rvalid(m00_regslice_to_m00_couplers_RVALID),
        .m_axi_wdata(m00_regslice_to_m00_couplers_WDATA),
        .m_axi_wid(m00_regslice_to_m00_couplers_WID),
        .m_axi_wlast(m00_regslice_to_m00_couplers_WLAST),
        .m_axi_wready(m00_regslice_to_m00_couplers_WREADY),
        .m_axi_wstrb(m00_regslice_to_m00_couplers_WSTRB),
        .m_axi_wvalid(m00_regslice_to_m00_couplers_WVALID),
        .s_axi_araddr(auto_pc_to_m00_regslice_ARADDR),
        .s_axi_arburst(auto_pc_to_m00_regslice_ARBURST),
        .s_axi_arcache(auto_pc_to_m00_regslice_ARCACHE),
        .s_axi_arid(auto_pc_to_m00_regslice_ARID),
        .s_axi_arlen(auto_pc_to_m00_regslice_ARLEN),
        .s_axi_arlock(auto_pc_to_m00_regslice_ARLOCK),
        .s_axi_arprot(auto_pc_to_m00_regslice_ARPROT),
        .s_axi_arqos(auto_pc_to_m00_regslice_ARQOS),
        .s_axi_arready(auto_pc_to_m00_regslice_ARREADY),
        .s_axi_arsize(auto_pc_to_m00_regslice_ARSIZE),
        .s_axi_arvalid(auto_pc_to_m00_regslice_ARVALID),
        .s_axi_awaddr(auto_pc_to_m00_regslice_AWADDR),
        .s_axi_awburst(auto_pc_to_m00_regslice_AWBURST),
        .s_axi_awcache(auto_pc_to_m00_regslice_AWCACHE),
        .s_axi_awid(auto_pc_to_m00_regslice_AWID),
        .s_axi_awlen(auto_pc_to_m00_regslice_AWLEN),
        .s_axi_awlock(auto_pc_to_m00_regslice_AWLOCK),
        .s_axi_awprot(auto_pc_to_m00_regslice_AWPROT),
        .s_axi_awqos(auto_pc_to_m00_regslice_AWQOS),
        .s_axi_awready(auto_pc_to_m00_regslice_AWREADY),
        .s_axi_awsize(auto_pc_to_m00_regslice_AWSIZE),
        .s_axi_awvalid(auto_pc_to_m00_regslice_AWVALID),
        .s_axi_bid(auto_pc_to_m00_regslice_BID),
        .s_axi_bready(auto_pc_to_m00_regslice_BREADY),
        .s_axi_bresp(auto_pc_to_m00_regslice_BRESP),
        .s_axi_bvalid(auto_pc_to_m00_regslice_BVALID),
        .s_axi_rdata(auto_pc_to_m00_regslice_RDATA),
        .s_axi_rid(auto_pc_to_m00_regslice_RID),
        .s_axi_rlast(auto_pc_to_m00_regslice_RLAST),
        .s_axi_rready(auto_pc_to_m00_regslice_RREADY),
        .s_axi_rresp(auto_pc_to_m00_regslice_RRESP),
        .s_axi_rvalid(auto_pc_to_m00_regslice_RVALID),
        .s_axi_wdata(auto_pc_to_m00_regslice_WDATA),
        .s_axi_wid(auto_pc_to_m00_regslice_WID),
        .s_axi_wlast(auto_pc_to_m00_regslice_WLAST),
        .s_axi_wready(auto_pc_to_m00_regslice_WREADY),
        .s_axi_wstrb(auto_pc_to_m00_regslice_WSTRB),
        .s_axi_wvalid(auto_pc_to_m00_regslice_WVALID));
endmodule

module m01_couplers_imp_S1U0SJ
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arprot,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awprot,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arprot,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awprot,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input [0:0]M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [2:0]M_AXI_arprot;
  input M_AXI_arready;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [2:0]M_AXI_awprot;
  input M_AXI_awready;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input [0:0]S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [2:0]S_AXI_arprot;
  output S_AXI_arready;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [2:0]S_AXI_awprot;
  output S_AXI_awready;
  input S_AXI_awvalid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  output S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire [31:0]m01_couplers_to_m01_couplers_ARADDR;
  wire [2:0]m01_couplers_to_m01_couplers_ARPROT;
  wire m01_couplers_to_m01_couplers_ARREADY;
  wire m01_couplers_to_m01_couplers_ARVALID;
  wire [31:0]m01_couplers_to_m01_couplers_AWADDR;
  wire [2:0]m01_couplers_to_m01_couplers_AWPROT;
  wire m01_couplers_to_m01_couplers_AWREADY;
  wire m01_couplers_to_m01_couplers_AWVALID;
  wire m01_couplers_to_m01_couplers_BREADY;
  wire [1:0]m01_couplers_to_m01_couplers_BRESP;
  wire m01_couplers_to_m01_couplers_BVALID;
  wire [31:0]m01_couplers_to_m01_couplers_RDATA;
  wire m01_couplers_to_m01_couplers_RREADY;
  wire [1:0]m01_couplers_to_m01_couplers_RRESP;
  wire m01_couplers_to_m01_couplers_RVALID;
  wire [31:0]m01_couplers_to_m01_couplers_WDATA;
  wire m01_couplers_to_m01_couplers_WREADY;
  wire [3:0]m01_couplers_to_m01_couplers_WSTRB;
  wire m01_couplers_to_m01_couplers_WVALID;

  assign M_AXI_araddr[31:0] = m01_couplers_to_m01_couplers_ARADDR;
  assign M_AXI_arprot[2:0] = m01_couplers_to_m01_couplers_ARPROT;
  assign M_AXI_arvalid = m01_couplers_to_m01_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = m01_couplers_to_m01_couplers_AWADDR;
  assign M_AXI_awprot[2:0] = m01_couplers_to_m01_couplers_AWPROT;
  assign M_AXI_awvalid = m01_couplers_to_m01_couplers_AWVALID;
  assign M_AXI_bready = m01_couplers_to_m01_couplers_BREADY;
  assign M_AXI_rready = m01_couplers_to_m01_couplers_RREADY;
  assign M_AXI_wdata[31:0] = m01_couplers_to_m01_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = m01_couplers_to_m01_couplers_WSTRB;
  assign M_AXI_wvalid = m01_couplers_to_m01_couplers_WVALID;
  assign S_AXI_arready = m01_couplers_to_m01_couplers_ARREADY;
  assign S_AXI_awready = m01_couplers_to_m01_couplers_AWREADY;
  assign S_AXI_bresp[1:0] = m01_couplers_to_m01_couplers_BRESP;
  assign S_AXI_bvalid = m01_couplers_to_m01_couplers_BVALID;
  assign S_AXI_rdata[31:0] = m01_couplers_to_m01_couplers_RDATA;
  assign S_AXI_rresp[1:0] = m01_couplers_to_m01_couplers_RRESP;
  assign S_AXI_rvalid = m01_couplers_to_m01_couplers_RVALID;
  assign S_AXI_wready = m01_couplers_to_m01_couplers_WREADY;
  assign m01_couplers_to_m01_couplers_ARADDR = S_AXI_araddr[31:0];
  assign m01_couplers_to_m01_couplers_ARPROT = S_AXI_arprot[2:0];
  assign m01_couplers_to_m01_couplers_ARREADY = M_AXI_arready;
  assign m01_couplers_to_m01_couplers_ARVALID = S_AXI_arvalid;
  assign m01_couplers_to_m01_couplers_AWADDR = S_AXI_awaddr[31:0];
  assign m01_couplers_to_m01_couplers_AWPROT = S_AXI_awprot[2:0];
  assign m01_couplers_to_m01_couplers_AWREADY = M_AXI_awready;
  assign m01_couplers_to_m01_couplers_AWVALID = S_AXI_awvalid;
  assign m01_couplers_to_m01_couplers_BREADY = S_AXI_bready;
  assign m01_couplers_to_m01_couplers_BRESP = M_AXI_bresp[1:0];
  assign m01_couplers_to_m01_couplers_BVALID = M_AXI_bvalid;
  assign m01_couplers_to_m01_couplers_RDATA = M_AXI_rdata[31:0];
  assign m01_couplers_to_m01_couplers_RREADY = S_AXI_rready;
  assign m01_couplers_to_m01_couplers_RRESP = M_AXI_rresp[1:0];
  assign m01_couplers_to_m01_couplers_RVALID = M_AXI_rvalid;
  assign m01_couplers_to_m01_couplers_WDATA = S_AXI_wdata[31:0];
  assign m01_couplers_to_m01_couplers_WREADY = M_AXI_wready;
  assign m01_couplers_to_m01_couplers_WSTRB = S_AXI_wstrb[3:0];
  assign m01_couplers_to_m01_couplers_WVALID = S_AXI_wvalid;
endmodule

module s00_couplers_imp_1I0LFG6
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arburst,
    M_AXI_arcache,
    M_AXI_arlen,
    M_AXI_arlock,
    M_AXI_arprot,
    M_AXI_arqos,
    M_AXI_arready,
    M_AXI_arsize,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awburst,
    M_AXI_awcache,
    M_AXI_awlen,
    M_AXI_awlock,
    M_AXI_awprot,
    M_AXI_awqos,
    M_AXI_awready,
    M_AXI_awsize,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rlast,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wlast,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arburst,
    S_AXI_arcache,
    S_AXI_arlen,
    S_AXI_arprot,
    S_AXI_arready,
    S_AXI_arsize,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awburst,
    S_AXI_awcache,
    S_AXI_awlen,
    S_AXI_awprot,
    S_AXI_awready,
    S_AXI_awsize,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rlast,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wlast,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input [0:0]M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [1:0]M_AXI_arburst;
  output [3:0]M_AXI_arcache;
  output [7:0]M_AXI_arlen;
  output [0:0]M_AXI_arlock;
  output [2:0]M_AXI_arprot;
  output [3:0]M_AXI_arqos;
  input M_AXI_arready;
  output [2:0]M_AXI_arsize;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [1:0]M_AXI_awburst;
  output [3:0]M_AXI_awcache;
  output [7:0]M_AXI_awlen;
  output [0:0]M_AXI_awlock;
  output [2:0]M_AXI_awprot;
  output [3:0]M_AXI_awqos;
  input M_AXI_awready;
  output [2:0]M_AXI_awsize;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [63:0]M_AXI_rdata;
  input M_AXI_rlast;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [63:0]M_AXI_wdata;
  output M_AXI_wlast;
  input M_AXI_wready;
  output [7:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input [0:0]S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [1:0]S_AXI_arburst;
  input [3:0]S_AXI_arcache;
  input [7:0]S_AXI_arlen;
  input [2:0]S_AXI_arprot;
  output S_AXI_arready;
  input [2:0]S_AXI_arsize;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [1:0]S_AXI_awburst;
  input [3:0]S_AXI_awcache;
  input [7:0]S_AXI_awlen;
  input [2:0]S_AXI_awprot;
  output S_AXI_awready;
  input [2:0]S_AXI_awsize;
  input S_AXI_awvalid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  output S_AXI_rlast;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  input S_AXI_wlast;
  output S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire GND_1;
  wire M_ACLK_1;
  wire [0:0]M_ARESETN_1;
  wire S_ACLK_1;
  wire [0:0]S_ARESETN_1;
  wire [31:0]auto_us_cc_df_to_s00_couplers_ARADDR;
  wire [1:0]auto_us_cc_df_to_s00_couplers_ARBURST;
  wire [3:0]auto_us_cc_df_to_s00_couplers_ARCACHE;
  wire [7:0]auto_us_cc_df_to_s00_couplers_ARLEN;
  wire [0:0]auto_us_cc_df_to_s00_couplers_ARLOCK;
  wire [2:0]auto_us_cc_df_to_s00_couplers_ARPROT;
  wire [3:0]auto_us_cc_df_to_s00_couplers_ARQOS;
  wire auto_us_cc_df_to_s00_couplers_ARREADY;
  wire [2:0]auto_us_cc_df_to_s00_couplers_ARSIZE;
  wire auto_us_cc_df_to_s00_couplers_ARVALID;
  wire [31:0]auto_us_cc_df_to_s00_couplers_AWADDR;
  wire [1:0]auto_us_cc_df_to_s00_couplers_AWBURST;
  wire [3:0]auto_us_cc_df_to_s00_couplers_AWCACHE;
  wire [7:0]auto_us_cc_df_to_s00_couplers_AWLEN;
  wire [0:0]auto_us_cc_df_to_s00_couplers_AWLOCK;
  wire [2:0]auto_us_cc_df_to_s00_couplers_AWPROT;
  wire [3:0]auto_us_cc_df_to_s00_couplers_AWQOS;
  wire auto_us_cc_df_to_s00_couplers_AWREADY;
  wire [2:0]auto_us_cc_df_to_s00_couplers_AWSIZE;
  wire auto_us_cc_df_to_s00_couplers_AWVALID;
  wire auto_us_cc_df_to_s00_couplers_BREADY;
  wire [1:0]auto_us_cc_df_to_s00_couplers_BRESP;
  wire auto_us_cc_df_to_s00_couplers_BVALID;
  wire [63:0]auto_us_cc_df_to_s00_couplers_RDATA;
  wire auto_us_cc_df_to_s00_couplers_RLAST;
  wire auto_us_cc_df_to_s00_couplers_RREADY;
  wire [1:0]auto_us_cc_df_to_s00_couplers_RRESP;
  wire auto_us_cc_df_to_s00_couplers_RVALID;
  wire [63:0]auto_us_cc_df_to_s00_couplers_WDATA;
  wire auto_us_cc_df_to_s00_couplers_WLAST;
  wire auto_us_cc_df_to_s00_couplers_WREADY;
  wire [7:0]auto_us_cc_df_to_s00_couplers_WSTRB;
  wire auto_us_cc_df_to_s00_couplers_WVALID;
  wire [31:0]s00_couplers_to_s00_regslice_ARADDR;
  wire [1:0]s00_couplers_to_s00_regslice_ARBURST;
  wire [3:0]s00_couplers_to_s00_regslice_ARCACHE;
  wire [7:0]s00_couplers_to_s00_regslice_ARLEN;
  wire [2:0]s00_couplers_to_s00_regslice_ARPROT;
  wire s00_couplers_to_s00_regslice_ARREADY;
  wire [2:0]s00_couplers_to_s00_regslice_ARSIZE;
  wire s00_couplers_to_s00_regslice_ARVALID;
  wire [31:0]s00_couplers_to_s00_regslice_AWADDR;
  wire [1:0]s00_couplers_to_s00_regslice_AWBURST;
  wire [3:0]s00_couplers_to_s00_regslice_AWCACHE;
  wire [7:0]s00_couplers_to_s00_regslice_AWLEN;
  wire [2:0]s00_couplers_to_s00_regslice_AWPROT;
  wire s00_couplers_to_s00_regslice_AWREADY;
  wire [2:0]s00_couplers_to_s00_regslice_AWSIZE;
  wire s00_couplers_to_s00_regslice_AWVALID;
  wire s00_couplers_to_s00_regslice_BREADY;
  wire [1:0]s00_couplers_to_s00_regslice_BRESP;
  wire s00_couplers_to_s00_regslice_BVALID;
  wire [31:0]s00_couplers_to_s00_regslice_RDATA;
  wire s00_couplers_to_s00_regslice_RLAST;
  wire s00_couplers_to_s00_regslice_RREADY;
  wire [1:0]s00_couplers_to_s00_regslice_RRESP;
  wire s00_couplers_to_s00_regslice_RVALID;
  wire [31:0]s00_couplers_to_s00_regslice_WDATA;
  wire s00_couplers_to_s00_regslice_WLAST;
  wire s00_couplers_to_s00_regslice_WREADY;
  wire [3:0]s00_couplers_to_s00_regslice_WSTRB;
  wire s00_couplers_to_s00_regslice_WVALID;
  wire [31:0]s00_regslice_to_auto_us_cc_df_ARADDR;
  wire [1:0]s00_regslice_to_auto_us_cc_df_ARBURST;
  wire [3:0]s00_regslice_to_auto_us_cc_df_ARCACHE;
  wire [7:0]s00_regslice_to_auto_us_cc_df_ARLEN;
  wire [0:0]s00_regslice_to_auto_us_cc_df_ARLOCK;
  wire [2:0]s00_regslice_to_auto_us_cc_df_ARPROT;
  wire [3:0]s00_regslice_to_auto_us_cc_df_ARQOS;
  wire s00_regslice_to_auto_us_cc_df_ARREADY;
  wire [3:0]s00_regslice_to_auto_us_cc_df_ARREGION;
  wire [2:0]s00_regslice_to_auto_us_cc_df_ARSIZE;
  wire s00_regslice_to_auto_us_cc_df_ARVALID;
  wire [31:0]s00_regslice_to_auto_us_cc_df_AWADDR;
  wire [1:0]s00_regslice_to_auto_us_cc_df_AWBURST;
  wire [3:0]s00_regslice_to_auto_us_cc_df_AWCACHE;
  wire [7:0]s00_regslice_to_auto_us_cc_df_AWLEN;
  wire [0:0]s00_regslice_to_auto_us_cc_df_AWLOCK;
  wire [2:0]s00_regslice_to_auto_us_cc_df_AWPROT;
  wire [3:0]s00_regslice_to_auto_us_cc_df_AWQOS;
  wire s00_regslice_to_auto_us_cc_df_AWREADY;
  wire [3:0]s00_regslice_to_auto_us_cc_df_AWREGION;
  wire [2:0]s00_regslice_to_auto_us_cc_df_AWSIZE;
  wire s00_regslice_to_auto_us_cc_df_AWVALID;
  wire s00_regslice_to_auto_us_cc_df_BREADY;
  wire [1:0]s00_regslice_to_auto_us_cc_df_BRESP;
  wire s00_regslice_to_auto_us_cc_df_BVALID;
  wire [31:0]s00_regslice_to_auto_us_cc_df_RDATA;
  wire s00_regslice_to_auto_us_cc_df_RLAST;
  wire s00_regslice_to_auto_us_cc_df_RREADY;
  wire [1:0]s00_regslice_to_auto_us_cc_df_RRESP;
  wire s00_regslice_to_auto_us_cc_df_RVALID;
  wire [31:0]s00_regslice_to_auto_us_cc_df_WDATA;
  wire s00_regslice_to_auto_us_cc_df_WLAST;
  wire s00_regslice_to_auto_us_cc_df_WREADY;
  wire [3:0]s00_regslice_to_auto_us_cc_df_WSTRB;
  wire s00_regslice_to_auto_us_cc_df_WVALID;

  assign M_ACLK_1 = M_ACLK;
  assign M_ARESETN_1 = M_ARESETN[0];
  assign M_AXI_araddr[31:0] = auto_us_cc_df_to_s00_couplers_ARADDR;
  assign M_AXI_arburst[1:0] = auto_us_cc_df_to_s00_couplers_ARBURST;
  assign M_AXI_arcache[3:0] = auto_us_cc_df_to_s00_couplers_ARCACHE;
  assign M_AXI_arlen[7:0] = auto_us_cc_df_to_s00_couplers_ARLEN;
  assign M_AXI_arlock[0] = auto_us_cc_df_to_s00_couplers_ARLOCK;
  assign M_AXI_arprot[2:0] = auto_us_cc_df_to_s00_couplers_ARPROT;
  assign M_AXI_arqos[3:0] = auto_us_cc_df_to_s00_couplers_ARQOS;
  assign M_AXI_arsize[2:0] = auto_us_cc_df_to_s00_couplers_ARSIZE;
  assign M_AXI_arvalid = auto_us_cc_df_to_s00_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = auto_us_cc_df_to_s00_couplers_AWADDR;
  assign M_AXI_awburst[1:0] = auto_us_cc_df_to_s00_couplers_AWBURST;
  assign M_AXI_awcache[3:0] = auto_us_cc_df_to_s00_couplers_AWCACHE;
  assign M_AXI_awlen[7:0] = auto_us_cc_df_to_s00_couplers_AWLEN;
  assign M_AXI_awlock[0] = auto_us_cc_df_to_s00_couplers_AWLOCK;
  assign M_AXI_awprot[2:0] = auto_us_cc_df_to_s00_couplers_AWPROT;
  assign M_AXI_awqos[3:0] = auto_us_cc_df_to_s00_couplers_AWQOS;
  assign M_AXI_awsize[2:0] = auto_us_cc_df_to_s00_couplers_AWSIZE;
  assign M_AXI_awvalid = auto_us_cc_df_to_s00_couplers_AWVALID;
  assign M_AXI_bready = auto_us_cc_df_to_s00_couplers_BREADY;
  assign M_AXI_rready = auto_us_cc_df_to_s00_couplers_RREADY;
  assign M_AXI_wdata[63:0] = auto_us_cc_df_to_s00_couplers_WDATA;
  assign M_AXI_wlast = auto_us_cc_df_to_s00_couplers_WLAST;
  assign M_AXI_wstrb[7:0] = auto_us_cc_df_to_s00_couplers_WSTRB;
  assign M_AXI_wvalid = auto_us_cc_df_to_s00_couplers_WVALID;
  assign S_ACLK_1 = S_ACLK;
  assign S_ARESETN_1 = S_ARESETN[0];
  assign S_AXI_arready = s00_couplers_to_s00_regslice_ARREADY;
  assign S_AXI_awready = s00_couplers_to_s00_regslice_AWREADY;
  assign S_AXI_bresp[1:0] = s00_couplers_to_s00_regslice_BRESP;
  assign S_AXI_bvalid = s00_couplers_to_s00_regslice_BVALID;
  assign S_AXI_rdata[31:0] = s00_couplers_to_s00_regslice_RDATA;
  assign S_AXI_rlast = s00_couplers_to_s00_regslice_RLAST;
  assign S_AXI_rresp[1:0] = s00_couplers_to_s00_regslice_RRESP;
  assign S_AXI_rvalid = s00_couplers_to_s00_regslice_RVALID;
  assign S_AXI_wready = s00_couplers_to_s00_regslice_WREADY;
  assign auto_us_cc_df_to_s00_couplers_ARREADY = M_AXI_arready;
  assign auto_us_cc_df_to_s00_couplers_AWREADY = M_AXI_awready;
  assign auto_us_cc_df_to_s00_couplers_BRESP = M_AXI_bresp[1:0];
  assign auto_us_cc_df_to_s00_couplers_BVALID = M_AXI_bvalid;
  assign auto_us_cc_df_to_s00_couplers_RDATA = M_AXI_rdata[63:0];
  assign auto_us_cc_df_to_s00_couplers_RLAST = M_AXI_rlast;
  assign auto_us_cc_df_to_s00_couplers_RRESP = M_AXI_rresp[1:0];
  assign auto_us_cc_df_to_s00_couplers_RVALID = M_AXI_rvalid;
  assign auto_us_cc_df_to_s00_couplers_WREADY = M_AXI_wready;
  assign s00_couplers_to_s00_regslice_ARADDR = S_AXI_araddr[31:0];
  assign s00_couplers_to_s00_regslice_ARBURST = S_AXI_arburst[1:0];
  assign s00_couplers_to_s00_regslice_ARCACHE = S_AXI_arcache[3:0];
  assign s00_couplers_to_s00_regslice_ARLEN = S_AXI_arlen[7:0];
  assign s00_couplers_to_s00_regslice_ARPROT = S_AXI_arprot[2:0];
  assign s00_couplers_to_s00_regslice_ARSIZE = S_AXI_arsize[2:0];
  assign s00_couplers_to_s00_regslice_ARVALID = S_AXI_arvalid;
  assign s00_couplers_to_s00_regslice_AWADDR = S_AXI_awaddr[31:0];
  assign s00_couplers_to_s00_regslice_AWBURST = S_AXI_awburst[1:0];
  assign s00_couplers_to_s00_regslice_AWCACHE = S_AXI_awcache[3:0];
  assign s00_couplers_to_s00_regslice_AWLEN = S_AXI_awlen[7:0];
  assign s00_couplers_to_s00_regslice_AWPROT = S_AXI_awprot[2:0];
  assign s00_couplers_to_s00_regslice_AWSIZE = S_AXI_awsize[2:0];
  assign s00_couplers_to_s00_regslice_AWVALID = S_AXI_awvalid;
  assign s00_couplers_to_s00_regslice_BREADY = S_AXI_bready;
  assign s00_couplers_to_s00_regslice_RREADY = S_AXI_rready;
  assign s00_couplers_to_s00_regslice_WDATA = S_AXI_wdata[31:0];
  assign s00_couplers_to_s00_regslice_WLAST = S_AXI_wlast;
  assign s00_couplers_to_s00_regslice_WSTRB = S_AXI_wstrb[3:0];
  assign s00_couplers_to_s00_regslice_WVALID = S_AXI_wvalid;
GND GND
       (.G(GND_1));
OpenSSD2_auto_us_cc_df_0 auto_us_cc_df
       (.m_axi_aclk(M_ACLK_1),
        .m_axi_araddr(auto_us_cc_df_to_s00_couplers_ARADDR),
        .m_axi_arburst(auto_us_cc_df_to_s00_couplers_ARBURST),
        .m_axi_arcache(auto_us_cc_df_to_s00_couplers_ARCACHE),
        .m_axi_aresetn(M_ARESETN_1),
        .m_axi_arlen(auto_us_cc_df_to_s00_couplers_ARLEN),
        .m_axi_arlock(auto_us_cc_df_to_s00_couplers_ARLOCK),
        .m_axi_arprot(auto_us_cc_df_to_s00_couplers_ARPROT),
        .m_axi_arqos(auto_us_cc_df_to_s00_couplers_ARQOS),
        .m_axi_arready(auto_us_cc_df_to_s00_couplers_ARREADY),
        .m_axi_arsize(auto_us_cc_df_to_s00_couplers_ARSIZE),
        .m_axi_arvalid(auto_us_cc_df_to_s00_couplers_ARVALID),
        .m_axi_awaddr(auto_us_cc_df_to_s00_couplers_AWADDR),
        .m_axi_awburst(auto_us_cc_df_to_s00_couplers_AWBURST),
        .m_axi_awcache(auto_us_cc_df_to_s00_couplers_AWCACHE),
        .m_axi_awlen(auto_us_cc_df_to_s00_couplers_AWLEN),
        .m_axi_awlock(auto_us_cc_df_to_s00_couplers_AWLOCK),
        .m_axi_awprot(auto_us_cc_df_to_s00_couplers_AWPROT),
        .m_axi_awqos(auto_us_cc_df_to_s00_couplers_AWQOS),
        .m_axi_awready(auto_us_cc_df_to_s00_couplers_AWREADY),
        .m_axi_awsize(auto_us_cc_df_to_s00_couplers_AWSIZE),
        .m_axi_awvalid(auto_us_cc_df_to_s00_couplers_AWVALID),
        .m_axi_bready(auto_us_cc_df_to_s00_couplers_BREADY),
        .m_axi_bresp(auto_us_cc_df_to_s00_couplers_BRESP),
        .m_axi_bvalid(auto_us_cc_df_to_s00_couplers_BVALID),
        .m_axi_rdata(auto_us_cc_df_to_s00_couplers_RDATA),
        .m_axi_rlast(auto_us_cc_df_to_s00_couplers_RLAST),
        .m_axi_rready(auto_us_cc_df_to_s00_couplers_RREADY),
        .m_axi_rresp(auto_us_cc_df_to_s00_couplers_RRESP),
        .m_axi_rvalid(auto_us_cc_df_to_s00_couplers_RVALID),
        .m_axi_wdata(auto_us_cc_df_to_s00_couplers_WDATA),
        .m_axi_wlast(auto_us_cc_df_to_s00_couplers_WLAST),
        .m_axi_wready(auto_us_cc_df_to_s00_couplers_WREADY),
        .m_axi_wstrb(auto_us_cc_df_to_s00_couplers_WSTRB),
        .m_axi_wvalid(auto_us_cc_df_to_s00_couplers_WVALID),
        .s_axi_aclk(S_ACLK_1),
        .s_axi_araddr(s00_regslice_to_auto_us_cc_df_ARADDR),
        .s_axi_arburst(s00_regslice_to_auto_us_cc_df_ARBURST),
        .s_axi_arcache(s00_regslice_to_auto_us_cc_df_ARCACHE),
        .s_axi_aresetn(S_ARESETN_1),
        .s_axi_arlen(s00_regslice_to_auto_us_cc_df_ARLEN),
        .s_axi_arlock(s00_regslice_to_auto_us_cc_df_ARLOCK),
        .s_axi_arprot(s00_regslice_to_auto_us_cc_df_ARPROT),
        .s_axi_arqos(s00_regslice_to_auto_us_cc_df_ARQOS),
        .s_axi_arready(s00_regslice_to_auto_us_cc_df_ARREADY),
        .s_axi_arregion(s00_regslice_to_auto_us_cc_df_ARREGION),
        .s_axi_arsize(s00_regslice_to_auto_us_cc_df_ARSIZE),
        .s_axi_arvalid(s00_regslice_to_auto_us_cc_df_ARVALID),
        .s_axi_awaddr(s00_regslice_to_auto_us_cc_df_AWADDR),
        .s_axi_awburst(s00_regslice_to_auto_us_cc_df_AWBURST),
        .s_axi_awcache(s00_regslice_to_auto_us_cc_df_AWCACHE),
        .s_axi_awlen(s00_regslice_to_auto_us_cc_df_AWLEN),
        .s_axi_awlock(s00_regslice_to_auto_us_cc_df_AWLOCK),
        .s_axi_awprot(s00_regslice_to_auto_us_cc_df_AWPROT),
        .s_axi_awqos(s00_regslice_to_auto_us_cc_df_AWQOS),
        .s_axi_awready(s00_regslice_to_auto_us_cc_df_AWREADY),
        .s_axi_awregion(s00_regslice_to_auto_us_cc_df_AWREGION),
        .s_axi_awsize(s00_regslice_to_auto_us_cc_df_AWSIZE),
        .s_axi_awvalid(s00_regslice_to_auto_us_cc_df_AWVALID),
        .s_axi_bready(s00_regslice_to_auto_us_cc_df_BREADY),
        .s_axi_bresp(s00_regslice_to_auto_us_cc_df_BRESP),
        .s_axi_bvalid(s00_regslice_to_auto_us_cc_df_BVALID),
        .s_axi_rdata(s00_regslice_to_auto_us_cc_df_RDATA),
        .s_axi_rlast(s00_regslice_to_auto_us_cc_df_RLAST),
        .s_axi_rready(s00_regslice_to_auto_us_cc_df_RREADY),
        .s_axi_rresp(s00_regslice_to_auto_us_cc_df_RRESP),
        .s_axi_rvalid(s00_regslice_to_auto_us_cc_df_RVALID),
        .s_axi_wdata(s00_regslice_to_auto_us_cc_df_WDATA),
        .s_axi_wlast(s00_regslice_to_auto_us_cc_df_WLAST),
        .s_axi_wready(s00_regslice_to_auto_us_cc_df_WREADY),
        .s_axi_wstrb(s00_regslice_to_auto_us_cc_df_WSTRB),
        .s_axi_wvalid(s00_regslice_to_auto_us_cc_df_WVALID));
OpenSSD2_s00_regslice_0 s00_regslice
       (.aclk(S_ACLK_1),
        .aresetn(S_ARESETN_1),
        .m_axi_araddr(s00_regslice_to_auto_us_cc_df_ARADDR),
        .m_axi_arburst(s00_regslice_to_auto_us_cc_df_ARBURST),
        .m_axi_arcache(s00_regslice_to_auto_us_cc_df_ARCACHE),
        .m_axi_arlen(s00_regslice_to_auto_us_cc_df_ARLEN),
        .m_axi_arlock(s00_regslice_to_auto_us_cc_df_ARLOCK),
        .m_axi_arprot(s00_regslice_to_auto_us_cc_df_ARPROT),
        .m_axi_arqos(s00_regslice_to_auto_us_cc_df_ARQOS),
        .m_axi_arready(s00_regslice_to_auto_us_cc_df_ARREADY),
        .m_axi_arregion(s00_regslice_to_auto_us_cc_df_ARREGION),
        .m_axi_arsize(s00_regslice_to_auto_us_cc_df_ARSIZE),
        .m_axi_arvalid(s00_regslice_to_auto_us_cc_df_ARVALID),
        .m_axi_awaddr(s00_regslice_to_auto_us_cc_df_AWADDR),
        .m_axi_awburst(s00_regslice_to_auto_us_cc_df_AWBURST),
        .m_axi_awcache(s00_regslice_to_auto_us_cc_df_AWCACHE),
        .m_axi_awlen(s00_regslice_to_auto_us_cc_df_AWLEN),
        .m_axi_awlock(s00_regslice_to_auto_us_cc_df_AWLOCK),
        .m_axi_awprot(s00_regslice_to_auto_us_cc_df_AWPROT),
        .m_axi_awqos(s00_regslice_to_auto_us_cc_df_AWQOS),
        .m_axi_awready(s00_regslice_to_auto_us_cc_df_AWREADY),
        .m_axi_awregion(s00_regslice_to_auto_us_cc_df_AWREGION),
        .m_axi_awsize(s00_regslice_to_auto_us_cc_df_AWSIZE),
        .m_axi_awvalid(s00_regslice_to_auto_us_cc_df_AWVALID),
        .m_axi_bready(s00_regslice_to_auto_us_cc_df_BREADY),
        .m_axi_bresp(s00_regslice_to_auto_us_cc_df_BRESP),
        .m_axi_bvalid(s00_regslice_to_auto_us_cc_df_BVALID),
        .m_axi_rdata(s00_regslice_to_auto_us_cc_df_RDATA),
        .m_axi_rlast(s00_regslice_to_auto_us_cc_df_RLAST),
        .m_axi_rready(s00_regslice_to_auto_us_cc_df_RREADY),
        .m_axi_rresp(s00_regslice_to_auto_us_cc_df_RRESP),
        .m_axi_rvalid(s00_regslice_to_auto_us_cc_df_RVALID),
        .m_axi_wdata(s00_regslice_to_auto_us_cc_df_WDATA),
        .m_axi_wlast(s00_regslice_to_auto_us_cc_df_WLAST),
        .m_axi_wready(s00_regslice_to_auto_us_cc_df_WREADY),
        .m_axi_wstrb(s00_regslice_to_auto_us_cc_df_WSTRB),
        .m_axi_wvalid(s00_regslice_to_auto_us_cc_df_WVALID),
        .s_axi_araddr(s00_couplers_to_s00_regslice_ARADDR),
        .s_axi_arburst(s00_couplers_to_s00_regslice_ARBURST),
        .s_axi_arcache(s00_couplers_to_s00_regslice_ARCACHE),
        .s_axi_arlen(s00_couplers_to_s00_regslice_ARLEN),
        .s_axi_arlock(GND_1),
        .s_axi_arprot(s00_couplers_to_s00_regslice_ARPROT),
        .s_axi_arqos({GND_1,GND_1,GND_1,GND_1}),
        .s_axi_arready(s00_couplers_to_s00_regslice_ARREADY),
        .s_axi_arregion({GND_1,GND_1,GND_1,GND_1}),
        .s_axi_arsize(s00_couplers_to_s00_regslice_ARSIZE),
        .s_axi_arvalid(s00_couplers_to_s00_regslice_ARVALID),
        .s_axi_awaddr(s00_couplers_to_s00_regslice_AWADDR),
        .s_axi_awburst(s00_couplers_to_s00_regslice_AWBURST),
        .s_axi_awcache(s00_couplers_to_s00_regslice_AWCACHE),
        .s_axi_awlen(s00_couplers_to_s00_regslice_AWLEN),
        .s_axi_awlock(GND_1),
        .s_axi_awprot(s00_couplers_to_s00_regslice_AWPROT),
        .s_axi_awqos({GND_1,GND_1,GND_1,GND_1}),
        .s_axi_awready(s00_couplers_to_s00_regslice_AWREADY),
        .s_axi_awregion({GND_1,GND_1,GND_1,GND_1}),
        .s_axi_awsize(s00_couplers_to_s00_regslice_AWSIZE),
        .s_axi_awvalid(s00_couplers_to_s00_regslice_AWVALID),
        .s_axi_bready(s00_couplers_to_s00_regslice_BREADY),
        .s_axi_bresp(s00_couplers_to_s00_regslice_BRESP),
        .s_axi_bvalid(s00_couplers_to_s00_regslice_BVALID),
        .s_axi_rdata(s00_couplers_to_s00_regslice_RDATA),
        .s_axi_rlast(s00_couplers_to_s00_regslice_RLAST),
        .s_axi_rready(s00_couplers_to_s00_regslice_RREADY),
        .s_axi_rresp(s00_couplers_to_s00_regslice_RRESP),
        .s_axi_rvalid(s00_couplers_to_s00_regslice_RVALID),
        .s_axi_wdata(s00_couplers_to_s00_regslice_WDATA),
        .s_axi_wlast(s00_couplers_to_s00_regslice_WLAST),
        .s_axi_wready(s00_couplers_to_s00_regslice_WREADY),
        .s_axi_wstrb(s00_couplers_to_s00_regslice_WSTRB),
        .s_axi_wvalid(s00_couplers_to_s00_regslice_WVALID));
endmodule

module s00_couplers_imp_1JGQSCA
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arburst,
    M_AXI_arcache,
    M_AXI_arid,
    M_AXI_arlen,
    M_AXI_arlock,
    M_AXI_arprot,
    M_AXI_arqos,
    M_AXI_arready,
    M_AXI_arsize,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awburst,
    M_AXI_awcache,
    M_AXI_awid,
    M_AXI_awlen,
    M_AXI_awlock,
    M_AXI_awprot,
    M_AXI_awqos,
    M_AXI_awready,
    M_AXI_awsize,
    M_AXI_awvalid,
    M_AXI_bid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rid,
    M_AXI_rlast,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wid,
    M_AXI_wlast,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arburst,
    S_AXI_arcache,
    S_AXI_arid,
    S_AXI_arlen,
    S_AXI_arlock,
    S_AXI_arprot,
    S_AXI_arqos,
    S_AXI_arready,
    S_AXI_arregion,
    S_AXI_arsize,
    S_AXI_aruser,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awburst,
    S_AXI_awcache,
    S_AXI_awid,
    S_AXI_awlen,
    S_AXI_awlock,
    S_AXI_awprot,
    S_AXI_awqos,
    S_AXI_awready,
    S_AXI_awregion,
    S_AXI_awsize,
    S_AXI_awuser,
    S_AXI_awvalid,
    S_AXI_bid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rid,
    S_AXI_rlast,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_ruser,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wlast,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wuser,
    S_AXI_wvalid);
  input M_ACLK;
  input [0:0]M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [1:0]M_AXI_arburst;
  output [3:0]M_AXI_arcache;
  output [0:0]M_AXI_arid;
  output [3:0]M_AXI_arlen;
  output [1:0]M_AXI_arlock;
  output [2:0]M_AXI_arprot;
  output [3:0]M_AXI_arqos;
  input M_AXI_arready;
  output [2:0]M_AXI_arsize;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [1:0]M_AXI_awburst;
  output [3:0]M_AXI_awcache;
  output [0:0]M_AXI_awid;
  output [3:0]M_AXI_awlen;
  output [1:0]M_AXI_awlock;
  output [2:0]M_AXI_awprot;
  output [3:0]M_AXI_awqos;
  input M_AXI_awready;
  output [2:0]M_AXI_awsize;
  output M_AXI_awvalid;
  input [0:0]M_AXI_bid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [63:0]M_AXI_rdata;
  input [0:0]M_AXI_rid;
  input M_AXI_rlast;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [63:0]M_AXI_wdata;
  output [0:0]M_AXI_wid;
  output M_AXI_wlast;
  input M_AXI_wready;
  output [7:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input [0:0]S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [1:0]S_AXI_arburst;
  input [3:0]S_AXI_arcache;
  input [0:0]S_AXI_arid;
  input [7:0]S_AXI_arlen;
  input [0:0]S_AXI_arlock;
  input [2:0]S_AXI_arprot;
  input [3:0]S_AXI_arqos;
  output S_AXI_arready;
  input [3:0]S_AXI_arregion;
  input [2:0]S_AXI_arsize;
  input [0:0]S_AXI_aruser;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [1:0]S_AXI_awburst;
  input [3:0]S_AXI_awcache;
  input [0:0]S_AXI_awid;
  input [7:0]S_AXI_awlen;
  input [0:0]S_AXI_awlock;
  input [2:0]S_AXI_awprot;
  input [3:0]S_AXI_awqos;
  output S_AXI_awready;
  input [3:0]S_AXI_awregion;
  input [2:0]S_AXI_awsize;
  input [0:0]S_AXI_awuser;
  input S_AXI_awvalid;
  output [0:0]S_AXI_bid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [63:0]S_AXI_rdata;
  output [0:0]S_AXI_rid;
  output S_AXI_rlast;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output [0:0]S_AXI_ruser;
  output S_AXI_rvalid;
  input [63:0]S_AXI_wdata;
  input S_AXI_wlast;
  output S_AXI_wready;
  input [7:0]S_AXI_wstrb;
  input [0:0]S_AXI_wuser;
  input S_AXI_wvalid;

  wire GND_1;
  wire S_ACLK_1;
  wire [0:0]S_ARESETN_1;
  wire [31:0]auto_pc_to_s00_couplers_ARADDR;
  wire [1:0]auto_pc_to_s00_couplers_ARBURST;
  wire [3:0]auto_pc_to_s00_couplers_ARCACHE;
  wire [0:0]auto_pc_to_s00_couplers_ARID;
  wire [3:0]auto_pc_to_s00_couplers_ARLEN;
  wire [1:0]auto_pc_to_s00_couplers_ARLOCK;
  wire [2:0]auto_pc_to_s00_couplers_ARPROT;
  wire [3:0]auto_pc_to_s00_couplers_ARQOS;
  wire auto_pc_to_s00_couplers_ARREADY;
  wire [2:0]auto_pc_to_s00_couplers_ARSIZE;
  wire auto_pc_to_s00_couplers_ARVALID;
  wire [31:0]auto_pc_to_s00_couplers_AWADDR;
  wire [1:0]auto_pc_to_s00_couplers_AWBURST;
  wire [3:0]auto_pc_to_s00_couplers_AWCACHE;
  wire [0:0]auto_pc_to_s00_couplers_AWID;
  wire [3:0]auto_pc_to_s00_couplers_AWLEN;
  wire [1:0]auto_pc_to_s00_couplers_AWLOCK;
  wire [2:0]auto_pc_to_s00_couplers_AWPROT;
  wire [3:0]auto_pc_to_s00_couplers_AWQOS;
  wire auto_pc_to_s00_couplers_AWREADY;
  wire [2:0]auto_pc_to_s00_couplers_AWSIZE;
  wire auto_pc_to_s00_couplers_AWVALID;
  wire [0:0]auto_pc_to_s00_couplers_BID;
  wire auto_pc_to_s00_couplers_BREADY;
  wire [1:0]auto_pc_to_s00_couplers_BRESP;
  wire auto_pc_to_s00_couplers_BVALID;
  wire [63:0]auto_pc_to_s00_couplers_RDATA;
  wire [0:0]auto_pc_to_s00_couplers_RID;
  wire auto_pc_to_s00_couplers_RLAST;
  wire auto_pc_to_s00_couplers_RREADY;
  wire [1:0]auto_pc_to_s00_couplers_RRESP;
  wire auto_pc_to_s00_couplers_RVALID;
  wire [63:0]auto_pc_to_s00_couplers_WDATA;
  wire [0:0]auto_pc_to_s00_couplers_WID;
  wire auto_pc_to_s00_couplers_WLAST;
  wire auto_pc_to_s00_couplers_WREADY;
  wire [7:0]auto_pc_to_s00_couplers_WSTRB;
  wire auto_pc_to_s00_couplers_WVALID;
  wire [31:0]s00_couplers_to_auto_pc_ARADDR;
  wire [1:0]s00_couplers_to_auto_pc_ARBURST;
  wire [3:0]s00_couplers_to_auto_pc_ARCACHE;
  wire [0:0]s00_couplers_to_auto_pc_ARID;
  wire [7:0]s00_couplers_to_auto_pc_ARLEN;
  wire [0:0]s00_couplers_to_auto_pc_ARLOCK;
  wire [2:0]s00_couplers_to_auto_pc_ARPROT;
  wire [3:0]s00_couplers_to_auto_pc_ARQOS;
  wire s00_couplers_to_auto_pc_ARREADY;
  wire [3:0]s00_couplers_to_auto_pc_ARREGION;
  wire [2:0]s00_couplers_to_auto_pc_ARSIZE;
  wire [0:0]s00_couplers_to_auto_pc_ARUSER;
  wire s00_couplers_to_auto_pc_ARVALID;
  wire [31:0]s00_couplers_to_auto_pc_AWADDR;
  wire [1:0]s00_couplers_to_auto_pc_AWBURST;
  wire [3:0]s00_couplers_to_auto_pc_AWCACHE;
  wire [0:0]s00_couplers_to_auto_pc_AWID;
  wire [7:0]s00_couplers_to_auto_pc_AWLEN;
  wire [0:0]s00_couplers_to_auto_pc_AWLOCK;
  wire [2:0]s00_couplers_to_auto_pc_AWPROT;
  wire [3:0]s00_couplers_to_auto_pc_AWQOS;
  wire s00_couplers_to_auto_pc_AWREADY;
  wire [3:0]s00_couplers_to_auto_pc_AWREGION;
  wire [2:0]s00_couplers_to_auto_pc_AWSIZE;
  wire [0:0]s00_couplers_to_auto_pc_AWUSER;
  wire s00_couplers_to_auto_pc_AWVALID;
  wire [0:0]s00_couplers_to_auto_pc_BID;
  wire s00_couplers_to_auto_pc_BREADY;
  wire [1:0]s00_couplers_to_auto_pc_BRESP;
  wire s00_couplers_to_auto_pc_BVALID;
  wire [63:0]s00_couplers_to_auto_pc_RDATA;
  wire [0:0]s00_couplers_to_auto_pc_RID;
  wire s00_couplers_to_auto_pc_RLAST;
  wire s00_couplers_to_auto_pc_RREADY;
  wire [1:0]s00_couplers_to_auto_pc_RRESP;
  wire [0:0]s00_couplers_to_auto_pc_RUSER;
  wire s00_couplers_to_auto_pc_RVALID;
  wire [63:0]s00_couplers_to_auto_pc_WDATA;
  wire s00_couplers_to_auto_pc_WLAST;
  wire s00_couplers_to_auto_pc_WREADY;
  wire [7:0]s00_couplers_to_auto_pc_WSTRB;
  wire [0:0]s00_couplers_to_auto_pc_WUSER;
  wire s00_couplers_to_auto_pc_WVALID;

  assign M_AXI_araddr[31:0] = auto_pc_to_s00_couplers_ARADDR;
  assign M_AXI_arburst[1:0] = auto_pc_to_s00_couplers_ARBURST;
  assign M_AXI_arcache[3:0] = auto_pc_to_s00_couplers_ARCACHE;
  assign M_AXI_arid[0] = auto_pc_to_s00_couplers_ARID;
  assign M_AXI_arlen[3:0] = auto_pc_to_s00_couplers_ARLEN;
  assign M_AXI_arlock[1:0] = auto_pc_to_s00_couplers_ARLOCK;
  assign M_AXI_arprot[2:0] = auto_pc_to_s00_couplers_ARPROT;
  assign M_AXI_arqos[3:0] = auto_pc_to_s00_couplers_ARQOS;
  assign M_AXI_arsize[2:0] = auto_pc_to_s00_couplers_ARSIZE;
  assign M_AXI_arvalid = auto_pc_to_s00_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = auto_pc_to_s00_couplers_AWADDR;
  assign M_AXI_awburst[1:0] = auto_pc_to_s00_couplers_AWBURST;
  assign M_AXI_awcache[3:0] = auto_pc_to_s00_couplers_AWCACHE;
  assign M_AXI_awid[0] = auto_pc_to_s00_couplers_AWID;
  assign M_AXI_awlen[3:0] = auto_pc_to_s00_couplers_AWLEN;
  assign M_AXI_awlock[1:0] = auto_pc_to_s00_couplers_AWLOCK;
  assign M_AXI_awprot[2:0] = auto_pc_to_s00_couplers_AWPROT;
  assign M_AXI_awqos[3:0] = auto_pc_to_s00_couplers_AWQOS;
  assign M_AXI_awsize[2:0] = auto_pc_to_s00_couplers_AWSIZE;
  assign M_AXI_awvalid = auto_pc_to_s00_couplers_AWVALID;
  assign M_AXI_bready = auto_pc_to_s00_couplers_BREADY;
  assign M_AXI_rready = auto_pc_to_s00_couplers_RREADY;
  assign M_AXI_wdata[63:0] = auto_pc_to_s00_couplers_WDATA;
  assign M_AXI_wid[0] = auto_pc_to_s00_couplers_WID;
  assign M_AXI_wlast = auto_pc_to_s00_couplers_WLAST;
  assign M_AXI_wstrb[7:0] = auto_pc_to_s00_couplers_WSTRB;
  assign M_AXI_wvalid = auto_pc_to_s00_couplers_WVALID;
  assign S_ACLK_1 = S_ACLK;
  assign S_ARESETN_1 = S_ARESETN[0];
  assign S_AXI_arready = s00_couplers_to_auto_pc_ARREADY;
  assign S_AXI_awready = s00_couplers_to_auto_pc_AWREADY;
  assign S_AXI_bid[0] = s00_couplers_to_auto_pc_BID;
  assign S_AXI_bresp[1:0] = s00_couplers_to_auto_pc_BRESP;
  assign S_AXI_bvalid = s00_couplers_to_auto_pc_BVALID;
  assign S_AXI_rdata[63:0] = s00_couplers_to_auto_pc_RDATA;
  assign S_AXI_rid[0] = s00_couplers_to_auto_pc_RID;
  assign S_AXI_rlast = s00_couplers_to_auto_pc_RLAST;
  assign S_AXI_rresp[1:0] = s00_couplers_to_auto_pc_RRESP;
  assign S_AXI_ruser[0] = s00_couplers_to_auto_pc_RUSER;
  assign S_AXI_rvalid = s00_couplers_to_auto_pc_RVALID;
  assign S_AXI_wready = s00_couplers_to_auto_pc_WREADY;
  assign auto_pc_to_s00_couplers_ARREADY = M_AXI_arready;
  assign auto_pc_to_s00_couplers_AWREADY = M_AXI_awready;
  assign auto_pc_to_s00_couplers_BID = M_AXI_bid[0];
  assign auto_pc_to_s00_couplers_BRESP = M_AXI_bresp[1:0];
  assign auto_pc_to_s00_couplers_BVALID = M_AXI_bvalid;
  assign auto_pc_to_s00_couplers_RDATA = M_AXI_rdata[63:0];
  assign auto_pc_to_s00_couplers_RID = M_AXI_rid[0];
  assign auto_pc_to_s00_couplers_RLAST = M_AXI_rlast;
  assign auto_pc_to_s00_couplers_RRESP = M_AXI_rresp[1:0];
  assign auto_pc_to_s00_couplers_RVALID = M_AXI_rvalid;
  assign auto_pc_to_s00_couplers_WREADY = M_AXI_wready;
  assign s00_couplers_to_auto_pc_ARADDR = S_AXI_araddr[31:0];
  assign s00_couplers_to_auto_pc_ARBURST = S_AXI_arburst[1:0];
  assign s00_couplers_to_auto_pc_ARCACHE = S_AXI_arcache[3:0];
  assign s00_couplers_to_auto_pc_ARID = S_AXI_arid[0];
  assign s00_couplers_to_auto_pc_ARLEN = S_AXI_arlen[7:0];
  assign s00_couplers_to_auto_pc_ARLOCK = S_AXI_arlock[0];
  assign s00_couplers_to_auto_pc_ARPROT = S_AXI_arprot[2:0];
  assign s00_couplers_to_auto_pc_ARQOS = S_AXI_arqos[3:0];
  assign s00_couplers_to_auto_pc_ARREGION = S_AXI_arregion[3:0];
  assign s00_couplers_to_auto_pc_ARSIZE = S_AXI_arsize[2:0];
  assign s00_couplers_to_auto_pc_ARUSER = S_AXI_aruser[0];
  assign s00_couplers_to_auto_pc_ARVALID = S_AXI_arvalid;
  assign s00_couplers_to_auto_pc_AWADDR = S_AXI_awaddr[31:0];
  assign s00_couplers_to_auto_pc_AWBURST = S_AXI_awburst[1:0];
  assign s00_couplers_to_auto_pc_AWCACHE = S_AXI_awcache[3:0];
  assign s00_couplers_to_auto_pc_AWID = S_AXI_awid[0];
  assign s00_couplers_to_auto_pc_AWLEN = S_AXI_awlen[7:0];
  assign s00_couplers_to_auto_pc_AWLOCK = S_AXI_awlock[0];
  assign s00_couplers_to_auto_pc_AWPROT = S_AXI_awprot[2:0];
  assign s00_couplers_to_auto_pc_AWQOS = S_AXI_awqos[3:0];
  assign s00_couplers_to_auto_pc_AWREGION = S_AXI_awregion[3:0];
  assign s00_couplers_to_auto_pc_AWSIZE = S_AXI_awsize[2:0];
  assign s00_couplers_to_auto_pc_AWUSER = S_AXI_awuser[0];
  assign s00_couplers_to_auto_pc_AWVALID = S_AXI_awvalid;
  assign s00_couplers_to_auto_pc_BREADY = S_AXI_bready;
  assign s00_couplers_to_auto_pc_RREADY = S_AXI_rready;
  assign s00_couplers_to_auto_pc_WDATA = S_AXI_wdata[63:0];
  assign s00_couplers_to_auto_pc_WLAST = S_AXI_wlast;
  assign s00_couplers_to_auto_pc_WSTRB = S_AXI_wstrb[7:0];
  assign s00_couplers_to_auto_pc_WUSER = S_AXI_wuser[0];
  assign s00_couplers_to_auto_pc_WVALID = S_AXI_wvalid;
GND GND
       (.G(GND_1));
OpenSSD2_auto_pc_1 auto_pc
       (.aclk(S_ACLK_1),
        .aresetn(S_ARESETN_1),
        .m_axi_araddr(auto_pc_to_s00_couplers_ARADDR),
        .m_axi_arburst(auto_pc_to_s00_couplers_ARBURST),
        .m_axi_arcache(auto_pc_to_s00_couplers_ARCACHE),
        .m_axi_arid(auto_pc_to_s00_couplers_ARID),
        .m_axi_arlen(auto_pc_to_s00_couplers_ARLEN),
        .m_axi_arlock(auto_pc_to_s00_couplers_ARLOCK),
        .m_axi_arprot(auto_pc_to_s00_couplers_ARPROT),
        .m_axi_arqos(auto_pc_to_s00_couplers_ARQOS),
        .m_axi_arready(auto_pc_to_s00_couplers_ARREADY),
        .m_axi_arsize(auto_pc_to_s00_couplers_ARSIZE),
        .m_axi_arvalid(auto_pc_to_s00_couplers_ARVALID),
        .m_axi_awaddr(auto_pc_to_s00_couplers_AWADDR),
        .m_axi_awburst(auto_pc_to_s00_couplers_AWBURST),
        .m_axi_awcache(auto_pc_to_s00_couplers_AWCACHE),
        .m_axi_awid(auto_pc_to_s00_couplers_AWID),
        .m_axi_awlen(auto_pc_to_s00_couplers_AWLEN),
        .m_axi_awlock(auto_pc_to_s00_couplers_AWLOCK),
        .m_axi_awprot(auto_pc_to_s00_couplers_AWPROT),
        .m_axi_awqos(auto_pc_to_s00_couplers_AWQOS),
        .m_axi_awready(auto_pc_to_s00_couplers_AWREADY),
        .m_axi_awsize(auto_pc_to_s00_couplers_AWSIZE),
        .m_axi_awvalid(auto_pc_to_s00_couplers_AWVALID),
        .m_axi_bid(auto_pc_to_s00_couplers_BID),
        .m_axi_bready(auto_pc_to_s00_couplers_BREADY),
        .m_axi_bresp(auto_pc_to_s00_couplers_BRESP),
        .m_axi_bvalid(auto_pc_to_s00_couplers_BVALID),
        .m_axi_rdata(auto_pc_to_s00_couplers_RDATA),
        .m_axi_rid(auto_pc_to_s00_couplers_RID),
        .m_axi_rlast(auto_pc_to_s00_couplers_RLAST),
        .m_axi_rready(auto_pc_to_s00_couplers_RREADY),
        .m_axi_rresp(auto_pc_to_s00_couplers_RRESP),
        .m_axi_ruser(GND_1),
        .m_axi_rvalid(auto_pc_to_s00_couplers_RVALID),
        .m_axi_wdata(auto_pc_to_s00_couplers_WDATA),
        .m_axi_wid(auto_pc_to_s00_couplers_WID),
        .m_axi_wlast(auto_pc_to_s00_couplers_WLAST),
        .m_axi_wready(auto_pc_to_s00_couplers_WREADY),
        .m_axi_wstrb(auto_pc_to_s00_couplers_WSTRB),
        .m_axi_wvalid(auto_pc_to_s00_couplers_WVALID),
        .s_axi_araddr(s00_couplers_to_auto_pc_ARADDR),
        .s_axi_arburst(s00_couplers_to_auto_pc_ARBURST),
        .s_axi_arcache(s00_couplers_to_auto_pc_ARCACHE),
        .s_axi_arid(s00_couplers_to_auto_pc_ARID),
        .s_axi_arlen(s00_couplers_to_auto_pc_ARLEN),
        .s_axi_arlock(s00_couplers_to_auto_pc_ARLOCK),
        .s_axi_arprot(s00_couplers_to_auto_pc_ARPROT),
        .s_axi_arqos(s00_couplers_to_auto_pc_ARQOS),
        .s_axi_arready(s00_couplers_to_auto_pc_ARREADY),
        .s_axi_arregion(s00_couplers_to_auto_pc_ARREGION),
        .s_axi_arsize(s00_couplers_to_auto_pc_ARSIZE),
        .s_axi_aruser(s00_couplers_to_auto_pc_ARUSER),
        .s_axi_arvalid(s00_couplers_to_auto_pc_ARVALID),
        .s_axi_awaddr(s00_couplers_to_auto_pc_AWADDR),
        .s_axi_awburst(s00_couplers_to_auto_pc_AWBURST),
        .s_axi_awcache(s00_couplers_to_auto_pc_AWCACHE),
        .s_axi_awid(s00_couplers_to_auto_pc_AWID),
        .s_axi_awlen(s00_couplers_to_auto_pc_AWLEN),
        .s_axi_awlock(s00_couplers_to_auto_pc_AWLOCK),
        .s_axi_awprot(s00_couplers_to_auto_pc_AWPROT),
        .s_axi_awqos(s00_couplers_to_auto_pc_AWQOS),
        .s_axi_awready(s00_couplers_to_auto_pc_AWREADY),
        .s_axi_awregion(s00_couplers_to_auto_pc_AWREGION),
        .s_axi_awsize(s00_couplers_to_auto_pc_AWSIZE),
        .s_axi_awuser(s00_couplers_to_auto_pc_AWUSER),
        .s_axi_awvalid(s00_couplers_to_auto_pc_AWVALID),
        .s_axi_bid(s00_couplers_to_auto_pc_BID),
        .s_axi_bready(s00_couplers_to_auto_pc_BREADY),
        .s_axi_bresp(s00_couplers_to_auto_pc_BRESP),
        .s_axi_bvalid(s00_couplers_to_auto_pc_BVALID),
        .s_axi_rdata(s00_couplers_to_auto_pc_RDATA),
        .s_axi_rid(s00_couplers_to_auto_pc_RID),
        .s_axi_rlast(s00_couplers_to_auto_pc_RLAST),
        .s_axi_rready(s00_couplers_to_auto_pc_RREADY),
        .s_axi_rresp(s00_couplers_to_auto_pc_RRESP),
        .s_axi_ruser(s00_couplers_to_auto_pc_RUSER),
        .s_axi_rvalid(s00_couplers_to_auto_pc_RVALID),
        .s_axi_wdata(s00_couplers_to_auto_pc_WDATA),
        .s_axi_wlast(s00_couplers_to_auto_pc_WLAST),
        .s_axi_wready(s00_couplers_to_auto_pc_WREADY),
        .s_axi_wstrb(s00_couplers_to_auto_pc_WSTRB),
        .s_axi_wuser(s00_couplers_to_auto_pc_WUSER),
        .s_axi_wvalid(s00_couplers_to_auto_pc_WVALID));
endmodule

module s00_couplers_imp_RUHP0G
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arprot,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awprot,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arburst,
    S_AXI_arcache,
    S_AXI_arid,
    S_AXI_arlen,
    S_AXI_arlock,
    S_AXI_arprot,
    S_AXI_arqos,
    S_AXI_arready,
    S_AXI_arsize,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awburst,
    S_AXI_awcache,
    S_AXI_awid,
    S_AXI_awlen,
    S_AXI_awlock,
    S_AXI_awprot,
    S_AXI_awqos,
    S_AXI_awready,
    S_AXI_awsize,
    S_AXI_awvalid,
    S_AXI_bid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rid,
    S_AXI_rlast,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wid,
    S_AXI_wlast,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input [0:0]M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [2:0]M_AXI_arprot;
  input M_AXI_arready;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [2:0]M_AXI_awprot;
  input M_AXI_awready;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input [0:0]S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [1:0]S_AXI_arburst;
  input [3:0]S_AXI_arcache;
  input [11:0]S_AXI_arid;
  input [3:0]S_AXI_arlen;
  input [1:0]S_AXI_arlock;
  input [2:0]S_AXI_arprot;
  input [3:0]S_AXI_arqos;
  output S_AXI_arready;
  input [2:0]S_AXI_arsize;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [1:0]S_AXI_awburst;
  input [3:0]S_AXI_awcache;
  input [11:0]S_AXI_awid;
  input [3:0]S_AXI_awlen;
  input [1:0]S_AXI_awlock;
  input [2:0]S_AXI_awprot;
  input [3:0]S_AXI_awqos;
  output S_AXI_awready;
  input [2:0]S_AXI_awsize;
  input S_AXI_awvalid;
  output [11:0]S_AXI_bid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  output [11:0]S_AXI_rid;
  output S_AXI_rlast;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  input [11:0]S_AXI_wid;
  input S_AXI_wlast;
  output S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire S_ACLK_1;
  wire [0:0]S_ARESETN_1;
  wire [31:0]auto_pc_to_s00_couplers_ARADDR;
  wire [2:0]auto_pc_to_s00_couplers_ARPROT;
  wire auto_pc_to_s00_couplers_ARREADY;
  wire auto_pc_to_s00_couplers_ARVALID;
  wire [31:0]auto_pc_to_s00_couplers_AWADDR;
  wire [2:0]auto_pc_to_s00_couplers_AWPROT;
  wire auto_pc_to_s00_couplers_AWREADY;
  wire auto_pc_to_s00_couplers_AWVALID;
  wire auto_pc_to_s00_couplers_BREADY;
  wire [1:0]auto_pc_to_s00_couplers_BRESP;
  wire auto_pc_to_s00_couplers_BVALID;
  wire [31:0]auto_pc_to_s00_couplers_RDATA;
  wire auto_pc_to_s00_couplers_RREADY;
  wire [1:0]auto_pc_to_s00_couplers_RRESP;
  wire auto_pc_to_s00_couplers_RVALID;
  wire [31:0]auto_pc_to_s00_couplers_WDATA;
  wire auto_pc_to_s00_couplers_WREADY;
  wire [3:0]auto_pc_to_s00_couplers_WSTRB;
  wire auto_pc_to_s00_couplers_WVALID;
  wire [31:0]s00_couplers_to_auto_pc_ARADDR;
  wire [1:0]s00_couplers_to_auto_pc_ARBURST;
  wire [3:0]s00_couplers_to_auto_pc_ARCACHE;
  wire [11:0]s00_couplers_to_auto_pc_ARID;
  wire [3:0]s00_couplers_to_auto_pc_ARLEN;
  wire [1:0]s00_couplers_to_auto_pc_ARLOCK;
  wire [2:0]s00_couplers_to_auto_pc_ARPROT;
  wire [3:0]s00_couplers_to_auto_pc_ARQOS;
  wire s00_couplers_to_auto_pc_ARREADY;
  wire [2:0]s00_couplers_to_auto_pc_ARSIZE;
  wire s00_couplers_to_auto_pc_ARVALID;
  wire [31:0]s00_couplers_to_auto_pc_AWADDR;
  wire [1:0]s00_couplers_to_auto_pc_AWBURST;
  wire [3:0]s00_couplers_to_auto_pc_AWCACHE;
  wire [11:0]s00_couplers_to_auto_pc_AWID;
  wire [3:0]s00_couplers_to_auto_pc_AWLEN;
  wire [1:0]s00_couplers_to_auto_pc_AWLOCK;
  wire [2:0]s00_couplers_to_auto_pc_AWPROT;
  wire [3:0]s00_couplers_to_auto_pc_AWQOS;
  wire s00_couplers_to_auto_pc_AWREADY;
  wire [2:0]s00_couplers_to_auto_pc_AWSIZE;
  wire s00_couplers_to_auto_pc_AWVALID;
  wire [11:0]s00_couplers_to_auto_pc_BID;
  wire s00_couplers_to_auto_pc_BREADY;
  wire [1:0]s00_couplers_to_auto_pc_BRESP;
  wire s00_couplers_to_auto_pc_BVALID;
  wire [31:0]s00_couplers_to_auto_pc_RDATA;
  wire [11:0]s00_couplers_to_auto_pc_RID;
  wire s00_couplers_to_auto_pc_RLAST;
  wire s00_couplers_to_auto_pc_RREADY;
  wire [1:0]s00_couplers_to_auto_pc_RRESP;
  wire s00_couplers_to_auto_pc_RVALID;
  wire [31:0]s00_couplers_to_auto_pc_WDATA;
  wire [11:0]s00_couplers_to_auto_pc_WID;
  wire s00_couplers_to_auto_pc_WLAST;
  wire s00_couplers_to_auto_pc_WREADY;
  wire [3:0]s00_couplers_to_auto_pc_WSTRB;
  wire s00_couplers_to_auto_pc_WVALID;

  assign M_AXI_araddr[31:0] = auto_pc_to_s00_couplers_ARADDR;
  assign M_AXI_arprot[2:0] = auto_pc_to_s00_couplers_ARPROT;
  assign M_AXI_arvalid = auto_pc_to_s00_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = auto_pc_to_s00_couplers_AWADDR;
  assign M_AXI_awprot[2:0] = auto_pc_to_s00_couplers_AWPROT;
  assign M_AXI_awvalid = auto_pc_to_s00_couplers_AWVALID;
  assign M_AXI_bready = auto_pc_to_s00_couplers_BREADY;
  assign M_AXI_rready = auto_pc_to_s00_couplers_RREADY;
  assign M_AXI_wdata[31:0] = auto_pc_to_s00_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = auto_pc_to_s00_couplers_WSTRB;
  assign M_AXI_wvalid = auto_pc_to_s00_couplers_WVALID;
  assign S_ACLK_1 = S_ACLK;
  assign S_ARESETN_1 = S_ARESETN[0];
  assign S_AXI_arready = s00_couplers_to_auto_pc_ARREADY;
  assign S_AXI_awready = s00_couplers_to_auto_pc_AWREADY;
  assign S_AXI_bid[11:0] = s00_couplers_to_auto_pc_BID;
  assign S_AXI_bresp[1:0] = s00_couplers_to_auto_pc_BRESP;
  assign S_AXI_bvalid = s00_couplers_to_auto_pc_BVALID;
  assign S_AXI_rdata[31:0] = s00_couplers_to_auto_pc_RDATA;
  assign S_AXI_rid[11:0] = s00_couplers_to_auto_pc_RID;
  assign S_AXI_rlast = s00_couplers_to_auto_pc_RLAST;
  assign S_AXI_rresp[1:0] = s00_couplers_to_auto_pc_RRESP;
  assign S_AXI_rvalid = s00_couplers_to_auto_pc_RVALID;
  assign S_AXI_wready = s00_couplers_to_auto_pc_WREADY;
  assign auto_pc_to_s00_couplers_ARREADY = M_AXI_arready;
  assign auto_pc_to_s00_couplers_AWREADY = M_AXI_awready;
  assign auto_pc_to_s00_couplers_BRESP = M_AXI_bresp[1:0];
  assign auto_pc_to_s00_couplers_BVALID = M_AXI_bvalid;
  assign auto_pc_to_s00_couplers_RDATA = M_AXI_rdata[31:0];
  assign auto_pc_to_s00_couplers_RRESP = M_AXI_rresp[1:0];
  assign auto_pc_to_s00_couplers_RVALID = M_AXI_rvalid;
  assign auto_pc_to_s00_couplers_WREADY = M_AXI_wready;
  assign s00_couplers_to_auto_pc_ARADDR = S_AXI_araddr[31:0];
  assign s00_couplers_to_auto_pc_ARBURST = S_AXI_arburst[1:0];
  assign s00_couplers_to_auto_pc_ARCACHE = S_AXI_arcache[3:0];
  assign s00_couplers_to_auto_pc_ARID = S_AXI_arid[11:0];
  assign s00_couplers_to_auto_pc_ARLEN = S_AXI_arlen[3:0];
  assign s00_couplers_to_auto_pc_ARLOCK = S_AXI_arlock[1:0];
  assign s00_couplers_to_auto_pc_ARPROT = S_AXI_arprot[2:0];
  assign s00_couplers_to_auto_pc_ARQOS = S_AXI_arqos[3:0];
  assign s00_couplers_to_auto_pc_ARSIZE = S_AXI_arsize[2:0];
  assign s00_couplers_to_auto_pc_ARVALID = S_AXI_arvalid;
  assign s00_couplers_to_auto_pc_AWADDR = S_AXI_awaddr[31:0];
  assign s00_couplers_to_auto_pc_AWBURST = S_AXI_awburst[1:0];
  assign s00_couplers_to_auto_pc_AWCACHE = S_AXI_awcache[3:0];
  assign s00_couplers_to_auto_pc_AWID = S_AXI_awid[11:0];
  assign s00_couplers_to_auto_pc_AWLEN = S_AXI_awlen[3:0];
  assign s00_couplers_to_auto_pc_AWLOCK = S_AXI_awlock[1:0];
  assign s00_couplers_to_auto_pc_AWPROT = S_AXI_awprot[2:0];
  assign s00_couplers_to_auto_pc_AWQOS = S_AXI_awqos[3:0];
  assign s00_couplers_to_auto_pc_AWSIZE = S_AXI_awsize[2:0];
  assign s00_couplers_to_auto_pc_AWVALID = S_AXI_awvalid;
  assign s00_couplers_to_auto_pc_BREADY = S_AXI_bready;
  assign s00_couplers_to_auto_pc_RREADY = S_AXI_rready;
  assign s00_couplers_to_auto_pc_WDATA = S_AXI_wdata[31:0];
  assign s00_couplers_to_auto_pc_WID = S_AXI_wid[11:0];
  assign s00_couplers_to_auto_pc_WLAST = S_AXI_wlast;
  assign s00_couplers_to_auto_pc_WSTRB = S_AXI_wstrb[3:0];
  assign s00_couplers_to_auto_pc_WVALID = S_AXI_wvalid;
OpenSSD2_auto_pc_2 auto_pc
       (.aclk(S_ACLK_1),
        .aresetn(S_ARESETN_1),
        .m_axi_araddr(auto_pc_to_s00_couplers_ARADDR),
        .m_axi_arprot(auto_pc_to_s00_couplers_ARPROT),
        .m_axi_arready(auto_pc_to_s00_couplers_ARREADY),
        .m_axi_arvalid(auto_pc_to_s00_couplers_ARVALID),
        .m_axi_awaddr(auto_pc_to_s00_couplers_AWADDR),
        .m_axi_awprot(auto_pc_to_s00_couplers_AWPROT),
        .m_axi_awready(auto_pc_to_s00_couplers_AWREADY),
        .m_axi_awvalid(auto_pc_to_s00_couplers_AWVALID),
        .m_axi_bready(auto_pc_to_s00_couplers_BREADY),
        .m_axi_bresp(auto_pc_to_s00_couplers_BRESP),
        .m_axi_bvalid(auto_pc_to_s00_couplers_BVALID),
        .m_axi_rdata(auto_pc_to_s00_couplers_RDATA),
        .m_axi_rready(auto_pc_to_s00_couplers_RREADY),
        .m_axi_rresp(auto_pc_to_s00_couplers_RRESP),
        .m_axi_rvalid(auto_pc_to_s00_couplers_RVALID),
        .m_axi_wdata(auto_pc_to_s00_couplers_WDATA),
        .m_axi_wready(auto_pc_to_s00_couplers_WREADY),
        .m_axi_wstrb(auto_pc_to_s00_couplers_WSTRB),
        .m_axi_wvalid(auto_pc_to_s00_couplers_WVALID),
        .s_axi_araddr(s00_couplers_to_auto_pc_ARADDR),
        .s_axi_arburst(s00_couplers_to_auto_pc_ARBURST),
        .s_axi_arcache(s00_couplers_to_auto_pc_ARCACHE),
        .s_axi_arid(s00_couplers_to_auto_pc_ARID),
        .s_axi_arlen(s00_couplers_to_auto_pc_ARLEN),
        .s_axi_arlock(s00_couplers_to_auto_pc_ARLOCK),
        .s_axi_arprot(s00_couplers_to_auto_pc_ARPROT),
        .s_axi_arqos(s00_couplers_to_auto_pc_ARQOS),
        .s_axi_arready(s00_couplers_to_auto_pc_ARREADY),
        .s_axi_arsize(s00_couplers_to_auto_pc_ARSIZE),
        .s_axi_arvalid(s00_couplers_to_auto_pc_ARVALID),
        .s_axi_awaddr(s00_couplers_to_auto_pc_AWADDR),
        .s_axi_awburst(s00_couplers_to_auto_pc_AWBURST),
        .s_axi_awcache(s00_couplers_to_auto_pc_AWCACHE),
        .s_axi_awid(s00_couplers_to_auto_pc_AWID),
        .s_axi_awlen(s00_couplers_to_auto_pc_AWLEN),
        .s_axi_awlock(s00_couplers_to_auto_pc_AWLOCK),
        .s_axi_awprot(s00_couplers_to_auto_pc_AWPROT),
        .s_axi_awqos(s00_couplers_to_auto_pc_AWQOS),
        .s_axi_awready(s00_couplers_to_auto_pc_AWREADY),
        .s_axi_awsize(s00_couplers_to_auto_pc_AWSIZE),
        .s_axi_awvalid(s00_couplers_to_auto_pc_AWVALID),
        .s_axi_bid(s00_couplers_to_auto_pc_BID),
        .s_axi_bready(s00_couplers_to_auto_pc_BREADY),
        .s_axi_bresp(s00_couplers_to_auto_pc_BRESP),
        .s_axi_bvalid(s00_couplers_to_auto_pc_BVALID),
        .s_axi_rdata(s00_couplers_to_auto_pc_RDATA),
        .s_axi_rid(s00_couplers_to_auto_pc_RID),
        .s_axi_rlast(s00_couplers_to_auto_pc_RLAST),
        .s_axi_rready(s00_couplers_to_auto_pc_RREADY),
        .s_axi_rresp(s00_couplers_to_auto_pc_RRESP),
        .s_axi_rvalid(s00_couplers_to_auto_pc_RVALID),
        .s_axi_wdata(s00_couplers_to_auto_pc_WDATA),
        .s_axi_wid(s00_couplers_to_auto_pc_WID),
        .s_axi_wlast(s00_couplers_to_auto_pc_WLAST),
        .s_axi_wready(s00_couplers_to_auto_pc_WREADY),
        .s_axi_wstrb(s00_couplers_to_auto_pc_WSTRB),
        .s_axi_wvalid(s00_couplers_to_auto_pc_WVALID));
endmodule

module s00_couplers_imp_W195PC
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arprot,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awprot,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arburst,
    S_AXI_arcache,
    S_AXI_arid,
    S_AXI_arlen,
    S_AXI_arlock,
    S_AXI_arprot,
    S_AXI_arqos,
    S_AXI_arready,
    S_AXI_arsize,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awburst,
    S_AXI_awcache,
    S_AXI_awid,
    S_AXI_awlen,
    S_AXI_awlock,
    S_AXI_awprot,
    S_AXI_awqos,
    S_AXI_awready,
    S_AXI_awsize,
    S_AXI_awvalid,
    S_AXI_bid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rid,
    S_AXI_rlast,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wid,
    S_AXI_wlast,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input [0:0]M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [2:0]M_AXI_arprot;
  input M_AXI_arready;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [2:0]M_AXI_awprot;
  input M_AXI_awready;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input [0:0]S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [1:0]S_AXI_arburst;
  input [3:0]S_AXI_arcache;
  input [11:0]S_AXI_arid;
  input [3:0]S_AXI_arlen;
  input [1:0]S_AXI_arlock;
  input [2:0]S_AXI_arprot;
  input [3:0]S_AXI_arqos;
  output S_AXI_arready;
  input [2:0]S_AXI_arsize;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [1:0]S_AXI_awburst;
  input [3:0]S_AXI_awcache;
  input [11:0]S_AXI_awid;
  input [3:0]S_AXI_awlen;
  input [1:0]S_AXI_awlock;
  input [2:0]S_AXI_awprot;
  input [3:0]S_AXI_awqos;
  output S_AXI_awready;
  input [2:0]S_AXI_awsize;
  input S_AXI_awvalid;
  output [11:0]S_AXI_bid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  output [11:0]S_AXI_rid;
  output S_AXI_rlast;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  input [11:0]S_AXI_wid;
  input S_AXI_wlast;
  output S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire S_ACLK_1;
  wire [0:0]S_ARESETN_1;
  wire [31:0]auto_pc_to_s00_couplers_ARADDR;
  wire [2:0]auto_pc_to_s00_couplers_ARPROT;
  wire auto_pc_to_s00_couplers_ARREADY;
  wire auto_pc_to_s00_couplers_ARVALID;
  wire [31:0]auto_pc_to_s00_couplers_AWADDR;
  wire [2:0]auto_pc_to_s00_couplers_AWPROT;
  wire auto_pc_to_s00_couplers_AWREADY;
  wire auto_pc_to_s00_couplers_AWVALID;
  wire auto_pc_to_s00_couplers_BREADY;
  wire [1:0]auto_pc_to_s00_couplers_BRESP;
  wire auto_pc_to_s00_couplers_BVALID;
  wire [31:0]auto_pc_to_s00_couplers_RDATA;
  wire auto_pc_to_s00_couplers_RREADY;
  wire [1:0]auto_pc_to_s00_couplers_RRESP;
  wire auto_pc_to_s00_couplers_RVALID;
  wire [31:0]auto_pc_to_s00_couplers_WDATA;
  wire auto_pc_to_s00_couplers_WREADY;
  wire [3:0]auto_pc_to_s00_couplers_WSTRB;
  wire auto_pc_to_s00_couplers_WVALID;
  wire [31:0]s00_couplers_to_auto_pc_ARADDR;
  wire [1:0]s00_couplers_to_auto_pc_ARBURST;
  wire [3:0]s00_couplers_to_auto_pc_ARCACHE;
  wire [11:0]s00_couplers_to_auto_pc_ARID;
  wire [3:0]s00_couplers_to_auto_pc_ARLEN;
  wire [1:0]s00_couplers_to_auto_pc_ARLOCK;
  wire [2:0]s00_couplers_to_auto_pc_ARPROT;
  wire [3:0]s00_couplers_to_auto_pc_ARQOS;
  wire s00_couplers_to_auto_pc_ARREADY;
  wire [2:0]s00_couplers_to_auto_pc_ARSIZE;
  wire s00_couplers_to_auto_pc_ARVALID;
  wire [31:0]s00_couplers_to_auto_pc_AWADDR;
  wire [1:0]s00_couplers_to_auto_pc_AWBURST;
  wire [3:0]s00_couplers_to_auto_pc_AWCACHE;
  wire [11:0]s00_couplers_to_auto_pc_AWID;
  wire [3:0]s00_couplers_to_auto_pc_AWLEN;
  wire [1:0]s00_couplers_to_auto_pc_AWLOCK;
  wire [2:0]s00_couplers_to_auto_pc_AWPROT;
  wire [3:0]s00_couplers_to_auto_pc_AWQOS;
  wire s00_couplers_to_auto_pc_AWREADY;
  wire [2:0]s00_couplers_to_auto_pc_AWSIZE;
  wire s00_couplers_to_auto_pc_AWVALID;
  wire [11:0]s00_couplers_to_auto_pc_BID;
  wire s00_couplers_to_auto_pc_BREADY;
  wire [1:0]s00_couplers_to_auto_pc_BRESP;
  wire s00_couplers_to_auto_pc_BVALID;
  wire [31:0]s00_couplers_to_auto_pc_RDATA;
  wire [11:0]s00_couplers_to_auto_pc_RID;
  wire s00_couplers_to_auto_pc_RLAST;
  wire s00_couplers_to_auto_pc_RREADY;
  wire [1:0]s00_couplers_to_auto_pc_RRESP;
  wire s00_couplers_to_auto_pc_RVALID;
  wire [31:0]s00_couplers_to_auto_pc_WDATA;
  wire [11:0]s00_couplers_to_auto_pc_WID;
  wire s00_couplers_to_auto_pc_WLAST;
  wire s00_couplers_to_auto_pc_WREADY;
  wire [3:0]s00_couplers_to_auto_pc_WSTRB;
  wire s00_couplers_to_auto_pc_WVALID;

  assign M_AXI_araddr[31:0] = auto_pc_to_s00_couplers_ARADDR;
  assign M_AXI_arprot[2:0] = auto_pc_to_s00_couplers_ARPROT;
  assign M_AXI_arvalid = auto_pc_to_s00_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = auto_pc_to_s00_couplers_AWADDR;
  assign M_AXI_awprot[2:0] = auto_pc_to_s00_couplers_AWPROT;
  assign M_AXI_awvalid = auto_pc_to_s00_couplers_AWVALID;
  assign M_AXI_bready = auto_pc_to_s00_couplers_BREADY;
  assign M_AXI_rready = auto_pc_to_s00_couplers_RREADY;
  assign M_AXI_wdata[31:0] = auto_pc_to_s00_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = auto_pc_to_s00_couplers_WSTRB;
  assign M_AXI_wvalid = auto_pc_to_s00_couplers_WVALID;
  assign S_ACLK_1 = S_ACLK;
  assign S_ARESETN_1 = S_ARESETN[0];
  assign S_AXI_arready = s00_couplers_to_auto_pc_ARREADY;
  assign S_AXI_awready = s00_couplers_to_auto_pc_AWREADY;
  assign S_AXI_bid[11:0] = s00_couplers_to_auto_pc_BID;
  assign S_AXI_bresp[1:0] = s00_couplers_to_auto_pc_BRESP;
  assign S_AXI_bvalid = s00_couplers_to_auto_pc_BVALID;
  assign S_AXI_rdata[31:0] = s00_couplers_to_auto_pc_RDATA;
  assign S_AXI_rid[11:0] = s00_couplers_to_auto_pc_RID;
  assign S_AXI_rlast = s00_couplers_to_auto_pc_RLAST;
  assign S_AXI_rresp[1:0] = s00_couplers_to_auto_pc_RRESP;
  assign S_AXI_rvalid = s00_couplers_to_auto_pc_RVALID;
  assign S_AXI_wready = s00_couplers_to_auto_pc_WREADY;
  assign auto_pc_to_s00_couplers_ARREADY = M_AXI_arready;
  assign auto_pc_to_s00_couplers_AWREADY = M_AXI_awready;
  assign auto_pc_to_s00_couplers_BRESP = M_AXI_bresp[1:0];
  assign auto_pc_to_s00_couplers_BVALID = M_AXI_bvalid;
  assign auto_pc_to_s00_couplers_RDATA = M_AXI_rdata[31:0];
  assign auto_pc_to_s00_couplers_RRESP = M_AXI_rresp[1:0];
  assign auto_pc_to_s00_couplers_RVALID = M_AXI_rvalid;
  assign auto_pc_to_s00_couplers_WREADY = M_AXI_wready;
  assign s00_couplers_to_auto_pc_ARADDR = S_AXI_araddr[31:0];
  assign s00_couplers_to_auto_pc_ARBURST = S_AXI_arburst[1:0];
  assign s00_couplers_to_auto_pc_ARCACHE = S_AXI_arcache[3:0];
  assign s00_couplers_to_auto_pc_ARID = S_AXI_arid[11:0];
  assign s00_couplers_to_auto_pc_ARLEN = S_AXI_arlen[3:0];
  assign s00_couplers_to_auto_pc_ARLOCK = S_AXI_arlock[1:0];
  assign s00_couplers_to_auto_pc_ARPROT = S_AXI_arprot[2:0];
  assign s00_couplers_to_auto_pc_ARQOS = S_AXI_arqos[3:0];
  assign s00_couplers_to_auto_pc_ARSIZE = S_AXI_arsize[2:0];
  assign s00_couplers_to_auto_pc_ARVALID = S_AXI_arvalid;
  assign s00_couplers_to_auto_pc_AWADDR = S_AXI_awaddr[31:0];
  assign s00_couplers_to_auto_pc_AWBURST = S_AXI_awburst[1:0];
  assign s00_couplers_to_auto_pc_AWCACHE = S_AXI_awcache[3:0];
  assign s00_couplers_to_auto_pc_AWID = S_AXI_awid[11:0];
  assign s00_couplers_to_auto_pc_AWLEN = S_AXI_awlen[3:0];
  assign s00_couplers_to_auto_pc_AWLOCK = S_AXI_awlock[1:0];
  assign s00_couplers_to_auto_pc_AWPROT = S_AXI_awprot[2:0];
  assign s00_couplers_to_auto_pc_AWQOS = S_AXI_awqos[3:0];
  assign s00_couplers_to_auto_pc_AWSIZE = S_AXI_awsize[2:0];
  assign s00_couplers_to_auto_pc_AWVALID = S_AXI_awvalid;
  assign s00_couplers_to_auto_pc_BREADY = S_AXI_bready;
  assign s00_couplers_to_auto_pc_RREADY = S_AXI_rready;
  assign s00_couplers_to_auto_pc_WDATA = S_AXI_wdata[31:0];
  assign s00_couplers_to_auto_pc_WID = S_AXI_wid[11:0];
  assign s00_couplers_to_auto_pc_WLAST = S_AXI_wlast;
  assign s00_couplers_to_auto_pc_WSTRB = S_AXI_wstrb[3:0];
  assign s00_couplers_to_auto_pc_WVALID = S_AXI_wvalid;
OpenSSD2_auto_pc_0 auto_pc
       (.aclk(S_ACLK_1),
        .aresetn(S_ARESETN_1),
        .m_axi_araddr(auto_pc_to_s00_couplers_ARADDR),
        .m_axi_arprot(auto_pc_to_s00_couplers_ARPROT),
        .m_axi_arready(auto_pc_to_s00_couplers_ARREADY),
        .m_axi_arvalid(auto_pc_to_s00_couplers_ARVALID),
        .m_axi_awaddr(auto_pc_to_s00_couplers_AWADDR),
        .m_axi_awprot(auto_pc_to_s00_couplers_AWPROT),
        .m_axi_awready(auto_pc_to_s00_couplers_AWREADY),
        .m_axi_awvalid(auto_pc_to_s00_couplers_AWVALID),
        .m_axi_bready(auto_pc_to_s00_couplers_BREADY),
        .m_axi_bresp(auto_pc_to_s00_couplers_BRESP),
        .m_axi_bvalid(auto_pc_to_s00_couplers_BVALID),
        .m_axi_rdata(auto_pc_to_s00_couplers_RDATA),
        .m_axi_rready(auto_pc_to_s00_couplers_RREADY),
        .m_axi_rresp(auto_pc_to_s00_couplers_RRESP),
        .m_axi_rvalid(auto_pc_to_s00_couplers_RVALID),
        .m_axi_wdata(auto_pc_to_s00_couplers_WDATA),
        .m_axi_wready(auto_pc_to_s00_couplers_WREADY),
        .m_axi_wstrb(auto_pc_to_s00_couplers_WSTRB),
        .m_axi_wvalid(auto_pc_to_s00_couplers_WVALID),
        .s_axi_araddr(s00_couplers_to_auto_pc_ARADDR),
        .s_axi_arburst(s00_couplers_to_auto_pc_ARBURST),
        .s_axi_arcache(s00_couplers_to_auto_pc_ARCACHE),
        .s_axi_arid(s00_couplers_to_auto_pc_ARID),
        .s_axi_arlen(s00_couplers_to_auto_pc_ARLEN),
        .s_axi_arlock(s00_couplers_to_auto_pc_ARLOCK),
        .s_axi_arprot(s00_couplers_to_auto_pc_ARPROT),
        .s_axi_arqos(s00_couplers_to_auto_pc_ARQOS),
        .s_axi_arready(s00_couplers_to_auto_pc_ARREADY),
        .s_axi_arsize(s00_couplers_to_auto_pc_ARSIZE),
        .s_axi_arvalid(s00_couplers_to_auto_pc_ARVALID),
        .s_axi_awaddr(s00_couplers_to_auto_pc_AWADDR),
        .s_axi_awburst(s00_couplers_to_auto_pc_AWBURST),
        .s_axi_awcache(s00_couplers_to_auto_pc_AWCACHE),
        .s_axi_awid(s00_couplers_to_auto_pc_AWID),
        .s_axi_awlen(s00_couplers_to_auto_pc_AWLEN),
        .s_axi_awlock(s00_couplers_to_auto_pc_AWLOCK),
        .s_axi_awprot(s00_couplers_to_auto_pc_AWPROT),
        .s_axi_awqos(s00_couplers_to_auto_pc_AWQOS),
        .s_axi_awready(s00_couplers_to_auto_pc_AWREADY),
        .s_axi_awsize(s00_couplers_to_auto_pc_AWSIZE),
        .s_axi_awvalid(s00_couplers_to_auto_pc_AWVALID),
        .s_axi_bid(s00_couplers_to_auto_pc_BID),
        .s_axi_bready(s00_couplers_to_auto_pc_BREADY),
        .s_axi_bresp(s00_couplers_to_auto_pc_BRESP),
        .s_axi_bvalid(s00_couplers_to_auto_pc_BVALID),
        .s_axi_rdata(s00_couplers_to_auto_pc_RDATA),
        .s_axi_rid(s00_couplers_to_auto_pc_RID),
        .s_axi_rlast(s00_couplers_to_auto_pc_RLAST),
        .s_axi_rready(s00_couplers_to_auto_pc_RREADY),
        .s_axi_rresp(s00_couplers_to_auto_pc_RRESP),
        .s_axi_rvalid(s00_couplers_to_auto_pc_RVALID),
        .s_axi_wdata(s00_couplers_to_auto_pc_WDATA),
        .s_axi_wid(s00_couplers_to_auto_pc_WID),
        .s_axi_wlast(s00_couplers_to_auto_pc_WLAST),
        .s_axi_wready(s00_couplers_to_auto_pc_WREADY),
        .s_axi_wstrb(s00_couplers_to_auto_pc_WSTRB),
        .s_axi_wvalid(s00_couplers_to_auto_pc_WVALID));
endmodule

module s01_couplers_imp_CRGJ2V
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arburst,
    M_AXI_arcache,
    M_AXI_arlen,
    M_AXI_arlock,
    M_AXI_arprot,
    M_AXI_arqos,
    M_AXI_arready,
    M_AXI_arsize,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awburst,
    M_AXI_awcache,
    M_AXI_awlen,
    M_AXI_awlock,
    M_AXI_awprot,
    M_AXI_awqos,
    M_AXI_awready,
    M_AXI_awsize,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rlast,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wlast,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arburst,
    S_AXI_arcache,
    S_AXI_arlen,
    S_AXI_arprot,
    S_AXI_arready,
    S_AXI_arsize,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awburst,
    S_AXI_awcache,
    S_AXI_awlen,
    S_AXI_awprot,
    S_AXI_awready,
    S_AXI_awsize,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rlast,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wlast,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input [0:0]M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [1:0]M_AXI_arburst;
  output [3:0]M_AXI_arcache;
  output [7:0]M_AXI_arlen;
  output [0:0]M_AXI_arlock;
  output [2:0]M_AXI_arprot;
  output [3:0]M_AXI_arqos;
  input M_AXI_arready;
  output [2:0]M_AXI_arsize;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [1:0]M_AXI_awburst;
  output [3:0]M_AXI_awcache;
  output [7:0]M_AXI_awlen;
  output [0:0]M_AXI_awlock;
  output [2:0]M_AXI_awprot;
  output [3:0]M_AXI_awqos;
  input M_AXI_awready;
  output [2:0]M_AXI_awsize;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [63:0]M_AXI_rdata;
  input M_AXI_rlast;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [63:0]M_AXI_wdata;
  output M_AXI_wlast;
  input M_AXI_wready;
  output [7:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input [0:0]S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [1:0]S_AXI_arburst;
  input [3:0]S_AXI_arcache;
  input [7:0]S_AXI_arlen;
  input [2:0]S_AXI_arprot;
  output S_AXI_arready;
  input [2:0]S_AXI_arsize;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [1:0]S_AXI_awburst;
  input [3:0]S_AXI_awcache;
  input [7:0]S_AXI_awlen;
  input [2:0]S_AXI_awprot;
  output S_AXI_awready;
  input [2:0]S_AXI_awsize;
  input S_AXI_awvalid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  output S_AXI_rlast;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  input S_AXI_wlast;
  output S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire GND_1;
  wire M_ACLK_1;
  wire [0:0]M_ARESETN_1;
  wire S_ACLK_1;
  wire [0:0]S_ARESETN_1;
  wire [31:0]auto_us_cc_df_to_s01_couplers_ARADDR;
  wire [1:0]auto_us_cc_df_to_s01_couplers_ARBURST;
  wire [3:0]auto_us_cc_df_to_s01_couplers_ARCACHE;
  wire [7:0]auto_us_cc_df_to_s01_couplers_ARLEN;
  wire [0:0]auto_us_cc_df_to_s01_couplers_ARLOCK;
  wire [2:0]auto_us_cc_df_to_s01_couplers_ARPROT;
  wire [3:0]auto_us_cc_df_to_s01_couplers_ARQOS;
  wire auto_us_cc_df_to_s01_couplers_ARREADY;
  wire [2:0]auto_us_cc_df_to_s01_couplers_ARSIZE;
  wire auto_us_cc_df_to_s01_couplers_ARVALID;
  wire [31:0]auto_us_cc_df_to_s01_couplers_AWADDR;
  wire [1:0]auto_us_cc_df_to_s01_couplers_AWBURST;
  wire [3:0]auto_us_cc_df_to_s01_couplers_AWCACHE;
  wire [7:0]auto_us_cc_df_to_s01_couplers_AWLEN;
  wire [0:0]auto_us_cc_df_to_s01_couplers_AWLOCK;
  wire [2:0]auto_us_cc_df_to_s01_couplers_AWPROT;
  wire [3:0]auto_us_cc_df_to_s01_couplers_AWQOS;
  wire auto_us_cc_df_to_s01_couplers_AWREADY;
  wire [2:0]auto_us_cc_df_to_s01_couplers_AWSIZE;
  wire auto_us_cc_df_to_s01_couplers_AWVALID;
  wire auto_us_cc_df_to_s01_couplers_BREADY;
  wire [1:0]auto_us_cc_df_to_s01_couplers_BRESP;
  wire auto_us_cc_df_to_s01_couplers_BVALID;
  wire [63:0]auto_us_cc_df_to_s01_couplers_RDATA;
  wire auto_us_cc_df_to_s01_couplers_RLAST;
  wire auto_us_cc_df_to_s01_couplers_RREADY;
  wire [1:0]auto_us_cc_df_to_s01_couplers_RRESP;
  wire auto_us_cc_df_to_s01_couplers_RVALID;
  wire [63:0]auto_us_cc_df_to_s01_couplers_WDATA;
  wire auto_us_cc_df_to_s01_couplers_WLAST;
  wire auto_us_cc_df_to_s01_couplers_WREADY;
  wire [7:0]auto_us_cc_df_to_s01_couplers_WSTRB;
  wire auto_us_cc_df_to_s01_couplers_WVALID;
  wire [31:0]s01_couplers_to_s01_regslice_ARADDR;
  wire [1:0]s01_couplers_to_s01_regslice_ARBURST;
  wire [3:0]s01_couplers_to_s01_regslice_ARCACHE;
  wire [7:0]s01_couplers_to_s01_regslice_ARLEN;
  wire [2:0]s01_couplers_to_s01_regslice_ARPROT;
  wire s01_couplers_to_s01_regslice_ARREADY;
  wire [2:0]s01_couplers_to_s01_regslice_ARSIZE;
  wire s01_couplers_to_s01_regslice_ARVALID;
  wire [31:0]s01_couplers_to_s01_regslice_AWADDR;
  wire [1:0]s01_couplers_to_s01_regslice_AWBURST;
  wire [3:0]s01_couplers_to_s01_regslice_AWCACHE;
  wire [7:0]s01_couplers_to_s01_regslice_AWLEN;
  wire [2:0]s01_couplers_to_s01_regslice_AWPROT;
  wire s01_couplers_to_s01_regslice_AWREADY;
  wire [2:0]s01_couplers_to_s01_regslice_AWSIZE;
  wire s01_couplers_to_s01_regslice_AWVALID;
  wire s01_couplers_to_s01_regslice_BREADY;
  wire [1:0]s01_couplers_to_s01_regslice_BRESP;
  wire s01_couplers_to_s01_regslice_BVALID;
  wire [31:0]s01_couplers_to_s01_regslice_RDATA;
  wire s01_couplers_to_s01_regslice_RLAST;
  wire s01_couplers_to_s01_regslice_RREADY;
  wire [1:0]s01_couplers_to_s01_regslice_RRESP;
  wire s01_couplers_to_s01_regslice_RVALID;
  wire [31:0]s01_couplers_to_s01_regslice_WDATA;
  wire s01_couplers_to_s01_regslice_WLAST;
  wire s01_couplers_to_s01_regslice_WREADY;
  wire [3:0]s01_couplers_to_s01_regslice_WSTRB;
  wire s01_couplers_to_s01_regslice_WVALID;
  wire [31:0]s01_regslice_to_auto_us_cc_df_ARADDR;
  wire [1:0]s01_regslice_to_auto_us_cc_df_ARBURST;
  wire [3:0]s01_regslice_to_auto_us_cc_df_ARCACHE;
  wire [7:0]s01_regslice_to_auto_us_cc_df_ARLEN;
  wire [0:0]s01_regslice_to_auto_us_cc_df_ARLOCK;
  wire [2:0]s01_regslice_to_auto_us_cc_df_ARPROT;
  wire [3:0]s01_regslice_to_auto_us_cc_df_ARQOS;
  wire s01_regslice_to_auto_us_cc_df_ARREADY;
  wire [3:0]s01_regslice_to_auto_us_cc_df_ARREGION;
  wire [2:0]s01_regslice_to_auto_us_cc_df_ARSIZE;
  wire s01_regslice_to_auto_us_cc_df_ARVALID;
  wire [31:0]s01_regslice_to_auto_us_cc_df_AWADDR;
  wire [1:0]s01_regslice_to_auto_us_cc_df_AWBURST;
  wire [3:0]s01_regslice_to_auto_us_cc_df_AWCACHE;
  wire [7:0]s01_regslice_to_auto_us_cc_df_AWLEN;
  wire [0:0]s01_regslice_to_auto_us_cc_df_AWLOCK;
  wire [2:0]s01_regslice_to_auto_us_cc_df_AWPROT;
  wire [3:0]s01_regslice_to_auto_us_cc_df_AWQOS;
  wire s01_regslice_to_auto_us_cc_df_AWREADY;
  wire [3:0]s01_regslice_to_auto_us_cc_df_AWREGION;
  wire [2:0]s01_regslice_to_auto_us_cc_df_AWSIZE;
  wire s01_regslice_to_auto_us_cc_df_AWVALID;
  wire s01_regslice_to_auto_us_cc_df_BREADY;
  wire [1:0]s01_regslice_to_auto_us_cc_df_BRESP;
  wire s01_regslice_to_auto_us_cc_df_BVALID;
  wire [31:0]s01_regslice_to_auto_us_cc_df_RDATA;
  wire s01_regslice_to_auto_us_cc_df_RLAST;
  wire s01_regslice_to_auto_us_cc_df_RREADY;
  wire [1:0]s01_regslice_to_auto_us_cc_df_RRESP;
  wire s01_regslice_to_auto_us_cc_df_RVALID;
  wire [31:0]s01_regslice_to_auto_us_cc_df_WDATA;
  wire s01_regslice_to_auto_us_cc_df_WLAST;
  wire s01_regslice_to_auto_us_cc_df_WREADY;
  wire [3:0]s01_regslice_to_auto_us_cc_df_WSTRB;
  wire s01_regslice_to_auto_us_cc_df_WVALID;

  assign M_ACLK_1 = M_ACLK;
  assign M_ARESETN_1 = M_ARESETN[0];
  assign M_AXI_araddr[31:0] = auto_us_cc_df_to_s01_couplers_ARADDR;
  assign M_AXI_arburst[1:0] = auto_us_cc_df_to_s01_couplers_ARBURST;
  assign M_AXI_arcache[3:0] = auto_us_cc_df_to_s01_couplers_ARCACHE;
  assign M_AXI_arlen[7:0] = auto_us_cc_df_to_s01_couplers_ARLEN;
  assign M_AXI_arlock[0] = auto_us_cc_df_to_s01_couplers_ARLOCK;
  assign M_AXI_arprot[2:0] = auto_us_cc_df_to_s01_couplers_ARPROT;
  assign M_AXI_arqos[3:0] = auto_us_cc_df_to_s01_couplers_ARQOS;
  assign M_AXI_arsize[2:0] = auto_us_cc_df_to_s01_couplers_ARSIZE;
  assign M_AXI_arvalid = auto_us_cc_df_to_s01_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = auto_us_cc_df_to_s01_couplers_AWADDR;
  assign M_AXI_awburst[1:0] = auto_us_cc_df_to_s01_couplers_AWBURST;
  assign M_AXI_awcache[3:0] = auto_us_cc_df_to_s01_couplers_AWCACHE;
  assign M_AXI_awlen[7:0] = auto_us_cc_df_to_s01_couplers_AWLEN;
  assign M_AXI_awlock[0] = auto_us_cc_df_to_s01_couplers_AWLOCK;
  assign M_AXI_awprot[2:0] = auto_us_cc_df_to_s01_couplers_AWPROT;
  assign M_AXI_awqos[3:0] = auto_us_cc_df_to_s01_couplers_AWQOS;
  assign M_AXI_awsize[2:0] = auto_us_cc_df_to_s01_couplers_AWSIZE;
  assign M_AXI_awvalid = auto_us_cc_df_to_s01_couplers_AWVALID;
  assign M_AXI_bready = auto_us_cc_df_to_s01_couplers_BREADY;
  assign M_AXI_rready = auto_us_cc_df_to_s01_couplers_RREADY;
  assign M_AXI_wdata[63:0] = auto_us_cc_df_to_s01_couplers_WDATA;
  assign M_AXI_wlast = auto_us_cc_df_to_s01_couplers_WLAST;
  assign M_AXI_wstrb[7:0] = auto_us_cc_df_to_s01_couplers_WSTRB;
  assign M_AXI_wvalid = auto_us_cc_df_to_s01_couplers_WVALID;
  assign S_ACLK_1 = S_ACLK;
  assign S_ARESETN_1 = S_ARESETN[0];
  assign S_AXI_arready = s01_couplers_to_s01_regslice_ARREADY;
  assign S_AXI_awready = s01_couplers_to_s01_regslice_AWREADY;
  assign S_AXI_bresp[1:0] = s01_couplers_to_s01_regslice_BRESP;
  assign S_AXI_bvalid = s01_couplers_to_s01_regslice_BVALID;
  assign S_AXI_rdata[31:0] = s01_couplers_to_s01_regslice_RDATA;
  assign S_AXI_rlast = s01_couplers_to_s01_regslice_RLAST;
  assign S_AXI_rresp[1:0] = s01_couplers_to_s01_regslice_RRESP;
  assign S_AXI_rvalid = s01_couplers_to_s01_regslice_RVALID;
  assign S_AXI_wready = s01_couplers_to_s01_regslice_WREADY;
  assign auto_us_cc_df_to_s01_couplers_ARREADY = M_AXI_arready;
  assign auto_us_cc_df_to_s01_couplers_AWREADY = M_AXI_awready;
  assign auto_us_cc_df_to_s01_couplers_BRESP = M_AXI_bresp[1:0];
  assign auto_us_cc_df_to_s01_couplers_BVALID = M_AXI_bvalid;
  assign auto_us_cc_df_to_s01_couplers_RDATA = M_AXI_rdata[63:0];
  assign auto_us_cc_df_to_s01_couplers_RLAST = M_AXI_rlast;
  assign auto_us_cc_df_to_s01_couplers_RRESP = M_AXI_rresp[1:0];
  assign auto_us_cc_df_to_s01_couplers_RVALID = M_AXI_rvalid;
  assign auto_us_cc_df_to_s01_couplers_WREADY = M_AXI_wready;
  assign s01_couplers_to_s01_regslice_ARADDR = S_AXI_araddr[31:0];
  assign s01_couplers_to_s01_regslice_ARBURST = S_AXI_arburst[1:0];
  assign s01_couplers_to_s01_regslice_ARCACHE = S_AXI_arcache[3:0];
  assign s01_couplers_to_s01_regslice_ARLEN = S_AXI_arlen[7:0];
  assign s01_couplers_to_s01_regslice_ARPROT = S_AXI_arprot[2:0];
  assign s01_couplers_to_s01_regslice_ARSIZE = S_AXI_arsize[2:0];
  assign s01_couplers_to_s01_regslice_ARVALID = S_AXI_arvalid;
  assign s01_couplers_to_s01_regslice_AWADDR = S_AXI_awaddr[31:0];
  assign s01_couplers_to_s01_regslice_AWBURST = S_AXI_awburst[1:0];
  assign s01_couplers_to_s01_regslice_AWCACHE = S_AXI_awcache[3:0];
  assign s01_couplers_to_s01_regslice_AWLEN = S_AXI_awlen[7:0];
  assign s01_couplers_to_s01_regslice_AWPROT = S_AXI_awprot[2:0];
  assign s01_couplers_to_s01_regslice_AWSIZE = S_AXI_awsize[2:0];
  assign s01_couplers_to_s01_regslice_AWVALID = S_AXI_awvalid;
  assign s01_couplers_to_s01_regslice_BREADY = S_AXI_bready;
  assign s01_couplers_to_s01_regslice_RREADY = S_AXI_rready;
  assign s01_couplers_to_s01_regslice_WDATA = S_AXI_wdata[31:0];
  assign s01_couplers_to_s01_regslice_WLAST = S_AXI_wlast;
  assign s01_couplers_to_s01_regslice_WSTRB = S_AXI_wstrb[3:0];
  assign s01_couplers_to_s01_regslice_WVALID = S_AXI_wvalid;
GND GND
       (.G(GND_1));
OpenSSD2_auto_us_cc_df_1 auto_us_cc_df
       (.m_axi_aclk(M_ACLK_1),
        .m_axi_araddr(auto_us_cc_df_to_s01_couplers_ARADDR),
        .m_axi_arburst(auto_us_cc_df_to_s01_couplers_ARBURST),
        .m_axi_arcache(auto_us_cc_df_to_s01_couplers_ARCACHE),
        .m_axi_aresetn(M_ARESETN_1),
        .m_axi_arlen(auto_us_cc_df_to_s01_couplers_ARLEN),
        .m_axi_arlock(auto_us_cc_df_to_s01_couplers_ARLOCK),
        .m_axi_arprot(auto_us_cc_df_to_s01_couplers_ARPROT),
        .m_axi_arqos(auto_us_cc_df_to_s01_couplers_ARQOS),
        .m_axi_arready(auto_us_cc_df_to_s01_couplers_ARREADY),
        .m_axi_arsize(auto_us_cc_df_to_s01_couplers_ARSIZE),
        .m_axi_arvalid(auto_us_cc_df_to_s01_couplers_ARVALID),
        .m_axi_awaddr(auto_us_cc_df_to_s01_couplers_AWADDR),
        .m_axi_awburst(auto_us_cc_df_to_s01_couplers_AWBURST),
        .m_axi_awcache(auto_us_cc_df_to_s01_couplers_AWCACHE),
        .m_axi_awlen(auto_us_cc_df_to_s01_couplers_AWLEN),
        .m_axi_awlock(auto_us_cc_df_to_s01_couplers_AWLOCK),
        .m_axi_awprot(auto_us_cc_df_to_s01_couplers_AWPROT),
        .m_axi_awqos(auto_us_cc_df_to_s01_couplers_AWQOS),
        .m_axi_awready(auto_us_cc_df_to_s01_couplers_AWREADY),
        .m_axi_awsize(auto_us_cc_df_to_s01_couplers_AWSIZE),
        .m_axi_awvalid(auto_us_cc_df_to_s01_couplers_AWVALID),
        .m_axi_bready(auto_us_cc_df_to_s01_couplers_BREADY),
        .m_axi_bresp(auto_us_cc_df_to_s01_couplers_BRESP),
        .m_axi_bvalid(auto_us_cc_df_to_s01_couplers_BVALID),
        .m_axi_rdata(auto_us_cc_df_to_s01_couplers_RDATA),
        .m_axi_rlast(auto_us_cc_df_to_s01_couplers_RLAST),
        .m_axi_rready(auto_us_cc_df_to_s01_couplers_RREADY),
        .m_axi_rresp(auto_us_cc_df_to_s01_couplers_RRESP),
        .m_axi_rvalid(auto_us_cc_df_to_s01_couplers_RVALID),
        .m_axi_wdata(auto_us_cc_df_to_s01_couplers_WDATA),
        .m_axi_wlast(auto_us_cc_df_to_s01_couplers_WLAST),
        .m_axi_wready(auto_us_cc_df_to_s01_couplers_WREADY),
        .m_axi_wstrb(auto_us_cc_df_to_s01_couplers_WSTRB),
        .m_axi_wvalid(auto_us_cc_df_to_s01_couplers_WVALID),
        .s_axi_aclk(S_ACLK_1),
        .s_axi_araddr(s01_regslice_to_auto_us_cc_df_ARADDR),
        .s_axi_arburst(s01_regslice_to_auto_us_cc_df_ARBURST),
        .s_axi_arcache(s01_regslice_to_auto_us_cc_df_ARCACHE),
        .s_axi_aresetn(S_ARESETN_1),
        .s_axi_arlen(s01_regslice_to_auto_us_cc_df_ARLEN),
        .s_axi_arlock(s01_regslice_to_auto_us_cc_df_ARLOCK),
        .s_axi_arprot(s01_regslice_to_auto_us_cc_df_ARPROT),
        .s_axi_arqos(s01_regslice_to_auto_us_cc_df_ARQOS),
        .s_axi_arready(s01_regslice_to_auto_us_cc_df_ARREADY),
        .s_axi_arregion(s01_regslice_to_auto_us_cc_df_ARREGION),
        .s_axi_arsize(s01_regslice_to_auto_us_cc_df_ARSIZE),
        .s_axi_arvalid(s01_regslice_to_auto_us_cc_df_ARVALID),
        .s_axi_awaddr(s01_regslice_to_auto_us_cc_df_AWADDR),
        .s_axi_awburst(s01_regslice_to_auto_us_cc_df_AWBURST),
        .s_axi_awcache(s01_regslice_to_auto_us_cc_df_AWCACHE),
        .s_axi_awlen(s01_regslice_to_auto_us_cc_df_AWLEN),
        .s_axi_awlock(s01_regslice_to_auto_us_cc_df_AWLOCK),
        .s_axi_awprot(s01_regslice_to_auto_us_cc_df_AWPROT),
        .s_axi_awqos(s01_regslice_to_auto_us_cc_df_AWQOS),
        .s_axi_awready(s01_regslice_to_auto_us_cc_df_AWREADY),
        .s_axi_awregion(s01_regslice_to_auto_us_cc_df_AWREGION),
        .s_axi_awsize(s01_regslice_to_auto_us_cc_df_AWSIZE),
        .s_axi_awvalid(s01_regslice_to_auto_us_cc_df_AWVALID),
        .s_axi_bready(s01_regslice_to_auto_us_cc_df_BREADY),
        .s_axi_bresp(s01_regslice_to_auto_us_cc_df_BRESP),
        .s_axi_bvalid(s01_regslice_to_auto_us_cc_df_BVALID),
        .s_axi_rdata(s01_regslice_to_auto_us_cc_df_RDATA),
        .s_axi_rlast(s01_regslice_to_auto_us_cc_df_RLAST),
        .s_axi_rready(s01_regslice_to_auto_us_cc_df_RREADY),
        .s_axi_rresp(s01_regslice_to_auto_us_cc_df_RRESP),
        .s_axi_rvalid(s01_regslice_to_auto_us_cc_df_RVALID),
        .s_axi_wdata(s01_regslice_to_auto_us_cc_df_WDATA),
        .s_axi_wlast(s01_regslice_to_auto_us_cc_df_WLAST),
        .s_axi_wready(s01_regslice_to_auto_us_cc_df_WREADY),
        .s_axi_wstrb(s01_regslice_to_auto_us_cc_df_WSTRB),
        .s_axi_wvalid(s01_regslice_to_auto_us_cc_df_WVALID));
OpenSSD2_s01_regslice_0 s01_regslice
       (.aclk(S_ACLK_1),
        .aresetn(S_ARESETN_1),
        .m_axi_araddr(s01_regslice_to_auto_us_cc_df_ARADDR),
        .m_axi_arburst(s01_regslice_to_auto_us_cc_df_ARBURST),
        .m_axi_arcache(s01_regslice_to_auto_us_cc_df_ARCACHE),
        .m_axi_arlen(s01_regslice_to_auto_us_cc_df_ARLEN),
        .m_axi_arlock(s01_regslice_to_auto_us_cc_df_ARLOCK),
        .m_axi_arprot(s01_regslice_to_auto_us_cc_df_ARPROT),
        .m_axi_arqos(s01_regslice_to_auto_us_cc_df_ARQOS),
        .m_axi_arready(s01_regslice_to_auto_us_cc_df_ARREADY),
        .m_axi_arregion(s01_regslice_to_auto_us_cc_df_ARREGION),
        .m_axi_arsize(s01_regslice_to_auto_us_cc_df_ARSIZE),
        .m_axi_arvalid(s01_regslice_to_auto_us_cc_df_ARVALID),
        .m_axi_awaddr(s01_regslice_to_auto_us_cc_df_AWADDR),
        .m_axi_awburst(s01_regslice_to_auto_us_cc_df_AWBURST),
        .m_axi_awcache(s01_regslice_to_auto_us_cc_df_AWCACHE),
        .m_axi_awlen(s01_regslice_to_auto_us_cc_df_AWLEN),
        .m_axi_awlock(s01_regslice_to_auto_us_cc_df_AWLOCK),
        .m_axi_awprot(s01_regslice_to_auto_us_cc_df_AWPROT),
        .m_axi_awqos(s01_regslice_to_auto_us_cc_df_AWQOS),
        .m_axi_awready(s01_regslice_to_auto_us_cc_df_AWREADY),
        .m_axi_awregion(s01_regslice_to_auto_us_cc_df_AWREGION),
        .m_axi_awsize(s01_regslice_to_auto_us_cc_df_AWSIZE),
        .m_axi_awvalid(s01_regslice_to_auto_us_cc_df_AWVALID),
        .m_axi_bready(s01_regslice_to_auto_us_cc_df_BREADY),
        .m_axi_bresp(s01_regslice_to_auto_us_cc_df_BRESP),
        .m_axi_bvalid(s01_regslice_to_auto_us_cc_df_BVALID),
        .m_axi_rdata(s01_regslice_to_auto_us_cc_df_RDATA),
        .m_axi_rlast(s01_regslice_to_auto_us_cc_df_RLAST),
        .m_axi_rready(s01_regslice_to_auto_us_cc_df_RREADY),
        .m_axi_rresp(s01_regslice_to_auto_us_cc_df_RRESP),
        .m_axi_rvalid(s01_regslice_to_auto_us_cc_df_RVALID),
        .m_axi_wdata(s01_regslice_to_auto_us_cc_df_WDATA),
        .m_axi_wlast(s01_regslice_to_auto_us_cc_df_WLAST),
        .m_axi_wready(s01_regslice_to_auto_us_cc_df_WREADY),
        .m_axi_wstrb(s01_regslice_to_auto_us_cc_df_WSTRB),
        .m_axi_wvalid(s01_regslice_to_auto_us_cc_df_WVALID),
        .s_axi_araddr(s01_couplers_to_s01_regslice_ARADDR),
        .s_axi_arburst(s01_couplers_to_s01_regslice_ARBURST),
        .s_axi_arcache(s01_couplers_to_s01_regslice_ARCACHE),
        .s_axi_arlen(s01_couplers_to_s01_regslice_ARLEN),
        .s_axi_arlock(GND_1),
        .s_axi_arprot(s01_couplers_to_s01_regslice_ARPROT),
        .s_axi_arqos({GND_1,GND_1,GND_1,GND_1}),
        .s_axi_arready(s01_couplers_to_s01_regslice_ARREADY),
        .s_axi_arregion({GND_1,GND_1,GND_1,GND_1}),
        .s_axi_arsize(s01_couplers_to_s01_regslice_ARSIZE),
        .s_axi_arvalid(s01_couplers_to_s01_regslice_ARVALID),
        .s_axi_awaddr(s01_couplers_to_s01_regslice_AWADDR),
        .s_axi_awburst(s01_couplers_to_s01_regslice_AWBURST),
        .s_axi_awcache(s01_couplers_to_s01_regslice_AWCACHE),
        .s_axi_awlen(s01_couplers_to_s01_regslice_AWLEN),
        .s_axi_awlock(GND_1),
        .s_axi_awprot(s01_couplers_to_s01_regslice_AWPROT),
        .s_axi_awqos({GND_1,GND_1,GND_1,GND_1}),
        .s_axi_awready(s01_couplers_to_s01_regslice_AWREADY),
        .s_axi_awregion({GND_1,GND_1,GND_1,GND_1}),
        .s_axi_awsize(s01_couplers_to_s01_regslice_AWSIZE),
        .s_axi_awvalid(s01_couplers_to_s01_regslice_AWVALID),
        .s_axi_bready(s01_couplers_to_s01_regslice_BREADY),
        .s_axi_bresp(s01_couplers_to_s01_regslice_BRESP),
        .s_axi_bvalid(s01_couplers_to_s01_regslice_BVALID),
        .s_axi_rdata(s01_couplers_to_s01_regslice_RDATA),
        .s_axi_rlast(s01_couplers_to_s01_regslice_RLAST),
        .s_axi_rready(s01_couplers_to_s01_regslice_RREADY),
        .s_axi_rresp(s01_couplers_to_s01_regslice_RRESP),
        .s_axi_rvalid(s01_couplers_to_s01_regslice_RVALID),
        .s_axi_wdata(s01_couplers_to_s01_regslice_WDATA),
        .s_axi_wlast(s01_couplers_to_s01_regslice_WLAST),
        .s_axi_wready(s01_couplers_to_s01_regslice_WREADY),
        .s_axi_wstrb(s01_couplers_to_s01_regslice_WSTRB),
        .s_axi_wvalid(s01_couplers_to_s01_regslice_WVALID));
endmodule

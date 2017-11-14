


`timescale 1ns / 1ps

module s_axi_nvme # (
	parameter C_S0_AXI_ADDR_WIDTH			= 32,
	parameter C_S0_AXI_DATA_WIDTH			= 32,
	parameter C_S0_AXI_BASEADDR				= 32'h83C00000,
	parameter C_S0_AXI_HIGHADDR				= 32'h83C0FFFF,

	parameter C_M0_AXI_ADDR_WIDTH			= 32,
	parameter C_M0_AXI_DATA_WIDTH			= 64,
	parameter C_M0_AXI_ID_WIDTH				= 1,
	parameter C_M0_AXI_AWUSER_WIDTH			= 1,
	parameter C_M0_AXI_WUSER_WIDTH			= 1,
	parameter C_M0_AXI_BUSER_WIDTH			= 1,
	parameter C_M0_AXI_ARUSER_WIDTH			= 1,
	parameter C_M0_AXI_RUSER_WIDTH			= 1
)
(
////////////////////////////////////////////////////////////////
//AXI4-lite slave interface signals
	input									s0_axi_aclk,
	input									s0_axi_aresetn,

//Write address channel
	input	[C_S0_AXI_ADDR_WIDTH-1 : 0]		s0_axi_awaddr,
	output									s0_axi_awready,
	input									s0_axi_awvalid,
	input	[2 : 0]							s0_axi_awprot,

//Write data channel
	input									s0_axi_wvalid,
	output									s0_axi_wready,
	input	[C_S0_AXI_DATA_WIDTH-1 : 0]		s0_axi_wdata,
	input	[(C_S0_AXI_DATA_WIDTH/8)-1 : 0]	s0_axi_wstrb,

//Write response channel
	output									s0_axi_bvalid,
	input									s0_axi_bready,
	output	[1 : 0]							s0_axi_bresp,

//Read address channel
	input									s0_axi_arvalid,
	output									s0_axi_arready,
	input	[C_S0_AXI_ADDR_WIDTH-1 : 0]		s0_axi_araddr,
	input	[2 : 0]							s0_axi_arprot,

//Read data channel
	output									s0_axi_rvalid,
	input									s0_axi_rready,
	output	[C_S0_AXI_DATA_WIDTH-1 : 0]		s0_axi_rdata,
	output	[1 : 0]							s0_axi_rresp,


////////////////////////////////////////////////////////////////
//AXI4 master interface signals
	input									m0_axi_aclk,
	input									m0_axi_aresetn,

// Write address channel
	output	[C_M0_AXI_ID_WIDTH-1:0]			m0_axi_awid,
	output	[C_M0_AXI_ADDR_WIDTH-1:0]		m0_axi_awaddr,
	output	[7:0]							m0_axi_awlen,
	output	[2:0]							m0_axi_awsize,
	output	[1:0]							m0_axi_awburst,
	output									m0_axi_awlock,
	output	[3:0]							m0_axi_awcache,
	output	[2:0]							m0_axi_awprot,
	output	[3:0]							m0_axi_awregion,
	output	[3:0]							m0_axi_awqos,
	output	[C_M0_AXI_AWUSER_WIDTH-1:0]		m0_axi_awuser,
	output									m0_axi_awvalid,
	input									m0_axi_awready,

// Write data channel
	output	[C_M0_AXI_ID_WIDTH-1:0]			m0_axi_wid,
	output	[C_M0_AXI_DATA_WIDTH-1:0]		m0_axi_wdata,
	output	[(C_M0_AXI_DATA_WIDTH/8)-1:0]	m0_axi_wstrb,
	output									m0_axi_wlast,
	output	[C_M0_AXI_WUSER_WIDTH-1:0]		m0_axi_wuser,
	output									m0_axi_wvalid,
	input									m0_axi_wready,

// Write response channel
	input	[C_M0_AXI_ID_WIDTH-1:0]			m0_axi_bid,
	input	[1:0]							m0_axi_bresp,
	input									m0_axi_bvalid,
	input	[C_M0_AXI_BUSER_WIDTH-1:0]		m0_axi_buser,
	output									m0_axi_bready,

// Read address channel
	output	[C_M0_AXI_ID_WIDTH-1:0]			m0_axi_arid,
	output	[C_M0_AXI_ADDR_WIDTH-1:0]		m0_axi_araddr,
	output	[7:0]							m0_axi_arlen,
	output	[2:0]							m0_axi_arsize,
	output	[1:0]							m0_axi_arburst,
	output									m0_axi_arlock,
	output	[3:0]							m0_axi_arcache,
	output	[2:0]							m0_axi_arprot,
	output	[3:0]							m0_axi_arregion,
	output	[3:0] 							m0_axi_arqos,
	output	[C_M0_AXI_ARUSER_WIDTH-1:0]		m0_axi_aruser,
	output									m0_axi_arvalid,
	input									m0_axi_arready,

// Read data channel
	input	[C_M0_AXI_ID_WIDTH-1:0]			m0_axi_rid,
	input	[C_M0_AXI_DATA_WIDTH-1:0]		m0_axi_rdata,
	input	[1:0]							m0_axi_rresp,
	input									m0_axi_rlast,
	input	[C_M0_AXI_RUSER_WIDTH-1:0]		m0_axi_ruser,
	input									m0_axi_rvalid,
	output 									m0_axi_rready,

	output									dev_irq_assert,

	input									pcie_ref_clk_p,
	input									pcie_ref_clk_n,
	input									pcie_perst_n,
	output	[3:0]							pcie_tx_p,
	output	[3:0]							pcie_tx_n,
	input	[3:0]							pcie_rx_p,
	input	[3:0]							pcie_rx_n


);

parameter	C_PCIE_DATA_WIDTH				= 128;


wire										user_clk_out;
wire										user_reset_out;
wire										user_lnk_up;

wire	[5:0]								tx_buf_av;
wire										tx_err_drop;
wire										tx_cfg_req;
wire										s_axis_tx_tready;
wire	[C_PCIE_DATA_WIDTH-1:0]				s_axis_tx_tdata;
wire	[(C_PCIE_DATA_WIDTH/8)-1:0]			s_axis_tx_tkeep;
wire	[3:0]								s_axis_tx_tuser;
wire										s_axis_tx_tlast;
wire										s_axis_tx_tvalid;
wire										tx_cfg_gnt;

wire	[C_PCIE_DATA_WIDTH-1:0]				m_axis_rx_tdata;
wire	[(C_PCIE_DATA_WIDTH/8)-1:0]			m_axis_rx_tkeep;
wire										m_axis_rx_tlast;
wire										m_axis_rx_tvalid;
wire										m_axis_rx_tready;
wire	[21:0]								m_axis_rx_tuser;
wire										rx_np_ok;
wire										rx_np_req;

wire	[11:0]								fc_cpld;
wire	[7:0]								fc_cplh;
wire	[11:0]								fc_npd;
wire	[7:0]								fc_nph;
wire	[11:0]								fc_pd;
wire	[7:0]								fc_ph;
wire	[2:0]								fc_sel;

wire	[7:0]								cfg_bus_number;
wire	[4:0]								cfg_device_number;
wire	[2:0]								cfg_function_number;

wire										cfg_interrupt;
wire										cfg_interrupt_rdy;
wire										cfg_interrupt_assert;
wire	[7:0]								cfg_interrupt_di;
wire	[7:0]								cfg_interrupt_do;
wire	[2:0]								cfg_interrupt_mmenable;
wire										cfg_interrupt_msienable;
wire										cfg_interrupt_msixenable;
wire										cfg_interrupt_msixfm;
wire										cfg_interrupt_stat;
wire	[4:0]								cfg_pciecap_interrupt_msgnum;

wire										cfg_to_turnoff;
wire										cfg_turnoff_ok;

wire	[15:0]								cfg_command;
wire	[15:0]								cfg_dcommand;
wire	[15:0]								cfg_lcommand;

wire	[5:0]								pl_ltssm_state;
wire										pl_received_hot_rst;
wire										sys_clk;
wire										sys_rst_n;

user_top # (
	.C_S0_AXI_ADDR_WIDTH					(C_S0_AXI_ADDR_WIDTH),
	.C_S0_AXI_DATA_WIDTH					(C_S0_AXI_DATA_WIDTH),
	.C_S0_AXI_BASEADDR						(C_S0_AXI_BASEADDR),
	.C_S0_AXI_HIGHADDR						(C_S0_AXI_HIGHADDR),

	.C_M0_AXI_ADDR_WIDTH					(C_M0_AXI_ADDR_WIDTH),
	.C_M0_AXI_DATA_WIDTH					(C_M0_AXI_DATA_WIDTH),
	.C_M0_AXI_ID_WIDTH						(C_M0_AXI_ID_WIDTH),
	.C_M0_AXI_AWUSER_WIDTH					(C_M0_AXI_AWUSER_WIDTH),
	.C_M0_AXI_WUSER_WIDTH					(C_M0_AXI_WUSER_WIDTH),
	.C_M0_AXI_BUSER_WIDTH					(C_M0_AXI_BUSER_WIDTH),
	.C_M0_AXI_ARUSER_WIDTH					(C_M0_AXI_ARUSER_WIDTH),
	.C_M0_AXI_RUSER_WIDTH					(C_M0_AXI_RUSER_WIDTH)
)
user_top_inst0 (

////////////////////////////////////////////////////////////////
//AXI4-lite slave interface signals
	.s0_axi_aclk							(s0_axi_aclk),
	.s0_axi_aresetn							(s0_axi_aresetn),

//Write address channel
	.s0_axi_awaddr							(s0_axi_awaddr),
	.s0_axi_awready							(s0_axi_awready),
	.s0_axi_awvalid							(s0_axi_awvalid),
	.s0_axi_awprot							(s0_axi_awprot),

//Write data channel
	.s0_axi_wvalid							(s0_axi_wvalid),
	.s0_axi_wready							(s0_axi_wready),
	.s0_axi_wdata							(s0_axi_wdata),
	.s0_axi_wstrb							(s0_axi_wstrb),

//Write response channel
	.s0_axi_bvalid							(s0_axi_bvalid),
	.s0_axi_bready							(s0_axi_bready),
	.s0_axi_bresp							(s0_axi_bresp),

//Read address channel
	.s0_axi_arvalid							(s0_axi_arvalid),
	.s0_axi_arready							(s0_axi_arready),
	.s0_axi_araddr							(s0_axi_araddr),
	.s0_axi_arprot							(s0_axi_arprot),

//Read data channel
	.s0_axi_rvalid							(s0_axi_rvalid),
	.s0_axi_rready							(s0_axi_rready),
	.s0_axi_rdata							(s0_axi_rdata),
	.s0_axi_rresp							(s0_axi_rresp),

////////////////////////////////////////////////////////////////
//AXI4 master interface signals
	.m0_axi_aclk							(m0_axi_aclk),
	.m0_axi_aresetn							(m0_axi_aresetn),

// Write address channel
	.m0_axi_awid							(m0_axi_awid),
	.m0_axi_awaddr							(m0_axi_awaddr),
	.m0_axi_awlen							(m0_axi_awlen),
	.m0_axi_awsize							(m0_axi_awsize),
	.m0_axi_awburst							(m0_axi_awburst),
	.m0_axi_awlock							(m0_axi_awlock),
	.m0_axi_awcache							(m0_axi_awcache),
	.m0_axi_awprot							(m0_axi_awprot),
	.m0_axi_awregion						(m0_axi_awregion),
	.m0_axi_awqos							(m0_axi_awqos),
	.m0_axi_awuser							(m0_axi_awuser),
	.m0_axi_awvalid							(m0_axi_awvalid),
	.m0_axi_awready							(m0_axi_awready),

// Write data channel
	.m0_axi_wid								(m0_axi_wid),
	.m0_axi_wdata							(m0_axi_wdata),
	.m0_axi_wstrb							(m0_axi_wstrb),
	.m0_axi_wlast							(m0_axi_wlast),
	.m0_axi_wuser							(m0_axi_wuser),
	.m0_axi_wvalid							(m0_axi_wvalid),
	.m0_axi_wready							(m0_axi_wready),

// Write response channel
	.m0_axi_bid								(m0_axi_bid),
	.m0_axi_bresp							(m0_axi_bresp),
	.m0_axi_bvalid							(m0_axi_bvalid),
	.m0_axi_buser							(m0_axi_buser),
	.m0_axi_bready							(m0_axi_bready),

// Read address channel
	.m0_axi_arid							(m0_axi_arid),
	.m0_axi_araddr							(m0_axi_araddr),
	.m0_axi_arlen							(m0_axi_arlen),
	.m0_axi_arsize							(m0_axi_arsize),
	.m0_axi_arburst							(m0_axi_arburst),
	.m0_axi_arlock							(m0_axi_arlock),
	.m0_axi_arcache							(m0_axi_arcache),
	.m0_axi_arprot							(m0_axi_arprot),
	.m0_axi_arregion						(m0_axi_arregion),
	.m0_axi_arqos							(m0_axi_arqos),
	.m0_axi_aruser							(m0_axi_aruser),
	.m0_axi_arvalid							(m0_axi_arvalid),
	.m0_axi_arready							(m0_axi_arready),

// Read data channel
	.m0_axi_rid								(m0_axi_rid),
	.m0_axi_rdata							(m0_axi_rdata),
	.m0_axi_rresp							(m0_axi_rresp),
	.m0_axi_rlast							(m0_axi_rlast),
	.m0_axi_ruser							(m0_axi_ruser),
	.m0_axi_rvalid							(m0_axi_rvalid),
	.m0_axi_rready							(m0_axi_rready),

	.dev_irq_assert							(dev_irq_assert),

	.pcie_ref_clk_p							(pcie_ref_clk_p),
	.pcie_ref_clk_n							(pcie_ref_clk_n),
	.pcie_perst_n							(pcie_perst_n),

	.user_clk_out							(user_clk_out),
	.user_reset_out							(user_reset_out),
	.user_lnk_up							(user_lnk_up),

	.tx_buf_av								(tx_buf_av),
	.tx_err_drop							(tx_err_drop),
	.tx_cfg_req								(tx_cfg_req),
	.s_axis_tx_tready						(s_axis_tx_tready),
	.s_axis_tx_tdata						(s_axis_tx_tdata),
	.s_axis_tx_tkeep						(s_axis_tx_tkeep),
	.s_axis_tx_tuser						(s_axis_tx_tuser),
	.s_axis_tx_tlast						(s_axis_tx_tlast),
	.s_axis_tx_tvalid						(s_axis_tx_tvalid),
	.tx_cfg_gnt								(tx_cfg_gnt),

	.m_axis_rx_tdata						(m_axis_rx_tdata),
	.m_axis_rx_tkeep						(m_axis_rx_tkeep),
	.m_axis_rx_tlast						(m_axis_rx_tlast),
	.m_axis_rx_tvalid						(m_axis_rx_tvalid),
	.m_axis_rx_tready						(m_axis_rx_tready),
	.m_axis_rx_tuser						(m_axis_rx_tuser),
	.rx_np_ok								(rx_np_ok),
	.rx_np_req								(rx_np_req),

	.fc_cpld								(fc_cpld),
	.fc_cplh								(fc_cplh),
	.fc_npd									(fc_npd),
	.fc_nph									(fc_nph),
	.fc_pd									(fc_pd),
	.fc_ph									(fc_ph),
	.fc_sel									(fc_sel),

	.cfg_bus_number							(cfg_bus_number),
	.cfg_device_number						(cfg_device_number),
	.cfg_function_number					(cfg_function_number),

	.cfg_interrupt							(cfg_interrupt),
	.cfg_interrupt_rdy						(cfg_interrupt_rdy),
	.cfg_interrupt_assert					(cfg_interrupt_assert),
	.cfg_interrupt_di						(cfg_interrupt_di),
	.cfg_interrupt_do						(cfg_interrupt_do),
	.cfg_interrupt_mmenable					(cfg_interrupt_mmenable),
	.cfg_interrupt_msienable				(cfg_interrupt_msienable),
	.cfg_interrupt_msixenable				(cfg_interrupt_msixenable),
	.cfg_interrupt_msixfm					(cfg_interrupt_msixfm),
	.cfg_interrupt_stat						(cfg_interrupt_stat),
	.cfg_pciecap_interrupt_msgnum			(cfg_pciecap_interrupt_msgnum),

	.cfg_to_turnoff							(cfg_to_turnoff),
	.cfg_turnoff_ok							(cfg_turnoff_ok),
	
	.cfg_command							(cfg_command),
	.cfg_dcommand							(cfg_dcommand),
	.cfg_lcommand							(cfg_lcommand),

	.pl_ltssm_state							(pl_ltssm_state),
	.pl_received_hot_rst					(pl_received_hot_rst),

	.sys_clk								(sys_clk),
	.sys_rst_n								(sys_rst_n)

);


pcie_7x_0_core_top 
pcie_7x_0_core_top_inst0(

  //----------------------------------------------------------------------------------------------------------------//
  // 1. PCI Express (pci_exp) Interface                                                                             //
  //----------------------------------------------------------------------------------------------------------------//

  // Tx
	.pci_exp_txn								(pcie_tx_n),
	.pci_exp_txp								(pcie_tx_p),

  // Rx
	.pci_exp_rxn								(pcie_rx_n),
	.pci_exp_rxp								(pcie_rx_p),

  //----------------------------------------------------------------------------------------------------------------//
  // 2. Clock & GT COMMON Sharing Interface                                                                         //
  //----------------------------------------------------------------------------------------------------------------//

  // Shared Logic Internal
	//.int_pclk_out_slave							(),
	//.int_pipe_rxusrclk_out						(),
	//.int_rxoutclk_out							(),
	//.int_dclk_out								(),
	//.int_userclk1_out							(),
	//.int_userclk2_out							(),
	//.int_oobclk_out								(),
	//.int_mmcm_lock_out							(),
	//.int_qplllock_out							(),
	//.int_qplloutclk_out							(),
	//.int_qplloutrefclk_out						(),
	//.int_pclk_sel_slave							(8'b0),

 // Shared Logic External  - Clocks
	//.pipe_pclk_in								(1'b0),
	//.pipe_rxusrclk_in							(1'b0),
	//.pipe_rxoutclk_in							(8'b0),
	//.pipe_dclk_in								(1'b0),
	//.pipe_userclk1_in							(1'b1),
	//.pipe_userclk2_in							(1'b0),
	//.pipe_oobclk_in								(1'b0),
	//.pipe_mmcm_lock_in							(1'b1),
    //
	//.pipe_txoutclk_out							(),
	//.pipe_rxoutclk_out							(),
	//.pipe_pclk_sel_out							(),
	//.pipe_gen3_out								(),

  // Shared Logic External - GT COMMON  

	//.qpll_drp_crscode							(12'b0),
	//.qpll_drp_fsm								(18'b0),
	//.qpll_drp_done								(2'b0),
	//.qpll_drp_reset								(2'b0),
	//.qpll_qplllock								(2'b0),
	//.qpll_qplloutclk							(2'b0),
	//.qpll_qplloutrefclk							(2'b0),
	//.qpll_qplld									(),
	//.qpll_qpllreset								(),
	//.qpll_drp_clk								(),
	//.qpll_drp_rst_n								(),
	//.qpll_drp_ovrd								(),
	//.qpll_drp_gen3								(),
	//.qpll_drp_start								(),

  //----------------------------------------------------------------------------------------------------------------//
  // 3. AXI-S Interface                                                                                             //
  //----------------------------------------------------------------------------------------------------------------//

  // Common
	.user_clk_out								(user_clk_out),
	.user_reset_out								(user_reset_out),
	.user_lnk_up								(user_lnk_up),
	.user_app_rdy								(),

  // AXI TX
  //-----------
	.tx_buf_av									(tx_buf_av),
	.tx_err_drop								(tx_err_drop),
	.tx_cfg_req									(tx_cfg_req),
	.s_axis_tx_tready							(s_axis_tx_tready),
	.s_axis_tx_tdata							(s_axis_tx_tdata),
	.s_axis_tx_tkeep							(s_axis_tx_tkeep),
	.s_axis_tx_tuser							(s_axis_tx_tuser),
	.s_axis_tx_tlast							(s_axis_tx_tlast),
	.s_axis_tx_tvalid							(s_axis_tx_tvalid),
	.tx_cfg_gnt									(tx_cfg_gnt),

  // AXI RX
  //-----------
	.m_axis_rx_tdata							(m_axis_rx_tdata),
	.m_axis_rx_tkeep							(m_axis_rx_tkeep),
	.m_axis_rx_tlast							(m_axis_rx_tlast),
	.m_axis_rx_tvalid							(m_axis_rx_tvalid),
	.m_axis_rx_tready							(m_axis_rx_tready),
	.m_axis_rx_tuser							(m_axis_rx_tuser),
	.rx_np_ok									(rx_np_ok),
	.rx_np_req									(rx_np_req),

  // Flow Control
	.fc_cpld									(fc_cpld),
	.fc_cplh									(fc_cplh),
	.fc_npd										(fc_npd),
	.fc_nph										(fc_nph),
	.fc_pd										(fc_pd),
	.fc_ph										(fc_ph),
	.fc_sel										(fc_sel),


  //----------------------------------------------------------------------------------------------------------------//
  // 4. Configuration (CFG) Interface                                                                               //
  //----------------------------------------------------------------------------------------------------------------//

  //------------------------------------------------//
  // EP and RP                                      //
  //------------------------------------------------//
	.cfg_mgmt_do									(),
	.cfg_mgmt_rd_wr_done							(),

	.cfg_status										(),
	.cfg_command									(cfg_command),
	.cfg_dstatus									(),
	.cfg_dcommand									(cfg_dcommand),
	.cfg_lstatus									(),
	.cfg_lcommand									(cfg_lcommand),
	.cfg_dcommand2									(),
	.cfg_pcie_link_state							(),

	.cfg_pmcsr_pme_en								(),
	.cfg_pmcsr_powerstate							(),
	.cfg_pmcsr_pme_status							(),
	.cfg_received_func_lvl_rst						(),

  // Management Interface
	.cfg_mgmt_di									(32'b0),
	.cfg_mgmt_byte_en								(4'b0),
	.cfg_mgmt_dwaddr								(10'b0),
	.cfg_mgmt_wr_en									(1'b0),
	.cfg_mgmt_rd_en									(1'b0),
	.cfg_mgmt_wr_readonly							(1'b0),

  // Error Reporting Interface
	.cfg_err_ecrc									(1'b0),
	.cfg_err_ur										(1'b0),
	.cfg_err_cpl_timeout							(1'b0),
	.cfg_err_cpl_unexpect							(1'b0),
	.cfg_err_cpl_abort								(1'b0),
	.cfg_err_posted									(1'b0),
	.cfg_err_cor									(1'b0),
	.cfg_err_atomic_egress_blocked					(1'b0),
	.cfg_err_internal_cor							(1'b0),
	.cfg_err_malformed								(1'b0),
	.cfg_err_mc_blocked								(1'b0),
	.cfg_err_poisoned								(1'b0),
	.cfg_err_norecovery								(1'b0),
	.cfg_err_tlp_cpl_header							(48'b0),
	.cfg_err_cpl_rdy								(),
	.cfg_err_locked									(1'b0),
	.cfg_err_acs									(1'b0),
	.cfg_err_internal_uncor							(1'b0),

	.cfg_trn_pending								(1'b0),
	.cfg_pm_halt_aspm_l0s							(1'b0),
	.cfg_pm_halt_aspm_l1							(1'b0),
	.cfg_pm_force_state_en							(1'b0),
	.cfg_pm_force_state								(2'b0),

	.cfg_dsn										(64'b0),
	.cfg_msg_received								(),
	.cfg_msg_data									(),

  //------------------------------------------------//
  // EP Only                                        //
  //------------------------------------------------//

  // Interrupt Interface Signals
	.cfg_interrupt									(cfg_interrupt),
	.cfg_interrupt_rdy								(cfg_interrupt_rdy),
	.cfg_interrupt_assert							(cfg_interrupt_assert),
	.cfg_interrupt_di								(cfg_interrupt_di),
	.cfg_interrupt_do								(cfg_interrupt_do),
	.cfg_interrupt_mmenable							(cfg_interrupt_mmenable),
	.cfg_interrupt_msienable						(cfg_interrupt_msienable),
	.cfg_interrupt_msixenable						(cfg_interrupt_msixenable),
	.cfg_interrupt_msixfm							(cfg_interrupt_msixfm),
	.cfg_interrupt_stat								(cfg_interrupt_stat),
	.cfg_pciecap_interrupt_msgnum					(cfg_pciecap_interrupt_msgnum),

	.cfg_to_turnoff									(cfg_to_turnoff),
	.cfg_turnoff_ok									(cfg_turnoff_ok),
	.cfg_bus_number									(cfg_bus_number),
	.cfg_device_number								(cfg_device_number),
	.cfg_function_number							(cfg_function_number),
	.cfg_pm_wake									(1'b0),

	.cfg_msg_received_pm_as_nak						(),
	.cfg_msg_received_setslotpowerlimit				(),

  //------------------------------------------------//
  // RP Only                                        //
  //------------------------------------------------//
	.cfg_pm_send_pme_to								(1'b0),
	.cfg_ds_bus_number								(8'b0),
	.cfg_ds_device_number							(5'b0),
	.cfg_ds_function_number							(3'b0),
	.cfg_mgmt_wr_rw1c_as_rw							(1'b0),

	.cfg_bridge_serr_en								(),
	.cfg_slot_control_electromech_il_ctl_pulse		(),
	.cfg_root_control_syserr_corr_err_en			(),
	.cfg_root_control_syserr_non_fatal_err_en		(),
	.cfg_root_control_syserr_fatal_err_en			(),
	.cfg_root_control_pme_int_en					(),
	.cfg_aer_rooterr_corr_err_reporting_en			(),
	.cfg_aer_rooterr_non_fatal_err_reporting_en		(),
	.cfg_aer_rooterr_fatal_err_reporting_en			(),
	.cfg_aer_rooterr_corr_err_received				(),
	.cfg_aer_rooterr_non_fatal_err_received			(),
	.cfg_aer_rooterr_fatal_err_received				(),

	.cfg_msg_received_err_cor						(),
	.cfg_msg_received_err_non_fatal					(),
	.cfg_msg_received_err_fatal						(),
	.cfg_msg_received_pm_pme						(),
	.cfg_msg_received_pme_to_ack					(),
	.cfg_msg_received_assert_int_a					(),
	.cfg_msg_received_assert_int_b					(),
	.cfg_msg_received_assert_int_c					(),
	.cfg_msg_received_assert_int_d					(),
	.cfg_msg_received_deassert_int_a				(),
	.cfg_msg_received_deassert_int_b				(),
	.cfg_msg_received_deassert_int_c				(),
	.cfg_msg_received_deassert_int_d				(),

  //----------------------------------------------------------------------------------------------------------------//
  // 5. Physical Layer Control and Status (PL) Interface                                                            //
  //----------------------------------------------------------------------------------------------------------------//

  //------------------------------------------------//
  // EP and RP                                      //
  //------------------------------------------------//
	.pl_directed_link_change						(2'b00),
	.pl_directed_link_width							(2'b00),
	.pl_directed_link_speed							(1'b0),
	.pl_directed_link_auton							(1'b0),
	.pl_upstream_prefer_deemph						(1'b0),

	.pl_sel_lnk_rate								(),
	.pl_sel_lnk_width								(),
	.pl_ltssm_state									(pl_ltssm_state),
	.pl_lane_reversal_mode							(),

	.pl_phy_lnk_up									(),
	.pl_tx_pm_state									(),
	.pl_rx_pm_state									(),

	.pl_link_upcfg_cap								(),
	.pl_link_gen2_cap								(),
	.pl_link_partner_gen2_supported					(),
	.pl_initial_link_width							(),

	.pl_directed_change_done						(),

  //------------------------------------------------//
  // EP Only                                        //
  //------------------------------------------------//
	.pl_received_hot_rst							(pl_received_hot_rst),

  //------------------------------------------------//
  // RP Only                                        //
  //------------------------------------------------//
	.pl_transmit_hot_rst							(1'b0),
	.pl_downstream_deemph_source					(1'b0),

  //----------------------------------------------------------------------------------------------------------------//
  // 6. AER interface                                                                                               //
  //----------------------------------------------------------------------------------------------------------------//

	.cfg_err_aer_headerlog							(128'b0),
	.cfg_aer_interrupt_msgnum						(5'b0),
	.cfg_err_aer_headerlog_set						(),
	.cfg_aer_ecrc_check_en							(),
	.cfg_aer_ecrc_gen_en							(),

  //----------------------------------------------------------------------------------------------------------------//
  // 7. VC interface                                                                                                //
  //----------------------------------------------------------------------------------------------------------------//

	.cfg_vc_tcvc_map								(),

  //----------------------------------------------------------------------------------------------------------------//
  // PCIe Fast Config: ICAP primitive Interface                                                                     //
  //----------------------------------------------------------------------------------------------------------------//

	//.icap_clk										(1'b0),
	//.icap_csib										(1'b0),
	//.icap_rdwrb										(1'b0),
	//.icap_i											(32'b0),
	//.icap_o											(),
    //
	//.pipe_txprbssel									(3'b0),
	//.pipe_rxprbssel									(3'b0),
	//.pipe_txprbsforceerr							(1'b0),
	//.pipe_rxprbscntreset							(1'b0),
	//.pipe_loopback									(3'b0),
    //
	//.pipe_rxprbserr									(),
    //
	//.pipe_rst_fsm									(),
	//.pipe_qrst_fsm									(),
	//.pipe_rate_fsm									(),
	//.pipe_sync_fsm_tx								(),
	//.pipe_sync_fsm_rx								(),
	//.pipe_drp_fsm									(),
    //
	//.pipe_rst_idle									(),
	//.pipe_qrst_idle									(),
	//.pipe_rate_idle									(),
	//.pipe_eyescandataerror							(),
	//.pipe_rxstatus									(),
	//.pipe_dmonitorout								(),
    //
	//.pipe_cpll_lock									(),
	//.pipe_qpll_lock									(),
	//.pipe_rxpmaresetdone							(),
	//.pipe_rxbufstatus								(),
	//.pipe_txphaligndone								(),
	//.pipe_txphinitdone								(),
	//.pipe_txdlysresetdone							(),
	//.pipe_rxphaligndone								(),
	//.pipe_rxdlysresetdone							(),
	//.pipe_rxsyncdone								(),
	//.pipe_rxdisperr									(),
	//.pipe_rxnotintable								(),
	//.pipe_rxcommadet								(),
    //
	//.gt_ch_drp_rdy									(),
	//.pipe_debug_0									(),
	//.pipe_debug_1									(),
	//.pipe_debug_2									(),
	//.pipe_debug_3									(),
	//.pipe_debug_4									(),
	//.pipe_debug_5									(),
	//.pipe_debug_6									(),
	//.pipe_debug_7									(),
	//.pipe_debug_8									(),
	//.pipe_debug_9									(),
	//.pipe_debug										(),

  //--------------Channel DRP---------------------------------
	//.ext_ch_gt_drpclk								(),
	//.ext_ch_gt_drpaddr								(72'b0),
	//.ext_ch_gt_drpen								(8'b0),
	//.ext_ch_gt_drpdi								(128'b0),
	//.ext_ch_gt_drpwe								(8'b0),
    //
	//.ext_ch_gt_drpdo								(),
	//.ext_ch_gt_drprdy								(),


  //----------------------------------------------------------------------------------------------------------------//
  // PCIe Fast Config: STARTUP primitive Interface                                                                  //
  //----------------------------------------------------------------------------------------------------------------//

  // This input should be used when the startup block is generated exteranl to the PCI Express Core
	//.startup_eos_in									(1'b0),		// 1-bit input: This signal should be driven by the EOS output of the STARTUP primitive.
  // These inputs and outputs may be use when the startup block is generated internal to the PCI Express Core.
	//.startup_cfgclk									(),		// 1-bit output: Configuration main clock output
	//.startup_cfgmclk								(),		// 1-bit output: Configuration internal oscillator clock output
	//.startup_eos									(),		// 1-bit output: Active high output signal indicating the End Of Startup
	//.startup_preq									(),		// 1-bit output: PROGRAM request to fabric output
	//.startup_clk									(1'b0),		// 1-bit input: User start-up clock input
	//.startup_gsr									(1'b0),		// 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
	//.startup_gts									(1'b0),		// 1-bit input: Global 3-state input (GTS cannot be used for the port name)
	//.startup_keyclearb								(1'b1),		// 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
	//.startup_pack									(1'b0),		// 1-bit input: PROGRAM acknowledge input
	//.startup_usrcclko								(1'b1),		// 1-bit input: User CCLK input
	//.startup_usrcclkts								(1'b0),		// 1-bit input: User CCLK 3-state enable input
	//.startup_usrdoneo								(1'b0),		// 1-bit input: User DONE pin output control
	//.startup_usrdonets								(1'b1),		// 1-bit input: User DONE 3-state enable output 

  //----------------------------------------------------------------------------------------------------------------//
  // 8. PCIe DRP (PCIe DRP) Interface                                                                               //
  //----------------------------------------------------------------------------------------------------------------//

	//.pcie_drp_clk									(1'b1),
	//.pcie_drp_en									(1'b0),
	//.pcie_drp_we									(1'b0),
	//.pcie_drp_addr									(9'b0),
	//.pcie_drp_di									(16'b0),
	//.pcie_drp_rdy									(),
	//.pcie_drp_do									(),
  //----------------------------------------------------------------------------------------------------------------//
  // PIPE PORTS to TOP Level For PIPE SIMULATION with 3rd Party IP/BFM/Xilinx BFM
  //----------------------------------------------------------------------------------------------------------------//
	//.common_commands_in								(4'b0),
	//.pipe_rx_0_sigs									(25'b0),
	//.pipe_rx_1_sigs									(25'b0),
	//.pipe_rx_2_sigs									(25'b0),
	//.pipe_rx_3_sigs									(25'b0),
	//.pipe_rx_4_sigs									(25'b0),
	//.pipe_rx_5_sigs									(25'b0),
	//.pipe_rx_6_sigs									(25'b0),
	//.pipe_rx_7_sigs									(25'b0),
    //
	//.common_commands_out							(),
	//.pipe_tx_0_sigs									(),
	//.pipe_tx_1_sigs									(),
	//.pipe_tx_2_sigs									(),
	//.pipe_tx_3_sigs									(),
	//.pipe_tx_4_sigs									(),
	//.pipe_tx_5_sigs									(),
	//.pipe_tx_6_sigs									(),
	//.pipe_tx_7_sigs									(),
  //----------------------------------------------------------------------------------------------------------------//
  // 9. System(SYS) Interface                                                                                       //
  //----------------------------------------------------------------------------------------------------------------//

	//.pipe_mmcm_rst_n								(1'b1),		// Async      | Async
	.sys_clk										(sys_clk),
	.sys_rst_n										(pcie_perst_n)
);


endmodule
###############################################################################################################
# Core-Level Timing Constraints for axi_dwidth_converter Component "OpenSSD2_auto_us_cc_df_0"
###############################################################################################################
#
# This component is configured to perform asynchronous clock-domain-crossing.
# In order for these core-level constraints to work properly, 
# the following rules apply to your system-level timing constraints:
#   1. Each of the nets connected to the s_axi_aclk and m_axi_aclk ports of this component
#      must have exactly one clock defined on it, using either
#      a) a create_clock command on a top-level clock pin specified in your system XDC file, or
#      b) a create_generated_clock command, typically generated automatically by a core 
#          producing a derived clock signal.
#   2. The s_axi_aclk and m_axi_aclk ports of this component should not be connected to the
#      same clock source.
#
set s_clk [get_clocks -of_objects [get_ports s_axi_aclk]]
set m_clk [get_clocks -of_objects [get_ports m_axi_aclk]]
set_false_path -through [get_nets -hierarchical -filter {NAME =~ *aresetn*}] -to [filter [get_cells -hierarchical -filter {(NAME =~ */rstblk/*) && ((NAME =~ *dw_fifogen_b_async*) || (NAME =~ *dw_fifogen_ar*) || (NAME =~ *dw_fifogen_rresp*) || (NAME =~ *dw_fifogen_aw*) || (NAME =~ *dw_fifogen_awpop*))}] {IS_SEQUENTIAL}]
set_max_delay -from [filter [all_fanout -from [get_ports s_axi_aclk] -flat -endpoints_only] {IS_LEAF && (NAME =~ *dw_fifogen*)}] -to [filter [all_fanout -from [get_ports m_axi_aclk] -flat -only_cells] {IS_SEQUENTIAL && (NAME =~ *dw_fifogen*) && (NAME !~ *dout_i_reg[*])}] -datapath_only [get_property -min PERIOD $s_clk]
set_max_delay -from [filter [all_fanout -from [get_ports m_axi_aclk] -flat -endpoints_only] {IS_LEAF && (NAME =~ *dw_fifogen*)}] -to [filter [all_fanout -from [get_ports s_axi_aclk] -flat -only_cells] {IS_SEQUENTIAL && (NAME =~ *dw_fifogen*) && (NAME !~ *dout_i_reg[*])}] -datapath_only [get_property -min PERIOD $m_clk]
set_disable_timing -from CLK -to O [filter [all_fanout -from [get_ports s_axi_aclk] -flat -endpoints_only -only_cells] {PRIMITIVE_SUBGROUP==dram || PRIMITIVE_SUBGROUP==LUTRAM}]
set_disable_timing -from CLK -to O [filter [all_fanout -from [get_ports m_axi_aclk] -flat -endpoints_only -only_cells] {PRIMITIVE_SUBGROUP==dram || PRIMITIVE_SUBGROUP==LUTRAM}]

##################################################################################
## constr_nvme for Cosmos OpenSSD
## Copyright (c) 2015 Hanyang University ENC Lab.
## Contributed by Kibin Park <kbpark@enc.hanyang.ac.kr>
##                Yong Ho Song <yhsong@enc.hanyang.ac.kr>
##
## This file is part of Cosmos OpenSSD.
##
## Cosmos OpenSSD is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3, or (at your option)
## any later version.
##
## Cosmos OpenSSD is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
## See the GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Cosmos OpenSSD; see the file COPYING.
## If not, see <http://www.gnu.org/licenses/>. 
##################################################################################

##################################################################################
## Company: ENC Lab. <http://enc.hanyang.ac.kr>
## Engineer: Kibin Park <kbpark@enc.hanyang.ac.kr>
## 
## Project Name: Cosmos OpenSSD
## Design Name: constr_nvme
## File Name: constr_nvme.xdc
##
## Version: v1.0.0
##
## Description: pinmaps for NVMe controller
##
##################################################################################

##################################################################################
## Revision History:
##
## * v1.0.0
##   - first draft 
##################################################################################

# PCIe
# (begin)
create_clock -period 10.00000000000000000 -name PCIe_RefClock_100MHz -waveform {0.00000000000000000 5.00000000000000000} [get_ports pcie_ref_clk_p]

set_false_path -through [get_ports pcie_perst_n]

set_false_path -from [get_clocks *userclk2] -to [get_clocks clk_fpga_0]
set_false_path -from [get_clocks clk_fpga_2] -to [get_clocks *userclk2]
set_false_path -from [get_clocks *userclk2] -to [get_clocks clk_fpga_2]
set_false_path -from [get_clocks clk_fpga_3] -to [get_clocks *userclk2]
set_false_path -from [get_clocks *userclk2] -to [get_clocks clk_fpga_3]
set_false_path -from [get_clocks clk_125mhz_mux_x0y0] -to [get_clocks clk_fpga_2]
set_false_path -from [get_clocks clk_fpga_2] -to [get_clocks clk_125mhz_mux_x0y0]
set_false_path -from [get_clocks clk_250mhz_mux_x0y0] -to [get_clocks clk_fpga_2]
set_false_path -from [get_clocks clk_fpga_2] -to [get_clocks clk_250mhz_mux_x0y0]
set_false_path -from [get_clocks clk_fpga_3] -to [get_clocks clk_fpga_2]
set_false_path -from [get_clocks clk_fpga_2] -to [get_clocks clk_fpga_3]
## (end)

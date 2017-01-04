##################################################################################
## pinmap_others for Cosmos OpenSSD
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
## Design Name: pinmap_others
## File Name: pinmap_others.xdc
##
## Version: v1.0.0
##
## Description: pinmaps for PCIe and debug pins
##
##################################################################################

##################################################################################
## Revision History:
##
## * v1.0.0
##   - first draft 
##################################################################################

set_property PACKAGE_PIN N8 [get_ports {pcie_ref_clk_p}]
set_property PACKAGE_PIN N7 [get_ports {pcie_ref_clk_n}]

set_property IOSTANDARD LVCMOS33 [get_ports {pcie_perst_n}]
set_property PACKAGE_PIN AB16 [get_ports {pcie_perst_n}]
set_property PULLDOWN TRUE [get_ports {pcie_perst_n}]

set_property PACKAGE_PIN P6  [get_ports {pcie_rx_p[0]}]
set_property PACKAGE_PIN T6  [get_ports {pcie_rx_p[1]}]
set_property PACKAGE_PIN U4  [get_ports {pcie_rx_p[2]}]
set_property PACKAGE_PIN V6  [get_ports {pcie_rx_p[3]}]
set_property PACKAGE_PIN AA4 [get_ports {pcie_rx_p[4]}]
set_property PACKAGE_PIN Y6  [get_ports {pcie_rx_p[5]}]
set_property PACKAGE_PIN AB6 [get_ports {pcie_rx_p[6]}]
set_property PACKAGE_PIN AC4 [get_ports {pcie_rx_p[7]}]

set_property PACKAGE_PIN P5  [get_ports {pcie_rx_n[0]}]
set_property PACKAGE_PIN T5  [get_ports {pcie_rx_n[1]}]
set_property PACKAGE_PIN U3  [get_ports {pcie_rx_n[2]}]
set_property PACKAGE_PIN V5  [get_ports {pcie_rx_n[3]}]
set_property PACKAGE_PIN AA3 [get_ports {pcie_rx_n[4]}]
set_property PACKAGE_PIN Y5  [get_ports {pcie_rx_n[5]}]
set_property PACKAGE_PIN AB5 [get_ports {pcie_rx_n[6]}]
set_property PACKAGE_PIN AC3 [get_ports {pcie_rx_n[7]}]

set_property PACKAGE_PIN N4  [get_ports {pcie_tx_p[0]}]
set_property PACKAGE_PIN P2  [get_ports {pcie_tx_p[1]}]
set_property PACKAGE_PIN R4  [get_ports {pcie_tx_p[2]}]
set_property PACKAGE_PIN T2  [get_ports {pcie_tx_p[3]}]
set_property PACKAGE_PIN V2  [get_ports {pcie_tx_p[4]}]
set_property PACKAGE_PIN W4  [get_ports {pcie_tx_p[5]}]
set_property PACKAGE_PIN Y2  [get_ports {pcie_tx_p[6]}]
set_property PACKAGE_PIN AB2 [get_ports {pcie_tx_p[7]}]

set_property PACKAGE_PIN N3  [get_ports {pcie_tx_n[0]}]
set_property PACKAGE_PIN P1  [get_ports {pcie_tx_n[1]}]
set_property PACKAGE_PIN R3  [get_ports {pcie_tx_n[2]}]
set_property PACKAGE_PIN T1  [get_ports {pcie_tx_n[3]}]
set_property PACKAGE_PIN V1  [get_ports {pcie_tx_n[4]}]
set_property PACKAGE_PIN W3  [get_ports {pcie_tx_n[5]}]
set_property PACKAGE_PIN Y1  [get_ports {pcie_tx_n[6]}]
set_property PACKAGE_PIN AB1 [get_ports {pcie_tx_n[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[0]}]
set_property PACKAGE_PIN AJ13 [get_ports {O_DEBUG[0]}]
set_property SLEW FAST [get_ports {O_DEBUG[0]}]
#set_property drive "8" [get_ports "O_DEBUG[0]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[1]}]
set_property PACKAGE_PIN AJ16 [get_ports {O_DEBUG[1]}]
set_property SLEW FAST [get_ports {O_DEBUG[1]}]
#set_property drive "8" [get_ports "O_DEBUG[1]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[1]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[2]}]
set_property PACKAGE_PIN AJ15 [get_ports {O_DEBUG[2]}]
set_property SLEW FAST [get_ports {O_DEBUG[2]}]
#set_property drive "8" [get_ports "O_DEBUG[2]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[2]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[3]}]
set_property PACKAGE_PIN AK16 [get_ports {O_DEBUG[3]}]
set_property SLEW FAST [get_ports {O_DEBUG[3]}]
#set_property drive "8" [get_ports "O_DEBUG[3]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[4]}]
set_property PACKAGE_PIN AK15 [get_ports {O_DEBUG[4]}]
set_property SLEW FAST [get_ports {O_DEBUG[4]}]
#set_property drive "8" [get_ports "O_DEBUG[4]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[4]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[5]}]
set_property PACKAGE_PIN AH17 [get_ports {O_DEBUG[5]}]
set_property SLEW FAST [get_ports {O_DEBUG[5]}]
#set_property drive "8" [get_ports "O_DEBUG[5]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[5]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[6]}]
set_property PACKAGE_PIN AH16 [get_ports {O_DEBUG[6]}]
set_property SLEW FAST [get_ports {O_DEBUG[6]}]
#set_property drive "8" [get_ports "O_DEBUG[6]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[6]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[7]}]
set_property PACKAGE_PIN AE12 [get_ports {O_DEBUG[7]}]
set_property SLEW FAST [get_ports {O_DEBUG[7]}]
#set_property drive "8" [get_ports "O_DEBUG[7]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[8]}]
set_property PACKAGE_PIN AF12 [get_ports {O_DEBUG[8]}]
set_property SLEW FAST [get_ports {O_DEBUG[8]}]
#set_property drive "8" [get_ports "O_DEBUG[8]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[8]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[9]}]
set_property PACKAGE_PIN AH14 [get_ports {O_DEBUG[9]}]
set_property SLEW FAST [get_ports {O_DEBUG[9]}]
#set_property drive "8" [get_ports "O_DEBUG[9]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[9]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[10]}]
set_property PACKAGE_PIN AH13 [get_ports {O_DEBUG[10]}]
set_property SLEW FAST [get_ports {O_DEBUG[10]}]
#set_property drive "8" [get_ports "O_DEBUG[10]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[10]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[11]}]
set_property PACKAGE_PIN AD14 [get_ports {O_DEBUG[11]}]
set_property SLEW FAST [get_ports {O_DEBUG[11]}]
#set_property drive "8" [get_ports "O_DEBUG[11]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[11]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[12]}]
set_property PACKAGE_PIN AD13 [get_ports {O_DEBUG[12]}]
set_property SLEW FAST [get_ports {O_DEBUG[12]}]
#set_property drive "8" [get_ports "O_DEBUG[12]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[12]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[13]}]
set_property PACKAGE_PIN AE13 [get_ports {O_DEBUG[13]}]
set_property SLEW FAST [get_ports {O_DEBUG[13]}]
#set_property drive "8" [get_ports "O_DEBUG[13]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[13]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[14]}]
set_property PACKAGE_PIN AF13 [get_ports {O_DEBUG[14]}]
set_property SLEW FAST [get_ports {O_DEBUG[14]}]
#set_property drive "8" [get_ports "O_DEBUG[14]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[14]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[15]}]
set_property PACKAGE_PIN AF15 [get_ports {O_DEBUG[15]}]
set_property SLEW FAST [get_ports {O_DEBUG[15]}]
#set_property drive "8" [get_ports "O_DEBUG[15]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[15]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[16]}]
set_property PACKAGE_PIN AG15 [get_ports {O_DEBUG[16]}]
set_property SLEW FAST [get_ports {O_DEBUG[16]}]
#set_property drive "8" [get_ports "O_DEBUG[16]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[16]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[17]}]
set_property PACKAGE_PIN AF18 [get_ports {O_DEBUG[17]}]
set_property SLEW FAST [get_ports {O_DEBUG[17]}]
#set_property drive "8" [get_ports "O_DEBUG[17]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[17]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[18]}]
set_property PACKAGE_PIN AF17 [get_ports {O_DEBUG[18]}]
set_property SLEW FAST [get_ports {O_DEBUG[18]}]
#set_property drive "8" [get_ports "O_DEBUG[18]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[18]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[19]}]
set_property PACKAGE_PIN AE16 [get_ports {O_DEBUG[19]}]
set_property SLEW FAST [get_ports {O_DEBUG[19]}]
#set_property drive "8" [get_ports "O_DEBUG[19]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[19]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[20]}]
set_property PACKAGE_PIN AE15 [get_ports {O_DEBUG[20]}]
set_property SLEW FAST [get_ports {O_DEBUG[20]}]
#set_property drive "8" [get_ports "O_DEBUG[20]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[20]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[21]}]
set_property PACKAGE_PIN AE18 [get_ports {O_DEBUG[21]}]
set_property SLEW FAST [get_ports {O_DEBUG[21]}]
#set_property drive "8" [get_ports "O_DEBUG[21]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[21]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[22]}]
set_property PACKAGE_PIN AE17 [get_ports {O_DEBUG[22]}]
set_property SLEW FAST [get_ports {O_DEBUG[22]}]
#set_property drive "8" [get_ports "O_DEBUG[22]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[22]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[23]}]
set_property PACKAGE_PIN AD16 [get_ports {O_DEBUG[23]}]
set_property SLEW FAST [get_ports {O_DEBUG[23]}]
#set_property drive "8" [get_ports "O_DEBUG[23]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[23]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[24]}]
set_property PACKAGE_PIN AD15 [get_ports {O_DEBUG[24]}]
set_property SLEW FAST [get_ports {O_DEBUG[24]}]
#set_property drive "8" [get_ports "O_DEBUG[24]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[24]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[25]}]
set_property PACKAGE_PIN AC14 [get_ports {O_DEBUG[25]}]
set_property SLEW FAST [get_ports {O_DEBUG[25]}]
#set_property drive "8" [get_ports "O_DEBUG[25]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[25]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[26]}]
set_property PACKAGE_PIN AC13 [get_ports {O_DEBUG[26]}]
set_property SLEW FAST [get_ports {O_DEBUG[26]}]
#set_property drive "8" [get_ports "O_DEBUG[26]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[26]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[27]}]
set_property PACKAGE_PIN AA15 [get_ports {O_DEBUG[27]}]
set_property SLEW FAST [get_ports {O_DEBUG[27]}]
#set_property drive "8" [get_ports "O_DEBUG[27]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[27]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[28]}]
set_property PACKAGE_PIN AA14 [get_ports {O_DEBUG[28]}]
set_property SLEW FAST [get_ports {O_DEBUG[28]}]
#set_property drive "8" [get_ports "O_DEBUG[28]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[28]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[29]}]
set_property PACKAGE_PIN AB12 [get_ports {O_DEBUG[29]}]
set_property SLEW FAST [get_ports {O_DEBUG[29]}]
#set_property drive "8" [get_ports "O_DEBUG[29]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[29]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[30]}]
set_property PACKAGE_PIN AC12 [get_ports {O_DEBUG[30]}]
set_property SLEW FAST [get_ports {O_DEBUG[30]}]
#set_property drive "8" [get_ports "O_DEBUG[30]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[30]}]

set_property IOSTANDARD LVCMOS33 [get_ports {O_DEBUG[31]}]
set_property PACKAGE_PIN AB15 [get_ports {O_DEBUG[31]}]
set_property SLEW FAST [get_ports {O_DEBUG[31]}]
#set_property drive "8" [get_ports "O_DEBUG[31]"]
set_property PIO_DIRECTION BIDIR [get_ports {O_DEBUG[31]}]


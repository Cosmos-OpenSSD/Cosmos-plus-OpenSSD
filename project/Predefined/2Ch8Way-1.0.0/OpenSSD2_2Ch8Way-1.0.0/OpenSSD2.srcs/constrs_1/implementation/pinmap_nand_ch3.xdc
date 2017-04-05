##################################################################################
## pinmap_nand_ch3 for Cosmos OpenSSD
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
## Design Name: pinmap_nand_ch3
## File Name: pinmap_nand_ch3.xdc
##
## Version: v1.0.0
##
## Description: pinmaps for nand channel 3
##
##################################################################################

##################################################################################
## Revision History:
##
## * v1.0.0
##   - first draft 
##################################################################################

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH3_DQ[0]"]
set_property PACKAGE_PIN "U29" [get_ports "IO_NAND_CH3_DQ[0]"]
set_property slew "slow" [get_ports "IO_NAND_CH3_DQ[0]"]
#set_property drive "8" [get_ports "IO_NAND_CH3_DQ[0]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH3_DQ[0]"]

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH3_DQ[1]"]
set_property PACKAGE_PIN "T29" [get_ports "IO_NAND_CH3_DQ[1]"]
set_property slew "slow" [get_ports "IO_NAND_CH3_DQ[1]"]
#set_property drive "8" [get_ports "IO_NAND_CH3_DQ[1]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH3_DQ[1]"]

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH3_DQ[2]"]
set_property PACKAGE_PIN "P29" [get_ports "IO_NAND_CH3_DQ[2]"]
set_property slew "slow" [get_ports "IO_NAND_CH3_DQ[2]"]
#set_property drive "8" [get_ports "IO_NAND_CH3_DQ[2]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH3_DQ[2]"]

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH3_DQ[3]"]
set_property PACKAGE_PIN "N29" [get_ports "IO_NAND_CH3_DQ[3]"]
set_property slew "slow" [get_ports "IO_NAND_CH3_DQ[3]"]
#set_property drive "8" [get_ports "IO_NAND_CH3_DQ[3]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH3_DQ[3]"]

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH3_DQ[4]"]
set_property PACKAGE_PIN "U30" [get_ports "IO_NAND_CH3_DQ[4]"]
set_property slew "slow" [get_ports "IO_NAND_CH3_DQ[4]"]
#set_property drive "8" [get_ports "IO_NAND_CH3_DQ[4]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH3_DQ[4]"]

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH3_DQ[5]"]
set_property PACKAGE_PIN "T30" [get_ports "IO_NAND_CH3_DQ[5]"]
set_property slew "slow" [get_ports "IO_NAND_CH3_DQ[5]"]
#set_property drive "8" [get_ports "IO_NAND_CH3_DQ[5]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH3_DQ[5]"]

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH3_DQ[6]"]
set_property PACKAGE_PIN "R30" [get_ports "IO_NAND_CH3_DQ[6]"]
set_property slew "slow" [get_ports "IO_NAND_CH3_DQ[6]"]
#set_property drive "8" [get_ports "IO_NAND_CH3_DQ[6]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH3_DQ[6]"]

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH3_DQ[7]"]
set_property PACKAGE_PIN "P30" [get_ports "IO_NAND_CH3_DQ[7]"]
set_property slew "slow" [get_ports "IO_NAND_CH3_DQ[7]"]
#set_property drive "8" [get_ports "IO_NAND_CH3_DQ[7]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH3_DQ[7]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH3_CE[0]"]
set_property PACKAGE_PIN "N27" [get_ports "O_NAND_CH3_CE[0]"]
set_property slew "slow" [get_ports "O_NAND_CH3_CE[0]"]
#set_property drive "8" [get_ports "O_NAND_CH3_CE[0]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH3_CE[0]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH3_CE[1]"]
set_property PACKAGE_PIN "P25" [get_ports "O_NAND_CH3_CE[1]"]
set_property slew "slow" [get_ports "O_NAND_CH3_CE[1]"]
#set_property drive "8" [get_ports "O_NAND_CH3_CE[1]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH3_CE[1]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH3_CE[2]"]
set_property PACKAGE_PIN "P26" [get_ports "O_NAND_CH3_CE[2]"]
set_property slew "slow" [get_ports "O_NAND_CH3_CE[2]"]
#set_property drive "8" [get_ports "O_NAND_CH3_CE[2]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH3_CE[2]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH3_CE[3]"]
set_property PACKAGE_PIN "T24" [get_ports "O_NAND_CH3_CE[3]"]
set_property slew "slow" [get_ports "O_NAND_CH3_CE[3]"]
#set_property drive "8" [get_ports "O_NAND_CH3_CE[3]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH3_CE[3]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH3_CE[4]"]
set_property PACKAGE_PIN "T25" [get_ports "O_NAND_CH3_CE[4]"]
set_property slew "slow" [get_ports "O_NAND_CH3_CE[4]"]
#set_property drive "8" [get_ports "O_NAND_CH3_CE[4]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH3_CE[4]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH3_CE[5]"]
set_property PACKAGE_PIN "P23" [get_ports "O_NAND_CH3_CE[5]"]
set_property slew "slow" [get_ports "O_NAND_CH3_CE[5]"]
#set_property drive "8" [get_ports "O_NAND_CH3_CE[5]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH3_CE[5]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH3_CE[6]"]
set_property PACKAGE_PIN "P24" [get_ports "O_NAND_CH3_CE[6]"]
set_property slew "slow" [get_ports "O_NAND_CH3_CE[6]"]
#set_property drive "8" [get_ports "O_NAND_CH3_CE[6]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH3_CE[6]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH3_CE[7]"]
set_property PACKAGE_PIN "P21" [get_ports "O_NAND_CH3_CE[7]"]
set_property slew "slow" [get_ports "O_NAND_CH3_CE[7]"]
#set_property drive "8" [get_ports "O_NAND_CH3_CE[7]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH3_CE[7]"]

set_property iostandard "SSTL18_II" [get_ports "O_NAND_CH3_CLE"]
set_property PACKAGE_PIN "V28" [get_ports "O_NAND_CH3_CLE"]
set_property slew "slow" [get_ports "O_NAND_CH3_CLE"]
#set_property drive "8" [get_ports "O_NAND_CH3_CLE"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH3_CLE"]

set_property iostandard "SSTL18_II" [get_ports "O_NAND_CH3_ALE"]
set_property PACKAGE_PIN "V29" [get_ports "O_NAND_CH3_ALE"]
set_property slew "slow" [get_ports "O_NAND_CH3_ALE"]
#set_property drive "8" [get_ports "O_NAND_CH3_ALE"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH3_ALE"]

set_property iostandard "SSTL18_II" [get_ports "O_NAND_CH3_WE"]
set_property PACKAGE_PIN "W25" [get_ports "O_NAND_CH3_WE"]
set_property slew "slow" [get_ports "O_NAND_CH3_WE"]
#set_property drive "8" [get_ports "O_NAND_CH3_WE"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH3_WE"]

set_property iostandard "DIFF_SSTL18_II" [get_ports "O_NAND_CH3_RE_P"]
set_property PACKAGE_PIN "N28" [get_ports "O_NAND_CH3_RE_P"]
set_property slew "slow" [get_ports "O_NAND_CH3_RE_P"]
#set_property drive "8" [get_ports "O_NAND_CH3_RE_P"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH3_RE_P"]

set_property iostandard "DIFF_SSTL18_II" [get_ports "O_NAND_CH3_RE_N"]
set_property PACKAGE_PIN "P28" [get_ports "O_NAND_CH3_RE_N"]
set_property slew "slow" [get_ports "O_NAND_CH3_RE_N"]
#set_property drive "8" [get_ports "O_NAND_CH3_RE_N"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH3_RE_N"]

set_property iostandard "DIFF_SSTL18_II" [get_ports "IO_NAND_CH3_DQS_P"]
set_property PACKAGE_PIN "U25" [get_ports "IO_NAND_CH3_DQS_P"]
set_property slew "slow" [get_ports "IO_NAND_CH3_DQS_P"]
#set_property drive "8" [get_ports "IO_NAND_CH3_DQS_P"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH3_DQS_P"]

set_property iostandard "DIFF_SSTL18_II" [get_ports "IO_NAND_CH3_DQS_N"]
set_property PACKAGE_PIN "V26" [get_ports "IO_NAND_CH3_DQS_N"]
set_property slew "slow" [get_ports "IO_NAND_CH3_DQS_N"]
#set_property drive "8" [get_ports "IO_NAND_CH3_DQS_N"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH3_DQS_N"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH3_RB[0]"]
set_property PACKAGE_PIN "W30" [get_ports "I_NAND_CH3_RB[0]"]
set_property slew "slow" [get_ports "I_NAND_CH3_RB[0]"]
#set_property drive "8" [get_ports "I_NAND_CH3_RB[0]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH3_RB[0]"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH3_RB[1]"]
set_property PACKAGE_PIN "R28" [get_ports "I_NAND_CH3_RB[1]"]
set_property slew "slow" [get_ports "I_NAND_CH3_RB[1]"]
#set_property drive "8" [get_ports "I_NAND_CH3_RB[1]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH3_RB[1]"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH3_RB[2]"]
set_property PACKAGE_PIN "U27" [get_ports "I_NAND_CH3_RB[2]"]
set_property slew "slow" [get_ports "I_NAND_CH3_RB[2]"]
#set_property drive "8" [get_ports "I_NAND_CH3_RB[2]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH3_RB[2]"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH3_RB[3]"]
set_property PACKAGE_PIN "R25" [get_ports "I_NAND_CH3_RB[3]"]
set_property slew "slow" [get_ports "I_NAND_CH3_RB[3]"]
#set_property drive "8" [get_ports "I_NAND_CH3_RB[3]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH3_RB[3]"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH3_RB[4]"]
set_property PACKAGE_PIN "R26" [get_ports "I_NAND_CH3_RB[4]"]
set_property slew "slow" [get_ports "I_NAND_CH3_RB[4]"]
#set_property drive "8" [get_ports "I_NAND_CH3_RB[4]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH3_RB[4]"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH3_RB[5]"]
set_property PACKAGE_PIN "R27" [get_ports "I_NAND_CH3_RB[5]"]
set_property slew "slow" [get_ports "I_NAND_CH3_RB[5]"]
#set_property drive "8" [get_ports "I_NAND_CH3_RB[5]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH3_RB[5]"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH3_RB[6]"]
set_property PACKAGE_PIN "T27" [get_ports "I_NAND_CH3_RB[6]"]
set_property slew "slow" [get_ports "I_NAND_CH3_RB[6]"]
#set_property drive "8" [get_ports "I_NAND_CH3_RB[6]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH3_RB[6]"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH3_RB[7]"]
set_property PACKAGE_PIN "N26" [get_ports "I_NAND_CH3_RB[7]"]
set_property slew "slow" [get_ports "I_NAND_CH3_RB[7]"]
#set_property drive "8" [get_ports "I_NAND_CH3_RB[7]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH3_RB[7]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH3_WP"]
set_property PACKAGE_PIN "W29" [get_ports "O_NAND_CH3_WP"]
set_property slew "slow" [get_ports "O_NAND_CH3_WP"]
#set_property drive "8" [get_ports "O_NAND_CH3_WP"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH3_WP"]
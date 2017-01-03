##################################################################################
## pinmap_nand_ch2 for Cosmos OpenSSD
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
## Design Name: pinmap_nand_ch2
## File Name: pinmap_nand_ch2.xdc
##
## Version: v1.0.0
##
## Description: pinmaps for nand channel 2
##
##################################################################################

##################################################################################
## Revision History:
##
## * v1.0.0
##   - first draft 
##################################################################################

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH2_DQ[0]"]
set_property PACKAGE_PIN "AK26" [get_ports "IO_NAND_CH2_DQ[0]"]
set_property slew "slow" [get_ports "IO_NAND_CH2_DQ[0]"]
#set_property drive "8" [get_ports "IO_NAND_CH2_DQ[0]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH2_DQ[0]"]

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH2_DQ[1]"]
set_property PACKAGE_PIN "AJ26" [get_ports "IO_NAND_CH2_DQ[1]"]
set_property slew "slow" [get_ports "IO_NAND_CH2_DQ[1]"]
#set_property drive "8" [get_ports "IO_NAND_CH2_DQ[1]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH2_DQ[1]"]

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH2_DQ[2]"]
set_property PACKAGE_PIN "AH27" [get_ports "IO_NAND_CH2_DQ[2]"]
set_property slew "slow" [get_ports "IO_NAND_CH2_DQ[2]"]
#set_property drive "8" [get_ports "IO_NAND_CH2_DQ[2]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH2_DQ[2]"]

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH2_DQ[3]"]
set_property PACKAGE_PIN "AH26" [get_ports "IO_NAND_CH2_DQ[3]"]
set_property slew "slow" [get_ports "IO_NAND_CH2_DQ[3]"]
#set_property drive "8" [get_ports "IO_NAND_CH2_DQ[3]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH2_DQ[3]"]

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH2_DQ[4]"]
set_property PACKAGE_PIN "AK28" [get_ports "IO_NAND_CH2_DQ[4]"]
set_property slew "slow" [get_ports "IO_NAND_CH2_DQ[4]"]
#set_property drive "8" [get_ports "IO_NAND_CH2_DQ[4]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH2_DQ[4]"]

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH2_DQ[5]"]
set_property PACKAGE_PIN "AK27" [get_ports "IO_NAND_CH2_DQ[5]"]
set_property slew "slow" [get_ports "IO_NAND_CH2_DQ[5]"]
#set_property drive "8" [get_ports "IO_NAND_CH2_DQ[5]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH2_DQ[5]"]

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH2_DQ[6]"]
set_property PACKAGE_PIN "AK30" [get_ports "IO_NAND_CH2_DQ[6]"]
set_property slew "slow" [get_ports "IO_NAND_CH2_DQ[6]"]
#set_property drive "8" [get_ports "IO_NAND_CH2_DQ[6]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH2_DQ[6]"]

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH2_DQ[7]"]
set_property PACKAGE_PIN "AJ30" [get_ports "IO_NAND_CH2_DQ[7]"]
set_property slew "slow" [get_ports "IO_NAND_CH2_DQ[7]"]
#set_property drive "8" [get_ports "IO_NAND_CH2_DQ[7]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH2_DQ[7]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH2_CE[0]"]
set_property PACKAGE_PIN "AE28" [get_ports "O_NAND_CH2_CE[0]"]
set_property slew "slow" [get_ports "O_NAND_CH2_CE[0]"]
#set_property drive "8" [get_ports "O_NAND_CH2_CE[0]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH2_CE[0]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH2_CE[1]"]
set_property PACKAGE_PIN "AF28" [get_ports "O_NAND_CH2_CE[1]"]
set_property slew "slow" [get_ports "O_NAND_CH2_CE[1]"]
#set_property drive "8" [get_ports "O_NAND_CH2_CE[1]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH2_CE[1]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH2_CE[2]"]
set_property PACKAGE_PIN "AF29" [get_ports "O_NAND_CH2_CE[2]"]
set_property slew "slow" [get_ports "O_NAND_CH2_CE[2]"]
#set_property drive "8" [get_ports "O_NAND_CH2_CE[2]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH2_CE[2]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH2_CE[3]"]
set_property PACKAGE_PIN "AG29" [get_ports "O_NAND_CH2_CE[3]"]
set_property slew "slow" [get_ports "O_NAND_CH2_CE[3]"]
#set_property drive "8" [get_ports "O_NAND_CH2_CE[3]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH2_CE[3]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH2_CE[4]"]
set_property PACKAGE_PIN "AF30" [get_ports "O_NAND_CH2_CE[4]"]
set_property slew "slow" [get_ports "O_NAND_CH2_CE[4]"]
#set_property drive "8" [get_ports "O_NAND_CH2_CE[4]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH2_CE[4]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH2_CE[5]"]
set_property PACKAGE_PIN "AG30" [get_ports "O_NAND_CH2_CE[5]"]
set_property slew "slow" [get_ports "O_NAND_CH2_CE[5]"]
#set_property drive "8" [get_ports "O_NAND_CH2_CE[5]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH2_CE[5]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH2_CE[6]"]
set_property PACKAGE_PIN "AG26" [get_ports "O_NAND_CH2_CE[6]"]
set_property slew "slow" [get_ports "O_NAND_CH2_CE[6]"]
#set_property drive "8" [get_ports "O_NAND_CH2_CE[6]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH2_CE[6]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH2_CE[7]"]
set_property PACKAGE_PIN "AG27" [get_ports "O_NAND_CH2_CE[7]"]
set_property slew "slow" [get_ports "O_NAND_CH2_CE[7]"]
#set_property drive "8" [get_ports "O_NAND_CH2_CE[7]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH2_CE[7]"]

set_property iostandard "SSTL18_II" [get_ports "O_NAND_CH2_CLE"]
set_property PACKAGE_PIN "AH28" [get_ports "O_NAND_CH2_CLE"]
set_property slew "slow" [get_ports "O_NAND_CH2_CLE"]
#set_property drive "8" [get_ports "O_NAND_CH2_CLE"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH2_CLE"]

set_property iostandard "SSTL18_II" [get_ports "O_NAND_CH2_ALE"]
set_property PACKAGE_PIN "AD25" [get_ports "O_NAND_CH2_ALE"]
set_property slew "slow" [get_ports "O_NAND_CH2_ALE"]
#set_property drive "8" [get_ports "O_NAND_CH2_ALE"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH2_ALE"]

set_property iostandard "SSTL18_II" [get_ports "O_NAND_CH2_WE"]
set_property PACKAGE_PIN "AE25" [get_ports "O_NAND_CH2_WE"]
set_property slew "slow" [get_ports "O_NAND_CH2_WE"]
#set_property drive "8" [get_ports "O_NAND_CH2_WE"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH2_WE"]

set_property iostandard "DIFF_SSTL18_II" [get_ports "O_NAND_CH2_RE_P"]
set_property PACKAGE_PIN "AJ28" [get_ports "O_NAND_CH2_RE_P"]
set_property slew "slow" [get_ports "O_NAND_CH2_RE_P"]
#set_property drive "8" [get_ports "O_NAND_CH2_RE_P"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH2_RE_P"]

set_property iostandard "DIFF_SSTL18_II" [get_ports "O_NAND_CH2_RE_N"]
set_property PACKAGE_PIN "AJ29" [get_ports "O_NAND_CH2_RE_N"]
set_property slew "slow" [get_ports "O_NAND_CH2_RE_N"]
#set_property drive "8" [get_ports "O_NAND_CH2_RE_N"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH2_RE_N"]

set_property iostandard "DIFF_SSTL18_II" [get_ports "IO_NAND_CH2_DQS_P"]
set_property PACKAGE_PIN "AE27" [get_ports "IO_NAND_CH2_DQS_P"]
set_property slew "slow" [get_ports "IO_NAND_CH2_DQS_P"]
#set_property drive "8" [get_ports "IO_NAND_CH2_DQS_P"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH2_DQS_P"]

set_property iostandard "DIFF_SSTL18_II" [get_ports "IO_NAND_CH2_DQS_N"]
set_property PACKAGE_PIN "AF27" [get_ports "IO_NAND_CH2_DQS_N"]
set_property slew "slow" [get_ports "IO_NAND_CH2_DQS_N"]
#set_property drive "8" [get_ports "IO_NAND_CH2_DQS_N"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH2_DQS_N"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH2_RB[0]"]
set_property PACKAGE_PIN "V27" [get_ports "I_NAND_CH2_RB[0]"]
set_property slew "slow" [get_ports "I_NAND_CH2_RB[0]"]
#set_property drive "8" [get_ports "I_NAND_CH2_RB[0]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH2_RB[0]"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH2_RB[1]"]
set_property PACKAGE_PIN "W28" [get_ports "I_NAND_CH2_RB[1]"]
set_property slew "slow" [get_ports "I_NAND_CH2_RB[1]"]
#set_property drive "8" [get_ports "I_NAND_CH2_RB[1]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH2_RB[1]"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH2_RB[2]"]
set_property PACKAGE_PIN "U26" [get_ports "I_NAND_CH2_RB[2]"]
set_property slew "slow" [get_ports "I_NAND_CH2_RB[2]"]
#set_property drive "8" [get_ports "I_NAND_CH2_RB[2]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH2_RB[2]"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH2_RB[3]"]
set_property PACKAGE_PIN "AE26" [get_ports "I_NAND_CH2_RB[3]"]
set_property slew "slow" [get_ports "I_NAND_CH2_RB[3]"]
#set_property drive "8" [get_ports "I_NAND_CH2_RB[3]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH2_RB[3]"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH2_RB[4]"]
set_property PACKAGE_PIN "AB27" [get_ports "I_NAND_CH2_RB[4]"]
set_property slew "slow" [get_ports "I_NAND_CH2_RB[4]"]
#set_property drive "8" [get_ports "I_NAND_CH2_RB[4]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH2_RB[4]"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH2_RB[5]"]
set_property PACKAGE_PIN "AC27" [get_ports "I_NAND_CH2_RB[5]"]
set_property slew "slow" [get_ports "I_NAND_CH2_RB[5]"]
#set_property drive "8" [get_ports "I_NAND_CH2_RB[5]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH2_RB[5]"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH2_RB[6]"]
set_property PACKAGE_PIN "AC28" [get_ports "I_NAND_CH2_RB[6]"]
set_property slew "slow" [get_ports "I_NAND_CH2_RB[6]"]
#set_property drive "8" [get_ports "I_NAND_CH2_RB[6]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH2_RB[6]"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH2_RB[7]"]
set_property PACKAGE_PIN "AD28" [get_ports "I_NAND_CH2_RB[7]"]
set_property slew "slow" [get_ports "I_NAND_CH2_RB[7]"]
#set_property drive "8" [get_ports "I_NAND_CH2_RB[7]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH2_RB[7]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH2_WP"]
set_property PACKAGE_PIN "AA25" [get_ports "O_NAND_CH2_WP"]
set_property slew "slow" [get_ports "O_NAND_CH2_WP"]
#set_property drive "8" [get_ports "O_NAND_CH2_WP"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH2_WP"]
##################################################################################
## pinmap_nand_ch1 for Cosmos OpenSSD
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
## Design Name: pinmap_nand_ch1
## File Name: pinmap_nand_ch1.xdc
##
## Version: v1.0.0
##
## Description: pinmaps for nand channel 1
##
##################################################################################

##################################################################################
## Revision History:
##
## * v1.0.0
##   - first draft 
##################################################################################

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH1_DQ[0]"]
set_property PACKAGE_PIN "W21" [get_ports "IO_NAND_CH1_DQ[0]"]
set_property slew "slow" [get_ports "IO_NAND_CH1_DQ[0]"]
#set_property drive "8" [get_ports "IO_NAND_CH1_DQ[0]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH1_DQ[0]"]

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH1_DQ[1]"]
set_property PACKAGE_PIN "Y21" [get_ports "IO_NAND_CH1_DQ[1]"]
set_property slew "slow" [get_ports "IO_NAND_CH1_DQ[1]"]
#set_property drive "8" [get_ports "IO_NAND_CH1_DQ[1]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH1_DQ[1]"]

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH1_DQ[2]"]
set_property PACKAGE_PIN "AA24" [get_ports "IO_NAND_CH1_DQ[2]"]
set_property slew "slow" [get_ports "IO_NAND_CH1_DQ[2]"]
#set_property drive "8" [get_ports "IO_NAND_CH1_DQ[2]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH1_DQ[2]"]

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH1_DQ[3]"]
set_property PACKAGE_PIN "AB24" [get_ports "IO_NAND_CH1_DQ[3]"]
set_property slew "slow" [get_ports "IO_NAND_CH1_DQ[3]"]
#set_property drive "8" [get_ports "IO_NAND_CH1_DQ[3]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH1_DQ[3]"]

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH1_DQ[4]"]
set_property PACKAGE_PIN "AA22" [get_ports "IO_NAND_CH1_DQ[4]"]
set_property slew "slow" [get_ports "IO_NAND_CH1_DQ[4]"]
#set_property drive "8" [get_ports "IO_NAND_CH1_DQ[4]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH1_DQ[4]"]

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH1_DQ[5]"]
set_property PACKAGE_PIN "AA23" [get_ports "IO_NAND_CH1_DQ[5]"]
set_property slew "slow" [get_ports "IO_NAND_CH1_DQ[5]"]
#set_property drive "8" [get_ports "IO_NAND_CH1_DQ[5]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH1_DQ[5]"]

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH1_DQ[6]"]
set_property PACKAGE_PIN "AC22" [get_ports "IO_NAND_CH1_DQ[6]"]
set_property slew "slow" [get_ports "IO_NAND_CH1_DQ[6]"]
#set_property drive "8" [get_ports "IO_NAND_CH1_DQ[6]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH1_DQ[6]"]

set_property iostandard "LVCMOS18" [get_ports "IO_NAND_CH1_DQ[7]"]
set_property PACKAGE_PIN "AC23" [get_ports "IO_NAND_CH1_DQ[7]"]
set_property slew "slow" [get_ports "IO_NAND_CH1_DQ[7]"]
#set_property drive "8" [get_ports "IO_NAND_CH1_DQ[7]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH1_DQ[7]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH1_CE[0]"]
set_property PACKAGE_PIN "AG21" [get_ports "O_NAND_CH1_CE[0]"]
set_property slew "slow" [get_ports "O_NAND_CH1_CE[0]"]
#set_property drive "8" [get_ports "O_NAND_CH1_CE[0]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH1_CE[0]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH1_CE[1]"]
set_property PACKAGE_PIN "AH21" [get_ports "O_NAND_CH1_CE[1]"]
set_property slew "slow" [get_ports "O_NAND_CH1_CE[1]"]
#set_property drive "8" [get_ports "O_NAND_CH1_CE[1]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH1_CE[1]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH1_CE[2]"]
set_property PACKAGE_PIN "AJ20" [get_ports "O_NAND_CH1_CE[2]"]
set_property slew "slow" [get_ports "O_NAND_CH1_CE[2]"]
#set_property drive "8" [get_ports "O_NAND_CH1_CE[2]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH1_CE[2]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH1_CE[3]"]
set_property PACKAGE_PIN "AK20" [get_ports "O_NAND_CH1_CE[3]"]
set_property slew "slow" [get_ports "O_NAND_CH1_CE[3]"]
#set_property drive "8" [get_ports "O_NAND_CH1_CE[3]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH1_CE[3]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH1_CE[4]"]
set_property PACKAGE_PIN "AK17" [get_ports "O_NAND_CH1_CE[4]"]
set_property slew "slow" [get_ports "O_NAND_CH1_CE[4]"]
#set_property drive "8" [get_ports "O_NAND_CH1_CE[4]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH1_CE[4]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH1_CE[5]"]
set_property PACKAGE_PIN "AK18" [get_ports "O_NAND_CH1_CE[5]"]
set_property slew "slow" [get_ports "O_NAND_CH1_CE[5]"]
#set_property drive "8" [get_ports "O_NAND_CH1_CE[5]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH1_CE[5]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH1_CE[6]"]
set_property PACKAGE_PIN "AH19" [get_ports "O_NAND_CH1_CE[6]"]
set_property slew "slow" [get_ports "O_NAND_CH1_CE[6]"]
#set_property drive "8" [get_ports "O_NAND_CH1_CE[6]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH1_CE[6]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH1_CE[7]"]
set_property PACKAGE_PIN "AJ19" [get_ports "O_NAND_CH1_CE[7]"]
set_property slew "slow" [get_ports "O_NAND_CH1_CE[7]"]
#set_property drive "8" [get_ports "O_NAND_CH1_CE[7]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH1_CE[7]"]

set_property iostandard "SSTL18_II" [get_ports "O_NAND_CH1_CLE"]
set_property PACKAGE_PIN "AC21" [get_ports "O_NAND_CH1_CLE"]
set_property slew "slow" [get_ports "O_NAND_CH1_CLE"]
#set_property drive "8" [get_ports "O_NAND_CH1_CLE"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH1_CLE"]

set_property iostandard "SSTL18_II" [get_ports "O_NAND_CH1_ALE"]
set_property PACKAGE_PIN "Y30" [get_ports "O_NAND_CH1_ALE"]
set_property slew "slow" [get_ports "O_NAND_CH1_ALE"]
#set_property drive "8" [get_ports "O_NAND_CH1_ALE"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH1_ALE"]

set_property iostandard "SSTL18_II" [get_ports "O_NAND_CH1_WE"]
set_property PACKAGE_PIN "AF19" [get_ports "O_NAND_CH1_WE"]
set_property slew "slow" [get_ports "O_NAND_CH1_WE"]
#set_property drive "8" [get_ports "O_NAND_CH1_WE"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH1_WE"]

set_property iostandard "DIFF_SSTL18_II" [get_ports "O_NAND_CH1_RE_P"]
set_property PACKAGE_PIN "Y22" [get_ports "O_NAND_CH1_RE_P"]
set_property slew "slow" [get_ports "O_NAND_CH1_RE_P"]
#set_property drive "8" [get_ports "O_NAND_CH1_RE_P"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH1_RE_P"]

set_property iostandard "DIFF_SSTL18_II" [get_ports "O_NAND_CH1_RE_N"]
set_property PACKAGE_PIN "Y23" [get_ports "O_NAND_CH1_RE_N"]
set_property slew "slow" [get_ports "O_NAND_CH1_RE_N"]
#set_property drive "8" [get_ports "O_NAND_CH1_RE_N"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH1_RE_N"]

set_property iostandard "DIFF_SSTL18_II" [get_ports "IO_NAND_CH1_DQS_P"]
set_property PACKAGE_PIN "AF20" [get_ports "IO_NAND_CH1_DQS_P"]
set_property slew "slow" [get_ports "IO_NAND_CH1_DQS_P"]
#set_property drive "8" [get_ports "IO_NAND_CH1_DQS_P"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH1_DQS_P"]

set_property iostandard "DIFF_SSTL18_II" [get_ports "IO_NAND_CH1_DQS_N"]
set_property PACKAGE_PIN "AG20" [get_ports "IO_NAND_CH1_DQS_N"]
set_property slew "slow" [get_ports "IO_NAND_CH1_DQS_N"]
#set_property drive "8" [get_ports "IO_NAND_CH1_DQS_N"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "IO_NAND_CH1_DQS_N"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH1_RB[0]"]
set_property PACKAGE_PIN "AF23" [get_ports "I_NAND_CH1_RB[0]"]
set_property slew "slow" [get_ports "I_NAND_CH1_RB[0]"]
#set_property drive "8" [get_ports "I_NAND_CH1_RB[0]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH1_RB[0]"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH1_RB[1]"]
set_property PACKAGE_PIN "AF24" [get_ports "I_NAND_CH1_RB[1]"]
set_property slew "slow" [get_ports "I_NAND_CH1_RB[1]"]
#set_property drive "8" [get_ports "I_NAND_CH1_RB[1]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH1_RB[1]"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH1_RB[2]"]
set_property PACKAGE_PIN "AD21" [get_ports "I_NAND_CH1_RB[2]"]
set_property slew "slow" [get_ports "I_NAND_CH1_RB[2]"]
#set_property drive "8" [get_ports "I_NAND_CH1_RB[2]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH1_RB[2]"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH1_RB[3]"]
set_property PACKAGE_PIN "AE21" [get_ports "I_NAND_CH1_RB[3]"]
set_property slew "slow" [get_ports "I_NAND_CH1_RB[3]"]
#set_property drive "8" [get_ports "I_NAND_CH1_RB[3]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH1_RB[3]"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH1_RB[4]"]
set_property PACKAGE_PIN "AE22" [get_ports "I_NAND_CH1_RB[4]"]
set_property slew "slow" [get_ports "I_NAND_CH1_RB[4]"]
#set_property drive "8" [get_ports "I_NAND_CH1_RB[4]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH1_RB[4]"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH1_RB[5]"]
set_property PACKAGE_PIN "W23" [get_ports "I_NAND_CH1_RB[5]"]
set_property slew "slow" [get_ports "I_NAND_CH1_RB[5]"]
#set_property drive "8" [get_ports "I_NAND_CH1_RB[5]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH1_RB[5]"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH1_RB[6]"]
set_property PACKAGE_PIN "AF22" [get_ports "I_NAND_CH1_RB[6]"]
set_property slew "slow" [get_ports "I_NAND_CH1_RB[6]"]
#set_property drive "8" [get_ports "I_NAND_CH1_RB[6]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH1_RB[6]"]

set_property iostandard "SSTL18_II" [get_ports "I_NAND_CH1_RB[7]"]
set_property PACKAGE_PIN "AB21" [get_ports "I_NAND_CH1_RB[7]"]
set_property slew "slow" [get_ports "I_NAND_CH1_RB[7]"]
#set_property drive "8" [get_ports "I_NAND_CH1_RB[7]"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "I_NAND_CH1_RB[7]"]

set_property iostandard "LVCMOS18" [get_ports "O_NAND_CH1_WP"]
set_property PACKAGE_PIN "Y25" [get_ports "O_NAND_CH1_WP"]
set_property slew "slow" [get_ports "O_NAND_CH1_WP"]
#set_property drive "8" [get_ports "O_NAND_CH1_WP"]
#set_property PIO_DIRECTION "BIDIR" [get_ports "O_NAND_CH1_WP"]

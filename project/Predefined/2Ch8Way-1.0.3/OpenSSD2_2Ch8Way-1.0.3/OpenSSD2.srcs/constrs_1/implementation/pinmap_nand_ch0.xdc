##################################################################################
## pinmap_nand_ch0 for Cosmos OpenSSD
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
## Design Name: pinmap_nand_ch0
## File Name: pinmap_nand_ch0.xdc
##
## Version: v1.0.0
##
## Description: pinmaps for nand channel 0
##
##################################################################################

##################################################################################
## Revision History:
##
## * v1.0.0
##   - first draft 
##################################################################################

set_property IOSTANDARD LVCMOS18 [get_ports {IO_NAND_CH0_DQ[0]}]
set_property PACKAGE_PIN AJ25 [get_ports {IO_NAND_CH0_DQ[0]}]
set_property SLEW FAST [get_ports {IO_NAND_CH0_DQ[0]}]
#set_property DRIVE 8 [get_ports {IO_NAND_CH0_DQ[0]}]
#set_property PIO_DIRECTION BIDIR [get_ports {IO_NAND_CH0_DQ[0]}]

set_property IOSTANDARD LVCMOS18 [get_ports {IO_NAND_CH0_DQ[1]}]
set_property PACKAGE_PIN AK25 [get_ports {IO_NAND_CH0_DQ[1]}]
set_property SLEW FAST [get_ports {IO_NAND_CH0_DQ[1]}]
#set_property DRIVE 8 [get_ports {IO_NAND_CH0_DQ[1]}]
#set_property PIO_DIRECTION BIDIR [get_ports {IO_NAND_CH0_DQ[1]}]

set_property IOSTANDARD LVCMOS18 [get_ports {IO_NAND_CH0_DQ[2]}]
set_property PACKAGE_PIN AK22 [get_ports {IO_NAND_CH0_DQ[2]}]
set_property SLEW FAST [get_ports {IO_NAND_CH0_DQ[2]}]
#set_property DRIVE 8 [get_ports {IO_NAND_CH0_DQ[2]}]
#set_property PIO_DIRECTION BIDIR [get_ports {IO_NAND_CH0_DQ[2]}]

set_property IOSTANDARD LVCMOS18 [get_ports {IO_NAND_CH0_DQ[3]}]
set_property PACKAGE_PIN AK23 [get_ports {IO_NAND_CH0_DQ[3]}]
set_property SLEW FAST [get_ports {IO_NAND_CH0_DQ[3]}]
#set_property DRIVE 8 [get_ports {IO_NAND_CH0_DQ[3]}]
#set_property PIO_DIRECTION BIDIR [get_ports {IO_NAND_CH0_DQ[3]}]

set_property IOSTANDARD LVCMOS18 [get_ports {IO_NAND_CH0_DQ[4]}]
set_property PACKAGE_PIN AJ23 [get_ports {IO_NAND_CH0_DQ[4]}]
set_property SLEW FAST [get_ports {IO_NAND_CH0_DQ[4]}]
#set_property DRIVE 8 [get_ports {IO_NAND_CH0_DQ[4]}]
#set_property PIO_DIRECTION BIDIR [get_ports {IO_NAND_CH0_DQ[4]}]

set_property IOSTANDARD LVCMOS18 [get_ports {IO_NAND_CH0_DQ[5]}]
set_property PACKAGE_PIN AJ24 [get_ports {IO_NAND_CH0_DQ[5]}]
set_property SLEW FAST [get_ports {IO_NAND_CH0_DQ[5]}]
#set_property DRIVE 8 [get_ports {IO_NAND_CH0_DQ[5]}]
#set_property PIO_DIRECTION BIDIR [get_ports {IO_NAND_CH0_DQ[5]}]

set_property IOSTANDARD LVCMOS18 [get_ports {IO_NAND_CH0_DQ[6]}]
set_property PACKAGE_PIN AH23 [get_ports {IO_NAND_CH0_DQ[6]}]
set_property SLEW FAST [get_ports {IO_NAND_CH0_DQ[6]}]
#set_property DRIVE 8 [get_ports {IO_NAND_CH0_DQ[6]}]
#set_property PIO_DIRECTION BIDIR [get_ports {IO_NAND_CH0_DQ[6]}]

set_property IOSTANDARD LVCMOS18 [get_ports {IO_NAND_CH0_DQ[7]}]
set_property PACKAGE_PIN AH24 [get_ports {IO_NAND_CH0_DQ[7]}]
set_property SLEW FAST [get_ports {IO_NAND_CH0_DQ[7]}]
#set_property DRIVE 8 [get_ports {IO_NAND_CH0_DQ[7]}]
#set_property PIO_DIRECTION BIDIR [get_ports {IO_NAND_CH0_DQ[7]}]

set_property IOSTANDARD LVCMOS18 [get_ports {O_NAND_CH0_CE[0]}]
set_property PACKAGE_PIN AA29 [get_ports {O_NAND_CH0_CE[0]}]
set_property SLEW SLOW [get_ports {O_NAND_CH0_CE[0]}]
#set_property DRIVE 8 [get_ports {O_NAND_CH0_CE[0]}]
#set_property PIO_DIRECTION BIDIR [get_ports {O_NAND_CH0_CE[0]}]

set_property IOSTANDARD LVCMOS18 [get_ports {O_NAND_CH0_CE[1]}]
set_property PACKAGE_PIN AA27 [get_ports {O_NAND_CH0_CE[1]}]
set_property SLEW SLOW [get_ports {O_NAND_CH0_CE[1]}]
#set_property DRIVE 8 [get_ports {O_NAND_CH0_CE[1]}]
#set_property PIO_DIRECTION BIDIR [get_ports {O_NAND_CH0_CE[1]}]

set_property IOSTANDARD LVCMOS18 [get_ports {O_NAND_CH0_CE[2]}]
set_property PACKAGE_PIN AA28 [get_ports {O_NAND_CH0_CE[2]}]
set_property SLEW SLOW [get_ports {O_NAND_CH0_CE[2]}]
#set_property DRIVE 8 [get_ports {O_NAND_CH0_CE[2]}]
#set_property PIO_DIRECTION BIDIR [get_ports {O_NAND_CH0_CE[2]}]

set_property IOSTANDARD LVCMOS18 [get_ports {O_NAND_CH0_CE[3]}]
set_property PACKAGE_PIN AB25 [get_ports {O_NAND_CH0_CE[3]}]
set_property SLEW SLOW [get_ports {O_NAND_CH0_CE[3]}]
#set_property DRIVE 8 [get_ports {O_NAND_CH0_CE[3]}]
#set_property PIO_DIRECTION BIDIR [get_ports {O_NAND_CH0_CE[3]}]

set_property IOSTANDARD LVCMOS18 [get_ports {O_NAND_CH0_CE[4]}]
set_property PACKAGE_PIN AC26 [get_ports {O_NAND_CH0_CE[4]}]
set_property SLEW SLOW [get_ports {O_NAND_CH0_CE[4]}]
#set_property DRIVE 8 [get_ports {O_NAND_CH0_CE[4]}]
#set_property PIO_DIRECTION BIDIR [get_ports {O_NAND_CH0_CE[4]}]

set_property IOSTANDARD LVCMOS18 [get_ports {O_NAND_CH0_CE[5]}]
set_property PACKAGE_PIN AD26 [get_ports {O_NAND_CH0_CE[5]}]
set_property SLEW SLOW [get_ports {O_NAND_CH0_CE[5]}]
#set_property DRIVE 8 [get_ports {O_NAND_CH0_CE[5]}]
#set_property PIO_DIRECTION BIDIR [get_ports {O_NAND_CH0_CE[5]}]

set_property IOSTANDARD LVCMOS18 [get_ports {O_NAND_CH0_CE[6]}]
set_property PACKAGE_PIN AD30 [get_ports {O_NAND_CH0_CE[6]}]
set_property SLEW SLOW [get_ports {O_NAND_CH0_CE[6]}]
#set_property DRIVE 8 [get_ports {O_NAND_CH0_CE[6]}]
#set_property PIO_DIRECTION BIDIR [get_ports {O_NAND_CH0_CE[6]}]

set_property IOSTANDARD LVCMOS18 [get_ports {O_NAND_CH0_CE[7]}]
set_property PACKAGE_PIN AE30 [get_ports {O_NAND_CH0_CE[7]}]
set_property SLEW SLOW [get_ports {O_NAND_CH0_CE[7]}]
#set_property DRIVE 8 [get_ports {O_NAND_CH0_CE[7]}]
#set_property PIO_DIRECTION BIDIR [get_ports {O_NAND_CH0_CE[7]}]

set_property IOSTANDARD SSTL18_II [get_ports O_NAND_CH0_CLE]
set_property PACKAGE_PIN AC24 [get_ports O_NAND_CH0_CLE]
set_property SLEW FAST [get_ports O_NAND_CH0_CLE]
#set_property DRIVE 8 [get_ports O_NAND_CH0_CLE]
#set_property PIO_DIRECTION BIDIR [get_ports O_NAND_CH0_CLE]

set_property IOSTANDARD SSTL18_II [get_ports O_NAND_CH0_ALE]
set_property PACKAGE_PIN AD24 [get_ports O_NAND_CH0_ALE]
set_property SLEW FAST [get_ports O_NAND_CH0_ALE]
#set_property DRIVE 8 [get_ports O_NAND_CH0_ALE]
#set_property PIO_DIRECTION BIDIR [get_ports O_NAND_CH0_ALE]

set_property IOSTANDARD SSTL18_II [get_ports O_NAND_CH0_WE]
set_property PACKAGE_PIN AG24 [get_ports O_NAND_CH0_WE]
set_property SLEW FAST [get_ports O_NAND_CH0_WE]
#set_property DRIVE 8 [get_ports O_NAND_CH0_WE]
#set_property PIO_DIRECTION BIDIR [get_ports O_NAND_CH0_WE]

set_property IOSTANDARD DIFF_SSTL18_II [get_ports O_NAND_CH0_RE_P]
set_property PACKAGE_PIN AJ21 [get_ports O_NAND_CH0_RE_P]
set_property SLEW FAST [get_ports O_NAND_CH0_RE_P]
#set_property DRIVE 8 [get_ports O_NAND_CH0_RE_P]
#set_property PIO_DIRECTION BIDIR [get_ports O_NAND_CH0_RE_P]

set_property IOSTANDARD DIFF_SSTL18_II [get_ports O_NAND_CH0_RE_N]
set_property PACKAGE_PIN AK21 [get_ports O_NAND_CH0_RE_N]
set_property SLEW FAST [get_ports O_NAND_CH0_RE_N]
#set_property DRIVE 8 [get_ports O_NAND_CH0_RE_N]
#set_property PIO_DIRECTION BIDIR [get_ports O_NAND_CH0_RE_N]

set_property IOSTANDARD DIFF_SSTL18_II [get_ports IO_NAND_CH0_DQS_P]
set_property PACKAGE_PIN AD23 [get_ports IO_NAND_CH0_DQS_P]
set_property SLEW FAST [get_ports IO_NAND_CH0_DQS_P]
#set_property DRIVE 8 [get_ports IO_NAND_CH0_DQS_P]
#set_property PIO_DIRECTION BIDIR [get_ports IO_NAND_CH0_DQS_P]

set_property IOSTANDARD DIFF_SSTL18_II [get_ports IO_NAND_CH0_DQS_N]
set_property PACKAGE_PIN AE23 [get_ports IO_NAND_CH0_DQS_N]
set_property SLEW FAST [get_ports IO_NAND_CH0_DQS_N]
#set_property DRIVE 8 [get_ports IO_NAND_CH0_DQS_N]
#set_property PIO_DIRECTION BIDIR [get_ports IO_NAND_CH0_DQS_N]

set_property IOSTANDARD SSTL18_II [get_ports {I_NAND_CH0_RB[0]}]
set_property PACKAGE_PIN AC29 [get_ports {I_NAND_CH0_RB[0]}]
set_property SLEW FAST [get_ports {I_NAND_CH0_RB[0]}]
#set_property DRIVE 8 [get_ports {I_NAND_CH0_RB[0]}]
#set_property PIO_DIRECTION BIDIR [get_ports {I_NAND_CH0_RB[0]}]

set_property IOSTANDARD SSTL18_II [get_ports {I_NAND_CH0_RB[1]}]
set_property PACKAGE_PIN AD29 [get_ports {I_NAND_CH0_RB[1]}]
set_property SLEW FAST [get_ports {I_NAND_CH0_RB[1]}]
#set_property DRIVE 8 [get_ports {I_NAND_CH0_RB[1]}]
#set_property PIO_DIRECTION BIDIR [get_ports {I_NAND_CH0_RB[1]}]

set_property IOSTANDARD SSTL18_II [get_ports {I_NAND_CH0_RB[2]}]
set_property PACKAGE_PIN AA30 [get_ports {I_NAND_CH0_RB[2]}]
set_property SLEW FAST [get_ports {I_NAND_CH0_RB[2]}]
#set_property DRIVE 8 [get_ports {I_NAND_CH0_RB[2]}]
#set_property PIO_DIRECTION BIDIR [get_ports {I_NAND_CH0_RB[2]}]

set_property IOSTANDARD SSTL18_II [get_ports {I_NAND_CH0_RB[3]}]
set_property PACKAGE_PIN AB29 [get_ports {I_NAND_CH0_RB[3]}]
set_property SLEW FAST [get_ports {I_NAND_CH0_RB[3]}]
#set_property DRIVE 8 [get_ports {I_NAND_CH0_RB[3]}]
#set_property PIO_DIRECTION BIDIR [get_ports {I_NAND_CH0_RB[3]}]

set_property IOSTANDARD SSTL18_II [get_ports {I_NAND_CH0_RB[4]}]
set_property PACKAGE_PIN AB30 [get_ports {I_NAND_CH0_RB[4]}]
set_property SLEW FAST [get_ports {I_NAND_CH0_RB[4]}]
#set_property DRIVE 8 [get_ports {I_NAND_CH0_RB[4]}]
#set_property PIO_DIRECTION BIDIR [get_ports {I_NAND_CH0_RB[4]}]

set_property IOSTANDARD SSTL18_II [get_ports {I_NAND_CH0_RB[5]}]
set_property PACKAGE_PIN Y26 [get_ports {I_NAND_CH0_RB[5]}]
set_property SLEW FAST [get_ports {I_NAND_CH0_RB[5]}]
#set_property DRIVE 8 [get_ports {I_NAND_CH0_RB[5]}]
#set_property PIO_DIRECTION BIDIR [get_ports {I_NAND_CH0_RB[5]}]

set_property IOSTANDARD SSTL18_II [get_ports {I_NAND_CH0_RB[6]}]
set_property PACKAGE_PIN Y27 [get_ports {I_NAND_CH0_RB[6]}]
set_property SLEW FAST [get_ports {I_NAND_CH0_RB[6]}]
#set_property DRIVE 8 [get_ports {I_NAND_CH0_RB[6]}]
#set_property PIO_DIRECTION BIDIR [get_ports {I_NAND_CH0_RB[6]}]

set_property IOSTANDARD SSTL18_II [get_ports {I_NAND_CH0_RB[7]}]
set_property PACKAGE_PIN Y28 [get_ports {I_NAND_CH0_RB[7]}]
set_property SLEW FAST [get_ports {I_NAND_CH0_RB[7]}]
#set_property DRIVE 8 [get_ports {I_NAND_CH0_RB[7]}]
#set_property PIO_DIRECTION BIDIR [get_ports {I_NAND_CH0_RB[7]}]

set_property IOSTANDARD LVCMOS18 [get_ports O_NAND_CH0_WP]
set_property PACKAGE_PIN AG22 [get_ports O_NAND_CH0_WP]
set_property SLEW SLOW [get_ports O_NAND_CH0_WP]
#set_property DRIVE 8 [get_ports O_NAND_CH0_WP]
#set_property PIO_DIRECTION BIDIR [get_ports O_NAND_CH0_WP]

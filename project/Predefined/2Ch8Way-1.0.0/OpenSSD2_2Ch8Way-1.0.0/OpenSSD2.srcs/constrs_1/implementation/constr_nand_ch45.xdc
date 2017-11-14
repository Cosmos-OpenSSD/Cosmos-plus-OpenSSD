##################################################################################
## constr_nand_CH41 for Cosmos OpenSSD
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
## Design Name: constr_nand_ch45
## File Name: constr_nand_ch45.xdc
##
## Version: v1.0.0
##
## Description: xdc constraints for nand channel 4 and 5
##
##################################################################################

##################################################################################
## Revision History:
##
## * v1.0.0
##   - first draft 
##################################################################################

# Common, MMCM
# (begin)
create_generated_clock -name MMCM4_GEN200M_Clock -source [get_pins CH4MMCMC1H200/inst/clk_in1] -add -master_clock clk_fpga_1 -multiply_by 2 [get_pins CH4MMCMC1H200/inst/clk_out1]
# (end)

# CH4, fixing FPGA internal blocks
# (begin)
set_property BEL IN_FIFO [get_cells V2NFC100DDR_4/inst/Inst_NPhy_Toggle_Top/Inst_NPhy_Toggle_Physical_Input/Inst_DQINFIFO4x4]
set_property LOC IN_FIFO_X1Y19 [get_cells V2NFC100DDR_4/inst/Inst_NPhy_Toggle_Top/Inst_NPhy_Toggle_Physical_Input/Inst_DQINFIFO4x4]
#set_property BEL BUFR [get_cells V2NFC100DDR_4/inst/Inst_NPhy_Toggle_Top/Inst_NPhy_Toggle_Physical_Input/Inst_DQSCLOCK]
#set_property LOC BUFR_X1Y19 [get_cells V2NFC100DDR_4/inst/Inst_NPhy_Toggle_Top/Inst_NPhy_Toggle_Physical_Input/Inst_DQSCLOCK]
# (end)

# CH4, Input side
# (begin)
create_clock -period 10 -name CH4_DQSFromNAND_Clock [get_ports {IO_NAND_CH4_DQS_P}]
set_clock_uncertainty 0.6 [get_clocks CH4_DQSFromNAND_Clock]
set_clock_latency -source 0.5 [get_clocks CH4_DQSFromNAND_Clock]

set_input_delay            -clock [get_clocks CH4_DQSFromNAND_Clock] -max 6 [get_ports {IO_NAND_CH4_DQ[*]}]
set_input_delay -add_delay -clock [get_clocks CH4_DQSFromNAND_Clock] -clock_fall -max 6 [get_ports {IO_NAND_CH4_DQ[*]}]
set_input_delay -add_delay -clock [get_clocks CH4_DQSFromNAND_Clock] -min 4 [get_ports {IO_NAND_CH4_DQ[*]}]
set_input_delay -add_delay -clock [get_clocks CH4_DQSFromNAND_Clock] -clock_fall -min 4 [get_ports {IO_NAND_CH4_DQ[*]}]
# (end)

# CH4, Output side
# (begin)
create_generated_clock -name CH4_DQSToNAND_Clock -source [get_pins CH4MMCMC1H200/inst/clk_out1] -multiply_by 1 -add -master_clock MMCM4_GEN200M_Clock [get_pins V2NFC100DDR_4/inst/Inst_NPhy_Toggle_Top/Inst_NPhy_Toggle_Physical_Output/Inst_DQSOSERDES/OQ]
create_generated_clock -name CH4_DQSToNAND_ClockOut -source [get_pins V2NFC100DDR_4/inst/Inst_NPhy_Toggle_Top/Inst_NPhy_Toggle_Physical_Output/Inst_DQSOSERDES/OQ] -multiply_by 1 -add -master_clock CH4_DQSToNAND_Clock [get_ports {IO_NAND_CH4_DQS_P}]
set_false_path -from [get_clocks clk_fpga_1] -to [get_clocks CH4_DQSToNAND_ClockOut]
set_output_delay            -clock [get_clocks CH4_DQSToNAND_ClockOut] 1 [get_ports {IO_NAND_CH4_DQ[*]}]
set_output_delay -add_delay -clock [get_clocks CH4_DQSToNAND_ClockOut] -clock_fall 1 [get_ports {IO_NAND_CH4_DQ[*]}]

create_generated_clock -name CH4_WEToNAND_Clock -source [get_pins CH4MMCMC1H200/inst/clk_out1] -multiply_by 1 -add -master_clock MMCM4_GEN200M_Clock [get_ports {O_NAND_CH4_WE}]
set_output_delay            -clock [get_clocks CH4_WEToNAND_Clock] 1 [get_ports {O_NAND_CH4_CE[*]}]
set_output_delay            -clock [get_clocks CH4_WEToNAND_Clock] 1 [get_ports {O_NAND_CH4_ALE}]
set_output_delay -add_delay -clock [get_clocks CH4_WEToNAND_Clock] -clock_fall 1 [get_ports {O_NAND_CH4_ALE}]
set_output_delay            -clock [get_clocks CH4_WEToNAND_Clock] 1 [get_ports {O_NAND_CH4_CLE}]
set_output_delay -add_delay -clock [get_clocks CH4_WEToNAND_Clock] -clock_fall 1 [get_ports {O_NAND_CH4_CLE}]

create_generated_clock -name CH4_REToNAND_Clock -source [get_pins CH4MMCMC1H200/inst/clk_out1] -multiply_by 1 -add -master_clock MMCM4_GEN200M_Clock [get_ports {O_NAND_CH4_RE_P}]
set_false_path -from [get_clocks CH4_DQSToNAND_ClockOut] -to [get_clocks CH4_DQSFromNAND_Clock]
set_false_path -from [get_clocks CH4_DQSToNAND_ClockOut] -to [get_clocks clk_fpga_1]
set_false_path -from [get_clocks CH4_DQSFromNAND_Clock] -to [get_clocks CH4_DQSToNAND_ClockOut]
# (end)

set_property IODELAY_GROUP "BANK_4_IODELAY_GROUP" [get_cells V2NFC100DDR_4/inst/Inst_NPhy_Toggle_Top/Inst_NPhy_Toggle_Physical_Input/Inst_DQSIDELAYCTRL]
set_property IODELAY_GROUP "BANK_4_IODELAY_GROUP" [get_cells V2NFC100DDR_4/inst/Inst_NPhy_Toggle_Top/Inst_NPhy_Toggle_Physical_Input/Inst_DQSIDELAY]

# CH5, fixing FPGA internal blocks
# (begin)
set_property BEL IN_FIFO [get_cells V2NFC100DDR_5/inst/Inst_NPhy_Toggle_Top/Inst_NPhy_Toggle_Physical_Input/Inst_DQINFIFO4x4]
set_property LOC IN_FIFO_X1Y16 [get_cells V2NFC100DDR_5/inst/Inst_NPhy_Toggle_Top/Inst_NPhy_Toggle_Physical_Input/Inst_DQINFIFO4x4]
#set_property BEL BUFR [get_cells V2NFC100DDR_5/inst/Inst_NPhy_Toggle_Top/Inst_NPhy_Toggle_Physical_Input/Inst_DQSCLOCK]
#set_property LOC BUFR_X1Y16 [get_cells V2NFC100DDR_5/inst/Inst_NPhy_Toggle_Top/Inst_NPhy_Toggle_Physical_Input/Inst_DQSCLOCK]
# (end)

# CH5, Input side
# (begin)
create_clock -period 10 -name CH5_DQSFromNAND_Clock [get_ports {IO_NAND_CH5_DQS_P}]
set_clock_uncertainty 0.6 [get_clocks CH5_DQSFromNAND_Clock]
set_clock_latency -source 0.5 [get_clocks CH5_DQSFromNAND_Clock]

set_input_delay            -clock [get_clocks CH5_DQSFromNAND_Clock] -max 6 [get_ports {IO_NAND_CH5_DQ[*]}]
set_input_delay -add_delay -clock [get_clocks CH5_DQSFromNAND_Clock] -clock_fall -max 6 [get_ports {IO_NAND_CH5_DQ[*]}]
set_input_delay -add_delay -clock [get_clocks CH5_DQSFromNAND_Clock] -min 4 [get_ports {IO_NAND_CH5_DQ[*]}]
set_input_delay -add_delay -clock [get_clocks CH5_DQSFromNAND_Clock] -clock_fall -min 4 [get_ports {IO_NAND_CH5_DQ[*]}]
# (end)

# CH5, Output side
# (begin)
create_generated_clock -name CH5_DQSToNAND_Clock -source [get_pins CH4MMCMC1H200/inst/clk_out1] -multiply_by 1 -add -master_clock MMCM4_GEN200M_Clock [get_pins V2NFC100DDR_5/inst/Inst_NPhy_Toggle_Top/Inst_NPhy_Toggle_Physical_Output/Inst_DQSOSERDES/OQ]
create_generated_clock -name CH5_DQSToNAND_ClockOut -source [get_pins V2NFC100DDR_5/inst/Inst_NPhy_Toggle_Top/Inst_NPhy_Toggle_Physical_Output/Inst_DQSOSERDES/OQ] -multiply_by 1 -add -master_clock CH5_DQSToNAND_Clock [get_ports {IO_NAND_CH5_DQS_P}]
set_false_path -from [get_clocks clk_fpga_1] -to [get_clocks CH5_DQSToNAND_ClockOut]
set_output_delay            -clock [get_clocks CH5_DQSToNAND_ClockOut] 1 [get_ports {IO_NAND_CH5_DQ[*]}]
set_output_delay -add_delay -clock [get_clocks CH5_DQSToNAND_ClockOut] -clock_fall 1 [get_ports {IO_NAND_CH5_DQ[*]}]

create_generated_clock -name CH5_WEToNAND_Clock -source [get_pins CH4MMCMC1H200/inst/clk_out1] -multiply_by 1 -add -master_clock MMCM4_GEN200M_Clock [get_ports {O_NAND_CH5_WE}]
set_output_delay            -clock [get_clocks CH5_WEToNAND_Clock] 1 [get_ports {O_NAND_CH5_CE[*]}]
set_output_delay            -clock [get_clocks CH5_WEToNAND_Clock] 1 [get_ports {O_NAND_CH5_ALE}]
set_output_delay -add_delay -clock [get_clocks CH5_WEToNAND_Clock] -clock_fall 1 [get_ports {O_NAND_CH5_ALE}]
set_output_delay            -clock [get_clocks CH5_WEToNAND_Clock] 1 [get_ports {O_NAND_CH5_CLE}]
set_output_delay -add_delay -clock [get_clocks CH5_WEToNAND_Clock] -clock_fall 1 [get_ports {O_NAND_CH5_CLE}]

create_generated_clock -name CH5_REToNAND_Clock -source [get_pins CH4MMCMC1H200/inst/clk_out1] -multiply_by 1 -add -master_clock MMCM4_GEN200M_Clock [get_ports {O_NAND_CH5_RE_P}]
set_false_path -from [get_clocks CH5_DQSToNAND_ClockOut] -to [get_clocks CH5_DQSFromNAND_Clock]
set_false_path -from [get_clocks CH5_DQSToNAND_ClockOut] -to [get_clocks clk_fpga_1]
set_false_path -from [get_clocks CH5_DQSFromNAND_Clock] -to [get_clocks CH5_DQSToNAND_ClockOut]
# (end)

set_property IODELAY_GROUP {} [get_cells V2NFC100DDR_5/inst/Inst_NPhy_Toggle_Top/Inst_NPhy_Toggle_Physical_Input/Inst_DQSIDELAYCTRL]
set_property IODELAY_GROUP "BANK_4_IODELAY_GROUP" [get_cells V2NFC100DDR_5/inst/Inst_NPhy_Toggle_Top/Inst_NPhy_Toggle_Physical_Input/Inst_DQSIDELAY]

-- Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2014.4 (win64) Build 1071353 Tue Nov 18 18:29:27 MST 2014
-- Date        : Wed Apr 05 15:09:04 2017
-- Host        : DESKTOP-24JKT5C running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Cosmos-plus-OpenSSD-master/Cosmos-plus-OpenSSD-master/Source/IPRepo/IPRepo-1.0.0/Tiger4NSC/src/DPBDCFIFO16x128W_32x64R/DPBDCFIFO16x128W_32x64R_stub.vhdl
-- Design      : DPBDCFIFO16x128W_32x64R
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z045ffg900-3
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DPBDCFIFO16x128W_32x64R is
  Port ( 
    rst : in STD_LOGIC;
    wr_clk : in STD_LOGIC;
    rd_clk : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR ( 15 downto 0 );
    wr_en : in STD_LOGIC;
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR ( 31 downto 0 );
    full : out STD_LOGIC;
    empty : out STD_LOGIC;
    wr_data_count : out STD_LOGIC_VECTOR ( 6 downto 0 )
  );

end DPBDCFIFO16x128W_32x64R;

architecture stub of DPBDCFIFO16x128W_32x64R is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "rst,wr_clk,rd_clk,din[15:0],wr_en,rd_en,dout[31:0],full,empty,wr_data_count[6:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "fifo_generator_v12_0,Vivado 2014.4";
begin
end;

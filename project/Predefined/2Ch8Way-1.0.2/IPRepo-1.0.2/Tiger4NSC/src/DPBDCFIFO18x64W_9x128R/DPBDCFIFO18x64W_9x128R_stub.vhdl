-- Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2014.4 (win64) Build 1071353 Tue Nov 18 18:29:27 MST 2014
-- Date        : Wed Apr 05 15:08:14 2017
-- Host        : DESKTOP-24JKT5C running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               c:/Cosmos-plus-OpenSSD-master/Cosmos-plus-OpenSSD-master/Source/IPRepo/IPRepo-1.0.0/Tiger4NSC/src/DPBDCFIFO18x64W_9x128R/DPBDCFIFO18x64W_9x128R_stub.vhdl
-- Design      : DPBDCFIFO18x64W_9x128R
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7z045ffg900-3
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity DPBDCFIFO18x64W_9x128R is
  Port ( 
    rst : in STD_LOGIC;
    wr_clk : in STD_LOGIC;
    rd_clk : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR ( 17 downto 0 );
    wr_en : in STD_LOGIC;
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR ( 8 downto 0 );
    full : out STD_LOGIC;
    empty : out STD_LOGIC;
    wr_data_count : out STD_LOGIC_VECTOR ( 5 downto 0 )
  );

end DPBDCFIFO18x64W_9x128R;

architecture stub of DPBDCFIFO18x64W_9x128R is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "rst,wr_clk,rd_clk,din[17:0],wr_en,rd_en,dout[8:0],full,empty,wr_data_count[5:0]";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "fifo_generator_v12_0,Vivado 2014.4";
begin
end;

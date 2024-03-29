-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.2 (lin64) Build 3671981 Fri Oct 14 04:59:54 MDT 2022
-- Date        : Fri Sep  1 12:39:54 2023
-- Host        : eda01 running 64-bit Red Hat Enterprise Linux release 8.2 (Ootpa)
-- Command     : write_vhdl -force -mode synth_stub
--               /home/hynam/workspace/DRAM-Bender/projects/U280/U280.gen/sources_1/ip/axis_clock_converter/axis_clock_converter_stub.vhdl
-- Design      : axis_clock_converter
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xcu280-fsvh2892-2L-e
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity axis_clock_converter is
  Port ( 
    s_axis_aresetn : in STD_LOGIC;
    m_axis_aresetn : in STD_LOGIC;
    s_axis_aclk : in STD_LOGIC;
    s_axis_tvalid : in STD_LOGIC;
    s_axis_tready : out STD_LOGIC;
    s_axis_tdata : in STD_LOGIC_VECTOR ( 255 downto 0 );
    s_axis_tkeep : in STD_LOGIC_VECTOR ( 31 downto 0 );
    s_axis_tlast : in STD_LOGIC;
    m_axis_aclk : in STD_LOGIC;
    m_axis_tvalid : out STD_LOGIC;
    m_axis_tready : in STD_LOGIC;
    m_axis_tdata : out STD_LOGIC_VECTOR ( 255 downto 0 );
    m_axis_tkeep : out STD_LOGIC_VECTOR ( 31 downto 0 );
    m_axis_tlast : out STD_LOGIC
  );

end axis_clock_converter;

architecture stub of axis_clock_converter is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "s_axis_aresetn,m_axis_aresetn,s_axis_aclk,s_axis_tvalid,s_axis_tready,s_axis_tdata[255:0],s_axis_tkeep[31:0],s_axis_tlast,m_axis_aclk,m_axis_tvalid,m_axis_tready,m_axis_tdata[255:0],m_axis_tkeep[31:0],m_axis_tlast";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "axis_clock_converter_v1_1_28_axis_clock_converter,Vivado 2022.2";
begin
end;

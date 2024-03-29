// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.2 (lin64) Build 3671981 Fri Oct 14 04:59:54 MDT 2022
// Date        : Fri Sep  1 12:40:00 2023
// Host        : eda01 running 64-bit Red Hat Enterprise Linux release 8.2 (Ootpa)
// Command     : write_verilog -force -mode synth_stub
//               /home/hynam/workspace/DRAM-Bender/projects/U280/U280.gen/sources_1/ip/instr_blk_mem_sim/instr_blk_mem_sim_stub.v
// Design      : instr_blk_mem_sim
// Purpose     : Stub declaration of top-level module interface
// Device      : xcu280-fsvh2892-2L-e
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_5,Vivado 2022.2" *)
module instr_blk_mem_sim(clka, ena, wea, addra, dina, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[0:0],addra[9:0],dina[63:0],douta[63:0]" */;
  input clka;
  input ena;
  input [0:0]wea;
  input [9:0]addra;
  input [63:0]dina;
  output [63:0]douta;
endmodule

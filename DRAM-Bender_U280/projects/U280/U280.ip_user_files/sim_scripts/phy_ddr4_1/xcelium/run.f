-makelib xcelium_lib/xpm -sv \
  "/tools/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
  "/tools/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_fifo/hdl/xpm_fifo.sv" \
  "/tools/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \
-endlib
-makelib xcelium_lib/xpm \
  "/tools/Xilinx/Vivado/2020.2/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib xcelium_lib/microblaze_v11_0_4 \
  "../../../ipstatic/hdl/microblaze_v11_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/bd_0/ip/ip_0/sim/bd_9f2c_microblaze_I_0.vhd" \
-endlib
-makelib xcelium_lib/lib_cdc_v1_0_2 \
  "../../../ipstatic/hdl/lib_cdc_v1_0_rfs.vhd" \
-endlib
-makelib xcelium_lib/proc_sys_reset_v5_0_13 \
  "../../../ipstatic/hdl/proc_sys_reset_v5_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/bd_0/ip/ip_1/sim/bd_9f2c_rst_0_0.vhd" \
-endlib
-makelib xcelium_lib/lmb_v10_v3_0_11 \
  "../../../ipstatic/hdl/lmb_v10_v3_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/bd_0/ip/ip_2/sim/bd_9f2c_ilmb_0.vhd" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/bd_0/ip/ip_3/sim/bd_9f2c_dlmb_0.vhd" \
-endlib
-makelib xcelium_lib/lmb_bram_if_cntlr_v4_0_19 \
  "../../../ipstatic/hdl/lmb_bram_if_cntlr_v4_0_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/bd_0/ip/ip_4/sim/bd_9f2c_dlmb_cntlr_0.vhd" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/bd_0/ip/ip_5/sim/bd_9f2c_ilmb_cntlr_0.vhd" \
-endlib
-makelib xcelium_lib/blk_mem_gen_v8_4_4 \
  "../../../ipstatic/simulation/blk_mem_gen_v8_4.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/bd_0/ip/ip_6/sim/bd_9f2c_lmb_bram_I_0.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/bd_0/ip/ip_7/sim/bd_9f2c_second_dlmb_cntlr_0.vhd" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/bd_0/ip/ip_8/sim/bd_9f2c_second_ilmb_cntlr_0.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/bd_0/ip/ip_9/sim/bd_9f2c_second_lmb_bram_I_0.v" \
-endlib
-makelib xcelium_lib/iomodule_v3_1_6 \
  "../../../ipstatic/hdl/iomodule_v3_1_vh_rfs.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/bd_0/ip/ip_10/sim/bd_9f2c_iomodule_0_0.vhd" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/bd_0/sim/bd_9f2c.v" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/ip_0/sim/phy_ddr4_microblaze_mcs.v" \
-endlib
-makelib xcelium_lib/xil_defaultlib -sv \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/ip_1/rtl/phy/phy_ddr4_phy_ddr4.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/ip_1/rtl/phy/ddr4_phy_v2_2_xiphy_behav.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/ip_1/rtl/phy/ddr4_phy_v2_2_xiphy.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/ip_1/rtl/iob/ddr4_phy_v2_2_iob_byte.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/ip_1/rtl/iob/ddr4_phy_v2_2_iob.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/ip_1/rtl/clocking/ddr4_phy_v2_2_pll.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_tristate_wrapper.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_riuor_wrapper.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_control_wrapper.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_byte_wrapper.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/ip_1/rtl/xiphy_files/ddr4_phy_v2_2_xiphy_bitslice_wrapper.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/ip_1/rtl/ip_top/phy_ddr4_phy.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/clocking/ddr4_v2_2_infrastructure.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/cal/ddr4_v2_2_cal_xsdb_bram.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/cal/ddr4_v2_2_cal_write.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/cal/ddr4_v2_2_cal_wr_byte.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/cal/ddr4_v2_2_cal_wr_bit.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/cal/ddr4_v2_2_cal_sync.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/cal/ddr4_v2_2_cal_read.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/cal/ddr4_v2_2_cal_rd_en.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/cal/ddr4_v2_2_cal_pi.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/cal/ddr4_v2_2_cal_mc_odt.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/cal/ddr4_v2_2_cal_debug_microblaze.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/cal/ddr4_v2_2_cal_cplx_data.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/cal/ddr4_v2_2_cal_cplx.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/cal/ddr4_v2_2_cal_config_rom.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/cal/ddr4_v2_2_cal_addr_decode.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/cal/ddr4_v2_2_cal_top.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/cal/ddr4_v2_2_cal_xsdb_arbiter.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/cal/ddr4_v2_2_cal.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/cal/ddr4_v2_2_chipscope_xsdb_slave.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/cal/ddr4_v2_2_dp_AB9.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/ip_top/phy_ddr4_ddr4.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/cal/phy_ddr4_ddr4_cal_riu.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/rtl/ip_top/phy_ddr4.sv" \
  "../../../../U280.gen/sources_1/ip/phy_ddr4_1/tb/microblaze_mcs_0.sv" \
-endlib
-makelib xcelium_lib/xil_defaultlib \
  glbl.v
-endlib


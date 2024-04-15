create_clock -period 10.000 [get_ports APB_0_PCLK_p]
#create_clock -period 10 [get_ports APB_0_PCLK]

create_clock -period 10.000 [get_ports AXI_ACLK_IN_0_p]

set_property IOSTANDARD DIFF_SSTL12 [get_ports APB_0_PCLK_p]
set_property PACKAGE_PIN BH6 [get_ports APB_0_PCLK_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports APB_0_PCLK_n]
set_property PACKAGE_PIN BJ6 [get_ports APB_0_PCLK_n]
#set_property IOSTANDARD LVCMOS18 [get_ports APB_0_PRESET_N]
#set_property PACKAGE_PIN L30       [get_ports APB_0_PRESET_N]

set_property IOSTANDARD DIFF_SSTL12 [get_ports AXI_ACLK_IN_0_n]
set_property PACKAGE_PIN F31 [get_ports AXI_ACLK_IN_0_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports AXI_ACLK_IN_0_p]
set_property PACKAGE_PIN G31 [get_ports AXI_ACLK_IN_0_p]
#set_property IOSTANDARD LVCMOS12 [get_ports AXI_ARESET_N_0]


set_property PACKAGE_PIN D32 [get_ports hbm_cattrip_output]
set_property IOSTANDARD LVCMOS18 [get_ports hbm_cattrip_output]

set_false_path -from [get_pins axi_rst_st0_n_reg/C] -to [get_pins *]
set_false_path -from [get_pins axi_rst_st0_n_reg/C] -to [get_pins *]
set_false_path -from [get_pins xdma_pcie_ep/u_xdma_0/inst/pcie4c_ip_i/inst/user_reset_reg/C] -to [get_pins *]
##set_false_path -from [get_pins axi_rst0_st0_n_reg_replica_8/C] -to [get_pins *]

##
## Project    : The Xilinx PCI Express DMA 
## File       : xilinx_pcie_xdma_ref_board.xdc
## Version    : 4.1
##-----------------------------------------------------------------------------
#
# User Configuration
# Link Width   - x8
# Link Speed   - Gen4
# Family       - virtexuplusHBM
# Part         - xcu280
# Package      - fsvh2892
# Speed grade  - -2L
#
# PCIe Block INT - 6
# PCIe Block STR - PCIE4C_X1Y0
#

# Xilinx Reference Board is AU280
###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################
##
## Free Running Clock is Required for IBERT/DRP operations.
##
#
#############################################################################################################
create_clock -name sys_clk -period 10 [get_ports sys_clk_p]
#
#############################################################################################################
set_false_path -from [get_ports sys_rst_n]
set_property PULLUP true [get_ports sys_rst_n]
set_property IOSTANDARD LVCMOS18 [get_ports sys_rst_n]
#
set_property PACKAGE_PIN BH26 [get_ports sys_rst_n]
#
set_property CONFIG_VOLTAGE 1.8 [current_design]
#
#############################################################################################################
#set_property PACKAGE_PIN AL14 [get_ports sys_clk_n]
#set_property PACKAGE_PIN AL15 [get_ports sys_clk_p]
set_property LOC [get_package_pins -of_objects [get_bels [get_sites -filter {NAME =~ *COMMON*} -of_objects [get_iobanks -of_objects [get_sites GTYE4_CHANNEL_X1Y15]]]/REFCLK0P]] [get_ports sys_clk_p]
set_property LOC [get_package_pins -of_objects [get_bels [get_sites -filter {NAME =~ *COMMON*} -of_objects [get_iobanks -of_objects [get_sites GTYE4_CHANNEL_X1Y15]]]/REFCLK0N]] [get_ports sys_clk_n]
#
#############################################################################################################
#############################################################################################################
#
#
# BITFILE/BITSTREAM compress options
#
#set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
#set_property BITSTREAM.CONFIG.BPI_SYNC_MODE Type1 [current_design]
#set_property CONFIG_MODE BPI16 [current_design]
#set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
#set_property BITSTREAM.CONFIG.UNUSEDPIN Pulldown [current_design]
#
#
set_false_path -to [get_pins -hier *sync_reg[0]/D]
#

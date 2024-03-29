

############################################################################
##
##   U280 - Master XDC 
##
############################################################################
#
# Bitstream Configuration
# ------------------------------------------------------------------------
set_property CONFIG_VOLTAGE 1.8 [current_design]
set_property BITSTREAM.CONFIG.CONFIGFALLBACK Enable [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 85.0 [current_design]
set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN disable [current_design]
set_property BITSTREAM.CONFIG.SPI_FALL_EDGE YES [current_design]
set_property BITSTREAM.CONFIG.UNUSEDPIN Pullup [current_design]
set_property BITSTREAM.CONFIG.SPI_32BIT_ADDR Yes [current_design]
# ------------------------------------------------------------------------




##------------------------------------------------------##
##  DRAM Bender
##------------------------------------------------------##

set_property DRIVE 8 [get_ports c0_ddr4_reset_n]
create_clock -period 10.000 [get_ports c0_sys_clk_p]
set_clock_groups -asynchronous -group [get_clocks c0_sys_clk_p -include_generated_clocks]
create_clock -period 10.000 -name refclk_100 [get_ports clk_ref_p]
set_clock_groups -asynchronous -group [get_clocks refclk_100 -include_generated_clocks]


set_property PACKAGE_PIN AR14             [get_ports clk_ref_n ]                    ;# Bank 225 - MGTREFCLK0N_225
set_property PACKAGE_PIN AR15             [get_ports clk_ref_p ]                    ;# Bank 225 - MGTREFCLK0P_225

set_property PACKAGE_PIN BH26             [get_ports pcie_rst]                      ;# Bank  67 VCCO - VCC1V8   - IO_L13P_T2L_N0_GC_QBC_67
set_property IOSTANDARD  LVCMOS18         [get_ports pcie_rst]                      ;# Bank  67 VCCO - VCC1V8   - IO_L13P_T2L_N0_GC_QBC_67

set_property PULLUP true [get_ports pcie_rst];

set_property PACKAGE_PIN L30              [get_ports sys_rst_l]                     ;# Bank  75 VCCO - VCC1V8   - IO_L2N_T0L_N3_75
set_property IOSTANDARD  LVCMOS18         [get_ports sys_rst_l]                     ;# Bank  75 VCCO - VCC1V8   - IO_L2N_T0L_N3_75



##------------------------------------------------------##
##  Pins for DDR4 PHY
##------------------------------------------------------##

#create_clock -name c0_sys_clock -period 10 [get_ports c0_sys_clk_p]

#create_clock -period 10.000 [get_ports c0_sys_clk_p]

set_property PACKAGE_PIN BJ43            [get_ports "c0_sys_clk_p"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L12P_T1U_N10_GC_A08_D24_65
set_property IOSTANDARD  DIFF_SSTL12_DCI [get_ports "c0_sys_clk_p"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L12P_T1U_N10_GC_A08_D24_65
set_property PACKAGE_PIN BJ44            [get_ports "c0_sys_clk_n"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L12N_T1U_N11_GC_A09_D25_65
set_property IOSTANDARD  DIFF_SSTL12_DCI [get_ports "c0_sys_clk_n"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L12N_T1U_N11_GC_A09_D25_65



#set_property PACKAGE_PIN L30       [get_ports "sys_rst"] ;# Bank  75 VCCO - VCC1V8   - IO_L2N_T0L_N3_75
#set_property IOSTANDARD  LVCMOS18  [get_ports "sys_rst"] ;# Bank  75 VCCO - VCC1V8   - IO_L2N_T0L_N3_75



#set_property PACKAGE_PIN D32 [get_ports hbm_cattrip_output]
#set_property IOSTANDARD LVCMOS18 [get_ports hbm_cattrip_output]


set_property PACKAGE_PIN BE51             [get_ports "c0_ddr4_dq[42]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L24N_T3U_N11_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[42]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L24N_T3U_N11_66
set_property PACKAGE_PIN BD51             [get_ports "c0_ddr4_dq[43]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L24P_T3U_N10_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[43]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L24P_T3U_N10_66
set_property PACKAGE_PIN BE50             [get_ports "c0_ddr4_dq[40]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L23N_T3U_N9_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[40]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L23N_T3U_N9_66
set_property PACKAGE_PIN BE49             [get_ports "c0_ddr4_dq[41]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L23P_T3U_N8_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[41]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L23P_T3U_N8_66
set_property PACKAGE_PIN BF48             [get_ports "c0_ddr4_dqs_c[10]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L22N_T3U_N7_DBC_AD0N_66
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[10]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L22N_T3U_N7_DBC_AD0N_66
set_property PACKAGE_PIN BF47             [get_ports "c0_ddr4_dqs_t[10]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L22P_T3U_N6_DBC_AD0P_66
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[10]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L22P_T3U_N6_DBC_AD0P_66
set_property PACKAGE_PIN BF52             [get_ports "c0_ddr4_dq[44]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L21N_T3L_N5_AD8N_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[44]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L21N_T3L_N5_AD8N_66
set_property PACKAGE_PIN BF51             [get_ports "c0_ddr4_dq[45]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L21P_T3L_N4_AD8P_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[45]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L21P_T3L_N4_AD8P_66
set_property PACKAGE_PIN BG50             [get_ports "c0_ddr4_dq[46]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L20N_T3L_N3_AD1N_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[46]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L20N_T3L_N3_AD1N_66
set_property PACKAGE_PIN BF50             [get_ports "c0_ddr4_dq[47]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L20P_T3L_N2_AD1P_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[47]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L20P_T3L_N2_AD1P_66
set_property PACKAGE_PIN BG49             [get_ports "c0_ddr4_dqs_c[11]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L19N_T3L_N1_DBC_AD9N_66
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[11]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L19N_T3L_N1_DBC_AD9N_66
set_property PACKAGE_PIN BG48             [get_ports "c0_ddr4_dqs_t[11]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L19P_T3L_N0_DBC_AD9P_66
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[11]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L19P_T3L_N0_DBC_AD9P_66
set_property PACKAGE_PIN BE54             [get_ports "c0_ddr4_dq[67]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L18N_T2U_N11_AD2N_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[67]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L18N_T2U_N11_AD2N_66
set_property PACKAGE_PIN BE53             [get_ports "c0_ddr4_dq[66]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L18P_T2U_N10_AD2P_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[66]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L18P_T2U_N10_AD2P_66
set_property PACKAGE_PIN BG54             [get_ports "c0_ddr4_dq[64]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L17N_T2U_N9_AD10N_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[64]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L17N_T2U_N9_AD10N_66
set_property PACKAGE_PIN BG53             [get_ports "c0_ddr4_dq[65]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L17P_T2U_N8_AD10P_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[65]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L17P_T2U_N8_AD10P_66
set_property PACKAGE_PIN BJ54             [get_ports "c0_ddr4_dqs_c[16]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L16N_T2U_N7_QBC_AD3N_66
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[16]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L16N_T2U_N7_QBC_AD3N_66
set_property PACKAGE_PIN BH54             [get_ports "c0_ddr4_dqs_t[16]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L16P_T2U_N6_QBC_AD3P_66
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[16]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L16P_T2U_N6_QBC_AD3P_66
set_property PACKAGE_PIN BK54             [get_ports "c0_ddr4_dq[70]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L15N_T2L_N5_AD11N_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[70]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L15N_T2L_N5_AD11N_66
set_property PACKAGE_PIN BK53             [get_ports "c0_ddr4_dq[71]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L15P_T2L_N4_AD11P_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[71]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L15P_T2L_N4_AD11P_66
set_property PACKAGE_PIN BH52             [get_ports "c0_ddr4_dq[68]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L14N_T2L_N3_GC_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[68]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L14N_T2L_N3_GC_66
set_property PACKAGE_PIN BG52             [get_ports "c0_ddr4_dq[69]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L14P_T2L_N2_GC_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[69]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L14P_T2L_N2_GC_66
set_property PACKAGE_PIN BJ53             [get_ports "c0_ddr4_dqs_c[17]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L13N_T2L_N1_GC_QBC_66
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[17]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L13N_T2L_N1_GC_QBC_66
set_property PACKAGE_PIN BJ52             [get_ports "c0_ddr4_dqs_t[17]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L13P_T2L_N0_GC_QBC_66
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[17]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L13P_T2L_N0_GC_QBC_66
set_property PACKAGE_PIN BH50             [get_ports "c0_ddr4_dq[48]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L12N_T1U_N11_GC_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[48]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L12N_T1U_N11_GC_66
set_property PACKAGE_PIN BH49             [get_ports "c0_ddr4_dq[51]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L12P_T1U_N10_GC_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[51]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L12P_T1U_N10_GC_66
set_property PACKAGE_PIN BJ51             [get_ports "c0_ddr4_dq[49]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L11N_T1U_N9_GC_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[49]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L11N_T1U_N9_GC_66
set_property PACKAGE_PIN BH51             [get_ports "c0_ddr4_dq[50]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L11P_T1U_N8_GC_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[50]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L11P_T1U_N8_GC_66
set_property PACKAGE_PIN BJ47             [get_ports "c0_ddr4_dqs_c[12]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L10N_T1U_N7_QBC_AD4N_66
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[12]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L10N_T1U_N7_QBC_AD4N_66
set_property PACKAGE_PIN BH47             [get_ports "c0_ddr4_dqs_t[12]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L10P_T1U_N6_QBC_AD4P_66
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[12]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L10P_T1U_N6_QBC_AD4P_66
set_property PACKAGE_PIN BJ49             [get_ports "c0_ddr4_dq[54]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L9N_T1L_N5_AD12N_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[54]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L9N_T1L_N5_AD12N_66
set_property PACKAGE_PIN BJ48             [get_ports "c0_ddr4_dq[55]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L9P_T1L_N4_AD12P_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[55]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L9P_T1L_N4_AD12P_66
set_property PACKAGE_PIN BK51             [get_ports "c0_ddr4_dq[53]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L8N_T1L_N3_AD5N_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[53]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L8N_T1L_N3_AD5N_66
set_property PACKAGE_PIN BK50             [get_ports "c0_ddr4_dq[52]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L8P_T1L_N2_AD5P_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[52]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L8P_T1L_N2_AD5P_66
set_property PACKAGE_PIN BK49             [get_ports "c0_ddr4_dqs_c[13]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L7N_T1L_N1_QBC_AD13N_66
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[13]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L7N_T1L_N1_QBC_AD13N_66
set_property PACKAGE_PIN BK48             [get_ports "c0_ddr4_dqs_t[13]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L7P_T1L_N0_QBC_AD13P_66
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[13]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L7P_T1L_N0_QBC_AD13P_66
set_property PACKAGE_PIN BL53             [get_ports "c0_ddr4_dq[33]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L6N_T0U_N11_AD6N_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[33]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L6N_T0U_N11_AD6N_66
set_property PACKAGE_PIN BL52             [get_ports "c0_ddr4_dq[34]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L6P_T0U_N10_AD6P_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[34]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L6P_T0U_N10_AD6P_66
set_property PACKAGE_PIN BM52             [get_ports "c0_ddr4_dq[32]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L5N_T0U_N9_AD14N_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[32]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L5N_T0U_N9_AD14N_66
set_property PACKAGE_PIN BL51             [get_ports "c0_ddr4_dq[35]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L5P_T0U_N8_AD14P_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[35]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L5P_T0U_N8_AD14P_66
set_property PACKAGE_PIN BM50             [get_ports "c0_ddr4_dqs_c[8]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L4N_T0U_N7_DBC_AD7N_66
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[8]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L4N_T0U_N7_DBC_AD7N_66
set_property PACKAGE_PIN BM49             [get_ports "c0_ddr4_dqs_t[8]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L4P_T0U_N6_DBC_AD7P_66
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[8]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L4P_T0U_N6_DBC_AD7P_66
set_property PACKAGE_PIN BN49             [get_ports "c0_ddr4_dq[38]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L3N_T0L_N5_AD15N_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[38]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L3N_T0L_N5_AD15N_66
set_property PACKAGE_PIN BM48             [get_ports "c0_ddr4_dq[39]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L3P_T0L_N4_AD15P_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[39]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L3P_T0L_N4_AD15P_66
set_property PACKAGE_PIN BN51             [get_ports "c0_ddr4_dq[37]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L2N_T0L_N3_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[37]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L2N_T0L_N3_66
set_property PACKAGE_PIN BN50             [get_ports "c0_ddr4_dq[36]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L2P_T0L_N2_66
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[36]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L2P_T0L_N2_66
set_property PACKAGE_PIN BP49             [get_ports "c0_ddr4_dqs_c[9]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L1N_T0L_N1_DBC_66
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[9]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L1N_T0L_N1_DBC_66
set_property PACKAGE_PIN BP48             [get_ports "c0_ddr4_dqs_t[9]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L1P_T0L_N0_DBC_66
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[9]"] ;# Bank  66 VCCO - VCC1V2_TOP - IO_L1P_T0L_N0_DBC_66
set_property PACKAGE_PIN BE44             [get_ports "c0_ddr4_adr[13]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L24N_T3U_N11_DOUT_CSO_B_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_adr[13]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L24N_T3U_N11_DOUT_CSO_B_65
set_property PACKAGE_PIN BE43             [get_ports "c0_ddr4_adr[14]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L24P_T3U_N10_EMCCLK_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_adr[14]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L24P_T3U_N10_EMCCLK_65
#set_property PACKAGE_PIN BD42             [get_ports "c0_ddr4_cs_n[2]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L23N_T3U_N9_PERSTN1_I2C_SDA_65
#set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_cs_n[2]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L23N_T3U_N9_PERSTN1_I2C_SDA_65
#set_property PACKAGE_PIN BC42             [get_ports "c0_ddr4_ALERT_n"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L23P_T3U_N8_I2C_SCLK_65
#set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_ALERT_n"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L23P_T3U_N8_I2C_SCLK_65
set_property PACKAGE_PIN BE46             [get_ports "c0_ddr4_odt[1]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L22N_T3U_N7_DBC_AD0N_D05_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_odt[1]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L22N_T3U_N7_DBC_AD0N_D05_65
set_property PACKAGE_PIN BE45             [get_ports "c0_ddr4_cs_n[1]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L22P_T3U_N6_DBC_AD0P_D04_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_cs_n[1]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L22P_T3U_N6_DBC_AD0P_D04_65
set_property PACKAGE_PIN BF43             [get_ports "c0_ddr4_adr[5]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L21N_T3L_N5_AD8N_D07_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_adr[5]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L21N_T3L_N5_AD8N_D07_65
set_property PACKAGE_PIN BF42             [get_ports "c0_ddr4_adr[3]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L21P_T3L_N4_AD8P_D06_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_adr[3]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L21P_T3L_N4_AD8P_D06_65
set_property PACKAGE_PIN BF46             [get_ports "c0_ddr4_adr[0]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L20N_T3L_N3_AD1N_D09_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_adr[0]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L20N_T3L_N3_AD1N_D09_65
set_property PACKAGE_PIN BF45             [get_ports "c0_ddr4_parity"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L20P_T3L_N2_AD1P_D08_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_parity"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L20P_T3L_N2_AD1P_D08_65
set_property PACKAGE_PIN BE41             [get_ports "c0_ddr4_bg[1]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L19N_T3L_N1_DBC_AD9N_D11_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_bg[1]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L19N_T3L_N1_DBC_AD9N_D11_65
set_property PACKAGE_PIN BD41             [get_ports "c0_ddr4_adr[11]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L19P_T3L_N0_DBC_AD9P_D10_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_adr[11]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L19P_T3L_N0_DBC_AD9P_D10_65
set_property PACKAGE_PIN BF41             [get_ports "c0_ddr4_bg[0]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_T3U_N12_PERSTN0_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_bg[0]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_T3U_N12_PERSTN0_65
set_property PACKAGE_PIN BH41             [get_ports "c0_ddr4_act_n"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_T2U_N12_CSI_ADV_B_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_act_n"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_T2U_N12_CSI_ADV_B_65
set_property PACKAGE_PIN BG45             [get_ports "c0_ddr4_adr[10]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L18N_T2U_N11_AD2N_D13_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_adr[10]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L18N_T2U_N11_AD2N_D13_65
set_property PACKAGE_PIN BG44             [get_ports "c0_ddr4_odt[0]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L18P_T2U_N10_AD2P_D12_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_odt[0]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L18P_T2U_N10_AD2P_D12_65
set_property PACKAGE_PIN BG43             [get_ports "c0_ddr4_adr[1]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L17N_T2U_N9_AD10N_D15_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_adr[1]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L17N_T2U_N9_AD10N_D15_65
set_property PACKAGE_PIN BG42             [get_ports "c0_ddr4_adr[6]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L17P_T2U_N8_AD10P_D14_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_adr[6]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L17P_T2U_N8_AD10P_D14_65
set_property PACKAGE_PIN BJ46             [get_ports "c0_ddr4_ck_c[0]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L16N_T2U_N7_QBC_AD3N_A01_D17_65
set_property IOSTANDARD  DIFF_SSTL12_DCI  [get_ports "c0_ddr4_ck_c[0]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L16N_T2U_N7_QBC_AD3N_A01_D17_65
set_property PACKAGE_PIN BH46             [get_ports "c0_ddr4_ck_t[0]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L16P_T2U_N6_QBC_AD3P_A00_D16_65
set_property IOSTANDARD  DIFF_SSTL12_DCI  [get_ports "c0_ddr4_ck_t[0]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L16P_T2U_N6_QBC_AD3P_A00_D16_65
#set_property PACKAGE_PIN BK41             [get_ports "c0_ddr4_ck_c[1]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L15N_T2L_N5_AD11N_A03_D19_65
#set_property IOSTANDARD  DIFF_SSTL12_DCI  [get_ports "c0_ddr4_ck_c[1]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L15N_T2L_N5_AD11N_A03_D19_65
#set_property PACKAGE_PIN BJ41             [get_ports "c0_ddr4_ck_t[1]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L15P_T2L_N4_AD11P_A02_D18_65
#set_property IOSTANDARD  DIFF_SSTL12_DCI  [get_ports "c0_ddr4_ck_t[1]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L15P_T2L_N4_AD11P_A02_D18_65
set_property PACKAGE_PIN BH45             [get_ports "c0_ddr4_ba[0]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L14N_T2L_N3_GC_A05_D21_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_ba[0]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L14N_T2L_N3_GC_A05_D21_65
set_property PACKAGE_PIN BH44             [get_ports "c0_ddr4_adr[16]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L14P_T2L_N2_GC_A04_D20_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_adr[16]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L14P_T2L_N2_GC_A04_D20_65
set_property PACKAGE_PIN BJ42             [get_ports "c0_ddr4_cke[1]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L13N_T2L_N1_GC_QBC_A07_D23_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_cke[1]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L13N_T2L_N1_GC_QBC_A07_D23_65
set_property PACKAGE_PIN BH42             [get_ports "c0_ddr4_cke[0]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L13P_T2L_N0_GC_QBC_A06_D22_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_cke[0]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L13P_T2L_N0_GC_QBC_A06_D22_65
#set_property PACKAGE_PIN BK44             [get_ports "c0_ddr4_cs_n[3]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L11N_T1U_N9_GC_A11_D27_65
#set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_cs_n[3]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L11N_T1U_N9_GC_A11_D27_65
set_property PACKAGE_PIN BK43             [get_ports "c0_ddr4_adr[8]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L11P_T1U_N8_GC_A10_D26_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_adr[8]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L11P_T1U_N8_GC_A10_D26_65
set_property PACKAGE_PIN BK46             [get_ports "c0_ddr4_cs_n[0]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L10N_T1U_N7_QBC_AD4N_A13_D29_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_cs_n[0]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L10N_T1U_N7_QBC_AD4N_A13_D29_65
set_property PACKAGE_PIN BK45             [get_ports "c0_ddr4_adr[2]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L10P_T1U_N6_QBC_AD4P_A12_D28_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_adr[2]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L10P_T1U_N6_QBC_AD4P_A12_D28_65
set_property PACKAGE_PIN BL43             [get_ports "c0_ddr4_adr[7]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L9N_T1L_N5_AD12N_A15_D31_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_adr[7]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L9N_T1L_N5_AD12N_A15_D31_65
set_property PACKAGE_PIN BL42             [get_ports "c0_ddr4_adr[12]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L9P_T1L_N4_AD12P_A14_D30_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_adr[12]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L9P_T1L_N4_AD12P_A14_D30_65
set_property PACKAGE_PIN BL46             [get_ports "c0_ddr4_adr[15]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L8N_T1L_N3_AD5N_A17_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_adr[15]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L8N_T1L_N3_AD5N_A17_65
set_property PACKAGE_PIN BL45             [get_ports "c0_ddr4_adr[4]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L8P_T1L_N2_AD5P_A16_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_adr[4]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L8P_T1L_N2_AD5P_A16_65
set_property PACKAGE_PIN BM47             [get_ports "c0_ddr4_ba[1]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L7N_T1L_N1_QBC_AD13N_A19_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_ba[1]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L7N_T1L_N1_QBC_AD13N_A19_65
set_property PACKAGE_PIN BL47             [get_ports "c0_ddr4_adr[17]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L7P_T1L_N0_QBC_AD13P_A18_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_adr[17]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L7P_T1L_N0_QBC_AD13P_A18_65
set_property PACKAGE_PIN BM42             [get_ports "c0_ddr4_adr[9]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_T1U_N12_SMBALERT_65
set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_adr[9]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_T1U_N12_SMBALERT_65
set_property PACKAGE_PIN BN45             [get_ports "c0_ddr4_dq[57]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L6N_T0U_N11_AD6N_A21_65
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[57]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L6N_T0U_N11_AD6N_A21_65
set_property PACKAGE_PIN BM45             [get_ports "c0_ddr4_dq[59]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L6P_T0U_N10_AD6P_A20_65
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[59]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L6P_T0U_N10_AD6P_A20_65
set_property PACKAGE_PIN BN44             [get_ports "c0_ddr4_dq[56]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L5N_T0U_N9_AD14N_A23_65
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[56]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L5N_T0U_N9_AD14N_A23_65
set_property PACKAGE_PIN BM44             [get_ports "c0_ddr4_dq[58]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L5P_T0U_N8_AD14P_A22_65
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[58]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L5P_T0U_N8_AD14P_A22_65
set_property PACKAGE_PIN BP46             [get_ports "c0_ddr4_dqs_c[14]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L4N_T0U_N7_DBC_AD7N_A25_65
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[14]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L4N_T0U_N7_DBC_AD7N_A25_65
set_property PACKAGE_PIN BN46             [get_ports "c0_ddr4_dqs_t[14]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L4P_T0U_N6_DBC_AD7P_A24_65
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[14]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L4P_T0U_N6_DBC_AD7P_A24_65
set_property PACKAGE_PIN BP44             [get_ports "c0_ddr4_dq[61]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L3N_T0L_N5_AD15N_A27_65
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[61]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L3N_T0L_N5_AD15N_A27_65
set_property PACKAGE_PIN BP43             [get_ports "c0_ddr4_dq[60]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L3P_T0L_N4_AD15P_A26_65
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[60]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L3P_T0L_N4_AD15P_A26_65
set_property PACKAGE_PIN BP47             [get_ports "c0_ddr4_dq[63]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L2N_T0L_N3_FWE_FCS2_B_65
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[63]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L2N_T0L_N3_FWE_FCS2_B_65
set_property PACKAGE_PIN BN47             [get_ports "c0_ddr4_dq[62]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L2P_T0L_N2_FOE_B_65
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[62]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L2P_T0L_N2_FOE_B_65
set_property PACKAGE_PIN BP42             [get_ports "c0_ddr4_dqs_c[15]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L1N_T0L_N1_DBC_RS1_65
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[15]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L1N_T0L_N1_DBC_RS1_65
set_property PACKAGE_PIN BN42             [get_ports "c0_ddr4_dqs_t[15]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L1P_T0L_N0_DBC_RS0_65
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[15]"] ;# Bank  65 VCCO - VCC1V2_TOP - IO_L1P_T0L_N0_DBC_RS0_65
set_property PACKAGE_PIN BJ31             [get_ports "c0_ddr4_dq[8]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L24N_T3U_N11_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[8]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L24N_T3U_N11_64
set_property PACKAGE_PIN BH31             [get_ports "c0_ddr4_dq[9]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L24P_T3U_N10_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[9]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L24P_T3U_N10_64
set_property PACKAGE_PIN BF33             [get_ports "c0_ddr4_dq[11]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L23N_T3U_N9_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[11]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L23N_T3U_N9_64
set_property PACKAGE_PIN BF32             [get_ports "c0_ddr4_dq[10]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L23P_T3U_N8_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[10]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L23P_T3U_N8_64
set_property PACKAGE_PIN BK30             [get_ports "c0_ddr4_dqs_c[2]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L22N_T3U_N7_DBC_AD0N_64
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[2]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L22N_T3U_N7_DBC_AD0N_64
set_property PACKAGE_PIN BJ29             [get_ports "c0_ddr4_dqs_t[2]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L22P_T3U_N6_DBC_AD0P_64
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[2]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L22P_T3U_N6_DBC_AD0P_64
set_property PACKAGE_PIN BG32             [get_ports "c0_ddr4_dq[15]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L21N_T3L_N5_AD8N_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[15]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L21N_T3L_N5_AD8N_64
set_property PACKAGE_PIN BF31             [get_ports "c0_ddr4_dq[14]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L21P_T3L_N4_AD8P_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[14]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L21P_T3L_N4_AD8P_64
set_property PACKAGE_PIN BH30             [get_ports "c0_ddr4_dq[13]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L20N_T3L_N3_AD1N_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[13]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L20N_T3L_N3_AD1N_64
set_property PACKAGE_PIN BH29             [get_ports "c0_ddr4_dq[12]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L20P_T3L_N2_AD1P_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[12]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L20P_T3L_N2_AD1P_64
set_property PACKAGE_PIN BG30             [get_ports "c0_ddr4_dqs_c[3]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L19N_T3L_N1_DBC_AD9N_64
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[3]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L19N_T3L_N1_DBC_AD9N_64
set_property PACKAGE_PIN BG29             [get_ports "c0_ddr4_dqs_t[3]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L19P_T3L_N0_DBC_AD9P_64
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[3]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L19P_T3L_N0_DBC_AD9P_64
#set_property PACKAGE_PIN BK29             [get_ports "c0_ddr4_EVENT_B"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_T3U_N12_64
#set_property IOSTANDARD  SSTL12_DCI       [get_ports "c0_ddr4_EVENT_B"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_T3U_N12_64
set_property PACKAGE_PIN BG33             [get_ports "c0_ddr4_reset_n"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_T2U_N12_64
set_property IOSTANDARD  LVCMOS12         [get_ports "c0_ddr4_reset_n"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_T2U_N12_64
set_property PACKAGE_PIN BH35             [get_ports "c0_ddr4_dq[25]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L18N_T2U_N11_AD2N_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[25]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L18N_T2U_N11_AD2N_64
set_property PACKAGE_PIN BH34             [get_ports "c0_ddr4_dq[24]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L18P_T2U_N10_AD2P_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[24]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L18P_T2U_N10_AD2P_64
set_property PACKAGE_PIN BF36             [get_ports "c0_ddr4_dq[27]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L17N_T2U_N9_AD10N_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[27]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L17N_T2U_N9_AD10N_64
set_property PACKAGE_PIN BF35             [get_ports "c0_ddr4_dq[26]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L17P_T2U_N8_AD10P_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[26]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L17P_T2U_N8_AD10P_64
set_property PACKAGE_PIN BK35             [get_ports "c0_ddr4_dqs_c[6]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L16N_T2U_N7_QBC_AD3N_64
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[6]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L16N_T2U_N7_QBC_AD3N_64
set_property PACKAGE_PIN BK34             [get_ports "c0_ddr4_dqs_t[6]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L16P_T2U_N6_QBC_AD3P_64
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[6]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L16P_T2U_N6_QBC_AD3P_64
set_property PACKAGE_PIN BG35             [get_ports "c0_ddr4_dq[31]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L15N_T2L_N5_AD11N_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[31]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L15N_T2L_N5_AD11N_64
set_property PACKAGE_PIN BG34             [get_ports "c0_ddr4_dq[30]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L15P_T2L_N4_AD11P_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[30]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L15P_T2L_N4_AD11P_64
set_property PACKAGE_PIN BJ34             [get_ports "c0_ddr4_dq[29]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L14N_T2L_N3_GC_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[29]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L14N_T2L_N3_GC_64
set_property PACKAGE_PIN BJ33             [get_ports "c0_ddr4_dq[28]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L14P_T2L_N2_GC_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[28]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L14P_T2L_N2_GC_64
set_property PACKAGE_PIN BJ32             [get_ports "c0_ddr4_dqs_c[7]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L13N_T2L_N1_GC_QBC_64
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[7]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L13N_T2L_N1_GC_QBC_64
set_property PACKAGE_PIN BH32             [get_ports "c0_ddr4_dqs_t[7]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L13P_T2L_N0_GC_QBC_64
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[7]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L13P_T2L_N0_GC_QBC_64
set_property PACKAGE_PIN BL33             [get_ports "c0_ddr4_dq[19]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L12N_T1U_N11_GC_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[19]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L12N_T1U_N11_GC_64
set_property PACKAGE_PIN BK33             [get_ports "c0_ddr4_dq[18]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L12P_T1U_N10_GC_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[18]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L12P_T1U_N10_GC_64
set_property PACKAGE_PIN BL31             [get_ports "c0_ddr4_dq[17]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L11N_T1U_N9_GC_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[17]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L11N_T1U_N9_GC_64
set_property PACKAGE_PIN BK31             [get_ports "c0_ddr4_dq[16]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L11P_T1U_N8_GC_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[16]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L11P_T1U_N8_GC_64
set_property PACKAGE_PIN BM35             [get_ports "c0_ddr4_dqs_c[4]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L10N_T1U_N7_QBC_AD4N_64
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[4]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L10N_T1U_N7_QBC_AD4N_64
set_property PACKAGE_PIN BL35             [get_ports "c0_ddr4_dqs_t[4]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L10P_T1U_N6_QBC_AD4P_64
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[4]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L10P_T1U_N6_QBC_AD4P_64
set_property PACKAGE_PIN BM33             [get_ports "c0_ddr4_dq[21]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L9N_T1L_N5_AD12N_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[21]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L9N_T1L_N5_AD12N_64
set_property PACKAGE_PIN BL32             [get_ports "c0_ddr4_dq[20]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L9P_T1L_N4_AD12P_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[20]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L9P_T1L_N4_AD12P_64
set_property PACKAGE_PIN BP34             [get_ports "c0_ddr4_dq[23]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L8N_T1L_N3_AD5N_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[23]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L8N_T1L_N3_AD5N_64
set_property PACKAGE_PIN BN34             [get_ports "c0_ddr4_dq[22]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L8P_T1L_N2_AD5P_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[22]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L8P_T1L_N2_AD5P_64
set_property PACKAGE_PIN BN35             [get_ports "c0_ddr4_dqs_c[5]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L7N_T1L_N1_QBC_AD13N_64
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[5]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L7N_T1L_N1_QBC_AD13N_64
set_property PACKAGE_PIN BM34             [get_ports "c0_ddr4_dqs_t[5]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L7P_T1L_N0_QBC_AD13P_64
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[5]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L7P_T1L_N0_QBC_AD13P_64
set_property PACKAGE_PIN BP32             [get_ports "c0_ddr4_dq[1]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L6N_T0U_N11_AD6N_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[1]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L6N_T0U_N11_AD6N_64
set_property PACKAGE_PIN BN32             [get_ports "c0_ddr4_dq[0]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L6P_T0U_N10_AD6P_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[0]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L6P_T0U_N10_AD6P_64
set_property PACKAGE_PIN BM30             [get_ports "c0_ddr4_dq[3]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L5N_T0U_N9_AD14N_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[3]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L5N_T0U_N9_AD14N_64
set_property PACKAGE_PIN BL30             [get_ports "c0_ddr4_dq[2]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L5P_T0U_N8_AD14P_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[2]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L5P_T0U_N8_AD14P_64
set_property PACKAGE_PIN BN30             [get_ports "c0_ddr4_dqs_c[0]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L4N_T0U_N7_DBC_AD7N_64
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[0]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L4N_T0U_N7_DBC_AD7N_64
set_property PACKAGE_PIN BN29             [get_ports "c0_ddr4_dqs_t[0]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L4P_T0U_N6_DBC_AD7P_64
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[0]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L4P_T0U_N6_DBC_AD7P_64
set_property PACKAGE_PIN BP31             [get_ports "c0_ddr4_dq[6]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L3N_T0L_N5_AD15N_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[6]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L3N_T0L_N5_AD15N_64
set_property PACKAGE_PIN BN31             [get_ports "c0_ddr4_dq[7]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L3P_T0L_N4_AD15P_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[7]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L3P_T0L_N4_AD15P_64
set_property PACKAGE_PIN BP29             [get_ports "c0_ddr4_dq[4]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L2N_T0L_N3_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[4]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L2N_T0L_N3_64
set_property PACKAGE_PIN BP28             [get_ports "c0_ddr4_dq[5]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L2P_T0L_N2_64
set_property IOSTANDARD  POD12_DCI        [get_ports "c0_ddr4_dq[5]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L2P_T0L_N2_64
set_property PACKAGE_PIN BM29             [get_ports "c0_ddr4_dqs_c[1]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L1N_T0L_N1_DBC_64
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_c[1]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L1N_T0L_N1_DBC_64
set_property PACKAGE_PIN BM28             [get_ports "c0_ddr4_dqs_t[1]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L1P_T0L_N0_DBC_64
set_property IOSTANDARD  DIFF_POD12_DCI   [get_ports "c0_ddr4_dqs_t[1]"] ;# Bank  64 VCCO - VCC1V2_TOP - IO_L1P_T0L_N0_DBC_64
#set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_pins -hier -filter {NAME =~ */*/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKIN1}]




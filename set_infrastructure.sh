# copy files from DRAM-Bender_U280
cp DRAM-Bender_U280/prebuilt/programFPGA.sh DRAM-Bender/prebuilt/ 
cp DRAM-Bender_U280/prebuilt/programFPGA.tcl DRAM-Bender/prebuilt/
cp DRAM-Bender_U280/prebuilt/run.sh DRAM-Bender/prebuilt/
cp -r DRAM-Bender_U280/prebuilt/U280 DRAM-Bender/prebuilt/

# copy files from SoftMC_hbm
cp SoftMC_hbm2/prebuilt/hbm2_35ns_10k.bit SoftMC/prebuilt/    
cp SoftMC_hbm2/prebuilt/programFPGA.sh SoftMC/prebuilt/    
cp SoftMC_hbm2/prebuilt/RowHammer.sh SoftMC/prebuilt/ 
cp SoftMC_hbm2/prebuilt/hbm2_7800ns_1k.bit SoftMC/prebuilt/   
cp SoftMC_hbm2/prebuilt/programFPGA.tcl SoftMC/prebuilt/ 
cp SoftMC_hbm2/prebuilt/RowPress.sh SoftMC/prebuilt/ 
cp -r SoftMC_hbm2/sw/basic SoftMC/sw/
cp -r SoftMC_hbm2/sw/Reset/ SoftMC/sw/
cp -r SoftMC_hbm2/sw/SoftMC_API/ SoftMC/sw/
cp -r SoftMC_hbm2/sw/xdma_driver/ SoftMC/sw/
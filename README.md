# Artifact Evaluation for "DRAMScope: Uncovering DRAM Microarchitecture and Characteristics by Issuing Memory Commands", ISCA 2024.
This repository contains artifact and workflows for reproducing the experiments presented in the ISCA 2024 paper by H. Nam et al.

## Contents
This repository contains **DDR4** and **HBM2** directories, and each consist of below subdirectories.
1. **RowHammer attack**. (Related to Fig. 7, 9, 10, 12, 13, and 16)
2. **RowCopy operation**. (Related to Table. 3)
3. **Retention time test**. (Related to Section III.B)
4. **RowPress attack**. (Related to Fig. 12 and 13)

## Hardware prerequisities
We has been successfully tested on:

### CPU
- Intel(R) Core(R) CPU i5-7500 @ 3.40GHz (Kaby Lake)
- Intel(R) Xeon(R) CPU i5-8400 @ 2.80GHz (Coffee Lake)

### FPGA
- AMD Alveo<sup><sub>TM</sub></sup> U200 ([link](https://www.xilinx.com/products/boards-and-kits/alveo/u200.html)).
- AMD Alveo<sup><sub>TM</sub></sup> U280 ([link](https://www.xilinx.com/products/boards-and-kits/alveo/u280.html)).


## Software prerequisities

- Ubuntu 18.04 (Linux kernel 5.4.0-150-generic)
- GNU Make 4.1+.
- C++14 build toolchain.
- Python 3.6.9+.
- AMD Vivado<sup><small>TM</small></sup> 2020.2 ([link](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/archive.html)).
- `pip` packages: `matplotlib` and `seaborn`.

## How to install
We use modified FPGA-based infrastructures (**SoftMC** and **DRAM Bender**).
- **SoftMC**: [https://github.com/CMU-SAFARI/SoftMC.git](https://github.com/CMU-SAFARI/SoftMC.git) (Hasan Hassan, Nandita Vijaykumar, Samira Khan, Saugata Ghose, Kevin Chang, Gennady Pekhimenko, Donghyuk Lee, Oguz Ergin, and Onur Mutlu, "SoftMC: A Flexible and Practical Open-Source Infrastructure for Enabling Experimental DRAM Studies" Proceedings of the 23rd International Symposium on High-Performance Computer Architecture (HPCA), Austin, TX, USA, February 2017.)
- **DRAM Bender**: [https://github.com/CMU-SAFARI/DRAM-Bender.git](https://github.com/CMU-SAFARI/DRAM-Bender.git) (A. Olgun, H. Hassan, A. G. Yaglikci, Y. C. Tugrul, L. Orosa, H. Luo, M. Patel, O. Ergin, O. Mutlu, "DRAM Bender: An Extensible and Versatile FPGA-based Infrastructure to Easily Test State-of-the-art DRAM Chips", IEEE TCAD, June 2023.)


1. Clone the Github repository.
```
$ git clone https://github.com/scale-snu/AE_ISCA2024_DRAMScope.git
$ cd AE_ISCA2024_DRAMScope
$ git submodule update --init --recursive
```

2. Patch modified SoftMC and DRAM-Bender.
```
$ bash set_infrastucture.sh
```

## How to program
We provide bitstream files for AMD Alveo<sup><sub>TM</sub></sup> U280. 

### DDR4
1. Programming the prebuilt bitstream.
```
$ cd DRAM-Bender/prebuilt
$ ./run.sh
```
2. Reboot the computer.
```
$ sudo reboot
```

3. After rebooting, load the AMD XDMA driver.
```
$ cd DRAM-Bender/sources/xdma_driver
$ sudo ./load_driver.sh
```

4. If the following 3 lines appear on the screen, the setup is complete.
```
Loading xdma driver...
The Kernel module installed correctly and the xmda devices were recognized.
DONE
```

### HBM2
1. Programming the prebuilt bitstream.
- If you want to test **RowHammer, RowCopy, or Retention,**
```
$ cd SoftMC/prebuilt
$ ./RowHammer.sh
```
- If you want to test **RowPress**,
```
$ cd SoftMC/prebuilt
$ ./RowPress.sh
```

2. Reboot the computer.
```
$ sudo reboot
```

3. After rebooting, load the AMD XDMA driver.
```
$ cd SoftMC/sw/xdma_driver
$ sudo ./load_driver.sh
```

4. If the following 3 lines appear on the screen, the setup is complete.
```
Loading xdma driver...
The Kernel module installed correctly and the xmda devices were recognized.
DONE
```

5. Set the mode registers
```
$ cd HBM2/0_SIMPLE_TEST
$ sudo ./run.sh
```

6. If the following 3 lines appear on the screen, it's complete.
```
=====================
===    Success    ===
=====================
```


## Reproducing DRAMScope
### DDR4
1) **RowHammer attack**  
Please refer to [DDR4/1_ROWHAMMER/README.md](DDR4/1_ROWHAMMER/README.md).
2) **RowCopy operation**  
Please refer to [DDR4/2_ROWCOPY/README.md](DDR4/2_ROWCOPY/README.md).
3) **Retention time test**  
Please refer to [DDR4/3_RETENTION/README.md](DDR4/3_RETENTION/README.md).
4) **RowPress attack**  
Please refer to [DDR4/4_ROWPRESS/README.md](DDR4/4_ROWPRESS/README.md).
### HBM2
1) **RowHammer attack**  
Please refer to [HBM2/1_ROWHAMMER/README.md](HBM2/1_ROWHAMMER/README.md).
2) **RowCopy operation**  
Please refer to [HBM2/2_ROWCOPY/README.md](HBM2/2_ROWCOPY/README.md).
3) **Retention time test**  
Please refer to [HBM2/3_RETENTION/README.md](HBM2/3_RETENTION/README.md).
4) **RowPress attack**  
Please refer to [HBM2/4_ROWPRESS/README.md](HBM2/4_ROWPRESS/README.md).

## Contact
Hwayong Nam ([hwayong.nam@scale.snu.ac.kr](hwayong.nam@scale.snu.ac.kr))  

Seungmin Beak ([seungmin.baek@scale.snu.ac.kr](seungmin.baek@scale.snu.ac.kr))     

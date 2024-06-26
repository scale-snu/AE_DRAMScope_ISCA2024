#include "softmc.h"

// here is a set of instructions inserted to FPGA

Instruction set_instrs[128]= {//18 + 104 (extra) // fifo depth = 128
  // mrs setting // 19 instr
  setMRS(0,0,0x00),
  genWAIT(15),
  setMRS(0,1,0x50),
  genWAIT(15),
  setMRS(0,2,0x96),
  genWAIT(15),
  setMRS(0,3,0xE1),
  genWAIT(15),
  setMRS(0,4,0x00),
  genWAIT(15),
  setMRS(0,5,0x00),
  genWAIT(15),
  setMRS(0,6,0x60),
  genWAIT(15),
  setMRS(0,7,0x02),
  genWAIT(15),
  setMRS(0,15,0x00),
  genWAIT(15),

  // user instructions // 76 
  genACT(0, 0, 0, 0, 0, 0xA0),
  genWAIT(2),
  genACT(0, 0, 0, 1, 1, 0xA1),
  genWAIT(2),
  genACT(0, 0, 0, 2, 2, 0xA2),
  genACT(0, 0, 1, 0, 0, 0xB0),
  genWAIT(2),
  genACT(0, 0, 1, 1, 1, 0xB1),
  genWAIT(2),
  genACT(0, 0, 1, 2, 2, 0xB2),
  genWR(0, 0, 0, 0, 0, 0xA, 0x11),
  genWAIT(2),
  genWR(0, 0, 0, 1, 1, 0xB, 0x22),
  genWAIT(2),
  genWR(0, 0, 0, 2, 2, 0xC, 0x33),
  genWAIT(2),
  genWR(0, 0, 1, 0, 0, 0xA, 0x44),
  genWAIT(2),
  genWR(0, 0, 1, 1, 1, 0xB, 0x55),
  genWAIT(2),
  genWR(0, 0, 1, 2, 2, 0xC, 0x66),
  genWAIT(2),
  genWAIT(20),
  genPRE(0, 0, 0, 0, 0),
  genPRE(0, 0, 0, 1, 1),
  genPRE(0, 0, 0, 2, 2),
  genPRE(0, 0, 1, 0, 0),
  genPRE(0, 0, 1, 1, 1),
  genPRE(0, 0, 1, 2, 2),
  
  
  genWAIT(20),
  genACT(0, 0, 0, 0, 0, 0xA0),
  genWAIT(2),
  genACT(0, 0, 0, 1, 1, 0xA1),
  genWAIT(2),
  genACT(0, 0, 0, 2, 2, 0xA2),
  genWAIT(2),
  genACT(0, 0, 1, 0, 0, 0xB0),
  genWAIT(2),
  genACT(0, 0, 1, 1, 1, 0xB1),
  genWAIT(2),
  genACT(0, 0, 1, 2, 2, 0xB2),
  genWAIT(2),
  genWAIT(2),
  genRD(0, 0, 0, 0, 0, 0xA),
  genWAIT(4),
  genRD(0, 0, 0, 1, 1, 0xB),
  genWAIT(4),
  genRD(0, 0, 0, 2, 2, 0xC),
  genWAIT(4),
  genRD(0, 0, 1, 0, 0, 0xA),
  genWAIT(4),
  genRD(0, 0, 1, 1, 1, 0xB), 
  genWAIT(4),
  genRD(0, 0, 1, 2, 2, 0xC),
  genWAIT(4),
  
  genWAIT(20), /// added below
  genPRE(0, 0, 0, 0, 0),
  genPRE(0, 0, 0, 1, 1),
  genPRE(0, 0, 0, 2, 2),
  genPRE(0, 0, 1, 0, 0),
  genPRE(0, 0, 1, 1, 1),
  genPRE(0, 0, 1, 2, 2),
  
  genWAIT(20),
  genWAIT(1),
  genWAIT(1),
  genWAIT(1),
  genWAIT(1),
  genWAIT(1),
  genWAIT(1),
  genWAIT(1),
  genWAIT(1),
  genWAIT(1),
  genEND()
};

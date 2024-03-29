#ifndef IN_MEMORY_H_
#define IN_MEMORY_H_

#include <iostream>
#include <cstring>
#include <cstdio>
#include <cassert>
#include <cmath>

#include "xdma.h"
#include "softmc.h"

////////// parameters ///////////

#define tCK       4    // 250MHz
#define tCKmin    1
#define tRCDWR    10      // ACT to Write
#define tRCDRD    14      // ACT to Read
#define tRAS      33      // Row Active Time, ACT to PRE
#define tRP       14      // Row Precharge Time
#define tRC       47      // Row Cycle Time, Row Cycle Time, ACT to ACT, tRAS + tRP
#define tWR       15      // Write Recovery Time, Write burst end -> PRE
#define tRRDS     4    
#define tRRDL     4    
#define tFAW      16    
#define tMRD      8   
#define tCCDS     4   
#define tCCDL     5   
#define tMOD      15    
#define tPREFD    8    
#define tRFCSB    160    
#define tCPDED    2    
#define tWTRL     7.5    
#define tWTRS     2.5    
#define tCL       0.5     // 0.47 < tCL < 0.53
#define tCH       0.5     // 0.47 < tCH < 0.53 
#define WL        7
#define RL        18

#define tRTP      23      // tRAS - tRCDWR ??


void printHelp(char* argv[]);

int to_cycle(int timing);

void writeRow(fpga_t* fpga, uint sid, uint ch, uint pc, uint bg, uint ba, uint row, uint col, uint8_t pattern, InstructionSequence*& iseq);
void readRow(fpga_t* fpga, uint sid, uint ch, uint pc, uint bg, uint ba, uint row, uint col, InstructionSequence*& iseq);

void test(fpga_t* fpga);

void send2fpga(fpga_t* fpga, InstructionSequence*& iseq);
void rowcopy(fpga_t* fpga, uint sid, uint ch, uint pc, uint bg, uint ba, uint src_row, uint dst_row, InstructionSequence*& iseq);


#endif // IN_MEMORY_H_

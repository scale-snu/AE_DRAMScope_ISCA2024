#ifndef RETENTION_H_
#define RETENTION_H_

#include <iostream>
#include <cstring>
#include <cstdio>
#include <cassert>
#include <cmath>

#include "xdma.h"
#include "softmc.h"

#define nCK(time) ((time/tCK) + 1)

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
// #define tCCDS     
// #define tCCDL     
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

#define nCKmin    nCK(tCKmin)
#define nRCDWR    nCK(tRCDWR)      // ACT to Write
#define nRCDRD    nCK(tRCDRD)      // ACT to Read
#define nRAS      nCK(tRAS)      // Row Active Time, ACT to PRE
#define nRP       nCK(tRP)      // Row Precharge Time
#define nRC       nCK(tRC)      // Row Cycle Time, Row Cycle Time, ACT to ACT, tRAS + tRP
#define nWR       nCK(tWR)      // Write Recovery Time, Write burst end -> PRE
#define nRRDS     nCK(tRRDS)    
#define nRRDL     nCK(tRRDL)    
#define nFAW      nCK(tFAW)    
#define nMRD      nCK(tMRD)   
#define nCCDS     2
#define nCCDL     4
#define nMOD      nCK(tMOD)    
#define nPREFD    nCK(tPREFD)    
#define nRFCSB    nCK(tRFCSB)    
#define nCPDED    nCK(tCPDED)    
#define nWTRL     nCK(tWTRL)    
#define nWTRS     nCK(tWTRS)    
#define nCL       nCK(tCL)     // 0.47 < tCL < 0.53
#define nCH       nCK(tCH)     // 0.47 < tCH < 0.53 
#define nWL       nCK(WL)
#define nRL       nCK(RL)

#define nRTP      nCK(tRTP)      // tRAS - tRCDWR ??



void printHelp(char* argv[]);

void writeRow(fpga_t* fpga, uint sid, uint ch, uint pc, uint bg, uint ba, uint row, uint8_t pattern, InstructionSequence*& iseq);

void ReadRow(fpga_t* fpga, uint sid, uint ch, uint pc, uint bg, uint ba, uint row, InstructionSequence*& iseq);

void CompareRow(fpga_t* fpga, uint sid, uint ch, uint pc, uint bg, uint ba, uint row, uint8_t pattern);

void testRetention(fpga_t* fpga, const int retention, const int data);


#endif // RETENTION_H_

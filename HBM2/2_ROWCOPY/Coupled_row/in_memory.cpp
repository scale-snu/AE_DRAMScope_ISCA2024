#include <iostream>
#include <cstring>
#include <cstdio>
#include <set>

#include "xdma.h"
#include "softmc.h"

#include "in_memory.h"

/*
void printHelp(char* argv[]) {
  std::cout << "A sample application that tests rowhammer of DRAM rows using HBM-SoftMC" << std::endl;
  std::cout << "Usage:" << argv[0] << " [Src row address] [Dst row address] [pseudo channel] [bank group] [bank]" << std::endl; 
  std::cout << "The row address should be a positive integer or zero." << std::endl;
}
*/
void writeRow(fpga_t* fpga, uint sid, uint ch, uint pc, uint bg, uint ba, uint row, uint col, uint8_t pattern, InstructionSequence*& iseq) {
  // Write data at 5 rows
  iseq->insert(genPRE(sid, ch, pc, bg, ba));
  iseq->insert(genWAIT(to_cycle(tRP))); // sensitive to # of rows

  iseq->insert(genACT(sid, ch, pc, bg, ba, row));
  iseq->insert(genWAIT(to_cycle(tRCDWR)));
  
  for(int sel_col = 0; sel_col < NUM_COLS; sel_col++) {
    iseq->insert(genWR(sid, ch, pc, bg, ba, sel_col, pattern));
    iseq->insert(genWAIT(to_cycle(tCCDL)));
  }
  iseq->insert(genWAIT(to_cycle(tWR)));

  // Precharge a bank
  iseq->insert(genPRE(sid, ch, pc, bg, ba));
  iseq->insert(genWAIT(to_cycle(tRP))); // tRP
}

void readRow(fpga_t* fpga, uint sid, uint ch, uint pc, uint bg, uint ba, uint row, uint col, InstructionSequence*& iseq) {
  // Read data at 5 rows
  iseq->insert(genACT(sid, ch, pc, bg, ba, row));
  iseq->insert(genWAIT(to_cycle(tRCDRD)));//tRCDRD)));  //(((int)tRP + (int)tRCDWR)/(int)tCK));

  for(int sel_col = 0; sel_col < NUM_COLS; sel_col++) {
    iseq->insert(genRD(sid, ch, pc, bg, ba, sel_col));
    //iseq->insert(genWAIT(to_cycle(tCCDL)));
    iseq->insert(genWAIT(10));
  }
  iseq->insert(genWAIT(10));
  iseq->insert(genPRE(sid, ch, pc, bg, ba));
  iseq->insert(genWAIT(15));//tRP
}

int to_cycle(int timing) {
  int remainder = (int)(timing*10000) % (int)(tCK*10000);
  int result = 1;
  if(remainder == 0)
    result = (int)(timing*10000) / (int)(tCK*10000);
  else 
    result = (int)(timing*10000) / (int)(tCK*10000) + 1;

  return result;
} 

void send2fpga(fpga_t* fpga, InstructionSequence*& iseq) {
  // dummy instrs
  for(int i = 0; i < 8; i++)
    iseq->insert(genWAIT(1));

  iseq->insert(genEND());
  iseq->execute(fpga);
}

void rowcopy(fpga_t* fpga, uint sid, uint ch, uint pc, uint bg, uint ba, uint src_row, uint dst_row, InstructionSequence*& iseq) {
  iseq->insert(genWAIT(30));
  iseq->insert(genACT(sid, ch, pc, bg, ba, src_row));
  iseq->insert(genWAIT(to_cycle(tRAS)));
  iseq->insert(genPRE(sid, ch, pc, bg, ba));
  // short time 
  iseq->insert(genACT(sid, ch, pc, bg, ba, dst_row));
  iseq->insert(genWAIT(to_cycle(tRAS+tRC)));
  iseq->insert(genPRE(sid, ch, pc, bg, ba));
  iseq->insert(genWAIT(20));
}


void test(fpga_t* fpga) {
  InstructionSequence* iseq = nullptr; // we temporarily store (before sending them to the FPGA) the generated instructions here
  iseq = new InstructionSequence();
  
  uint sid  = 0;
  uint ch   = 0;
  uint pc   = 0;
  uint bg   = 0;
  uint ba   = 0;
  uint col  = 0;

  std::set <int> size;

  uint dst_row = 0;
  uint *rbuf = new uint[16];
  for (uint src_row = 0; src_row < NUM_ROWS; src_row+=1024) {
    for (uint interval = 1; interval < NUM_ROWS; interval *= 2) {
      iseq->size = 0;

      dst_row = src_row + 10;
      uint8_t src_pattern = 0xFF; 
      uint8_t dst_pattern = 0x00;
      uint pattern_32 = src_pattern;
      for(int i = 0; i < 4-1; i++) {
        pattern_32 = (pattern_32 << 8) | src_pattern;
      }

      //========================================//
      // insert instructions
      //========================================//
      // Initialize
      writeRow(fpga, sid, ch, pc, bg, ba, src_row, col, 0x00, iseq); 
      writeRow(fpga, sid, ch, pc, bg, ba, dst_row, col, 0x00, iseq); 

      writeRow(fpga, sid, ch, pc, bg, ba, (src_row+interval)%NUM_ROWS, col, 0x00, iseq); 
      writeRow(fpga, sid, ch, pc, bg, ba, (dst_row+interval)%NUM_ROWS, col, 0x00, iseq); 
      
      // write to the rows
      writeRow(fpga, sid, ch, pc, bg, ba, src_row, col, src_pattern, iseq); 
      writeRow(fpga, sid, ch, pc, bg, ba, dst_row, col, dst_pattern, iseq); 

      writeRow(fpga, sid, ch, pc, bg, ba, (src_row+interval)%NUM_ROWS, col, src_pattern, iseq); 
      writeRow(fpga, sid, ch, pc, bg, ba, (dst_row+interval)%NUM_ROWS, col, dst_pattern, iseq); 
      std::cerr << "Write data to Row " << dst_row << std::endl;

      // RowCopy
      rowcopy(fpga, sid, ch, pc, bg, ba, src_row, dst_row, iseq);

      // Read from the rows
      //readRow(fpga, sid, ch, pc, bg, ba, dst_row, col, iseq);
      readRow(fpga, sid, ch, pc, bg, ba, (dst_row+interval)%NUM_ROWS, col, iseq);

      //========================================//
      // send instructions to fpga
      //========================================//
      send2fpga(fpga, iseq);

      //========================================//
      // receive data from fpga
      //========================================//
      //usleep(1000);
      //readAndCompareRow(fpga, sid, ch, pc, bg, ba, dst_row, col, iseq, src_pattern);

      uint rc = 0;

      for(int sel_col = 0; sel_col < NUM_COLS; sel_col++) {
        rc = fpga_recv(fpga, 0, (void*)rbuf, 64, 0, 0);
        for(int i = 8*pc; i < 8 + 8*pc; i++) {
          if(rbuf[i] == pattern_32) {
            size.insert(interval);
          }
        }
      }


    }
  }
  delete[] rbuf;
  delete iseq;

  std::cout << std::endl << "===============================" << std::endl;
  std::cout << "Distance between coupled rows = " << std::endl;
  for (auto it = size.begin(); it != size.end(); it++)
    std::cout << *it << std::endl;
}


#include <iostream>
#include <cstring>
#include <cstdio>
#include <vector>

#include "xdma.h"
#include "softmc.h"

#include "rowpress.h"

uint remapping(uint row) {
  uint remap[16] = {0,1,2,3,4,5,6,7,14,15,12,13,10,11,8,9};
  return (row/16)*16 + remap[row%16];
}

void near_rows (const uint aggr, std::vector<int> &victims, const int interval) {
  int vic_len = 2;
  uint vic[vic_len];

  vic[0] = remapping(remapping(aggr) + interval);
  vic[1] = remapping(remapping(aggr) - interval);

  for (int i = 0; i < vic_len; i++) {
    //if (interval == 1) printf("[%d]: %d \n", i, vic[i]);
    if (vic[i] > 0 && vic[i] < NUM_ROWS) {
      victims.push_back(vic[i]); 
    }
  }
}

void printHelp(char* argv[]) {
  std::cout << "A sample application that tests rowhammer of DRAM rows for DRAMScope" << std::endl;
  std::cout << "Usage:" << argv[0] << " [HAMMER COUNT] [Aggressor row] [pseudo channel] [bank group] [bank] [Data pattern]" << std::endl; 
  std::cout << "The Hammer Count should be a positive integer." << std::endl;
}
void writeRow(fpga_t* fpga, uint sid, uint ch, uint pc, uint bg, uint ba, uint row, uint col, uint8_t pattern, InstructionSequence*& iseq) {
  uint8_t dp  = pattern%256;

  // Activate target row
  iseq->insert(genACT(sid, ch, pc, bg, ba, row));
  iseq->insert(genWAIT(5));  //(((int)tRP + (int)tRCDWR)/(int)tCK));

  for(int sel_col = 0; sel_col < NUM_COLS; sel_col++) {
    iseq->insert(genWR(sid, ch, pc, bg, ba, sel_col, dp));
    iseq->insert(genWAIT(5));
  }
  iseq->insert(genWAIT(5)); // sensitive to # of rows
  // Precharge a bank
  iseq->insert(genPRE(sid, ch, pc, bg, ba));
  iseq->insert(genWAIT(12)); // sensitive to # of rows
}

void readRow(fpga_t* fpga, uint sid, uint ch, uint pc, uint bg, uint ba, uint row, uint col, InstructionSequence*& iseq) {
  iseq->insert(genPRE(sid, ch, pc, bg, ba));
  iseq->insert(genWAIT(10)); 

  // Activate target row
  iseq->insert(genACT(sid, ch, pc, bg, ba, row));
  iseq->insert(genWAIT(10)); 

  for(int sel_col = 0; sel_col < NUM_COLS; sel_col++) {
    iseq->insert(genRD(sid, ch, pc, bg, ba, sel_col));
    iseq->insert(genWAIT(5));
  }
  iseq->insert(genWAIT(10)); // sensitive to # of rows   
  iseq->insert(genPRE(sid, ch, pc, bg, ba));
  iseq->insert(genWAIT(10));
}

void send2fpga(fpga_t* fpga, InstructionSequence*& iseq) {
  // dummy instrs
  for(int i = 0; i < 8; i++)
    iseq->insert(genWAIT(1));

  iseq->insert(genEND());
  iseq->execute(fpga);
  //std::cerr << "iseq->size =" << iseq->size << std::endl;
  iseq->size = 0;
}

void rowpress(fpga_t* fpga, uint sid, uint ch, uint pc, uint bg, uint ba, uint row, uint col, const int hammer_count, InstructionSequence*& iseq) {
  int gran = 30;
  int times = hammer_count / gran / 1000;
  int left  = (hammer_count % (gran*1000)) / 1000;

  // dummy instr
  for(int i = 0; i < 8; i++)
    iseq->insert(genWAIT(8));

  // max hammer count = 31K/1 instr
  for(int it = 0; it < times; it++) {

    iseq->insert(genHAMMER(sid, ch, pc, bg, ba, row, gran)); // 300k hammering

    // dummy instrs
    for(int i = 0; i < 8; i++)
      iseq->insert(genWAIT(8));

  }
  if(left != 0) {
    iseq->insert(genHAMMER(sid, ch, pc, bg, ba, row, left)); 
  }

  // dummy instr
  for(int i = 0; i < 8; i++)
    iseq->insert(genWAIT(8));

}

void readAndCompareRow(fpga_t* fpga, uint sid, uint ch, uint pc, uint bg, uint ba, uint aggr_row, uint row, uint col, uint8_t pattern, InstructionSequence*& iseq) {
  Instruction pattern_32 = pattern;
  for(int i = 0; i < 4-1; i++) {
    pattern_32 = (pattern_32 << 8) | pattern;
  }

  //Receive the data
  int rc;
  uint *rbuf = new uint[16];

  for(int sel_col = 0; sel_col < NUM_COLS; sel_col++) {
    rc = fpga_recv(fpga, 0, (void*)rbuf, 64, 0, 0);
    int bit = 0;
    for(int i = 8*pc; i < 8 + 8*pc; i++) {
      for(int shift = 0; shift < 32; shift++) {
        int compare = (pattern_32>>shift) % 2;
        if((rbuf[i]>>shift)%2 != compare) {
          std::cout << aggr_row << "," << row << "," << pc << "," << bg << "," << ba << "," << sel_col << "," << bit << "," << compare << std::endl;
        }
        bit++;
      }
    }
  }
  delete[] rbuf;
}

void testRH(fpga_t* fpga, const int hammer_count, const int aggr_row, const int pc, const int bg, const int ba, uint dp) {
  InstructionSequence* iseq = nullptr; // we temporarily store (before sending them to the FPGA) the generated instructions here
  iseq = new InstructionSequence();

  uint pattern = dp % 256; 

  uint sid  = 0;
  uint ch   = 0;
  //uint pc   = 0;
  //uint bank_group  = (uint)bg;
  //uint bank = (uint)ba;
  uint row = aggr_row;
  uint col = 0;

  std::vector<int> victims;
  near_rows(row, victims, 1);

  iseq->size = 0;
  // write init data
  for (auto victim : victims) {
    writeRow(fpga, sid, ch, pc, bg, ba, row, col, (~pattern)%256, iseq); 
    send2fpga(fpga, iseq);
  }

  // write rows
  writeRow(fpga, sid, ch, pc, bg, ba, row, col, (~pattern)%256, iseq); 
  for (auto victim : victims) {
    writeRow(fpga, sid, ch, pc, bg, ba, victim, col, pattern, iseq); 
  }

  rowpress(fpga, sid, ch, pc, bg, ba, row, col, hammer_count, iseq);

  for (auto victim : victims) {
    readRow(fpga, sid, ch, pc, bg, ba, victim, col, iseq);
  }
  send2fpga(fpga, iseq);

  for (auto victim : victims) {
    readAndCompareRow(fpga, sid, ch, pc, bg, ba, row, victim, col, pattern, iseq);
  }

  delete iseq;
}


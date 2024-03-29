#include <iostream>
#include <cstring>
#include <cstdio>

#include "xdma.h"
#include "softmc.h"

#include "rowhammer.h"

int total_row = 32;

void printHelp(char* argv[]) {
  std::cout << "A sample application that tests rowhammer of DRAM rows for DRAMScope" << std::endl;
  std::cout << "Usage:" << argv[0] << " [HAMMER COUNT] [Aggressor row] [pseudo channel] [bank group] [bank] [Data pattern]" << std::endl; 
  std::cout << "The Hammer Count should be a positive integer." << std::endl;
}
void writeRow(fpga_t* fpga, uint sid, uint ch, uint pc, uint bg, uint ba, uint row, uint col, uint8_t pattern, InstructionSequence*& iseq) {
  uint8_t aggr_dp = (~pattern)%256;
  uint8_t vic_dp  = pattern%256;

  int start = row - 8;
  int end = row + 8;
  if (start <= 0)      start = 0;
  if (end >= NUM_ROWS) end = NUM_ROWS - 1;
  
  // Write data at 5 rows
  for(int sel_row = start; sel_row < end; sel_row++){
    // Activate target row
    iseq->insert(genACT(sid, ch, pc, bg, ba, sel_row));
    iseq->insert(genWAIT(5));  //(((int)tRP + (int)tRCDWR)/(int)tCK));

    for(int sel_col = 0; sel_col < NUM_COLS; sel_col++) {
      if (sel_row == row)
        iseq->insert(genWR(sid, ch, pc, bg, ba, sel_col, aggr_dp));
      else 
        iseq->insert(genWR(sid, ch, pc, bg, ba, sel_col, vic_dp));
      iseq->insert(genWAIT(5));
    }
    iseq->insert(genWAIT(5)); // sensitive to # of rows
    // Precharge a bank
    iseq->insert(genPRE(sid, ch, pc, bg, ba));
    iseq->insert(genWAIT(12)); // sensitive to # of rows

    //printf("Write at Col: %d, Row: %u, Bank: %u, BG: %u, PC: %u\n", col, row, sel_ba, sel_bg, pc);		
    //printf("write row : %d\n", sel_row);
  }
}

void readRow(fpga_t* fpga, uint sid, uint ch, uint pc, uint bg, uint ba, uint row, uint col, InstructionSequence*& iseq) {
  // Read data at 5 rows
  int start = row - 8;
  int end = row + 8;
  if (start <= 0)      start = 0;
  if (end >= NUM_ROWS) end = NUM_ROWS - 1;

  iseq->insert(genPRE(sid, ch, pc, bg, ba));
  iseq->insert(genWAIT(4)); 
  for(int sel_row = start; sel_row < end; sel_row++){
    if(sel_row != row) {
      // Activate target row
      iseq->insert(genACT(sid, ch, pc, bg, ba, sel_row));
      iseq->insert(genWAIT(10)); 

      for(int sel_col = 0; sel_col < NUM_COLS; sel_col++) {
        iseq->insert(genRD(sid, ch, pc, bg, ba, sel_col));
        iseq->insert(genWAIT(5));
      }
      iseq->insert(genWAIT(10)); // sensitive to # of rows   
      iseq->insert(genPRE(sid, ch, pc, bg, ba));
      iseq->insert(genWAIT(10));

      //printf("read row : %d\n", sel_row);
    }
  }
}

void send2fpga(fpga_t* fpga, InstructionSequence*& iseq) {
  // dummy instrs
  for(int i = 0; i < 8; i++)
    iseq->insert(genWAIT(1));

  iseq->insert(genEND());
  iseq->execute(fpga);
  iseq->size = 0;
}

void rowhammer(fpga_t* fpga, uint sid, uint ch, uint pc, uint bg, uint ba, uint row, uint col, const int hammer_count, InstructionSequence*& iseq) {
  int gran = 30;
  int times = hammer_count / gran / 10000;
  int left  = (hammer_count % (gran*10000)) / 10000;

  // dummy instr
  for(int i = 0; i < 8; i++)
    iseq->insert(genWAIT(8));

  // max hammer count = 310K/1 instr
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

void readAndCompareRow(fpga_t* fpga, uint sid, uint ch, uint pc, uint bg, uint ba, uint row, uint col, uint8_t pattern, InstructionSequence*& iseq) {
  Instruction pattern_32 = pattern;
  for(int i = 0; i < 4-1; i++) {
    pattern_32 = (pattern_32 << 8) | pattern;
  }

  int start = row - 8;
  int end = row + 8;
  if (start <= 0)      start = 0;
  if (end >= NUM_ROWS) end = NUM_ROWS - 1;
  //Receive the data
  int rc;
  uint *rbuf = new uint[16];

  for(int sel_row = start; sel_row < end; sel_row++){
    if(sel_row != row) {
      for(int sel_col = 0; sel_col < NUM_COLS; sel_col++) {
        rc = fpga_recv(fpga, 0, (void*)rbuf, 64, 0, 0);
        int bit = 0;
        for(int i = 8*pc; i < 8 + 8*pc; i++) {
          for(int shift = 0; shift < 32; shift++) {
            int compare = (pattern_32>>shift) % 2;
            if((rbuf[i]>>shift)%2 != compare) {
              std::cout << row << "," << sel_row << "," << pc << "," << bg << "," << ba << "," << sel_col << "," << bit << "," << compare << std::endl;
            }
            bit++;
          }
        }
      }
    }  
  } 
  delete[] rbuf;
}

void testRH(fpga_t* fpga, const int hammer_count, const int aggr_row, const int pc, const int bg, const int ba, uint dp) {
  InstructionSequence* iseq = nullptr; // we temporarily store (before sending them to the FPGA) the generated instructions here
  iseq = new InstructionSequence();

  uint pattern = dp % 0x100; 

  uint sid  = 0;
  uint ch   = 0;
  //uint pc   = 0;
  //uint bank_group  = (uint)bg;
  //uint bank = (uint)ba;
  uint row = aggr_row;
  uint col = 0;

  iseq->size = 0;
  // write the data pattern to the entire row

  writeRow(fpga, sid, ch, pc, bg, ba, row, col, (~pattern)%256, iseq); 
  send2fpga(fpga, iseq);
  writeRow(fpga, sid, ch, pc, bg, ba, row, col, pattern, iseq); 

  rowhammer(fpga, sid, ch, pc, bg, ba, row, col, hammer_count, iseq);
  readRow(fpga, sid, ch, pc, bg, ba, row, col, iseq);
  send2fpga(fpga, iseq);

  readAndCompareRow(fpga, sid, ch, pc, bg, ba, row, col, pattern, iseq);

  delete iseq;
}


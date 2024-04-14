#include <iostream>
#include <cstring>
#include <cstdio>

#include "xdma.h"
#include "softmc.h"

#include "retention.h"

void printHelp(char* argv[]) {
  std::cout << "Retention time test for DRAMScope" << std::endl;
  std::cout << "Usage:" << argv[0] << " [REFRESH INTERVAL] [CELL DATA]" << std::endl; 
  std::cout << "The Refresh Interval should be a positive integer, indicating the target retention time in milliseconds." << std::endl;
  std::cout << "Data stored in cells should be 0 or 1." << std::endl;
}

void writeRow(fpga_t* fpga, uint sid, uint ch, uint pc, uint bg, uint ba, uint row, uint8_t pattern, InstructionSequence*& iseq) {
  if(iseq == nullptr)
    iseq = new InstructionSequence();
  else 
    iseq->size = 0;//reuse the provided InstructionSequence to avoid dynamic allocation on each call

  iseq->insert(genPRE(sid, ch, pc, bg, ba));
  iseq->insert(genWAIT(nRP));	
  
  // Activate target row
  iseq->insert(genACT(sid, ch, pc, bg, ba, row));
  iseq->insert(genWAIT(nRCDWR));  //(((int)tRP + (int)tRCDWR)/(int)tCK));


  for(int sel_col = 0; sel_col < NUM_COLS; sel_col++) {
    iseq->insert(genWR(sid, ch, pc, bg, ba, sel_col, pattern));
    iseq->insert(genWAIT(nCCDL));
  }
  iseq->insert(genWAIT(nCK(tRAS - tRCDWR))); // 

  // explicit Precharge target bank
  iseq->insert(genPRE(sid, ch, pc, bg, ba));
  iseq->insert(genWAIT(nRP)); //tCCDS/tCK)); // (4+15) /3.33 =   6
  
  // dummy instrs
  for(int i = 0; i < 8; i++)
    iseq->insert(genWAIT(1));

  // START Transaction
  iseq->insert(genEND());
  iseq->execute(fpga);
}

void ReadRow(fpga_t* fpga, uint sid, uint ch, uint pc, uint bg, uint ba, uint row, InstructionSequence*& iseq) {
  if(iseq == nullptr)
    iseq = new InstructionSequence();
  else 
    iseq->size = 0;//reuse the provided InstructionSequence to avoid dynamic allocation on each call

  for(int i = 0; i++; i < 10)
    iseq->insert(genWAIT(2));

  iseq->insert(genPRE(sid, ch, pc, bg, ba));
  iseq->insert(genWAIT(nRP));	
  
  // activate target row
  iseq->insert(genACT(sid, ch, pc, bg, ba, row));
  iseq->insert(genWAIT(nRCDRD));  //(((int)trp + (int)trcdwr)/(int)tck));

  //read the entire row
  for(int sel_col = 0; sel_col < NUM_COLS; sel_col++) {
    iseq->insert(genRD(sid, ch, pc, bg, ba, sel_col));
    iseq->insert(genWAIT(nCCDL));
  }
  iseq->insert(genWAIT(nCK(tRAS-tRCDWR)));
  //precharge
  iseq->insert(genPRE(sid, ch, pc, bg, ba));
  iseq->insert(genWAIT(nRP));	
  //}

  // dummy instrs
  for(int i = 0; i < 8; i++)
    iseq->insert(genWAIT(1));

  // START Transaction
  iseq->insert(genEND());
  iseq->execute(fpga);
}

void Refresh(fpga_t* fpga, uint count, uint tRFC, InstructionSequence*& iseq) {
  // tREFI = 3.9 us / 100 (100 is prescaler)
  // tRFC = 260 ns (4Gb per CH)
  if(iseq == nullptr)
    iseq = new InstructionSequence();
  else 
    iseq->size = 0;
  
  for(int i = 0; i < 8192; i++) {
    iseq->insert(genPREALL(0,0,0,0,0));
    iseq->insert(genWAIT(nRP));
    iseq->insert(genREF(0,0,0));
    iseq->insert(genWAIT(tRFC));
    iseq->insert(genWAIT(970)); // 4 us
  }

  for(int i = 0; i < 8; i++)
    iseq->insert(genWAIT(1));


	//START Transaction
	iseq->insert(genEND());

	iseq->execute(fpga);	
}


void AutoRefresh(fpga_t* fpga, uint tREFI, uint tRFC, InstructionSequence*& iseq) {
  // tREFI = 3.9 us / 0.1 (100 ns is prescaler)
  // tRFC = 260 ns (4Gb per CH)
  if(iseq == nullptr)
    iseq = new InstructionSequence();
  else 
    iseq->size = 0;

  iseq->insert(set_tREFI(tREFI));
  iseq->insert(genWAIT(1));
	iseq->insert(set_tRFC(tRFC)); 
  iseq->insert(genWAIT(1));


  //Precharge
  iseq->insert(genPRE(0, 0, 0, 0, 0));
  iseq->insert(genWAIT(nRP));	
  

  for(int i = 0; i < 20; i++)
    iseq->insert(genWAIT(1));

	//START Transaction
	iseq->insert(genEND());

	iseq->execute(fpga);	
}

void CompareRow(fpga_t* fpga, uint sid, uint ch, uint pc, uint bg, uint ba, uint row, uint8_t pattern, int& error_count) {
  Instruction pattern_64 = pattern;
  for(int i = 0; i < 7; i++) {
    pattern_64 = (pattern_64 << 8) | pattern;
  }

  uint *tmp = new uint[16];
  uint rbuf[16];
  for(int sel_col = 0; sel_col < NUM_COLS; sel_col++) {
    // Receive the data
    fpga_recv(fpga, 0, (void*)tmp, 64, 0, 0);
    for(int j = 0; j < 16; j++)
      rbuf[j] = tmp[j];

    // Compare with the pattern
    uint* rbuf8 = rbuf;
    uint rbuf4[8];
    for(int i = 7; i >= 0; i--) {
      if(pc == 1) {
        if(i>=8)
          rbuf4[i-8] = rbuf8[i];
      }
      else {
        if(i<8)
          rbuf4[i] = rbuf8[i];
      }
    }

    // Error detecting
    int bit = 0;
    for (int k = 0; k < 8; k++) {
      Instruction temp = rbuf4[k];
      for(int shift = 0; shift < 32; shift++) {
        if(temp%2 != (pattern_64>>shift) % 2) {
          printf("%d,%d,%d,%d,%d,%d\n", pc, bg, ba, row, sel_col, bit);  
        }
        bit++; 
        temp >>= 1;
      }
    }
  }
  delete [] tmp;
}

void testRetention(fpga_t* fpga, const int retention, const int data) {
  uint8_t pattern = 0xFF * data; 

  bool stack_done = false;
  uint sid = 0;
  uint ch  = 0;
  uint pc  = 0;
  uint bg  = 0;
  uint ba  = 0;

  InstructionSequence* iseq = nullptr;

  int iter = 0;
  int error_count = 0;
  printf("pc,bg,ba,row,col,bit\n");

  //////////////////////////////////////////////////
  // write data in cells of one bank
  //////////////////////////////////////////////////
  fflush(stdout);
  
  // write the data pattern to the entire row
  int num_row = 8192;
  for (int row = 0; row < num_row; row++) {
    writeRow(fpga, sid, ch, pc, bg, ba, row, pattern, iseq);
    usleep(1000);
  }

  //////////////////////////////////////////////////
  // Wait for Retention time
  //////////////////////////////////////////////////       

  usleep(retention*1000);

  //////////////////////////////////////////////////
  // Read & Compare 
  //////////////////////////////////////////////////       

  for (int row = 0; row < num_row; row++) {
    std::cerr << "Read row " << row << std::endl;
    ReadRow(fpga, sid, ch, pc, bg, ba, row, iseq);
    usleep(1000);
    CompareRow(fpga, sid, ch, pc, bg, ba, row, pattern, error_count); 
  }

  delete iseq;
}


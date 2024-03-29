#include "instruction.h"
#include "prog.h"
#include "SMC_Registers.h"
#include "functions.h"

#include <iostream>
#include <cstring>
#include <vector>

#define NUM_ROWS 65536

using namespace std;

int main(int argc, char * argv[]) {

  uint wait, bank, src_dp, dst_dp;
  string vendor;

  if (argc < 6) {
    printf("-wait <PRE to ACT time interval in rowcopy operation> ");
    printf("-bank <bank address> ");
    printf("-vendor <DRAM vendor (e.g., s, h, m)>\n");
    printf("E.g., sudo ./Rowcopy -wait 3 -bank 0 -vendor s\n");
    return 0;
  }

  for (int i = 1; i < argc; i++){
    if (strcmp(argv[i], "-wait")==0) {
      wait = atoi(argv[i+1]);
    } else if (strcmp(argv[i], "-bank")==0) {
      bank = atoi(argv[i + 1]);
    } else if (strcmp(argv[i],"-vendor")==0) {
      vendor = argv[i+1];
    }
  }

  ///////////////////////////////////////////////////////////////////////
  ////////////////////////      Platform      ///////////////////////////
  ///////////////////////////////////////////////////////////////////////
  SoftMCPlatform platform;
  platform.init();
  platform.reset_fpga();
  platform.set_aref(true); // true 
  Program p;

  uint src_row = 0;
  src_dp = 0xffffffff;
  dst_dp = 0x0;
  
  for (int dst_row = src_row + 1; dst_row < NUM_ROWS; dst_row++) {

    ///////////////////////////////////////////////////////////////////////
    //////////////////////      WRITE ROWS      ///////////////////////////
    ///////////////////////////////////////////////////////////////////////
    WriteRow(&platform, src_dp, bank, src_row);
    WriteRow(&platform, dst_dp, bank, dst_row);

    ///////////////////////////////////////////////////////////////////////
    /////////////////////////      ROWCOPY      ///////////////////////////
    ///////////////////////////////////////////////////////////////////////
    RowCopy(&platform, bank, src_row, dst_row, wait);

    ///////////////////////////////////////////////////////////////////////
    ////////////////////////      READ ROW      ///////////////////////////
    ///////////////////////////////////////////////////////////////////////
    ReadRow(&platform, bank, dst_row);

    ///////////////////////////////////////////////////////////////////////
    //////////////////////      COMPARE DATA      /////////////////////////
    ///////////////////////////////////////////////////////////////////////
    int bufsize = 8192;
    unsigned char buf[bufsize];

    int count = 0;

    for (int idx = 0; idx < 1; idx++) {
      platform.receiveData(buf, bufsize);
      int start = bufsize/128/4;
      int end   = bufsize/128/4*2;
      for (int i = start ; i < end; i++){
        if((uint8_t)buf[bufsize/128-i-1] != (uint8_t)src_dp) {
          count ++;
        }
      }
    }
    if (count > 14) {
      printf("subarray size: %3d (row = %d)\n", dst_row - src_row, src_row);
      src_row = dst_row;
    }
  }
  printf("subarray size: %3d (row = %d)\n", NUM_ROWS - src_row, src_row);
}

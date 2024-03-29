#include "instruction.h"
#include "prog.h"
#include "SMC_Registers.h"
#include "functions.h"

#include <iostream>
#include <cstring>
#include <vector>
#include <unistd.h>

#define NUM_ROWS 131072

using namespace std;

int main(int argc, char * argv[]){

  uint start, bank, num_rows, sleep;

  if (argc < 8) {
    printf("-start <start row address> ");
    printf("-bank <bank address> ");
    printf("-num_rows <# of rows> ");
    printf("-sleep <retention time [us]>\n");
    printf("E.g., sudo ./Retention -start 100 -bank 0 -num_rows 100 -sleep 10000000\n");
    return 0;
  }
  
  for (int i = 1; i < argc; i++){
    if (strcmp(argv[i], "-start")==0) {
      start = atoi(argv[i+1]);
    } else if (strcmp(argv[i], "-bank")==0) {
      bank = atoi(argv[i + 1]);
    } else if (strcmp(argv[i], "-num_rows")==0) {
      num_rows = atoi(argv[i + 1]);
    } else if (strcmp(argv[i], "-sleep")==0) {
      sleep = atoi(argv[i + 1]);
    }
  }

  ///////////////////////////////////////////////////////////////////////
  ////////////////////////      Platform      ///////////////////////////
  ///////////////////////////////////////////////////////////////////////
  SoftMCPlatform platform;
  platform.init();
  platform.reset_fpga();
  platform.set_aref(false);
  Program p;

  unsigned char buf[8192];

  uint tmp_err = 0;

  ///////////////////////////////////////////////////////////////////////
  //////////////////////      WRITE ROWS      ///////////////////////////
  ///////////////////////////////////////////////////////////////////////
  for(int it = 0; it < num_rows; it++){
    WriteRow(&platform, 0xFFFFFFFF, bank, start+it);
  }

  usleep(sleep);

  ///////////////////////////////////////////////////////////////////////
  /////////////////////      RETENTION TEST      ////////////////////////
  ///////////////////////////////////////////////////////////////////////
  for(int it = 0; it < num_rows; it++){
    ReadRow(&platform, bank, start+it);
    platform.receiveData(buf, 8192);
    tmp_err = 0;
    for (int i = 0 ; i < 8192 ; i++){
      tmp_err = 0xFFFFFFFF ^ (uint8_t)buf[i];
      for (int div = 0; div < 8; div++) {
        if((tmp_err >> div)%2 == 1) {
          int col = ((8*i + div) / 512)*8;
          int bit = (8*i + div) % 512;
          int rev_bit = 4*((bit%64) / 8) + bit%4;
          printf("%d,%d,%d,%d,%d\n", bank, start+it, col, bit, rev_bit);
        }
      }
    }
  }
}

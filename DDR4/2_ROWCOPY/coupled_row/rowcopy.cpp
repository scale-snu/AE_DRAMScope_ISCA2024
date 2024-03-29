#include "instruction.h"
#include "prog.h"
#include "SMC_Registers.h"
#include "functions.h"

#include <iostream>
#include <cstring>
#include <vector>

#define NUM_ROWS 131072 // x4

using namespace std;

uint remap[16] = {0,1,2,3,4,5,6,7,14,15,12,13,10,11,8,9};

uint remapping(uint row, string vendor) {
  if (vendor == "s") 
    return (row/16)*16 + remap[row%16];
  else 
    return row;
}

uint RCD_inversion (const uint row) {
  uint data_mask = 0b11101010000000111;
  uint inv_mask  = 0b00010101111111000;
  uint bit_mask  = 0b11111111111111111;

  uint tmp_row = 0;
  tmp_row |= row & data_mask;
  tmp_row |= (~row) & inv_mask;
  tmp_row &= bit_mask;

  return tmp_row;
}

void near_rows (const uint aggr, vector<int> &victims, const int interval, string vendor) {
  int vic_len = 4;
  uint vic[vic_len];

  vic[0] = remapping(remapping(aggr, vendor) + interval, vendor);
  vic[1] = remapping(remapping(aggr, vendor) - interval, vendor);
  vic[2] = RCD_inversion(remapping(remapping(RCD_inversion(aggr), vendor) + interval, vendor));
  vic[3] = RCD_inversion(remapping(remapping(RCD_inversion(aggr), vendor) - interval, vendor));

  for (int i = 0; i < vic_len; i++) {
    if (vic[i] > 0 && vic[i] < NUM_ROWS) {
      victims.push_back(vic[i]); 
    }
  }
}

int bit_count(int n) {
  int i;
  for(i = 0; n != 0; i++) {
      n &= (n - 1);
  }
  return i;
}

int main(int argc, char * argv[]) {
  uint src, dst, wait, bank, src_dp, dst_dp;
  string vendor;

  if (argc < 14) {
    printf("Usage: %s ", argv[0]);
    printf("-src -dst <source/destination row address> ");
    printf("-wait <PRE to ACT time interval in rowcopy operation> ");
    printf("-bank <bank address> ");
    printf("-src_dp -dst_dp <data pattern in hex> ");
    printf("-vendor <DRAM vendor (e.g., s, h, m)>\n");
    printf("E.g., sudo ./Rowcopy -src 300 -dst 400 -wait 3 -bank 0 -src_dp f0f0f0f0 -dst_dp ffffffff -vendor s\n");
    return 0;
  }

  for (int i = 1; i < argc; i++){
    if (strcmp(argv[i], "-src")==0) {
      src = atoi(argv[i+1]);
    } else if (strcmp(argv[i], "-dst")==0) {
      dst = atoi(argv[i+1]);
    } else if (strcmp(argv[i], "-wait")==0) {
      wait = atoi(argv[i+1]);
    } else if (strcmp(argv[i], "-bank")==0) {
      bank = atoi(argv[i + 1]);
    } else if (strcmp(argv[i], "-src_dp")==0) {
      src_dp = strtol(argv[i+1], nullptr, 16);
    } else if (strcmp(argv[i], "-dst_dp")==0) {
      dst_dp = strtol(argv[i+1], nullptr, 16);
    } else if (strcmp(argv[i], "-vendor")==0) {
      vendor = argv[i+1];
    }
  }
  ///////////////////////////////////////////////////////////////////////
  ////////////////////////      Platform      ///////////////////////////
  ///////////////////////////////////////////////////////////////////////
  SoftMCPlatform platform;
  platform.init();
  platform.reset_fpga();
  platform.set_aref(true);
  Program p;

  ///////////////////////////////////////////////////////////////////////
  //////////////////////      WRITE ROWS      ///////////////////////////
  ///////////////////////////////////////////////////////////////////////
  WriteRow(&platform, src_dp, bank, src);
  WriteRow(&platform, dst_dp, bank, dst);
  for (int i = 1; i < 4; i++) {
    WriteRow(&platform, src_dp, bank, src+i*NUM_ROWS/4);
    WriteRow(&platform, dst_dp, bank, dst+i*NUM_ROWS/4);
  }

  ///////////////////////////////////////////////////////////////////////
  ////////////////////////      READ ROWS      //////////////////////////
  ///////////////////////////////////////////////////////////////////////
  ReadRow(&platform, bank, src);
  ReadRow(&platform, bank, dst);
  for (int i = 1; i < 4; i++) {
    ReadRow(&platform, bank, src+i*NUM_ROWS/4);
    ReadRow(&platform, bank, dst+i*NUM_ROWS/4);
  }

  ///////////////////////////////////////////////////////////////////////
  //////////////////////      COMPARE DATA      /////////////////////////
  ///////////////////////////////////////////////////////////////////////
  int bufsize = 8192;
  unsigned char buf[bufsize];

  uint read_row[8] = {src, dst, src+NUM_ROWS/4, dst+NUM_ROWS/4,
                      src+2*NUM_ROWS/4, dst+2*NUM_ROWS/4, src+3*NUM_ROWS/4, dst+3*NUM_ROWS/4
                      };
  cout << "=========================" << endl;
  cout << endl;
  printf("Before RowCopy\n");
  printf("\n");
  for (int idx = 0; idx < 8; idx++) {
    platform.receiveData(buf, bufsize);
    printf("row %4d:\t", read_row[idx]);
    for (int i = 12 ; i < 12+8; i+=2){
      printf("%2x", (uint8_t)((buf[27-i] * 16) + (buf[27-(i+1)] % 16)));
    }
    for (int i = 12 ; i < 12+8; i+=2){
      printf("%2x", (uint8_t)((buf[27-(i+1)] / 16) + (buf[27-i] & 0xf0)));
    }
    cout << endl;
  }
  cout << "=========================" << endl;
  cout << endl;

  ///////////////////////////////////////////////////////////////////////
  /////////////////////////      ROWCOPY      ///////////////////////////
  ///////////////////////////////////////////////////////////////////////
  RowCopy(&platform, bank, src, dst, wait);
  
  ///////////////////////////////////////////////////////////////////////
  ////////////////////////      READ ROWS      //////////////////////////
  ///////////////////////////////////////////////////////////////////////
  ReadRow(&platform, bank, src);
  ReadRow(&platform, bank, dst);

  for (int i = 1; i < 4; i++) {
    ReadRow(&platform, bank, src+i*NUM_ROWS/4);
    ReadRow(&platform, bank, dst+i*NUM_ROWS/4);
  }

  ///////////////////////////////////////////////////////////////////////
  //////////////////////      COMPARE DATA      /////////////////////////
  ///////////////////////////////////////////////////////////////////////
  printf("After RowCopy\n");
  printf("\n");
  for (int idx = 0; idx < 8; idx++) {
    platform.receiveData(buf, 8192);
    printf("row %4d:\t", read_row[idx]);
    int start = bufsize/128/4;
    int end   = bufsize/128/4*2;
    
    for (int i = start; i < end; i+=2){
      printf("%2x", (uint8_t)((buf[bufsize/128-i-1] * 16) + (buf[bufsize/128-(i+1)-1] % 16)));
    }
    cout << " ";
    for (int i = start; i < end; i+=2){
      printf("%2x", (uint8_t)((buf[bufsize/128-(i+1)-1] / 16) + (buf[bufsize/128-i-1] / 16) * 16));
    }
    cout << endl;
    if(idx == 3) printf("\nCheck unintended RowCopy\n\n");
  }
  cout << "=========================" << endl;
}

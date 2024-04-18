#include "instruction.h"
#include "prog.h"
#include "SMC_Registers.h"
#include "functions.h"

#include <iostream>
#include <cstring>
#include <vector>
#include <set>

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

  set <int> size;

  int bufsize = 8192;
  unsigned char buf[bufsize];

  bool find = false;
  
  for (int interval = 1; interval < NUM_ROWS; interval*=2) {
    ///////////////////////////////////////////////////////////////////////
    //////////////////////      WRITE ROWS      ///////////////////////////
    ///////////////////////////////////////////////////////////////////////
    WriteRow(&platform, src_dp, bank, src);
    WriteRow(&platform, dst_dp, bank, dst);
    WriteRow(&platform, src_dp, bank, (src+interval)%NUM_ROWS);
    WriteRow(&platform, dst_dp, bank, (dst+interval)%NUM_ROWS);

    ///////////////////////////////////////////////////////////////////////
    //////////////////////        ROW COPY        /////////////////////////
    ///////////////////////////////////////////////////////////////////////
    RowCopy(&platform, bank, src, dst, wait);
    
    ///////////////////////////////////////////////////////////////////////
    ////////////////////////      READ ROWS      //////////////////////////
    ///////////////////////////////////////////////////////////////////////
    ReadRow(&platform, bank, (dst+interval)%NUM_ROWS);

    ///////////////////////////////////////////////////////////////////////
    //////////////////////      COMPARE DATA      /////////////////////////
    ///////////////////////////////////////////////////////////////////////
    int count = 0;
    platform.receiveData(buf, bufsize);
    int start = bufsize/128/4*2;
    int end   = bufsize/128/4*3;
    for (int i = start ; i < end; i++){
      if((uint8_t)buf[bufsize/128-i-1] == (uint8_t)src_dp) {
        count++;
      }
    }
    if (count > 14) {
      //cout << "Coupled row interval = " << interval << endl;
      size.insert(interval);
      find = true;
    }
  }
  std::cout << std::endl << "=======================" << std::endl;
  if(!find)
    cout << "There is no coupled-rows." << endl;
  else {
    std::cout << "Subarray size = " << std::endl;
    for (auto it = size.begin(); it != size.end(); it++)
      std::cout << *it << std::endl;
  }
}

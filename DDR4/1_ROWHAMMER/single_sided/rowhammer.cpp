#include "instruction.h"
#include "prog.h"
#include "SMC_Registers.h"
#include "functions.h"

#include <iostream>
#include <cstring>
#include <vector>

#define NUM_ROWS 131072 // x4
// #define NUM_ROWS 65536 // x8

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

int main(int argc, char * argv[]){

  uint aggressor, bank, iter, tRAS, tRP, vic_dp, aggr_dp;
  string vendor;

  if (argc < 16) {
    printf("Usage: %s ", argv[0]);
    printf("-aggr <aggressor row address> ");
    printf("-bank <bank address> ");
    printf("-iter <hammer count> ");
    printf("-tRAS -tRP <additive tRAS/tRP (default: 1)> ");
    printf("-vic_dp -aggr_dp <data pattern in hex> ");
    printf("-vendor <DRAM vendor (e.g., s, h, m)>\n");
    printf("E.g., sudo ./Rowhammer -aggr 300 -bank 0 -iter 400000 -tRAS 1 -tRP 1 -vic_dp 33333333 -aggr_dp cccccccc -vendor s\n");
    return 0;
  }

  for (int i = 1; i < argc; i++){
    if (strcmp(argv[i], "-aggr")==0) {
      aggressor = atoi(argv[i+1]);
    } else if (strcmp(argv[i], "-bank")==0) {
      bank = atoi(argv[i + 1]);
    } else if (strcmp(argv[i], "-iter")==0) {
      iter = atoi(argv[i + 1]);
    } else if (strcmp(argv[i], "-tRAS")==0) {
      tRAS = atof(argv[i + 1]);
    } else if (strcmp(argv[i], "-tRP")==0) {
      tRP = atof(argv[i + 1]);
    } else if (strcmp(argv[i], "-vic_dp")==0) {
      vic_dp = strtol(argv[i+1], nullptr, 16);
    } else if (strcmp(argv[i], "-aggr_dp")==0) {
      aggr_dp = strtol(argv[i+1], nullptr, 16);
    } else if (strcmp(argv[i], "-vendor")==0) {
      vendor = argv[i+1];
    }
  }

  ///////////////////////////////////////////////////////////////////////
  ///////////////////      FIND VICTIM ROWS      ////////////////////////
  ///////////////////////////////////////////////////////////////////////
  int adjacent = remapping(aggressor, vendor);
  vector<int> victims;

  near_rows(aggressor, victims, 1, vendor);

  sort(victims.begin(), victims.end());
  victims.erase(unique(victims.begin(), victims.end()) ,victims.end());

  ///////////////////////////////////////////////////////////////////////
  ////////////////////////      Platform      ///////////////////////////
  ///////////////////////////////////////////////////////////////////////
  SoftMCPlatform platform;
  platform.init();
  platform.reset_fpga();
  platform.set_aref(true);
  Program p;

  ///////////////////////////////////////////////////////////////////////
  ////////////////////      AGGRESSOR ROWS      /////////////////////////
  ///////////////////////////////////////////////////////////////////////
  WriteRow(&platform, aggr_dp, bank, aggressor);
  
  ///////////////////////////////////////////////////////////////////////
  /////////////////////      VICTIM ROWS      ///////////////////////////
  ///////////////////////////////////////////////////////////////////////
  for (auto victim : victims) {
    WriteRow(&platform, vic_dp, bank, victim);
  }

  ///////////////////////////////////////////////////////////////////////
  ///////////////////////      ROWHAMMER      ///////////////////////////
  ///////////////////////////////////////////////////////////////////////
  SingleSided(&platform, bank, aggressor, iter, tRAS, tRP);

  ///////////////////////////////////////////////////////////////////////
  /////////////////////      READ VICTIM ROWS      //////////////////////
  ///////////////////////////////////////////////////////////////////////
  for (auto victim : victims) {
    ReadRow(&platform, bank, victim);
  }

  ///////////////////////////////////////////////////////////////////////
  //////////////////////      COMPARE DATA      /////////////////////////
  ///////////////////////////////////////////////////////////////////////
  int bufsize = 8192;
  unsigned char buf[bufsize];

  uint tmp_err = 0;
  
  uint pattern_0[8];
  uint pattern_rev[2] = {0,0};

  for (int i = 0; i < 8; i++) {
    pattern_0[i] = (vic_dp >> (i*4))%16;
  } 
  for (int i = 0; i < 8; i++) {
    pattern_rev[i/4] += (pattern_0[i] * 17) << (8*(i%4));
  }

  uint expected_bits[8];
  for(int i = 0; i < 8; i++) {
    expected_bits[i] = (pattern_rev[i/4] >> (8*(i%4)))%256;
  }

  for(int num_vic = 0; num_vic < victims.size(); num_vic++){
    platform.receiveData(buf, bufsize);
    tmp_err = 0;
    for (int i = 0 ; i < bufsize ; i++){
      tmp_err = expected_bits[i%8] ^ (uint8_t)buf[i];
      for (int div = 0; div < 8; div++) {
        if((tmp_err >> div)%2 == 1) {
          int wr_pttn = (expected_bits[i%8] >> div) % 2;
          int col = ((8*i + div) / 512)*8;
          int bit = (8*i + div) % 512;
          int rev_bit = 4*((bit%64) / 8) + bit%4;
          int chip = 2*(bit/64) + (bit/4)%2;
          printf("%d,%d,%d,%d,%d,%d,%d\n", bank, aggressor, victims[num_vic], col, bit, wr_pttn, rev_bit);
        }
      }
    } 
  }
}

#include "functions.h"

Inst all_nops() {
  return  __pack_mininsts(SMC_NOP(), SMC_NOP(), SMC_NOP(), SMC_NOP());
}

void SingleSided(SoftMCPlatform *platform, uint bank, uint aggressor, uint hammer_count, uint RAS_scale, uint RP_scale){
  Program p;
  uint HMR_COUNTER_REG = 7;
  uint NUM_HMR_REG = 8;

  // IMPORTANT: PREA to get around the auto-read of DRAM Bender
  p.add_inst(SMC_PRE(BAR, 0, 1), SMC_NOP(), SMC_NOP(), SMC_NOP());

  p.add_inst(SMC_LI(bank, BAR));
  p.add_inst(SMC_LI(aggressor, RAR));
  
  p.add_inst(SMC_LI(0, HMR_COUNTER_REG));
  p.add_inst(SMC_LI(hammer_count, NUM_HMR_REG));

  platform->set_aref(false);

  // Activate the aggressor row for hammer_count times
  p.add_label("HMR_BEGIN");
  p.add_inst(SMC_NOP(), SMC_NOP(), SMC_NOP(), SMC_ACT(BAR, 0, RAR, 0)); // ACT
  p.add_inst(SMC_SLEEP(7 * RAS_scale));                                 // 5 ns * 7 = 35 ns
  p.add_inst(SMC_PRE(BAR, 0, 0), SMC_NOP(), SMC_NOP(), SMC_NOP());      // PRE
  p.add_inst(all_nops());                                               // 5ns + 7.5ns = 12.5ns
  if (RP_scale > 1) 
    p.add_inst(SMC_SLEEP(3 * (RAS_scale-1))); 
  p.add_inst(SMC_ADDI(HMR_COUNTER_REG, 1, HMR_COUNTER_REG));            // Hammer count ++
  p.add_branch(p.BR_TYPE::BL, HMR_COUNTER_REG, NUM_HMR_REG, "HMR_BEGIN"); 

  platform->set_aref(true);
  p.add_inst(all_nops()); 
  p.add_inst(SMC_END());

  platform->execute(p);
}

void DoubleSided(SoftMCPlatform *platform, uint bank, uint aggressor1, uint aggressor2, uint hammer_count, uint RAS_scale, uint RP_scale){
  
  uint HMR_COUNTER_REG = 7;
  uint NUM_HMR_REG = 8;

  Program p;

  // IMPORTANT: PREA to get around the auto-read of DRAM Bender
  p.add_inst(SMC_PRE(BAR, 0, 1), SMC_NOP(), SMC_NOP(), SMC_NOP()); // 15ns

  p.add_inst(SMC_LI(bank, BAR));
  p.add_inst(SMC_LI(aggressor1, RAR));

  p.add_inst(SMC_LI(0, HMR_COUNTER_REG));
  p.add_inst(SMC_LI(hammer_count, NUM_HMR_REG));

  platform->set_aref(false);

  // Activate the aggressor row for hammer_count times
  p.add_label("HMR_BEGIN");

  // Additive RAS latency after 36ns standard tRAS, step size is 5 * 6 = 30ns
  if (RAS_scale > 1)
    p.add_inst(SMC_SLEEP(7 * (RAS_scale - 1))); // 20 ns 

  // PRE aggressor row 2
  p.add_inst(SMC_PRE(BAR, 0, 0), SMC_NOP(), SMC_NOP(), SMC_NOP()); // 15 ns
  p.add_inst(SMC_LI(aggressor1, RAR));

  // Additive RP latency after 15ns standard tRP, step size is 5 * 6 = 30ns
  if (RP_scale > 1)
    p.add_inst(SMC_SLEEP(3 * (RP_scale - 1)));

  // ACT aggressor row 1
  p.add_inst(SMC_NOP(), SMC_NOP(), SMC_NOP(), SMC_ACT(BAR, 0, RAR, 0));
  p.add_inst(SMC_LI(aggressor2, RAR));
  p.add_inst(SMC_SLEEP(6)); // 30 ns
  // Additive RAS latency after 36ns standard tRAS, step size is 5 * 6 = 30ns
  if (RAS_scale > 1)
    p.add_inst(SMC_SLEEP(7 * (RAS_scale - 1)));

  // PRE aggressor row 1
  p.add_inst(SMC_PRE(BAR, 0, 0), SMC_NOP(), SMC_NOP(), SMC_NOP());
  p.add_inst(SMC_ADDI(HMR_COUNTER_REG, 1, HMR_COUNTER_REG));
  // Additive RP latency after 15ns standard tRP, step size is 5 * 6 = 30ns
  if (RP_scale > 1)
    p.add_inst(SMC_SLEEP(3 * (RP_scale - 1)));

  // ACT aggressor row 2
  p.add_inst(SMC_NOP(), SMC_NOP(), SMC_NOP(), SMC_ACT(BAR, 0, RAR, 0));
  p.add_branch(p.BR_TYPE::BL, HMR_COUNTER_REG, NUM_HMR_REG, "HMR_BEGIN");

  platform->set_aref(true);

  p.add_inst(SMC_PRE(BAR, 0, 0), SMC_NOP(), SMC_NOP(), SMC_NOP());

  p.add_inst(all_nops()); 
  p.add_inst(SMC_END());

  platform->execute(p);
}

void WriteRow(SoftMCPlatform *platform, uint pattern, uint bank, uint row){
  Program p;
  p.add_inst(SMC_LI(bank, BAR));
  p.add_inst(SMC_LI(row, RAR));
  // Column address stride is 8 since we are doing BL=8
  p.add_inst(SMC_LI(8, CASR));

  uint pattern_0[8];
  uint pattern_rev[2] = {0,0};

  for (int i = 0; i < 8; i++) {
    pattern_0[i] = (pattern >> (i*4))%16;
  } 
  for (int i = 0; i < 8; i++) {
    pattern_rev[i/4] += (pattern_0[i] * 17) << (8*(i%4));
  }

  // Load the cache line into the wide data register
  for(uint i = 0 ; i < 16 ; i+=2)
  {
    p.add_inst(SMC_LI(pattern_rev[0], PATTERN_REG));
    p.add_inst(SMC_LDWD(PATTERN_REG, i));
    p.add_inst(SMC_LI(pattern_rev[1], PATTERN_REG));
    p.add_inst(SMC_LDWD(PATTERN_REG, i+1));
  }

  // Activate and write to the row
  p.add_inst(SMC_PRE(BAR, 0, 1), SMC_NOP(), SMC_NOP(), SMC_NOP());
  p.add_inst(SMC_LI(0, CAR));
  p.add_inst(all_nops()); 
  p.add_inst(all_nops()); 

  p.add_inst(SMC_ACT(BAR, 0, RAR, 0), SMC_NOP(), SMC_NOP(), SMC_NOP());
  p.add_inst(all_nops()); // 5ns
  p.add_inst(all_nops()); // 5ns

  for(int i = 0 ; i < 128 ; i++)
  {
    p.add_inst(SMC_WRITE(BAR, 0, CAR, 1, 0, 0), SMC_NOP(), SMC_NOP(), SMC_NOP());
    p.add_inst(all_nops()); // 5ns
  }
  p.add_inst(SMC_SLEEP(4)); // 20 ns for tWR
  
  p.add_inst(SMC_PRE(BAR, 0, 0), SMC_NOP(), SMC_NOP(), SMC_NOP());
  p.add_inst(all_nops()); 
  p.add_inst(all_nops());

  p.add_inst(SMC_END());
  
  platform->execute(p);    
}
void WriteRows(){

}

void ReadRow(SoftMCPlatform *platform, uint bank, uint row){
  Program p;
  p.add_inst(SMC_LI(bank, BAR));
  p.add_inst(SMC_LI(row, RAR));
  // Column address stride is 8 since we are doing BL=8
  p.add_inst(SMC_LI(8, CASR));

  // Activate and read from the row
  p.add_inst(SMC_PRE(BAR, 0, 1), SMC_NOP(), SMC_NOP(), SMC_NOP());
  p.add_inst(SMC_LI(0, CAR));
  p.add_inst(all_nops());
  p.add_inst(all_nops());

  p.add_inst(SMC_ACT(BAR, 0, RAR, 0), SMC_NOP(), SMC_NOP(), SMC_NOP());
  p.add_inst(all_nops()); 
  p.add_inst(all_nops());

  for(int i = 0 ; i < 128 ; i++)
  {
    p.add_inst(SMC_READ(BAR, 0, CAR, 1, 0, 0), SMC_NOP(), SMC_NOP(), SMC_NOP());
    p.add_inst(all_nops()); 
  }
  p.add_inst(SMC_SLEEP(4));

  p.add_inst(SMC_PRE(BAR, 0, 0), SMC_NOP(), SMC_NOP(), SMC_NOP());
  p.add_inst(SMC_SLEEP(3));

  p.add_inst(SMC_END());

  platform->execute(p);
}

void ReadRows(){

}
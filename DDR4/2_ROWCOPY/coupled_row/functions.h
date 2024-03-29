#include "instruction.h"
#include "prog.h"
#include "platform.h"
#include "SMC_Registers.h"

#include <iostream>

#define NUM_COL 128

using namespace std;

Inst all_nops();

void SingleSided(SoftMCPlatform *platform, uint bank, uint aggressor, uint hammer_count, uint RAS_scale, uint RP_scale);
void DoubleSided(SoftMCPlatform *platform, uint bank, uint aggressor1, uint aggressor2, uint hammer_count, uint RAS_scale, uint RP_scale);
void CustomizedDoubleSided(SoftMCPlatform *platform, uint bank, uint aggressor1, uint aggressor2, uint hammer_count, uint RAS_scale, uint where);
void WriteRow(SoftMCPlatform *platform, uint pattern, uint bank, uint row);
void WriteRows();
void ReadRow(SoftMCPlatform *platform, uint bank, uint row);
void ReadRows();
void RowCopy(SoftMCPlatform *platform, uint bank, uint src_row, uint dst_row, uint wait);
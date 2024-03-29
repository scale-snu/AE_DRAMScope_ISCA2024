#ifndef SOFTMC_H
#define SOFTMC_H

#include <unistd.h>
#include <stdint.h>
#include <stdlib.h>
#include <vector>
#include <sys/time.h>
#include "xdma.h"

#define GET_TIME_INIT(num) struct timeval _timers[num]

#define GET_TIME_VAL(num) gettimeofday(&_timers[num], NULL)

#define TIME_VAL_TO_MS(num) (((double)_timers[num].tv_sec*1000.0) + ((double)_timers[num].tv_usec/1000.0))
#define TIME_VAL_TO_US(num) (((double)_timers[num].tv_sec) + ((double)_timers[num].tv_usec))

#define RA_WIDTH    14
#define CA_WIDTH    5
#define BA_WIDTH    2
#define BG_WIDTH    2
#define PC_WIDTH    1
#define CH_WIDTH    3
#define SID_WIDTH   1
#define R_WIDTH     6
#define C_WIDTH     8
#define DATA_WIDTH  8

// The current instruction format is 32 bits wide. But we allocate
// 64 bits (2 words) for each instruction to keep the hardware simple.
// Having C_PCI_DATA_WIDTH of 64 performs better than 32 when sending
// data that we read from the DRAM back to the host machine.
// TODO: modify the hardware to support 32-bit instructions.
#define INSTR_SIZE  16//2 words 64 bit // 16 word 512 bit

#define NUM_ROWS    16384
#define NUM_COLS    32
#define NUM_BANKS   4
#define NUM_PC      2
#define NUM_GROUPS  4
#define NUM_STACKS  1 //2


typedef uint64_t Instruction;
typedef uint32_t uint;

//DO NOT EDIT (unless you change the verilog code)
enum class INSTR_TYPE{
  END_OF_INSTRS = 0,
  SET_BUS_DIR = 1,
  SET_TREFI = 2,
  SET_TRFC = 3,
  WAIT = 4,
  ACT = 8,
  PRE = 9,
  REF = 10,
  HAMMER = 11,
  READ = 12,
  WRITE = 13,
  MRS = 14
};

class InstructionSequence{

  public:
    InstructionSequence();
    InstructionSequence(const uint capacity);
    virtual ~InstructionSequence();

    void insert(const Instruction c);
    void execute(fpga_t* fpga);

    uint size;
    Instruction* instrs;
  private:
    uint capacity;
    const static uint init_cap = 256;
};


class DramAddr{

  public:
    uint row;
    uint bank;

    DramAddr() : row(0), bank(0) {}
    DramAddr(uint row, uint bank){ this->row = row; this->bank = bank;}
};

Instruction genACT    (uint sid, uint ch, uint pc, uint bg, uint ba, uint row);
Instruction genPRE    (uint sid, uint ch, uint pc, uint bg, uint ba);
Instruction genPREALL (uint sid, uint ch, uint pc, uint bg, uint ba);
Instruction genWR     (uint sid, uint ch, uint pc, uint bg, uint ba, uint col, uint8_t pattern);
Instruction genRD     (uint sid, uint ch, uint pc, uint bg, uint ba, uint col);
Instruction genWAIT   (uint cycles);
Instruction genEND    ();
Instruction setMRS    (uint ch, uint num, uint opcode);

Instruction genREF (uint sid, uint ch, uint pc); 
Instruction set_tREFI(uint tREFI);
Instruction set_tRFC(uint tRFC);


// for Row Hammer 
Instruction genHAMMER  (uint sid, uint ch, uint pc, uint bg, uint ba, uint row, uint hammer_count);


#endif //SOFTMC_H


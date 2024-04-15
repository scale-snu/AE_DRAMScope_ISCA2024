//uncomment the line below to run a simulation using "tb_softMC_top"
`define tCK 4000

// instruction opcode
`define DRAM_INSTR 4'b1xxx
`define ROW_CMD    2'b10
`define COL_CMD    2'b11
  // row commands
`define ACT        4'b1000
`define PRE        4'b1001
`define REF        4'b1010
`define ROWHAMMER  4'b1011

// column commands
`define READ       4'b1100
`define WRITE      4'b1101
`define MRS        4'b1110
  // etc
`define END_ISEQ   4'b0000
`define SET_TREFI  4'b0010
`define SET_TRFC   4'b0011
`define WAIT       4'b0100


`define RA_OFFSET     13 // 0 ~ 13
`define CA_OFFSET     4  // 0 ~ 4
`define BA_OFFSET     15 // 14 ~ 15
`define BG_OFFSET     17 // 16 ~ 17
`define PC_OFFSET     18 // 18
`define CH_OFFSET     21 // 19 ~ 21
`define SID_OFFSET    22 // 22
`define CKE_OFFSET    23 // 23
`define PAR_OFFSET    24 // 24
`define SEC_OFFSET    25 // 25
`define WRDATA_OFFSET 12 // 12 ~ 5
`define MRS_OP_OFFSET 12 // 12 ~ 5



//Set accordingly to tCK, (6, 6, 14 if tCK = 4000ps)
`define DEF_TRP   15000/`tCK
`define DEF_TRCD  15000/`tCK
`define DEF_TRAS  33000/`tCK

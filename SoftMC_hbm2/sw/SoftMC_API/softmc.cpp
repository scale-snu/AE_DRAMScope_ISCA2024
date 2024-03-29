#include "softmc.h"
#include <fstream>
#include <iostream>
#include <cassert>

using namespace std;

InstructionSequence::InstructionSequence() {
	capacity = 100000;
	instrs = new Instruction[capacity];
	size = 0;
}

InstructionSequence::InstructionSequence(const uint capacity){
	instrs = new Instruction[capacity];
	size = 0;
	this->capacity = capacity;
}

InstructionSequence::~InstructionSequence(){
	delete[] instrs;
}

void InstructionSequence::insert(const Instruction c){
	if(size == capacity){
		Instruction* tmp = new Instruction[capacity*2];

		for(uint i = 0; i < size; i++)
			tmp[i] = instrs[i];

		delete[] instrs;
		capacity *=2;
		instrs = tmp;
	}
	instrs[size] = c;
	size++;
}

void InstructionSequence::execute(fpga_t* fpga){
  for(int i = 0; i < size; i++) {
    fpga_send(fpga, 0, (void*)&instrs[i], 8, 0, 1, 0);
  }
}

//==========================================================================================================
// DRAM instructions 
//==========================================================================================================

Instruction genACT(uint sid, uint ch, uint pc, uint bg, uint ba, uint row){
	Instruction instr = (uint)INSTR_TYPE::ACT;
	instr <<= 28 - RA_WIDTH - BA_WIDTH - BG_WIDTH - PC_WIDTH - CH_WIDTH - SID_WIDTH; // << 28 - 23
	instr |= 0x1;
	instr <<= SID_WIDTH; // << 1
	instr |= sid;
	instr <<= CH_WIDTH; // << 3
	instr |= ch;
	instr <<= PC_WIDTH; // << 1
	instr |= pc;
	instr <<= BG_WIDTH; // << 2
	instr |= bg;
	instr <<= BA_WIDTH; // << 2
	instr |= ba;
	instr <<= RA_WIDTH; // << 14
	instr |= row;
	return instr;
}


Instruction genPRE(uint sid, uint ch, uint pc, uint bg, uint ba){ // no command to precharge all rows in all-banks
	Instruction instr = (uint)INSTR_TYPE::PRE;

	instr <<= 28 - RA_WIDTH - BA_WIDTH - BG_WIDTH - PC_WIDTH - CH_WIDTH - SID_WIDTH;
	instr |= 0x1;
	instr <<= SID_WIDTH;
	instr |= sid;
	instr <<= CH_WIDTH;
	instr |= ch;
	instr <<= PC_WIDTH;
	instr |= pc;
	instr <<= BG_WIDTH;
	instr |= bg;
	instr <<= BA_WIDTH;
	instr |= ba;
	instr <<= RA_WIDTH;
		
	return instr;
}
Instruction genPREALL(uint sid, uint ch, uint pc, uint bg, uint ba){ // no command to precharge all rows in all-banks
	Instruction instr = (uint)INSTR_TYPE::PRE;

	instr <<= 28 - RA_WIDTH - BA_WIDTH - BG_WIDTH - PC_WIDTH - CH_WIDTH - SID_WIDTH;
	//instr |= 0x1;
	instr <<= SID_WIDTH;
	instr |= sid;
	instr <<= CH_WIDTH;
	instr |= ch;
	instr <<= PC_WIDTH;
	instr |= pc;
	instr <<= BG_WIDTH;
	instr |= bg;
	instr <<= BA_WIDTH;
	instr |= ba;
	instr <<= RA_WIDTH;
  instr |= 0x1;
		
	return instr;
}

Instruction genWR(uint sid, uint ch, uint pc, uint bg, uint ba, uint col, uint8_t pattern){
	Instruction instr = (uint)INSTR_TYPE::WRITE;

	instr <<= 28 - CA_WIDTH - DATA_WIDTH - 1 - BA_WIDTH - BG_WIDTH - PC_WIDTH - CH_WIDTH - SID_WIDTH;
	instr |= 0x1;
	instr <<= SID_WIDTH; // << 1
	instr |= sid;
	instr <<= CH_WIDTH; // << 3
	instr |= ch;
	instr <<= PC_WIDTH; // << 1
	instr |= pc;
	instr <<= BG_WIDTH; // << 2 
	instr |= bg;
	instr <<= BA_WIDTH; // << 2
	instr |= ba;

	instr <<= DATA_WIDTH + 1;
	instr |= pattern;
	instr <<= CA_WIDTH;
	instr |= col;
		
	return instr;
}

Instruction genRD(uint sid, uint ch, uint pc, uint bg, uint ba, uint col){
	Instruction instr = (uint)INSTR_TYPE::READ;

	instr <<= 28 - CA_WIDTH - DATA_WIDTH - 1 - BA_WIDTH - BG_WIDTH - PC_WIDTH - CH_WIDTH - SID_WIDTH;
	instr |= 0x1;
	instr <<= SID_WIDTH;
	instr |= sid;
	instr <<= CH_WIDTH;
	instr |= ch;
	instr <<= PC_WIDTH;
	instr |= pc;
	instr <<= BG_WIDTH;
	instr |= bg;
	instr <<= BA_WIDTH;
	instr |= ba;

	instr <<= DATA_WIDTH + 1 + CA_WIDTH;
	instr |= col;
		
	return instr;
}


Instruction genWAIT(uint cycles){ //min 1, max 1023
	assert(cycles >= 1);
	assert(cycles <= 1023 && "Could not wait for more than 1023 cycles since the current hardware implementation has a 10 bit counter for this purpose.");
  
	Instruction instr = (uint)INSTR_TYPE::WAIT;
	instr <<= 28;
	instr |= cycles;

	return instr;
}


Instruction genEND(){
	return (Instruction)((uint)INSTR_TYPE::END_OF_INSTRS << 28);
}

Instruction setMRS(uint ch, uint num, uint opcode) {
	Instruction instr = (uint)INSTR_TYPE::MRS;
	instr <<= 5;
	instr |= 0x1; // cke = 1
	instr <<= 9;
	instr |= num;
	instr <<= 1;
	
	instr <<= 8;
	instr |= opcode;
	instr <<= 5;
	return instr;
}

//==========================================================================================================
// Row hammer instruction 
//==========================================================================================================

Instruction genHAMMER  (uint sid, uint ch, uint pc, uint bg, uint ba, uint row, uint hammer_count) {
  Instruction instr = (uint)INSTR_TYPE::HAMMER;
  instr <<= 5; // 9
  instr |= hammer_count;
  instr <<= 1; // 10
  instr |= sid;
  instr <<= 3; // 13
  instr |= ch;
  instr <<= 1;  // 14
  instr |= pc; 
  instr <<= 2; // 16
  instr |= bg; 
  instr <<= 2; // 18
  instr |= ba;
  instr <<= 14;
  instr |= row;
  return instr;
}

//==========================================================================================================
// Refresh instructions 
//==========================================================================================================

Instruction genREF (uint sid, uint ch, uint pc) {
	Instruction instr = (uint)INSTR_TYPE::REF;

	instr <<= 28 - RA_WIDTH - BA_WIDTH - BG_WIDTH - PC_WIDTH - CH_WIDTH - SID_WIDTH;
	//instr |= 0x1;
	instr <<= SID_WIDTH;
	instr |= sid;
	instr <<= CH_WIDTH;
	instr |= ch;
	instr <<= PC_WIDTH;
	instr |= pc;
	instr <<= (BG_WIDTH + BA_WIDTH + RA_WIDTH);
  instr |= 0x1;	
	return instr;
}


    
Instruction set_tREFI(uint tREFI){	
  Instruction instr = (uint)INSTR_TYPE::SET_TREFI;

  instr <<= 28;
	instr |= tREFI; 

	return instr;
}

Instruction set_tRFC(uint tRFC){
	Instruction instr = (uint)INSTR_TYPE::SET_TRFC;

	instr <<= 28;
	instr |= tRFC; 

	return instr;
}



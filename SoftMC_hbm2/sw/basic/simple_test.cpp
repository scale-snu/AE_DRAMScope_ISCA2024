#include <iostream>
#include <cstring>
#include <cstdio>

#include "xdma.h"
#include "softmc.h"

#include "set_instrs.h"

int main(){
  if(getuid()) {
    printf("This program must be run as root\n");
    return 0;
  }

	fpga_t* fpga;
	int fid = 0; //fpga id

  fflush(stdout);

  fpga = fpga_open(fid);
	if(!fpga){
		printf("Problem on opening the fpga \n");
		return -1;
	} else {
	  printf("The FPGA has been opened successfully! \n");
  }

  ///////////////////////////////////////////////////////////////////
  // Simulation start
  //***************************************************************//

  int instr_size = 0;
  Instruction input_inst = 0xFFFFFFFF;

  InstructionSequence* iseq = new InstructionSequence;

  // Insert instructions from "set_instrs.h"
  while(input_inst != genEND()) 
  {
    input_inst = set_instrs[instr_size++];
    iseq->insert(input_inst);
  }

  // send data to fpga
  iseq->execute(fpga);

  int rc;
  int read_num = 6; 
  int read_count = 0; 

  Instruction* rbuf = new Instruction[8*read_num];
  Instruction* temp = new Instruction[8];
  uint data_size = sizeof(Instruction) * 8 * read_num;
  
  int chunk = 8;
  for (int i = 0; i < 8*read_num; i+=chunk) {
    rc = fpga_recv(fpga, 0, (void*)&temp[0], 8*chunk, 0, 0);    
    
    if(rc < 0){
      break;;
    } else {
      for (int j = 0; j < 8; j++)
        rbuf[i+j] = temp[j];
    }
    read_count++;
  }  
  printf("\n            |Pseudo channel 1|");
  printf("|Pseudo channel 0|\n");
  bool success = true;
  for(int i = 0; i < 8*read_num; i+=8) {
    printf("[OUTPUT %3d]: ", i/8);
    for(int j = 7; j >= 0; j-=4) {
      printf("%16lx ", (uint64_t)rbuf[i+j]);
      if (((j == 7) && (i/8 < read_num/2)) || ((j == 3) && (i/8 >= read_num/2))) {
        if ((uint64_t)rbuf[i+j] != (uint64_t)(0x0)) 
          success = false;
      } else {
        if ((uint64_t)rbuf[i+j] != (uint64_t)(0x1111111111111111 * (i/8+1))) 
          success = false;
      }
    }
    printf("\n");
  }

  
  //***************************************************************//
  // Simulation done
  ///////////////////////////////////////////////////////////////////
  if (success) {
    printf("\n=====================\n");
    printf("===    Success    ===\n");
    printf("=====================\n");
  } else {
    printf("\n=====================\n");
    printf("===      Fail     ===\n");
    printf("=====================\n");
  }

	fpga_close(fpga);
  delete [] rbuf;
  delete iseq;

	return 0;
}


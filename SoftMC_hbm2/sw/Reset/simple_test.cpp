#include <iostream>
#include <cstring>
#include <cstdio>

#include "xdma.h"
#include "softmc.h"

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

  InstructionSequence* iseq = new InstructionSequence;
  for(int i = 0; i < 8; i++)
    iseq->insert(genWAIT(1));

  iseq->insert(genEND());
  iseq->execute(fpga);

  int rc;
  
  Instruction* temp = new Instruction[8];
  uint data_size = sizeof(Instruction)*8;
  
  for (int i = 0; i < 8192; i++) 
    rc = fpga_recv(fpga, 0, (void*)&temp[0], data_size, 0, 0);    

	fpga_close(fpga);
  delete temp;
  delete iseq;

	return 0;
}


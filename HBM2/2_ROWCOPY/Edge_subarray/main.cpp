#include <iostream>
#include <cstring>
#include <cstdio>

#include "xdma.h"
#include "softmc.h"

#include "in_memory.h"

int main(int argc, char* argv[]){
  if(getuid()) {
    printf("This program must be run as root\n");
    return 0;
  }

	fpga_t* fpga;
	int fid = 0; //fpga id
	int ch = 0; //channel id
/*
  if(argc != 6 || strcmp(argv[2], "--help") == 0){
		printf("%d\n",argc);
    printHelp(argv);
		return -2;
	}

  std::string s_ref(argv[1]);
  std::string s_ref1(argv[2]);
  std::string s_ref2(argv[3]);
  std::string s_ref3(argv[4]);
  std::string s_ref4(argv[5]);
  int src_row = 0;
  int dst_row = 0;
  int pc = 0;
  int bg = 0;
  int ba = 0;

  try{
      src_row = stoi(s_ref);
      dst_row = stoi(s_ref1);
      pc = stoi(s_ref2);
      bg = stoi(s_ref3);
      ba = stoi(s_ref4);
  }catch(...){
      printHelp(argv);
      return -3;
  }

  if(src_row <= 0 || dst_row < 0){
      printHelp(argv);
      return -4;
  }
*/
  // open an FPGA device
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
  ///////////////////////////////////////////////////////////////////
	test(fpga);

  ///////////////////////////////////////////////////////////////////
  // Simulation done
  ///////////////////////////////////////////////////////////////////
	fpga_close(fpga);

	return 0;
}


#include <iostream>
#include <cstring>
#include <cstdio>

#include "xdma.h"
#include "softmc.h"

#include "rowhammer.h"

int main(int argc, char* argv[]){
  if(getuid()) {
    std::cout << "This program must be run as root" << std::endl;
    return 0;
  }

	fpga_t* fpga;
	int fid = 0; //fpga id

  if(argc != 7 || strcmp(argv[2], "--help") == 0){
		printHelp(argv);
		return -2;
	}

  int hammer_count = 0;
  int aggr_row = 0;
  int pc = 0;
  int bg = 0;
  int ba = 0;
  uint dp = 0x00;

  try{
      hammer_count = atoi(argv[1]);
      aggr_row = atoi(argv[2]);
      pc = atoi(argv[3]);
      bg = atoi(argv[4]);
      ba = atoi(argv[5]);
      dp = strtol(argv[6], nullptr, 16);
  }catch(...){
      printHelp(argv);
      return -3;
  }

  if(hammer_count <= 0 || aggr_row < 0){
      printHelp(argv);
      return -4;
  }

  // open an FPGA device
  fflush(stdout);
  fpga = fpga_open(fid);
  /*
	if(!fpga){
		std::cerr << "Problem on opening the fpga" << std::endl;
		return -1;
	} else {
	  std::cerr << "The FPGA has been opened successfully!" << std::endl;
  }
  */

  ///////////////////////////////////////////////////////////////////
  // Simulation start
  //***************************************************************//

  //std::cerr << "aggr_row,vic_row,pc,bg,ba,col,bit" << std::endl;
	testRH(fpga, hammer_count, aggr_row, pc, bg, ba, dp);

  //***************************************************************//
  // Simulation done
  ///////////////////////////////////////////////////////////////////

	fpga_close(fpga);

	return 0;
}


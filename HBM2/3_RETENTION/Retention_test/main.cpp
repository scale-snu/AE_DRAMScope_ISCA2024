#include <iostream>
#include <cstring>
#include <cstdio>

#include "xdma.h"
#include "softmc.h"

#include "retention.h"

int main(int argc, char* argv[]){
  if(getuid()) {
    printf("This program must be run as root\n");
    return 0;
  }

	fpga_t* fpga;
	int fid = 0; //fpga id
	int ch = 0; //channel id

  if(argc != 3 || strcmp(argv[1], "--help") == 0){
		printHelp(argv);
		return -2;
	}

  std::string s_ref1(argv[1]);
  std::string s_ref2(argv[2]);
  int refresh_interval = 0;
  int data = 0;

  try{
      refresh_interval = stoi(s_ref1);
      data = stoi(s_ref2);
  }catch(...){
      printHelp(argv);
      return -3;
  }

  if(refresh_interval <= 0){
      printHelp(argv);
      return -4;
  }

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
  //***************************************************************//
     
  printf("Starting Retention Time Test @ %d ms! \n", refresh_interval);

	testRetention(fpga, refresh_interval, data);

  //***************************************************************//
  // Simulation done
  ///////////////////////////////////////////////////////////////////

	fpga_close(fpga);

	return 0;
}


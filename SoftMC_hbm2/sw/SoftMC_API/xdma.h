#ifndef XDMA_H
#define XDMA_H

#include <stdlib.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>

//#define OFFSET_IN_FPGA_DRAM   0x10000000
#define OFFSET_IN_FPGA_DRAM   0x80000000
struct fpga_t
{
	int fd_r;
  int fd_w;
	int id;
};
typedef struct fpga_t fpga_t;

fpga_t * fpga_open(int id);

int fpga_send(fpga_t * fpga, int chnl, void * data, int len, int destoff, 
	int last, long long timeout);

void fpga_close(fpga_t * fpga);

int fpga_recv(fpga_t * fpga, int chnl, void * data, int len, int destoff, long long timeout);

#endif // XDMA_H

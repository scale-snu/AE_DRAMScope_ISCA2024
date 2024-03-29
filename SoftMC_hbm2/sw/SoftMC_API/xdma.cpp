#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include "xdma.h"

fpga_t * fpga_open(int id) 
{
	fpga_t * fpga;

	// Allocate space for the fpga_dev
	fpga = (fpga_t *)malloc(sizeof(fpga_t));
	if (fpga == NULL)
		return NULL;
	fpga->id = id;	

	// Open the device file.
	fpga->fd_r = open("/dev/xdma0_c2h_0", O_RDONLY);
  fpga->fd_w = open("/dev/xdma0_h2c_0", O_WRONLY);
	if (fpga->fd_r < 0 || fpga->fd_w < 0) {
		free(fpga); 
		return NULL;
	}
  return fpga;
}

void fpga_close(fpga_t * fpga) 
{
	// Close the device file.
	close(fpga->fd_r);
  close(fpga->fd_w);
	free(fpga);
}

int fpga_send(fpga_t * fpga, int chnl, void * data, int len, int destoff, 
	int last, long long timeout)
{
  int ret;
  //printf("Write the data\n");
  ret = pwrite(fpga->fd_w , (char*)data, len, OFFSET_IN_FPGA_DRAM + destoff); // size=1 means 1 byte
  //ret = write(fpga->fd_w , (char*)data, len); // size=1 means 1 byte
  if (ret < 0) {
    perror("write failed with errno");
  }

  return ret;
}

int fpga_recv(fpga_t * fpga, int chnl, void * data, int len, int destoff, long long timeout)
{
	int ret;
  ret = pread(fpga->fd_r , (char*)data, len, OFFSET_IN_FPGA_DRAM + destoff);
  //ret = read(fpga->fd_r , (char*)data, len);
  if (ret < 0) {
    perror("write failed with errno");
  }

  return ret;
}

import os, sys
import matplotlib.pyplot as plt
import seaborn as sns

def read_file_chunks(file_path, chunk_size=100000):
    with open(file_path, 'r') as log_file:
        while True:
            lines = log_file.readlines(chunk_size)
            if not lines:
                break
            for line in lines:
                yield line

def remapping():
    remap['s'] = [0,1,2,3,4,5,6,7,14,15,12,13,10,11,8,9]
    remap['m'] = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
    remap['h'] = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]


def adjacent(vendor='s', aggr_row=0, victim_row=0, bit=0):
    key = vendor
    div_aggr = aggr_row % 16
    div_vic  = victim_row % 16
    
    index1 = remap[key].index(div_aggr)
    index2 = remap[key].index(div_vic)
    distance = index1-index2
    return distance

if __name__ == '__main__':
    remap = {}
    bursts = {}
    remapping()
    chunk_size = 100000
  
    vendor = 's'
    count = 200000
    RD_DATA = 32
    N_ROW = 1024
    N_COL = pow(2,5)
    N_BIT = 256

    gate_A = {}
    gate_B = {}
    
    for data in [0, 1]:
        gate_A[data] = 0
        gate_B[data] = 0

    for i in range(1, len(sys.argv)):
        file = sys.argv[i]
        for line in read_file_chunks(file, chunk_size):
            if "a" in line: continue
            
            aggr, vic, pc, bg, ba, col, bit, wr_pttn = map(int,line.strip().split(","))
            judge = adjacent(vendor, aggr, vic, bit)
            rev_bit = (N_BIT * col + bit) % 16
            
            ######################################
            ############     6F2     #############
            ######################################
            if judge == -1 or judge == 15:
                if vic%2 == 1:
                    if rev_bit == 0:
                        gate_A[wr_pttn] += 1 / N_ROW / N_COL / N_BIT
                    else:
                        gate_B[wr_pttn] += 1 / N_ROW / N_COL / N_BIT
                else:
                    if rev_bit == 1:
                        gate_A[wr_pttn] += 1 / N_ROW / N_COL / N_BIT
                    else:
                        gate_B[wr_pttn] += 1 / N_ROW / N_COL / N_BIT
            elif judge == 1 or judge == -15:
                if vic%2 == 1:
                    if rev_bit == 1:
                        gate_A[wr_pttn] += 1 / N_ROW / N_COL / N_BIT
                    else:
                        gate_B[wr_pttn] += 1 / N_ROW / N_COL / N_BIT
                else:
                    if rev_bit == 0:
                        gate_A[wr_pttn] += 1 / N_ROW / N_COL / N_BIT
                    else:
                        gate_B[wr_pttn] += 1 / N_ROW / N_COL / N_BIT

    ##############################################
    ###############     plot     #################
    ##############################################
    plt.subplot(121)
    plt.title("Data 0", fontsize = 15, weight='bold')
    plt.ylim([0,0.00006])
    plt.yticks(fontsize=10)
    plt.xticks(range(0, 2), fontsize=10)
    plt.bar(["Gate A", "Gate B"], [gate_A[0], gate_B[0]], width=0.5)
    
    plt.subplot(122)
    plt.title("Data 1", fontsize = 15, weight='bold')
    plt.ylim([0,0.00006])
    plt.yticks(fontsize=10)
    plt.xticks(range(0, 2), fontsize=10)
    plt.bar(["Gate A", "Gate B"], [gate_A[1], gate_B[1]], width=0.5)
    
    plt.tight_layout()
    
    plt.savefig(f'./figure_13.png')
    plt.cla()

import os, sys
import matplotlib.pyplot as plt
import seaborn as sns

def read_file_chunks(file_path, chunk_size=2):
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
    
    upper = {}
    lower = {}
    gate_A = {}
    gate_B = {}
    
    for data in range(2):
        upper[data] = {}
        lower[data] = {}
        for bit in range(0,RD_DATA):
            upper[data][bit] = 0
            lower[data][bit] = 0
       
    for i in range(1, len(sys.argv)):
        file = sys.argv[i]
        for line in read_file_chunks(file, chunk_size):
            if "a" in line: continue

            aggr, vic, pc, bg, ba, col, bit, wr_pttn = map(int,line.strip().split(","))
            judge = adjacent(vendor, aggr, vic, bit)
            rev_bit = (N_BIT * col + bit) % RD_DATA
                
            ######################################
            ############     6F2     #############
            ######################################
            if judge == -1 or judge == 15:
                if vic%2 == 1:
                    upper[wr_pttn][rev_bit] += 1 / N_ROW / N_COL / N_BIT
                else:
                    lower[wr_pttn][rev_bit] += 1 / N_ROW / N_COL / N_BIT
            elif judge == 1 or judge == -15:
                if vic%2 == 1:
                    lower[wr_pttn][rev_bit] += 1 / N_ROW / N_COL / N_BIT
                else:
                    upper[wr_pttn][rev_bit] += 1 / N_ROW / N_COL / N_BIT

    ##############################################
    ###############     plot     #################
    ##############################################
    plt.subplot(221)
    plt.title("Upper aggressor", fontsize = 15, weight='bold')
    plt.ylim([0,0.000004])
    plt.yticks(fontsize=10)
    plt.xticks(range(0, RD_DATA, 4), fontsize=10)
    plt.plot([i for i in range(0, RD_DATA)], upper[0].values(), linestyle='-', marker='o', markersize=4)
    
    plt.subplot(222)
    plt.title("Upper aggressor", fontsize = 15, weight='bold')
    plt.ylim([0,0.000004])
    plt.yticks(fontsize=10)
    plt.xticks(range(0, RD_DATA, 4), fontsize=10)
    plt.plot([i for i in range(0, RD_DATA)], upper[1].values(), linestyle='-', marker='o', markersize=4)
    
    plt.subplot(223)
    plt.title("Lower aggressor", fontsize = 15, weight='bold')
    plt.ylim([0,0.000004])
    plt.yticks(fontsize=10)
    plt.xticks(range(0, RD_DATA, 4), fontsize=10)
    plt.plot([i for i in range(0, RD_DATA)], lower[0].values(), linestyle='-', marker='o', markersize=4)
    
    plt.subplot(224)
    plt.title("Lower aggressor", fontsize = 15, weight='bold')
    plt.ylim([0,0.000004])
    plt.yticks(fontsize=10)
    plt.xticks(range(0, RD_DATA, 4), fontsize=10)
    plt.plot([i for i in range(0, RD_DATA)], lower[1].values(), linestyle='-', marker='o', markersize=4)

    plt.tight_layout()
    
    plt.savefig(f'./figure_12.png')
    plt.cla()

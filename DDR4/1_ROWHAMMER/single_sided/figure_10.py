import os, sys
import matplotlib.pyplot as plt

count = 200000

RD_DATA = 32
N_ROW = 1024 # num_rows
N_COL = pow(2,10)
N_BIT = 65536 / 16

edge = [0 for i in range(2)]
typical = [0 for i in range(2)]

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

def burst_info():
    bursts[0] = [0,1,2,3,4,5,6,7]
    bursts[1] = [1,2,3,0,5,6,7,4]
    bursts[2] = [2,3,0,1,6,7,4,5]
    bursts[3] = [3,0,1,2,7,4,5,6]
    bursts[4] = [4,5,6,7,0,1,2,3]
    bursts[5] = [5,6,7,4,1,2,3,0]
    bursts[6] = [6,7,4,5,2,3,0,1]
    bursts[7] = [7,4,5,6,3,0,1,2]
    
def bit_index(chip, bit):
    bitmap = {}

    # primary side
    '''
    bitmap[0] = [2,0,3,1] # 3
    bitmap[1] = [3,1,2,0] # 7
    bitmap[2] = [0,2,1,3] # 11
    bitmap[3] = [3,1,2,0] 
    bitmap[4] = [3,0,2,1] # 19
    bitmap[5] = [3,1,2,0]
    bitmap[6] = [0,2,1,3] # 27
    bitmap[7] = [3,1,2,0]
    bitmap[8] = [0,3,1,2] # 35
    bitmap[9] = [3,1,2,0]
    bitmap[10] = [0,2,1,3] # 43
    bitmap[11] = [3,1,2,0]
    bitmap[12] = [0,2,1,3] # 51
    bitmap[13] = [3,1,2,0]
    bitmap[14] = [3,1,2,0] # 59
    bitmap[15] = [3,1,2,0]
    '''
    
    # secondary side
    
    bitmap[0] = [0,2,1,3] # 3
    bitmap[1] = [1,3,0,2] # 7
    bitmap[2] = [2,0,3,1] # 11
    bitmap[3] = [1,3,0,2] 
    bitmap[4] = [0,3,1,2] # 19
    bitmap[5] = [1,3,0,2]
    bitmap[6] = [2,0,3,1] # 27
    bitmap[7] = [1,3,0,2]
    bitmap[8] = [3,0,2,1] # 35
    bitmap[9] = [1,3,0,2]
    bitmap[10] = [2,0,3,1] # 43
    bitmap[11] = [1,3,0,2]
    bitmap[12] = [2,0,3,1] # 51
    bitmap[13] = [1,3,0,2]
    bitmap[14] = [2,0,3,1] # 59
    bitmap[15] = [1,3,0,2]
    
    # 1 rank 
    '''
    bitmap[0] = [3,1,2,0] # 3
    bitmap[1] = [0,2,1,3] # 7
    bitmap[2] = [3,1,2,0] # 11
    bitmap[3] = [0,2,1,3] # 15 
    bitmap[4] = [3,1,2,0] # 19
    bitmap[5] = [0,2,1,3] # 23
    bitmap[6] = [3,1,2,0] # 27
    bitmap[7] = [0,2,1,3] # 31
    bitmap[8] = [3,1,2,0] # 35
    bitmap[9] = [0,2,1,3] # 39
    bitmap[10] = [3,1,2,0] # 43
    bitmap[11] = [0,2,1,3] # 47
    bitmap[12] = [3,1,2,0] # 51
    bitmap[13] = [0,2,1,3] # 55
    bitmap[14] = [3,1,2,0] # 59
    bitmap[15] = [0,2,1,0] # 63
    '''

    return bitmap[chip][bit]

def col_info(col, bit):
    chip = (2*(bit // 64) + ((bit//4)%2))
    burst = bursts[col%8][(bit%64)//8]
    bit_in_BL = bit_index(chip, bit%4)   
    return chip, burst, bit_in_BL

def adjacent(vendor='s', aggr_row=0, victim_row=0, bit=0):
    key = vendor
    
    data_mask = 0b11101011000000111
    inv_mask  = 0b00010100111111000
    bit_mask  = 0b11111111111111111
    
    temp_aggr = aggr_row
    temp_vic = victim_row
    if bit > 255:
        temp_aggr = 0
        temp_vic = 0
        temp_aggr |= aggr_row & data_mask
        temp_aggr |= (~aggr_row) & inv_mask
        temp_aggr &= bit_mask
        
        temp_vic |= victim_row & data_mask
        temp_vic |= (~victim_row) & inv_mask
        temp_vic &= bit_mask
    
    div_aggr = temp_aggr % 16
    div_vic  = temp_vic % 16
    
    index1 = remap[key].index(div_aggr)
    index2 = remap[key].index(div_vic)
    distance = index1-index2
    return distance

if __name__ == '__main__':
    remap = {}
    bursts = {}
    remapping()
    burst_info()
    chunk_size = 100000
    vendor = sys.argv[1]

    if vendor == 's': remaps = [1,3,5,7,0,2,4,6,9,11,13,15,8,10,12,14,17,19,21,23,16,18,20,22,25,27,29,31,24,26,28,30]
    elif vendor == 'h': remaps = [0,8,16,24,2,10,18,26,4,12,20,28,6,14,22,30,1,9,17,25,3,11,19,27,5,13,21,29,7,15,23,31]
    elif vendor == 'm': remaps = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
    for i in range(2, len(sys.argv)):
        file = sys.argv[i]
        for line in read_file_chunks(file, chunk_size):
            
            if 'Opened' in line or 'Successfully' in line : continue
            bank, aggr, vic, col, bit, wr_pttn, _ = map(int,line.strip().split(","))
            judge = adjacent(vendor, aggr, vic, bit)
            chip, burst, bit_in_BL = col_info(col,bit)
            rev_bit = (4*burst + bit_in_BL) # +32*chip

            if chip != 6: continue # data from one chip

            ######################################
            ############     6F2     #############
            ######################################
            if vic >= 4096 and vic < 4096+640: # typical subarray
                typical[wr_pttn] += 1 / N_ROW / N_BIT
            elif vic > 32768 - 640 and vic < 32768: # edge subarray
                edge[wr_pttn] += 1 / N_ROW / N_BIT

    ##############################################
    ###############     plot     #################
    ##############################################
    
    '''
    plt.subplot(121)
    plt.title("Typical subarray", fontsize = 15, weight='bold')
    # plt.ylim([0,0.0002])
    plt.yticks(fontsize=10)
    plt.xticks(range(0, 2), fontsize=10)
    plt.bar([0, 1], typical.values(), width=0.5)
    
    plt.subplot(122)
    plt.title("Edge subarray", fontsize = 15, weight='bold')
    # plt.ylim([0,0.0002])
    plt.yticks(fontsize=10)
    plt.xticks(range(0, 2), fontsize=10)
    plt.bar([0, 1], edge.values(), width=0.5)
    '''
    x_axis = ['0/1', '1/0']
    plt.bar([i-0.175 for i  in range(2)], typical, width=0.35, alpha=0.8, color='blue', label='Typical')
    plt.bar([i+0.175 for i  in range(2)], edge, width=0.35, alpha=0.8, color='orange', label='Edge')
    plt.yticks(fontsize=10)
    plt.xticks(range(2), x_axis, fontsize=10)
    plt.xlabel('Aggressor row data / Victim row data')
    
    
    plt.legend()
    plt.tight_layout()
    
    plt.savefig('./figure_10.png')
    plt.cla()


import os, sys
import matplotlib.pyplot as plt

count = 200000

RD_DATA = 32
N_ROW = 1024 # num_rows
N_COL = pow(2,10)
N_BIT = 65536 / 16

top5 = []
top5_aggr_dp = []
top5_vic_dp = []
bot5 = []
bot5_aggr_dp = []
bot5_vic_dp = []
vic_00 = 0
vic_ff = 0

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

def permute(org, vector):
    result = 0
    result += (org & 0x1) << vector[0] 
    result += ((org & 0x2) >> 1) << vector[1]
    result += ((org & 0x4) >> 2) << vector[2]
    result += ((org & 0x8) >> 3) << vector[3]
    return result

if __name__ == '__main__':
    remap = {}
    bursts = {}
    remapping()
    burst_info()
    chunk_size = 100000
    vendor = sys.argv[1]
    file_dir = sys.argv[2]
    files = os.listdir(file_dir)

    for tmp_file in files:
        n = 0
        file = os.path.join(file_dir, tmp_file)
        for line in read_file_chunks(file, chunk_size):

            if 'Opened' in line or 'Successfully' in line : continue

            bank, aggr, vic, col, bit, wr_pttn, _ = map(int,line.strip().split(","))
            chip, burst, bit_in_BL = col_info(col,bit)

            if chip != 6: continue # data from one chip
            n+=1
        
        if not top5: top5.insert(0, n)
        if not bot5: bot5.insert(0, n)
        if file.split('/')[-1].split('_')[-2].split('aggr')[-1] == "ffffffff" and file.split('/')[-1].split('_')[-1].split('vic')[-1] == "0":
            vic_00 = n
        elif file.split('/')[-1].split('_')[-2].split('aggr')[-1] == "0" and file.split('/')[-1].split('_')[-1].split('vic')[-1] == "ffffffff":
            vic_ff = n
        
        m = 0
        for i in top5:
            if i < n: 
                top5.insert(m, n)
                top5_aggr_dp.insert(m, file.split('/')[-1].split('_')[-2].split('aggr')[-1])
                top5_vic_dp.insert(m, file.split('/')[-1].split('_')[-1].split('vic')[-1])
                break
            m += 1

        m = 0
        for i in bot5:
            if i > n:
                bot5.insert(m, n)
                bot5_aggr_dp.insert(m, file.split('/')[-1].split('_')[-2].split('aggr')[-1])
                bot5_vic_dp.insert(m, file.split('/')[-1].split('_')[-1].split('vic')[-1])
                break
            m+=1

    top5_vic = []
    top5_aggr = []
    bot5_vic = []
    bot5_aggr = []
    for i in range(5):
        top5_vic.append(str(hex(permute(int(top5_vic_dp[i][-1], 16), [2,0,3,1]))))
        top5_aggr.append(str(hex(permute(int(top5_aggr_dp[i][-1], 16), [2,0,3,1]))))
        bot5_vic.append(str(hex(permute(int(bot5_vic_dp[i][-1], 16), [2,0,3,1]))))
        bot5_aggr.append(str(hex(permute(int(bot5_aggr_dp[i][-1], 16), [2,0,3,1]))))

    ##############################################
    ###############     plot     #################
    ##############################################
    plt.title("Top5 and Bottom5", fontsize = 15, weight='bold')
    # plt.ylim([0,0.0002])
    plt.yticks(fontsize=10)
    plt.xticks(fontsize=10)
    plt.bar(["0x0\n0xf","0xf\n0x0", top5_vic[0]+"\n"+top5_aggr[0], top5_vic[1]+"\n"+top5_aggr[1], top5_vic[2]+"\n"+top5_aggr[2], top5_vic[3]+"\n"+top5_aggr[3], top5_vic[4]+"\n"+top5_aggr[4], 
                bot5_vic[4]+"\n"+bot5_aggr[4], bot5_vic[3]+"\n"+bot5_aggr[3], bot5_vic[2]+"\n"+bot5_aggr[2], bot5_vic[1]+"\n"+bot5_aggr[1], bot5_vic[0]+"\n"+bot5_aggr[0]], 
            [vic_00 / N_ROW / N_BIT, vic_ff / N_ROW / N_BIT, top5[0] / N_ROW / N_BIT, top5[1] / N_ROW / N_BIT, top5[2] / N_ROW / N_BIT, top5[3] / N_ROW / N_BIT, top5[4] / N_ROW / N_BIT, 
                bot5[4] / N_ROW / N_BIT, bot5[3] / N_ROW / N_BIT, bot5[2] / N_ROW / N_BIT, bot5[1] / N_ROW / N_BIT, bot5[0] / N_ROW / N_BIT], 
            width=0.5)

    plt.tight_layout()
    
    plt.savefig('./figure_16.png')
    plt.cla()

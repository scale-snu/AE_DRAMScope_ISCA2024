import os, sys
import matplotlib.pyplot as plt

count = 200000

RD_DATA = 32
N_ROW = 1024 # num_rows
N_COL = pow(2,10)
N_BIT = 65536 / 16

k = 5
top = []
top_aggr_dp = []
top_vic_dp = []
bot = []
bot_aggr_dp = []
bot_vic_dp = []
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

def inverse_permute(org, vector):
    result = 0
    for i in range(8):
        result += ((org >> (4*i + 0))%2) << (vector.index(0) + 4*i)
        result += ((org >> (4*i + 1))%2) << (vector.index(1) + 4*i)
        result += ((org >> (4*i + 2))%2) << (vector.index(2) + 4*i)
        result += ((org >> (4*i + 3))%2) << (vector.index(3) + 4*i)
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
    bitmap_chip = [0,2,1,3]

    #if   vendor == 's': remaps = [0,4,8,12,1,5,9,13,2,6,10,14,3,7,11,15,16,20,24,28,17,21,25,29,18,22,26,30,19,23,27,31]
    if   vendor == 's': remaps = [0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31]
    elif vendor == 'h': remaps = [0,8,16,24,2,10,18,26,4,12,20,28,6,14,22,30,1,9,17,25,3,11,19,27,5,13,21,29,7,15,23,31]
    elif vendor == 'm': remaps = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
    
    for tmp_file in files:
        n = 0
        file = os.path.join(file_dir, tmp_file)
        if 'ba0_ra8k_' not in file: continue 
        
        for line in read_file_chunks(file, chunk_size):

            if 'Opened' in line or 'Successfully' in line : continue

            bank, aggr, vic, col, bit, wr_pttn, _ = map(int,line.strip().split(","))
            chip, burst, bit_in_BL = col_info(col,bit)

            if chip != 0: continue # data from one chip
            
            n+=1
        
        if not top: top.insert(0, n)
        if not bot: bot.insert(0, n)
        if file.split('/')[-1].split('_')[-2].split('aggr')[-1] == "ffffffff" and file.split('/')[-1].split('_')[-1].split('vic')[-1].split('.')[0] == "0":
            vic_00 = n
        elif file.split('/')[-1].split('_')[-2].split('aggr')[-1] == "0" and file.split('/')[-1].split('_')[-1].split('vic')[-1].split('.')[0] == "ffffffff":
            vic_ff = n
        if file.split('/')[-1].split('_')[-1].split('vic')[-1].split('.')[0] == "ffffffff": continue
        
        m = 0
        for i in top:
            if i < n: 
                top.insert(m, n)
                top_aggr_dp.insert(m, file.split('/')[-1].split('_')[-2].split('aggr')[-1])
                top_vic_dp.insert(m, file.split('/')[-1].split('_')[-1].split('vic')[-1].split('.')[0])
                break
            m += 1

        m = 0
        for i in bot:
            if i > n:
                bot.insert(m, n)
                bot_aggr_dp.insert(m, file.split('/')[-1].split('_')[-2].split('aggr')[-1])
                bot_vic_dp.insert(m, file.split('/')[-1].split('_')[-1].split('vic')[-1].split('.')[0])
                break
            m+=1

    top_vic = []
    top_aggr = []
    bot_vic = []
    bot_aggr = []
    for i in range(k):
        val_top_vic  = inverse_permute(int(top_vic_dp  [i][-8:], 16), bitmap_chip)
        val_top_aggr = inverse_permute(int(top_aggr_dp [i][-8:], 16), bitmap_chip)
        val_bot_vic  = inverse_permute(int(bot_vic_dp  [i][-8:], 16), bitmap_chip)
        val_bot_aggr = inverse_permute(int(bot_aggr_dp [i][-8:], 16), bitmap_chip)
        
        remap_top_vic  = 0
        remap_top_aggr = 0
        remap_bot_vic  = 0
        remap_bot_aggr = 0
        
        for j in range(32):
            remap_top_vic  += ((val_top_vic  >> j)%2) << remaps[j]
            remap_top_aggr += ((val_top_aggr >> j)%2) << remaps[j]
            remap_bot_vic  += ((val_bot_vic  >> j)%2) << remaps[j]
            remap_bot_aggr += ((val_bot_aggr >> j)%2) << remaps[j]
        
        top_vic.append (str(hex(remap_top_vic %256)))
        top_aggr.append(str(hex(remap_top_aggr%256)))
        bot_vic.append (str(hex(remap_bot_vic %256)))
        bot_aggr.append(str(hex(remap_bot_aggr%256)))

    ##############################################
    ###############     plot     #################
    ##############################################
    plt.title("Top and Bottom5", fontsize = 15, weight='bold')
    plt.yticks([0.2*i for i in range(9)],fontsize=10)
    plt.ylim([0,1.6])
    plt.xticks(fontsize=10)
    
    for i in range(k):
        top[i] = top[i]/vic_00
        bot[i] = bot[i]/vic_00
         
    x = ["0x00\n0xff","0xff\n0x00"]
    y = [vic_00/vic_00, vic_ff/vic_00]
    
    for i in range(k):
        x.append(top_vic[i]+"\n"+top_aggr[i])
        y.append(top[i])
    x.append("...")
    y.append(0)
    for i in range(k):
        x.append(bot_vic[k-1-i]+"\n"+bot_aggr[k-1-i])
        y.append(bot[k-1-i])
    
    plt.bar(x,y, width=0.5)
    plt.xlabel("Victim row data\nAggressor")
    plt.tight_layout()
    
    plt.savefig('./figure_16.png')
    plt.cla()




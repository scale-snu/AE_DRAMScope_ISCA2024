
import os, sys

filename = "run_.sh"
exe = "Rowhammer"

device="s16_00"
vendor = 's'
celcius= '75c'
num_banks = 1
tRASs = [1]
tRPs  = [1]
iter = [600000]
edge_subarray_rows = [i for i in range(4096, 4096+640)] + [i for i in range(32768-640, 32768)]
rows = range(1024)
type = 'rowhammer'


path=f'./data/DRAMScope/{type}/{device}'

bitmap_chip6 = [1,3,0,2]#[2,0,3,1] # 27

    

def permute(org, vector):
    result = 0
    for i in range(8):
        result += ((org >> (4*i + 0))%2) << (vector[0] + 4*i)
        result += ((org >> (4*i + 1))%2) << (vector[1] + 4*i)
        result += ((org >> (4*i + 2))%2) << (vector[2] + 4*i)
        result += ((org >> (4*i + 3))%2) << (vector[3] + 4*i)
    result = org
    return result

if   vendor == 's': remaps = [0,4,8,12,1,5,9,13,2,6,10,14,3,7,11,15,16,20,24,28,17,21,25,29,18,22,26,30,19,23,27,31]
elif vendor == 'h': remaps = [0,8,16,24,2,10,18,26,4,12,20,28,6,14,22,30,1,9,17,25,3,11,19,27,5,13,21,29,7,15,23,31]
elif vendor == 'm': remaps = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]

def remap_swizzling(input, swizzling):
    result = 0
    for i in range(32):
        result  += (input >> i)%2 << remaps[i]
    return result


aggr_pttn = [permute(remap_swizzling(0x11111111*i, remaps),bitmap_chip6) for i in range(16)]

vic_pttn  = [permute(remap_swizzling(0x11111111*i, remaps),bitmap_chip6) for i in range(16)]

line = ''

for tRAS in tRASs:
    for tRP in tRPs:
        for count in iter:
            for bank in range(0, num_banks):
                for aggr in aggr_pttn:
                    aggr = hex(aggr)[2:]
                    for vic in vic_pttn: 
                        vic = hex(vic)[2:]
                        #line += f'rm -f {path}/{count}/{tRAS}tRAS_{tRP}tRP/{celcius}/ba{bank}_ra{0}k_aggr{aggr}_vic{vic}.csv ;\n'
                        line += f'rm -f {path}/{count}/{tRAS}tRAS_{tRP}tRP/{celcius}/ba{bank}_ra{4}k_aggr{aggr}_vic{vic}.csv ;\n'
                        line += f'rm -f {path}/{count}/{tRAS}tRAS_{tRP}tRP/{celcius}/ba{bank}_ra{31}k_aggr{aggr}_vic{vic}.csv ;\n'

## edge subarray
for tRAS in tRASs:
    for tRP in tRPs:
        for count in iter:
            line += f'mkdir -p {path}/{count}/{tRAS}tRAS_{tRP}tRP/{celcius} ;\n'
            for aggr in aggr_pttn:
                if (aggr != 0x0) and (aggr != 0xffffffff): continue
                aggr = hex(aggr)[2:]
                for vic in vic_pttn: 
                    vic = hex(vic)[2:]
                    if ((aggr == '0') and (vic == 'ffffffff')) or ((aggr == 'ffffffff') and (vic == '0')): 
                        for bank in range(0, num_banks):
                            for row in edge_subarray_rows:
                                cmd = f'sudo ./{exe} -aggr {row} -bank {bank} -iter {count} -tRAS {tRAS} -tRP {tRP} '
                                cmd += f'-aggr_dp {aggr} -vic_dp {vic} -vendor {vendor} '
                                cmd += f'>> {path}/{count}/{tRAS}tRAS_{tRP}tRP/{celcius}/'
                                cmd += f'ba{bank}_ra{(row)//1024}k_aggr{aggr}_vic{vic}.csv'

                                if row%512==0:
                                    line += f'date +%x%X ;\n'
                                    line += f'echo \"{cmd} \" ;\n'
                                    
                                line += f'{cmd} ;\n'
'''
## all patterns                            
for tRAS in tRASs:
    for tRP in tRPs:
        for count in iter:
            line += f'mkdir -p {path}/{count}/{tRAS}tRAS_{tRP}tRP/{celcius} ;\n'
            for aggr in aggr_pttn:
                aggr = hex(aggr)[2:]
                for vic in vic_pttn: 
                    vic = hex(vic)[2:]
                    for bank in range(0, num_banks):
                        for row in rows:
                            cmd = f'sudo ./{exe} -aggr {row} -bank {bank} -iter {count} -tRAS {tRAS} -tRP {tRP} '
                            cmd += f'-aggr_dp {aggr} -vic_dp {vic} -vendor {vendor} '
                            cmd += f'>> {path}/{count}/{tRAS}tRAS_{tRP}tRP/{celcius}/'
                            cmd += f'ba{bank}_ra{(row)//1024}k_aggr{aggr}_vic{vic}.csv'

                            if row%512==0:
                                line += f'date +%x%X ;\n'
                                line += f'echo \"{cmd} \" ;\n'
                                
                            line += f'{cmd} ;\n'
'''
f = open(filename, 'w')
f.write(line)
f.close()

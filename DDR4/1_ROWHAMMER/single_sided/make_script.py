
import os, sys

filename = "run_.sh"
exe = "Rowhammer"

device="s21_00"
vendor = 's'
celcius= '75c'
num_banks = 1
tRASs = [1]
tRPs  = [1]
iter = [300000]
rows = [i for i in range(8192, 8192+1024)] + [i for i in range(32768-1024, 32768)]
type = 'rowhammer'


path=f'./data/DRAMScope/{type}/{device}'

remaps = [0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31]
bitmap_chip = [0,3,1,2]

def permute(org, vector):
    result = 0
    for i in range(8):
        result += ((org >> (4*i + 0))%2) << (vector[0] + 4*i)
        result += ((org >> (4*i + 1))%2) << (vector[1] + 4*i)
        result += ((org >> (4*i + 2))%2) << (vector[2] + 4*i)
        result += ((org >> (4*i + 3))%2) << (vector[3] + 4*i)
    return result

aggr_pttn = [0 for i in range(16)]
vic_pttn  = [0 for i in range(16)]
for i in range(16):
    pttn = 0x11111111 * i
    remap_pttn = 0
    for j in range(32):
        remap_pttn  += (pttn  >> j)%2 << remaps.index(j)
    remap_pttn = permute(remap_pttn, bitmap_chip)
    aggr_pttn[i] = remap_pttn
    vic_pttn[i] = remap_pttn

for pttn in aggr_pttn:
    print(hex(pttn))
line = ''

for tRAS in tRASs:
    for tRP in tRPs:
        for count in iter:
            for bank in range(0, num_banks):
                for aggr in aggr_pttn:
                    aggr = hex(aggr)[2:]
                    for vic in vic_pttn: 
                        vic = hex(vic)[2:]
                        line += f'rm -f {path}/{count}/{tRAS}tRAS_{tRP}tRP/{celcius}/ba{bank}_ra{8}k_aggr{aggr}_vic{vic}.csv ;\n'
                        line += f'rm -f {path}/{count}/{tRAS}tRAS_{tRP}tRP/{celcius}/ba{bank}_ra{31}k_aggr{aggr}_vic{vic}.csv ;\n'

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

f = open(filename, 'w')
f.write(line)
f.close()


import os, sys

filename = "run_.sh"
exe = "Rowhammer"

device="s17_00"
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


line = ''

aggr_pttn = [0x11111111*i for i in range(16)]
             
vic_pttn = [0x11111111*i for i in range(16)]

for tRAS in tRASs:
    for tRP in tRPs:
        for count in iter:
            for bank in range(0, num_banks):
                for aggr in aggr_pttn:
                    aggr = hex(aggr)[2:]
                    for vic in vic_pttn: 
                        vic = hex(vic)[2:]
                        line += f'rm -f {path}/{count}/{tRAS}tRAS_{tRP}tRP/{celcius}/ba{bank}_ra{0}k_aggr{aggr}_vic{vic}.csv ;\n'
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

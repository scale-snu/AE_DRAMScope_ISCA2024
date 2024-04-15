
import os, sys

filename = "run_.sh"
exe = "Rowpress"

device="s16_00"
vendor = 's'
celcius= '75c'
num_banks = 1
tRASs = [1300] # 7.8us
tRPs  = [1]
iter = [8000]
rows = [i for i in range(1024)]
type = 'rowpress'


path=f'./data/DRAMScope/{type}/{device}'


line = ''

aggr_pttn = [0x0, 0xffffffff]
             
vic_pttn = [0x0, 0xffffffff]

for tRAS in tRASs:
    for tRP in tRPs:
        for count in iter:
            line += f'mkdir -p {path}/{count}/{tRAS}tRAS_{tRP}tRP/{celcius} ;\n'
            for aggr in aggr_pttn: 
                aggr = hex(aggr)[2:]
                for vic in vic_pttn: 
                    vic = hex(vic)[2:]
                    if ((aggr == '0') and (vic == 'ffffffff')) or ((aggr == 'ffffffff') and (vic == '0')): 
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

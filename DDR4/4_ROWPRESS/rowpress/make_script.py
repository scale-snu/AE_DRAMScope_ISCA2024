
import os, sys

filename = "run_.sh"
exe = "Rowpress"

device="s17_00"
vendor = 's'
celcius= '75c'
num_banks = 1
tRASs = [7800] # 7.8us
tRPs  = [1]
iter = [8000]
rows = [i for i in range(640)]
type = 'rowpress'


path=f'./data/DRAMScope/{type}/{device}'

n = 0
line = ''

# aggr_pttn = [0x00000000, 0xF000F000, 0x0F000F00, 0x00F000F0, 0x000F000F, 
             
#              0xFFFFFFFF, 0x0FFF0FFF, 0xF0FFF0FF, 0xFF0FFF0F, 0xFFF0FFF0 ]
             
# vic_pttn = [0xFFFFFFFF, 0x0FFF0FFF, 0xF0FFF0FF, 0xFF0FFF0F, 0xFFF0FFF0,
            
#             0x00000000, 0xF000F000, 0x0F000F00, 0x00F000F0, 0x000F000F]
aggr_pttn = [0x0, 0xffffffff]
             
vic_pttn = [0x0, 0xffffffff]

for tRAS in tRASs:
    for tRP in tRPs:
        for count in iter:
            for aggr, vic in aggr_pttn, vic_pttn: 
                aggr = hex(aggr)[2:]
                vic = hex(vic)[2:]
                for bank in range(0, num_banks):
                    for row in rows:
                        for bank in range(0, num_banks):
                            line += f'mkdir -p {path}/{count}/{tRAS}tRAS_{tRP}tRP/{celcius} ;\n'

                            cmd = f'sudo ./{exe} -aggr {row} -bank {bank} -iter {count} -tRAS {tRAS} -tRP {tRP} '
                            cmd += f'-aggr_dp {aggr} -vic_dp {vic} -vendor {vendor} '
                            cmd += f'>> {path}/{count}/{tRAS}tRAS_{tRP}tRP/{celcius}/'
                            cmd += f'ba{bank}_ra{(row)//1024}k_aggr{aggr}_vic{vic}.csv'

                            if row%512==0:
                                line += f'date +%x%X ;\n'
                                line += f'echo \"{cmd} \" ;\n'
                                
                            line += f'{cmd} ;\n'
                            n += 1

f = open(filename, 'w')
f.write(line)
f.close()

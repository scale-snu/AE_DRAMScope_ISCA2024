
import os, sys


if __name__ == '__main__':
    filename = "run_.sh"
    exe = "Rowhammer"
    dir_path = os.path.dirname(os.path.realpath(__file__))
    row_idx = 1024 
    pc = 0
    bg = 0
    ba = 0
    extra = 0
    freq = 0

    iter = [600000]
    rows = range(0,row_idx)

    line = ''
    vic_pttn = [0xFF, 0x00]

    for count in iter:
        for vic in vic_pttn:
            aggr = hex((~vic)%256)[2:]
            vic = hex(vic)[2:]
            for row in range(0, row_idx, row_idx):
                cmd = f'rm -f {dir_path}/{count}/'
                cmd += f'ba{ba}_ra{(row)//row_idx}k_aggr{aggr}_vic{vic}'
                line += f'{cmd} ;\n'

    
    for count in iter:
        line += f'mkdir -p {dir_path}/{count} ;\n'
        for vic in vic_pttn:
            aggr = hex((~vic)%256)[2:]
            vic = hex(vic)[2:]
            for row in rows:
                if row % row_idx == 0:
                    line += f"echo \"aggr_row,row,pc,bg,ba,col,bit,data\" > {dir_path}/{count}/ba{ba}_ra{(row)//1024}k_aggr{aggr}_vic{vic} ;"
                cmd = f'sudo ./{exe} {count} {row} {pc} {bg} {ba} 0x{vic} '
                cmd += f'>> {dir_path}/{count}/'
                cmd += f'ba{ba}_ra{(row)//1024}k_aggr{aggr}_vic{vic}'

                if row%100==0:
                    line += f'date +%x%X ;\n'
                    line += f'echo \"{cmd} \" ;\n'
                    
                line += f'{cmd} ;\n'
    ########################################



    f = open(filename, 'w')
    f.write(line)
    f.close()
	#return_value = os.system(f"sudo bash {filename} ;")

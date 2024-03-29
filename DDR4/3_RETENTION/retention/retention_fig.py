import os, sys
import matplotlib.pyplot as plt

count = 200000
x = []
y = []

def read_file_chunks(file_path, chunk_size=2):
    with open(file_path, 'r') as log_file:
        while True:
            lines = log_file.readlines(chunk_size)
            if not lines:
                break
            for line in lines:
                yield line

if __name__ == '__main__':
    chunk_size = 100000
    output = "true_anti"
    
    ba = 0
    file = sys.argv[1]
    for line in read_file_chunks(file, chunk_size):
        bank, row, col, bit, rev_bit = map(int,line.strip().split(",")) 
        chip = (2*(bit // 64) + ((bit//4)%2))
        x.append(4096*chip + 32*col + rev_bit)
        y.append(row)

    ##############################################
    ###########    Scatter plot     ##############
    ##############################################
    plt.scatter(x, y, s=0.2, c='orange')
    plt.savefig(f'./{output}.png')
    plt.cla()

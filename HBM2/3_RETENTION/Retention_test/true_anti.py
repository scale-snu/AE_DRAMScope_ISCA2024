import os, sys
import matplotlib.pyplot as plt
import seaborn as sns


def read_file_chunks(file_path, chunk_size=10000):
    with open(file_path, 'r') as log_file:
        while True:
            lines = log_file.readlines(chunk_size)
            if not lines:
                break
            for line in lines:
                yield line

if __name__ == '__main__':
  rows = range(8192)
  dir_path = os.path.dirname(os.path.realpath(__file__))
  retention0_file = f"{dir_path}/log/retention_data0_60s.csv"
  retention1_file = f"{dir_path}/log/retention_data1_60s.csv"
  
  flip0 = [0 for i in rows]
  flip1 = [0 for i in rows]

  for line in read_file_chunks(retention0_file):
    if "a" not in line:
      pc, bg, ba, row, col, bit = map(int,line.strip().split(",")) 
      flip0[row] += 1
  
  for line in read_file_chunks(retention1_file):
    if "a" not in line:
      pc, bg, ba, row, col, bit = map(int,line.strip().split(",")) 
      flip1[row] += 1  
  
  true_cell = [0 for i in rows]
  anti_cell = [0 for i in rows]
  
  for row in rows:
    if flip0[row] > flip1[row]:
      anti_cell[row] = 1
    elif flip0[row] < flip1[row]:
      true_cell[row] = 1

  ##############################################
  # barh plot 
  ############################################## 
  plt.title('Distribution of true-/anti-cells')
  plt.ylabel("Row address")
  plt.barh(y=rows, width=true_cell, color='royalblue', height=0.2)
  plt.barh(y=rows, width=anti_cell, color='orange', height=0.2)
  plt.yticks(range(0,8000+1,1000))
  plt.xticks([0,1])
  

  plt.savefig(f'section_3.svg')
  plt.cla()
  

            
  

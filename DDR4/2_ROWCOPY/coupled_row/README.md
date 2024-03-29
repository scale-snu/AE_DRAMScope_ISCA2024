# Find coupled row

## Run
```
$ make
$ sudo ./run.sh
```

## Instructions
```
sudo ./Rowcopy [-src src] [-dst dst] [-wait wait] [-bank bank] [-src_dp src_dp] [-dst_dp dst_dp] [-vendor vendor]
          -src src                 : source row address
          -dst dst                 : destination row address
          -wait wait               : PRE to ACT time interval in rowcopy operation
          -bank bank               : bank address
          -src_dp src_dp           : source row data pattern
          -dst_dp dst_dp           : destination row data pattern
          -vendor vendor           : DRAM vendor (e.g., s, h, m)
```

## Table 3
Open `coupled_row.txt`.
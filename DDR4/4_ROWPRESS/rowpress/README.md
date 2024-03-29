# RowPress

## Run (15 min)
```
$ make
$ sudo ./run.sh
```

## Instructions

```
$ sudo ./Rowpress [-aggr aggressor] [-bank bank] [-iter iter] [-tRAS tRAS] [-tRP tRP] [-vic_dp vic_dp] [-aggr_dp aggr_dp] [-vendor vendor]
          -aggr aggressor            : aggressor row address
          -bank bank                 : bank address
          -iter iter                 : hammer count
          -tRAS tRAS                 : additive tRAS (default: 7800)
          -tRP tRP                   : additive tRP (default: 1)
          -vic_dp vic_dp             : victim row data pattern in hex
          -aggr_dp aggr_dp           : aggressor row data pattern in hex
          -vendor vendor             : DRAM vendor (e.g., s, h, m)
```

## Figure 12

1. Make a figure.
```
$ bash figure_12.sh
```
2. open `figure_12.png`

## Figure 13

1. Make a figure.
```
$ bash figure_13.sh
```
2. open `figure_13.png`
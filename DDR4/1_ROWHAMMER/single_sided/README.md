# Single-sided RowHammer attack

## Run (3 hours)
```
$ make
$ sudo ./run.sh
```


## Instructions

```
$ sudo ./Rowhammer [-aggr aggressor] [-bank bank] [-iter iter] [-tRAS tRAS] [-tRP tRP] [-vic_dp vic_dp] [-aggr_dp aggr_dp] [-vendor vendor]
          -aggr aggressor            : aggressor row address
          -bank bank                 : bank address
          -iter iter                 : hammer count
          -tRAS tRAS                 : additive tRAS (default: 1)
          -tRP tRP                   : additive tRP (default: 1)
          -vic_dp vic_dp             : victim row data pattern in hex
          -aggr_dp aggr_dp           : aggressor row data pattern in hex
          -vendor vendor             : DRAM vendor (e.g., s, h, m)
```

## Figure 10

1. Make a figure
```
$ ./figure_10.sh
```
2. open `figure_10.png`

## Figure 12

1. Make a figure
```
$ ./figure_12.sh
```
2. open `figure_12.png`

## Figure 13
1. Make a figure
```
$ ./figure_13.sh
```
2. open `figure_13.png`

## Figure 16
1. Make a figure
```
$ ./figure_16.sh
```
2. open `figure_16.png`
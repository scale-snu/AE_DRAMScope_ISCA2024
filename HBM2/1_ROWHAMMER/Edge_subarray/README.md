# BER distribution across subarrays.
Reproducing "BER across subarrays" (***Fig. 10***).

## Run

1. Run the RowHammer attack .
```
$ make
$ sudo ./run.sh
```

## Instructions
```
sudo ./Rowhammer [HAMMER COUNT] [aggressor row] [pseudo channel] [bank group] [bank] [data pattern]
          HAMMER COUNT         : hammering count
          Aggressor row        : aggressor row address
          pseudo channel       : pseudo channel address
          bank group           : bank group address
          bank                 : bank address
          data pattern         : victim row data pattern in hex
```

## Figure 10

1. Make a figure.
```
$ bash figure_10.sh
```
2. Open `figure_10.png`.

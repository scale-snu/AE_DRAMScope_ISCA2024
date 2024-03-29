# BER analysis across 6F<sup>2</sup>. 
Reproducing "BER across gate types" (***Fig. 12 and 13***).

## Run

1. Run the RowPress attack .
```
$ make
$ sudo ./run.sh
```

## Instructions
```
sudo ./RowPress [HAMMER COUNT] [aggressor row] [pseudo channel] [bank group] [bank] [data pattern]
          HAMMER COUNT         : hammering count
          Aggressor row        : aggressor row address
          pseudo channel       : pseudo channel address
          bank group           : bank group address
          bank                 : bank address
          data pattern         : victim row data pattern in hex
```

# Figure 12
1. Make a figure.
```
$ bash figure_12.sh
```
2. Open `figure_12.png`

# Figure 13

```
$ bash figure_13.sh
```
3. Open `figure_13.png`.


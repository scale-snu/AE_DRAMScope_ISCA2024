# Retention time test

## Run (2 min)

```
$ make
$ sudo ./run.sh
```

## Instructions

```
sudo ./Retention [-start start] [-bank bank] [-num_rows num_rows] [-sleep sleep]
          -start start               : start row address
          -bank bank                 : bank address
          -num_rows num_rows         : # of rows
          -sleep sleep               : retention time [us]
```

## Figure
1. Make a figure.
```
$ ./section_3.sh
```
2. Open `true_anti.png`. If there are consists only of true-cells, a single color appears in the graph, while if there are true-/anti-cells present, it manifests as a striped pattern.

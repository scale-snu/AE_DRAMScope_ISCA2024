# Simple test for SoftMC 

This ***Simple_test*** must be executed first after programming the bitfile in the FPGA and rebooting. When executing ***Simple_test***, the mode register is set and basic write and read operations are performed.

### Run
```
$ make
$ sudo ./run.sh
```

### Check the result
1. If the following screen appears after the experiment, it is successful.
```
The FPGA has been opened successfully! 

            |Pseudo channel 1||Pseudo channel 0|
[OUTPUT   0]:                0 1111111111111111 
[OUTPUT   1]:                0 2222222222222222 
[OUTPUT   2]:                0 3333333333333333 
[OUTPUT   3]: 4444444444444444                0 
[OUTPUT   4]: 5555555555555555                0 
[OUTPUT   5]: 6666666666666666                0 

=====================
===    Success    ===
=====================
```



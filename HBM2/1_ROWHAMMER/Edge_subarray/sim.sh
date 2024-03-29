#!/bin/bash

date "+%x%X"

for row in 16
do
  for count in 100000
  do 
    for group in {0..3}
    do
      for bank in {0..3}
      do
        date "+%x%X"
        echo "sudo ./rowhammer_test ${count}0 $row 0 $group $bank > log/$count/hammer.000.$row.$count.txt"
        sudo ./rowhammer_test ${count}0 $row 0 $group $bank > log/$count/hammer.000.$row.$count.txt
        echo "$count $row"
      done
    done
  done
done

for row in {1000..16000..1000}
do
  for count in 300000
  do 
    for group in 0 #{0..3}
    do
      for bank in 0 #{0..3}
      do
        date "+%x%X"
        echo "sudo ./rowhammer_test ${count}0 $row 0 $group $bank > log/$count/hammer.000.$row.$count.txt"
        sudo ./rowhammer_test ${count}0 $row 0 $group $bank > log/$count/hammer.000.$row.$count.txt
        echo "$count $row"
      done
    done
  done
done

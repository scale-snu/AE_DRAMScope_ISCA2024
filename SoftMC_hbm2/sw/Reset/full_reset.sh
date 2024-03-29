#!/bin/bash

($( dirname "${BASH_SOURCE[0]}" )/Flush) &
pid=$!

sleep 2

kill -9 $pid

#!/bin/bash

a=100
b=devops

echo ${a}times
echo $b

DATE=2022-03-10
echo Today date is $DATE


DATE=$(date+%F)
echo Today date is $DATE

x=10
y=20
ADD=$(($x+$y))
echo Add = $ADD

# SCALAR
c=10

# ARRAYS
c=(10 20 "small large")
echo First Value of Array = ${c[0]}
echo Third Value of Array = ${c[2]}
echo All Value of Array = ${c[*]}

echo Training = ${TRAINING}
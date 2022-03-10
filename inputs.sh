#!/bin/bash

read -p 'Enter your name:' name
echo "Your name = $name"

# Special Variables
# $0-$n, $* or $@ (yields same thing), $#,
echo Script Name $0
echo First Argument $1
echo All Arguments $*
echo Number of Arguments $#


#!/bin/bash

# the day of week calculation at https://www.tondering.dk/claus/cal/chrweek.php
# includes expressions

# a=(14-month)/12 : indicator of if a month is before March vs March or later.
# y=(year - a) : current year for March and later, otherwise previous year
# m=month + 12*a -2 : enumerate months starting with March == 1
# then for the Julian calendar
# d=(5 + day + y + y/4 + 31*m/12) %7
# or for the Gregorian calendar
# d=(day + y + y/4 - y/100 + y/400 + 31*m/12) %7

# The purpose of this script is to understand the mystery expression: (31*m/12) % 7
# For months Jan-Dec, this expression results in values
# 0 3 2 5 0 3 5 1 4 6 2 4

# which are the day of week offsets (Sunday == 0) for the first day of
# each month of a non-leap year. The expressions with y account for the leap year adjustment.

# Many day of week calculations use a per-month table of values like this so how did someone
# figure out such a simple formula?

# this script brute forces 
# start with, and the ratio values in the mystery expression to see which ones
# yield the sequence of values.

# Desired offsets (Jan-Dec)
offsets=(0 3 2 5 0 3 5 1 4 6 2 4)

for ((i=1; i<100; i++)); do
    for ((j=1; j<100; j++)); do
        for ((off=0; off<12; off++)); do # offset
            testoffset=(
                $( for((month=1; month<=12; month++)); do
                       a=$(( (12+$off-$month)/12 ))
                       m=$(( $month + 12*${a} - ${off} ))
                       printf "%d " $(( i*m/j % 7 ))
                   done ) )
            if [[ "${testoffset[*]}" == "${offsets[*]}" ]]; then
                echo i=$i j=$j "($i*m/$j)" offset=$off offset array="${testoffset[*]}"
            fi
        done
    done
done

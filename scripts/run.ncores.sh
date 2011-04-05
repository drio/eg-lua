#!/bin/bash
#
set -e

split -l 461229 input/affy.txt 
$jit $eg_lua ./xaa ./input/soldata.txt > o.xaa &
$jit $eg_lua ./xab ./input/soldata.txt > o.xab &
wait
cat o.xaa o.xab | sort -t, -k2,2n > output.split
rm -f x* o.x*

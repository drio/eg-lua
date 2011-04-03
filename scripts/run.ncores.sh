#!/bin/bash
#
set -e

split -l 461229 input/affy.txt 
../../tmp/luajit-2.0/src/luajit ./eg-lua.lua ./xaa ./input/soldata.txt > o.xaa &
../../tmp/luajit-2.0/src/luajit ./eg-lua.lua ./xab ./input/soldata.txt > o.xab &
wait
cat o.xaa o.xab | sort -t, -k2,2n > output.split
rm -f x* o.x*

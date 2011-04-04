#!/bin/bash
#
set -e

jit=" /Users/drio/tmp/LuaJIT-1.1.6/src/luajit"
probes="/Users/drio/Dropbox/git_repo/eg-lua/input/affy.txt"
reads="/Users/drio/Dropbox/git_repo/rGenotype/data/soldata.txt"
small_probes="/tmp/eg.small_probes.txt"
small_reads="/tmp/eg.small_reads.txt"

head -100000 $probes > $small_probes
head -200000 $reads > $small_reads
time $jit ./eg-lua.lua $small_probes $small_reads |\
sort -t, -k2,2n > output.small.egl
rm -f $small_probes $small_reads

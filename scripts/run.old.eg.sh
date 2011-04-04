#!/bin/bash
#
set -e

old_eg="/Users/drio/Dropbox/git_repo/v1.egenotype/core/eg-counter"
probes="/Users/drio/Dropbox/git_repo/eg-lua/input/affy.txt"
reads="/Users/drio/Dropbox/git_repo/rGenotype/data/soldata.txt"
list="/tmp/tmp.eg.txt"

echo "$reads" > $list
time $old_eg $probes $list output.old 1
cat output.old | sort -t, -k2,2n > o
mv o output.old

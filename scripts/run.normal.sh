#!/bin/bash
#
set -e

probes="/Users/drio/Dropbox/git_repo/eg-lua/input/affy.txt"
reads="/Users/drio/Dropbox/git_repo/rGenotype/data/soldata.txt"

time $jit $eg_lua $probes $reads |\
sort -t, -k2,2n > output.egl

#!/bin/bash
#
set -e

probes="/Users/drio/Dropbox/git_repo/eg-lua/input/affy.txt"
reads="/Users/drio/Dropbox/git_repo/rGenotype/data/soldata.txt"

time /Users/drio/tmp/LuaJIT-1.1.6/src/luajit ./eg-lua.lua $probes $reads |\
sort -t, -k2,2n > output.egl

#!/bin/bash
#
set -e

echo "$reads" > $list
time $old_eg $probes $list output.old 1
cat output.old | sort -t, -k2,2n > o
mv o output.old

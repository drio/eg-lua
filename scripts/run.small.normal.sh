#!/bin/bash
#
set -e
source "`dirname ${BASH_SOURCE[0]}`/common.sh"

head -100000 $probes > $small_probes
head -200000 $reads > $small_reads
time $compiler $eg_lua $small_probes $small_reads |\
sort -t, -k2,2n > output.small.egl
rm -f $small_probes $small_reads

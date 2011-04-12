#!/bin/bash
#
set -e
source "`dirname ${BASH_SOURCE[0]}`/common.sh"

head -10000 $probes > $small_probes
head -20000 $reads > $small_reads
time $compiler $eg_lua $small_probes $small_reads |\
sort -t, -k2,2n > output.small.egl
rm -f $small_probes $small_reads

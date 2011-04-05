#!/bin/bash
#
set -e
source "`dirname ${BASH_SOURCE[0]}`/common.sh"

time $jit $eg_lua $probes $reads | sort -t, -k2,2n > output.egl

#!/bin/bash
#
set -e
source "`dirname ${BASH_SOURCE[0]}`/common.sh"

split -l 461229 $probes
$compiler $eg_lua ./xaa $reads > o.xaa &
$compiler $eg_lua ./xab $reads > o.xab &
wait
cat o.xaa o.xab | sort -t, -k2,2n > output.split
rm -f x* o.x*

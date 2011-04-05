#!/bin/bash
#
set -e

source "`dirname ${BASH_SOURCE[0]}`/common.sh"
lua test_eg.lua

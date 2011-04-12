scripts_path=`dirname ${BASH_SOURCE[0]}`
bin_path="$scripts_path/../bin"
export LUA_PATH="$bin_path/?.lua"

lua="`which lua`"
jit="$HOME/tmp/LuaJIT-1.1.6/src/luajit"
probes="$HOME/Dropbox/git_repo/eg-lua/input/affy.txt"
reads="$HOME/Dropbox/git_repo/rGenotype/data/soldata.txt"
small_probes="/tmp/eg.small_probes.txt"
small_reads="/tmp/eg.small_reads.txt"
old_eg="$HOME/Dropbox/git_repo/v1.egenotype/core/eg-counter"
list="/tmp/tmp.eg.txt"
eg_lua="$bin_path/eg.lua"

# Set the paths so lua can find the profiler
# enable cfg.profile* in the arguments
# Use compiler = lua if you want to enable profiling
profile_lib="$HOME/tmp/luaprofiler-2.0.2/bin/profiler.so"
compiler=$lua
analyzer="$scripts_path/summary.lua"
[ -f $profile_lib ] && export LUA_CPATH="$HOME/tmp/luaprofiler-2.0.2/bin/?.so"

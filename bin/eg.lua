#!/usr/bin/env lua

require("bio")
require("arguments")
require("probes")
require("results")
if cfg.profile_probes or cfg.profile_reads then require("profiler") end
if cfg.profile_probes then io.stderr:write("Probe profiling enabled.\n") end
if cfg.profile_reads then io.stderr:write("Reads profiling enabled.\n") end

local args = arguments.load_them(arg)
io.stderr:write("probe_size:", cfg.probe_size);  

if cfg.profile_probes then profiler.start("probes.profile") end
local hp = probes.load_probes(args)
if cfg.profile_probes then profiler.stop() end

if cfg.profile_reads then profiler.start("reads.profile") end
probes.screen_reads(args, hp)
if cfg.profile_reads then profiler.stop() end

results.show(hp)

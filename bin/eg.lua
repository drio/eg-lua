#!/usr/bin/env lua

require("bio")
require("arguments")
require("probes")
require("results")
if cfg.profile_probes then require("profiler") end

local args = arguments.load_them(arg);
if cfg.profile_probes then io.stderr:write("Probe profiling enabled.\n") end
io.stderr:write("probe_size:", cfg.probe_size);  

if cfg.profile_probes then profiler.start("probes.profile") end
local hp = probes.load_probes(args);
if cfg.profile_probes then profiler.stop() end

probes.screen_reads(args, hp);

results.show(hp)

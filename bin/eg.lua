#!/usr/bin/env lua

require("bio")
require("arguments")
require("probes")
require("results")

local args = arguments.load_them(arg);
io.stderr:write("probe_size:", cfg.probe_size);  
local hp = probes.load_probes(args);
probes.screen_reads(args, hp);
results.show(hp)

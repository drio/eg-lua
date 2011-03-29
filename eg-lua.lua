#!/usr/bin/env lua

local cfg = {};
cfg.print_lines = 100000;
cfg.usage       = "Usage: " .. arg[0] .. " <probes_file> <reads_file>\n"
cfg.flank_size  = 15;
cfg.probe_size  = (cfg.flank_size * 2) + 1;

-- test_input_parameters
function load_arguments(arg)
  local args = { probes_fn=nil, reads_fn=nil };
  local probes_fn = arg[1];
  local reads_fn = arg[2];
  if probes_fn == nil or reads_fn == nil then
    io.stderr:write(cfg.usage);
    os.exit(1); 
  end

  args.probes_fn = probes_fn
  args.reads_fn  = reads_fn
  return args
end

-- Load probes
-- 1	100006955	rs4908018	TTTGTCTAAAACAAC	CTTTCACTAGGCTCA	C	A
function load_probes(args)
  local tmp = {}
  local h = {}
  local p = 0;
  local probe = nil;

  for line in io.lines(args.probes_fn) do
    if p % cfg.print_lines == 0 then io.stderr:write("\rReading probes: ", p) end
    local i = 1;
    for field in line:gmatch("[^\t]+") do
      tmp[i] = field;
      i = i + 1;
    end
    probe          = tmp[4] .. "N" .. tmp[5];
    h[probe]       = {}
    h[probe].chrm  = tmp[1]; h[probe].pos  = tmp[2]
    h[probe].id    = tmp[3]; h[probe].ref  = tmp[6];
    h[probe].var   = tmp[7]; h[probe].hits = nil;
    p = p + 1;
  end
  io.stderr:write("\rReading probes: ", p, "\n");

  return h;
end

-- Screen reads against the probes
function screen_reads(args, probes)
  local i = 0;
  local name = nil;
  local seq  = nil;
  local n_hits = 0;

  -- Given a read and a probe list(table) slides a window (size of the probes)
  -- to look for perfect matches. If there is a hit, it saves it in the table.
  local function slide_over_read(read, pl)
      local i      = 1;
      local slice  = nil;
      local ps     = cfg.probe_size;
      local fs     = cfg.flank_size;
      local n_hits = 0;

      while ps + i <= #read+1 do -- while the window is within the size of the read
        sub_read = read:sub(i, ps+i-1);
        nt_value = sub_read:sub(fs+1, fs+1);
        sub_read = sub_read:sub(1, fs) .. "N" .. sub_read:sub(fs+2);
        if pl[sub_read] then -- We have a probe with that sequence
          if pl[sub_read].hits then -- We have hits for that probe already
            pl[sub_read].hits[nt_value] = pl[sub_read].hits[nt_value] + 1;
          else
            pl[sub_read].hits = {A=0, C=0, G=0, T=0, N=0};
            pl[sub_read].hits[nt_value] = 1;
          end
          n_hits = n_hits + 1
        end
        i = i + 1
      end
      return n_hits;
  end

  for l in io.lines(args.reads_fn) do
    local tmp = l:find("%s"); -- Grab the first string on the line
    if l:byte(1) == 62 or l:byte(1) == 64 then -- ">" || "@"
      i = i + 1;
      name = (tmp and l:sub(2, tmp-1)) or l:sub(2);
      if i % cfg.print_lines == 0 then io.stderr:write("\rProcessing reads: ", i, "|", n_hits) end
    else
      n_hits = n_hits + slide_over_read(l, probes);
    end
  end
  io.stderr:write("\rProcessing reads: ", i, "|", n_hits, "\n");
end

-- Dumps the allele counting per each probe
function show_results(probes)
  for k,v in pairs(probes) do
    if v.hits then
      local h = v.hits
      io.write(string.format("%s,%s,%s,%s,%s,", v.chrm, v.pos, v.id, v.ref, v.var));
      io.write(string.format("%s,%s,%s,%s,%s\n", h.A, h.C, h.G, h.T, h.N));
    end
  end  
end


-------
-- MAIN
-------
io.stderr:write("probe_size:", cfg.probe_size);  
local args = load_arguments(arg);
local probes = load_probes(args);
screen_reads(args, probes);
show_results(probes)

--[[
print("---------");
local test_probe = "TTATCATTCCCTTCCNGATCACCTCTACCAG";
print("test_probe should be", test_probe);  
print(probes["TTATCATTCCCTTCCNGATCACCTCTACCAG"].id);
io.stderr:write("Done.", "\n")
--]]
--                         TTATCATTCCCTTCCNGATCACCTCTACCAG
-- print(slide_over_read("AAAATTATCATTCCCTTCCAGATCACCTCTACCAGAAAA", probes));
